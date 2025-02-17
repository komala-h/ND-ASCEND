/**
 * Affiliation trigger Handler class
 * 
 * @author  Stela Zhang
 * @version  1.1, 2020-09-09
 * @since  1.0
 */
global class asc_TRIG_AffiliationHandler extends ucinn_ascendv2.ascend_TDTM_Runnable {
  private ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper = new ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper();

  /*******************************************************************************************************
   * @description Overridden method that handles the trigger actions and calls the relevant logic
   * @return The dmlWrapper with any sObjects to be inserted/updated/deleted
   */
  global override ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, ucinn_ascendv2.ascend_TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
    List<ucinn_ascendv2__Affiliation__c> triggerNew = (List<ucinn_ascendv2__Affiliation__c>) newList;
    List<ucinn_ascendv2__Affiliation__c> triggerOld = (List<ucinn_ascendv2__Affiliation__c>) oldList;

    Map<Id, ucinn_ascendv2__Affiliation__c> triggerOldMap = new Map<Id, ucinn_ascendv2__Affiliation__c>();
    if (triggerOld != null) {
      for (ucinn_ascendv2__Affiliation__c affiliation : triggerOld) {
        triggerOldMap.put(affiliation.Id, affiliation);
      }
    }

    if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeInsert) {
        setPrimaryToTrueIfCurrent(triggerNew);
        processAffiliationWorkflowRules(triggerNew, triggerOldMap);
        ND_AffilationProcessor.processSinglePrimaryEmployer(triggerNew,false);
        

    } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterInsert) {
        updateAddressRelationPhoneEmailFromAffiliation(triggerNew, triggerOldMap);
        ND_AffilationProcessor.UpdateConstituentType(triggerNew);
        updateConstituentIfPrimaryAffiliation(triggerNew, TriggerOldMap);
     
    } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeUpdate) {
        processAffiliationWorkflowRules(triggerNew, triggerOldMap);
        ND_AffilationProcessor.processSinglePrimaryEmployer(triggerNew,false);

    } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterUpdate) {
        updateAddressRelationPhoneEmailFromAffiliation(triggerNew, triggerOldMap);
        ND_AffilationProcessor.UpdateConstituentType(triggerNew);
        ND_AffilationProcessor.inactivateRelatedBusinessComms(triggerNew,triggerOld); //added Jay's class to inactivate address,email, phone records
        updateConstituentIfPrimaryAffiliation(triggerNew, TriggerOldMap);
      
    } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeDelete) {
    
    } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterDelete) {
        updateConstituentIfPrimaryAffiliation(triggerNew, TriggerOldMap);

    } 

    return dmlWrapper;
  }
  /**
   * This method sets primary employment to TRUE/FALSE based on CURRENT/FORMER Affiliation status
   * @param triggerNew list of new Affiliation records
   */
  private void setPrimaryToTrueIfCurrent(List<ucinn_ascendv2__Affiliation__c> triggerNew) {
    
  }

    /*******************************************************************************************************
     * @description Method run to update corresponding Address Relation, Phone, and Email when respective field is populated
     * @param triggerNew The list of newly updated Affiliations
     * @param triggerOldMap The map of the old versions of the newly updated Affiliations
     * @return N/A
     */
    private void updateAddressRelationPhoneEmailFromAffiliation(List<ucinn_ascendv2__Affiliation__c> triggerNew, Map<Id, ucinn_ascendv2__Affiliation__c> triggerOldMap) {

        Map<Id, Id> mapAddressRelIdToAffilId = new Map<Id, Id>();
        Map<Id, Id> mapPhoneIdToAffilId = new Map<Id, Id>();
        Map<Id, Id> mapEmailIdToAffilId = new Map<Id, Id>();
        Map<Id, Date> mapAffilIdToEndDate = new Map<Id, Date>();

        // system.debug('this is triggernew ');
        // for (ucinn_ascendv2__Affiliation__c tnew : triggerNew) {
        //     system.debug(tnew);
        // }

        for (ucinn_ascendv2__Affiliation__c affil : triggerNew) {
            // system.debug('!!! affil status and endddate ' + affil.ucinn_ascendv2__Status__c + affil.ucinn_ascendv2__End_Date__c);
            if (affil.ucinn_ascendv2__Status__c == 'Former' && affil.ucinn_ascendv2__End_Date__c != null) {
                mapAffilIdToEndDate.put(affil.Id, affil.ucinn_ascendv2__End_Date__c);
            }

            if (affil.Business_Address__c != null) {

                if ((Trigger.isInsert) || (Trigger.isUpdate && (triggerOldMap.get(affil.Id).Business_Address__c != affil.Business_Address__c))) {

                    mapAddressRelIdToAffilId.put(affil.Business_Address__c, affil.Id);    
                }
            }

            if (affil.Business_Phone__c != null) {
                if ((Trigger.isInsert) || (Trigger.isUpdate && (triggerOldMap.get(affil.Id).Business_Phone__c != affil.Business_Phone__c))) {

                    mapPhoneIdToAffilId.put(affil.Business_Phone__c, affil.Id);    
                }

            }

            if (affil.Business_Email__c != null) {
                if ((Trigger.isInsert) || (Trigger.isUpdate && (triggerOldMap.get(affil.Id).Business_Email__c != affil.Business_Email__c))) {

                    mapEmailIdToAffilId.put(affil.Business_Email__c, affil.Id);    
                }
            }
        }

        if (!mapAddressRelIdToAffilId.isEmpty()) {
            List<ucinn_ascendv2__Address_Relation__c> addrelsToUpdate = [SELECT Id
                                                                         FROM ucinn_ascendv2__Address_Relation__c
                                                                         WHERE (Id IN: mapAddressRelIdToAffilId.keySet())];
            for (ucinn_ascendv2__Address_Relation__c addrel : addrelsToUpdate) {
                addrel.Affiliation__c = mapAddressRelIdToAffilId.get(addrel.Id);

                if (mapAffilIdToEndDate.containsKey(addrel.Affiliation__c)) {
                    addrel.ucinn_ascendv2__End_Date__c = mapAffilIdToEndDate.get(addrel.Affiliation__c);
                    addrel.ucinn_ascendv2__Status__c = 'Former';
                    addrel.ucinn_ascendv2__Is_Preferred__c = false;
                }
            }
            update addrelsToUpdate;
        }

        if (!mapPhoneIdToAffilId.isEmpty()) {
            List<ucinn_ascendv2__Phone__c> phonesToUpdate = [SELECT Id
                                                            FROM ucinn_ascendv2__Phone__c
                                                            WHERE (Id IN: mapPhoneIdToAffilId.keySet())];
            for (ucinn_ascendv2__Phone__c phone : phonesToUpdate) {
                phone.Affiliation__c = mapPhoneIdToAffilId.get(phone.Id);

                if (mapAffilIdToEndDate.containsKey(phone.Affiliation__c)) {
                    phone.ucinn_ascendv2__End_Date__c = mapAffilIdToEndDate.get(phone.Affiliation__c);
                    phone.ucinn_ascendv2__Status__c = 'Former';
                    phone.ucinn_ascendv2__Is_Preferred__c = false;
                    
                }
            }
            update phonesToUpdate;
        }

        if (!mapEmailIdToAffilId.isEmpty()) {
            List<ucinn_ascendv2__Email__c> emailsToUpdate = [SELECT Id
                                                            FROM ucinn_ascendv2__Email__c
                                                            WHERE (Id IN: mapEmailIdToAffilId.keySet())];
            for (ucinn_ascendv2__Email__c email : emailsToUpdate) {
                email.Affiliation__c = mapEmailIdToAffilId.get(email.Id);

                if (mapAffilIdToEndDate.containsKey(email.Affiliation__c)) {
                    email.ucinn_ascendv2__End_Date__c = mapAffilIdToEndDate.get(email.Affiliation__c);
                    email.ucinn_ascendv2__Status__c = 'Former';
                    email.ucinn_ascendv2__Is_Preferred__c = false;
                   
                }
            }
            update emailsToUpdate;
        }           
    }

    private void processAffiliationWorkflowRules(List<ucinn_ascendv2__Affiliation__c> triggerNew, Map<Id, ucinn_ascendv2__Affiliation__c> triggerOldMap) {

        Set<Id> affilIdsToUpdateOrgSearchWithAccountName = new Set<Id>();

        for (ucinn_ascendv2__Affiliation__c affil : triggerNew) {

            if (affil.ucinn_ascendv2__Status__c == 'Current' ) {
                if(affil.ucinn_ascendv2__Start_Date__c == null){
                    affil.ucinn_ascendv2__Start_Date__c = date.today();
                }
                if(affil.ucinn_ascendv2__End_Date__c != null){
                    affil.ucinn_ascendv2__End_Date__c = null;
                }
            }

            if (affil.ucinn_ascendv2__Status__c == 'Former') {
                if(affil.ucinn_ascendv2__End_Date__c == null){
                    system.debug('end date :' + affil.ucinn_ascendv2__End_Date__c);
                    affil.ucinn_ascendv2__End_Date__c = date.today();
                }
                /*if(affil.ucinn_ascendv2__Start_Date__c == null){
                    affil.ucinn_ascendv2__Start_Date__c = date.today();
                }*/
                affil.Is_Primary_Employment__c = false;
            }
            
            
            //qluong 12/1/22 - Also make sure the status stays Current?
            if (affil.ucinn_ascendv2__Constituent_Role__c == 'Retired Employee') {
                affil.Is_Primary_Employment__c = false; // qluong 2/24/2023 requirement per task T-01243
            }

            
            if (affil.Employer_Name__c == null) {
                affilIdsToUpdateOrgSearchWithAccountName.add(affil.Id);
                affil.Organization_search__c = affil.ucinn_ascendv2__Account__r.Name; 
            }
            else if (affil.Employer_Name__c != null) {
                affil.Organization_search__c = affil.Employer_Name__c;
            }
        }

        if (!affilIdsToUpdateOrgSearchWithAccountName.isEmpty()) {
            Map<Id, ucinn_ascendv2__Affiliation__c> mapIdToAffilsToUpdateOrgSearchWithAccountName = new Map<Id, ucinn_ascendv2__Affiliation__c>([SELECT Id, ucinn_ascendv2__Account__r.Name
                                                                                                                                                FROM ucinn_ascendv2__Affiliation__c 
                                                                                                                                                WHERE (Id IN: affilIdsToUpdateOrgSearchWithAccountName)]);
            for (ucinn_ascendv2__Affiliation__c affil : triggerNew) {
                if (mapIdToAffilsToUpdateOrgSearchWithAccountName.containsKey(affil.Id)) {
                    affil.Organization_search__c = mapIdToAffilsToUpdateOrgSearchWithAccountName.get(affil.Id).ucinn_ascendv2__Account__r.Name;
                }
            }
        }
    }

    private void updateConstituentIfPrimaryAffiliation(List<ucinn_ascendv2__Affiliation__c> triggerNew, Map<Id, ucinn_ascendv2__Affiliation__c> triggerOldMap){
        List<ucinn_ascendv2__Affiliation__c> affilList;
        List<Contact> contactWithAffil;
        List<Contact> contactsToUpdate = new List<Contact>();
        Map<Id, Contact> conMap;
        Set<Id> affilIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        Set<Id> contactsPACheck = new Set<Id>();
        Contact con;

        // gather contact ids
        if(Trigger.isDelete){
            for(ucinn_ascendv2__Affiliation__c affil: triggerOldMap.values()){
                contactIds.add(affil.ucinn_ascendv2__Contact__c);
            }     
        }
        else{
            for(ucinn_ascendv2__Affiliation__c affil: triggerNew){
                contactIds.add(affil.ucinn_ascendv2__Contact__c);
                affilIds.add(affil.id);
            }     

            // query to get the account record name
            affilList = [SELECT id, ucinn_ascendv2__Status__c, Is_Primary_Employment__c, ucinn_ascendv2__Business_Title__c, 
                        ucinn_ascendv2__Contact__c, ucinn_ascendv2__Account__c, ucinn_ascendv2__Account__r.Name, Employer_Name__c 
                        FROM ucinn_ascendv2__Affiliation__c 
                        WHERE id IN: affilIds];
        }

        conMap = new Map<Id, Contact>([SELECT id, Current_Employer__c, Employer_Name__c, Title
                                        FROM Contact
                                        WHERE id IN: contactIds]);

        if(Trigger.isInsert){
            for(ucinn_ascendv2__Affiliation__c affil: affilList){
                if(affil.ucinn_ascendv2__Status__c == 'Current' && affil.Is_Primary_Employment__c == true){
                    con = conMap.get(affil.ucinn_ascendv2__Contact__c);
                    con.Current_Employer__c = affil.ucinn_ascendv2__Account__c;
                    
                    //qluong - add logic on 3/17/2023 to support use case where the organization is name only. In such a case, use the employer name
                    //on the affiliation record to populate the employer name field on the constituent record.
                    if(affil.ucinn_ascendv2__Account__r.Name == 'EMPLOYER IN NAME ONLY'){
                        con.Employer_Name__c = affil.Employer_Name__c;
                    }
                    else{
                        con.Employer_Name__c ='';
                    }
                    
                    con.Title = affil.ucinn_ascendv2__Business_Title__c;

                    contactsToUpdate.add(con);
                }
            }
        }
        else if(Trigger.isUpdate){
            for(ucinn_ascendv2__Affiliation__c affil: affilList){
                if(affil.ucinn_ascendv2__Status__c == 'Current' && affil.Is_Primary_Employment__c == true &&
                    (affil.ucinn_ascendv2__Status__c != triggerOldMap.get(affil.id).ucinn_ascendv2__Status__c ||
                    affil.Is_Primary_Employment__c != triggerOldMap.get(affil.id).Is_Primary_Employment__c
                    || affil.ucinn_ascendv2__Business_Title__c != triggerOldMap.get(affil.id).ucinn_ascendv2__Business_Title__c)
                  ){
                    
                    con = conMap.get(affil.ucinn_ascendv2__Contact__c);
                    con.Current_Employer__c = affil.ucinn_ascendv2__Account__c;
                    
                    //qluong - add logic on 3/17/2023 to support use case where the organization is name only. In such a case, use the employer name
                    //on the affiliation record to populate the employer name field on the constituent record.
                    if(affil.ucinn_ascendv2__Account__r.Name == 'EMPLOYER IN NAME ONLY'){
                        con.Employer_Name__c = affil.Employer_Name__c;
                    }
                    else{
                        con.Employer_Name__c ='';
                    }
                    con.Title = affil.ucinn_ascendv2__Business_Title__c;

                    contactsToUpdate.add(con);
                }
                else if((affil.ucinn_ascendv2__Status__c != 'Current' || affil.Is_Primary_Employment__c != true) &&
                    triggerOldMap.get(affil.id).ucinn_ascendv2__Status__c == 'Current' &&
                    triggerOldMap.get(affil.id).Is_Primary_Employment__c == true){

                    con = conMap.get(affil.ucinn_ascendv2__Contact__c);
                    con.Current_Employer__c = null;
                    con.Employer_Name__c = null;
                    con.Title = null;

                    contactsPACheck.add(con.id);
                    contactsToUpdate.add(con);
                }
            }
        }
        else if(Trigger.isDelete){
            System.debug('here');
            for(ucinn_ascendv2__Affiliation__c affil: triggerOldMap.values()){
                if(affil.ucinn_ascendv2__Status__c == 'Current' && affil.Is_Primary_Employment__c == true){
                    
                    con = conMap.get(affil.ucinn_ascendv2__Contact__c);
                    con.Current_Employer__c = null;
                    con.Employer_Name__c = null;
                    con.Title = null;

                    contactsPACheck.add(con.id);
                    contactsToUpdate.add(con);
                }
            }  
        }

        if(contactsPACheck.size() > 0){
            contactWithAffil = [SELECT id, 
                                    (SELECT id, ucinn_ascendv2__Business_Title__c, ucinn_ascendv2__Account__c, ucinn_ascendv2__Account__r.Name 
                                    FROM ucinn_ascendv2__Affiliations_Contact__r
                                    WHERE ucinn_ascendv2__Status__c = 'Current'
                                    AND Is_Primary_Employment__c = true) 
                                    FROM Contact WHERE Id IN: contactsPACheck];

            for(Contact contact: contactWithAffil){
                for(ucinn_ascendv2__Affiliation__c affil: contact.ucinn_ascendv2__Affiliations_contact__r){
                    contact.Current_Employer__c = affil.ucinn_ascendv2__Account__c;
                    contact.Employer_Name__c = affil.ucinn_ascendv2__Account__r.Name;
                    contact.Title = affil.ucinn_ascendv2__Business_Title__c;
                }
            }
        }

        if(contactsToUpdate.size() > 0){
            update contactsToUpdate;
        }
    }
  
}