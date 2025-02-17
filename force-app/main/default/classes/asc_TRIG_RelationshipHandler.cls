/**
 * @author UC Innovation
 * @date 9/1/2021
 * @group Trigger Handlers
 * @description Handler class for Relationship Trigger
 */
global class asc_TRIG_RelationshipHandler extends ucinn_ascendv2.ascend_TDTM_Runnable {
    private ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper = new ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper();
    public static Boolean canInvokeSyncReciprocalRalationshipFieldsUpdate = true;
    public static Boolean canInvokeSyncAddressRelations = true;
    

    /*******************************************************************************************************
     * @description Overridden method that handles the trigger actions and calls the relevant logic
     * @return The dmlWrapper with any sObjects to be inserted/updated/deleted
     */
    global override ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, ucinn_ascendv2.ascend_TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        List<ucinn_ascendv2__Relationship__c> triggerNew = (List<ucinn_ascendv2__Relationship__c>) newList;
        List<ucinn_ascendv2__Relationship__c> triggerOld = (List<ucinn_ascendv2__Relationship__c>) oldList;

        Map<Id, ucinn_ascendv2__Relationship__c> triggerOldMap = new Map<Id, ucinn_ascendv2__Relationship__c>();
        if (triggerOld != null) {
            for (ucinn_ascendv2__Relationship__c rel : triggerOld) {
                triggerOldMap.put(rel.Id, rel);
            }
        }

        if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeInsert) {
            setRelationshipStartDate(triggerNew);
            uncheckDoNotSyncAddressSettings(triggerNew, triggerOldMap);
            syncReciprocalRalationshipFieldsInsert(triggerNew);
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterInsert) {
            updateContactPartnerSignificantOther(triggerNew, triggerOldMap);
            createChildRelationship(triggerNew);
            syncAddressRelations(triggerNew, triggerOldMap);
            whenMarriedSyncNonConstRels(triggerNew, triggerOldMap);
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeUpdate) {
            setRelationshipStartDate(triggerNew);
            uncheckDoNotSyncAddressSettings(triggerNew, triggerOldMap);
            syncReciprocalRalationshipFieldsUpdate(triggerNew, triggerOldMap);
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterUpdate) {
            updateContactPartnerSignificantOther(triggerNew, triggerOldMap);
            syncAddressRelations(triggerNew, triggerOldMap);
            whenMarriedSyncNonConstRels(triggerNew, triggerOldMap);
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeDelete) {
            updateContactPartnerSignificantOther(triggerNew, triggerOldMap);
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterDelete) {
      
        } 

        return dmlWrapper;
    }
    
    /*******************************************************************************************************
     * @description Method run to uncheck Sync Home Address and/or Sync Seasonal Address
     * @param triggerNew The list of newly updated Relationships
     * @return N/A
     */
    private void uncheckDoNotSyncAddressSettings(List<ucinn_ascendv2__Relationship__c> triggerNew, Map<Id, ucinn_ascendv2__Relationship__c> triggerOldMap) {
        
        List<ucinn_ascendv2__Relationship__c> relationshipList = new List<ucinn_ascendv2__Relationship__c>();
        List<String> validChildConstituentTypeList = new List<String>{'SA','ST','RC'}; // Confirmed Admitted Student, Student, Related Child
        List<String> validRelationshipRoleList = new List<String>{'Spouse','Partner/Significant Other','Child','Parent'};
        List<String> validSpouseRelationshipRoleList = new List<String>{'Spouse','Partner/Significant Other'}; // 05/26/2023 - T-01406
        List<String> validParentChildRelationshipRoleList = new List<String>{'Child','Parent'}; // 05/26/2023 - T-01406
        Map<Id, String> conTypeMap = new Map<Id, String>();
        Set<Id> contactSet = new Set<Id>();
        Map<Id, List<ucinn_ascendv2__Relationship__c>> existingParentChildRelMap = new Map<Id, List<ucinn_ascendv2__Relationship__c>>(); // 05/26/2023 - T-01406
        Set<ucinn_ascendv2__Relationship__c> parentChildRelListUpdate = new Set<ucinn_ascendv2__Relationship__c>(); // 05/26/2023 - T-01406

        if (Trigger.isInsert) {
            for (ucinn_ascendv2__Relationship__c rel : triggerNew) {
                relationshipList.add(rel);
                contactSet.add(rel.ucinn_ascendv2__Contact__c);
                contactSet.add(rel.ucinn_ascendv2__Related_Contact__c);
            }
        } else if (Trigger.isUpdate) {
            for (ucinn_ascendv2__Relationship__c rel : triggerNew) {
                if ( (validRelationshipRoleList.contains(rel.ucinn_ascendv2__Related_Contact_Role__c) || validRelationshipRoleList.contains(triggerOldMap.get(rel.Id).ucinn_ascendv2__Related_Contact_Role__c) ) || 
                        (rel.ucinn_ascendv2__Related_Contact_Role__c != triggerOldMap.get(rel.Id).ucinn_ascendv2__Related_Contact_Role__c || 
                            rel.nd_Do_Not_Sync_Home_Address__c != triggerOldMap.get(rel.Id).nd_Do_Not_Sync_Home_Address__c || 
                            rel.nd_Do_Not_Sync_Seasonal_Address__c != triggerOldMap.get(rel.Id).nd_Do_Not_Sync_Seasonal_Address__c) ) {
                        
                    relationshipList.add(rel);
                    contactSet.add(rel.ucinn_ascendv2__Contact__c);
                    contactSet.add(rel.ucinn_ascendv2__Related_Contact__c);
                }
            }
        }

        if (!contactSet.isEmpty()) {
            // 05/26/2023 - T-01406: set Do Not Sync to true for existing related child relationship records when parents become divorced
            for (ucinn_ascendv2__Relationship__c rel : [SELECT Id, Name, ucinn_ascendv2__Contact__c, ucinn_ascendv2__Related_Contact_Role__c FROM ucinn_ascendv2__Relationship__c WHERE ucinn_ascendv2__Contact__c IN :contactSet AND ucinn_ascendv2__Related_Contact_Role__c IN :validParentChildRelationshipRoleList]) {
                if (existingParentChildRelMap.containsKey(rel.ucinn_ascendv2__Contact__c)) {
                    existingParentChildRelMap.get(rel.ucinn_ascendv2__Contact__c).add(rel);
                } else {
                    existingParentChildRelMap.put(rel.ucinn_ascendv2__Contact__c, new List<ucinn_ascendv2__Relationship__c>{rel});
                }
            }
        }
        
        if (!relationshipList.isEmpty()) {
            for (Contact con : [Select Id, ucinn_ascendv2__Contact_Type__c From Contact Where Id In :contactSet]) {
                conTypeMap.put(con.Id, con.ucinn_ascendv2__Contact_Type__c+'');
            }
            
            for (ucinn_ascendv2__Relationship__c rel : relationshipList) {
                Id childContactId = null;
                Boolean donotsync = false;
                
                if (rel.ucinn_ascendv2__Related_Contact_Role__c == 'Parent') {
                    childContactId = rel.ucinn_ascendv2__Contact__c;
                } else if (rel.ucinn_ascendv2__Related_Contact_Role__c == 'Child') {
                    childContactId = rel.ucinn_ascendv2__Related_Contact__c;
                }
                
                if (!validRelationshipRoleList.contains(rel.ucinn_ascendv2__Related_Contact_Role__c)) {
                    donotsync = true;
                }
                
                if (childContactId != null) {
                    if (conTypeMap.containsKey(childContactId)) {
                        List<String> typeList = conTypeMap.get(childContactId).split(';');
                        Boolean childHasValidTypes = false;
                        
                        // if child constituent type is NOT ('SA','ST','RC') then we set do not sync to true
                        // if child constituent type is ('SA','ST','RC') then we set do not sync to false and does nothing
                        for (String t : typeList) {
                            if (validChildConstituentTypeList.contains(t)) {
                                childHasValidTypes = true;
                            }
                        }
                        
                        if (!childHasValidTypes) {
                            donotsync = true;
                        }
                    }
                }
                
                if (donotsync) {
                    rel.nd_Do_Not_Sync_Home_Address__c = true;
                    rel.nd_Do_Not_Sync_Seasonal_Address__c = true;
                    rel.ucinn_ascendv2__Apply_Soft_Credit__c = false; // Added on 03/24/2023 - Case 00002183 / W-000620

                    // 05/26/2023 - T-01406: set Do Not Sync to true for existing related child relationship records when parents become divorced
                    if (!validRelationshipRoleList.contains(rel.ucinn_ascendv2__Related_Contact_Role__c)) {
                        if (existingParentChildRelMap.containsKey(rel.ucinn_ascendv2__Contact__c)) {
                            for (ucinn_ascendv2__Relationship__c parentChildRel : existingParentChildRelMap.get(rel.ucinn_ascendv2__Contact__c)) {
                                parentChildRel.nd_Do_Not_Sync_Home_Address__c = true;
                                parentChildRel.nd_Do_Not_Sync_Seasonal_Address__c = true;
                                parentChildRel.ucinn_ascendv2__Apply_Soft_Credit__c = false;

                                parentChildRelListUpdate.add(parentChildRel);
                            }
                        }

                        if (existingParentChildRelMap.containsKey(rel.ucinn_ascendv2__Related_Contact__c)) {
                            for (ucinn_ascendv2__Relationship__c parentChildRel : existingParentChildRelMap.get(rel.ucinn_ascendv2__Related_Contact__c)) {
                                parentChildRel.nd_Do_Not_Sync_Home_Address__c = true;
                                parentChildRel.nd_Do_Not_Sync_Seasonal_Address__c = true;
                                parentChildRel.ucinn_ascendv2__Apply_Soft_Credit__c = false;

                                parentChildRelListUpdate.add(parentChildRel);
                            }
                        }
                    }
                }
            }
        }

        // 05/26/2023 - T-01406: set Do Not Sync to true for existing related child relationship records when parents become divorced
        if (!parentChildRelListUpdate.isEmpty()) {
          //  update new List<ucinn_ascendv2__Relationship__c>(parentChildRelListUpdate);
        }
    }
    
    // 3.27.2023 Do_Not_Apply_Soft_Credit__c has been removed from the relationship
    // /*******************************************************************************************************
    //  * @description Method to check or uncheck Apply Soft Credit
    //  * @param triggerNew The list of newly updated Relationships
    //  * @return N/A
    //  */
    // private void setupApplySoftCreditSettings(List<ucinn_ascendv2__Relationship__c> triggerNew) {
    //     for (ucinn_ascendv2__Relationship__c rel : triggerNew) {
    //         rel.ucinn_ascendv2__Apply_Soft_Credit__c = !rel.Do_Not_Apply_Soft_Credit__c;
    //     }
    // }

    /*******************************************************************************************************
     * @description When Relationship is inserted, synchronize fields determined by Fields_To_Sync fieldset on reciprocal relationship. 
     * @param triggerNew The list of newly updated Relationships
     * @return N/A.
     */
    private void syncReciprocalRalationshipFieldsInsert(List<ucinn_ascendv2__Relationship__c> triggerNew) {
        List<Schema.FieldSetMember> fieldsToSync = SObjectType.ucinn_ascendv2__Relationship__c.FieldSets.getMap().get('Fields_To_Sync').getFields();

        Set<Id> reciprocalRelationShipIdSet = new Set<Id>();
        for(ucinn_ascendv2__Relationship__c eachRelationship : triggerNew) {
            if(eachRelationship.ucinn_ascendv2__Reciprocal_Relationship__c != null) {
                reciprocalRelationShipIdSet.add(eachRelationship.ucinn_ascendv2__Reciprocal_Relationship__c);
            }
        }
        //System.debug('reciprocalRelationShipIdSet[' + reciprocalRelationShipIdSet.size() + ']=' + reciprocalRelationShipIdSet);
        if(reciprocalRelationShipIdSet.size() < 1) return;

        String query = 'SELECT ';
        for(Schema.FieldSetMember eachField : fieldsToSync){
            query += eachField.getFieldPath() + ', ';
        }
        query += ' Id FROM ucinn_ascendv2__Relationship__c WHERE Id IN :reciprocalRelationShipIdSet';
        //System.debug('query = ' + query);

        Map<Id, ucinn_ascendv2__Relationship__c> reciprocalRelationshipMap = new Map<Id, ucinn_ascendv2__Relationship__c> ((List<ucinn_ascendv2__Relationship__c>)Database.query(query));
        //System.debug('reciprocalRelationshipMap[' + reciprocalRelationshipMap.size() + ']=' + reciprocalRelationshipMap);

        List<ucinn_ascendv2__Relationship__c> relationshipsToUpdate = new List<ucinn_ascendv2__Relationship__c>();
        for(ucinn_ascendv2__Relationship__c eachRelationship : triggerNew) {
            Boolean bChange = false;
            for(Schema.FieldSetMember eachField : fieldsToSync){
                if(eachRelationship.get(eachField.getFieldPath()) != reciprocalRelationshipMap.get(eachRelationship.ucinn_ascendv2__Reciprocal_Relationship__c).get(eachField.getFieldPath())){
                    eachRelationship.put(eachField.getFieldPath(), reciprocalRelationshipMap.get(eachRelationship.ucinn_ascendv2__Reciprocal_Relationship__c).get(eachField.getFieldPath()));
                }
            }
        }
    }

    /*******************************************************************************************************
     * @description When Relationship is updated, synchronize fields determined by Fields_To_Sync fieldset on reciprocal relationship. 
     * @param triggerNew The list of newly updated Relationships
     * @param triggerOldMap The map of the old versions of the newly updated Relationships
     * @return N/A.
     */
    private void syncReciprocalRalationshipFieldsUpdate(List<ucinn_ascendv2__Relationship__c> triggerNew, Map<Id, ucinn_ascendv2__Relationship__c> triggerOldMap) {
        if (!canInvokeSyncReciprocalRalationshipFieldsUpdate) {
            return;
        }
        
        List<Schema.FieldSetMember> fieldsToSync = SObjectType.ucinn_ascendv2__Relationship__c.FieldSets.getMap().get('Fields_To_Sync').getFields();
        
        Set<ucinn_ascendv2__Relationship__c> changedRelationshipSet = new Set<ucinn_ascendv2__Relationship__c>();
        Set<Id> reciprocalRelationShipIdSet = new Set<Id>();
        //system.debug('triggerNew' + triggerNew);
        for (ucinn_ascendv2__Relationship__c eachRelationship : triggerNew) {
            Boolean bChange = false;
            for (Schema.FieldSetMember eachField : fieldsToSync){
                if(eachRelationship.get(eachField.getFieldPath()) != triggerOldMap.get(eachRelationship.Id).get(eachField.getFieldPath())){
                    bChange=true;
                    break;
                }
            }
            
            if (bChange) {
                changedRelationshipSet.add(eachRelationship);
                if (eachRelationship.ucinn_ascendv2__Reciprocal_Relationship__c != null && !triggerOldMap.containsKey(eachRelationship.ucinn_ascendv2__Reciprocal_Relationship__c)) {
                    reciprocalRelationShipIdSet.add(eachRelationship.ucinn_ascendv2__Reciprocal_Relationship__c);
                }
            }
        }
        //System.debug('reciprocalRelationShipIdSet[' + reciprocalRelationShipIdSet.size() + ']=' + reciprocalRelationShipIdSet);
        if (reciprocalRelationShipIdSet.size() < 1) {
            return;
        }

        // Query for reciprocal relationships
        String query = 'SELECT ';
        for(Schema.FieldSetMember eachField : fieldsToSync){
            query += eachField.getFieldPath() + ', ';
        }
        query += ' Id FROM ucinn_ascendv2__Relationship__c WHERE Id IN :reciprocalRelationShipIdSet';

        Map<Id, ucinn_ascendv2__Relationship__c> reciprocalRelationshipMap = new Map<Id, ucinn_ascendv2__Relationship__c> ((List<ucinn_ascendv2__Relationship__c>)Database.query(query));
        //System.debug('reciprocalRelationshipMap[' + reciprocalRelationshipMap.size() + ']=' + reciprocalRelationshipMap);

        List<ucinn_ascendv2__Relationship__c> relationshipsToUpdate = new List<ucinn_ascendv2__Relationship__c>();
        for (ucinn_ascendv2__Relationship__c eachRelationship : changedRelationshipSet) {
            Boolean bChange = false;
            for (Schema.FieldSetMember eachField : fieldsToSync) {                
                if (reciprocalRelationshipMap.get(eachRelationship.ucinn_ascendv2__Reciprocal_Relationship__c)!=null && reciprocalRelationshipMap.get(eachRelationship.ucinn_ascendv2__Reciprocal_Relationship__c).get(eachField.getFieldPath()) != eachRelationship.get(eachField.getFieldPath())) {
                    reciprocalRelationshipMap.get(eachRelationship.ucinn_ascendv2__Reciprocal_Relationship__c).put(eachField.getFieldPath(), eachRelationship.get(eachField.getFieldPath()));
                    bChange = true;                    
                }
            }
            if (bChange) {
                relationshipsToUpdate.add(reciprocalRelationshipMap.get(eachRelationship.ucinn_ascendv2__Reciprocal_Relationship__c));
            }
        }
        //system.debug('relationshipsToUpdate' + relationshipsToUpdate);        
        if (relationshipsToUpdate.size() > 0) {
            ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger('ucinn_ascendv2__Relationship__c', false);
            update relationshipsToUpdate;
            ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger('ucinn_ascendv2__Relationship__c', true);
        }
    }
    
    /*******************************************************************************************************
     * @description Method run to sync the address relations
     * @param triggerNew The list of newly updated Relationships
     * @param triggerOldMap The map of the old versions of the newly updated Relationships
     * @return N/A
     */
    private void syncAddressRelations(List<ucinn_ascendv2__Relationship__c> triggerNew, Map<Id, ucinn_ascendv2__Relationship__c> triggerOldMap) {
        if (!canInvokeSyncAddressRelations) {
            return;
        }
        asc_TRIG_RelationshipHandler.canInvokeSyncAddressRelations = false;
        // List<ucinn_ascendv2__Address_Relation__c> addrelList = new List<ucinn_ascendv2__Address_Relation__c>();
        // Map<Id, String> matchkeyMap = new Map<Id, String>();
        // Set<Id> contactSet = new Set<Id>();
        // Set<Id> relationshipProrityContactSet = new Set<Id>();
        // Set<String> keynameSet = new Set<String>();
        Map<Id, Id> conIdToRelatedConIdMap = new Map<Id, Id>();
        
        if (Trigger.isInsert) {
            for (ucinn_ascendv2__Relationship__c rel : triggerNew) {
                if (!rel.nd_Do_Not_Sync_Home_Address__c || !rel.nd_Do_Not_Sync_Seasonal_Address__c) {
                    // contactSet.add(rel.ucinn_ascendv2__Contact__c);
                    // contactSet.add(rel.ucinn_ascendv2__Related_Contact__c);
                    // relationshipProrityContactSet.add(rel.ucinn_ascendv2__Contact__c);
                    // W-001207: Sync Address Relations should be referenced from where the Relationship is created from
                    // W-001207: Needed to reverse ucinn_ascendv2__Contact__c and ucinn_ascendv2__Related_Contact__c mapping 
                        // due to Reciprocal Relationship gets created first before the actual Relationship being created by user during insert transaction.
                        // Unlike the update transaction, where the actual Relationship being created gets completed first before updating its Reciprocal Relationship.
                    // conIdToRelatedConIdMap.put(rel.ucinn_ascendv2__Contact__c, rel.ucinn_ascendv2__Related_Contact__c);
                    conIdToRelatedConIdMap.put(rel.ucinn_ascendv2__Related_Contact__c, rel.ucinn_ascendv2__Contact__c);
                }
            }
        } else if (Trigger.isUpdate) {
            for (ucinn_ascendv2__Relationship__c rel : triggerNew) {
                if ( (!rel.nd_Do_Not_Sync_Home_Address__c || !rel.nd_Do_Not_Sync_Seasonal_Address__c) && 
                        (rel.nd_Do_Not_Sync_Home_Address__c != triggerOldMap.get(rel.Id).nd_Do_Not_Sync_Home_Address__c || rel.nd_Do_Not_Sync_Seasonal_Address__c != triggerOldMap.get(rel.Id).nd_Do_Not_Sync_Seasonal_Address__c) ) {
                    // contactSet.add(rel.ucinn_ascendv2__Contact__c);
                    // contactSet.add(rel.ucinn_ascendv2__Related_Contact__c);
                    // relationshipProrityContactSet.add(rel.ucinn_ascendv2__Contact__c);
                    conIdToRelatedConIdMap.put(rel.ucinn_ascendv2__Contact__c, rel.ucinn_ascendv2__Related_Contact__c);
                }
            }
        }
        
        if (!conIdToRelatedConIdMap.isEmpty() && !System.isFuture() && !System.isBatch()) {
            syncAddressRelationsFuture(conIdToRelatedConIdMap); // T-01475: Primary Constituent should be the basis for syncing addresses
            /* for (ucinn_ascendv2__Address_Relation__c addrel : [Select Id, ucinn_ascendv2__Contact__c, ucinn_ascendv2__Contact__r.AccountId, ucinn_ascendv2__Status__c, ucinn_ascendv2__Type__c, 
                                                               ucinn_ascendv2__Address__c, ucinn_ascendv2__Data_Source__c, ucinn_ascendv2__End_Date__c, ucinn_ascendv2__In_Care_Of__c,
                                                               ucinn_ascendv2__Is_Preferred__c, ucinn_ascendv2__Seasonal_End_Day__c, ucinn_ascendv2__Seasonal_End_Month__c,
                                                               ucinn_ascendv2__Seasonal_End_Year__c, ucinn_ascendv2__Seasonal_Start_Day__c, ucinn_ascendv2__Seasonal_Start_Month__c,
                                                               ucinn_ascendv2__Seasonal_Start_Year__c, ucinn_ascendv2__Source__c, ucinn_ascendv2__Start_Date__c, ucinn_ascendv2__Account__c, 
                                                               RecordTypeId, Update_Spouse_Address__c, Update_Household_Member_Addresses__c
                                                               From ucinn_ascendv2__Address_Relation__c Where ucinn_ascendv2__Contact__c In :contactSet]) {
                
                String keyname = asc_UTIL_AddressRelationHelper.getAddressRelationKeyname(addrel.ucinn_ascendv2__Status__c, 
                                                                                          addrel.ucinn_ascendv2__Type__c, 
                                                                                          addrel.ucinn_ascendv2__Address__c);
            
                if (!keynameSet.contains(keyname)) {
                    keynameSet.add(keyname);
                    
                    addrelList.add(addrel);
                    matchkeyMap.put(addrel.Id, keyname);
                }                                                        
            }
            
            if (!addrelList.isEmpty()) {
                asc_TRIG_AddressRelationHandler.canInvokeSyncAddressRelations = false;
                asc_UTIL_AddressRelationHelper.syncAddressRelations(addrelList, matchkeyMap, relationshipProrityContactSet, false);
            } */
        }
    }

    /*******************************************************************************************************
     * @description Future method run to sync the address relations // T-01475: Primary Constituent should be the basis for syncing addresses
     * @param conIdToRelatedConIdMap The Map of constituent Id to related constituent Id
     * @return N/A
     */
    @future
    public static void syncAddressRelationsFuture(Map<Id, Id> conIdToRelatedConIdMap) {
        List<ucinn_ascendv2__Address_Relation__c> addrelList = new List<ucinn_ascendv2__Address_Relation__c>();
        Map<Id, String> matchkeyMap = new Map<Id, String>();
        Set<String> keynameSet = new Set<String>();
        Set<Id> relationshipPriorityContactSet = new Set<Id>();
        Set<Id> contactIdsSet = new Set<Id>();

        if (!conIdToRelatedConIdMap.isEmpty()) {
            for (Contact con : [SELECT Id, Name, Account.ucinn_ascendv2__Primary_Contact__c FROM Contact WHERE Id IN :conIdToRelatedConIdMap.keySet()]) {
                relationshipPriorityContactSet.add(con.Account.ucinn_ascendv2__Primary_Contact__c);
            }

            for (Id conId : conIdToRelatedConIdMap.keySet()) {
                contactIdsSet.add(conId);
                contactIdsSet.add(conIdToRelatedConIdMap.get(conId));
            }
            // clin 09/21/2023 W-001207 - Updated SOQL and ordered it by ucinn_ascendv2__Status__c to get the Active(Current) records first before the Inactive(Former)
            for (ucinn_ascendv2__Address_Relation__c addrel : [Select Id, ucinn_ascendv2__Contact__c, ucinn_ascendv2__Contact__r.AccountId, ucinn_ascendv2__Status__c, ucinn_ascendv2__Type__c, 
                                                               ucinn_ascendv2__Address__c, ucinn_ascendv2__Data_Source__c, ucinn_ascendv2__End_Date__c, ucinn_ascendv2__In_Care_Of__c,
                                                               ucinn_ascendv2__Is_Preferred__c, ucinn_ascendv2__Seasonal_End_Day__c, ucinn_ascendv2__Seasonal_End_Month__c,
                                                               ucinn_ascendv2__Seasonal_End_Year__c, ucinn_ascendv2__Seasonal_Start_Day__c, ucinn_ascendv2__Seasonal_Start_Month__c,
                                                               ucinn_ascendv2__Seasonal_Start_Year__c, ucinn_ascendv2__Source__c, ucinn_ascendv2__Start_Date__c, ucinn_ascendv2__Account__c, 
                                                               RecordTypeId, Update_Spouse_Address__c, Update_Household_Member_Addresses__c
                                                               From ucinn_ascendv2__Address_Relation__c Where ucinn_ascendv2__Contact__c In :contactIdsSet 
                                                               ORDER BY ucinn_ascendv2__Status__c, Id ASC]) {
                
                String keyname = asc_UTIL_AddressRelationHelper.getAddressRelationKeyname(addrel.ucinn_ascendv2__Status__c, 
                                                                                          addrel.ucinn_ascendv2__Type__c, 
                                                                                          addrel.ucinn_ascendv2__Address__c);
            
                if (!keynameSet.contains(keyname)) {
                    keynameSet.add(keyname);
                    
                    addrelList.add(addrel);
                    matchkeyMap.put(addrel.Id, keyname);
                }                                                        
            }
            
            if (!addrelList.isEmpty()) {
                asc_TRIG_AddressRelationHandler.canInvokeSyncAddressRelations = false;
                // As per discussion with Quy 09/05/2023 - Synced addresses should also sync the Preferred flag. Set 4th param to TRUE to sync the Preferred flag.
                asc_UTIL_AddressRelationHelper.syncAddressRelations(addrelList, matchkeyMap, relationshipPriorityContactSet, true);
            }
        }
    }
    
    /*******************************************************************************************************
     * @description Method to set relationship Start Date to TODAY if NULL
     * @param triggerNew The list of newly updated Relationships
     * @return N/A
     */
    private void setRelationshipStartDate(List<ucinn_ascendv2__Relationship__c> triggerNew) {
        for (ucinn_ascendv2__Relationship__c rel : triggerNew) {
            if (rel.Start_Date__c == null) {
                rel.Start_Date__c = Date.today();
            }
        }
    }
    
    /*******************************************************************************************************
     * @description Update constituent partner/significant other
     * @param triggerNew The list of newly updated Relationships
     * @return N/A
     */
    private void updateContactPartnerSignificantOther(List<ucinn_ascendv2__Relationship__c> triggerNew, Map<Id, ucinn_ascendv2__Relationship__c> triggerOldMap) {
        List<Contact> updateContactList = new List<Contact>();
        Map<Id, Id> contactPartnerMap = new Map<Id, Id>();
        Set<Id> contactWithPartnerRoleSet = new Set<Id>();
        
        if (Trigger.isInsert || Trigger.isUndelete) {
            for (ucinn_ascendv2__Relationship__c rel : triggerNew) {
                if (rel.ucinn_ascendv2__Related_Contact_Role__c == 'Partner/Significant Other') {
                    contactPartnerMap.put(rel.ucinn_ascendv2__Contact__c, rel.ucinn_ascendv2__Related_Contact__c);
                    contactWithPartnerRoleSet.add(rel.ucinn_ascendv2__Contact__c);
                }
            }
        } else if (Trigger.isUpdate) {
            for (ucinn_ascendv2__Relationship__c rel : triggerNew) {
                if ( (rel.ucinn_ascendv2__Related_Contact_Role__c == 'Partner/Significant Other' || triggerOldMap.get(rel.Id).ucinn_ascendv2__Related_Contact_Role__c == 'Partner/Significant Other')
                        && (rel.ucinn_ascendv2__Related_Contact_Role__c != triggerOldMap.get(rel.Id).ucinn_ascendv2__Related_Contact_Role__c ) ) {
                    contactPartnerMap.put(rel.ucinn_ascendv2__Contact__c, rel.ucinn_ascendv2__Related_Contact__c);
                
                    if (rel.ucinn_ascendv2__Related_Contact_Role__c == 'Partner/Significant Other') {
                        contactWithPartnerRoleSet.add(rel.ucinn_ascendv2__Contact__c);
                    }
                }
            }
        } else if (Trigger.isDelete) {
            for (ucinn_ascendv2__Relationship__c rel : triggerOldMap.values()) {
                if (rel.ucinn_ascendv2__Related_Contact_Role__c == 'Partner/Significant Other') {
                    contactPartnerMap.put(rel.ucinn_ascendv2__Contact__c, rel.ucinn_ascendv2__Related_Contact__c);
                }
            }
        }
        
        if (!contactPartnerMap.isEmpty()) {
            for (Id conId : contactPartnerMap.keySet()) {
                Contact con = new Contact(Id = conId);
                Contact con2 = new Contact(Id = contactPartnerMap.get(conId));
                
                if (contactWithPartnerRoleSet.contains(conId)) {
                    con.nd_Partner_Significant_Other__c = contactPartnerMap.get(conId);
                    con2.nd_Partner_Significant_Other__c = conId;
                } else {
                    con.nd_Partner_Significant_Other__c = null;
                    con2.nd_Partner_Significant_Other__c = null;
                }
                
                updateContactList.add(con);
                updateContactList.add(con2);
            }
            
            if (!updateContactList.isEmpty()) {
                update updateContactList;
            }
        }
    }
    
    /*******************************************************************************************************
     * @description Create child relationship
     * @param triggerNew The list of newly updated Relationships
     * @param triggerOldMap The map of the old versions of the newly updated Relationships
     * @return N/A
     */
    private void createChildRelationship(List<ucinn_ascendv2__Relationship__c> triggerNew) {
        List<String> roleList = new List<String>{'Spouse','Partner/Significant Other','Child'};
        List<ucinn_ascendv2__Relationship__c> insertRelationshipList = new List<ucinn_ascendv2__Relationship__c>();
        List<ucinn_ascendv2__Relationship__c> relationshipList = new List<ucinn_ascendv2__Relationship__c>();
        Map<Id, Map<Id, ucinn_ascendv2__Relationship__c>> contactChildrenMap = new Map<Id, Map<Id, ucinn_ascendv2__Relationship__c>>();
        Set<Id> allContactSet = new Set<Id>();
        
        for (ucinn_ascendv2__Relationship__c rel : triggerNew) {
            if (roleList.contains(rel.ucinn_ascendv2__Related_Contact_Role__c)) {
                allContactSet.add(rel.ucinn_ascendv2__Contact__c);
                allContactSet.add(rel.ucinn_ascendv2__Related_Contact__c);
            }
        }
        
        if (!allContactSet.isEmpty()) {
            
            // Collect spouse & partner contacts
            for (ucinn_ascendv2__Relationship__c rel : [Select Id, ucinn_ascendv2__Contact__c, ucinn_ascendv2__Related_Contact__c From ucinn_ascendv2__Relationship__c 
                    Where (ucinn_ascendv2__Contact__c In :allContactSet Or ucinn_ascendv2__Related_Contact__c In :allContactSet) 
                    And (ucinn_ascendv2__Related_Contact_Role__c = 'Spouse' Or ucinn_ascendv2__Related_Contact_Role__c = 'Partner/Significant Other')]) {
                relationshipList.add(rel);
                allContactSet.add(rel.ucinn_ascendv2__Contact__c);
                allContactSet.add(rel.ucinn_ascendv2__Related_Contact__c);
            }
            
            // Collect existing child relationships
            for (ucinn_ascendv2__Relationship__c rel : [Select Id, ucinn_ascendv2__Contact__c, ucinn_ascendv2__Related_Contact__c, ucinn_ascendv2__Related_Contact_Role__c, 
                    ucinn_ascendv2__Apply_Soft_Credit__c, nd_Do_Not_Sync_Home_Address__c, nd_Do_Not_Sync_Seasonal_Address__c, ucinn_ascendv2__Status__c, ucinn_ascendv2__Source__c 
                    From ucinn_ascendv2__Relationship__c Where (ucinn_ascendv2__Contact__c In :allContactSet Or ucinn_ascendv2__Related_Contact__c In :allContactSet) 
                    And ucinn_ascendv2__Related_Contact_Role__c = 'Child']) {
                
                if (!contactChildrenMap.containsKey(rel.ucinn_ascendv2__Contact__c)) {
                    contactChildrenMap.put(rel.ucinn_ascendv2__Contact__c, new Map<Id, ucinn_ascendv2__Relationship__c>());
                }
                contactChildrenMap.get(rel.ucinn_ascendv2__Contact__c).put(rel.ucinn_ascendv2__Related_Contact__c, rel);
            }
            
            if (relationshipList.isEmpty()) {
                return;
            }
            
            // Find missing child relationship when spouse or partner relationship is created
            for (ucinn_ascendv2__Relationship__c rel : relationshipList) {
                Set<Id> contactChildrenSet = new Set<Id>();
                Set<Id> relatedcontactChildrenSet = new Set<Id>();
                Set<Id> allChildren1Set = new Set<Id>();
                
                if (contactChildrenMap.containsKey(rel.ucinn_ascendv2__Contact__c)) {
                    contactChildrenSet = contactChildrenMap.get(rel.ucinn_ascendv2__Contact__c).keySet();
                }
                
                if (contactChildrenMap.containsKey(rel.ucinn_ascendv2__Related_Contact__c)) {
                    relatedcontactChildrenSet = contactChildrenMap.get(rel.ucinn_ascendv2__Related_Contact__c).keySet();
                }
                
                allChildren1Set.addAll(contactChildrenSet);
                allChildren1Set.addAll(relatedcontactChildrenSet);
                
                if (!contactChildrenSet.equals(relatedcontactChildrenSet)) {
                    insertRelationshipList.addAll(getChildRelationshipToAdd(rel.ucinn_ascendv2__Contact__c, rel.ucinn_ascendv2__Related_Contact__c, allChildren1Set, contactChildrenSet, contactChildrenMap));
                }
            }
            
            if (!insertRelationshipList.isEmpty()) {
                insert insertRelationshipList;
            }
        }
    }
    
    /*******************************************************************************************************
     * @description Get relationship records to add
     * @param contactToAddChildrenId The contact Id which the children will be added to
     * @param contactWithChildrenId The contact Id which has the missing children
     * @param allChildrenSet The set of all children Ids
     * @param contactChildrenToRemoveSet The set of contact children Ids to remove
     * @param contactChildrenMap The mapping children data
     * @return List of Relationships
     */
    private List<ucinn_ascendv2__Relationship__c> getChildRelationshipToAdd(Id contactToAddChildrenId, Id contactWithChildrenId, Set<Id> allChildrenSet, Set<Id> contactChildrenToRemoveSet, Map<Id, Map<Id, ucinn_ascendv2__Relationship__c>> contactChildrenMap) {
        List<ucinn_ascendv2__Relationship__c> ret = new List<ucinn_ascendv2__Relationship__c>();
        Set<Id> missingSet = allChildrenSet;
        
        missingSet.removeAll(contactChildrenToRemoveSet);
        
        for (Id childId : missingSet) {
            if (contactChildrenMap.containsKey(contactWithChildrenId)) {
                if (contactChildrenMap.get(contactWithChildrenId).containsKey(childId)) {
                    ucinn_ascendv2__Relationship__c rel = contactChildrenMap.get(contactWithChildrenId).get(childId);
                    
                    ucinn_ascendv2__Relationship__c newrel = new ucinn_ascendv2__Relationship__c();
                    newrel.ucinn_ascendv2__Contact__c = contactToAddChildrenId;
                    newrel.ucinn_ascendv2__Related_Contact__c = childId;
                    newrel.ucinn_ascendv2__Related_Contact_Role__c = 'Child';
                    newrel.ucinn_ascendv2__Apply_Soft_Credit__c = rel.ucinn_ascendv2__Apply_Soft_Credit__c;
                    newrel.nd_Do_Not_Sync_Home_Address__c = rel.nd_Do_Not_Sync_Home_Address__c;
                    newrel.nd_Do_Not_Sync_Seasonal_Address__c = rel.nd_Do_Not_Sync_Seasonal_Address__c;
                    newrel.ucinn_ascendv2__Status__c = rel.ucinn_ascendv2__Status__c;
                    newrel.ucinn_ascendv2__Source__c = rel.ucinn_ascendv2__Source__c;
                    ret.add(newrel);
                }
            }
        }
        
        return ret;
    }

    /*******************************************************************************************************
     * @description Create Non-Constituent Relationship Contact Cards on Partner/SO when relationship to Partner/SO is made
     * @param triggerNew The list of newly updated Relationships
     * @return N/A
     */
    private void whenMarriedSyncNonConstRels(List<ucinn_ascendv2__Relationship__c> triggerNew, Map<Id, ucinn_ascendv2__Relationship__c> triggerOldMap) {
        List<String> roleList = new List<String>{'Spouse','Partner/Significant Other'};
        Map<Id, Id> mapParentAIdToParentBId = new Map<Id, Id>();
        Set<Id> parentBIds = new Set<Id>();

        for (ucinn_ascendv2__Relationship__c rel : triggerNew) {
            if (roleList.contains(rel.ucinn_ascendv2__Related_Contact_Role__c)) {
                //This relationship signifies a Spouse/SO, copy the Child Contact Cards over to Parent B
                mapParentAIdToParentBId.put(rel.ucinn_ascendv2__Contact__c, rel.ucinn_ascendv2__Related_Contact__c);
                parentBIds.add(rel.ucinn_ascendv2__Related_Contact__c);
            }
        }

        List<Contact_Card__c> contactCardsToInsertOnParentB = new List<Contact_Card__c>();
        Map<Id, Contact> parentAWithContactCards = new Map<Id, Contact>([SELECT Id, (SELECT Id, First_Name__c, Last_Name__c, Data_Source__c, Contact_Type__c, Comments__c, Birthday__c, High_School_Graduation_Date__c, OwnerId, CreatedById, CreatedDate, RecordTypeId FROM Related_Contacts__r WHERE Contact_Type__c = 'Child') FROM Contact WHERE (Id IN: mapParentAIdToParentBId.keySet())]);
        Map<Id, Contact> parentBWithContactCards = new Map<Id, Contact>([SELECT Id, (SELECT Id, First_Name__c, Last_Name__c FROM Related_Contacts__r WHERE Contact_Type__c = 'Child') FROM Contact WHERE (Id IN: parentBIds)]);
        for (Id parentAId : parentAWithContactCards.keySet()) {
            //Look at parentB to prevent redundant contact card creation
            Contact parentB = parentBWithContactCards.get(mapParentAIdToParentBId.get(parentAId));
            List<Contact_Card__c> existingContactCardsOnParentB = parentB.Related_Contacts__r;
            Map<String, Set<String>> mapLastNameToFirstNameSetCCsonParentB = new Map<String, Set<String>>();
            for (Contact_Card__c existingContactCardOnParentB : existingContactCardsOnParentB) {

                Set<String> firstNameSetCC = new Set<String>();
                if (mapLastNameToFirstNameSetCCsonParentB.containsKey(existingContactCardOnParentB.Last_Name__c)) {
                    firstNameSetCC = mapLastNameToFirstNameSetCCsonParentB.get(existingContactCardOnParentB.Last_Name__c);
                }
                firstNameSetCC.add(existingContactCardOnParentB.First_Name__c);
                mapLastNameToFirstNameSetCCsonParentB.put(existingContactCardOnParentB.Last_Name__c, firstNameSetCC);

            }

            for (Contact_Card__c contactCardOnParentA : parentAWithContactCards.get(parentAId).Related_Contacts__r) {

                //Check if the contact card already exists
                Boolean createNewContactCard = true;
                if (mapLastNameToFirstNameSetCCsonParentB.containsKey(contactCardOnParentA.Last_Name__c)) {
                    Set<String> firstNameSetCC = mapLastNameToFirstNameSetCCsonParentB.get(contactCardOnParentA.Last_Name__c);
                    if (firstNameSetCC.contains(contactCardOnParentA.First_Name__c)) {
                        //This contact card already exists, don't make a new one
                        createNewContactCard = false;
                    }
                }

                if (createNewContactCard) {
                    Contact_Card__c contactCardToInsertOnParentB = contactCardOnParentA.clone(false, false, true, false);
                    contactCardToInsertOnParentB.Related_Constituent__c = mapParentAIdToParentBId.get(parentAId);
                    contactCardsToInsertOnParentB.add(contactCardToInsertOnParentB);
                }
            }
        }

        ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger('Contact_Card__c', false);
        insert contactCardsToInsertOnParentB;
        ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger('Contact_Card__c', true);
    }

}