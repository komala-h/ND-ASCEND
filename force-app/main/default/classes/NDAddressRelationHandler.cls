global class NDAddressRelationHandler {

  /*  
  //extends ucinn_ascendv2.ascend_TDTM_Runnable 
  private ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper = new ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper();
  public static boolean addRelationHandlerRun = false;

  
  global override ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper run(List<sObject> newList, List<sObject> oldList, ucinn_ascendv2.ascend_TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
    List<ucinn_ascendv2__Address_Relation__c> triggerNew = (List<ucinn_ascendv2__Address_Relation__c>) newList;
    List<ucinn_ascendv2__Address_Relation__c> triggerOld = (List<ucinn_ascendv2__Address_Relation__c>) oldList;

    Map<Id, ucinn_ascendv2__Address_Relation__c> triggerOldMap = new Map<Id, ucinn_ascendv2__Address_Relation__c>();
    if (triggerOld != null) {
      for (ucinn_ascendv2__Address_Relation__c ar : triggerOld) {
        triggerOldMap.put(ar.Id, ar);
      }
    }

    if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeInsert) {
		
    } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterInsert) {
      //PopulateHouseholdClubsfornewAddress(triggerNew);
       // addRelationHandlerRun= true;
    }else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterUpdate) {
      //PopulateHouseholdClubsfornewAddress(triggerNew);
    }  

    return dmlWrapper;
  }
    
    public static void PopulateHouseholdClubsfornewAddress(List<ucinn_ascendv2__Address_Relation__c> newRecords){
        Set<String> conIds = new Set<String>(); 
        Set<String> allConIds = new Set<String>();
        Map<string,Account> primaryAcc = new Map<String,Account>();
        Set<string> primaryContacts = new Set<String>();
        Map<String,String> postalcodeConMap = new Map<String,String>();
        Map<String,ND_Geo_Group_Region__c> postalcodeGeoGroup = new Map<String,ND_Geo_Group_Region__c>();
        Map<String,contact> updateCon = new Map<String,Contact>();
        Map<string,Account> updateAccMap = new Map<string,Account>();
        Map<String,String> countrycodeConMap = new Map<String,String>();
        Set<String> ERDRecords = new Set<String>();
        
        for(ucinn_ascendv2__Address_Relation__c ar :newRecords ){
            if( ar.ND_Address_Country__c!='United States' && ar.ucinn_ascendv2__Status__c== 'Current' && (ar.ucinn_ascendv2__Type__c =='B' || ar.ucinn_ascendv2__Type__c=='H')
               && ar.ND_RecordTypeName__c =='Contact_Address_Relation' && ar.ucinn_ascendv2__Contact__c!=null && ar.ucinn_ascendv2__End_Date__c==null
              ){
                   if(ar.ucinn_ascendv2__Is_Preferred__c)
                   	conIds.add(ar.ucinn_ascendv2__Contact__c); 
                   
                   if(ar.Is_ERD_Or_EPD__c && ar.ucinn_ascendv2__Type__c =='H' )
                        ERDRecords.add(ar.ucinn_ascendv2__Contact__c);              
                   if(ar.ND_Address_Country__c!=null)
                   		countrycodeConMap.put(ar.ucinn_ascendv2__Address__c,ar.ND_Address_Country__c);    
                  
              }
            else if((ar.ND_Address_Country__c=='United States' || ar.ND_Address_Country__c=='US')
                && ar.ucinn_ascendv2__Status__c== 'Current' && (ar.ucinn_ascendv2__Type__c =='B' || ar.ucinn_ascendv2__Type__c=='H')
               && ar.ND_RecordTypeName__c =='Contact_Address_Relation' && ar.ucinn_ascendv2__Contact__c!=null && ar.ucinn_ascendv2__End_Date__c==null ){                   
                   if(ar.ucinn_ascendv2__Is_Preferred__c)
                   	conIds.add(ar.ucinn_ascendv2__Contact__c);   
                   
                   if(ar.Is_ERD_Or_EPD__c && ar.ucinn_ascendv2__Type__c =='H' )
                        ERDRecords.add(ar.ucinn_ascendv2__Contact__c); 
                   
					if(ar.ucinn_ascendv2__Address_Postal_Code_Formula__c!=null)
                   		postalcodeConMap.put(ar.ucinn_ascendv2__Address__c,ar.ucinn_ascendv2__Address_Postal_Code_Formula__c.split('-')[0]);
                    //else
                        //postalcodeConMap.put(ar.ucinn_ascendv2__Address__c,null);
             }		  
            allConIds.add(ar.ucinn_ascendv2__Contact__c);
        }
        system.debug('^&@'+allConIds);
        Map<string,string> ERPConandPrimaryContact = new Map<String,String>();
        for(Contact con: [Select id,accountId,account.ND_Household_Category__c,Account.ucinn_ascendv2__PRM__c,Account.ucinn_ascendv2__PRM__r.ERDs_and_EPD__c,Account.ucinn_ascendv2__Primary_Contact__c,Account.recordtype.DeveloperName from contact where id=:allConIds  ]){
            if((con.Account.ucinn_ascendv2__Primary_Contact__c!=null ) 
                ||Test.isrunningtest()){
                if(con.Account.ucinn_ascendv2__PRM__c==null || (con.Account.ucinn_ascendv2__PRM__c!=null && con.Account.ucinn_ascendv2__PRM__r.ERDs_and_EPD__c)){    
                    primaryContacts.add(con.Account.ucinn_ascendv2__Primary_Contact__c);   
                    ERPConandPrimaryContact.put(con.id,con.Account.ucinn_ascendv2__Primary_Contact__c);   
                }
                }
            //&& !conids.contains(con.Account.ucinn_ascendv2__Primary_Contact__c)

             primaryAcc.put(con.Id, new Account (id=con.accountId,ND_Household_Category__c=con.account.ND_Household_Category__c)); 
        }
        system.debug('primaryAcc'+primaryContacts);
        system.debug('primaryAcc'+primaryAcc);
        system.debug('primaryAcc'+ERPConandPrimaryContact);
        Map<String,string> ERDConCountryCodeMap = new Map<String,String>();
        Map<String,string> ERDConPostalCodeMap = new Map<String,String>();
        for(ucinn_ascendv2__Address_Relation__c arc: [select id,ND_Address_Country__c,ucinn_ascendv2__Status__c,ucinn_ascendv2__Type__c,ND_RecordTypeName__c,ucinn_ascendv2__End_Date__c,
                                               ucinn_ascendv2__Contact__c,ucinn_ascendv2__Address_Postal_Code_Formula__c,ucinn_ascendv2__Address__c,
                                               ucinn_ascendv2__Is_Preferred__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__Country__c from ucinn_ascendv2__Address_Relation__c
                                                     where  ucinn_ascendv2__Contact__c=:primaryContacts AND 
                                                     (ucinn_ascendv2__Type__c ='B' OR  ucinn_ascendv2__Type__c='H') AND ucinn_ascendv2__Status__c='Current' AND ucinn_ascendv2__End_Date__c=null]){
           
           if(arc.ucinn_ascendv2__Is_Preferred__c && arc.ucinn_ascendv2__Address__r.ucinn_ascendv2__Country__c!='United States'){
               countrycodeConMap.put(arc.ucinn_ascendv2__Contact__c,arc.ND_Address_Country__c);
           }else if(arc.ucinn_ascendv2__Is_Preferred__c && arc.ucinn_ascendv2__Address_Postal_Code_Formula__c!=null){
               postalcodeConMap.put(arc.ucinn_ascendv2__Contact__c,arc.ucinn_ascendv2__Address_Postal_Code_Formula__c.split('-')[0]);
           } 
           
           if(arc.ucinn_ascendv2__Type__c=='H' ){
               if(arc.ucinn_ascendv2__Address__r.ucinn_ascendv2__Country__c!='United States' && 
                  countrycodeConMap.get(arc.ucinn_ascendv2__Contact__c)!=arc.ND_Address_Country__c){
                   ERDConCountryCodeMap.put(arc.ucinn_ascendv2__Contact__c,arc.ND_Address_Country__c);
               }else if( arc.ucinn_ascendv2__Address_Postal_Code_Formula__c!=null ){ //postalcodeConMap.get(arc.ucinn_ascendv2__Contact__c)!=arc.ucinn_ascendv2__Address_Postal_Code_Formula__c.split('-')[0]
                   ERDConPostalCodeMap.put(arc.ucinn_ascendv2__Contact__c,arc.ucinn_ascendv2__Address_Postal_Code_Formula__c.split('-')[0]);
               }                                                              
           }
        }
        
        system.debug(ERDConCountryCodeMap);
        system.debug(ERDConPostalCodeMap);
        for(ND_Geo_Group_Region__c gr: [Select id,Postal_Code__c,Prospect_Region__c,ND_Club_Region__c,MSA_Code__c,MSA_Name__c,Country__c from ND_Geo_Group_Region__c where Postal_Code__c=:postalcodeConMap.values() OR Postal_Code__c=:ERDConPostalCodeMap.values()]){
            postalcodeGeoGroup.put(gr.Postal_Code__c, gr);
        }
        
        for(ND_Geo_Group_Region__c gr: [Select id,Postal_Code__c,Prospect_Region__c,ND_Club_Region__c,MSA_Code__c,MSA_Name__c,Country__c from ND_Geo_Group_Region__c where Country__c=:countrycodeConMap.values() OR Country__c=:ERDConCountryCodeMap.values()]){
            postalcodeGeoGroup.put(gr.Country__c, gr);
        }
        
        for(ucinn_ascendv2__Address_Relation__c ar :newRecords ){
            if(ar.ucinn_ascendv2__Status__c== 'Current' && (ar.ucinn_ascendv2__Type__c =='B' || ar.ucinn_ascendv2__Type__c=='H')
               && ar.ND_RecordTypeName__c =='Contact_Address_Relation' && ar.ucinn_ascendv2__Contact__c!=null && ar.ucinn_ascendv2__End_Date__c==null){ 
                  String postalcode = ar.ucinn_ascendv2__Address_Postal_Code_Formula__c!=null?ar.ucinn_ascendv2__Address_Postal_Code_Formula__c.split('-')[0]:null;
                  String  homeRegion='';
                  String ERPPrimaryCon = ERPConandPrimaryContact.get(ar.ucinn_ascendv2__Contact__c);
                   system.debug('ERPPrimaryCon'+ERPPrimaryCon);
                   ND_Geo_Group_Region__c grRecord = new ND_Geo_Group_Region__c();
                   if(ar.ND_Address_Country__c!='United States'){
                      grRecord =postalcodeGeoGroup.get(ar.ND_Address_Country__c)!=null?postalcodeGeoGroup.get(ar.ND_Address_Country__c):grRecord;
                       if(ar.Is_ERD_Or_EPD__c && ar.ucinn_ascendv2__Type__c=='H')
                       	homeRegion = ERPPrimaryCon!=null&&ERDConCountryCodeMap.containsKey(ERPPrimaryCon)&& postalcodeGeoGroup.get(ERDConCountryCodeMap.get(ERPPrimaryCon))!=null?(postalcodeGeoGroup.get(ERDConCountryCodeMap.get(ERPPrimaryCon)).Prospect_Region__c):'';
                   }else if(ar.ND_Address_Country__c=='United States' || ar.ND_Address_Country__c=='US'){                       
                       grRecord = postalcodeGeoGroup.get(postalcode)!=null?postalcodeGeoGroup.get(postalcode):grRecord;
                       if(ar.Is_ERD_Or_EPD__c && ar.ucinn_ascendv2__Type__c=='H')
                       	homeRegion = ERPPrimaryCon!=null&&ERDConPostalCodeMap.containsKey(ERPPrimaryCon)&&postalcodeGeoGroup.get(ERDConPostalCodeMap.get(ERPPrimaryCon))!=null?postalcodeGeoGroup.get(ERDConPostalCodeMap.get(ERPPrimaryCon)).Prospect_Region__c:'';
                   }
                   system.debug('@grRecord'+grRecord);
                   if(grRecord!=null)
                  { 
                      contact con = new contact(id=ar.ucinn_ascendv2__Contact__c);
                      
                      con.ND_Home_Address_Region__c=homeRegion;
                      // checking the set contains is primary addresses and related contact 
                      if(conids.contains(con.Id)){
                            con.Prospect_Region__c = grRecord.Prospect_Region__c;
                              account acc = primaryAcc.get(con.id);
                              if(acc.ND_Household_Category__c!='AS' && ar.ND_Address_Country__c!='United States')
                                  acc.Prospect_Region__c = grRecord.Prospect_Region__c;
                              else
                                  acc.Prospect_Region__c = grRecord.Prospect_Region__c;
                              if(acc.ND_Household_Category__c!='AS' && ar.ND_Address_Country__c!='United States')
                                  acc.ND_Home_Address_Region__c = homeRegion;
                              else
                                  acc.ND_Home_Address_Region__c = homeRegion;                          
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
                          if(acc.ND_Household_Category__c!='AS' && ar.ND_Address_Country__c!='United States')
                              acc.ND_Home_Address_Region__c = homeRegion;
                          else
                              acc.ND_Home_Address_Region__c = homeRegion;                            
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
        //if(!updateCon.values().isEmpty())
             //System.enqueueJob(new NDAddressQueuable(updateCon.values(),updateAccMap.values()));
            
      
}*/
}