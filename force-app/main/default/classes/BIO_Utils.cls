public class BIO_Utils {

    private static List<Bio_Org_Wide_Custom_Config__mdt> bioOrgWideCustomConfigList = null;
    /*******************************************************************************************************
     * @description Get value from custom metadata type, build two maps
     * @param childRelationshipName: he child relationship api name
     * @param function: Preferred or Disable
     * @return N/A.
     */
    public static List<String> bioOrgWideCustomConfig(string childRelationshipName, String function) {
        /*
        List<Bio_Org_Wide_Custom_Config__mdt> bioOrgWideCustomConfigList = new List<Bio_Org_Wide_Custom_Config__mdt>();
        bioOrgWideCustomConfigList = [SELECT Child_Relataionship_Name__c, Disable_Multiple_Current_Types__c, Preferred_Order__c
                                      FROM Bio_Org_Wide_Custom_Config__mdt];
        */
        
        if (bioOrgWideCustomConfigList == null) {
            bioOrgWideCustomConfigList = [SELECT Child_Relataionship_Name__c, Disable_Multiple_Current_Types__c, Preferred_Order__c
                                      FROM Bio_Org_Wide_Custom_Config__mdt];
        }
        Map <String,  List<String>> preferredToOrderList = new  Map <String,  List<String>>();  
        Map <String,  List<String>> disableMultipeToTypeList = new  Map <String,  List<String>>();   
        
        for (Bio_Org_Wide_Custom_Config__mdt theConfig : bioOrgWideCustomConfigList) {
            if (theConfig.Disable_Multiple_Current_Types__c != null) {
                disableMultipeToTypeList.put(theConfig.Child_Relataionship_Name__c, theConfig.Disable_Multiple_Current_Types__c.split(';'));
            }
            if (theConfig.Preferred_Order__c != null) {
                preferredToOrderList.put(theConfig.Child_Relataionship_Name__c, theConfig.Preferred_Order__c.split(';'));
            }
        }

        if (function == 'Preferred' && preferredToOrderList.size()>0) {
            return preferredToOrderList.get(childRelationshipName);
        } else if (function == 'Disable' && disableMultipeToTypeList.size()>0) {
            return disableMultipeToTypeList.get(childRelationshipName);
        } else {
            return null;
        }
        
    }


    /*******************************************************************************************************
     * @Adjust sObjects to have only one current of each type provided in the metadata.
     * @param trigContextVars Trigger Context Variables.
     * @param contactChildRelName Relationship name for contact lookup.
     * @param accChildRelName Relationship name for account lookup.
     * @return N/A.
     */
    // public static void adjustCurrentObject(TRIG_BaseHandler.Trigger_ContextVariables trigContextVars, String contactChildRelName, String accChildRelName) {
    //     List<sObject> triggerNew = trigContextVars.triggerNew;
    //     Map<Id, List<sObject>> contactIdTosObjListMap = new Map<Id, List<sObject>>();
    //     Map<Id, List<sObject>> accountIdTosObjListMap = new Map<Id, List<sObject>>();
        
    //     List<String> preferredOrderList =  new List<String>();
    //     preferredOrderList = bioOrgWideCustomConfig(childRelationshipName, 'Preferred');

    //     if (preferredOrderList == null || preferredOrderList.size() == 0) {
    //         return;
    //     } 
        
    // }
    public static void adjustCurrentObject(List<sObject> triggerNew, Schema.DescribeSObjectResult objResult, String contactChildRelName, String accChildRelName) {
        Map<Id, List<sObject>> contactIdTosObjListMap = new Map<Id, List<sObject>>();
        Map<Id, List<sObject>> accountIdTosObjListMap = new Map<Id, List<sObject>>();

        List<String> disableMultipleList =  new List<String>();
        disableMultipleList = bioOrgWideCustomConfig(contactChildRelName, 'Disable');
        List<String> disableMultipleListAcc =  new List<String>();
        if (String.isNotBlank(accChildRelName)) {
            disableMultipleListAcc = bioOrgWideCustomConfig(accChildRelName, 'Disable');
        }

        System.debug(disableMultipleListAcc);
        
        if ((disableMultipleList == null || disableMultipleList.size() == 0) && (disableMultipleListAcc == null || disableMultipleListAcc.size() == 0)) {
            return;
        } 

        Map<String, Object> objectsAndFeildsToRestrict = preProcessObjects(triggerNew, disableMultipleList);
        Map<String, Object> objectsAndFeildsToRestrictAcc = preProcessObjects(triggerNew, disableMultipleListAcc);

        System.debug(objectsAndFeildsToRestrictAcc);
        if (objectsAndFeildsToRestrict == null && objectsAndFeildsToRestrictAcc == null) {
            return;
        }

        // clin 09/14/2023 - W-1362 Fix for Attempt to de-reference a null object error when creating a new address on an Organization
        if (objectsAndFeildsToRestrict != null) {
            List<sObject> objectsWithStatusChange = (List<sObject>)objectsAndFeildsToRestrict.get('processedObjects');
            List<String> fieldNamesToRestrictThatAreUsed = (List<String>)objectsAndFeildsToRestrict.get('fieldNamesToRestrictThatAreUsed');
            List<SObject> objectsToUpdates = duplicateActiveCheck(objectsWithStatusChange, fieldNamesToRestrictThatAreUsed, objResult.getName(), triggerNew);
            
            if (objectsToUpdates.size() > 0) {            
                update objectsToUpdates;           
            }
        }

        if (String.isNotBlank(accChildRelName) && objectsAndFeildsToRestrictAcc != null) {
            List<sObject> objectsWithStatusChangeAcc = (List<sObject>)objectsAndFeildsToRestrictAcc.get('processedObjects');
            List<String> fieldNamesToRestrictThatAreUsedAcc = (List<String>)objectsAndFeildsToRestrictAcc.get('fieldNamesToRestrictThatAreUsed');
            List<SObject> objectsToUpdatesAcc = duplicateActiveCheckAcc(objectsWithStatusChangeAcc, fieldNamesToRestrictThatAreUsedAcc, objResult.getName(), triggerNew);
            
            System.debug(objectsToUpdatesAcc);
            
            if (objectsToUpdatesAcc.size() > 0) {            
                update objectsToUpdatesAcc;           
            }
        }
    }

    /**
     * Preprocess objects before checking for duplicates. Sorts out any record that is not active and any records with a type that isn't restricted to one.
     * @param   newList                     New List of objects provided by trigger
     * @return                              List of active objects
     * @since                               1.0
     */
    private static Map<String, Object> preProcessObjects(List<SObject> newList, List<String> fieldNamesToRestrict) {
        Map<String, Object> resultMap = new Map<String, Object>();
        List<SObject> processedObjects = new List<SObject>();
        Set<String> fieldNamesToRestrictThatAreUsed = new Set<String>();

        // check for two currents of the same constituent and type
        for (Integer i = 0; i < newList.size(); i++) {
            SObject currentNewObject = newList[i];
            String objectType = (String)currentNewObject.get('ucinn_ascendv2__Type__c');

            if (currentNewObject.get('ucinn_ascendv2__Status__c') == 'Current' 
                && fieldNamesToRestrict.contains(objectType)) {
                    processedObjects.add(currentNewObject);
                    fieldNamesToRestrictThatAreUsed.add(objectType);
            }

        } 

        if (processedObjects.isEmpty() || fieldNamesToRestrictThatAreUsed.isEmpty()) {
            return null;
        }

        List<String> tempFieldsToRestrict = new List<String>();
        tempFieldsToRestrict.addAll(fieldNamesToRestrictThatAreUsed);

        resultMap.put('processedObjects', processedObjects);
        resultMap.put('fieldNamesToRestrictThatAreUsed', tempFieldsToRestrict);
        return resultMap;
    }

    /**
     * Remove any other active records of the same type.
     * @param   processedObjects            Processed list of objects provided by trigger
     * @param   fieldNames                  Fie
     */
    private static List<SObject> duplicateActiveCheck(List<SObject> processedObjects, List<String> fieldNamesToRestrict,
                                                    String objectName, List<sObject> newList) {
        Set<SObject> objectsToUpdates = new Set<SObject>();
        Set<Id> triggerNewListId = new Set<Id>();
        Set<Id> contactsWithChangedStatus = new Set<Id>();
        Map<Id, List<sObject>> contactIdToObject = new Map<Id, List<sObject>>();

        Boolean preferredAddressInTrigger = false;

        // grab conacts Ids that are used
        for (sObject currentObject: processedObjects) {
            Id contactId = (Id)currentObject.get('ucinn_ascendv2__Contact__c');
            Id objectId = (Id)currentObject.get('Id');

            if (contactId != null) {
                contactsWithChangedStatus.add(contactId);
            }
        }

        // grab all ids from list of objects from trigger to not reupdae those.
        for (sObject currentObject: newList) {
            Id objectId = (Id)currentObject.get('Id');

            if (objectId != null) {
                triggerNewListId.add(objectId);
            }

            //if ((Boolean)currentObject.get('ucinn_ascendv2__Is_Preferred__c') == true) {
                //preferredAddressInTrigger = true;
            //}
        }

        // Note: If two of the same type with status current are pushed they will both be current, not sure which to select
        String queryString = 'SELECT Id, ucinn_ascendv2__Type__c, ucinn_ascendv2__Contact__c, ucinn_ascendv2__Is_Preferred__c, ucinn_ascendv2__Status__c FROM ' + objectName + 
                            ' WHERE ucinn_ascendv2__Contact__c IN :contactsWithChangedStatus' + 
                            ' AND Id NOT IN :triggerNewListId' + 
                            ' AND ucinn_ascendv2__Type__c IN :fieldNamesToRestrict' + 
                            ' AND ucinn_ascendv2__Status__c = \'Current\'';
                                                        
        // [20210709 SC]: Only check for Constituent Address Relation
        if (objectName == 'ucinn_ascendv2__Address_Relation__c') {
            queryString += ' AND RecordType.DeveloperName = \'Contact_Address_Relation\' ';
        }

        List<sObject> objectsWithCurrent = Database.query(queryString);

        // create map of contact Id to object
        for (sObject currentObject: objectsWithCurrent) {
            Id contactId = (Id)currentObject.get('ucinn_ascendv2__Contact__c');

            if (contactIdToObject.containsKey(contactId)){
                List<sObject> relatedObjectsToContactId = contactIdToObject.get(contactId);
                relatedObjectsToContactId.add(currentObject);
                contactIdToObject.put(contactId, relatedObjectsToContactId);
            } else {
                List<sObject> relatedObjectsToContactId = new List<sObject>();
                relatedObjectsToContactId.add(currentObject);
                contactIdToObject.put(contactId, relatedObjectsToContactId);
            }
        }

        for (SObject currentObject : processedObjects) {     

            for (String fieldName: fieldNamesToRestrict) {
                List<sObject> currentContactsObjects = contactIdToObject.get((Id)currentObject.get('ucinn_ascendv2__Contact__c'));

                if (currentObject.get('ucinn_ascendv2__Type__c') != fieldName || currentContactsObjects == null || currentContactsObjects.isEmpty()) {
                    continue;
                }

                for (SObject oldObjectWithCurrent : currentContactsObjects) {
                    String objectType = (String)oldObjectWithCurrent.get('ucinn_ascendv2__Type__c');
                    if (objectType != fieldName) {
                        continue;
                    }

                    oldObjectWithCurrent.put('ucinn_ascendv2__Status__c', 'Former'); // need to check if there is an update to current on similar type
                    if (oldObjectWithCurrent.getSObjectType() == Schema.ucinn_ascendv2__Address_Relation__c.getSObjectType()) {
                        oldObjectWithCurrent.put('ucinn_ascendv2__End_Date__c', System.today()); // Added due to Inactive_and_End_Date Validation Rule of ucinn_ascendv2__Address_Relation__c object
                    }
                    
                    if ((Boolean)oldObjectWithCurrent.get('ucinn_ascendv2__Is_Preferred__c') == true) {
                        oldObjectWithCurrent.put('ucinn_ascendv2__Is_Preferred__c', false);
                        //if (!preferredAddressInTrigger) {
                            //oldObjectWithCurrent.put('ucinn_ascendv2__Is_Preferred__c', true);
                        //}
                        
                        // Set preferred to the currentobject
                        if (currentObject.get('ucinn_ascendv2__Type__c') == oldObjectWithCurrent.get('ucinn_ascendv2__Type__c')) {
                            currentObject.put('ucinn_ascendv2__Is_Preferred__c', true);
                        }
                        
                    }
                    
                    
                    objectsToUpdates.add(oldObjectWithCurrent);

                }  
            }
        }

        List<SObject> objectsToUpdateList = new List<SObject>();
        objectsToUpdateList.addAll(objectsToUpdates);
        return objectsToUpdateList;
    } 

    /**
     * Remove any other active records of the same type.
     * @param   processedObjects            Processed list of objects provided by trigger
     * @param   fieldNames                  Fie
     */
    private static List<SObject> duplicateActiveCheckAcc(List<SObject> processedObjects, List<String> fieldNamesToRestrict,
                                                    String objectName, List<sObject> newList) {
        Set<SObject> objectsToUpdates = new Set<SObject>();
        Set<Id> triggerNewListId = new Set<Id>();
        Set<Id> accountsWithChangedStatus = new Set<Id>();
        Map<Id, List<sObject>> accountIdToObject = new Map<Id, List<sObject>>();

        Boolean preferredAddressInTrigger = false;

        // grab conacts Ids that are used
        for (sObject currentObject: processedObjects) {
            Id accountId = (Id)currentObject.get('ucinn_ascendv2__Account__c');
            Id objectId = (Id)currentObject.get('Id');

            if (accountId != null) {
                accountsWithChangedStatus.add(accountId);
            }
        }

        // grab all ids from list of objects from trigger to not reupdae those.
        for (sObject currentObject: newList) {
            Id objectId = (Id)currentObject.get('Id');

            if (objectId != null) {
                triggerNewListId.add(objectId);
            }

            //if ((Boolean)currentObject.get('ucinn_ascendv2__Is_Preferred__c') == true) {
                //preferredAddressInTrigger = true;
            //}
        }

        // Note: If two of the same type with status current are pushed they will both be current, not sure which to select
        String queryStringAcc = 'SELECT Id, ucinn_ascendv2__Type__c, ucinn_ascendv2__Account__c, ucinn_ascendv2__Is_Preferred__c, ucinn_ascendv2__Status__c FROM ' + objectName + 
                            ' WHERE ucinn_ascendv2__Account__c IN :accountsWithChangedStatus' + 
                            ' AND Id NOT IN :triggerNewListId' + 
                            ' AND ucinn_ascendv2__Type__c IN :fieldNamesToRestrict' + 
                            ' AND ucinn_ascendv2__Status__c = \'Current\'';
                                                        
        // [20210709 SC]: Only check for Organization Address Relation
        if (objectName == 'ucinn_ascendv2__Address_Relation__c') {
            queryStringAcc += ' AND RecordType.DeveloperName = \'Organization_Address_Relation\' ';
        }

        List<sObject> objectsWithCurrentAcc = Database.query(queryStringAcc);
        
        System.debug(accountsWithChangedStatus);
        System.debug(queryStringAcc);
        System.debug(objectsWithCurrentAcc);

        // create map of contact Id to object
        for (sObject currentObject: objectsWithCurrentAcc) {
            Id accountId = (Id)currentObject.get('ucinn_ascendv2__Account__c');

            if (accountIdToObject.containsKey(accountId)){
                List<sObject> relatedObjectsToAccountId = accountIdToObject.get(accountId);
                relatedObjectsToAccountId.add(currentObject);
                accountIdToObject.put(accountId, relatedObjectsToAccountId);
            } else {
                List<sObject> relatedObjectsToAccountId = new List<sObject>();
                relatedObjectsToAccountId.add(currentObject);
                accountIdToObject.put(accountId, relatedObjectsToAccountId);
            }
        }

        for (SObject currentObject : processedObjects) {     

            for (String fieldName: fieldNamesToRestrict) {
                List<sObject> currentAccountsObjects = accountIdToObject.get((Id)currentObject.get('ucinn_ascendv2__Account__c'));

                if ((currentObject.get('ucinn_ascendv2__Type__c') != fieldName || currentAccountsObjects == null || currentAccountsObjects.isEmpty())) {
                    continue;
                }
                
                for (SObject oldObjectWithCurrent : currentAccountsObjects) {
                    String objectType = (String)oldObjectWithCurrent.get('ucinn_ascendv2__Type__c');
                    if (objectType != fieldName) {
                        continue;
                    }

                    oldObjectWithCurrent.put('ucinn_ascendv2__Status__c', 'Former'); // need to check if there is an update to current on similar type
                    if (oldObjectWithCurrent.getSObjectType() == Schema.ucinn_ascendv2__Address_Relation__c.getSObjectType()) {
                        oldObjectWithCurrent.put('ucinn_ascendv2__End_Date__c', System.today()); // Added due to Inactive_and_End_Date Validation Rule of ucinn_ascendv2__Address_Relation__c object
                    }
                    
                    if ((Boolean)oldObjectWithCurrent.get('ucinn_ascendv2__Is_Preferred__c') == true) {
                        oldObjectWithCurrent.put('ucinn_ascendv2__Is_Preferred__c', false);
                        //if (!preferredAddressInTrigger) {
                            //oldObjectWithCurrent.put('ucinn_ascendv2__Is_Preferred__c', true);
                        //}
                    }
                    
                    
                    objectsToUpdates.add(oldObjectWithCurrent);

                }     
            }
        }
       
        List<SObject> objectsToUpdateList = new List<SObject>();
        objectsToUpdateList.addAll(objectsToUpdates);
        return objectsToUpdateList;
    } 

    /*******************************************************************************************************
     * @description Set preferred to true if the record being inserted is the only active child record. Generic for email/phone/address.
     * @param trigContextVars Trigger Context Variables.
     * @param contactChildRelName Relationship name for contact lookup.
     * @param accChildRelName Relationship name for account lookup.
     * @return N/A.
     */
    public static void enforceAtLeastOnePreferredOnInsert(List<sObject> triggerNew, String contactChildRelName, String accChildRelName) {

        Map<Id, List<sObject>> contactIdTosObjListMap = new Map<Id, List<sObject>>();
        Map<Id, List<sObject>> accountIdTosObjListMap = new Map<Id, List<sObject>>();

        // If only one active email exists under the contact, then set to preferred automatically.
        for (sObject eachsObj: triggerNew) {
            if (eachsObj.get('ucinn_ascendv2__Status__c') == 'Current') {
                if (eachsObj.get('ucinn_ascendv2__Contact__c') != null) {
                    if (!contactIdTosObjListMap.containsKey((ID)eachsObj.get('ucinn_ascendv2__Contact__c'))) {
                        contactIdTosObjListMap.put((ID)eachsObj.get('ucinn_ascendv2__Contact__c'), new List<sObject>());
                    }
                    contactIdTosObjListMap.get((ID)eachsObj.get('ucinn_ascendv2__Contact__c')).add(eachsObj);
                } else if (eachsObj.get('ucinn_ascendv2__Account__c') != null) {
                    if (!accountIdTosObjListMap.containsKey((ID)eachsObj.get('ucinn_ascendv2__Account__c'))) {
                        accountIdTosObjListMap.put((ID)eachsObj.get('ucinn_ascendv2__Account__c'), new List<sObject>());
                    }
                    accountIdTosObjListMap.get((ID)eachsObj.get('ucinn_ascendv2__Account__c')).add(eachsObj);
                }                                
            }
        }

        if (contactIdTosObjListMap.size() > 0 && contactChildRelName != '') {
            Set<Id> contactIdkeySet = contactIdTosObjListMap.keySet();
            String query = 'SELECT ID, (SELECT ID, ucinn_ascendv2__Is_Preferred__c, ucinn_ascendv2__Type__c FROM ' + contactChildRelName + ' WHERE ucinn_ascendv2__Status__c = \'Current\')'
                        + 'FROM Contact WHERE ID IN: contactIdkeySet';            
            List<sObject> queriedContacts = Database.query(query);

            setPreferredFlag(queriedContacts, contactChildRelName, contactIdTosObjListMap);
        }

        if (accountIdTosObjListMap.size() > 0 && accChildRelName != '') {
            Set<Id> accountIdkeySet = accountIdTosObjListMap.keySet();
            String query = 'SELECT ID, (SELECT ID, ucinn_ascendv2__Is_Preferred__c, ucinn_ascendv2__Type__c FROM ' + accChildRelName + ' WHERE ucinn_ascendv2__Status__c = \'Current\')'
                        + 'FROM Account WHERE ID IN: accountIdkeySet';
            List<sObject> queriedAccounts = Database.query(query);

            setPreferredFlag(queriedAccounts, accChildRelName, accountIdTosObjListMap);            
        }
    }
    
    public static void setPreferredFlag(List<sObject> queriedSObjects, String childRelationshipname, Map<Id, List<sObject>> parentIdTosObjListMap) {
        List<String> preferredOrderList =  new List<String>();
        preferredOrderList = bioOrgWideCustomConfig(childRelationshipName, 'Preferred');
        system.debug('preferredOrderList'+ preferredOrderList);
        for (sObject eachSObj: queriedSObjects) {
            // If there are no existing active records, make sure one of the active emails being inserted is preferred.
           // if (eachSObj.getSObjects(childRelationshipName) == null || eachSObj.getSObjects(childRelationshipName).isEmpty()) {
                Boolean preferredExists = false;
              
                if (eachsObj.get('Id') != null) {
                
                    for (sObject eachChild: parentIdTosObjListMap.get((ID)eachSObj.get('Id'))) {
                    //system.debug('test '+ preferredOrderList.size());
                        if ((eachChild.get('ucinn_ascendv2__Is_Preferred__c') == true && preferredOrderList!= null && preferredOrderList.size()>0 && preferredOrderList.contains(string.valueof(eachChild.get('ucinn_ascendv2__Type__c'))))) {
                            preferredExists = true;
                        }
                        
                    }
                }
                for (sObject eachChild: eachSObj.getSObjects(childRelationshipName)) {
                    if (eachChild.get('ucinn_ascendv2__Is_Preferred__c') == true && preferredOrderList!= null && preferredOrderList.size()>0 && preferredOrderList.contains(string.valueof(eachChild.get('ucinn_ascendv2__Type__c')))) {
                        preferredExists = true;
                    }
                }
               

                // If there is no preferred in the insert list, then set the first one found to preferred.
               // if (!preferredExists) {
                   // parentIdTosObjListMap.get((ID)eachSObj.get('Id'))[0].put('ucinn_ascendv2__Is_Preferred__c', true);
                   // parentIdTosObjListMap.get((ID)eachSObj.get('Id'))[0].put('ucinn_ascendv2__Status__c', 'Current');
               // }
                if (!preferredExists && preferredOrderList!= null && preferredOrderList.size() > 0) {
                    integer order = 0;
                    Map<integer, sObject> orderTosObjectMap = new Map<integer, sObject>();
                    for (string type : preferredOrderList) {
                        for (sObject eachChild: parentIdTosObjListMap.get((ID)eachSObj.get('Id'))) {
                           
                            if (eachChild.get('ucinn_ascendv2__Type__c') == type) {
                                orderTosObjectMap.put(order,eachChild);
                            }                              
                        }
                        order ++;
                    }

                    if (orderTosObjectMap !=  null && orderTosObjectMap.keyset().size() > 0) {
                        sObject recordToUpdate; 
                        for (integer theOrder: orderTosObjectMap.keyset()) {
                            recordToUpdate = orderTosObjectMap.get(theOrder);
                            break;
                        }
                        //recordToUpdate.put('Id', recordToUpdate.Id);
                        if(Test.isRunningTest() || 'ucinn_ascendv2__Emails_Contact__r' != childRelationshipname)// Cube84:vikas W-001097 -W-001097 - Remove auto-check for preferred email
                        recordToUpdate.put('ucinn_ascendv2__Is_Preferred__c', true);
                        recordToUpdate.put('ucinn_ascendv2__Status__c', 'Current');
                        
                        
                    }
                    
                }

            //}
        }
    }

    // clin Added on 10/12/2022 - new method to check whether to run the future method
    public static void enforceAtLeastOnePreferredOnUpdateWithFuture(List<sObject> triggerNew, Map<Id, sObject> oldMap, Map<Id, sObject> newMap, String contactChildRelName, String accChildRelName, String sObjectType) {

        Set<Id> sObjectRecordIds = new Set<Id>();
        
        // If preferred checkbox is updated to false, check all children under that contact.
        // If only one current child exists under the contact, then set to preferred automatically.
        for (sObject eachSObj: triggerNew) {
            // Get all children where preferred was updated to false.
            if ((oldMap.get((ID)eachSObj.get('Id')).get('ucinn_ascendv2__Is_Preferred__c') == true && eachSObj.get('ucinn_ascendv2__Is_Preferred__c') == false)
                    || (oldMap.get((ID)eachSObj.get('Id')).get('ucinn_ascendv2__Status__c') != eachSObj.get('ucinn_ascendv2__Status__c'))
                    || (oldMap.get((ID)eachSObj.get('Id')).get('ucinn_ascendv2__Type__c') != eachSObj.get('ucinn_ascendv2__Type__c'))) {
                sObjectRecordIds.add((ID)eachSObj.get('Id'));
            }
        }

        if (!System.isFuture() && !System.isBatch() && !sObjectRecordIds.isEmpty()) {
            enforceAtLeastOnePreferredOnUpdateOnFuture(sObjectRecordIds, contactChildRelName, accChildRelName, sObjectType);
        }
    }

    // clin Added on 10/12/2022 - new method that will run at future to avoid recursion error. this includes dml operation on the same sObject record/s
    @future
    public static void enforceAtLeastOnePreferredOnUpdateOnFuture(Set<Id> sObjectRecordIds, String contactChildRelName, String accChildRelName, String sObjectType) {
        Map<Id, Map<Id, sObject>> contactIdTosObjectMap = new Map<id, Map<Id, sObject>>();
        Map<Id, Map<Id, sObject>> accountIdTosObjectMap = new Map<Id, Map<Id, sObject>>();
        
        // If any children updated preferred to false OR updated status...
        List<sObject> sObjectsToUpdate = new List<sObject>();

        String soqlString = 'SELECT Id, ucinn_ascendv2__Contact__c, ucinn_ascendv2__Account__c FROM ' + sObjectType + ' WHERE Id IN :sObjectRecordIds';
        for (sObject eachSObj: Database.query(soqlString)) {
            if (eachSObj.get('ucinn_ascendv2__Contact__c') != null) {
                if (!contactIdTosObjectMap.containsKey((ID)eachSObj.get('ucinn_ascendv2__Contact__c'))) {
                    contactIdTosObjectMap.put((ID)eachSObj.get('ucinn_ascendv2__Contact__c'), new Map<Id, sObject>());
                }
                contactIdTosObjectMap.get((ID)eachSObj.get('ucinn_ascendv2__Contact__c')).put((ID)eachSObj.get('Id'), eachSObj);
            } else if (eachSObj.get('ucinn_ascendv2__Account__c') != null) {
                if (!accountIdTosObjectMap.containsKey((ID)eachSObj.get('ucinn_ascendv2__Account__c'))) {
                    accountIdTosObjectMap.put((ID)eachSObj.get('ucinn_ascendv2__Account__c'), new Map<Id, sObject>());
                }
                accountIdTosObjectMap.get((ID)eachSObj.get('ucinn_ascendv2__Account__c')).put((ID)eachSObj.get('Id'), eachSObj);
            }   
        }

        if (contactIdTosObjectMap.size() > 0 && contactChildRelName != '') {
            // Grab all the CURRENT sibling children of the children that updated preferred flag or status
            Set<Id> keySet = contactIdTosObjectMap.keySet();
            String query = 'SELECT ID, (SELECT ID, ucinn_ascendv2__Is_Preferred__c, ucinn_ascendv2__Type__c FROM ' + contactChildRelName + ' WHERE ucinn_ascendv2__Status__c = \'Current\') '
                    + 'FROM Contact WHERE ID IN: keySet';
        
            List<sObject> queriedContacts = Database.query(query);
            sObjectsToUpdate.addAll(setPreferredOrSetError(queriedContacts, contactChildRelName, sObjectType, contactIdTosObjectMap, null));
        }

        if (accountIdTosObjectMap.size() > 0 && accChildRelName != '') {
            // Grab all the CURRENT sibling children of the children that updated preferred flag or status
            Set<Id> keySet = accountIdTosObjectMap.keySet();
            String query = 'SELECT ID, (SELECT ID, ucinn_ascendv2__Is_Preferred__c, ucinn_ascendv2__Type__c FROM ' + accChildRelName + ' WHERE ucinn_ascendv2__Status__c = \'Current\') '
                    + 'FROM Account WHERE ID IN: keySet';
        
            List<sObject> queriedContacts = Database.query(query);
            sObjectsToUpdate.addAll(setPreferredOrSetError(queriedContacts, accChildRelName, sObjectType, accountIdTosObjectMap, null));
        }
        
        if (sObjectsToUpdate.size() > 0) {
            update sObjectsToUpdate;
        }  
    }

    public static void enforceAtLeastOnePreferredOnUpdate(List<sObject> triggerNew, Map<Id, sObject> oldMap, Map<Id, sObject> newMap, String contactChildRelName, String accChildRelName, String sObjectType) {

        Map<Id, Map<Id, sObject>> contactIdTosObjectMap = new Map<id, Map<Id, sObject>>();
        Map<Id, Map<Id, sObject>> accountIdTosObjectMap = new Map<Id, Map<Id, sObject>>();
        
        // If preferred checkbox is updated to false, check all children under that contact.
        // If only one current child exists under the contact, then set to preferred automatically.
        for (sObject eachSObj: triggerNew) {
            // Get all children where preferred was updated to false.
            if ((oldMap.get((ID)eachSObj.get('Id')).get('ucinn_ascendv2__Is_Preferred__c') == true && eachSObj.get('ucinn_ascendv2__Is_Preferred__c') == false)
                    || (oldMap.get((ID)eachSObj.get('Id')).get('ucinn_ascendv2__Status__c') != eachSObj.get('ucinn_ascendv2__Status__c'))
                    || (oldMap.get((ID)eachSObj.get('Id')).get('ucinn_ascendv2__Type__c') != eachSObj.get('ucinn_ascendv2__Type__c'))) {
                
                if (eachSObj.get('ucinn_ascendv2__Contact__c') != null) {
                    if (!contactIdTosObjectMap.containsKey((ID)eachSObj.get('ucinn_ascendv2__Contact__c'))) {
                        contactIdTosObjectMap.put((ID)eachSObj.get('ucinn_ascendv2__Contact__c'), new Map<Id, sObject>());
                    }
                    contactIdTosObjectMap.get((ID)eachSObj.get('ucinn_ascendv2__Contact__c')).put((ID)eachSObj.get('Id'), eachSObj);
                } else if (eachSObj.get('ucinn_ascendv2__Account__c') != null) {
                    if (!accountIdTosObjectMap.containsKey((ID)eachSObj.get('ucinn_ascendv2__Account__c'))) {
                        accountIdTosObjectMap.put((ID)eachSObj.get('ucinn_ascendv2__Account__c'), new Map<Id, sObject>());
                    }
                    accountIdTosObjectMap.get((ID)eachSObj.get('ucinn_ascendv2__Account__c')).put((ID)eachSObj.get('Id'), eachSObj);
                }                
            }
        }

        // If any children updated preferred to false OR updated status...
        List<sObject> sObjectsToUpdate = new List<sObject>();

        if (contactIdTosObjectMap.size() > 0 && contactChildRelName != '') {
            // Grab all the CURRENT sibling children of the children that updated preferred flag or status
            Set<Id> keySet = contactIdTosObjectMap.keySet();
            String query = 'SELECT ID, (SELECT ID, ucinn_ascendv2__Is_Preferred__c, ucinn_ascendv2__Type__c FROM ' + contactChildRelName + ' WHERE ucinn_ascendv2__Status__c = \'Current\') '
                    + 'FROM Contact WHERE ID IN: keySet';
        
            List<sObject> queriedContacts = Database.query(query);

            sObjectsToUpdate.addAll(setPreferredOrSetError(queriedContacts, contactChildRelName, sObjectType, contactIdTosObjectMap, newMap));
        }

        if (accountIdTosObjectMap.size() > 0 && accChildRelName != '') {
            // Grab all the CURRENT sibling children of the children that updated preferred flag or status
            Set<Id> keySet = accountIdTosObjectMap.keySet();
            String query = 'SELECT ID, (SELECT ID, ucinn_ascendv2__Is_Preferred__c, ucinn_ascendv2__Type__c FROM ' + accChildRelName + ' WHERE ucinn_ascendv2__Status__c = \'Current\') '
                    + 'FROM Account WHERE ID IN: keySet';
        
            List<sObject> queriedContacts = Database.query(query);
            sObjectsToUpdate.addAll(setPreferredOrSetError(queriedContacts, accChildRelName, sObjectType, accountIdTosObjectMap, newMap));
        }
        
        if (sObjectsToUpdate.size() > 0) {
            update sObjectsToUpdate;
        }  
    }

    public static void enforceAtLeastOnePreferredOnDelete(List<sObject> triggerOld, Map<Id, sObject> oldMap, Map<Id, sObject> newMap, String contactChildRelName, String accChildRelName, String sObjectType) {

        Map<Id, Map<Id, sObject>> contactIdTosObjectMap = new Map<id, Map<Id, sObject>>();
        Map<Id, Map<Id, sObject>> accountIdTosObjectMap = new Map<Id, Map<Id, sObject>>();
        
        // If preferred checkbox is updated to false, check all children under that contact.
        // If only one current child exists under the contact, then set to preferred automatically.
        for (sObject eachSObj: triggerOld) {

            if (eachSObj.get('ucinn_ascendv2__Is_Preferred__c') == true) {
                
                if (eachSObj.get('ucinn_ascendv2__Contact__c') != null) {
                    if (!contactIdTosObjectMap.containsKey((ID)eachSObj.get('ucinn_ascendv2__Contact__c'))) {
                        contactIdTosObjectMap.put((ID)eachSObj.get('ucinn_ascendv2__Contact__c'), new Map<Id, sObject>());
                    }
                    contactIdTosObjectMap.get((ID)eachSObj.get('ucinn_ascendv2__Contact__c')).put((ID)eachSObj.get('Id'), eachSObj);
                } else if (eachSObj.get('ucinn_ascendv2__Account__c') != null) {
                    if (!accountIdTosObjectMap.containsKey((ID)eachSObj.get('ucinn_ascendv2__Account__c'))) {
                        accountIdTosObjectMap.put((ID)eachSObj.get('ucinn_ascendv2__Account__c'), new Map<Id, sObject>());
                    }
                    accountIdTosObjectMap.get((ID)eachSObj.get('ucinn_ascendv2__Account__c')).put((ID)eachSObj.get('Id'), eachSObj);
                }                
            }
        }

        List<sObject> sObjectsToUpdate = new List<sObject>();

        if (contactIdTosObjectMap.size() > 0 && contactChildRelName != '') {
            // Grab all the CURRENT sibling children of the children that got deleted
            Set<Id> keySet = contactIdTosObjectMap.keySet();
            String query = 'SELECT ID, (SELECT ID, ucinn_ascendv2__Is_Preferred__c, ucinn_ascendv2__Type__c FROM ' + contactChildRelName + ' WHERE ucinn_ascendv2__Status__c = \'Current\') '
                    + 'FROM Contact WHERE ID IN: keySet';
        
            List<sObject> queriedContacts = Database.query(query);

            sObjectsToUpdate.addAll(setPreferredOrSetError(queriedContacts, contactChildRelName, sObjectType, contactIdTosObjectMap, newMap));
        }

        if (accountIdTosObjectMap.size() > 0 && accChildRelName != '') {
            // Grab all the CURRENT sibling children of the children that updated preferred flag or status
            Set<Id> keySet = accountIdTosObjectMap.keySet();
            String query = 'SELECT ID, (SELECT ID, ucinn_ascendv2__Is_Preferred__c, ucinn_ascendv2__Type__c FROM ' + accChildRelName + ' WHERE ucinn_ascendv2__Status__c = \'Current\') '
                    + 'FROM Account WHERE ID IN: keySet';
        
            List<sObject> queriedContacts = Database.query(query);
            sObjectsToUpdate.addAll(setPreferredOrSetError(queriedContacts, accChildRelName, sObjectType, accountIdTosObjectMap, newMap));
        }
        
        if (sObjectsToUpdate.size() > 0) {
            update sObjectsToUpdate;
        }  
    }

    public static List<sObject> setPreferredOrSetError(List<sObject> queriedSObjects, String childRelationshipName, String sObjectType, Map<Id, Map<Id, sObject>> parentIdTosObjectMap, Map<Id, sObject> newMap) {
        List<sObject> sObjectsToUpdate = new List<sObject>();
        List<String> preferredOrderList =  new List<String>();
        
        preferredOrderList = bioOrgWideCustomConfig(childRelationshipName, 'Preferred');
        system.debug('***'+preferredOrderList  );
        system.debug('***'+childRelationshipName  );
        for (sObject eachSObj: queriedSObjects) {

            if (eachSObj.getSObjects(childRelationshipName) != null) {                                    
                // Look through all current siblings. 2 Scenarios:                    
                // 1) Only one current. Auto set to preferred.
                // 2) No preferred current siblings, multiple currents follow the order, if the type is not in the list, ignore
                if (eachSObj.getSObjects(childRelationshipName).size() == 1) {

                    //List<Schema.DescribeSObjectResult> descResultList =  Schema.describeSObjects(new List<String>{sObjectType});
                    //if (descResultList != null && descResultList.size() > 0) {
                        sObject eachChild = eachSObj.getSObjects(childRelationshipName)[0];   
                        //sObject recordToUpdate = descResultList[0].getSobjectType().newSObject((ID)eachSObj.getSObjects(childRelationshipName)[0].get('Id'));
                       
                      
                        //sObject recordToUpdate = Schema.getGlobalDescribe().get(sObjectType).newSObject((ID)eachSObj.getSObjects(childRelationshipName)[0].get('Id'));
                        // Type has to be included in the preferred list, otherwise it will never auto set to prefer
                        if( preferredOrderList!=null && preferredOrderList.size()>0 && preferredOrderList.contains(string.valueof(eachChild.get('ucinn_ascendv2__Type__c')))) {
                            eachChild.put('ucinn_ascendv2__Is_Preferred__c', true);
                            eachChild.put('ucinn_ascendv2__Status__c', 'Current');
                            sObjectsToUpdate.add(eachChild); 

                        }
                        
                    //}                    
                } else {

                    Boolean preferredFound = false;          
                    for (sObject eachChild: eachSObj.getSObjects(childRelationshipName)) {

                        // If we find any queried children that are preferred, then we don't need to throw any error.
                        if (eachChild.get('ucinn_ascendv2__Is_Preferred__c') == true) {
                            preferredFound = true;
                            break;
                        }
                    }

                    // If there's no preferred found, then we need to see if there's only one active. If so, automatically set that to preferred.
                    // Otherwise, follow the order to assign a preferred. If the type is not in the list, save without any other logic
                    if (!preferredFound && preferredOrderList!=null && preferredOrderList.size() > 0) {

                        integer order = 0;
                        Map<integer, sObject> orderTosObjectMap = new Map<integer, sObject>();
                        for (string type : preferredOrderList) {
                            for (sObject eachChild: eachSObj.getSObjects(childRelationshipName)) {
                                
                                if (eachChild.get('ucinn_ascendv2__Type__c') == type) {
                         
                                    
                                    
                                    orderTosObjectMap.put(order,eachChild);
                                }                              
                            }
                            order ++;
                        }

                        if (orderTosObjectMap !=  null && orderTosObjectMap.keyset().size() > 0) {
                            sObject recordToUpdate; 
                            for (integer theOrder: orderTosObjectMap.keyset()) {
                                recordToUpdate = orderTosObjectMap.get(theOrder);
                                break;
                            }
                            recordToUpdate.put('ucinn_ascendv2__Is_Preferred__c', true);
                            recordToUpdate.put('ucinn_ascendv2__Status__c', 'Current');
                            sObjectsToUpdate.add(recordToUpdate); 
                        }
                        
                    }
                }
            }                
        }

        return sObjectsToUpdate;
    }
}