/**
 * @author UC Innovation
 * @date 
 * @group Trigger Handlers
 * @description Handler class for Contact Trigger
 * @Changes 9/2/2020 Sync address relation
 */
global class asc_TRIG_ContactHandler extends ucinn_ascendv2.ascend_TDTM_Runnable {
    private ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper = new ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper();
    public static Boolean canInvokeUpdateDeceasedRelatedRecords = true;
    public static Boolean canInvokeSyncMaritalStatusAndSalutationPreference = true;

    /*******************************************************************************************************
     * @description Overridden method that handles the trigger actions and calls the relevant logic
     * @return The dmlWrapper with any sObjects to be inserted/updated/deleted
     */
    global override ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, ucinn_ascendv2.ascend_TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        List<Contact> triggerNew = (List<Contact>) newList;
        List<Contact> triggerOld = (List<Contact>) oldList;

        Map<Id, Contact> triggerOldMap = new Map<Id, Contact>();
        if (triggerOld != null) {
            for (Contact eachCon : triggerOld) {
                triggerOldMap.put(eachCon.Id, eachCon);
            }
        }

        if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeInsert) {
            updateMaritalStatusAndSalutationPreference(triggerNew, triggerOldMap);
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterInsert) {
            //syncAddressRelations(triggerNew , triggerOldMap);
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeUpdate) {
            updateMaritalStatusAndSalutationPreference(triggerNew, triggerOldMap);
            updateDeceasedMaritalStatus(triggerNew , triggerOldMap); // clin deceased logic for constituent record
            syncMaritalStatusAndSalutationPreference(triggerNew , triggerOldMap);
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterUpdate) {
            updateConstituentFullNameRecords(triggerNew, triggerOldMap); 
            //syncAddressRelations(triggerNew , triggerOldMap);
            updateSalutations(triggerNew, triggerOldMap);
            updateDeceasedRelatedRecords(triggerNew, triggerOldMap); // clin deceased logic for constituent's related records
            updateChildRelationshipAddressSyncSettings(triggerNew, triggerOldMap);
            copyWealthAssetsOnHouseholdUnmerge(triggerNew, triggerOldMap);
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeDelete) {
        
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterDelete) {
      
        } 

        return dmlWrapper;
    }
    
    /*******************************************************************************************************
     * @description Method run to sync the address relations
     * @param triggerNew The list of newly updated Contacts
     * @param triggerOldMap The map of the old versions of the newly updated Contacts
     * @return N/A
     */
    /*
    private void syncAddressRelations(List<Contact> triggerNew, Map<Id, Contact> triggerOldMap) {
        List<ucinn_ascendv2__Address_Relation__c> addrelList = new List<ucinn_ascendv2__Address_Relation__c>();
        Map<Id, String> matchkeyMap = new Map<Id, String>();                                                       //Map<Address Relation Id, Keyname>
        Set<Id> accountSet = new Set<Id>();
        Set<Id> contactSet = new Set<Id>();
        Set<String> keynameSet = new Set<String>();
        
        if (Trigger.isInsert) {
            for (Contact con : triggerNew) {
                if (con.ucinn_ascendv2__Preferred_Spouse__c != null || con.AccountId != null) {
                    contactSet.add(con.Id);
                    
                    if (con.AccountId != null) {
                        accountSet.add(con.AccountId);
                    }
                }
            }
        } else if (Trigger.isUpdate) {
            for (Contact con : triggerNew) {
                if ((con.ucinn_ascendv2__Preferred_Spouse__c != null && con.ucinn_ascendv2__Preferred_Spouse__c != triggerOldMap.get(con.Id).ucinn_ascendv2__Preferred_Spouse__c) ||
                        (con.AccountId != null && con.AccountId != triggerOldMap.get(con.Id).AccountId)) {
                    contactSet.add(con.Id);
                    
                    if (con.AccountId != null) {
                        accountSet.add(con.AccountId);
                    }
                }
            }
        }
        
        System.debug('#### contactSet: '+contactSet);
        System.debug('#### accountSet: '+accountSet);
        
        if (!contactSet.isEmpty()) {
            for (ucinn_ascendv2__Address_Relation__c addrel : [Select Id, ucinn_ascendv2__Contact__c, ucinn_ascendv2__Contact__r.AccountId, ucinn_ascendv2__Status__c, ucinn_ascendv2__Type__c, 
                                                               ucinn_ascendv2__Address__c, ucinn_ascendv2__Data_Source__c, ucinn_ascendv2__End_Date__c, ucinn_ascendv2__In_Care_Of__c,
                                                               ucinn_ascendv2__Is_Preferred__c, ucinn_ascendv2__Seasonal_End_Day__c, ucinn_ascendv2__Seasonal_End_Month__c,
                                                               ucinn_ascendv2__Seasonal_End_Year__c, ucinn_ascendv2__Seasonal_Start_Day__c, ucinn_ascendv2__Seasonal_Start_Month__c,
                                                               ucinn_ascendv2__Seasonal_Start_Year__c, ucinn_ascendv2__Source__c, ucinn_ascendv2__Start_Date__c, ucinn_ascendv2__Account__c, 
                                                               RecordTypeId, Update_Spouse_Address__c, Update_Household_Member_Addresses__c
                                                               From ucinn_ascendv2__Address_Relation__c 
                                                               Where (ucinn_ascendv2__Contact__c In :contactSet
                                                                      Or ucinn_ascendv2__Contact__r.AccountId In :accountSet)]) {
                
                String keyname = asc_UTIL_AddressRelationHelper.getAddressRelationKeyname(addrel.ucinn_ascendv2__Status__c, 
                                                                                          addrel.ucinn_ascendv2__Type__c, 
                                                                                          addrel.ucinn_ascendv2__Address__c);
            
                if (!keynameSet.contains(keyname)) {
                    keynameSet.add(keyname);
                    
                    addrelList.add(addrel);
                    matchkeyMap.put(addrel.Id, keyname);
                }                                                        
            }
            
            System.debug('#### keynameSet: '+keynameSet);
            System.debug('#### addrelList: '+addrelList);
            System.debug('#### matchkeyMap: '+matchkeyMap);
            
            if (!addrelList.isEmpty()) {
                asc_TRIG_AddressRelationHandler.canInvokeSyncAddressRelations = false;
                //asc_UTIL_AddressRelationHelper.collectContactPreviousPreferredMap(contactSet);
                asc_UTIL_AddressRelationHelper.syncAddressRelations(addrelList, matchkeyMap, false);
            }
        }
    }*/

    /*******************************************************************************************************
     * @description Method to update Full Name record.
     * @param triggerNew The list of newly updated Contacts
     * @param triggerOldMap The map of the old versions of the newly updated Contacts
     * @return N/A
     */
    private void updateConstituentFullNameRecords(List<Contact> triggerNew, Map<Id, Contact> triggerOldMap) {
        List<ucinn_ascendv2__Contact_Name__c> updateNameList = new List<ucinn_ascendv2__Contact_Name__c>();
        Set<Id> contactSet = new Set<Id>();
        
        // Collect contacts to evaluate
        if (Trigger.isUpdate) {
            for (Contact con : triggerNew) {
                if (con.Nickname__c != triggerOldMap.get(con.Id).Nickname__c ) {
                    contactSet.add(con.id);
                }
            }
        }
        if (!contactSet.isEmpty() && !System.isBatch()) {
            updateConstituentFullNameRecordsOnFuture(contactSet);
        }
    }
    
    // clin 12/07/2023 - created this method to run at future to prevent recursion with updating the Nickname field back again from Constituent Name Trigger Handler
    @future
    private static void updateConstituentFullNameRecordsOnFuture(Set<Id> contactSet) {
        List<ucinn_ascendv2__Contact_Name__c> updateNameList = new List<ucinn_ascendv2__Contact_Name__c>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        
        if (!contactSet.isEmpty()) {
            contactMap = new Map<Id, Contact>([Select Id, Nickname__c From Contact Where Id In :contactSet]);
            
            for (ucinn_ascendv2__Contact_Name__c cn : [Select Id, ucinn_ascendv2__Contact__c, ucinn_ascendv2__Nickname__c From ucinn_ascendv2__Contact_Name__c 
                  Where ucinn_ascendv2__Contact__c In :contactSet And ucinn_ascendv2__Type__c = 'Full Name']) {
                String newNickname = contactMap.get(cn.ucinn_ascendv2__Contact__c).Nickname__c;
                
                if (newNickname != cn.ucinn_ascendv2__Nickname__c) {
                    cn.ucinn_ascendv2__Nickname__c = newNickname;
                    updateNameList.add(cn);
                }
            }
            
            if (!updateNameList.isEmpty()) {
                update updateNameList;
            }
        }
    }
    
    /*******************************************************************************************************
     * @description Method to update salutations
     * @param triggerNew The list of newly updated Contacts
     * @param triggerOldMap The map of the old versions of the newly updated Contacts
     * @return N/A
     */
    private void updateSalutations(List<Contact> triggerNew, Map<Id, Contact> triggerOldMap) {
        // List<Contact> contactList = new List<Contact>();
        Set<Id> contactSet = new Set<Id>();
        
        // Collect contacts to evaluate
        if (Trigger.isUpdate) {
            for (Contact con : triggerNew) {
                // T-01475: Primary Constituent should always be first in the joint salutations
                /* if (con.ucinn_ascendv2__Preferred_Spouse__c != triggerOldMap.get(con.Id).ucinn_ascendv2__Preferred_Spouse__c ||
                        con.nd_Partner_Significant_Other__c != triggerOldMap.get(con.Id).nd_Partner_Significant_Other__c ||
                        con.ucinn_ascendv2__Contact_Type__c != triggerOldMap.get(con.Id).ucinn_ascendv2__Contact_Type__c ||
                        con.ucinn_ascendv2__Donor_ID__c != triggerOldMap.get(con.Id).ucinn_ascendv2__Donor_ID__c ||
                        con.ucinn_ascendv2__Lifetime_Cash__c != triggerOldMap.get(con.Id).ucinn_ascendv2__Lifetime_Cash__c) {
                    contactSet.add(con.Id);
                    contactList.add(con);
                } */
                if (con.ucinn_ascendv2__Preferred_Spouse__c != triggerOldMap.get(con.Id).ucinn_ascendv2__Preferred_Spouse__c ||
                        con.nd_Partner_Significant_Other__c != triggerOldMap.get(con.Id).nd_Partner_Significant_Other__c) {
                    contactSet.add(con.Id);
                }
            }
        }
        
        if (!contactSet.isEmpty()) {
            
            Map<Id, Map<String, Object>> contactData = asc_UTIL_ContactHelper.getContactData(contactSet);
            asc_UTIL_ContactHelper.setupSalutations(contactData);
        }
    }
    
    /*******************************************************************************************************
     * @description Method to update deceased marital status
     * @param triggerNew The list of newly updated Contacts
     * @param triggerOldMap The map of the old versions of the newly updated Contacts
     * @return N/A
     */
    private void updateDeceasedMaritalStatus(List<Contact> triggerNew, Map<Id, Contact> triggerOldMap) {
        // Collect contacts to evaluate
        if (Trigger.isUpdate) {
            for (Contact con : triggerNew) {
                if (con.ucinn_ascendv2__Is_Deceased__c && con.ucinn_ascendv2__Is_Deceased__c != triggerOldMap.get(con.Id).ucinn_ascendv2__Is_Deceased__c) {
                    con.Constituent_Status__c = 'D'; // clin use case 1
                    
                    // clin 09/28/2022 - updated values for ucinn_ascendv2__Marital_Status__c field
                    if ((triggerOldMap.get(con.Id).ucinn_ascendv2__Marital_Status__c == 'M' || triggerOldMap.get(con.Id).ucinn_ascendv2__Marital_Status__c == 'Married') && 
                        triggerOldMap.get(con.Id).ucinn_ascendv2__Preferred_Spouse__c != null) {  // Check the old marital status because ascend logic is removing this
                            con.ucinn_ascendv2__Marital_Status__c = 'Z';
                            con.nd_Backend_Marital_Status__c='Z';
                        }
                     else if (triggerOldMap.get(con.Id).ucinn_ascendv2__Marital_Status__c == 'S') {
                           con.ucinn_ascendv2__Marital_Status__c = 'S';
                           con.nd_Backend_Marital_Status__c = 'S';
                   }
                    else if (triggerOldMap.get(con.Id).ucinn_ascendv2__Marital_Status__c == 'P') {
                           con.ucinn_ascendv2__Marital_Status__c = 'P';
                           con.nd_Backend_Marital_Status__c = 'P';
                   }
                   else if (triggerOldMap.get(con.Id).ucinn_ascendv2__Marital_Status__c == 'Widowed') {
                           con.ucinn_ascendv2__Marital_Status__c = 'Widowed';
                           con.nd_Backend_Marital_Status__c = 'Widowed';
                   }
                    else if (triggerOldMap.get(con.Id).ucinn_ascendv2__Marital_Status__c == 'Divorced') {
                           con.ucinn_ascendv2__Marital_Status__c = 'Divorced';
                           con.nd_Backend_Marital_Status__c = 'Divorced';
                   }
                    else if (triggerOldMap.get(con.Id).ucinn_ascendv2__Marital_Status__c == 'X') {
                           con.ucinn_ascendv2__Marital_Status__c = 'X';
                           con.nd_Backend_Marital_Status__c = 'X';
                   }
                    else if (triggerOldMap.get(con.Id).ucinn_ascendv2__Marital_Status__c == 'F') {
                           con.ucinn_ascendv2__Marital_Status__c = 'F';
                           con.nd_Backend_Marital_Status__c = 'F';
                   }
                     else if (triggerOldMap.get(con.Id).ucinn_ascendv2__Marital_Status__c == 'N') {
                           con.ucinn_ascendv2__Marital_Status__c = 'N';
                           con.nd_Backend_Marital_Status__c = 'N';
                   }
                }
                if (con.ucinn_ascendv2__Marital_Status__c == null || con.ucinn_ascendv2__Marital_Status__c =='') {
                    //system.debug('Setting Marital Status to backend value: ' + con.nd_Backend_Marital_Status__c);
                    con.ucinn_ascendv2__Marital_Status__c = con.nd_Backend_Marital_Status__c;
                }
            }
        }
    }
    
    /*******************************************************************************************************
     * @description Method to update related records of deceased constituents
     * @param triggerNew The list of newly updated Contacts
     * @param triggerOldMap The map of the old versions of the newly updated Contacts
     * @return N/A
     */
    private void updateDeceasedRelatedRecords(List<Contact> triggerNew, Map<Id, Contact> triggerOldMap) {
        if (!canInvokeUpdateDeceasedRelatedRecords) {
            return;
        }
        
        Map<Id, Contact> deceasedConIdToConMap = new Map<Id, Contact>(); // clin Added on 10/07/2022
        Map<Id, Id> contactSpouseMap = new Map<Id, Id>();
        
        // Collect contacts to evaluate
        if (Trigger.isUpdate) {
            for (Contact con : triggerNew) {
                if (con.ucinn_ascendv2__Is_Deceased__c && con.ucinn_ascendv2__Is_Deceased__c != triggerOldMap.get(con.Id).ucinn_ascendv2__Is_Deceased__c) {
                    contactSpouseMap.put(con.Id, triggerOldMap.get(con.Id).ucinn_ascendv2__Preferred_Spouse__c);  // Use the old spouse value because ascend logic is removing this
                    deceasedConIdToConMap.put(con.Id, con); // clin Added on 10/07/2022
                }
            }
        }

        if (!deceasedConIdToConMap.isEmpty()) {
            canInvokeUpdateDeceasedRelatedRecords = false;
            canInvokeSyncMaritalStatusAndSalutationPreference = false;
            
            // clin 01/11/2023 - bypass the syncing of Address Relation records between spouses 
            asc_TRIG_AddressRelationHandler.canInvokeSyncAddressRelations = false;
            updateDeceasedRelatedRecordStatus(deceasedConIdToConMap.keySet(), 'ucinn_ascendv2__Address_Relation__c'); // clin use case 2
            asc_TRIG_AddressRelationHandler.canInvokeSyncAddressRelations = true;
            
            // qluong 1/2/2024 - decision to move processing emails, phone, involvement, service indidcator to the Constituent - After Update 7 - Deceasing Update Related Records flow.
            // This is done separately so it take the workload from the trigger and prevent salesforce governor limit of too many soql queries error.
            //updateDeceasedRelatedRecordStatus(deceasedConIdToConMap.keySet(), 'ucinn_ascendv2__Email__c'); // clin use case 3
            //updateDeceasedRelatedRecordStatus(deceasedConIdToConMap.keySet(), 'ucinn_ascendv2__Phone__c'); // clin use case 4
            // clin 09/28/2022 - added new related objects to update
            //updateDeceasedRelatedRecordStatus(deceasedConIdToConMap.keySet(), 'ucinn_ascendv2__Involvement__c'); // clin use case 7

            Map<Id, ucinn_ascendv2__Relationship__c> deceasedConIdToSpouseRelationshipMap = getSpousalRelationship(deceasedConIdToConMap.keySet());
            
            updateSurvivingSpouses(deceasedConIdToConMap, deceasedConIdToSpouseRelationshipMap); // clin use case 13 / use case 14 / use case 15

            // clin 09/28/2022 - update Relationship record when constituent is deceased
            // clin 10/10/2023 - remvoved method because ascend OOB already sets spousal relationship to Widow
            // updateDeceasedSpousalRelationship(deceasedConIdToSpouseRelationshipMap.values()); // clin use case 14 / use case 15

            asc_TRIG_RelationshipHandler.canInvokeSyncReciprocalRalationshipFieldsUpdate = false;

            syncDeceasedChildRelationships(contactSpouseMap);

            updateRelatedAffiliations(deceasedConIdToConMap, deceasedConIdToSpouseRelationshipMap); // clin use case 6 and use case 18

            updateRelatedSocietyMemberships(deceasedConIdToConMap, deceasedConIdToSpouseRelationshipMap); // clin use case 8, use case 16, use case 17

            addSurvivingSpouseServiceIndicators(deceasedConIdToConMap, deceasedConIdToSpouseRelationshipMap); // clin use case 24
            
            updateDeceasedHouseholdPrimaryConstituents(contactSpouseMap); // clin use case 12
            
            // qluong 1/2/2024 - decision to move this from trigger to a flow that triggers off of the household account.
            // The flow is Organization - After Update - Deceasing Strategy Update.
            //updateHouseholdRelatedRecords(deceasedConIdToConMap.keySet(), deceasedConIdToSpouseRelationshipMap); // clin use case 19, use case 20, use case 21, use case 22, use case 23
             
            // createDeceasedCase(deceasedConIdToConMap, deceasedConIdToSpouseRelationshipMap); // clin use case 11.  Being handled by the flow Case Deceased Constituent Flow.

            // sendPRMNotification(deceasedConIdToConMap); // clin Use case 9 and use case 10 // clin 10/09/2023 - As per Quy, there is already an existing flow to create an action center notification. Requested to be commented out.
            
            
            canInvokeSyncMaritalStatusAndSalutationPreference = true;
            asc_TRIG_RelationshipHandler.canInvokeSyncReciprocalRalationshipFieldsUpdate = true;
        }
    }

    /*******************************************************************************************************
     * @description Method to update the surviving spouses of the deceased constituents
     * @param deceasedConIdToConMap Map of deceased constituent Id to its deceased constituent record
     * @param deceasedConIdToSpouseRelationshipMap Map of deceased constituent Id to its spousal relationship record
     * @return N/A
     */ // clin use case 13 / use case 14
     private void updateSurvivingSpouses(Map<Id, Contact> deceasedConIdToConMap, Map<Id, ucinn_ascendv2__Relationship__c> deceasedConIdToSpouseRelationshipMap) {
        List<Contact> updateContactSpouseList = new List<Contact>();
        Map<Id, Id> spouseIdToDeceasedConIdMap = new Map<Id, Id>();
        
        for (ucinn_ascendv2__Relationship__c rel : deceasedConIdToSpouseRelationshipMap.values()) {
            if (rel.ucinn_ascendv2__Contact__c != null && rel.ucinn_ascendv2__Related_Contact__c != null) {
                spouseIdToDeceasedConIdMap.put(rel.ucinn_ascendv2__Related_Contact__c, rel.ucinn_ascendv2__Contact__c);
            }
        }
        
        // Collect spouse to update
        for (Contact spouseCon : [SELECT Id, ucinn_ascendv2__Marital_Status__c, ucinn_ascendv2__Contact_Type__c, ucinn_ascendv2__Preferred_Class_Year__c 
                                    FROM Contact WHERE Id IN :spouseIdToDeceasedConIdMap.keySet()]) {
            Id deceasedConId = spouseIdToDeceasedConIdMap.containsKey(spouseCon.Id) ? spouseIdToDeceasedConIdMap.get(spouseCon.Id) : null;

            if (deceasedConId != null) {
                if (deceasedConIdToConMap.containsKey(deceasedConId)) {
                    Contact deceasedContact = deceasedConIdToConMap.get(deceasedConId);
                    
                    if (deceasedContact.ucinn_ascendv2__Contact_Type__c != null) {
                        // clin use case 13 / use case 14
                        if (deceasedContact.ucinn_ascendv2__Contact_Type__c.contains('AL')) {
                            // clin 09/28/2022 - updated values for ucinn_ascendv2__Marital_Status__c field
                            // clin 10/10/2022 - Still needs confirmation if Marital Status needs to be updated. Removed code in the meantime.
                            // spouseCon.ucinn_ascendv2__Marital_Status__c = 'W'; // clin use case 14 / use case 15
                            
                            List<String> spouseConTypeList = new List<String>();
                            if (spouseCon.ucinn_ascendv2__Contact_Type__c != null) {
                                spouseConTypeList = spouseCon.ucinn_ascendv2__Contact_Type__c.split(';');
                            }
                            
                            if (!spouseConTypeList.contains('AW') || spouseCon.ucinn_ascendv2__Preferred_Class_Year__c != deceasedContact.ucinn_ascendv2__Preferred_Class_Year__c) {
                                // Use Case 13 - Add 'Alumni Widow' to surving spouse's ucinn_ascendv2__Contact_Type__c if deceased constituent has ucinn_ascendv2__Contact_Type__c = 'Alumni'
                                if (!spouseConTypeList.contains('AW')) {
                                    spouseConTypeList.add('AW');
                                    spouseCon.ucinn_ascendv2__Contact_Type__c = String.join(spouseConTypeList, ';');
                                }

                                // Use Case 14 - Copy ucinn_ascendv2__Preferred_Class_Year__c to suriving spouse if deceased constituent has ucinn_ascendv2__Contact_Type__c = 'Alumni'
                                spouseCon.ucinn_ascendv2__Preferred_Class_Year__c = deceasedContact.ucinn_ascendv2__Preferred_Class_Year__c;

                                updateContactSpouseList.add(spouseCon);
                            }
                        }
                    }
                }
            }
        }
        
        if (!updateContactSpouseList.isEmpty()) {
            update updateContactSpouseList;
        }
    }
    
    /*******************************************************************************************************
     * @description Method to update related records (Address Relation, Email, Phone, Service Indicator, Involvement) Status
     * @param deceasedConIds Set of deceased constituent Ids
     * @param objectName API name of the related object to update
     * @return N/A
     * @updated 09/28/2022 by clin - added new fields depending on the related objects - Use cases 2, 3, 4, 5, 6, 7 and 8
     */
    private void updateDeceasedRelatedRecordStatus(Set<Id> deceasedConIds, String objectName) {
        List<sObject> updateList = new List<sObject>();
        
        if (!deceasedConIds.isEmpty() && String.isNotBlank(objectName)) {
            String soqlString;
            String soqlFields = 'Id, ucinn_ascendv2__Contact__r.ucinn_ascendv2__Date_Marked_Deceased__c, ucinn_ascendv2__Contact__r.ND_Decease_Confirmed_Date__c';

            if (objectName == 'ucinn_ascendv2__Address_Relation__c' || 
                objectName == 'ucinn_ascendv2__Email__c' || 
                objectName == 'ucinn_ascendv2__Phone__c') {
                soqlFields += ', ucinn_ascendv2__Status__c, ucinn_ascendv2__Is_Preferred__c, ucinn_ascendv2__End_Date__c';
                String soqlWhere = ' AND ucinn_ascendv2__Status__c = \'Current\'';
                soqlString = 'SELECT ' + soqlFields + ' FROM ' + objectName + ' WHERE ucinn_ascendv2__Contact__c IN :deceasedConIds' + soqlWhere;
            } else if (objectName == 'ucinn_ascendv2__Service_Indicator__c') {
                soqlFields += ', ucinn_ascendv2__Is_Active__c, ucinn_ascendv2__End_Date__c';
                soqlString = 'SELECT ' + soqlFields + ' FROM ' + objectName + ' WHERE ucinn_ascendv2__Contact__c IN :deceasedConIds';
            } else if (objectName == 'ucinn_ascendv2__Involvement__c') {
                soqlFields += ', ucinn_ascendv2__Status__c, ucinn_ascendv2__End_Date__c';
                soqlString = 'SELECT ' + soqlFields + ' FROM ' + objectName + ' WHERE ucinn_ascendv2__Contact__c IN :deceasedConIds';
            }

            if (soqlString != null) {
                for (sObject obj : Database.query(soqlString)) {
                    if (objectName == 'ucinn_ascendv2__Address_Relation__c' ) {
                        if (obj.get('ucinn_ascendv2__Status__c') != 'Former') {
                            obj.put('ucinn_ascendv2__Status__c', 'Former');
                        }

                        if (Boolean.valueOf(obj.get('ucinn_ascendv2__Is_Preferred__c')) == true) {
                            obj.put('ucinn_ascendv2__Is_Preferred__c', false);
                        }

                        // clin 09/28/2022 - set ucinn_ascendv2__End_Date__c to constituent's ucinn_ascendv2__Date_Marked_Deceased__c / ND_Decease_Confirmed_Date__c / TODAY
                        if (obj.getSObject('ucinn_ascendv2__Contact__r').get('ucinn_ascendv2__Date_Marked_Deceased__c') != null) {
                            obj.put('ucinn_ascendv2__End_Date__c', obj.getSObject('ucinn_ascendv2__Contact__r').get('ucinn_ascendv2__Date_Marked_Deceased__c'));
                        } else if (obj.getSObject('ucinn_ascendv2__Contact__r').get('ND_Decease_Confirmed_Date__c') != null) {
                            obj.put('ucinn_ascendv2__End_Date__c', obj.getSObject('ucinn_ascendv2__Contact__r').get('ND_Decease_Confirmed_Date__c'));
                        } else {
                            obj.put('ucinn_ascendv2__End_Date__c', System.today());
                        }

                        updateList.add(obj);
                    }  

                }
            }
        }
        
        if (!updateList.isEmpty()) {
            update updateList;
        }
    }
    
    /*******************************************************************************************************
     * @description Method to add "Quiet Stage" - no solicitation for 6 months to surviving spouse
     * @param deceasedConIdToConMap Map of deceased constituent Id to its deceased constituent record
     * @param deceasedConIdToSpouseRelationshipMap Map of deceased constituent Id to its spousal relationship record
     * @return N/A
     */ // clin use case 24
    private void addSurvivingSpouseServiceIndicators(Map<Id, Contact> deceasedConIdToConMap, Map<Id, ucinn_ascendv2__Relationship__c> deceasedConIdToSpouseRelationshipMap) {
        List<ucinn_ascendv2__Service_Indicator__c> insertServiceIndicatorList = new List<ucinn_ascendv2__Service_Indicator__c>();
        Set<Id> spouseIds = new Set<Id>();
        Map<Id, List<ucinn_ascendv2__Service_Indicator__c>> spouseIdToServiceIndicatorsList = new Map<Id, List<ucinn_ascendv2__Service_Indicator__c>>();
        
        for (Id deceasedConId : deceasedConIdToConMap.keySet()) {
            if (deceasedConIdToSpouseRelationshipMap.containsKey(deceasedConId)) {
                spouseIds.add(deceasedConIdToSpouseRelationshipMap.get(deceasedConId).ucinn_ascendv2__Related_Contact__c);
            }
        }

        // Retrieve existing QP Service Indicators
        // clin 10/09/2023 - updated service indicator value code from QP to DNQ in the WHERE clause
        for (ucinn_ascendv2__Service_Indicator__c si : [SELECT Id, ucinn_ascendv2__Contact__c, ucinn_ascendv2__Start_Date__c, ucinn_ascendv2__End_Date__c 
                                                                FROM ucinn_ascendv2__Service_Indicator__c WHERE ucinn_ascendv2__Service_Indicator_Value__r.ucinn_ascendv2__Code__c = 'DNQ'
                                                                AND ucinn_ascendv2__Contact__c IN :spouseIds]) {
            if (spouseIdToServiceIndicatorsList.containsKey(si.ucinn_ascendv2__Contact__c)) {
                spouseIdToServiceIndicatorsList.get(si.ucinn_ascendv2__Contact__c).add(si);
            } else {
                spouseIdToServiceIndicatorsList.put(si.ucinn_ascendv2__Contact__c, new List<ucinn_ascendv2__Service_Indicator__c>{si});
            }
        }

        // clin 10/20/2022 - based on use case 24, only Service Indicator Value "QP" should be added to the spouse of the deceased constituent
        // clin 10/20/2022 - Removed 'DNE', 'DNP', 'DNS'
        // clin 10/09/2023 - updated service indicator value code from QP to DNQ in the WHERE clause
        ucinn_ascendv2__Service_Indicator_Value__c siv = [SELECT Id FROM ucinn_ascendv2__Service_Indicator_Value__c WHERE ucinn_ascendv2__Code__c = 'DNQ' LIMIT 1];

        if (siv != null) {
            for (Id deceasedConId : deceasedConIdToConMap.keySet()) {
                if (deceasedConIdToSpouseRelationshipMap.containsKey(deceasedConId)) {
                    Id spouseId = deceasedConIdToSpouseRelationshipMap.get(deceasedConId).ucinn_ascendv2__Related_Contact__c;

                    if (spouseId != null) {
                        ucinn_ascendv2__Service_Indicator__c newsi = new ucinn_ascendv2__Service_Indicator__c();
                        newsi.RecordTypeId = Schema.SObjectType.ucinn_ascendv2__Service_Indicator__c.getRecordTypeInfosByDeveloperName().get('Contact_Service_Indicator').getRecordTypeId();
                        newsi.ucinn_ascendv2__Contact__c = spouseId;
                        newsi.ucinn_ascendv2__Service_Indicator_Value__c = siv.Id;
                        // clin 10/20/2022 - based on use case 24, use ucinn_ascendv2__Date_Marked_Deceased__c instead of Date.today()
                        if (deceasedConIdToConMap.get(deceasedConId).ucinn_ascendv2__Date_Marked_Deceased__c != null) {
                            newsi.ucinn_ascendv2__Start_Date__c = deceasedConIdToConMap.get(deceasedConId).ucinn_ascendv2__Date_Marked_Deceased__c;
                            newsi.ucinn_ascendv2__End_Date__c = deceasedConIdToConMap.get(deceasedConId).ucinn_ascendv2__Date_Marked_Deceased__c.addMonths(6);
                            newsi.ucinn_ascendv2__Is_Display_On_Record_Page__c = true;
                        }
                        newsi.Status__c = 'None'; // clin 10/20/2022 - based on use case 24, this should be "Exclude" instead of "Include" // clin 10/10/2023 W-001647 - As per ND, this should be set to None instead of Exclude
                        newsi.Data_Source__c = 'Deceasing';

                        Boolean addServiceIndicator = true;

                        // Do not add same QP Service Indicator if it already exists
                        if (spouseIdToServiceIndicatorsList.containsKey(spouseId)) {
                            for (ucinn_ascendv2__Service_Indicator__c si : spouseIdToServiceIndicatorsList.get(spouseId)) {
                                if (si.ucinn_ascendv2__Start_Date__c == newsi.ucinn_ascendv2__Start_Date__c && si.ucinn_ascendv2__End_Date__c == newsi.ucinn_ascendv2__End_Date__c) {
                                    addServiceIndicator = false;
                                }
                            }
                        }
                        
                        if (addServiceIndicator) {
                            insertServiceIndicatorList.add(newsi);
                        }
                    }
                }
            }
        }
        
        if (!insertServiceIndicatorList.isEmpty()) {
            insert insertServiceIndicatorList;
        }
    }
    
    /*******************************************************************************************************
     * @description Method to set the surviving spouse as the primary constituent
     * @param contactSpouseMap The map of deceased spouse Id and surviving spouse Id
     * @return N/A
     */ // clin use case 12
    private void updateDeceasedHouseholdPrimaryConstituents(Map<Id, Id> contactSpouseMap) {
        List<Account> updateAccountList = new List<Account>();
        
        for (Account acc : [SELECT Id, Name, ucinn_ascendv2__Primary_Contact__c, Secondary_Constituent__c, 
                                (SELECT Id, ucinn_ascendv2__Is_Deceased__c, LastName, FirstName, ucinn_ascendv2__Donor_ID__c FROM Contacts) 
                            FROM Account WHERE ucinn_ascendv2__Primary_Contact__c In :contactSpouseMap.keySet()]) {
            Id deceasedConId = acc.ucinn_ascendv2__Primary_Contact__c;
            Id spouseId = contactSpouseMap.get(acc.ucinn_ascendv2__Primary_Contact__c);
            
            Map<Id, Contact> membersConIdToConMap = new Map<Id, Contact>();
            
            for (Contact con : acc.Contacts) {
                membersConIdToConMap.put(con.Id, con);
            }
            
            if (spouseId != null && membersConIdToConMap.containsKey(spouseId)) {
                // clin 10/07/2022 - Update Primary Constituent and Secondary Constituent only when the spouse of the deceased is not deceased
                Contact spouseCon = membersConIdToConMap.get(spouseId);

                if (!spouseCon.ucinn_ascendv2__Is_Deceased__c) {
                    acc.Name = spouseCon.LastName + ', ' + spouseCon.FirstName + ', ' + spouseCon.ucinn_ascendv2__Donor_ID__c + ' Household';
                    acc.ucinn_ascendv2__Primary_Contact__c = spouseId;
                    acc.Secondary_Constituent__c = deceasedConId;
                    updateAccountList.add(acc);
                }
            }
        }
        
        if (!updateAccountList.isEmpty()) {
            update updateAccountList;
        }
    }

    /*******************************************************************************************************
     * @description Method to retrieve currently active spousal relationship records of the deceased constituent
     * @param deceasedConIds Set of deceased constituent Ids
     * @return deceasedConIdToSpouseRelationshipMap Map of deceased constituent Id to its spousal relationship record
     */
    private Map<Id, ucinn_ascendv2__Relationship__c> getSpousalRelationship(Set<Id> deceasedConIds) {
        Map<Id, ucinn_ascendv2__Relationship__c> deceasedConIdToSpouseRelationshipMap = new Map<Id, ucinn_ascendv2__Relationship__c>();
        List<String> validSpousalRoles = new List<String>{'Spouse', 'Partner/Significant Other'};

        if (!deceasedConIds.isEmpty()) {
            // clin 10/13/2022 - Need confirmation if we need to check for ucinn_ascendv2__Status__c or Start Date/End Date
            for (ucinn_ascendv2__Relationship__c rel : [SELECT Id, ucinn_ascendv2__Contact__c, ucinn_ascendv2__Related_Contact__c, 
                                                            nd_Do_Not_Sync_Home_Address__c, nd_Do_Not_Sync_Seasonal_Address__c, 
                                                            ucinn_ascendv2__Apply_Soft_Credit__c, ucinn_ascendv2__Related_Contact_Role__c, ucinn_ascendv2__Status__c 
                                                            FROM ucinn_ascendv2__Relationship__c 
                                                            WHERE ucinn_ascendv2__Contact__c IN :deceasedConIds AND 
                                                                ucinn_ascendv2__Related_Contact_Role__c IN :validSpousalRoles]) {
                deceasedConIdToSpouseRelationshipMap.put(rel.ucinn_ascendv2__Contact__c, rel);
            }
        }

        return deceasedConIdToSpouseRelationshipMap;
    }

    /*******************************************************************************************************
     * @description Method to update the relationship records of the deceased constituents
     * @param spousalRelsList List of spousal relationship records related to the deceased constituents
     * @return N/A
     */ // clin use case 14 / use case 15
    private void updateDeceasedSpousalRelationship(List<ucinn_ascendv2__Relationship__c> spousalRelsList) {
        List<ucinn_ascendv2__Relationship__c> relationshipRolesUpdate = new List<ucinn_ascendv2__Relationship__c>();
        List<ucinn_ascendv2__Relationship__c> relationshipFlagsUpdate = new List<ucinn_ascendv2__Relationship__c>();
        
        for (ucinn_ascendv2__Relationship__c rel : spousalRelsList) {
            rel.ucinn_ascendv2__Related_Contact_Role__c = 'Widow';

            relationshipRolesUpdate.add(rel);
        }
        
        if (!relationshipRolesUpdate.isEmpty()) {
            // asc_TRIG_RelationshipHandler.canInvokeSyncReciprocalRalationshipFieldsUpdate = false; // clin 05/02/2023 - Removed
            update relationshipRolesUpdate;
            // asc_TRIG_RelationshipHandler.canInvokeSyncReciprocalRalationshipFieldsUpdate = true; // clin 05/02/2023 - Removed
        }
        // clin 05/02/2023 - Removed logic. This already exists in asc_TRIG_RelationshipHandler. Check uncheckDoNotSyncAddressSettings method and syncReciprocalRalationshipFieldsUpdate method
        /* for (ucinn_ascendv2__Relationship__c rel : spousalRelsList) {
            rel.nd_Do_Not_Sync_Home_Address__c = true;
            rel.nd_Do_Not_Sync_Seasonal_Address__c = true;
            rel.ucinn_ascendv2__Apply_Soft_Credit__c = false;

            relationshipFlagsUpdate.add(rel);
        }
        
        if (!relationshipFlagsUpdate.isEmpty()) {
            update relationshipFlagsUpdate;
        } */
    }

    /*******************************************************************************************************
     * @description Method to update related Society Membership records of the deceased constituent and the surviving spouse
     * @param deceasedConIdToConMap Map of deceased constituent Id to its deceased constituent record
     * @param deceasedConIdToSpouseRelationshipMap Map of deceased constituent Id to its spousal relationship record
     * @return N/A
     */ // clin use case 8, use case 16, use case 17
     private void updateRelatedSocietyMemberships(Map<Id, Contact> deceasedConIdToConMap, Map<Id, ucinn_ascendv2__Relationship__c> deceasedConIdToSpouseRelationshipMap) {
        List<ucinn_ascendv2__Society_Membership__c> updateMembershipList = new List<ucinn_ascendv2__Society_Membership__c>();
        List<ucinn_ascendv2__Society_Membership__c> insertMembershipList = new List<ucinn_ascendv2__Society_Membership__c>();
        Map<Id, List<ucinn_ascendv2__Society_Membership__c>> deceasedConIdToActiveMembershipsList = new Map<Id, List<ucinn_ascendv2__Society_Membership__c>>();
        Map<Id, List<ucinn_ascendv2__Society_Membership__c>> spouseIdToActiveMembershipsList = new Map<Id, List<ucinn_ascendv2__Society_Membership__c>>();
        Set<String> excludedGivingSocietyCodes = new Set<String>{'FT', 'BG'};
        Set<Id> spouseIdsOfDeceasedCon = new Set<Id>();
        
        for (Id deceasedConId : deceasedConIdToConMap.keySet()) {
            if (deceasedConIdToSpouseRelationshipMap.containsKey(deceasedConId)) {
                Id spouseId = deceasedConIdToSpouseRelationshipMap.get(deceasedConId).ucinn_ascendv2__Related_Contact__c;
                spouseIdsOfDeceasedCon.add(spouseId);
            }
        }

        for (ucinn_ascendv2__Society_Membership__c sm : [SELECT Id, ucinn_ascendv2__Contact__c, ucinn_ascendv2__Giving_Society__c, ucinn_ascendv2__Giving_Society__r.nd_Giving_Society_Code__c, 
                                                        nd_Membership_Type__c, nd_Active_Inactive__c, ucinn_ascendv2__Expiration_Date__c, ucinn_ascendv2__Member_Since__c, nd_Status__c, ucinn_ascendv2__Is_Primary__c, 
                                                        ucinn_ascendv2__Membership_Level__c, nd_Membership_Level_Date__c 
                                                    FROM ucinn_ascendv2__Society_Membership__c 
                                                    WHERE (ucinn_ascendv2__Contact__c IN :deceasedConIdToConMap.keySet() OR ucinn_ascendv2__Contact__c IN :spouseIdsOfDeceasedCon) AND nd_Status__c = 'A']) {
            if (deceasedConIdToConMap.containsKey(sm.ucinn_ascendv2__Contact__c)) {
                if (deceasedConIdToActiveMembershipsList.containsKey(sm.ucinn_ascendv2__Contact__c)) {
                    deceasedConIdToActiveMembershipsList.get(sm.ucinn_ascendv2__Contact__c).add(sm);
                } else {
                    deceasedConIdToActiveMembershipsList.put(sm.ucinn_ascendv2__Contact__c, new List<ucinn_ascendv2__Society_Membership__c>{sm});
                }
            }
            
            if (spouseIdsOfDeceasedCon.contains(sm.ucinn_ascendv2__Contact__c)) {
                if (spouseIdToActiveMembershipsList.containsKey(sm.ucinn_ascendv2__Contact__c)) {
                    spouseIdToActiveMembershipsList.get(sm.ucinn_ascendv2__Contact__c).add(sm);
                } else {
                    spouseIdToActiveMembershipsList.put(sm.ucinn_ascendv2__Contact__c, new List<ucinn_ascendv2__Society_Membership__c>{sm});
                }
            }
        }

        for (Id deceasedConId : deceasedConIdToConMap.keySet()) {
            Contact deceasedCon = deceasedConIdToConMap.get(deceasedConId);

            if (deceasedConIdToActiveMembershipsList.containsKey(deceasedConId)) {
                // If deceased constituent has a spouse // use case 16 and use case 17
                if (deceasedConIdToSpouseRelationshipMap.containsKey(deceasedConId)) {
                    Id spouseId = deceasedConIdToSpouseRelationshipMap.get(deceasedConId).ucinn_ascendv2__Related_Contact__c;

                    Map<Id, List<ucinn_ascendv2__Society_Membership__c>> deceasedMembershipsToCloneMap = new Map<Id, List<ucinn_ascendv2__Society_Membership__c>>();

                    for (ucinn_ascendv2__Society_Membership__c deceasedSM : deceasedConIdToActiveMembershipsList.get(deceasedConId)) {
                        if (deceasedSM.nd_Membership_Type__c == 'Member' && deceasedSM.nd_Active_Inactive__c == true && 
                            (deceasedSM.ucinn_ascendv2__Expiration_Date__c == null || deceasedSM.ucinn_ascendv2__Expiration_Date__c > System.today()) && 
                            !excludedGivingSocietyCodes.contains(deceasedSM.ucinn_ascendv2__Giving_Society__r.nd_Giving_Society_Code__c)) {
                            ucinn_ascendv2__Society_Membership__c updatedDeceasedSM = new ucinn_ascendv2__Society_Membership__c();
                            updatedDeceasedSM.Id = deceasedSM.Id;
                            updatedDeceasedSM.nd_Status__c = 'X';
                            updatedDeceasedSM.ucinn_ascendv2__Expiration_Date__c = deceasedCon.ucinn_ascendv2__Date_Marked_Deceased__c;
    
                            updateMembershipList.add(updatedDeceasedSM);

                            if (deceasedMembershipsToCloneMap.containsKey(deceasedSM.ucinn_ascendv2__Giving_Society__c)) {
                                deceasedMembershipsToCloneMap.get(deceasedSM.ucinn_ascendv2__Giving_Society__c).add(deceasedSM);
                            } else {
                                deceasedMembershipsToCloneMap.put(deceasedSM.ucinn_ascendv2__Giving_Society__c, new List<ucinn_ascendv2__Society_Membership__c>{deceasedSM});
                            }
                        }
                    }

                    // if spouse has a Society Membership with the same Giving Society as the deceased constituent,
                    // update the Non-Member Spouse record and clone the deceased Consituent's Society Membership record
                    if (spouseIdToActiveMembershipsList.containsKey(spouseId)) {
                        for (ucinn_ascendv2__Society_Membership__c spouseSM : spouseIdToActiveMembershipsList.get(spouseId)) {
                            if (deceasedMembershipsToCloneMap.containsKey(spouseSM.ucinn_ascendv2__Giving_Society__c) && spouseSM.nd_Membership_Type__c == 'Non-Member Spouse' && 
                                (spouseSM.ucinn_ascendv2__Expiration_Date__c == null || spouseSM.ucinn_ascendv2__Expiration_Date__c > System.today())) {
                                spouseSM.nd_Status__c = 'P';
                                spouseSM.ucinn_ascendv2__Expiration_Date__c = deceasedCon.ucinn_ascendv2__Date_Marked_Deceased__c;

                                updateMembershipList.add(spouseSM);

                                // clone the deceased Constituent's Soceity Membership record
                                for (ucinn_ascendv2__Society_Membership__c deceasedSM : deceasedMembershipsToCloneMap.get(spouseSM.ucinn_ascendv2__Giving_Society__c)) {
                                    ucinn_ascendv2__Society_Membership__c clonedSM = deceasedSM.clone(false, true);
                                    clonedSM.ucinn_ascendv2__Contact__c = spouseId;
                                    clonedSM.ucinn_ascendv2__Is_Primary__c = true;

                                    insertMembershipList.add(clonedSM);
                                }
                            }
                        }
                    }
                    // Do nothing if deceased constituent has an active Society Membership where Giving Society = FT or BG
                    // These will be manual exceptions processed by ND
                }
                // If decease constituent does not have a spouse // use case 8
                else {
                    for (ucinn_ascendv2__Society_Membership__c deceasedSM : deceasedConIdToActiveMembershipsList.get(deceasedConId)) {
                        deceasedSM.nd_Status__c = 'X';

                        if (deceasedCon.ucinn_ascendv2__Date_Marked_Deceased__c != null) {
                            deceasedSM.ucinn_ascendv2__Expiration_Date__c = deceasedCon.ucinn_ascendv2__Date_Marked_Deceased__c;
                        } else if (deceasedCon.ND_Decease_Confirmed_Date__c != null) {
                            deceasedSM.ucinn_ascendv2__Expiration_Date__c = deceasedCon.ND_Decease_Confirmed_Date__c;
                        } else {
                            deceasedSM.ucinn_ascendv2__Expiration_Date__c = System.today();
                        }

                        updateMembershipList.add(deceasedSM);
                    }
                }
            }
        }
        
        if (!updateMembershipList.isEmpty()) {
            update updateMembershipList;
        }

        if (!insertMembershipList.isEmpty()) {
            insert insertMembershipList;
        }
    }

    /*******************************************************************************************************
     * @description Method to update related Affiliation records of the deceased constituent and the surviving spouse
     * @param deceasedConIdToConMap Map of deceased constituent Id to its deceased constituent record
     * @param deceasedConIdToSpouseRelationshipMap Map of deceased constituent Id to its spousal relationship record
     * @return N/A
     */ // clin use case 6 and use case 18
     private void updateRelatedAffiliations(Map<Id, Contact> deceasedConIdToConMap, Map<Id, ucinn_ascendv2__Relationship__c> deceasedConIdToSpouseRelationshipMap) {
        List<ucinn_ascendv2__Affiliation__c> updateAffiliationsList = new List<ucinn_ascendv2__Affiliation__c>();
        Map<Id, List<ucinn_ascendv2__Affiliation__c>> deceasedConIdToAffiliationsList = new Map<Id, List<ucinn_ascendv2__Affiliation__c>>();
        Map<Id, List<ucinn_ascendv2__Affiliation__c>> spouseIdToActiveAffiliationsList = new Map<Id, List<ucinn_ascendv2__Affiliation__c>>();
        Set<String> excludedGivingSocietyCodes = new Set<String>{'FT', 'BG'};
        Set<Id> spouseIdsOfDeceasedCon = new Set<Id>();
        
        for (Id deceasedConId : deceasedConIdToConMap.keySet()) {
            if (deceasedConIdToSpouseRelationshipMap.containsKey(deceasedConId)) {
                Id spouseId = deceasedConIdToSpouseRelationshipMap.get(deceasedConId).ucinn_ascendv2__Related_Contact__c;
                spouseIdsOfDeceasedCon.add(spouseId);
            }
        }

        for (ucinn_ascendv2__Affiliation__c aff : [SELECT Id, ucinn_ascendv2__Contact__c, ucinn_ascendv2__Status__c, ucinn_ascendv2__End_Date__c, nd_Employee_Type__c 
                                                    FROM ucinn_ascendv2__Affiliation__c 
                                                    WHERE ucinn_ascendv2__Contact__c IN :deceasedConIdToConMap.keySet() OR ucinn_ascendv2__Contact__c IN :spouseIdsOfDeceasedCon]) {
            if (deceasedConIdToConMap.containsKey(aff.ucinn_ascendv2__Contact__c)) {
                if (deceasedConIdToAffiliationsList.containsKey(aff.ucinn_ascendv2__Contact__c)) {
                    deceasedConIdToAffiliationsList.get(aff.ucinn_ascendv2__Contact__c).add(aff);
                } else {
                    deceasedConIdToAffiliationsList.put(aff.ucinn_ascendv2__Contact__c, new List<ucinn_ascendv2__Affiliation__c>{aff});
                }
            }
            
            if (spouseIdsOfDeceasedCon.contains(aff.ucinn_ascendv2__Contact__c)) {
                if (spouseIdToActiveAffiliationsList.containsKey(aff.ucinn_ascendv2__Contact__c)) {
                    spouseIdToActiveAffiliationsList.get(aff.ucinn_ascendv2__Contact__c).add(aff);
                } else {
                    spouseIdToActiveAffiliationsList.put(aff.ucinn_ascendv2__Contact__c, new List<ucinn_ascendv2__Affiliation__c>{aff});
                }
            }
        }

        for (Id deceasedConId : deceasedConIdToConMap.keySet()) {
            Contact deceasedCon = deceasedConIdToConMap.get(deceasedConId);

            if (deceasedConIdToAffiliationsList.containsKey(deceasedConId)) {
                Boolean hasNDEmploymentAff = false;

                // use case 6 - update active Affiliation records of the deceased Constituent
                for (ucinn_ascendv2__Affiliation__c deceasedAff : deceasedConIdToAffiliationsList.get(deceasedConId)) {
                    if (deceasedAff.ucinn_ascendv2__Status__c == 'Current') {
                        deceasedAff.ucinn_ascendv2__Status__c = 'Active at time of Death';

                        if (deceasedCon.ucinn_ascendv2__Date_Marked_Deceased__c != null) {
                            deceasedAff.ucinn_ascendv2__End_Date__c = deceasedCon.ucinn_ascendv2__Date_Marked_Deceased__c;
                        } else if (deceasedCon.ND_Decease_Confirmed_Date__c != null) {
                            deceasedAff.ucinn_ascendv2__End_Date__c = deceasedCon.ND_Decease_Confirmed_Date__c;
                        } else {
                            deceasedAff.ucinn_ascendv2__End_Date__c = System.today();
                        }

                        deceasedAff.Is_Primary_Employment__c = false; // Added on 03/23/2023

                        updateAffiliationsList.add(deceasedAff);
                    }

                    // check if deceased constituent has an Affiliation record with ND Employment
                    if (deceasedAff.nd_Employee_Type__c != null) {
                        hasNDEmploymentAff = true;
                    }
                }

                // If deceased constituent has a spouse and an affiliation with ND Employment // use case 18
                // Commented out because we need not change the spouse's Affiliation Status just because the other spouse passes.
           /*   if (deceasedConIdToSpouseRelationshipMap.containsKey(deceasedConId) && hasNDEmploymentAff) {
                    Id spouseId = deceasedConIdToSpouseRelationshipMap.get(deceasedConId).ucinn_ascendv2__Related_Contact__c;
                    
                    // update related Affiliation records(where nd_Employee_Type__c != NULL) of the spouse
                    if (spouseIdToActiveAffiliationsList.containsKey(spouseId)) {
                        for (ucinn_ascendv2__Affiliation__c spouseAff : spouseIdToActiveAffiliationsList.get(spouseId)) {
                            if (spouseAff.nd_Employee_Type__c != null) {
                                spouseAff.ucinn_ascendv2__Status__c = 'Spouse Active at Time of Death';
                                spouseAff.ucinn_ascendv2__End_Date__c = deceasedCon.ucinn_ascendv2__Date_Marked_Deceased__c;
                                spouseAff.Is_Primary_Employment__c = false; // Added on 03/23/2023

                                updateAffiliationsList.add(spouseAff);
                            }
                        }
                    }
                }*/
            }
        }
        
        if (!updateAffiliationsList.isEmpty()) {
            update updateAffiliationsList;
        }
    }

    /*******************************************************************************************************
     * @description Method to move the related records(Strategy, Proposal, Research, Wealth Rating, Wealth Asset) of the deceased constituent to the surviving spouse(new Primary Constituent of the household)
     * @param deceasedConIdToConMap Map of deceased constituent Id to its deceased constituent record
     * @param deceasedConIdToSpouseRelationshipMap Map of deceased constituent Id to its spousal relationship record
     * @return N/A
     */ // clin use case 19, use case 20, use case 21, use case 22, use case 23
    /*
     private void updateHouseholdRelatedRecords(Set<Id> deceasedConIds, Map<Id, ucinn_ascendv2__Relationship__c> deceasedConIdToSpouseRelationshipMap) {
        List<String> relatedObjects = new List<String>{'ucinn_ascendv2__Strategy__c', 'Opportunity', 'ucinn_ascendv2__Research__c', 'ucinn_ascendv2__Wealth_Rating__c', 'Wealth_Asset__c', 'Case'}; // list of sObject API names of related records that need to be updated
        List<sObject> updateList = new List<sObject>();
        Id proposalRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Proposal').getRecordTypeId();
        Id researchRequestRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Research Requests').getRecordTypeId();
        
        if (!deceasedConIds.isEmpty() && !relatedObjects.isEmpty()) {
            for (String objectName : relatedObjects) {
                String soqlString;

                if (objectName == 'ucinn_ascendv2__Strategy__c' || 
                    objectName == 'ucinn_ascendv2__Research__c' || 
                    objectName == 'ucinn_ascendv2__Wealth_Rating__c') { // use case 19, 21, 22
                    soqlString = 'SELECT Id, ucinn_ascendv2__Contact__c, ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__Primary_Contact__c FROM ' + objectName + ' WHERE ucinn_ascendv2__Contact__c IN :deceasedConIds';
                } else if (objectName == 'Opportunity') { // use case 20
                    soqlString = 'SELECT Id, ucinn_ascendv2__Contact__c, ucinn_ascendv2__Proposal_Contact__c, ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__Primary_Contact__c FROM ' + objectName + ' WHERE ucinn_ascendv2__Contact__c IN :deceasedConIds AND RecordTypeId = :proposalRecTypeId AND IsClosed = FALSE';
                } else if (objectName == 'Wealth_Asset__c') { // use case 23
                    soqlString = 'SELECT Id, Constituent__c, Constituent__r.Account.ucinn_ascendv2__Primary_Contact__c FROM ' + objectName + ' WHERE Constituent__c IN :deceasedConIds AND Status__c = \'Active\'';
                } else if (objectName == 'Case') { // use case 21
                    soqlString = 'SELECT Id, ContactId, Contact.Account.ucinn_ascendv2__Primary_Contact__c FROM ' + objectName + ' WHERE ContactId IN :deceasedConIds AND RecordTypeId = :researchRequestRecTypeId AND IsClosed = FALSE';
                }

                if (soqlString != null) {
                    for (sObject obj : Database.query(soqlString)) {
                        if (objectName == 'ucinn_ascendv2__Strategy__c' || 
                            objectName == 'ucinn_ascendv2__Research__c' || 
                            objectName == 'ucinn_ascendv2__Wealth_Rating__c') {
                            Id deceasedConId = Id.valueOf(String.valueOf(obj.get('ucinn_ascendv2__Contact__c')));
                            Id householdPrimaryCon = Id.valueOf(String.valueOf(obj.getSObject('ucinn_ascendv2__Contact__r').getSObject('Account').get('ucinn_ascendv2__Primary_Contact__c')));
                            
                            // update record only if deceased constituent has a spouse
                            if (deceasedConIdToSpouseRelationshipMap.containsKey(deceasedConId) && 
                                obj.get('ucinn_ascendv2__Contact__c') != householdPrimaryCon) {
                                obj.put('ucinn_ascendv2__Contact__c', householdPrimaryCon);
                                
                                updateList.add(obj);
                            }
                        } else if (objectName == 'Opportunity') {
                            Id deceasedConId = Id.valueOf(String.valueOf(obj.get('ucinn_ascendv2__Contact__c')));
                            Id householdPrimaryCon = Id.valueOf(String.valueOf(obj.getSObject('ucinn_ascendv2__Contact__r').getSObject('Account').get('ucinn_ascendv2__Primary_Contact__c')));
                            
                            // update record only if deceased constituent has a spouse
                            if (deceasedConIdToSpouseRelationshipMap.containsKey(deceasedConId) && 
                                (obj.get('ucinn_ascendv2__Contact__c') != householdPrimaryCon || obj.get('ucinn_ascendv2__Proposal_Contact__c') != householdPrimaryCon)) {
                                obj.put('ucinn_ascendv2__Contact__c', householdPrimaryCon);
                                obj.put('ucinn_ascendv2__Proposal_Contact__c', householdPrimaryCon);

                                updateList.add(obj);
                            }
                        } else if (objectName == 'Wealth_Asset__c') {
                            Id deceasedConId = Id.valueOf(String.valueOf(obj.get('Constituent__c')));
                            Id householdPrimaryCon = Id.valueOf(String.valueOf(obj.getSObject('Constituent__r').getSObject('Account').get('ucinn_ascendv2__Primary_Contact__c')));

                            if (deceasedConIdToSpouseRelationshipMap.containsKey(deceasedConId) && 
                                obj.get('Constituent__c') != householdPrimaryCon) {
                                obj.put('Constituent__c', householdPrimaryCon);

                                updateList.add(obj);
                            }
                        } else if (objectName == 'Case') {
                            Id deceasedConId = Id.valueOf(String.valueOf(obj.get('ContactId')));
                            Id householdPrimaryCon = Id.valueOf(String.valueOf(obj.getSObject('Contact').getSObject('Account').get('ucinn_ascendv2__Primary_Contact__c')));

                            if (deceasedConIdToSpouseRelationshipMap.containsKey(deceasedConId) && 
                                obj.get('ContactId') != householdPrimaryCon) {
                                obj.put('ContactId', householdPrimaryCon);

                                updateList.add(obj);
                            }
                        }
                    }
                }
            }
        }
        
        if (!updateList.isEmpty()) {
            update updateList;
        }
    }
    */
    /*******************************************************************************************************
     * @description Method to update the relationship records of the surviving spouses
     * @param deceasedConIdToConMap Map of deceased constituent Id to its deceased constituent record
     * @param deceasedConIdToSpouseRelationshipMap Map of deceased constituent Id to its spousal relationship record
     * @return N/A
     */ // clin use case 11
    /* private void createDeceasedCase(Map<Id, Contact> deceasedConIdToConMap, Map<Id, ucinn_ascendv2__Relationship__c> deceasedConIdToSpouseRelationshipMap) {
        List<Case> casesList = new List<Case>();
        
        for (Contact con : deceasedConIdToConMap.values()) {
            // Only create a case if the deceased constituent does not have a spousal relationship
            if (!deceasedConIdToSpouseRelationshipMap.containsKey(con.Id)) {
                Case deceasedCase = new Case();
                deceasedCase.Subject = 'Deceased Constituent - Assess Assignment Records';
                deceasedCase.Request_Purpose__c = 'Update Capacity';
                deceasedCase.Initiate_Request__c = con.ucinn_ascendv2__Full_Name_Formula__c + ' is deceased.';
                deceasedCase.Strategy_Change__c = 'Evaluation of Assignment is needed.';
                deceasedCase.Requested_By__c = UserInfo.getUserId();
                deceasedCase.Due_Date__c = con.ucinn_ascendv2__Date_Marked_Deceased__c != null ? con.ucinn_ascendv2__Date_Marked_Deceased__c.addDays(30) : null;

                casesList.add(deceasedCase);
            }
        }

        if (!casesList.isEmpty()) {
            insert casesList;
        }
    } */

    /*******************************************************************************************************
     * @description Method to send an email and chatter notification to the PRM of the deceased constituent
     * @param deceasedConIdToConMap Map of deceased constituent Id to its deceased constituent record
     * @return N/A
     * // clin Use case 9 and use case 10
     * // clin 10/09/2023 - As per Quy, there is already an existing flow to create an action center notification. Requested to be commented out.
     */
    /* private void sendPRMNotification(Map<Id, Contact> deceasedConIdToConMap) {
        Set<Id> householdIds = new Set<Id>();
        Map<Id, ucinn_ascendv2__Assignment__c> householdIdToPRMRecMap = new Map<Id, ucinn_ascendv2__Assignment__c>();
        Map<Id, List<String>> conIdToAdressesMap = new Map<Id, List<String>>();
        Map<Id, String> conIdToBodyTextsMap = new Map<Id, String>();
        List<ConnectApi.BatchInput> chatterPostBatchInputs = new List<ConnectApi.BatchInput>();

        for (Contact con : deceasedConIdToConMap.values()) {
            householdIds.add(con.AccountId);
        }

        for (ucinn_ascendv2__Assignment__c assign : [SELECT Id, ucinn_ascendv2__Account__c, ucinn_ascendv2__Assigned_Relationship_Manager_User__c, 
                                                    ucinn_ascendv2__Assigned_Relationship_Manager_User__r.Email, 
                                                    ucinn_ascendv2__Assigned_Relationship_Manager_User__r.ManagerId 
                                                    FROM ucinn_ascendv2__Assignment__c 
                                                    WHERE ucinn_ascendv2__Account__c IN :householdIds 
                                                        AND ucinn_ascendv2__Assignment_Type__c = 'Primary Relationship Manager' 
                                                        AND nd_Is_Active__c = TRUE]) {
            if (assign.ucinn_ascendv2__Assigned_Relationship_Manager_User__c != null) {
                householdIdToPRMRecMap.put(assign.ucinn_ascendv2__Account__c, assign);
            }
        }
        
        for (Contact con : deceasedConIdToConMap.values()) {
            String bodyText;

            if (String.isNotBlank(con.ucinn_ascendv2__Donor_ID__c) && String.isNotBlank(con.ucinn_ascendv2__Full_Name_Formula__c) && con.ucinn_ascendv2__Date_Marked_Deceased__c != null) {
                bodyText = ' Constituent ' + con.ucinn_ascendv2__Donor_ID__c + ' ' + con.ucinn_ascendv2__Full_Name_Formula__c + ' was deceased on ' + con.ucinn_ascendv2__Date_Marked_Deceased__c.format() + '.';

                conIdToBodyTextsMap.put(con.Id, bodyText);
            }

            if (householdIdToPRMRecMap.containsKey(con.AccountId)) {
                ucinn_ascendv2__Assignment__c prmAssignment = householdIdToPRMRecMap.get(con.AccountId);

                if (prmAssignment.ucinn_ascendv2__Assigned_Relationship_Manager_User__c != null) {
                    List<String> emailAddressesList = new List<String>();
                    emailAddressesList.add(prmAssignment.ucinn_ascendv2__Assigned_Relationship_Manager_User__r.Email);
                    conIdToAdressesMap.put(con.Id, emailAddressesList);

                    // clin 10/06/2022 - Create Chatter Post on the ucinn_ascendv2__Assigned_Relationship_Manager_User__r.ManagerId user record
                    if (prmAssignment.ucinn_ascendv2__Assigned_Relationship_Manager_User__r.ManagerId != null && bodyText != null) {
                        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
    
                        feedItemInput.subjectId = prmAssignment.ucinn_ascendv2__Assigned_Relationship_Manager_User__r.ManagerId;
                        
                        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                        
                        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                        mentionSegmentInput.id = prmAssignment.ucinn_ascendv2__Assigned_Relationship_Manager_User__r.ManagerId;
                        messageBodyInput.messageSegments.add(mentionSegmentInput);

                        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
                        textSegmentInput.text = bodyText;
                        messageBodyInput.messageSegments.add(textSegmentInput);

                        feedItemInput.body = messageBodyInput;
                        
                        ConnectApi.BatchInput chatterPostBatchInput = new ConnectApi.BatchInput(feedItemInput);
                        chatterPostBatchInputs.add(chatterPostBatchInput);
                    }
                }
            }
        }

        // clin 10/06/2022 - Use Case 10 - Send a Chatter Notification to the ucinn_ascendv2__Assigned_Relationship_Manager_User__r.ManagerId
        if (!Test.isRunningTest()) { ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), chatterPostBatchInputs); }
        
        // clin 10/06/2022 - Use Case 9 - Send an email notification to the ucinn_ascendv2__Assigned_Relationship_Manager_User__r.Email
        if (!conIdToAdressesMap.isEmpty() && !conIdToBodyTextsMap.isEmpty()) {
            sendDeceasedEmails(conIdToAdressesMap, conIdToBodyTextsMap);
        }
    } */

    /*******************************************************************************************************
     * @description Method to send multiple email notifications for deceased constituents
     * @param conIdToAdressesMap Map of deceased constituent Id to the email addresses to send the email notification to
     * @param conIdToBodyTextsMap Map of deceased constituent Id to the content body of the email notification
     * @return N/A
     */
    public void sendDeceasedEmails(Map<Id, List<String>> conIdToAdressesMap, Map<Id, String> conIdToBodyTextsMap) {
        List<Messaging.SingleEmailMessage> emailMsgs = new List<Messaging.SingleEmailMessage>();

        for (Id conId : conIdToAdressesMap.keySet()) {
            Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();

            List<String> toAddresses = conIdToAdressesMap.get(conId);
            emailMsg.setToAddresses(toAddresses);

            emailMsg.setSubject('Deceased Constituent Notification');

            if (conIdToBodyTextsMap.containsKey(conId)) {
                String bodyText = conIdToBodyTextsMap.get(conId);
                emailMsg.setPlainTextBody(bodyText);
            }

            emailMsgs.add(emailMsg);
        }

        Messaging.sendEmail(emailMsgs);

        // List<String> sendTo = new List<String>();
        // sendTo.add('entcrm@nd.edu');
        // mail.setReplyTo('no_reply@nd.edu');
        // mail.setSenderDisplayName('Scheduled Apex');
    }
    
    /*******************************************************************************************************
     * @description Method to ensure that the surviving spouse gets the children if there are differences in relationship state
     * @param contactSpouseMap The map of deceased spouse Id and surviving spouse Id
     * @return N/A
     */
    private void syncDeceasedChildRelationships(Map<Id, Id> contactSpouseMap) {
        List<String> fieldNameList = getSyncableFieldNames('ucinn_ascendv2__Relationship__c');
        List<ucinn_ascendv2__Relationship__c> insertRelationshipList = new List<ucinn_ascendv2__Relationship__c>();
        Map<Id, Map<Id, ucinn_ascendv2__Relationship__c>> contactChildrenMap = new Map<Id, Map<Id, ucinn_ascendv2__Relationship__c>>();
        Set<Id> allContactSet = new Set<Id>();
        
        allContactSet.addAll(contactSpouseMap.keySet());
        
        for (Id spouseId : contactSpouseMap.values()) {
            if (spouseId != null) {
                allContactSet.add(spouseId);
            }
        }
        
        // Collect children
        for (ucinn_ascendv2__Relationship__c rel : Database.query('Select Id, ' + String.join(fieldNameList, ',') + ' From ucinn_ascendv2__Relationship__c ' +
             ' Where ucinn_ascendv2__Contact__c In :allContactSet And ucinn_ascendv2__Related_Contact_Role__c = \'Child\' ')) {
            
            if (!contactChildrenMap.containsKey(rel.ucinn_ascendv2__Contact__c)) {
                contactChildrenMap.put(rel.ucinn_ascendv2__Contact__c, new Map<Id, ucinn_ascendv2__Relationship__c>());
            }
            contactChildrenMap.get(rel.ucinn_ascendv2__Contact__c).put(rel.ucinn_ascendv2__Related_Contact__c, rel);
        }
        
        // Check if spouse has all the children
        for (Id conId : contactSpouseMap.keySet()) {
            Id spouseId = contactSpouseMap.get(conId);
            
            if (spouseId != null) {
                Set<Id> conchildrenSet = (contactChildrenMap.containsKey(conId)) ? contactChildrenMap.get(conId).keySet() : new Set<Id>();
                Set<Id> spousechildrenSet = (contactChildrenMap.containsKey(spouseId)) ? contactChildrenMap.get(spouseId).keySet() : new Set<Id>();
                
                // Add missing children
                if (!spousechildrenSet.containsAll(conchildrenSet)) {
                    for (Id childId : conchildrenSet) {
                        if (!spousechildrenSet.contains(childId)) {
                            ucinn_ascendv2__Relationship__c rel = contactChildrenMap.get(conId).get(childId);
                            ucinn_ascendv2__Relationship__c newrel = new ucinn_ascendv2__Relationship__c();
                            
                            for (String fn : fieldNameList) {
                                if (fn != 'Name' && fn != 'ucinn_ascendv2__Contact__c' && fn != 'UCIN_External_ID__c') {
                                    newrel.put(fn, rel.get(fn));
                                }
                            }
                            
                            newrel.ucinn_ascendv2__Contact__c = spouseId;
                            insertRelationshipList.add(newrel);
                        }
                    }
                }
            }
        }
        
        if (!insertRelationshipList.isEmpty()) {
            insert insertRelationshipList;
        }
    }
    
    /*******************************************************************************************************
     * @description Method to get the syncable fields
     * @param objectType Object type name
     * @return List of field names
     */
    public static List<String> getSyncableFieldNames(String objectName) {
        Map<String, Schema.Sobjectfield> fieldmap = Schema.getGlobalDescribe().get(objectName).getDescribe().Fields.getMap();
        List<String> fieldNamelist = new List<String>();
        
        if (fieldmap != null) {
            for (Schema.Sobjectfield f : fieldmap.values()) {
                Schema.Describefieldresult fd = f.getDescribe();
                
                if (fd.isUpdateable()) {
                    fieldNamelist.add(fd.getName());
                }
            }
        }
        
        return fieldNamelist;
    }
    
    /*******************************************************************************************************
     * @description Update Sync Home Address and Sync Seasonal Address checkboxes in Relationship
     * @param triggerNew The list of newly updated Contacts
     * @param triggerOldMap The map of the old versions of the newly updated Contacts
     * @return N/A
     */
    private void updateChildRelationshipAddressSyncSettings(List<Contact> triggerNew, Map<Id, Contact> triggerOldMap) {
        List<ucinn_ascendv2__Relationship__c> updateRelationshipList = new List<ucinn_ascendv2__Relationship__c>();
        List<String> validChildConstituentTypeList = new List<String>{'SA','ST','RC'};
        Set<Id> contactSet = new Set<Id>();
        
        for (Contact con : triggerNew) {
            if ( (con.ucinn_ascendv2__Contact_Type__c != triggerOldMap.get(con.Id).ucinn_ascendv2__Contact_Type__c) ) {
                List<String> newcontypes = (con.ucinn_ascendv2__Contact_Type__c+'').split(';');
                List<String> oldcontypes = (triggerOldMap.get(con.Id).ucinn_ascendv2__Contact_Type__c+'').split(';');
                List<String> allcontypes = new List<String>();
                
                allcontypes.addAll(newcontypes);
                allcontypes.addAll(oldcontypes);
                
                for (String t : allcontypes) {
                    if (validChildConstituentTypeList.contains(t)) {
                        contactSet.add(con.Id);
                    }
                }
            }
        }
        
        if (!contactSet.isEmpty()) {
            for (ucinn_ascendv2__Relationship__c rel : [Select Id, nd_Do_Not_Sync_Home_Address__c, nd_Do_Not_Sync_Seasonal_Address__c, ucinn_ascendv2__Related_Contact__r.ucinn_ascendv2__Contact_Type__c 
                    From ucinn_ascendv2__Relationship__c Where ucinn_ascendv2__Related_Contact__c In :contactSet And ucinn_ascendv2__Related_Contact_Role__c = 'Child']) {
                
                List<String> contypes = (rel.ucinn_ascendv2__Related_Contact__r.ucinn_ascendv2__Contact_Type__c+'').split(';');
                Boolean hasValidType = false;
                Boolean hasChanges = false;
                Boolean oldSyncHomeAddress = rel.nd_Do_Not_Sync_Home_Address__c;
                Boolean oldSyncSeasonalAddress = rel.nd_Do_Not_Sync_Seasonal_Address__c;
                
                for (String t : contypes) {
                    if (validChildConstituentTypeList.contains(t)) {
                        hasValidType = true;
                    }
                }
                
                rel.nd_Do_Not_Sync_Home_Address__c = !hasValidType;
                rel.nd_Do_Not_Sync_Seasonal_Address__c = !hasValidType;
                
                if (rel.nd_Do_Not_Sync_Home_Address__c != oldSyncHomeAddress || rel.nd_Do_Not_Sync_Seasonal_Address__c != oldSyncSeasonalAddress) {
                    hasChanges = true;
                }
                
                if (hasChanges) {
                    updateRelationshipList.add(rel);
                }
            }
            
            if (!updateRelationshipList.isEmpty()) {
                update updateRelationshipList;
            }
        }
    }

    /*******************************************************************************************************
     * @description Copy Wealth Assets on Unmerge
     * @param triggerNew The list of newly updated Contacts
     * @param triggerOldMap The map of the old versions of the newly updated Contacts
     * @return N/A
     */
    private void copyWealthAssetsOnHouseholdUnmerge(List<Contact> triggerNew, Map<Id, Contact> triggerOldMap) {
        List<Wealth_Asset__c> wealthAssetsToInsert = new List<Wealth_Asset__c>();
        List<Wealth_Asset__c> wealthAssetsToUpdate = new List<Wealth_Asset__c>();
        List<String> filteredRoles = new List<String>{'Divorced Spouse', 'Former Spouse', 'Former Partner/Significant Other', 'Ex-Spouse', 'DD'};

        Map<Id, Id> contactOldAccountMap = new Map<Id, Id>();
        Map<Id, Id> accountsToCopyWealthAssetsFromToMap = new Map<Id, Id>();
        List<Id> accountIdsToCopyWealthAssetsFrom = new List<Id>();
        List<Id> accountIdsToCopyWealthAssetsTo = new List<Id>();
        Set<Id> contactSet = new Set<Id>();
        
        for (Contact con : triggerNew) {
            if (con.AccountId != triggerOldMap.get(con.Id).AccountId) {
                contactSet.add(con.Id);
            }
        }
        
        if (contactSet.isEmpty()) {
            return;
        }
        
        for (ucinn_ascendv2__Relationship__c rel : [SELECT Id, ucinn_ascendv2__Contact__c, ucinn_ascendv2__Related_Contact__r.AccountId FROM ucinn_ascendv2__Relationship__c 
                WHERE ucinn_ascendv2__Contact__c In :contactSet AND ucinn_ascendv2__Related_Contact_Role__c IN :filteredRoles]) {
            
            contactOldAccountMap.put(rel.ucinn_ascendv2__Contact__c, rel.ucinn_ascendv2__Related_Contact__r.AccountId);
        }
        
        // Processing contacts that have changed to a new account
        for (Contact con : triggerNew) {
            Id oldAccountId = triggerOldMap.get(con.Id).AccountId;

            if (triggerOldMap.get(con.Id) == null) {
                continue;
            }
            Id oldContactAccountId = triggerOldMap.get(con.Id).AccountId;

            if (!contactOldAccountMap.containsKey(con.Id)) {
                continue;
            }

            if (con.AccountId != null &&
                oldAccountId != null &&
                con.AccountId != oldAccountId) {

                accountsToCopyWealthAssetsFromToMap.put(oldAccountId, con.AccountId);
                accountIdsToCopyWealthAssetsFrom.add(oldAccountId);
                accountIdsToCopyWealthAssetsTo.add(con.AccountId);
            }
        }

        if (accountsToCopyWealthAssetsFromToMap.size() == 0) {
            return;
        }

        // Filtering for household accounts and querying records
        Id householdRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        List<Account> accountsToCopyWealthAssetsFrom = [SELECT Id 
                                                        FROM Account 
                                                        WHERE Id IN :accountIdsToCopyWealthAssetsFrom AND
                                                              RecordTypeId = :householdRecordId]; // Filter for only households
        List<Account> accountsToCopyWealthAssetsTo = [SELECT Id, CreatedDate, ucinn_ascendv2__Number_of_Household_Members__c
                                                      FROM Account 
                                                      WHERE Id IN :accountIdsToCopyWealthAssetsTo AND
                                                            RecordTypeId = :householdRecordId];

        Map<Id, Account> accountsToCopyWealthAssetsToMap = new Map<Id, Account>();
        for (Account accTo : accountsToCopyWealthAssetsTo) {
            accountsToCopyWealthAssetsToMap.put(accTo.Id, accTo);
        }

        // Querying Wealth Assets
        List<String> wealthAssetFields = new List<String>(Wealth_Asset__c.SObjectType.getDescribe().fields.getMap().keySet());
        String wealthAssetQuery = 'SELECT ' + String.join(wealthAssetFields, ',') + 
                                ' FROM Wealth_Asset__c' +
                                ' WHERE Organization__c IN :accountsToCopyWealthAssetsFrom';
        List<Wealth_Asset__c> allWealthAssetsToCopy = Database.query(wealthAssetQuery);

        Map<Id, List<Wealth_Asset__c>> oldAccIdToWealthAssetListMap = new Map<Id, List<Wealth_Asset__c>>();
        for (Wealth_Asset__c wc : allWealthAssetsToCopy) {
            if (!oldAccIdToWealthAssetListMap.containsKey(wc.Organization__c)) {
                oldAccIdToWealthAssetListMap.put(wc.Organization__c, new List<Wealth_Asset__c>());
            }
            oldAccIdToWealthAssetListMap.get(wc.Organization__c).add(wc);
        }
        
        // Copy wealth assets from old household to new
        for (Account accFrom : accountsToCopyWealthAssetsFrom) {

            Id accountIdToCopyTo = accountsToCopyWealthAssetsFromToMap.get(accFrom.Id);
            Account accountToCopyTo = accountsToCopyWealthAssetsToMap.get(accountIdToCopyTo);

            if (accountToCopyTo != null) {

                // Querying Wealth Assets
                List<Wealth_Asset__c> wealthAssetsToCopy = oldAccIdToWealthAssetListMap.get(accFrom.Id);
                if (wealthAssetsToCopy == null || wealthAssetsToCopy.size() == 0) {
                    continue;
                }

                // Checks to prevent operation on user created households, direct linkage was lost due to this trigger operating based off non overridable code logic
                // As a result we need to use heuristics to determine validity
                    // Add accounts created only recently
                Long accountToCopyToDTLong = accountToCopyTo.CreatedDate.getTime();
                Long currentDTLong = Datetime.now().getTime();
                if (currentDTLong - accountToCopyToDTLong > 30000) {
                    continue;
                }

                    // Omit any accounts that have more than one member
                if (accountToCopyTo.ucinn_ascendv2__Number_of_Household_Members__c > 1) {
                    continue;
                }

                for (Wealth_Asset__c wa : wealthAssetsToCopy) {
                    // Copying and updating status of new wealth asset
                    Wealth_Asset__c copiedWA = wa.clone(false, true);
                    copiedWA.Organization__c = accountToCopyTo.Id;
                    copiedWA.Status__c = 'Review';
                    wealthAssetsToInsert.add(copiedWA);

                    // Update old wealth asset status
                    wa.Status__c = 'Review';
                    wealthAssetsToUpdate.add(wa);
                }
            
            }

        }

        if (wealthAssetsToInsert != null) {
            insert wealthAssetsToInsert;
        }
        if (wealthAssetsToUpdate != null) {
            update wealthAssetsToUpdate;
        }
             
    }
    
    /*******************************************************************************************************
     * @description Method to update marital status and salutation preference
     * @param triggerNew The list of newly updated Contacts
     * @param triggerOldMap The map of the old versions of the newly updated Contacts
     * @return N/A
     */
    private void updateMaritalStatusAndSalutationPreference(List<Contact> triggerNew, Map<Id, Contact> triggerOldMap) {
        for (Contact con : triggerNew) {
            if (Trigger.isInsert || (Trigger.isUpdate && (con.nd_Partner_Significant_Other__c != triggerOldMap.get(con.Id).nd_Partner_Significant_Other__c
                    || con.ucinn_ascendv2__Preferred_Spouse__c != triggerOldMap.get(con.Id).ucinn_ascendv2__Preferred_Spouse__c) ) ) {
                        
                if (con.nd_Partner_Significant_Other__c != null) {
                    con.ucinn_ascendv2__Marital_Status__c = 'P';
                    con.ucinn_ascendv2__Salutation_Preference__c = 'Joint';
                } else if (con.ucinn_ascendv2__Preferred_Spouse__c == null && con.ucinn_ascendv2__Marital_Status__c != 'Widowed') {
                    con.ucinn_ascendv2__Marital_Status__c = 'S';
                    con.ucinn_ascendv2__Salutation_Preference__c = 'Individual';
                }
            }
        }
    }
    
    /*******************************************************************************************************
     * @description Method to sync salutation preference to spouse or partner
     * @param triggerNew The list of newly updated Contacts
     * @param triggerOldMap The map of the old versions of the newly updated Contacts
     * @return N/A
     */
    private void syncMaritalStatusAndSalutationPreference(List<Contact> triggerNew, Map<Id, Contact> triggerOldMap) {
        if (!canInvokeSyncMaritalStatusAndSalutationPreference) {
            return;
        }
        
        Map<Id, Contact> updateContactMap = new Map<Id, Contact>();
        Map<Id, Contact> triggerNewMap = new Map<Id, Contact>();
        for (Contact con : triggerNew) {
            triggerNewMap.put(con.Id, con);
        }
        
        for (Contact con : triggerNew) {
            // clin 12/20/2023 - Fix for Too Many SOQL 101 issue within ascend and prevent unnecessary update
            // clin 12/20/2023 - This logic should only run if there is a change to ucinn_ascendv2__Marital_Status__c or ucinn_ascendv2__Salutation_Preference__c
            // clin 12/20/2023 - prior if condition is running logic every time there is a ucinn_ascendv2__Preferred_Spouse__c or nd_Partner_Significant_Other__c
            /* if ( con.ucinn_ascendv2__Preferred_Spouse__c != null || con.nd_Partner_Significant_Other__c != null 
                    && (con.ucinn_ascendv2__Marital_Status__c != triggerOldMap.get(con.Id).ucinn_ascendv2__Marital_Status__c
                        || con.ucinn_ascendv2__Salutation_Preference__c != triggerOldMap.get(con.Id).ucinn_ascendv2__Salutation_Preference__c) ) { */
            if ( (con.ucinn_ascendv2__Preferred_Spouse__c != null || con.nd_Partner_Significant_Other__c != null) 
                    && (con.ucinn_ascendv2__Marital_Status__c != triggerOldMap.get(con.Id).ucinn_ascendv2__Marital_Status__c
                        || con.ucinn_ascendv2__Salutation_Preference__c != triggerOldMap.get(con.Id).ucinn_ascendv2__Salutation_Preference__c) ) {
                if (con.ucinn_ascendv2__Preferred_Spouse__c != null) {
                    if (triggerNewMap.containsKey(con.ucinn_ascendv2__Preferred_Spouse__c)) {
                        Contact curcon = triggerNewMap.get(con.ucinn_ascendv2__Preferred_Spouse__c);
                        curcon.ucinn_ascendv2__Salutation_Preference__c = con.ucinn_ascendv2__Salutation_Preference__c;
                    } else {
                        Contact updcon = new Contact(Id = con.ucinn_ascendv2__Preferred_Spouse__c);
                        updcon.ucinn_ascendv2__Salutation_Preference__c = con.ucinn_ascendv2__Salutation_Preference__c;
                        updateContactMap.put(updcon.Id, updcon);
                    }
                }
                
                if (con.nd_Partner_Significant_Other__c != null) {
                    if (triggerNewMap.containsKey(con.nd_Partner_Significant_Other__c)) {
                        Contact curcon = triggerNewMap.get(con.nd_Partner_Significant_Other__c);
                        if (curcon.nd_Partner_Significant_Other__c != null) {
                            curcon.ucinn_ascendv2__Marital_Status__c = con.ucinn_ascendv2__Marital_Status__c;
                            curcon.ucinn_ascendv2__Salutation_Preference__c = con.ucinn_ascendv2__Salutation_Preference__c;
                        }
                        
                    } else {
                        Contact updcon = new Contact(Id = con.nd_Partner_Significant_Other__c);
                        //if (updcon.nd_Partner_Significant_Other__c != null) {
                        updcon.ucinn_ascendv2__Marital_Status__c = con.ucinn_ascendv2__Marital_Status__c;
                        updcon.ucinn_ascendv2__Salutation_Preference__c = con.ucinn_ascendv2__Salutation_Preference__c;
                        updateContactMap.put(updcon.Id, updcon);
                        //}
                    }
                }
            }
        }
        
        if (!updateContactMap.isEmpty()) {
            ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger('Contact', false);
            update updateContactMap.values();
            ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger('Contact', true);
        }
    }
}