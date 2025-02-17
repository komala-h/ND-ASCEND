/**
 * @author UC Innovation
 * @date 3/9/2022
 * @group Trigger Handlers
 * @description Handler class for Email Trigger
 */
global class asc_TRIG_EmailHandler extends ucinn_ascendv2.ascend_TDTM_Runnable {
    public static boolean isInsertOperation = false; // Cube84:vikas W-001097 -W-001097 - Remove auto-check for preferred email
    private ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper = new ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper();
    
    /*******************************************************************************************************
     * @description Overridden method that handles the trigger actions and calls the relevant logic
     * @return The dmlWrapper with any sObjects to be inserted/updated/deleted
     */
    global override ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, ucinn_ascendv2.ascend_TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        List<ucinn_ascendv2__Email__c> triggerNew = (List<ucinn_ascendv2__Email__c>) newList;
        List<ucinn_ascendv2__Email__c> triggerOld = (List<ucinn_ascendv2__Email__c>) oldList;

        Map<Id, ucinn_ascendv2__Email__c> triggerOldMap = new Map<Id, ucinn_ascendv2__Email__c>();
        if (triggerOld != null) {
            for (ucinn_ascendv2__Email__c email : triggerOld) {
                triggerOldMap.put(email.Id, email);
            }
        }

        Map<Id, ucinn_ascendv2__Email__c> TriggerNewMap = new Map<Id, ucinn_ascendv2__Email__c>();
        if (triggerNew != null) {
            for (ucinn_ascendv2__Email__c email : triggerNew) {
                triggerNewMap.put(email.Id, email);
            }
        }

        if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeInsert) {
            disableMultipleCurrentByType(triggerNew, objResult);
            validateAtLeastOnePreferredEmailOnInsert(triggerNew);
            SetStartAndEndDateFromStatus(triggerNew, triggerOldMap);
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterInsert) {
            updateAffiliationFromEmail(triggerNew, triggerOldMap);
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeUpdate) {
            disableMultipleCurrentByType(triggerNew, objResult);
            SetStartAndEndDateFromStatus(triggerNew, triggerOldMap);
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterUpdate) {
            updateAffiliationFromEmail(triggerNew, triggerOldMap);
            validateAtLeastOnePreferredEmailOnUpdate(triggerNew, triggerOldMap, triggerNewMap);
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeDelete) {
            
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterDelete) {
            
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterUndelete) {
            
        }
        
        return dmlWrapper;
    }

    /*******************************************************************************************************
     * @description Method run to update corresponding Affiliation when respective field is populated
     * @param triggerNew The list of newly updated Emails
     * @param triggerOldMap The map of the old versions of the newly updated Emails
     * @return N/A
     */
    private void updateAffiliationFromEmail(List<ucinn_ascendv2__Email__c> triggerNew, Map<Id, ucinn_ascendv2__Email__c> triggerOldMap) {

        Map<Id, Id> mapAffilIdToEmailId = new Map<Id, Id>();

        for (ucinn_ascendv2__Email__c email : triggerNew) {

            if (email.Affiliation__c != null) {

                if ((Trigger.isInsert) || (Trigger.isUpdate && (triggerOldMap.get(email.Id).Affiliation__c != email.Affiliation__c))) {

                    mapAffilIdToEmailId.put(email.Affiliation__c, email.Id);    
                }
            }
        }

        if (!mapAffilIdToEmailId.isEmpty()) {
            List<ucinn_ascendv2__Affiliation__c> affilsToUpdate = [SELECT Id 
                                                                   FROM ucinn_ascendv2__Affiliation__c 
                                                                   WHERE (Id IN: mapAffilIdToEmailId.keySet())];

            for (ucinn_ascendv2__Affiliation__c affilToUpdate : affilsToUpdate) {
                affilToUpdate.Business_Email__c = mapAffilIdToEmailId.get(affilToUpdate.Id);
            }   
            update affilsToUpdate;
        }       
    }

    /*******************************************************************************************************
     * @description Make sure there's always at least one preferred email.
     * @param trigContextVars Trigger Context Variables.
     * @return N/A.
     */
    private void validateAtLeastOnePreferredEmailOnInsert(List<ucinn_ascendv2__Email__c> triggerNew) {
        isInsertOperation= true;// Cube84:vikas W-001097 -W-001097 - Remove auto-check for preferred email
        BIO_Utils.enforceAtLeastOnePreferredOnInsert(triggerNew, 'ucinn_ascendv2__Emails_Contact__r', '');
    }

    /*******************************************************************************************************
     * @description Make sure there's always at least one preferred email.
     * @param trigContextVars Trigger Context Variables.
     * @return N/A.
     */
    private void validateAtLeastOnePreferredEmailOnUpdate(List<ucinn_ascendv2__Email__c> triggerNew, Map<Id, ucinn_ascendv2__Email__c> oldMap, Map<Id, ucinn_ascendv2__Email__c> newMap) {
        if(!isInsertOperation)// Cube84:vikas W-001097 -W-001097 - Remove auto-check for preferred email
        BIO_Utils.enforceAtLeastOnePreferredOnUpdate(triggerNew, oldMap, newMap, 'ucinn_ascendv2__Emails_Contact__r', '', 'ucinn_ascendv2__Email__c');
    }

    /*******************************************************************************************************
     * @description Make sure there's always one current based on metadata type
     * @param trigContextVars Trigger Context Variables.
     * @return N/A.
     */
    private void disableMultipleCurrentByType(List<ucinn_ascendv2__Email__c> triggerNew, Schema.DescribeSObjectResult contextObjResult) {
        BIO_Utils.adjustCurrentObject(triggerNew, contextObjResult, 'ucinn_ascendv2__Emails_Contact__r','');
        
    }
    
    private void SetStartAndEndDateFromStatus(List<ucinn_ascendv2__Email__c> triggerNew, Map<Id, ucinn_ascendv2__Email__c> triggerOldMap) {
        System.debug('SetStartAndEndDateFromStatus'+triggerNew);
        for (ucinn_ascendv2__Email__c oneEmail : triggerNew) {

            if (oneEmail.ucinn_ascendv2__Status__c == 'Former' && triggerOldMap.size()>0 && triggerOldMap.get(oneEmail.Id).ucinn_ascendv2__Status__c != 'Former') {
                oneEmail.ucinn_ascendv2__Is_Preferred__c = false;
                if(oneEmail.ucinn_ascendv2__End_Date__c == null){
                    oneEmail.ucinn_ascendv2__End_Date__c = date.today();
                }
                
            }
            else if (oneEmail.ucinn_ascendv2__Status__c == 'Current' && ((triggerOldMap.size()>0 && triggerOldMap.get(oneEmail.Id).ucinn_ascendv2__Status__c != 'Current') || triggerOldMap.size()==0 )) {
                if(oneEmail.ucinn_ascendv2__Start_Date__c == null){
                    oneEmail.ucinn_ascendv2__Start_Date__c = date.today();
                }
                if(oneEmail.ucinn_ascendv2__End_Date__c != null){
                    oneEmail.ucinn_ascendv2__End_Date__c = null;
                }
                
            }
        }         
    }

}