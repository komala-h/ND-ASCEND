global class Nd_HardandSoftCreditTriggerHandler extends ucinn_ascendv2.ascend_TDTM_Runnable {
    
    private ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper = new ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper();
    
    private static final string Significant_Gift ='SIG';
    private static final string Review ='RV';
    public Static boolean isAfterContextExcecuted = false;
    
    global override ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, ucinn_ascendv2.ascend_TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        List<ucinn_ascendv2__Hard_and_Soft_Credit__c> triggerNew = (List<ucinn_ascendv2__Hard_and_Soft_Credit__c>) newList;
        List<ucinn_ascendv2__Hard_and_Soft_Credit__c> triggerOld = (List<ucinn_ascendv2__Hard_and_Soft_Credit__c>) oldList;
        
        Map<Id, ucinn_ascendv2__Hard_and_Soft_Credit__c> triggerOldMap = new Map<Id, ucinn_ascendv2__Hard_and_Soft_Credit__c>();
        if (triggerOld != null) {
            for (ucinn_ascendv2__Hard_and_Soft_Credit__c hsc : triggerOld) {
                triggerOldMap.put(hsc.Id, hsc);
            }
        }
        
        if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeInsert) {
             hardandsoft(triggerNew,triggerOldMap);
        } 
         else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterUpdate) {
            if(!Nd_HardandSoftCreditTriggerHandler.isAfterContextExcecuted)
            	updateAckStatusandAckDate(triggerNew,triggerOldMap);
        } 
               
        return dmlWrapper;
    }
    
    /*
	public static void beforeInsert(list<ucinn_ascendv2__Hard_and_Soft_Credit__c> newRecords){
		hardandsoft(newRecords);
	}
	public static void beforeUpdate(list<ucinn_ascendv2__Hard_and_Soft_Credit__c> newRecords, Map<id,ucinn_ascendv2__Hard_and_Soft_Credit__c> newRecordsMap){
		hardandsoft(newRecords);
	}    
	*/
    
    public static void hardandsoft(list<ucinn_ascendv2__Hard_and_Soft_Credit__c> hs,map<id,ucinn_ascendv2__Hard_and_Soft_Credit__c> oldMap){
        list<ucinn_ascendv2__Hard_and_Soft_Credit__c> hs1 = new list<ucinn_ascendv2__Hard_and_Soft_Credit__c>();
        set<id> oppIds = new set<id>();
        set<id>conIds = new set<id>();
                
        Map<String,String> PayID = new Map<String,String>();
        Map<String,ucinn_ascendv2__Payment__c> Payrecords = new Map<String,ucinn_ascendv2__Payment__c>();
        List<String> RecList=new List<String>();
        List<String> RecpList=new List<String>();
        
        for(ucinn_ascendv2__Hard_and_Soft_Credit__c hsc: hs){
            if(hsc.ucinn_ascendv2__Contact__c!=null && hsc.ucinn_ascendv2__Opportunity__c!=null ){
                oppids.add(hsc.ucinn_ascendv2__Opportunity__c);
                conids.add(hsc.ucinn_ascendv2__Contact__c);
            }         
        }

        Map<String,Decimal> finalpaymemts = new Map<String,Decimal>();
 
        // amount >1000
  /*    for(ucinn_ascendv2__Hard_and_Soft_Credit__c hdsd: hs){
            system.debug('RecNumber'+hdsd.ucinn_ascendv2__Receipt_Number__c);
            if(hdsd.ucinn_ascendv2__Receipt_Number__c!=null)
            RecList.add(hdsd.ucinn_ascendv2__Receipt_Number__c);
        }
        for(AggregateResult agr:[SELECT ucinn_ascendv2__Receipt_Number__c, SUM(ucinn_ascendv2__Payment_Amount__c) FROM ucinn_ascendv2__Payment__c where ucinn_ascendv2__Receipt_Number__c IN:RecList GROUP BY ucinn_ascendv2__Receipt_Number__c ])
        {
            finalpaymemts.put((String)agr.get('ucinn_ascendv2__Receipt_Number__c'),(Decimal)agr.get('expr0'));
        }*/
     
        
        Map<id,opportunity> mapOppdetails = new Map<id,Opportunity>([select id,recordtype.DeveloperName,ND_Pipeline__c,ucinn_ascendv2__Adjusted_Gift__c,(select id from ucinn_ascendv2__Tributes_Opportunity__r where ucinn_ascendv2__Tribute_Type__c IN ('H','M')) 
                                                                     from Opportunity 
                                                                     where id=:oppids]);
        Map<Id,contact> mapofconDetails = new Map<id,contact> ([Select id,nd_SIG__c 
                                                                from contact 
                                                                where id=:conIds AND nd_SIG__c=true ]);
        
        for(ucinn_ascendv2__Hard_and_Soft_Credit__c hsc: hs){
            Opportunity op= mapOppdetails.get(hsc.ucinn_ascendv2__Opportunity__c);
            List<ucinn_ascendv2__Tribute__c> trb = new list<ucinn_ascendv2__Tribute__c>();
            if(op!=null){
                trb= op.ucinn_ascendv2__Tributes_Opportunity__r;
            }
            
            //hsc.ucinn_ascendv2__Opportunity__r.ucinn_ascendv2__Contact__r.nd_SIG__c &&
            
            if( hsc.ucinn_ascendv2__Opportunity__c!=null 
               && mapOppdetails.containsKey(hsc.ucinn_ascendv2__Opportunity__c) 
               && hsc.ucinn_ascendv2__Credit_Amount__c>=100000 
               && ( mapOppdetails.get(hsc.ucinn_ascendv2__Opportunity__c).recordtype.DeveloperName=='Pledge'
                   || mapOppdetails.get(hsc.ucinn_ascendv2__Opportunity__c).recordtype.DeveloperName=='Gift' 
                  )
               &&  mapOppdetails.get(hsc.ucinn_ascendv2__Opportunity__c).ucinn_ascendv2__Adjusted_Gift__c==null
               //added
               && (hsc.ucinn_ascendv2__Payment__r.ND_Pipeline__c!='GD' || hsc.ucinn_ascendv2__Opportunity__r.ND_Pipeline__c!='GD')
               && (hsc.ucinn_ascendv2__Designation_Code_Formula__c !='LICENCE PLATE')
               && (hsc.ucinn_ascendv2__Opportunity__r.Type !='GS' && hsc.ucinn_ascendv2__Opportunity__r.Type !='GT' 
                   && hsc.ucinn_ascendv2__Opportunity__r.Type !='MP' && hsc.ucinn_ascendv2__Opportunity__r.Type !='MT' 
                   && hsc.ucinn_ascendv2__Opportunity__r.Type !='MA' && hsc.ucinn_ascendv2__Opportunity__r.Type !='MB')
               && !(hsc.ucinn_ascendv2__Payment__r.ucinn_ascendv2__Transaction_Type__c =='Pledge Payment' 
                    && hsc.ucinn_ascendv2__Opportunity__r.Type=='Grant' )
               && (hsc.ucinn_ascendv2__Payment__r.ucinn_ascendv2__Payment_Amount__c>1000)
              ){   
                  hsc.nd_Acknowledgement_Reason__c = Significant_Gift;
                  hsc.nd_Acknowledgment_Status__c = Review;
            }
            else if( hsc.ucinn_ascendv2__Contact__c!=null 
                    && mapofconDetails.containsKey(hsc.ucinn_ascendv2__Contact__c) 
                    && mapofconDetails.get(hsc.ucinn_ascendv2__Contact__c).nd_SIG__c                 
                    && !trb.isEmpty() 
                    && ( mapOppdetails.get(hsc.ucinn_ascendv2__Opportunity__c).recordtype.DeveloperName=='Pledge'
                        || mapOppdetails.get(hsc.ucinn_ascendv2__Opportunity__c).recordtype.DeveloperName=='Gift'
                       )
                    &&  mapOppdetails.get(hsc.ucinn_ascendv2__Opportunity__c).ucinn_ascendv2__Adjusted_Gift__c==null
                    //Added
                    && (hsc.ucinn_ascendv2__Payment__r.ND_Pipeline__c!='GD' || hsc.ucinn_ascendv2__Opportunity__r.ND_Pipeline__c!='GD')
                    && (hsc.ucinn_ascendv2__Designation_Code_Formula__c !='LICENCE PLATE')
                    && (hsc.ucinn_ascendv2__Opportunity__r.Type !='GS' && hsc.ucinn_ascendv2__Opportunity__r.Type !='GT' 
                        && hsc.ucinn_ascendv2__Opportunity__r.Type !='MP' && hsc.ucinn_ascendv2__Opportunity__r.Type !='MT' 
                        && hsc.ucinn_ascendv2__Opportunity__r.Type !='MA' && hsc.ucinn_ascendv2__Opportunity__r.Type !='MB')
                    && !(hsc.ucinn_ascendv2__Payment__r.ucinn_ascendv2__Transaction_Type__c =='Pledge Payment' 
                    && hsc.ucinn_ascendv2__Opportunity__r.Type=='Grant' )
                    && (hsc.ucinn_ascendv2__Payment__r.ucinn_ascendv2__Payment_Amount__c>1000)
                    ){
                       hsc.nd_Acknowledgement_Reason__c = Significant_Gift;
                       hsc.nd_Acknowledgment_Status__c = Review;                      
                       
                   }
            else if( hsc.ucinn_ascendv2__Opportunity__c!=null 
                    && hsc.ucinn_ascendv2__Contact__c!=null 
                    &&   mapofconDetails.containsKey(hsc.ucinn_ascendv2__Contact__c)
                    && mapofconDetails.get(hsc.ucinn_ascendv2__Contact__c).nd_SIG__c
                    && ( mapOppdetails.containsKey(hsc.ucinn_ascendv2__Opportunity__c) 
                        && (mapOppdetails.get(hsc.ucinn_ascendv2__Opportunity__c).recordtype.DeveloperName=='Pledge'
                            || mapOppdetails.get(hsc.ucinn_ascendv2__Opportunity__c).recordtype.DeveloperName=='Gift')
                       )
                    &&  mapOppdetails.get(hsc.ucinn_ascendv2__Opportunity__c).ucinn_ascendv2__Adjusted_Gift__c==null
                    //Added
                    && (hsc.ucinn_ascendv2__Payment__r.ND_Pipeline__c!='GD' || hsc.ucinn_ascendv2__Opportunity__r.ND_Pipeline__c!='GD')
                    && (hsc.ucinn_ascendv2__Designation_Code_Formula__c !='LICENCE PLATE')
                    && (hsc.ucinn_ascendv2__Opportunity__r.Type !='GS' && hsc.ucinn_ascendv2__Opportunity__r.Type !='GT' 
                        && hsc.ucinn_ascendv2__Opportunity__r.Type !='MP' && hsc.ucinn_ascendv2__Opportunity__r.Type !='MT' 
                        && hsc.ucinn_ascendv2__Opportunity__r.Type !='MA' && hsc.ucinn_ascendv2__Opportunity__r.Type !='MB')
                    && !(hsc.ucinn_ascendv2__Payment__r.ucinn_ascendv2__Transaction_Type__c =='Pledge Payment' 
                    && hsc.ucinn_ascendv2__Opportunity__r.Type=='Grant' )
                    && (hsc.ucinn_ascendv2__Payment__r.ucinn_ascendv2__Payment_Amount__c>1000)
                   ){
                       hsc.nd_Acknowledgement_Reason__c = Significant_Gift;
                       hsc.nd_Acknowledgment_Status__c = Review;
            }
            else if( hsc.ucinn_ascendv2__Contact__c!=null 
                    && mapofconDetails.containsKey(hsc.ucinn_ascendv2__Contact__c)                
                    && pipeline__mdt.getInstance(op.ND_Pipeline__c)!=null 
                    && !trb.isEmpty()){
                        hsc.nd_Acknowledgement_Reason__c = Significant_Gift;
                        hsc.nd_Acknowledgment_Status__c = Review;                      
            }
        }                
    }
    
    public static void  updateAckStatusandAckDate (List<ucinn_ascendv2__Hard_and_Soft_Credit__c> newRec, Map<Id,ucinn_ascendv2__Hard_and_Soft_Credit__c> oldMap){
        Set<String> RecpList=new Set<String>();
        List <ucinn_ascendv2__Hard_and_Soft_Credit__c>  updateRecords = new List<ucinn_ascendv2__Hard_and_Soft_Credit__c>();
        Map<String,ucinn_ascendv2__Hard_and_Soft_Credit__c> contextRecords = new Map<String,ucinn_ascendv2__Hard_and_Soft_Credit__c>();
        //new line
        for(ucinn_ascendv2__Hard_and_Soft_Credit__c sofhar: newRec){
            if(oldMap.size()>0 && sofhar.ucinn_ascendv2__Receipt_Number__c!=null && oldMap.get(sofhar.id).nd_Acknowledgment_Status__c=='RV' && sofhar.nd_Acknowledgment_Status__c=='RE')
            {
                RecpList.add(sofhar.ucinn_ascendv2__Receipt_Number__c);
                contextRecords.put(sofhar.Id,sofhar);
                contextRecords.put(sofhar.ucinn_ascendv2__Receipt_Number__c,sofhar);
            }
        }
        for(ucinn_ascendv2__Hard_and_Soft_Credit__c sfchcr:[select id,ucinn_ascendv2__Receipt_Number__c,nd_Acknowledgment_Status__c,nd_Acknowledgement_Status_Date__c 
                                                            from ucinn_ascendv2__Hard_and_Soft_Credit__c 
                                                            where ucinn_ascendv2__Receipt_Number__c IN: RecpList AND Id !=:contextRecords.keySet() AND nd_Acknowledgment_Status__c='RV' ])
        {
            ucinn_ascendv2__Hard_and_Soft_Credit__c rec = contextRecords.get(sfchcr.ucinn_ascendv2__Receipt_Number__c);
            sfchcr.nd_Acknowledgment_Status__c='RE';
            sfchcr.nd_Acknowledgement_Status_Date__c= rec.nd_Acknowledgement_Status_Date__c!=null?rec.nd_Acknowledgement_Status_Date__c: system.today();
            updateRecords.add(sfchcr);
        } 
        
        if(updateRecords.size()>0 && !Nd_HardandSoftCreditTriggerHandler.isAfterContextExcecuted){
            Nd_HardandSoftCreditTriggerHandler.isAfterContextExcecuted = true;
            Update updateRecords;
        }
    }
}