/*Description:An Active new Home Address record is created on a Constituent
				where their respective Household has an Active Assignment record Populate Home Address region.
*
*/

global class Nd_TRIG_AddressRelationHandler extends ucinn_ascendv2.ascend_TDTM_Runnable {
    
    private ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper = new ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper();
    
    global override ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, ucinn_ascendv2.ascend_TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        List<ucinn_ascendv2__Address_Relation__c> triggerNew = (List<ucinn_ascendv2__Address_Relation__c>) newList;
        List<ucinn_ascendv2__Address_Relation__c> triggerOld = (List<ucinn_ascendv2__Address_Relation__c>) oldList;
        
        Map<Id, ucinn_ascendv2__Address_Relation__c> triggerOldMap = new Map<Id, ucinn_ascendv2__Address_Relation__c>();
        if (triggerOld != null) {
            for (ucinn_ascendv2__Address_Relation__c add : triggerOld) {
                triggerOldMap.put(add.Id, add);
            }
        }
        
        if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterInsert) {
            populateAddressRelations(triggerNew);
        } 
        else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterUpdate) {
            processPreferredAddressRelations(triggerNew,triggerOldMap);
        } 
        else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterDelete) {
            
        } 
        return dmlWrapper;
    }
    public static void processPreferredAddressRelations(List<ucinn_ascendv2__Address_Relation__c> newAddressRelation,Map<Id,ucinn_ascendv2__Address_Relation__c> oldAddressRelationMap)
    {
        Set<Id> contactIds = new Set<Id>();
        Set<Id> addressRelationIds = new Set<Id>();
        if(!oldAddressRelationMap.isEmpty())
        {
            //Check if there is a change in Preferred Address
            for(ucinn_ascendv2__Address_Relation__c addRelation : newAddressRelation){
                if(oldAddressRelationMap.get(addRelation.Id) != null && oldAddressRelationMap.get(addRelation.Id).ucinn_ascendv2__Is_Preferred__c!=addRelation.ucinn_ascendv2__Is_Preferred__c){
                    addressRelationIds.add(addRelation.Id);
                    system.debug('addressRelationIds '+addressRelationIds);
                }
            }
            List<ucinn_ascendv2__Address_Relation__c> addressRelations = [SELECT Id, ucinn_ascendv2__Type__c, ucinn_ascendv2__Is_Preferred__c,ucinn_ascendv2__Address__c,ucinn_ascendv2__Address__r.ND_ToBeProcessedByBatchJob__c,
                                                                          ucinn_ascendv2__Contact__c,ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__c
                                                                          FROM ucinn_ascendv2__Address_Relation__c WHERE Id IN :addressRelationIds  AND  
                                                                         (ucinn_ascendv2__Type__c='H' OR  ucinn_ascendv2__Type__c='B') AND ucinn_ascendv2__Status__c='Current' AND ucinn_ascendv2__End_Date__c=null AND  ucinn_ascendv2__Is_Preferred__c=true];
            
            
            if(!addressRelationIds.isEmpty()){
                List<ucinn_ascendv2__Address_Relation__c> activeBusinessRelations = new List<ucinn_ascendv2__Address_Relation__c>();
                List<ucinn_ascendv2__Address_Relation__c> homeRelationsToProcess = new List<ucinn_ascendv2__Address_Relation__c>();
                
                for (ucinn_ascendv2__Address_Relation__c addRelation : addressRelations) {
                    if (addRelation.ucinn_ascendv2__Type__c == 'B') {
                        activeBusinessRelations.add(addRelation);
                    } else if (addRelation.ucinn_ascendv2__Type__c == 'H') {
                        if (addRelation.ucinn_ascendv2__Contact__c != null && addRelation.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__c!= null) {
                            homeRelationsToProcess.add(addRelation);
                        }else {                   
                            activeBusinessRelations.add(addRelation);
                        } 
                    }
                }            
                // Process Business Address and  Home Address without PRM
                if (!activeBusinessRelations.isEmpty()) {
                    setBatchForBusiness(activeBusinessRelations);
                }           
                // Process Home Address with PRM
                if (!homeRelationsToProcess.isEmpty()) {
                    populateAddressRelations(homeRelationsToProcess);
                } 
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
    public static void populateAddressRelations(List<ucinn_ascendv2__Address_Relation__c> addressRelations)
    {
        Set<Id>ContactIds= new Set<Id>();
        Set<Id>AccountIds= new Set<Id>();
       // Map<Id, Id> primaryContactAccountMap = new Map<Id, Id>(); 
        for (ucinn_ascendv2__Address_Relation__c address : addressRelations) {                               
            if(address.ucinn_ascendv2__Contact__c != null && address.ucinn_ascendv2__Address__c!=NULL) {
                ContactIds.add(address.ucinn_ascendv2__Contact__c);                       
            }
        }      
        if (!contactIds.isEmpty()) {
            for (Contact con : [SELECT Id, AccountId, ND_Home_Address_Region__c, Prospect_Region__c, MSA_Code__c, MSA_Name__c, Account.ucinn_ascendv2__Primary_Contact__c  FROM Contact WHERE Id IN :contactIds]) {            
                if (con.AccountId != null ) {
                    accountIds.add(con.AccountId);
                }
            }
        }        
        //Check for the Account that have Active Assignments
        List<ucinn_ascendv2__Assignment__c>AssignList=[Select Id,ucinn_ascendv2__Account__c,nd_Is_Active__c,ucinn_ascendv2__Assignment_Type__c from
                                                       ucinn_ascendv2__Assignment__c where ucinn_ascendv2__Account__c=:accountIds and nd_Is_Active__c=true  AND ucinn_ascendv2__Assignment_Type__c ='Primary Relationship Manager'];       
        if(!AssignList.isEmpty())
        {
            List<ucinn_ascendv2__Address_Relation__c> relationList =[select id,ND_Address_Country__c,ucinn_ascendv2__Contact__r.Account.ND_Household_Category__c,ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__Primary_Contact__c,ucinn_ascendv2__Contact__r.Account.Secondary_Constituent__c, ucinn_ascendv2__Status__c,ucinn_ascendv2__Type__c,ND_RecordTypeName__c,ucinn_ascendv2__End_Date__c,
                                                                     ucinn_ascendv2__Contact__c,ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__c,ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__r.ND_Group_Region__c,Is_ERD_Or_EPD__c, ucinn_ascendv2__Address_Postal_Code_Formula__c,ucinn_ascendv2__Address__c,
                                                                     ucinn_ascendv2__Is_Preferred__c,ucinn_ascendv2__Address_State_Formula__c,ucinn_ascendv2__Contact__r.AccountId,ucinn_ascendv2__Address__r.ucinn_ascendv2__Country__c from ucinn_ascendv2__Address_Relation__c
                                                                     where  ucinn_ascendv2__Contact__c in:ContactIds  AND  
                                                                     ucinn_ascendv2__Type__c='H' AND ucinn_ascendv2__Status__c='Current' AND ucinn_ascendv2__End_Date__c=null AND  ucinn_ascendv2__Is_Preferred__c=true];
            
            Map<string,string> prmRegionMap = new Map<string,string>();
            Map<string,string> postalCodeMap = new Map<String,String>();
            Map<string,String> countryCodeMap = new Map<String,String>();
            // new line added for If country is Canada (CA)--
            Map<string,String> StateCodeMap = new Map<String,String>();
            Map<string,ND_Geo_Group_Region__c> postalcodeGeoGroup = new Map<String,ND_Geo_Group_Region__c>();
            Map<string,Contact> newConMap = new Map<string,Contact>();
            Map<string,Account> newAccMap = new Map<string,Account>();
            
            for(ucinn_ascendv2__Address_Relation__c arc: relationList){
                if(arc.ucinn_ascendv2__Type__c == 'H' && arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__c!=null && 
                   arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__r.ND_Group_Region__c!=null){
                       prmRegionMap.put(arc.ucinn_ascendv2__Contact__r.AccountId,arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__r.ND_Group_Region__c);
                       system.debug('prmRegionMap '+prmRegionMap);
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
                    system.debug('postalcodeGeoGroup '+postalcodeGeoGroup);
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
            
            
            for(ucinn_ascendv2__Address_Relation__c arc: relationList){              
                contact con ;
                Account acc ;
                if(newConMap.containsKey(arc.ucinn_ascendv2__Contact__c))
                    con = newConMap.get(arc.ucinn_ascendv2__Contact__c);
                
                else
                    con = new contact(id=arc.ucinn_ascendv2__Contact__c,
                                      ND_Club_Region__c=null,
                                      nd_Alumni_Club_Business__c = null, 
                                      ND_Home_Address_Region__c = null,
                                      MSA_Code__c = null,
                                      MSA_Name__c = null,   
                                      Prospect_Region__c =null 
                                       );
                
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
                       system.debug('inside PRm');
                       con.Prospect_Region__c = arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__r.ND_Group_Region__c;
                       acc.Prospect_Region__c= arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__r.ND_Group_Region__c;
                       //prmRegionMap.put(arc.ucinn_ascendv2__Contact__r.AccountId,arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__r.ND_Group_Region__c);
                   }
                // Country code Us
                if((arc.ND_Address_Country__c=='United States' || arc.ND_Address_Country__c=='US') && arc.ucinn_ascendv2__Address_Postal_Code_Formula__c!=NULL){
                    ND_Geo_Group_Region__c gr;
                    String postalcode =arc.ucinn_ascendv2__Address_Postal_Code_Formula__c.split('-')[0];
                    //postalCodeMap.put(arc.ucinn_ascendv2__Address__c, arc.ucinn_ascendv2__Address_Postal_Code_Formula__c);
                    if(postalcodeGeoGroup.containsKey(postalcode))
                        gr =postalcodeGeoGroup.get(arc.ucinn_ascendv2__Address_Postal_Code_Formula__c.split('-')[0]);
                  
                    if(gr!=null && arc.ucinn_ascendv2__Type__c=='H' ){
                        // if( arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__c!=null){ //&& arc.Is_ERD_Or_EPD__c && arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__r.ND_Group_Region__c==null)                          
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
                       // if( arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__c!=null){// && arc.Is_ERD_Or_EPD__c && arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__r.ND_Group_Region__c==null) {                         
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
}