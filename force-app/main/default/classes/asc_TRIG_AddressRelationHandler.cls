/**
 * @author Sulung Chandra, UC Innovation
 * @date 9/2/2020
 * @group Trigger Handlers
 * @description Handler class for Address Relation Trigger
 */
global class asc_TRIG_AddressRelationHandler extends ucinn_ascendv2.ascend_TDTM_Runnable {
    private ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper = new ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper();
    public static boolean canInvokeSyncUpdateSettings = true;
    public static boolean canInvokeSyncAddressRelations = true;
    public static boolean canInvokeDeleteSyncedAddressRelations = true;
    public static boolean canInvokeMultiCurrency = true;
    
    /*******************************************************************************************************
     * @description Overridden method that handles the trigger actions and calls the relevant logic
     * @return The dmlWrapper with any sObjects to be inserted/updated/deleted
     */
    global override ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, ucinn_ascendv2.ascend_TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        List<ucinn_ascendv2__Address_Relation__c> triggerNew = (List<ucinn_ascendv2__Address_Relation__c>) newList;
        List<ucinn_ascendv2__Address_Relation__c> triggerOld = (List<ucinn_ascendv2__Address_Relation__c>) oldList;

        Map<Id, ucinn_ascendv2__Address_Relation__c> triggerOldMap = new Map<Id, ucinn_ascendv2__Address_Relation__c>();
        if (triggerOld != null) {
            for (ucinn_ascendv2__Address_Relation__c addrel : triggerOld) {
                triggerOldMap.put(addrel.Id, addrel);
            }
        }

        Map<Id, ucinn_ascendv2__Address_Relation__c> triggerNewMap = new Map<Id, ucinn_ascendv2__Address_Relation__c>();
        if (triggerNew != null) {
            for (ucinn_ascendv2__Address_Relation__c addrel : triggerNew) {
                triggerNewMap.put(addrel.Id, addrel);
            }
        }


        if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeInsert) {
            //validatePreferredAddressType(triggerNew);
            collectPreviousContactPreferredAddressRelations(triggerNew , triggerOldMap);
            disableMultipleCurrentByType(triggerNew, objResult);
            validateAtLeastOnePreferredAddOnInsert(triggerNew);
            updateStartAndEndDateFromStatus(triggerNew, triggerOldMap);
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterInsert) {
            // populateTooltips(triggerNew);
            syncAddressRelations(triggerNew , triggerOldMap);
            updateAffiliationFromAddressRelation(triggerNew, triggerOldMap);
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeUpdate) {
            //validatePreferredAddressType(triggerNew);
            //syncUpdateSettings(triggerNew , triggerOldMap);
            collectPreviousContactPreferredAddressRelations(triggerNew , triggerOldMap);
            disableMultipleCurrentByType(triggerNew, objResult);
            updateStartAndEndDateFromStatus(triggerNew, triggerOldMap);
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterUpdate) {
            syncAddressRelations(triggerNew , triggerOldMap);
            validateAtLeastOnePreferredAddOnUpdate(triggerNew, triggerOldMap, triggerNewMap);
            updateAffiliationFromAddressRelation(triggerNew, triggerOldMap);
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeDelete) {
            
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterDelete) {
            deleteSyncedAddressRelations(triggerOldMap);
            validateAtLeastOnePreferredAddOnDelete(triggerOld, triggerOldMap, triggerNewMap);
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterUndelete) {
            //validatePreferredAddressType(triggerNew);
          syncAddressRelations(triggerNew , triggerOldMap);
        }
        
        return dmlWrapper;
    }
    
    /*******************************************************************************************************
     * @description Method to collect previous preferred address relations before insert or update
     * @param triggerNew The list of newly updated Address Relations
     * @param triggerOldMap The map of the old versions of the newly updated Address Relations
     * @return N/A
     */
    private void collectPreviousContactPreferredAddressRelations(List<ucinn_ascendv2__Address_Relation__c> triggerNew, Map<Id, ucinn_ascendv2__Address_Relation__c> triggerOldMap) {
        if(!canInvokeSyncAddressRelations){
            return;
        }  
        
        Set<Id> contactSet = new Set<Id>();
        
        if (Trigger.isInsert || Trigger.isUndelete) {
            for (ucinn_ascendv2__Address_Relation__c addrel : triggerNew) {
                if (addrel.ucinn_ascendv2__Contact__c != null) {
                    contactSet.add(addrel.ucinn_ascendv2__Contact__c);
                }
            }
        } else if (Trigger.isUpdate) {
            for (ucinn_ascendv2__Address_Relation__c addrel : triggerNew) {
                if (addrel.ucinn_ascendv2__Contact__c != null) {
                    contactSet.add(addrel.ucinn_ascendv2__Contact__c);
                }
                if (triggerOldMap.get(addrel.Id).ucinn_ascendv2__Contact__c != null) {
                    contactSet.add(triggerOldMap.get(addrel.Id).ucinn_ascendv2__Contact__c);
                }
            }
        }
        
        if (!contactSet.isEmpty()) {
            asc_UTIL_AddressRelationHelper.collectContactPreviousPreferredMap(contactSet);
        }
    }
    
    /*******************************************************************************************************
     * @description Method run to sync the address relations
     * @param triggerNew The list of newly updated Address Relations
     * @param triggerOldMap The map of the old versions of the newly updated Address Relations
     * @return N/A
     */
    private void syncAddressRelations(List<ucinn_ascendv2__Address_Relation__c> triggerNew, Map<Id, ucinn_ascendv2__Address_Relation__c> triggerOldMap) {
        if(!canInvokeSyncAddressRelations){
            return;
        }  
        
        List<ucinn_ascendv2__Address_Relation__c> addrelList = new List<ucinn_ascendv2__Address_Relation__c>();
        Map<Id, String> matchkeyMap = new Map<Id, String>();                                                       //Map<Address Relation Id, Keyname>
        
        if (Trigger.isInsert || Trigger.isUndelete) {
            for (ucinn_ascendv2__Address_Relation__c addrel : triggerNew) {
                String keyname = asc_UTIL_AddressRelationHelper.getAddressRelationKeyname(addrel.ucinn_ascendv2__Status__c, addrel.ucinn_ascendv2__Type__c, addrel.ucinn_ascendv2__Address__c);
                
                matchkeyMap.put(addrel.Id, keyname);
                addrelList.add(addrel);
            }
        } else if (Trigger.isUpdate) {
            for (ucinn_ascendv2__Address_Relation__c addrel : triggerNew) {
                if (addrel.ucinn_ascendv2__Data_Source__c != triggerOldMap.get(addrel.Id).ucinn_ascendv2__Data_Source__c ||
                        addrel.ucinn_ascendv2__End_Date__c != triggerOldMap.get(addrel.Id).ucinn_ascendv2__End_Date__c ||
                        addrel.ucinn_ascendv2__In_Care_Of__c != triggerOldMap.get(addrel.Id).ucinn_ascendv2__In_Care_Of__c ||
                        addrel.ucinn_ascendv2__Seasonal_End_Day__c != triggerOldMap.get(addrel.Id).ucinn_ascendv2__Seasonal_End_Day__c ||
                        addrel.ucinn_ascendv2__Seasonal_End_Month__c != triggerOldMap.get(addrel.Id).ucinn_ascendv2__Seasonal_End_Month__c ||
                        addrel.ucinn_ascendv2__Seasonal_End_Year__c != triggerOldMap.get(addrel.Id).ucinn_ascendv2__Seasonal_End_Year__c ||
                        addrel.ucinn_ascendv2__Seasonal_Start_Day__c != triggerOldMap.get(addrel.Id).ucinn_ascendv2__Seasonal_Start_Day__c ||
                        addrel.ucinn_ascendv2__Seasonal_Start_Month__c != triggerOldMap.get(addrel.Id).ucinn_ascendv2__Seasonal_Start_Month__c ||
                        addrel.ucinn_ascendv2__Seasonal_Start_Year__c != triggerOldMap.get(addrel.Id).ucinn_ascendv2__Seasonal_Start_Year__c ||
                        addrel.ucinn_ascendv2__Source__c != triggerOldMap.get(addrel.Id).ucinn_ascendv2__Source__c ||
                        addrel.ucinn_ascendv2__Start_Date__c != triggerOldMap.get(addrel.Id).ucinn_ascendv2__Start_Date__c ||
                        addrel.ucinn_ascendv2__Status__c != triggerOldMap.get(addrel.Id).ucinn_ascendv2__Status__c ||
                        addrel.ucinn_ascendv2__Type__c != triggerOldMap.get(addrel.Id).ucinn_ascendv2__Type__c ||
                        addrel.ucinn_ascendv2__Address__c != triggerOldMap.get(addrel.Id).ucinn_ascendv2__Address__c) {
                            
                    String keyname = asc_UTIL_AddressRelationHelper.getAddressRelationKeyname(triggerOldMap.get(addrel.Id).ucinn_ascendv2__Status__c, 
                                                                                              triggerOldMap.get(addrel.Id).ucinn_ascendv2__Type__c, 
                                                                                              triggerOldMap.get(addrel.Id).ucinn_ascendv2__Address__c);
                    
                    matchkeyMap.put(addrel.Id, keyname);
                    addrelList.add(addrel);
                }
            }
        }
        
        if (!addrelList.isEmpty()) {
            //canInvokeSyncAddressRelations = true;
            asc_UTIL_AddressRelationHelper.syncAddressRelations(addrelList, matchkeyMap, null, true);
        }
    }
    
    /*******************************************************************************************************
     * @description Method run to delete synced address relations
     * @param triggerOldMap The map of the old versions of the newly updated Address Relations
     * @return N/A
     */
    private void deleteSyncedAddressRelations(Map<Id, ucinn_ascendv2__Address_Relation__c> triggerOldMap) {
        if(!canInvokeDeleteSyncedAddressRelations){
            return;
        }  
        
        List<ucinn_ascendv2__Address_Relation__c> addrelList = new List<ucinn_ascendv2__Address_Relation__c>();
        Map<Id, String> matchkeyMap = new Map<Id, String>();                                                       //Map<Address Relation Id, Keyname>
        
        for (ucinn_ascendv2__Address_Relation__c addrel : triggerOldMap.values()) {
            String keyname = asc_UTIL_AddressRelationHelper.getAddressRelationKeyname(addrel.ucinn_ascendv2__Status__c, addrel.ucinn_ascendv2__Type__c, addrel.ucinn_ascendv2__Address__c);
            
            matchkeyMap.put(addrel.Id, keyname);
            addrelList.add(addrel);
        }
        
        if (!addrelList.isEmpty()) {
            canInvokeDeleteSyncedAddressRelations = false;
            asc_UTIL_AddressRelationHelper.deleteSyncedAddressRelations(addrelList, matchkeyMap);
        }
    }
    
    /*******************************************************************************************************
     * @description Method to validate if there is already an existing preferred address of different type
     * @param triggerNew The list of newly updated Address Relations
     * @param triggerOldMap The map of the old versions of the newly updated Address Relations
     * @return N/A
     */
    /*
    private void validatePreferredAddressType(List<ucinn_ascendv2__Address_Relation__c> triggerNew) {
        List<ucinn_ascendv2__Address_Relation__c> addrelList = new List<ucinn_ascendv2__Address_Relation__c>();
        List<String> errorList = new List<String>();
        Map<Id, String> contactPreferredAddressTypeMap = new Map<Id, String>();
        Set<Id> contactSet = new Set<Id>();
        
        for (ucinn_ascendv2__Address_Relation__c addrel : triggerNew) {
            if (addrel.Update_Spouse_Address__c && addrel.ucinn_ascendv2__Is_Preferred__c && addrel.ucinn_ascendv2__Contact__c != null) {
                addrelList.add(addrel);
                contactSet.add(addrel.ucinn_ascendv2__Contact__c);
                contactPreferredAddressTypeMap.put(addrel.ucinn_ascendv2__Contact__c, addrel.ucinn_ascendv2__Type__c);
            }
        }
        
        if (!addrelList.isEmpty()) {
            
            // Validate
            for (ucinn_ascendv2__Address_Relation__c addrel : [Select ucinn_ascendv2__Contact__r.ucinn_ascendv2__Preferred_Spouse__c, ucinn_ascendv2__Type__c, toLabel(ucinn_ascendv2__Type__c) typeLabel 
                    From ucinn_ascendv2__Address_Relation__c Where Update_Spouse_Address__c = True And ucinn_ascendv2__Is_Preferred__c = True 
                    And ucinn_ascendv2__Contact__r.ucinn_ascendv2__Preferred_Spouse__c In :contactSet And RecordType.DeveloperName Not In ('Organization_Address_Relation')]) {
                
                if (contactPreferredAddressTypeMap.containsKey(addrel.ucinn_ascendv2__Contact__r.ucinn_ascendv2__Preferred_Spouse__c)) {
                    if (contactPreferredAddressTypeMap.get(addrel.ucinn_ascendv2__Contact__r.ucinn_ascendv2__Preferred_Spouse__c) != addrel.ucinn_ascendv2__Type__c) {
                        errorList.add('The spouse has an existing ' + addrel.get('typeLabel') + ' address as the preferred address');
                    }
                }
            }
            
            // Add errors
            if (!errorList.isEmpty()) {
                triggerNew[0].addError(String.join(errorList, '; '));
            }
        }
    }*/

    /*******************************************************************************************************
     * @description Make sure there's always one current based on metadata type
     * @param trigContextVars Trigger Context Variables.
     * @return N/A.
     */
    private void disableMultipleCurrentByType(List<sObject> triggerNew, Schema.DescribeSObjectResult objResult) {
        //BIO_Utils.adjustCurrentObject(trigContextVars, 'ucinn_ascendv2__Address_Relations_Contact__r', 'ucinn_ascendv2__Address_Relations_Account__r');
        BIO_Utils.adjustCurrentObject(triggerNew, objResult, 'ucinn_ascendv2__Address_Relations_Contact__r','ucinn_ascendv2__Address_Relations_Account__r');
        
    }

        /*******************************************************************************************************
     * @description Make sure there's always at least one preferred address.
     * @param trigContextVars Trigger Context Variables.
     * @return N/A.
     */
    private void validateAtLeastOnePreferredAddOnInsert(List<sObject> triggerNew) {        
        BIO_Utils.enforceAtLeastOnePreferredOnInsert(triggerNew, 'ucinn_ascendv2__Address_Relations_Contact__r', 'ucinn_ascendv2__Address_Relations_Account__r');

    }

    /*******************************************************************************************************
     * @description Make sure there's always at least one preferred address. If user tries to update so none of the addresses are preferred, throw an error.
     * @param trigContextVars Trigger Context Variables.
     * @return N/A.
     */
    private void validateAtLeastOnePreferredAddOnUpdate(List<sObject> triggerNew, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        // clin Updated on 10/12/2022 - Updated to call new method with @future annotation to process the update on the sObject record/s asynchronously
        // BIO_Utils.enforceAtLeastOnePreferredOnUpdate(triggerNew, oldMap, newMap, 'ucinn_ascendv2__Address_Relations_Contact__r', 'ucinn_ascendv2__Address_Relations_Account__r', 'ucinn_ascendv2__Address_Relation__c');
        BIO_Utils.enforceAtLeastOnePreferredOnUpdateWithFuture(triggerNew, oldMap, newMap, 'ucinn_ascendv2__Address_Relations_Contact__r', 'ucinn_ascendv2__Address_Relations_Account__r', 'ucinn_ascendv2__Address_Relation__c');
    }

    private void validateAtLeastOnePreferredAddOnDelete(List<sObject> triggerOld, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        BIO_Utils.enforceAtLeastOnePreferredOnDelete(triggerOld, oldMap, newMap, 'ucinn_ascendv2__Address_Relations_Contact__r', 'ucinn_ascendv2__Address_Relations_Account__r', 'ucinn_ascendv2__Address_Relation__c');
    }

    /*******************************************************************************************************
     * @description Method run to add end and start dates dependent on status
     * @param triggerNew The list of newly updated Address Relations
     * @param triggerOldMap The map of the old versions of the newly updated Address Relations
     * @return N/A
     */
    private void updateStartAndEndDateFromStatus(List<ucinn_ascendv2__Address_Relation__c> triggerNew, Map<Id, ucinn_ascendv2__Address_Relation__c> triggerOldMap) {
        System.debug('updateStartAndEndDateFromStatus'+triggerNew);
        for (ucinn_ascendv2__Address_Relation__c addrel : triggerNew) {

            if (addrel.ucinn_ascendv2__Status__c == 'Former' && triggerOldMap.size()>0 && triggerOldMap.get(addrel.Id).ucinn_ascendv2__Status__c != 'Former'){
                if(addrel.ucinn_ascendv2__End_Date__c == null) {
                    addrel.ucinn_ascendv2__End_Date__c = date.today();
                }
                addrel.ucinn_ascendv2__Is_Preferred__c = false;
            }
            else if (addrel.ucinn_ascendv2__Status__c == 'Current' && ((triggerOldMap.size()>0 &&triggerOldMap.get(addrel.Id).ucinn_ascendv2__Status__c != 'Current') || triggerOldMap.size()==0) ) {
                if(addrel.ucinn_ascendv2__Start_Date__c == null){
                    addrel.ucinn_ascendv2__Start_Date__c = date.today();
                }
                if(addrel.ucinn_ascendv2__End_Date__c != null){
                    addrel.ucinn_ascendv2__End_Date__c = null;
                }    
                
            }

        }         
    }


    /*******************************************************************************************************
     * @description Method run to update corresponding Affiliation when respective field is populated
     * @param triggerNew The list of newly updated Address Relations
     * @param triggerOldMap The map of the old versions of the newly updated Address Relations
     * @return N/A
     */
    private void updateAffiliationFromAddressRelation(List<ucinn_ascendv2__Address_Relation__c> triggerNew, Map<Id, ucinn_ascendv2__Address_Relation__c> triggerOldMap) {

        Map<Id, Id> mapAffilIdToAddRelId = new Map<Id, Id>();

        for (ucinn_ascendv2__Address_Relation__c addrel : triggerNew) {

            if (addrel.Affiliation__c != null) {

                if ((Trigger.isInsert) || (Trigger.isUpdate && (triggerOldMap.get(addrel.Id).Affiliation__c != addrel.Affiliation__c))) {

                    mapAffilIdToAddRelId.put(addrel.Affiliation__c, addrel.Id);    
                }
            }
        }

        if (!mapAffilIdToAddRelId.isEmpty()) {
            List<ucinn_ascendv2__Affiliation__c> affilsToUpdate = [SELECT Id 
                                                                   FROM ucinn_ascendv2__Affiliation__c 
                                                                   WHERE (Id IN: mapAffilIdToAddRelId.keySet())];

            for (ucinn_ascendv2__Affiliation__c affilToUpdate : affilsToUpdate) {
                affilToUpdate.Business_Address__c = mapAffilIdToAddRelId.get(affilToUpdate.Id);
            }   
            update affilsToUpdate;
        }       
    }

}