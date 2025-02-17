/**
 * @author UC Innovation
 * @date 3/9/2022
 * @group Trigger Handlers
 * @description Handler class for Phone Trigger
 */
global class asc_TRIG_PhoneHandler extends ucinn_ascendv2.ascend_TDTM_Runnable {
    private ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper = new ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper();
    
    /*******************************************************************************************************
     * @description Overridden method that handles the trigger actions and calls the relevant logic
     * @return The dmlWrapper with any sObjects to be inserted/updated/deleted
     */
    global override ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, ucinn_ascendv2.ascend_TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        List<ucinn_ascendv2__Phone__c> triggerNew = (List<ucinn_ascendv2__Phone__c>) newList;
        List<ucinn_ascendv2__Phone__c> triggerOld = (List<ucinn_ascendv2__Phone__c>) oldList;

        Map<Id, ucinn_ascendv2__Phone__c> triggerOldMap = new Map<Id, ucinn_ascendv2__Phone__c>();
        if (triggerOld != null) {
            for (ucinn_ascendv2__Phone__c phone : triggerOld) {
                triggerOldMap.put(phone.Id, phone);
            }
        }

        Map<Id, ucinn_ascendv2__Phone__c> TriggerNewMap = new Map<Id, ucinn_ascendv2__Phone__c>();
        if (triggerNew != null) {
            for (ucinn_ascendv2__Phone__c phone : triggerNew) {
                triggerNewMap.put(phone.Id, phone);
            }
        }

        if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeInsert) {
            SetStartAndEndDateFromStatus(triggerNew, triggerOldMap);
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterInsert) {
            updateAffiliationFromPhone(triggerNew, triggerOldMap);
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeUpdate) {
            SetStartAndEndDateFromStatus(triggerNew, triggerOldMap);
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterUpdate) {
            updateAffiliationFromPhone(triggerNew, triggerOldMap);
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeDelete) {
            
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterDelete) {
            
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterUndelete) {
            
        }
        
        return dmlWrapper;
    }

    /*******************************************************************************************************
     * @description Method run to update corresponding Affiliation when respective field is populated
     * @param triggerNew The list of newly updated Phones
     * @param triggerOldMap The map of the old versions of the newly updated Phones
     * @return N/A
     */
    private void updateAffiliationFromPhone(List<ucinn_ascendv2__Phone__c> triggerNew, Map<Id, ucinn_ascendv2__Phone__c> triggerOldMap) {

        Map<Id, Id> mapAffilIdToPhoneId = new Map<Id, Id>();

        for (ucinn_ascendv2__Phone__c phone : triggerNew) {

            if (phone.Affiliation__c != null) {

                if ((Trigger.isInsert) || (Trigger.isUpdate && (triggerOldMap.get(phone.Id).Affiliation__c != phone.Affiliation__c))) {

                    mapAffilIdToPhoneId.put(phone.Affiliation__c, phone.Id);    
                }
            }
        }

        if (!mapAffilIdToPhoneId.isEmpty()) {
            List<ucinn_ascendv2__Affiliation__c> affilsToUpdate = [SELECT Id 
                                                                   FROM ucinn_ascendv2__Affiliation__c 
                                                                   WHERE (Id IN: mapAffilIdToPhoneId.keySet())];

            for (ucinn_ascendv2__Affiliation__c affilToUpdate : affilsToUpdate) {
                affilToUpdate.Business_Phone__c = mapAffilIdToPhoneId.get(affilToUpdate.Id);
            }   
            update affilsToUpdate;
        }       
    }
    
     private void SetStartAndEndDateFromStatus(List<ucinn_ascendv2__Phone__c> triggerNew, Map<Id, ucinn_ascendv2__phone__c> triggerOldMap) {
        System.debug('SetStartAndEndDateFromStatus'+triggerNew);
        for (ucinn_ascendv2__Phone__c onePhone : triggerNew) {

            if (onephone.ucinn_ascendv2__Status__c == 'Former' && triggerOldMap.size()>0 && triggerOldMap.get(onePhone.Id).ucinn_ascendv2__Status__c !='Former' ) {
                system.debug('Former');
                if(onephone.ucinn_ascendv2__End_Date__c == null){                
                    onephone.ucinn_ascendv2__End_Date__c = date.today();
                }
                onephone.ucinn_ascendv2__Is_Preferred__c = false;
                system.debug('Former: Is Preferred: ' +  onephone.ucinn_ascendv2__Is_Preferred__c);
                system.debug('Former: End Date: ' +  onephone.ucinn_ascendv2__End_Date__c);
            }

            else if (onephone.ucinn_ascendv2__Status__c == 'Current' && ((triggerOldMap.size()>0 && triggerOldMap.get(onePhone.Id).ucinn_ascendv2__Status__c !='Current') || triggerOldMap.size()==0) ) {
                if(onephone.ucinn_ascendv2__Start_Date__c == null){
                    onephone.ucinn_ascendv2__Start_Date__c = date.today();
                }
                if(onephone.ucinn_ascendv2__End_Date__c != null){
                    onephone.ucinn_ascendv2__End_Date__c = null;
                }
                system.debug('Current');
                system.debug('Current: Start Date:' + onephone.ucinn_ascendv2__Start_Date__c);
                system.debug('TriggerOldMap: ' + triggerOldMap);
                system.debug('TriggerOldMap Size: ' + triggerOldMap.size());
                
            }
        }         
    }


}