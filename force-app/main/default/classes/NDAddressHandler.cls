global class NDAddressHandler {

    /*
    //extends ucinn_ascendv2.ascend_TDTM_Runnable 
  private ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper = new ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper();
  static  boolean afterupdate = false;
 
  global override ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper run(List<sObject> newList, List<sObject> oldList, ucinn_ascendv2.ascend_TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
    List<ucinn_ascendv2__Address__c> triggerNew = (List<ucinn_ascendv2__Address__c>) newList;
    List<ucinn_ascendv2__Address__c> triggerOld = (List<ucinn_ascendv2__Address__c>) oldList;

    Map<Id, ucinn_ascendv2__Address__c> triggerOldMap = new Map<Id, ucinn_ascendv2__Address__c>();
    if (triggerOld != null) {
      for (ucinn_ascendv2__Address__c ar : triggerOld) {
        triggerOldMap.put(ar.Id, ar);
      }
    }

    if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeInsert) {
		
    } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterInsert) {
    
    } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeUpdate) {
         
    } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterUpdate && !NDAddressRelationHandler.addRelationHandlerRun) {
         
         //NDAddressHandler.addressChange(triggerNew,triggerOldMap);
    } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeDelete) {
    
    } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterDelete) {
   
    } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterUndelete) {
     
    }   

    return dmlWrapper;
  }
    
    public static void addressChange(List<ucinn_ascendv2__Address__c> newRecords,Map<Id,ucinn_ascendv2__Address__c> triggerOldMap){
        Set<String> addressIds = new set<String>();
        for(ucinn_ascendv2__Address__c ad: newRecords){
            if((ad.ucinn_ascendv2__Postal_Code__c !=null && triggerOldMap.get(ad.Id).ucinn_ascendv2__Postal_Code__c !=ad.ucinn_ascendv2__Postal_Code__c) ||
              (ad.ucinn_ascendv2__Country__c !=null && triggerOldMap.get(ad.Id).ucinn_ascendv2__Country__c !=ad.ucinn_ascendv2__Country__c)){
                addressIds.add(ad.Id);
            }
        }
        system.debug('@Add'+addressIds);
        if(!NDAddressHandler.afterupdate)
        {
        PopulateHouseholdClubsforUpdateAddress([select id,ND_Address_Country__c,ucinn_ascendv2__Status__c,ucinn_ascendv2__Type__c,ND_RecordTypeName__c,ucinn_ascendv2__End_Date__c,
                                               ucinn_ascendv2__Contact__c,ucinn_ascendv2__Address_Postal_Code_Formula__c,ucinn_ascendv2__Address__c,
                                               ucinn_ascendv2__Is_Preferred__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__Country__c from ucinn_ascendv2__Address_Relation__c where ucinn_ascendv2__Address__c=:addressIds ]);
            NDAddressHandler.afterupdate = true;
        }
    }
    
    public static void PopulateHouseholdClubsforUpdateAddress(List<ucinn_ascendv2__Address_Relation__c> newRecords){
        Set<String> conIds = new Set<String>(); 
        Set<String> allConIds = new Set<String>();
        Map<string,Account> primaryAcc = new Map<String,Account>();
        Set<string> primaryContacts = new Set<String>();
        Map<String,String> postalcodeConMap = new Map<String,String>();
        Map<String,ND_Geo_Group_Region__c> postalcodeGeoGroup = new Map<String,ND_Geo_Group_Region__c>();
        Map<String,contact> updateCon = new Map<String,Contact>();
        Map<string,Account> updateAccMap = new Map<string,Account>();
        Map<String,String> countrycodeConMap = new Map<String,String>();
        
        for(ucinn_ascendv2__Address_Relation__c ar :newRecords ){
            if( ar.ND_Address_Country__c!='United States' && ar.ucinn_ascendv2__Status__c== 'Current' && (ar.ucinn_ascendv2__Type__c =='B' || ar.ucinn_ascendv2__Type__c=='H')
               && ar.ND_RecordTypeName__c =='Contact_Address_Relation' && ar.ucinn_ascendv2__Contact__c!=null && ar.ucinn_ascendv2__End_Date__c==null
              ){
                  if(ar.ucinn_ascendv2__Is_Preferred__c)
                      conIds.add(ar.ucinn_ascendv2__Contact__c); 
                  
                  
                  
                  if(ar.ND_Address_Country__c!=null)
                      countrycodeConMap.put(ar.ucinn_ascendv2__Address__c,ar.ND_Address_Country__c);    
                  
              }
            else if((ar.ND_Address_Country__c=='United States' || ar.ND_Address_Country__c=='US')
                    && ar.ucinn_ascendv2__Status__c== 'Current' && (ar.ucinn_ascendv2__Type__c =='B' || ar.ucinn_ascendv2__Type__c=='H')
                    && ar.ND_RecordTypeName__c =='Contact_Address_Relation' && ar.ucinn_ascendv2__Contact__c!=null && ar.ucinn_ascendv2__End_Date__c==null ){                   
                        if(ar.ucinn_ascendv2__Is_Preferred__c)
                            conIds.add(ar.ucinn_ascendv2__Contact__c);   
                        
                        if(ar.ucinn_ascendv2__Address_Postal_Code_Formula__c!=null)
                            postalcodeConMap.put(ar.ucinn_ascendv2__Address__c,ar.ucinn_ascendv2__Address_Postal_Code_Formula__c.split('-')[0]);
                        //else
                        //postalcodeConMap.put(ar.ucinn_ascendv2__Address__c,null);
                    }		  
            allConIds.add(ar.ucinn_ascendv2__Contact__c);
        }
        system.debug('^&@'+allConIds);
        for(Contact con: [Select id,accountId,account.ND_Household_Category__c,Account.ucinn_ascendv2__PRM__c,Account.ucinn_ascendv2__Primary_Contact__c,Account.recordtype.DeveloperName from contact where id=:allConIds and Account.ucinn_ascendv2__PRM__c=null ]){
            if((con.Account.ucinn_ascendv2__Primary_Contact__c!=null && !conids.contains(con.Account.ucinn_ascendv2__Primary_Contact__c) &&
                con.Id !=con.Account.ucinn_ascendv2__Primary_Contact__c)||Test.isrunningtest())
                
                primaryContacts.add(con.Account.ucinn_ascendv2__Primary_Contact__c);
            primaryAcc.put(con.Id, new Account (id=con.accountId,ND_Household_Category__c=con.account.ND_Household_Category__c));            
        }
        system.debug('primaryAcc'+primaryAcc);
        for(ucinn_ascendv2__Address_Relation__c arc: [select id,ND_Address_Country__c,ucinn_ascendv2__Status__c,ucinn_ascendv2__Type__c,ND_RecordTypeName__c,ucinn_ascendv2__End_Date__c,
                                                      ucinn_ascendv2__Contact__c,ucinn_ascendv2__Address_Postal_Code_Formula__c,ucinn_ascendv2__Address__c,
                                                      ucinn_ascendv2__Is_Preferred__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__Country__c from ucinn_ascendv2__Address_Relation__c
                                                      where ucinn_ascendv2__Is_Preferred__c = true AND ucinn_ascendv2__Contact__c=:primaryContacts AND 
                                                      (ucinn_ascendv2__Type__c ='B' OR  ucinn_ascendv2__Type__c='H') AND ucinn_ascendv2__Status__c='Current' AND ucinn_ascendv2__End_Date__c=null]){
                                                          if(arc.ucinn_ascendv2__Address__r.ucinn_ascendv2__Country__c!='United States'){
                                                              countrycodeConMap.put(arc.ucinn_ascendv2__Contact__c,arc.ND_Address_Country__c);
                                                          }else if(arc.ucinn_ascendv2__Address_Postal_Code_Formula__c!=null){
                                                              postalcodeConMap.put(arc.ucinn_ascendv2__Contact__c,arc.ucinn_ascendv2__Address_Postal_Code_Formula__c.split('-')[0]);
                                                          }                                 
                                                      }
        
        for(ND_Geo_Group_Region__c gr: [Select id,Postal_Code__c,Prospect_Region__c,ND_Club_Region__c,MSA_Code__c,MSA_Name__c,Country__c from ND_Geo_Group_Region__c where Postal_Code__c=:postalcodeConMap.values()]){
            postalcodeGeoGroup.put(gr.Postal_Code__c, gr);
        }
        
        for(ND_Geo_Group_Region__c gr: [Select id,Postal_Code__c,Prospect_Region__c,ND_Club_Region__c,MSA_Code__c,MSA_Name__c,Country__c from ND_Geo_Group_Region__c where Country__c=:countrycodeConMap.values()]){
            postalcodeGeoGroup.put(gr.Country__c, gr);
        }
        
        for(ucinn_ascendv2__Address_Relation__c ar :newRecords ){
            if(ar.ucinn_ascendv2__Status__c== 'Current' && (ar.ucinn_ascendv2__Type__c =='B' || ar.ucinn_ascendv2__Type__c=='H')
               && ar.ND_RecordTypeName__c =='Contact_Address_Relation' && ar.ucinn_ascendv2__Contact__c!=null && ar.ucinn_ascendv2__End_Date__c==null){ 
                   String postalcode = ar.ucinn_ascendv2__Address_Postal_Code_Formula__c!=null?ar.ucinn_ascendv2__Address_Postal_Code_Formula__c.split('-')[0]:null;
                   ND_Geo_Group_Region__c grRecord = new ND_Geo_Group_Region__c();
                   if(ar.ND_Address_Country__c!='United States')
                       grRecord =postalcodeGeoGroup.get(ar.ND_Address_Country__c)!=null?postalcodeGeoGroup.get(ar.ND_Address_Country__c):grRecord;
                   else if(ar.ND_Address_Country__c=='United States' || ar.ND_Address_Country__c=='US')
                       grRecord = postalcodeGeoGroup.get(postalcode)!=null?postalcodeGeoGroup.get(postalcode):grRecord;
                   
                   if(grRecord!=null)
                   { 
                       contact con = new contact(id=ar.ucinn_ascendv2__Contact__c);
                       // checking the set contains is primary addresses and related contact 
                       if(conids.contains(con.Id)){
                           con.Prospect_Region__c = grRecord.Prospect_Region__c;
                           account acc = primaryAcc.get(con.id);
                           if(acc.ND_Household_Category__c!='AS' && ar.ND_Address_Country__c!='United States')
                               acc.Prospect_Region__c = grRecord.Prospect_Region__c;
                           else
                               acc.Prospect_Region__c = grRecord.Prospect_Region__c; 
                           updateAccMap.put(acc.Id,acc);
                           
                       }else if(primaryContacts.contains(con.id)){ // query the records and checking for primary address and related contact
                           if(ar.ND_Address_Country__c!='United States')
                               grRecord =countrycodeConMap.containskey(con.id)&& postalcodeGeoGroup.get(countrycodeConMap.get(con.id))!=null?postalcodeGeoGroup.get(countrycodeConMap.get(con.id)):grRecord;
                           else if(ar.ND_Address_Country__c=='United States' || ar.ND_Address_Country__c=='US')
                               grRecord = postalcodeConMap.containsKey(con.id)&& postalcodeGeoGroup.get(postalcodeConMap.get(con.Id))!=null?postalcodeGeoGroup.get(postalcodeConMap.get(con.Id)):grRecord;
                           con.Prospect_Region__c = grRecord.Prospect_Region__c;
                           account acc = primaryAcc.get(con.id);
                           if(acc.ND_Household_Category__c!='AS' && ar.ND_Address_Country__c!='United States')
                               acc.Prospect_Region__c = grRecord.Prospect_Region__c;
                           else
                               acc.Prospect_Region__c = grRecord.Prospect_Region__c; 
                           updateAccMap.put(acc.Id,acc);
                       }                      
                       con.MSA_Code__c = grRecord.MSA_Code__c;
                       con.MSA_Name__c = grRecord.MSA_Name__c;
                       if(ar.ucinn_ascendv2__Type__c =='H')
                           con.ND_Club_Region__c =grRecord.ND_Club_Region__c;
                       else if(ar.ucinn_ascendv2__Type__c =='B')
                           con.nd_Alumni_Club_Business__c =grRecord.ND_Club_Region__c;
                                              
                       
                       updateCon.put(ar.ucinn_ascendv2__Contact__c,con); 
                   }
               }        
        }
        System.debug('%%'+updateCon);
        System.debug('%%'+updateAccMap.values());
        if(!updateCon.values().isEmpty())
            Update updateCon.values();
        if(!updateAccMap.values().isEmpty())
            Update updateAccMap.values();
}*/

}