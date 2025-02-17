/**
* @author UC Innovation
* @date 3/27/2023
* @group Trigger Handlers
* @description Handler class for Contact Card Trigger
*/
global with sharing class TRIG_ContactCardHandler extends TRIG_BaseHandler{
    /*******************************************************************************************************
    * @description Before Insert Calls.
    * @param trigContextVars Trigger Context Variables.
    * @param dmlWrapper any dmls required will be in here.
    * @return N/A.
    */
    protected override void beforeInsert(Trigger_ContextVariables trigContextVars, ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper) {
    }
    protected override void afterInsert(Trigger_ContextVariables trigContextVars, ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper) {
        syncContactCardsWithSpouse(trigContextVars);
    }
    protected override void beforeUpdate(Trigger_ContextVariables trigContextVars, ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper) {
    }
    protected override void afterUpdate(Trigger_ContextVariables trigContextVars, ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper) {
    }
    protected override void afterDelete(Trigger_ContextVariables trigContextVars, ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper) {
    }
    protected override void afterUndelete(Trigger_ContextVariables trigContextVars, ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper) {
    }

    /*******************************************************************************************************
     * @description Method run to uncheck Sync Home Address and/or Sync Seasonal Address
     * @param triggerNew The list of newly updated Relationships
     * @return N/A
     */
    private void syncContactCardsWithSpouse(Trigger_ContextVariables trigContextVars) {
        String ncrRecordTypeID = Schema.SObjectType.Contact_Card__c.getRecordTypeInfosByName().get('Non-Constituent Relationship').getRecordTypeId();

        List<Contact_Card__c> contactCards = Trigger.New;
        List<Contact_Card__c> contactCardsToSync = new List<Contact_Card__c>();
        Map<Id, List<Contact_Card__c>> mapParentAToContactCards = new Map<Id, List<Contact_Card__c>>();

        //Find which Contact Cards need to be synced and link them with parent A
        for (Contact_Card__c contactCard : contactCards) {
            if (contactCard.RecordTypeId == ncrRecordTypeID && contactCard.Contact_Type__c == 'Child') {
                contactCardsToSync.add(contactCard);

                List<Contact_Card__c> contactCardsOnParentA = new List<Contact_Card__c>();
                if (mapParentAToContactCards.containsKey(contactCard.Related_Constituent__c)) {
                    contactCardsOnParentA = mapParentAToContactCards.get(contactCard.Related_Constituent__c);
                }
                contactCardsOnParentA.add(contactCard);
                mapParentAToContactCards.put(contactCard.Related_Constituent__c, contactCardsOnParentA);

            }
        }

        //Find parent B
        Map<Id, Id> mapParentAIdToParentBId = new Map<Id, Id>();
        Set<Id> parentBIds = new Set<Id>();
        List<String> roleList = new List<String>{'Spouse','Partner/Significant Other'};
        for (ucinn_ascendv2__Relationship__c relToParentB : [SELECT Id, ucinn_ascendv2__Contact__c, ucinn_ascendv2__Related_Contact__c FROM ucinn_ascendv2__Relationship__c WHERE (ucinn_ascendv2__Contact__c IN: mapParentAToContactCards.keySet() AND ucinn_ascendv2__Related_Contact_Role__c IN: roleList)]) {
            mapParentAIdToParentBId.put(relToParentB.ucinn_ascendv2__Contact__c, relToParentB.ucinn_ascendv2__Related_Contact__c);
            parentBIds.add(relToParentB.ucinn_ascendv2__Related_Contact__c);
        }

        //Query for parent B's existing Contact Cards to prevent redundancy
        Map<Id, Contact> parentBWithContactCards = new Map<Id, Contact>([SELECT Id, (SELECT Id, First_Name__c, Last_Name__c FROM Related_Contacts__r WHERE Contact_Type__c = 'Child') FROM Contact WHERE (Id IN: parentBIds)]);


        List<Contact_Card__c> contactCardsToInsertOnParentB = new List<Contact_Card__c>();
        //Move over Contact Cards
        for (Id parentAId : mapParentAToContactCards.keySet()) {
            List<Contact_Card__c> parentAContactCards = mapParentAToContactCards.get(parentAId);
            if (mapParentAIdToParentBId.containsKey(parentAId)) {
                Id parentBId = mapParentAIdToParentBId.get(parentAId);

                //Look at existing contact cards on parent B to make map
                Map<String, Set<String>> mapLastNameToFirstNameSetCCsonParentB = new Map<String, Set<String>>();
                for (Contact_Card__c contactCardOnParentB : parentBWithContactCards.get(parentBId).Related_Contacts__r) {

                    Set<String> firstNameSetCC = new Set<String>();
                    if (mapLastNameToFirstNameSetCCsonParentB.containsKey(contactCardOnParentB.Last_Name__c)) {
                        firstNameSetCC = mapLastNameToFirstNameSetCCsonParentB.get(contactCardOnParentB.Last_Name__c);
                    }
                    firstNameSetCC.add(contactCardOnParentB.First_Name__c);
                    mapLastNameToFirstNameSetCCsonParentB.put(contactCardOnParentB.Last_Name__c, firstNameSetCC);
                }

                for (Contact_Card__c parentAContactCard : parentAContactCards) {
                    Boolean createNewContactCard = true;
                    if (mapLastNameToFirstNameSetCCsonParentB.containsKey(parentAContactCard.Last_Name__c)) {
                        Set<String> firstNameSetCC = mapLastNameToFirstNameSetCCsonParentB.get(parentAContactCard.Last_Name__c);
                        if (firstNameSetCC.contains(parentAContactCard.First_Name__c)) {
                            //This contact card already exists, don't make a new one
                            createNewContactCard = false;
                        }
                    }
    
                    if (createNewContactCard) {
                        Contact_Card__c contactCardToInsertOnParentB = parentAContactCard.clone(false, false, true, false);
                        contactCardToInsertOnParentB.Related_Constituent__c = mapParentAIdToParentBId.get(parentAId);
                        contactCardsToInsertOnParentB.add(contactCardToInsertOnParentB);
                    }
                }
            }
        }


        //Insert Contact Cards to their spouses
        ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger('Contact_Card__c', false);
        insert contactCardsToInsertOnParentB;
        ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger('Contact_Card__c', true);
    }
}