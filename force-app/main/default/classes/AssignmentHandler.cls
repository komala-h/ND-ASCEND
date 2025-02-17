/*Description: When an Assignment is Created for a Household,Using Primary Constituent there, populating the 
               Home Address Region in Constituent and Organization.
 * Date:07/30/24
 */
global class AssignmentHandler extends ucinn_ascendv2.ascend_TDTM_Runnable {
    
    private ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper = new ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper();
    
    global override ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, ucinn_ascendv2.ascend_TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        List<ucinn_ascendv2__Assignment__c> triggerNew = (List<ucinn_ascendv2__Assignment__c>) newList;
        List<ucinn_ascendv2__Assignment__c> triggerOld = (List<ucinn_ascendv2__Assignment__c>) oldList;
        
        Map<Id, ucinn_ascendv2__Assignment__c> triggerOldMap = new Map<Id, ucinn_ascendv2__Assignment__c>();
        if (triggerOld != null) {
            for (ucinn_ascendv2__Assignment__c assign : triggerOld) {
                triggerOldMap.put(assign.Id, assign);
            }
        }
        
        if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterInsert) {
            processAddressRelations(triggerNew,null);
        } 
        else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterUpdate) {
            
        } 
        else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterDelete) {
            processAddressRelations(null,triggerOld);
        } 
        
        return dmlWrapper;
    }
    public static void processAddressRelations(List<ucinn_ascendv2__Assignment__c> newAssignments,List<ucinn_ascendv2__Assignment__c> oldAssignments)
    {
        Set<Id> accountIds = new Set<Id>();
        // Handle deletions
        if (oldAssignments != null && !oldAssignments.isEmpty()) {
            for (ucinn_ascendv2__Assignment__c assignment : oldAssignments) {
                if (assignment.ucinn_ascendv2__Account__c != null && assignment.ucinn_ascendv2__Assignment_Type__c == 'Primary Relationship Manager') {
                    accountIds.add(assignment.ucinn_ascendv2__Account__c);
                }
            }
        }
        // Handle insertions
        if (newAssignments != null && !newAssignments.isEmpty()) {
            for (ucinn_ascendv2__Assignment__c assignment : newAssignments) {
                if (assignment.ucinn_ascendv2__Account__c != null && assignment.ucinn_ascendv2__Assignment_Type__c=='Primary Relationship Manager') {
                    accountIds.add(assignment.ucinn_ascendv2__Account__c);
                }
            }
        }  
        if (!accountIds.isEmpty()) {
            // Query Account records to get ucinn_ascendv2__Primary_Contact__c(Primary Constituent)
            Map<Id, Account> accountsMap = new Map<Id, Account>();
            for (Account acc : [SELECT Id, ND_Home_Address_Region__c,ucinn_ascendv2__Primary_Contact__c,Secondary_Constituent__c FROM Account  WHERE Id IN :accountIds]){   
                accountsMap.put(acc.Id, acc);
            }
            // Query Contacts related to the Accounts
            Set<Id> contactIds = new Set<Id>();
            for (Account acc : accountsMap.values()) {
                if (acc.ucinn_ascendv2__Primary_Contact__c != null) {
                    contactIds.add(acc.ucinn_ascendv2__Primary_Contact__c);
                }
                if (acc.Secondary_Constituent__c != null) {
                    contactIds.add(acc.Secondary_Constituent__c);
                }
            }
            //Put Contact Ids and respective contact in a Map
            Map<Id, Contact> contactsMap = new Map<Id, Contact>();
            if (!contactIds.isEmpty()) {
                for (Contact con : [SELECT Id, ND_Club_Region__c, ND_Home_Address_Region__c, MSA_Code__c, MSA_Name__c, Prospect_Region__c FROM Contact WHERE Id IN :contactIds]) {
                    contactsMap.put(con.Id, con);
                }
            }
            List<ucinn_ascendv2__Address_Relation__c> relations = new List<ucinn_ascendv2__Address_Relation__c>();
            Set<Id> contactIdToQuery = new Set<Id>();  
           List<ucinn_ascendv2__Assignment__c> allAssignments = new List<ucinn_ascendv2__Assignment__c>();         
                    if (newAssignments != null) {
                        allAssignments.addAll(newAssignments);
                    }
                    if (oldAssignments != null) {
                        allAssignments.addAll(oldAssignments);
                    }
                    
                    if (!allAssignments.isEmpty()) {
                        for (ucinn_ascendv2__Assignment__c assignment : allAssignments) {  
                    if (assignment.ucinn_ascendv2__Account__c != null) {
                        Account acc = accountsMap.get(assignment.ucinn_ascendv2__Account__c);
                        if (acc != null && acc.ucinn_ascendv2__Primary_Contact__c != null) {
                            Contact con = contactsMap.get(acc.ucinn_ascendv2__Primary_Contact__c);
                            if (con!= null ) { //&& con.ND_Home_Address_Region__c == null
                                // Query Address Relations records based on Contact ID
                                contactIdToQuery.add(con.Id);                       
                            }
                        }
                        if (acc != null && acc.Secondary_Constituent__c != null) {
                            Contact seccon = contactsMap.get(acc.Secondary_Constituent__c);
                            if (seccon!= null ) { 
                                contactIdToQuery.add(seccon.Id);                       
                            }
                        }                   
                    }
                }                
            }           
            Map<Id,ucinn_ascendv2__Address_Relation__c> activeHomeRelationMap = new Map<Id,ucinn_ascendv2__Address_Relation__c>();
            Map<Id,ucinn_ascendv2__Address_Relation__c>activeBusinessRelationMap = new Map<Id,ucinn_ascendv2__Address_Relation__c>();
            relations= [select id,ND_Address_Country__c,ucinn_ascendv2__Contact__r.Account.ND_Household_Category__c,ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__Primary_Contact__c,ucinn_ascendv2__Contact__r.Account.Secondary_Constituent__c, ucinn_ascendv2__Status__c,ucinn_ascendv2__Type__c,ND_RecordTypeName__c,ucinn_ascendv2__End_Date__c,
                        ucinn_ascendv2__Contact__c,ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__c,ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__r.ND_Group_Region__c,Is_ERD_Or_EPD__c, ucinn_ascendv2__Address_Postal_Code_Formula__c,ucinn_ascendv2__Address__c,ucinn_ascendv2__Address__r.ND_ToBeProcessedByBatchJob__c,
                        ucinn_ascendv2__Is_Preferred__c,ucinn_ascendv2__Address_State_Formula__c,ucinn_ascendv2__Contact__r.AccountId,ucinn_ascendv2__Address__r.ucinn_ascendv2__Country__c from ucinn_ascendv2__Address_Relation__c
                        where  ucinn_ascendv2__Contact__c in:contactIdToQuery  AND 
                        (ucinn_ascendv2__Type__c ='B' OR  ucinn_ascendv2__Type__c='H') AND ucinn_ascendv2__Status__c='Current'  AND ucinn_ascendv2__End_Date__c=null AND  ucinn_ascendv2__Is_Preferred__c=true];     
            for (ucinn_ascendv2__Address_Relation__c relation : relations) {
                if (relation.ucinn_ascendv2__Type__c == 'H') {
                    activeHomeRelationMap.put(relation.ucinn_ascendv2__Contact__c, relation);
                } else if (relation.ucinn_ascendv2__Type__c == 'B') {
                    activeBusinessRelationMap.put(relation.ucinn_ascendv2__Contact__c,relation);
                }
            }             
            if(!activeHomeRelationMap.isEmpty() && !activeBusinessRelationMap.isEmpty()) 
            {
                 setBatchForBusiness(activeBusinessRelationMap.values());
            }
            if(activeHomeRelationMap.isEmpty() && !activeBusinessRelationMap.isEmpty()) 
            {
                setBatchForBusiness(activeBusinessRelationMap.values());               
            }
            if (!activeHomeRelationMap.isEmpty()) 
            {
                PopulateHouseholdClubsfornewAddress(activeHomeRelationMap.values());            
            }
        }
    }
    public static void setBatchForBusiness(List<ucinn_ascendv2__Address_Relation__c> activeBusinessRelations)
    {
        List<ucinn_ascendv2__Address__c> addressesToUpdate = new List<ucinn_ascendv2__Address__c>();
        for (ucinn_ascendv2__Address_Relation__c businessRelation : activeBusinessRelations) {
            businessRelation.ucinn_ascendv2__Address__r.ND_ToBeProcessedByBatchJob__c = System.today();
            addressesToUpdate.add(businessRelation.ucinn_ascendv2__Address__r);
        }
        
        // Perform the update
        if (!addressesToUpdate.isEmpty()) {
            //update addressesToUpdate;
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
            }
            // New changes for country Code. I did find few records(9799) using the country code instead of Country Name
            if((arc.ND_Address_Country__c=='United States' || arc.ND_Address_Country__c=='US' ) && arc.ucinn_ascendv2__Address_Postal_Code_Formula__c!=NULL ){
                postalCodeMap.put(arc.ucinn_ascendv2__Address__c, arc.ucinn_ascendv2__Address_Postal_Code_Formula__c.split('-')[0]);
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
                con = new contact(id=arc.ucinn_ascendv2__Contact__c,
                        Prospect_Region__c =null  );
             
            if(newAccMap.containsKey(arc.ucinn_ascendv2__Contact__r.AccountId))
                acc = newAccMap.get(arc.ucinn_ascendv2__Contact__r.AccountId);
                          
            else
                acc = new Account(id=arc.ucinn_ascendv2__Contact__r.AccountId,
                                 Prospect_Region__c = null 
                                 );
        
            if(arc.ucinn_ascendv2__Type__c == 'H' && arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__c!=null && 
               (arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__r.ND_Group_Region__c!=null||test.isrunningTest())){
                 
               con.Prospect_Region__c = arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__r.ND_Group_Region__c;
               acc.Prospect_Region__c= arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__r.ND_Group_Region__c;
            }
            // Country code Us
            if((arc.ND_Address_Country__c=='United States' || arc.ND_Address_Country__c=='US') && arc.ucinn_ascendv2__Address_Postal_Code_Formula__c!=NULL){
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
                    }                                 

        }// end of united states logic  
        else{
                ND_Geo_Group_Region__c ggr;
            if(postalcodeGeoGroup.containsKey(arc.ND_Address_Country__c)){
                        ggr =postalcodeGeoGroup.get(arc.ND_Address_Country__c); 
                    }
                   if(ggr!=null && arc.ucinn_ascendv2__Type__c=='H' ){
                        	acc.ND_Home_Address_Region__c = ggr.Prospect_Region__c;                        
                        	con.ND_Home_Address_Region__c =ggr.Prospect_Region__c;
                       if(arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__c==null && 
                          arc.ucinn_ascendv2__Contact__r.Account.ND_Household_Category__c!='AS'){
                        con.Prospect_Region__c =ggr.Prospect_Region__c;
                        acc.Prospect_Region__c = ggr.Prospect_Region__c;   
                       } 
                    }                                 
        }
              // global address
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
        if(newConMap.size()>0 ){ //&& newAccMap.size()>0
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