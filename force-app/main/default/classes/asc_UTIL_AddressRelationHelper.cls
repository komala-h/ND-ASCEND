/**
 * @author Sulung Chandra, UC Innovation
 * @date 9/2/2020
 * @group Helpers
 * @description Helper class for evaluate the Address Relation
 */
public with sharing class asc_UTIL_AddressRelationHelper {
    public static Map<Id, Map<String, String>> contactPreviousPreferredMap;

    /*******************************************************************************************************
     * @description Method run to collect previous contact address relations
     * @param contactSet Set of contact Ids
     */
    public static void collectContactPreviousPreferredMap(Set<Id> contactSet) {
        contactPreviousPreferredMap = new Map<Id, Map<String, String>>();  // Map<Contact Id, Map of Params>
        
        for (ucinn_ascendv2__Relationship__c rel : [Select nd_Do_Not_Sync_Home_Address__c, nd_Do_Not_Sync_Seasonal_Address__c, ucinn_ascendv2__Contact__c, ucinn_ascendv2__Related_Contact__c 
                From ucinn_ascendv2__Relationship__c Where (ucinn_ascendv2__Contact__c In :contactSet Or ucinn_ascendv2__Related_Contact__c In :contactSet)]) {
                    
            contactSet.add(rel.ucinn_ascendv2__Contact__c);
            contactSet.add(rel.ucinn_ascendv2__Related_Contact__c);
        }
        
        for (ucinn_ascendv2__Address_Relation__c addrel : [Select Id, ucinn_ascendv2__Contact__c, ucinn_ascendv2__Status__c, ucinn_ascendv2__Type__c, ucinn_ascendv2__Address__c
                From ucinn_ascendv2__Address_Relation__c Where ucinn_ascendv2__Contact__c In :contactSet And ucinn_ascendv2__Is_Preferred__c = True]) {
            
            String keyname = getAddressRelationKeyname(addrel.ucinn_ascendv2__Status__c, addrel.ucinn_ascendv2__Type__c, addrel.ucinn_ascendv2__Address__c);
            contactPreviousPreferredMap.put(addrel.ucinn_ascendv2__Contact__c, new Map<String, String>());
            contactPreviousPreferredMap.get(addrel.ucinn_ascendv2__Contact__c).put('Keyname', keyname);
            contactPreviousPreferredMap.get(addrel.ucinn_ascendv2__Contact__c).put('AddressType', addrel.ucinn_ascendv2__Type__c);
        }
    }

    /*******************************************************************************************************
     * @description Method run to sync the address relations
     * @param addrelList List of Address Relation records
     * @param matchkeyMap Map of Address Relation record and the keyname
     * @param contactSet Set of Contact Ids to evaluate. If Null, collect it from addrelList
     * @param allowPreferredToSync Allow Preferred flag to sync
     * @return keyname
     */
    public static void syncAddressRelations(List<ucinn_ascendv2__Address_Relation__c> addrelList, Map<Id, String> matchkeyMap, Set<Id> contactSet, Boolean allowPreferredToSync) {
        List<ucinn_ascendv2__Address_Relation__c> addrelListToUpsert = new List<ucinn_ascendv2__Address_Relation__c>();
        Map<Id, ucinn_ascendv2__Address_Relation__c> addrelMapToUpsert = new Map<Id, ucinn_ascendv2__Address_Relation__c>(); // added to prevent duplicate error
        Map<String, ucinn_ascendv2__Address_Relation__c> addrelMapToInsert = new Map<String, ucinn_ascendv2__Address_Relation__c>();
        Map<String, Map<Id, List<ucinn_ascendv2__Address_Relation__c>>> matchingrelatedaddrelMap = new Map<String, Map<Id, List<ucinn_ascendv2__Address_Relation__c>>>();  //Map<Keyname, Map<ContactId, List<Address Relation>>>
        Map<Id, Set<Id>> relatedContactMap = new Map<Id, Set<Id>>();
        Set<Id> contactAndSpouseSet = new Set<Id>();
        Set<String> contactWithSyncHomeAddress = new Set<String>();
        Set<String> contactWithSyncSeasonalAddress = new Set<String>();
        List<String> validSpouseRelationshipRoleList = new List<String>{'Spouse','Partner/Significant Other'}; // clin Added on 09/19/2023 for W-001207: limit syncAddressRelations to only spouses/partner/so to avoid Too Many SOQL 101 Error
        
        if (contactPreviousPreferredMap == null) {
            contactPreviousPreferredMap = new Map<Id, Map<String, String>>();
        }
        
        if (!addrelList.isEmpty()) {
            
            // Collect contact Ids
            if (contactSet == null) {
                contactSet = new Set<Id>();
                
                for (ucinn_ascendv2__Address_Relation__c addrel : addrelList) {
                    if (addrel.ucinn_ascendv2__Contact__c != null) {
                        contactSet.add(addrel.ucinn_ascendv2__Contact__c);
                    }
                }
            }
            
            // Collect sync mapping setting
            // clin Updated SOQL where clause filter on 09/19/2023 for W-001207: limit syncAddressRelations to only spouses/partner/so to avoid Too Many SOQL 101 Error
            for (ucinn_ascendv2__Relationship__c rel : [Select nd_Do_Not_Sync_Home_Address__c, nd_Do_Not_Sync_Seasonal_Address__c, ucinn_ascendv2__Contact__c, ucinn_ascendv2__Related_Contact__c 
                    From ucinn_ascendv2__Relationship__c Where ucinn_ascendv2__Contact__c In :contactSet And (nd_Do_Not_Sync_Home_Address__c = false Or nd_Do_Not_Sync_Seasonal_Address__c = false) 
                                                                AND ucinn_ascendv2__Related_Contact_Role__c IN :validSpouseRelationshipRoleList]) {
                
                contactAndSpouseSet.add(rel.ucinn_ascendv2__Contact__c);
                contactAndSpouseSet.add(rel.ucinn_ascendv2__Related_Contact__c);
                        
                if (!relatedContactMap.containsKey(rel.ucinn_ascendv2__Contact__c)) {
                    relatedContactMap.put(rel.ucinn_ascendv2__Contact__c, new Set<Id>());
                }
                
                if (!rel.nd_Do_Not_Sync_Home_Address__c) {
                    relatedContactMap.get(rel.ucinn_ascendv2__Contact__c).add(rel.ucinn_ascendv2__Related_Contact__c);
                    contactWithSyncHomeAddress.add(getRelationshipKeyname(rel.ucinn_ascendv2__Contact__c, rel.ucinn_ascendv2__Related_Contact__c));
                    contactWithSyncHomeAddress.add(getRelationshipKeyname(rel.ucinn_ascendv2__Related_Contact__c, rel.ucinn_ascendv2__Contact__c));
                }
                if (!rel.nd_Do_Not_Sync_Seasonal_Address__c) {
                    relatedContactMap.get(rel.ucinn_ascendv2__Contact__c).add(rel.ucinn_ascendv2__Related_Contact__c);
                    contactWithSyncSeasonalAddress.add(getRelationshipKeyname(rel.ucinn_ascendv2__Contact__c, rel.ucinn_ascendv2__Related_Contact__c));
                    contactWithSyncSeasonalAddress.add(getRelationshipKeyname(rel.ucinn_ascendv2__Related_Contact__c, rel.ucinn_ascendv2__Contact__c));
                }
            }
            
            //Collect matching address relations
            for (ucinn_ascendv2__Address_Relation__c relatedaddrel : [Select Id, ucinn_ascendv2__Contact__c, ucinn_ascendv2__Contact__r.AccountId, ucinn_ascendv2__Status__c, ucinn_ascendv2__Type__c, 
                    ucinn_ascendv2__Address__c, ucinn_ascendv2__Data_Source__c, ucinn_ascendv2__End_Date__c, ucinn_ascendv2__In_Care_Of__c,
                    ucinn_ascendv2__Is_Preferred__c, ucinn_ascendv2__Seasonal_End_Day__c, ucinn_ascendv2__Seasonal_End_Month__c,
                    ucinn_ascendv2__Seasonal_End_Year__c, ucinn_ascendv2__Seasonal_Start_Day__c, ucinn_ascendv2__Seasonal_Start_Month__c,
                    ucinn_ascendv2__Seasonal_Start_Year__c, ucinn_ascendv2__Source__c, ucinn_ascendv2__Start_Date__c
                    From ucinn_ascendv2__Address_Relation__c Where ucinn_ascendv2__Contact__c In :contactAndSpouseSet]) {
                String keyname = getAddressRelationKeyname(relatedaddrel.ucinn_ascendv2__Status__c, relatedaddrel.ucinn_ascendv2__Type__c, relatedaddrel.ucinn_ascendv2__Address__c);
                
                if(!matchingrelatedaddrelMap.containsKey(keyname)) {
                    matchingrelatedaddrelMap.put(keyname, new Map<Id, List<ucinn_ascendv2__Address_Relation__c>>());
                }
                if(!matchingrelatedaddrelMap.get(keyname).containsKey(relatedaddrel.ucinn_ascendv2__Contact__c)) {
                    matchingrelatedaddrelMap.get(keyname).put(relatedaddrel.ucinn_ascendv2__Contact__c, new List<ucinn_ascendv2__Address_Relation__c>());
                }
                matchingrelatedaddrelMap.get(keyname).get(relatedaddrel.ucinn_ascendv2__Contact__c).add(relatedaddrel);
            }
            
            //Collect records to insert and update
            for(ucinn_ascendv2__Address_Relation__c addrel : addrelList) {
                String keyname = matchkeyMap.get(addrel.Id);
                
                if (!relatedContactMap.containsKey(addrel.ucinn_ascendv2__Contact__c)) {
                    continue;
                }
                
                //Collect inserts and updates
                for(Id contactId : relatedContactMap.get(addrel.ucinn_ascendv2__Contact__c)) {
                    ucinn_ascendv2__Address_Relation__c matchedaddrel = null;
                    String keynamecontact = keyname + '_' + String.valueOf(contactId);      //This is used to prevent duplicate record creation
                    String relkeyname = getRelationshipKeyname(addrel.ucinn_ascendv2__Contact__c, contactId);
                    Boolean hasChanges = false;
                    Boolean syncPreferred = false;
                    Boolean canSync = false;
                    
                    // Skip if there is no sync checked for the relationship
                    if ( ((addrel.ucinn_ascendv2__Type__c == 'H') && contactWithSyncHomeAddress.contains(relkeyname)) || 
                            (addrel.ucinn_ascendv2__Type__c == 'Seasonal' && contactWithSyncSeasonalAddress.contains(relkeyname)) ) {
                        canSync = true;
                    }
                    
                    if (!canSync) {
                        continue;
                    }
                    
                    // Check if preferred can be synced
                    if (contactPreviousPreferredMap.containsKey(addrel.ucinn_ascendv2__Contact__c) && contactPreviousPreferredMap.containsKey(contactId)) {
                        String contactAddressType = contactPreviousPreferredMap.get(addrel.ucinn_ascendv2__Contact__c).get('AddressType');
                        String relatedContactAddressType = contactPreviousPreferredMap.get(contactId).get('AddressType');
                        
                        System.debug('#### contactAddressType: '+contactAddressType);
                        System.debug('#### relatedContactAddressType: '+relatedContactAddressType);
                        
                        if (contactAddressType == relatedContactAddressType) {
                            syncPreferred = true;
                        }
                    } else if (!contactPreviousPreferredMap.containsKey(addrel.ucinn_ascendv2__Contact__c) && !contactPreviousPreferredMap.containsKey(contactId)) {
                        syncPreferred = true;
                    }
                    
                    System.debug('#### syncPreferred: '+syncPreferred);
                    System.debug('#### contactPreviousPreferredMap: '+contactPreviousPreferredMap);
                    System.debug('#### contactPreviousPreferredMap.containsKey(addrel.ucinn_ascendv2__Contact__c): '+contactPreviousPreferredMap.containsKey(addrel.ucinn_ascendv2__Contact__c));
                    System.debug('#### contactPreviousPreferredMap.containsKey(contactId): '+contactPreviousPreferredMap.containsKey(contactId));
                    
                    //if (contactPreviousPreferredMap.containsKey(addrel.ucinn_ascendv2__Contact__c) && contactPreviousPreferredMap.containsKey(contactId)) {
                    //    String contactKeyname = contactPreviousPreferredMap.get(addrel.ucinn_ascendv2__Contact__c).get('Keyname');
                    //    String relatedContactKeyname = contactPreviousPreferredMap.get(contactId).get('Keyname');
                    //    
                    //    if (contactKeyname == relatedContactKeyname) {
                    //        syncPreferred = true;
                    //    }
                    //} else if (!contactPreviousPreferredMap.containsKey(addrel.ucinn_ascendv2__Contact__c) && !contactPreviousPreferredMap.containsKey(contactId)) {
                    //    syncPreferred = true;
                    //}
                    
                    if (!allowPreferredToSync) {
                        syncPreferred = false;
                    }
                    
                    if (matchingrelatedaddrelMap.containsKey(keyname)) {
                        if (matchingrelatedaddrelMap.get(keyname).containsKey(contactId)) {
                            if (!matchingrelatedaddrelMap.get(keyname).get(contactId).isEmpty()) {
                                matchedaddrel = matchingrelatedaddrelMap.get(keyname).get(contactId)[0];
                            }
                        }
                    }
                    
                    if (matchedaddrel != null) {         //Match found, update
                        if (matchedaddrel.ucinn_ascendv2__Data_Source__c != addrel.ucinn_ascendv2__Data_Source__c ||
                            matchedaddrel.ucinn_ascendv2__End_Date__c != addrel.ucinn_ascendv2__End_Date__c ||
                            matchedaddrel.ucinn_ascendv2__In_Care_Of__c != addrel.ucinn_ascendv2__In_Care_Of__c ||
                            matchedaddrel.ucinn_ascendv2__Is_Preferred__c != addrel.ucinn_ascendv2__Is_Preferred__c ||
                            matchedaddrel.ucinn_ascendv2__Seasonal_End_Day__c != addrel.ucinn_ascendv2__Seasonal_End_Day__c ||
                            matchedaddrel.ucinn_ascendv2__Seasonal_End_Month__c != addrel.ucinn_ascendv2__Seasonal_End_Month__c ||
                            matchedaddrel.ucinn_ascendv2__Seasonal_End_Year__c != addrel.ucinn_ascendv2__Seasonal_End_Year__c ||
                            matchedaddrel.ucinn_ascendv2__Seasonal_Start_Day__c != addrel.ucinn_ascendv2__Seasonal_Start_Day__c ||
                            matchedaddrel.ucinn_ascendv2__Seasonal_Start_Month__c != addrel.ucinn_ascendv2__Seasonal_Start_Month__c ||
                            matchedaddrel.ucinn_ascendv2__Seasonal_Start_Year__c != addrel.ucinn_ascendv2__Seasonal_Start_Year__c ||
                            matchedaddrel.ucinn_ascendv2__Source__c != addrel.ucinn_ascendv2__Source__c ||
                            matchedaddrel.ucinn_ascendv2__Start_Date__c != addrel.ucinn_ascendv2__Start_Date__c ||
                            matchedaddrel.ucinn_ascendv2__Status__c != addrel.ucinn_ascendv2__Status__c ||
                            matchedaddrel.ucinn_ascendv2__Type__c != addrel.ucinn_ascendv2__Type__c ||
                            matchedaddrel.ucinn_ascendv2__Address__c != addrel.ucinn_ascendv2__Address__c) {
                            hasChanges = true;
                        }
                        
                        if (hasChanges) {
                            matchedaddrel.ucinn_ascendv2__Data_Source__c = addrel.ucinn_ascendv2__Data_Source__c;    
                            matchedaddrel.ucinn_ascendv2__End_Date__c = addrel.ucinn_ascendv2__End_Date__c;
                            matchedaddrel.ucinn_ascendv2__In_Care_Of__c = addrel.ucinn_ascendv2__In_Care_Of__c;
                            matchedaddrel.ucinn_ascendv2__Seasonal_End_Day__c = addrel.ucinn_ascendv2__Seasonal_End_Day__c;
                            matchedaddrel.ucinn_ascendv2__Seasonal_End_Month__c = addrel.ucinn_ascendv2__Seasonal_End_Month__c;
                            matchedaddrel.ucinn_ascendv2__Seasonal_End_Year__c = addrel.ucinn_ascendv2__Seasonal_End_Year__c;
                            matchedaddrel.ucinn_ascendv2__Seasonal_Start_Day__c = addrel.ucinn_ascendv2__Seasonal_Start_Day__c;
                            matchedaddrel.ucinn_ascendv2__Seasonal_Start_Month__c = addrel.ucinn_ascendv2__Seasonal_Start_Month__c;
                            matchedaddrel.ucinn_ascendv2__Seasonal_Start_Year__c = addrel.ucinn_ascendv2__Seasonal_Start_Year__c;    
                            matchedaddrel.ucinn_ascendv2__Source__c = addrel.ucinn_ascendv2__Source__c;
                            matchedaddrel.ucinn_ascendv2__Start_Date__c = addrel.ucinn_ascendv2__Start_Date__c;
                            matchedaddrel.ucinn_ascendv2__Status__c = addrel.ucinn_ascendv2__Status__c;
                            matchedaddrel.ucinn_ascendv2__Type__c = addrel.ucinn_ascendv2__Type__c; 
                            matchedaddrel.ucinn_ascendv2__Address__c = addrel.ucinn_ascendv2__Address__c; 
                            
                            if (syncPreferred) {
                                matchedaddrel.ucinn_ascendv2__Is_Preferred__c = addrel.ucinn_ascendv2__Is_Preferred__c;
                            }
                            if (matchedaddrel.ucinn_ascendv2__Status__c == 'Former') {
                                matchedaddrel.ucinn_ascendv2__Is_Preferred__c = false;
                            }
                            
                            addrelMapToUpsert.put(matchedaddrel.Id, matchedaddrel); // changed to a map to prevent duplicate error
                        }
                    } else if (matchedaddrel == null) {  //No match found, insert
                        if (!addrelMapToInsert.containsKey(keynamecontact)) {
                            ucinn_ascendv2__Address_Relation__c newaddrel = new ucinn_ascendv2__Address_Relation__c();
                            newaddrel.RecordTypeId = addrel.RecordTypeId;
                            //newaddrel.ucinn_ascendv2__Account__c = addrel.ucinn_ascendv2__Account__c;
                            newaddrel.ucinn_ascendv2__Address__c = addrel.ucinn_ascendv2__Address__c;
                            newaddrel.ucinn_ascendv2__Contact__c = contactId;
                            newaddrel.ucinn_ascendv2__Data_Source__c = addrel.ucinn_ascendv2__Data_Source__c;    
                            newaddrel.ucinn_ascendv2__End_Date__c = addrel.ucinn_ascendv2__End_Date__c;
                            newaddrel.ucinn_ascendv2__In_Care_Of__c = addrel.ucinn_ascendv2__In_Care_Of__c;
                            newaddrel.ucinn_ascendv2__Seasonal_End_Day__c = addrel.ucinn_ascendv2__Seasonal_End_Day__c;
                            newaddrel.ucinn_ascendv2__Seasonal_End_Month__c = addrel.ucinn_ascendv2__Seasonal_End_Month__c;
                            newaddrel.ucinn_ascendv2__Seasonal_End_Year__c = addrel.ucinn_ascendv2__Seasonal_End_Year__c;
                            newaddrel.ucinn_ascendv2__Seasonal_Start_Day__c = addrel.ucinn_ascendv2__Seasonal_Start_Day__c;
                            newaddrel.ucinn_ascendv2__Seasonal_Start_Month__c = addrel.ucinn_ascendv2__Seasonal_Start_Month__c;
                            newaddrel.ucinn_ascendv2__Seasonal_Start_Year__c = addrel.ucinn_ascendv2__Seasonal_Start_Year__c;    
                            newaddrel.ucinn_ascendv2__Source__c = addrel.ucinn_ascendv2__Source__c;
                            newaddrel.ucinn_ascendv2__Start_Date__c = addrel.ucinn_ascendv2__Start_Date__c;
                            newaddrel.ucinn_ascendv2__Status__c = addrel.ucinn_ascendv2__Status__c;
                            newaddrel.ucinn_ascendv2__Type__c = addrel.ucinn_ascendv2__Type__c;
                            
                            if (syncPreferred) {
                                newaddrel.ucinn_ascendv2__Is_Preferred__c = addrel.ucinn_ascendv2__Is_Preferred__c;
                            } else {
                                
                                // If there is already a Preferred address of the same Type, set the new one to Preferred
                                // The previous address of the same Type will be deactivated and Preferred will be set to false by the "Disable Multiple Current Types" handler.
                                //if (contactPreviousPreferredMap.containsKey(newaddrel.ucinn_ascendv2__Contact__c)) {
                                //    String previousPreferredAddressType = contactPreviousPreferredMap.get(newaddrel.ucinn_ascendv2__Contact__c).get('AddressType');
                                //    if (previousPreferredAddressType == newaddrel.ucinn_ascendv2__Type__c) {
                                //        newaddrel.ucinn_ascendv2__Is_Preferred__c = true;
                                //    }
                                //}
                                
                            }
                            if (newaddrel.ucinn_ascendv2__Status__c == 'Former') {
                                newaddrel.ucinn_ascendv2__Is_Preferred__c = false;
                            }
                            
                            addrelMapToInsert.put(keynamecontact, newaddrel);
                        }
                    }
                }
            }

            // add the values from addrelMapToUpsert to the addrelListToUpsert to prevent duplicate error
            if (!addrelMapToUpsert.isEmpty()) {
                addrelListToUpsert.addAll(addrelMapToUpsert.values());
            }
            
            if (!addrelMapToInsert.isEmpty()) {
                addrelListToUpsert.addAll(addrelMapToInsert.values());
            }

            If (!addrelListToUpsert.isEmpty()) {
                //ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger('ucinn_ascendv2__Address_Relation__c', false);
                asc_TRIG_AddressRelationHandler.canInvokeSyncAddressRelations = false; // clin 12/20/2023 - Avoid recursive issue when syncing address relation records between spouses/partners
                upsert addrelListToUpsert;
                asc_TRIG_AddressRelationHandler.canInvokeSyncAddressRelations = true; // clin 12/20/2023 - Avoid recursive issue when syncing address relation records between spouses/partners
                //ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger('ucinn_ascendv2__Address_Relation__c', true);
            }
        }
    }
    
    /*******************************************************************************************************
     * @description Method run to delete synced address relations
     * @param addrelList List of Address Relation records
     * @param matchkeyMap Map of Address Relation record and the keyname
     * @return keyname
     */
    public static void deleteSyncedAddressRelations(List<ucinn_ascendv2__Address_Relation__c> addrelList, Map<Id, String> matchkeyMap) {
        List<ucinn_ascendv2__Address_Relation__c> addrelListToDelete = new List<ucinn_ascendv2__Address_Relation__c>();
        Map<String, List<ucinn_ascendv2__Address_Relation__c>> matchingrelatedaddrelMap = new Map<String, List<ucinn_ascendv2__Address_Relation__c>>();  //Map<Keyname, List<Address Relation>>
        Set<Id> contactSet = new Set<Id>();
        Set<String> contactWithSyncHomeAddress = new Set<String>();
        Set<String> contactWithSyncSeasonalAddress = new Set<String>();
        
        if (!addrelList.isEmpty()) {
            
            // Collect keyname and contact Ids
            for (ucinn_ascendv2__Address_Relation__c addrel : addrelList) {
                if (addrel.ucinn_ascendv2__Contact__c != null) {
                    contactSet.add(addrel.ucinn_ascendv2__Contact__c);
                }
            }
            
            // Collect sync mapping setting
            for (ucinn_ascendv2__Relationship__c rel : [Select nd_Do_Not_Sync_Home_Address__c, nd_Do_Not_Sync_Seasonal_Address__c, ucinn_ascendv2__Contact__c, ucinn_ascendv2__Related_Contact__c 
                    From ucinn_ascendv2__Relationship__c Where (ucinn_ascendv2__Contact__c In :contactSet Or ucinn_ascendv2__Related_Contact__c In :contactSet)
                    And (nd_Do_Not_Sync_Home_Address__c = false Or nd_Do_Not_Sync_Seasonal_Address__c = false)]) {
                
                contactSet.add(rel.ucinn_ascendv2__Contact__c);
                contactSet.add(rel.ucinn_ascendv2__Related_Contact__c);
                        
                if (!rel.nd_Do_Not_Sync_Home_Address__c) {
                    contactWithSyncHomeAddress.add(getRelationshipKeyname(rel.ucinn_ascendv2__Contact__c, rel.ucinn_ascendv2__Related_Contact__c));
                    contactWithSyncHomeAddress.add(getRelationshipKeyname(rel.ucinn_ascendv2__Related_Contact__c, rel.ucinn_ascendv2__Contact__c));
                }
                if (!rel.nd_Do_Not_Sync_Seasonal_Address__c) {
                    contactWithSyncSeasonalAddress.add(getRelationshipKeyname(rel.ucinn_ascendv2__Contact__c, rel.ucinn_ascendv2__Related_Contact__c));
                    contactWithSyncSeasonalAddress.add(getRelationshipKeyname(rel.ucinn_ascendv2__Related_Contact__c, rel.ucinn_ascendv2__Contact__c));
                }
            }
            
            //Collect matching address relations
            for (ucinn_ascendv2__Address_Relation__c relatedaddrel : [Select Id, ucinn_ascendv2__Contact__c , ucinn_ascendv2__Status__c, ucinn_ascendv2__Type__c, ucinn_ascendv2__Address__c, 
                                                                      Update_Spouse_Address__c, Update_Household_Member_Addresses__c From ucinn_ascendv2__Address_Relation__c 
                                                                      Where Id Not In :addrelList And ucinn_ascendv2__Contact__c In :contactSet]) {
            
                String keyname = getAddressRelationKeyname(relatedaddrel.ucinn_ascendv2__Status__c, relatedaddrel.ucinn_ascendv2__Type__c, relatedaddrel.ucinn_ascendv2__Address__c);
                if(!matchingrelatedaddrelMap.containsKey(keyname)) {
                    matchingrelatedaddrelMap.put(keyname, new List<ucinn_ascendv2__Address_Relation__c>());
                }
                matchingrelatedaddrelMap.get(keyname).add(relatedaddrel);
            }
            
            //Collect records to delete
            for(ucinn_ascendv2__Address_Relation__c addrel : addrelList) {
                String keyname = matchkeyMap.get(addrel.Id);
                
                if (!matchingrelatedaddrelMap.containsKey(keyname)) {
                    continue;
                }
                
                for (ucinn_ascendv2__Address_Relation__c relatedaddrel : matchingrelatedaddrelMap.get(keyname)) {
                    String relkeyname = getRelationshipKeyname(addrel.ucinn_ascendv2__Contact__c, relatedaddrel.ucinn_ascendv2__Contact__c);
                    Boolean canSync = false;
                    
                    // Skip if there is no sync checked for the relationship
                    if ( ((addrel.ucinn_ascendv2__Type__c == 'H') && contactWithSyncHomeAddress.contains(relkeyname)) || 
                            (addrel.ucinn_ascendv2__Type__c == 'Seasonal' && contactWithSyncSeasonalAddress.contains(relkeyname)) ) {
                        canSync = true;
                    }
                    
                    if (!canSync) {
                        continue;
                    }
                    
                    addrelListToDelete.add(relatedaddrel);
                }
            }   
            
            If (!addrelListToDelete.isEmpty()) {
                delete addrelListToDelete;
            }
        }
    }
    
    /*******************************************************************************************************
     * @description Method to concatenate and get the keyname for address relation matching
     * @param statusString Status value from the Address Relation record
     * @param typeString Type value from the Address Relation record
     * @param addressString Address Id value from the Address Relation record
     * @return keyname
     */
    public static String getAddressRelationKeyname(String statusString, String typeString, String addressIdString) {
        //return String.valueOf(statusString) + '_' + String.valueOf(typeString) + '_' + String.valueOf(addressIdString);
        
        // [20210904 SC]: Having status as part of the sync key causes multiple unncessary syncing when disableMultipleCurrentByType is also enabled.
        return String.valueOf(typeString) + '_' + String.valueOf(addressIdString);
    }
    
    /*******************************************************************************************************
     * @description Method to concatenate and get the keyname for relationship matching
     * @param contactId Relationship contact Id
     * @param relatedContactId Relationship related contact Id
     * @return keyname
     */
    public static String getRelationshipKeyname(Id contactId, Id relatedContactId) {
        return String.valueOf(contactId) + '_' + String.valueOf(relatedContactId);
    }
}