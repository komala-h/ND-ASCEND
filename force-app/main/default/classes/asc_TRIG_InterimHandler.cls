/*
* Author: UCInnovation
* Date: 5/4/2022
* Description: custom trigger on interim object
*/

global with sharing class asc_TRIG_InterimHandler extends TRIG_BaseHandler {


    protected override void beforeInsert(Trigger_ContextVariables trigContextVars, ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper) {
       
       
    }

    protected override void beforeUpdate(Trigger_ContextVariables trigContextVars, ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper) {
        
        
    }
    
    protected override void afterInsert(Trigger_ContextVariables trigContextVars, ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper) {
    }
    
    protected override void afterUpdate(Trigger_ContextVariables trigContextVars, ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper) {
        callInterimProcessorUpdateContactRTv2(trigContextVars);
        updateConstituentType(trigContextVars);
    }

    private void callInterimProcessorUpdateContactRTv2 (Trigger_ContextVariables trigContextVars) {
        List<ucinn_ascendv2__Interim__c> TriggerNew = (List<ucinn_ascendv2__Interim__c>) trigContextVars.TriggerNew;
        Map<Id,ucinn_ascendv2__Interim__c> TriggerOldMap = new Map<Id, ucinn_ascendv2__Interim__c>();
        for (ucinn_ascendv2__Interim__c eachOldInterim : (List<ucinn_ascendv2__Interim__c>) trigContextVars.oldMap.values()) {
            TriggerOldMap.put(eachOldInterim.Id, eachOldInterim);
        }
        
        ND_InterimProcessor.updateContactRTv2(TriggerNew, TriggerOldMap);
    }

    private void updateConstituentType(Trigger_ContextVariables trigContextVars) {
        List<ucinn_ascendv2__Interim__c> triggerNew = trigContextVars.triggerNew;
        Map<Id, sObject> oldMap = trigContextVars.oldMap;

        List<ucinn_ascendv2__Interim__c> interimsToProcess = new List<ucinn_ascendv2__Interim__c>();
        Set<Id> contactsToQuery = new Set<Id>();
        for (ucinn_ascendv2__Interim__c interim : triggerNew) {
            if (oldMap != null &&
                    interim.ucinn_ascendv2__Status__c == 'Completed' && 
                    interim.ucinn_ascendv2__Status__c != oldMap.get(interim.Id).get('ucinn_ascendv2__Status__c') &&
                    interim.ND_Constituent_Type__c != null) {
                contactsToQuery.add(interim.ucinn_ascendv2__Contact__c);
                interimsToProcess.add(interim);
            }
        }

        Map<Id, Contact> contactMap = new Map<Id, Contact>([
            SELECT Id, ucinn_ascendv2__Contact_Type__c
            FROM Contact
            WHERE Id IN :contactsToQuery
        ]);

        Map<Id, Contact> contactsToUpdate = new Map<Id, Contact>();
        for (ucinn_ascendv2__Interim__c interim : interimsToProcess) {
            if (!contactMap.containsKey(interim.ucinn_ascendv2__Contact__c)) {
                continue;
            }

            Contact cont = contactMap.get(interim.ucinn_ascendv2__Contact__c);
            String newContactType = interimToContactCompare(interim, cont);
            if (cont.ucinn_ascendv2__Contact_Type__c != newContactType) {
                cont.ucinn_ascendv2__Contact_Type__c = newContactType;
                contactsToUpdate.put(cont.Id, cont);
            }
        }

        if (!contactsToUpdate.isEmpty()) {
            //ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger('Contact', false);
            update contactsToUpdate.values();
            //ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger('Contact', true);
        }
    }

    private String interimToContactCompare(ucinn_ascendv2__Interim__c interim, Contact cont) {
        String contTypeStr = '';
        List<String> contactTypes = cont.ucinn_ascendv2__Contact_Type__c?.split(';');

        if (contactTypes == null || contactTypes.isEmpty()) {
            contTypeStr = interim.ND_Constituent_Type__c;
        }
        else {
            if (interim.ND_Constituent_Type__c == 'SA') {
                if (contactTypes.contains('FR')) {
                    contactTypes.set(contactTypes.indexOf('FR'), 'SA');
                }
                if (contactTypes.contains('RE')) {
                    contactTypes.set(contactTypes.indexOf('RE'), 'SA');
                }
                if (contactTypes.contains('RC')) {
                    contactTypes.set(contactTypes.indexOf('RC'), 'SA');
                }
                if (contactTypes.contains('SW')) {
                    contactTypes.set(contactTypes.indexOf('SW'), 'SA');
                }
                if (!contactTypes.contains('SA')) {
                    contactTypes.add('SA');
                }
            }
            else if (interim.ND_Constituent_Type__c == 'ST') {
                if (contactTypes.contains('FR')) {
                    contactTypes.set(contactTypes.indexOf('FR'), 'ST');
                }
                if (contactTypes.contains('RE')) {
                    contactTypes.set(contactTypes.indexOf('RE'), 'ST');
                }
                if (contactTypes.contains('RC')) {
                    contactTypes.set(contactTypes.indexOf('RC'), 'ST');
                }
                if (contactTypes.contains('SA')) {
                    contactTypes.set(contactTypes.indexOf('SA'), 'ST');
                }
                if (contactTypes.contains('SW')) {
                    contactTypes.set(contactTypes.indexOf('SW'), 'ST');
                }
                if (!contactTypes.contains('ST')) {
                    contactTypes.add('ST');
                }
            }
            else if (interim.ND_Constituent_Type__c == 'SW') {
                if (contactTypes.contains('SA')) {
                    contactTypes.set(contactTypes.indexOf('SA'), 'SW');
                }
                if (contactTypes.contains('ST')) {
                    contactTypes.set(contactTypes.indexOf('ST'), 'SW');
                }
                if (!contactTypes.contains('SW')) {
                    contactTypes.add('SW');
                }
            }
            else if (interim.ND_Constituent_Type__c == 'AL') {
                if (contactTypes.contains('ST')) {
                    if (!contactTypes.contains('AL')) {
                        contactTypes.set(contactTypes.indexOf('ST'), 'AL');
                    }
                    else {
                        contactTypes.remove(contactTypes.indexOf('ST'));
                    }
                }
            }
            Set<String> contTypesSet = new Set<String>(contactTypes);   // convert to set to eliminate duplicate values
            List<String> contTypeList = new List<String>(contTypesSet);  // convert to list to use in String.join()
            contTypeStr = String.join(contTypeList, ';');
        }
        //System.debug('contTypeStr=' + contTypeStr);
        return contTypeStr;
    }

}