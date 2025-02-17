public with sharing class ND_HSAcknowledgementUpdate {
    
    private static final string Significant_Gift ='SIG';
    private static final string Review ='RV';
    
    @invocableMethod(label='Process Sessions')
    public static void processRecords(List<ID> SesList) {
        Set<Id> creditSet = new Set<Id>();
        creditSet.addAll(SesList);
        List<String> recNumber=new List<String>();
        List<ucinn_ascendv2__Hard_and_Soft_Credit__c> hs=new List<ucinn_ascendv2__Hard_and_Soft_Credit__c>();
        
        // to get record H&S record from flow ID
        For(ucinn_ascendv2__Hard_and_Soft_Credit__c hsrec :[select id,ucinn_ascendv2__Receipt_Number__c,ucinn_ascendv2__Opportunity__c,ucinn_ascendv2__Contact__c,nd_Acknowledgment_Status__c,nd_Acknowledgement_Status_Date__c from ucinn_ascendv2__Hard_and_Soft_Credit__c where ID IN: creditSet])
        {
            if(hsrec.ucinn_ascendv2__Receipt_Number__c!=null)
            {
              recNumber.add(hsrec.ucinn_ascendv2__Receipt_Number__c);  
            }
        }
        //This is to get all the H&s records based on given Rec number, all ack to be updated
        if(recNumber.size()>0)
        {
         hs =[select id,ucinn_ascendv2__Receipt_Number__c,ucinn_ascendv2__Opportunity__c,ucinn_ascendv2__Contact__c,nd_Acknowledgment_Status__c,nd_Acknowledgement_Status_Date__c,
              ucinn_ascendv2__Designation_Code_Formula__c,ucinn_ascendv2__Payment__r.ucinn_ascendv2__Transaction_Type__c,ucinn_ascendv2__Payment__r.ucinn_ascendv2__Adjusted_Gift__c,ucinn_ascendv2__Payment__r.ucinn_ascendv2__Payment_Amount__c,ucinn_ascendv2__Payment__r.ND_Pipeline__c 
              from ucinn_ascendv2__Hard_and_Soft_Credit__c 
              where ucinn_ascendv2__Receipt_Number__c IN: recNumber];   
        }
        
        set<id> oppIds = new set<id>();
        Map<String,String> PayID = new Map<String,String>();
        Map<String,ucinn_ascendv2__Payment__c> Payrecords = new Map<String,ucinn_ascendv2__Payment__c>();
        List<String> RecList=new List<String>();
        List<String> RecpList=new List<String>();
        
        for(ucinn_ascendv2__Hard_and_Soft_Credit__c hsc: hs){
            if(hsc.ucinn_ascendv2__Opportunity__c!=null){
                oppIds.add(hsc.ucinn_ascendv2__Opportunity__c);
            }
            //system.debug('RecNumber'+hsc.ucinn_ascendv2__Receipt_Number__c);
            if(hsc.ucinn_ascendv2__Receipt_Number__c!=null)
            {
                RecList.add(hsc.ucinn_ascendv2__Receipt_Number__c);
            }
        }
       
        // amount >1000
    
        Map<String,Decimal> finalpaymemts = new Map<String,Decimal>();
        for(AggregateResult agr:[SELECT ucinn_ascendv2__Receipt_Number__c, SUM(ucinn_ascendv2__Payment_Amount__c) FROM ucinn_ascendv2__Payment__c where ucinn_ascendv2__Receipt_Number__c IN:RecList GROUP BY ucinn_ascendv2__Receipt_Number__c ])
        {
            finalpaymemts.put((String)agr.get('ucinn_ascendv2__Receipt_Number__c'),(Decimal)agr.get('expr0'));
        }
     
        //till here
        Map<id,opportunity> mapOppdetails = new Map<id,Opportunity>([select id,recordtype.DeveloperName,ND_Pipeline__c,ucinn_ascendv2__Adjusted_Gift__c,Type from Opportunity where id=:oppids]);
       List <ucinn_ascendv2__Hard_and_Soft_Credit__c>  updateRecords = new List<ucinn_ascendv2__Hard_and_Soft_Credit__c>();

        for(ucinn_ascendv2__Hard_and_Soft_Credit__c hsc: hs){
            Opportunity op= mapOppdetails.get(hsc.ucinn_ascendv2__Opportunity__c);
            
            //hsc.ucinn_ascendv2__Opportunity__r.ucinn_ascendv2__Contact__r.nd_SIG__c &&
              if( hsc.ucinn_ascendv2__Opportunity__c!=null 
               && mapOppdetails.containsKey(hsc.ucinn_ascendv2__Opportunity__c) 
               && finalpaymemts.get(hsc.ucinn_ascendv2__Receipt_Number__c)>=100000 
               && ( mapOppdetails.get(hsc.ucinn_ascendv2__Opportunity__c).recordtype.DeveloperName=='Pledge'
                   || mapOppdetails.get(hsc.ucinn_ascendv2__Opportunity__c).recordtype.DeveloperName=='Gift' 
                  )
               && hsc.ucinn_ascendv2__Payment__r.ucinn_ascendv2__Adjusted_Gift__c==null
              // &&  mapOppdetails.get(hsc.ucinn_ascendv2__Opportunity__c).ucinn_ascendv2__Adjusted_Gift__c==null
               //Added
               && (hsc.ucinn_ascendv2__Payment__r.ND_Pipeline__c!='GD' || mapOppdetails.get(hsc.ucinn_ascendv2__Opportunity__c).ND_Pipeline__c!='GD')
               && (hsc.ucinn_ascendv2__Designation_Code_Formula__c !='LICENCE PLATE')
               && (mapOppdetails.get(hsc.ucinn_ascendv2__Opportunity__c).Type !='GS' && mapOppdetails.get(hsc.ucinn_ascendv2__Opportunity__c).Type !='GT' 
               		&& mapOppdetails.get(hsc.ucinn_ascendv2__Opportunity__c).Type !='MP' && mapOppdetails.get(hsc.ucinn_ascendv2__Opportunity__c).Type !='MT' 
               		&& mapOppdetails.get(hsc.ucinn_ascendv2__Opportunity__c).Type !='MA' && mapOppdetails.get(hsc.ucinn_ascendv2__Opportunity__c).Type !='MB')
               && !(hsc.ucinn_ascendv2__Payment__r.ucinn_ascendv2__Transaction_Type__c =='Pledge Payment' 
               		&& mapOppdetails.get(hsc.ucinn_ascendv2__Opportunity__c).Type=='Grant' )
              // && (hsc.ucinn_ascendv2__Payment__r.ucinn_ascendv2__Payment_Amount__c>1000)
              ){ 
                  //system.debug('updated');
                  hsc.nd_Acknowledgement_Reason__c = Significant_Gift;
                  hsc.nd_Acknowledgment_Status__c = Review;
                  updateRecords.add(hsc);
              }
        } 
        if(updateRecords.size()>0){
            Update updateRecords;
        }
    }
    
}