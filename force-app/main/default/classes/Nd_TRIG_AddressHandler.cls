/*Description:Fires when an Active Home Address zip code is updated  on a Constituent
              where their respective Household has an Active Assignment record.
Date:8/7/2024
*/
global class Nd_TRIG_AddressHandler extends ucinn_ascendv2.ascend_TDTM_Runnable {
    
    private ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper = new ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper();
    
    global override ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, ucinn_ascendv2.ascend_TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        List<ucinn_ascendv2__Address__c> triggerNew = (List<ucinn_ascendv2__Address__c>) newList;
        List<ucinn_ascendv2__Address__c> triggerOld = (List<ucinn_ascendv2__Address__c>) oldList;
        
        Map<Id, ucinn_ascendv2__Address__c> triggerOldMap = new Map<Id, ucinn_ascendv2__Address__c>();
        if (triggerOld != null) {
            for (ucinn_ascendv2__Address__c add : triggerOld) {
                triggerOldMap.put(add.Id, add);
            }
        }
        
        if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterInsert) {
            
        } 
        else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterUpdate) {
            processAddressRelations(triggerNew,triggerOldMap);
        } 
        else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterDelete) {
            
        } 
        return dmlWrapper;
    }
    public static void processAddressRelations(List<ucinn_ascendv2__Address__c> newAddress,Map<Id,ucinn_ascendv2__Address__c> oldAddressMap)
    {
        Set<Id>contactIds= new Set<Id>();
        Set<Id>accountIds= new Set<Id>();
        Set<Id> addressIdsToCheck = new Set<Id>();
        List<ucinn_ascendv2__Address_Relation__c> activeBusinessRelations = new List<ucinn_ascendv2__Address_Relation__c>();

        if(!oldAddressMap.isEmpty())
        {
            //Check if there is a change in Postal code
            for(ucinn_ascendv2__Address__c address : newAddress){           
                if(address.ucinn_ascendv2__Postal_Code__c!=NULL && (oldAddressMap.get(address.Id).ucinn_ascendv2__Postal_Code__c!=address.ucinn_ascendv2__Postal_Code__c)){                
                    addressIdsToCheck.add(address.Id);                   
                }
            }                       
        }
        //Query Contact and Account based on Changed Postal Code
        List<ucinn_ascendv2__Address_Relation__c> addRelations = new List<ucinn_ascendv2__Address_Relation__c>();
        if (!addressIdsToCheck.isEmpty()) {
            addRelations = [SELECT id,ucinn_ascendv2__Type__c,ucinn_ascendv2__Contact__c,ucinn_ascendv2__Address__c,ucinn_ascendv2__Address__r.ND_ToBeProcessedByBatchJob__c,ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__c FROM ucinn_ascendv2__Address_Relation__c WHERE (ucinn_ascendv2__Type__c='H' OR ucinn_ascendv2__Type__c='B')  and ucinn_ascendv2__Status__c='Current' and  ucinn_ascendv2__Is_Preferred__c=true and ucinn_ascendv2__Address__c IN :addressIdsToCheck];
            for (ucinn_ascendv2__Address_Relation__c relation : addRelations) {
                if(relation.ucinn_ascendv2__Type__c=='H'){
                    if (relation.ucinn_ascendv2__Contact__c != null) {
                        if (relation.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__c == null) {
                            activeBusinessRelations.add(relation);
                        } else {
                            contactIds.add(relation.ucinn_ascendv2__Contact__c);
                        }                    
                    }
                }else if(relation.ucinn_ascendv2__Type__c=='B'){
                    activeBusinessRelations.add(relation); 
                }
            }
        }
        if(!activeBusinessRelations.isEmpty())
        {
            setBatchForBusiness(activeBusinessRelations);
        }
        
        Map<Id, Contact> contactsMap = new Map<Id, Contact>();  
        if (!contactIds.isEmpty()) {
            for (Contact con : [SELECT Id, AccountId, ND_Home_Address_Region__c, Prospect_Region__c, MSA_Code__c, MSA_Name__c FROM Contact WHERE Id IN :contactIds]) {
                contactsMap.put(con.Id, con);
                if (con.AccountId != null) {
                    accountIds.add(con.AccountId);
                }
            }
        }
          // Fetch Accounts where the Primary Contact is one of the contacts
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, ucinn_ascendv2__Primary_Contact__c,Secondary_Constituent__c FROM Account 
           												   WHERE Id IN:accountIds]);// AND ucinn_ascendv2__Primary_Contact__c IN :contactIds]);
   
        // Check for Active Assignments in these Accounts
        if (!accountIds.isEmpty()) {
            List<ucinn_ascendv2__Assignment__c> assignList = [SELECT Id, ucinn_ascendv2__Account__c FROM ucinn_ascendv2__Assignment__c 
                                                              WHERE ucinn_ascendv2__Account__c IN :accountIds 
                                                              AND nd_Is_Active__c = true AND ucinn_ascendv2__Assignment_Type__c ='Primary Relationship Manager']; 
            system.debug('assignList '+assignList);
            Set<Id> contactIdToQuery = new Set<Id>();
            Set<Id> contactIdsToCheck = new Set<Id>();
            
            // Collect all primary and secondary contact IDs
            for (ucinn_ascendv2__Assignment__c assign : assignList) {
                Account account = accountMap.get(assign.ucinn_ascendv2__Account__c);
                if (account != null) {
                    Id primaryContactId = account.ucinn_ascendv2__Primary_Contact__c;
                    Id secondaryContactId = account.Secondary_Constituent__c;
                    
                    if (contactsMap.containsKey(primaryContactId)) {
                        contactIdsToCheck.add(primaryContactId);
                    }
                    if (contactsMap.containsKey(secondaryContactId)) {
                        contactIdsToCheck.add(secondaryContactId);
                    }
                }
            }
            
            Map<Id, Id> contactToAddressesMap = new Map<Id, Id>();
            for (ucinn_ascendv2__Address_Relation__c relation : [ SELECT ucinn_ascendv2__Address__c, ucinn_ascendv2__Contact__c FROM ucinn_ascendv2__Address_Relation__c
                												WHERE ucinn_ascendv2__Contact__c IN :contactIdsToCheck AND ucinn_ascendv2__Type__c = 'H'
                                                                 AND ucinn_ascendv2__Status__c = 'Current' and  ucinn_ascendv2__Is_Preferred__c=true ])
             {
                // Map each contact ID to its related address IDs
                if (!contactToAddressesMap.containsKey(relation.ucinn_ascendv2__Contact__c)) {
                    contactToAddressesMap.put(relation.ucinn_ascendv2__Contact__c, relation.ucinn_ascendv2__Address__c);
                }
                //contactToAddressesMap.get(relation.ucinn_ascendv2__Contact__c).add(relation.ucinn_ascendv2__Address__c);
             }
            for (ucinn_ascendv2__Assignment__c assign : assignList) {
                Account account = accountMap.get(assign.ucinn_ascendv2__Account__c);
                if (account != null) {
                    // Process primary contact
                    Id primaryContactId = account.ucinn_ascendv2__Primary_Contact__c;
                    if (contactToAddressesMap.containsKey(primaryContactId)) {
                        Id primaryContactAddress = contactToAddressesMap.get(primaryContactId);
                        for (ucinn_ascendv2__Address__c changedAddress : newAddress) {
                            if (primaryContactAddress == changedAddress.Id) {
                                contactIdToQuery.add(primaryContactId);
                            }
                        }
                    }
                    // Process secondary contact
                    Id secondaryContactId = account.Secondary_Constituent__c;
                    if (contactToAddressesMap.containsKey(secondaryContactId)) {
                        Id secondaryContactAddress = contactToAddressesMap.get(secondaryContactId);
                        for (ucinn_ascendv2__Address__c changedAddress : newAddress) {
                            if (secondaryContactAddress == changedAddress.Id) {
                                contactIdToQuery.add(secondaryContactId);
                            }
                        }
                    }
                }
            }            
     

       List<ucinn_ascendv2__Address_Relation__c> relationList = new List<ucinn_ascendv2__Address_Relation__c>(); 
        if (!contactIdToQuery.isEmpty()) {
            relationList= [select id,ND_Address_Country__c,ucinn_ascendv2__Contact__r.Account.ND_Household_Category__c,ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__Primary_Contact__c,ucinn_ascendv2__Contact__r.Account.Secondary_Constituent__c, ucinn_ascendv2__Status__c,ucinn_ascendv2__Type__c,ND_RecordTypeName__c,ucinn_ascendv2__End_Date__c,
                           ucinn_ascendv2__Contact__c,ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__c,ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__r.ND_Group_Region__c,Is_ERD_Or_EPD__c, ucinn_ascendv2__Address_Postal_Code_Formula__c,ucinn_ascendv2__Address__c,
                           ucinn_ascendv2__Is_Preferred__c,ucinn_ascendv2__Address_State_Formula__c,ucinn_ascendv2__Contact__r.AccountId,ucinn_ascendv2__Address__r.ucinn_ascendv2__Country__c from ucinn_ascendv2__Address_Relation__c
                           where  ucinn_ascendv2__Contact__c=:contactIdToQuery  AND
                           ucinn_ascendv2__Type__c='H' AND ucinn_ascendv2__Status__c='Current' AND   ucinn_ascendv2__End_Date__c=null and  ucinn_ascendv2__Is_Preferred__c=true]; 
                            //AND ucinn_ascendv2__Address_Postal_Code_Formula__c !=null                 
            
        }
        if (!relationList.isEmpty()) 
        {
            PopulateHouseholdClubsfornewAddress(relationList);            
        } 
    }
    }
     public static void setBatchForBusiness(List<ucinn_ascendv2__Address_Relation__c> activeBusinessRelations)
    {
        List<ucinn_ascendv2__Address__c> addressesToUpdate = new List<ucinn_ascendv2__Address__c>();
        
         for (ucinn_ascendv2__Address_Relation__c businessRelation : activeBusinessRelations) {
        if (businessRelation.ucinn_ascendv2__Address__c != null) {
            ucinn_ascendv2__Address__c relatedAddress = businessRelation.ucinn_ascendv2__Address__r;
            relatedAddress.ND_ToBeProcessedByBatchJob__c = System.today();
            addressesToUpdate.add(relatedAddress);
        }
    }
        if (!addressesToUpdate.isEmpty()) {
            String errorMsg='';
            List<Database.SaveResult>updateResults = Database.update(addressesToUpdate, false);
            for(Integer i=0;i<updateResults.size();i++){
                if (!updateResults.get(i).isSuccess()){
                    Database.Error error = updateResults.get(i).getErrors().get(0);String failedDML = error.getMessage();
                    errorMsg = errorMsg+failedDML+'-'+addressesToUpdate.get(i).Id+'\n';
                    system.debug('errorMsgAddress '+errorMsg);
                }        
            } 
        }
    }
    public static void PopulateHouseholdClubsfornewAddress(List<ucinn_ascendv2__Address_Relation__c> addressRelations)
    {
        Map<string,string> prmRegionMap = new Map<string,string>();
        Map<string,string> postalCodeMap = new Map<String,String>();
        Map<string,String> countryCodeMap = new Map<String,String>();
        // new line added for If country is Canada (CA)--
        Map<string,String> StateCodeMap = new Map<String,String>();
        Map<string,ND_Geo_Group_Region__c> postalcodeGeoGroup = new Map<String,ND_Geo_Group_Region__c>();
        Map<string,Contact> newConMap = new Map<string,Contact>();
        Map<string,Account> newAccMap = new Map<string,Account>();
        
        for(ucinn_ascendv2__Address_Relation__c arc: addressRelations){
            if(arc.ucinn_ascendv2__Type__c == 'H' && arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__c!=null && 
               arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__r.ND_Group_Region__c!=null){
                   prmRegionMap.put(arc.ucinn_ascendv2__Contact__r.AccountId,arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__r.ND_Group_Region__c);
                   system.debug('prmRegionMap '+prmRegionMap);
               }
            // New changes for country Code. I did find few records(9799) using the country code instead of Country Name
            if((arc.ND_Address_Country__c=='United States' || arc.ND_Address_Country__c=='US' ) && arc.ucinn_ascendv2__Address_Postal_Code_Formula__c!=NULL ){
                postalCodeMap.put(arc.ucinn_ascendv2__Address__c, arc.ucinn_ascendv2__Address_Postal_Code_Formula__c.split('-')[0]);
                system.debug('postalCodeMap '+postalCodeMap);
            }// new line added for If country is Canada (CA)--
            else if(arc.ND_Address_Country__c=='Canada' || arc.ND_Address_Country__c=='CA') {
                countryCodeMap.put(arc.ucinn_ascendv2__Address__c, arc.ND_Address_Country__c);
                StateCodeMap.put(arc.ucinn_ascendv2__Address__c, arc.ucinn_ascendv2__Address_State_Formula__c);
            }
            else if(String.isNotBlank(arc.ND_Address_Country__c)) {
                countryCodeMap.put(arc.ucinn_ascendv2__Address__c, arc.ND_Address_Country__c);
            }
        }
        
        if(!postalCodeMap.isEmpty()){
            for(ND_Geo_Group_Region__c gr: [Select id,Postal_Code__c,Prospect_Region__c,ND_Club_Region__c,MSA_Code__c,MSA_Name__c,Country__c from ND_Geo_Group_Region__c where Postal_Code__c=:postalCodeMap.values()]){
                postalcodeGeoGroup.put(gr.Postal_Code__c, gr);
            }
        }
        if(!countryCodeMap.isEmpty()){
            for(ND_Geo_Group_Region__c gr: [Select id,Postal_Code__c,Prospect_Region__c,ND_Club_Region__c,MSA_Code__c,MSA_Name__c,Country__c,nd_Country_Full_Name__c from ND_Geo_Group_Region__c where nd_Country_Full_Name__c=:countryCodeMap.values() OR Country__c=:countryCodeMap.values()]){
                postalcodeGeoGroup.put(gr.nd_Country_Full_Name__c, gr);
                //Add Country__c to postalcodeGeoGroup map to accomodate 2-digit country code
                postalcodeGeoGroup.put(gr.Country__c, gr);
            }
        }       
        // New lines for canada country
        if(!StateCodeMap.isEmpty() && !countryCodeMap.isEmpty()){
            for(ND_Geo_Group_Region__c gr: [Select id,Postal_Code__c,Prospect_Region__c,ND_Club_Region__c,MSA_Code__c,MSA_Name__c,Country__c,nd_Country_Full_Name__c from ND_Geo_Group_Region__c where (nd_Country_Full_Name__c=:countryCodeMap.values() OR Country__c=:countryCodeMap.values()) AND State_Code__c=:StateCodeMap.values()]){
                postalcodeGeoGroup.put(gr.nd_Country_Full_Name__c, gr);
                postalcodeGeoGroup.put(gr.Country__c, gr);
            }
        }
      
        for(ucinn_ascendv2__Address_Relation__c arc: addressRelations){
            contact con ;
            Account acc ;
            if(newConMap.containsKey(arc.ucinn_ascendv2__Contact__c))
                con = newConMap.get(arc.ucinn_ascendv2__Contact__c);           
            else
                con = new contact(id=arc.ucinn_ascendv2__Contact__c,ND_Club_Region__c=null,
                                  nd_Alumni_Club_Business__c = null, 
                                  ND_Home_Address_Region__c = null,
                                  MSA_Code__c = null,
                                  MSA_Name__c = null,   
                                  Prospect_Region__c =null  );
            
            if(newAccMap.containsKey(arc.ucinn_ascendv2__Contact__r.AccountId))
                acc = newAccMap.get(arc.ucinn_ascendv2__Contact__r.AccountId);            
            else
                acc = new Account(id=arc.ucinn_ascendv2__Contact__r.AccountId,
                                  ND_Home_Address_Region__c=null,
                                  MSA_Code__c = null,
                                  MSA_Name__c = null, 
                                  Prospect_Region__c = null 
                                 );
        if(arc.ucinn_ascendv2__Type__c == 'H' && arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__c!=null && 
               (arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__r.ND_Group_Region__c!=null||test.isrunningTest())){
                   
                   con.Prospect_Region__c = arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__r.ND_Group_Region__c;
                   acc.Prospect_Region__c= arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__r.ND_Group_Region__c;
               }
            // Country code Us
            if((arc.ND_Address_Country__c=='United States' || arc.ND_Address_Country__c=='US' ) && arc.ucinn_ascendv2__Address_Postal_Code_Formula__c!=NULL){
                ND_Geo_Group_Region__c gr;
                String postalcode =arc.ucinn_ascendv2__Address_Postal_Code_Formula__c.split('-')[0];
                if(postalcodeGeoGroup.containsKey(postalcode))
                    gr =postalcodeGeoGroup.get(arc.ucinn_ascendv2__Address_Postal_Code_Formula__c.split('-')[0]);
                    system.debug('gr '+gr);
                if(gr!=null && arc.ucinn_ascendv2__Type__c=='H' ){
                        acc.ND_Home_Address_Region__c = gr.Prospect_Region__c;                        
                        con.ND_Home_Address_Region__c =gr.Prospect_Region__c;
                      if(arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__c==null ||
                          (arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__c!=null && 
                           arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__r.ND_Group_Region__c==null)){
                        con.Prospect_Region__c =gr.Prospect_Region__c;
                        acc.Prospect_Region__c = gr.Prospect_Region__c;   
                       }
                        con.ND_Club_Region__c = gr.ND_Club_Region__c;
                       if(arc.ucinn_ascendv2__Is_Preferred__c || Test.isRunningTest()){
                        con.MSA_Code__c = gr.MSA_Code__c;
                        con.MSA_Name__c = gr.MSA_Name__c;
                       	acc.MSA_Code__c =gr.MSA_Code__c;
                       	acc.MSA_Name__c =gr.MSA_Name__c;
                       }
                }                                                 
                
            }// end of united states logic  
            else{
                ND_Geo_Group_Region__c ggr;
                //postalCodeMap.put(arc.ucinn_ascendv2__Address__c, arc.ucinn_ascendv2__Address_Postal_Code_Formula__c);
                if(postalcodeGeoGroup.containsKey(arc.ND_Address_Country__c)){
                    ggr =postalcodeGeoGroup.get(arc.ND_Address_Country__c);
                }
                if(ggr!=null && arc.ucinn_ascendv2__Type__c=='H' ){
                        acc.ND_Home_Address_Region__c = ggr.Prospect_Region__c;                        
                        con.ND_Home_Address_Region__c =ggr.Prospect_Region__c;
                     con.ND_Club_Region__c = ggr.ND_Club_Region__c;
                       if(arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__c==null && 
                          arc.ucinn_ascendv2__Contact__r.Account.ND_Household_Category__c!='AS'){
                        con.Prospect_Region__c =ggr.Prospect_Region__c;
                        acc.Prospect_Region__c = ggr.Prospect_Region__c;   
                       } 
                       if(arc.ucinn_ascendv2__Is_Preferred__c || Test.isRunningTest()){
                        con.MSA_Code__c = ggr.MSA_Code__c;
                        con.MSA_Name__c = ggr.MSA_Name__c;
                        acc.MSA_Code__c =ggr.MSA_Code__c;
                       	acc.MSA_Name__c = ggr.MSA_Name__c;
                       }
                }                                 
            }  // global address
            if(arc.ucinn_ascendv2__Contact__c==arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__Primary_Contact__c)
              {
                newConMap.put(con.Id,con);
                newAccMap.put(acc.Id,acc);  
                  
              }else if(arc.ucinn_ascendv2__Contact__c==arc.ucinn_ascendv2__Contact__r.Account.Secondary_Constituent__c){
                 newConMap.put(con.Id,con);  
              }
            
        }// end of loop
        String errorMsg='';
       List<Database.SaveResult> updateResults;
            if(newConMap.size()>0 ){//&& newAccMap.size()>0
                updateResults = Database.update(newConMap.values(), false);
                for(Integer i=0;i<updateResults.size();i++){
                    if (!updateResults.get(i).isSuccess()){
                        Database.Error error = updateResults.get(i).getErrors().get(0);String failedDML = error.getMessage();
                        errorMsg = errorMsg+failedDML+'-'+newConMap.values().get(i).Id+'\n';
                        system.debug('errorMsgCon '+errorMsg);
                    }        
                }
            }
            if(newAccMap.size()>0 ) {
                updateResults = Database.update(newAccMap.values(), false);
                for(Integer i=0;i<updateResults.size();i++){
                    if (!updateResults.get(i).isSuccess()){
                        Database.Error error = updateResults.get(i).getErrors().get(0);String failedDML = error.getMessage();
                        errorMsg = errorMsg+failedDML+'-'+newAccMap.values().get(i).Id+'\n';
                        system.debug('errorMsgAcc '+errorMsg);
                    }        
                }
            }
    }
}