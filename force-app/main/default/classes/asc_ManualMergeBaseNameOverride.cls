/**
 * Follow ascend logic when processing interims with custom tab names
 * 
 * @author      UC Innovation
 * @version     1.0
 * @since       1.0
 */ 
global class asc_ManualMergeBaseNameOverride extends ucinn_ascendv2.ascend_BIO_ManualMergeBase {
    //Custom merge tabs that need to follow ascend logic
    private static Map<String, List<String>> tabNameOverrides {
        get {
            if (tabNameOverrides == null) {
                tabNameOverrides = new Map<String, List<String>>();

                for (Interim_Merge_Override__mdt overrideMDT : [SELECT DeveloperName, Ascend_Tab__c FROM Interim_Merge_Override__mdt]) {
                    if (!tabNameOverrides.containsKey(overrideMDT.Ascend_Tab__c)) {
                        tabNameOverrides.put(overrideMDT.Ascend_Tab__c, new List<String>{ overrideMDT.DeveloperName });
                    } else {
                        tabNameOverrides.get(overrideMDT.Ascend_Tab__c).add(overrideMDT.DeveloperName);
                    }
                }
            }

            return tabNameOverrides;
        }
        private set;
    }

    /**
     *  Override ascend function to include custom merge tabs
     *
     * @param       tab: all information about a tab, necessary for processing.
     */
    global override void performInterimCardMergeForInfoTargetsOnly() {
        for (TabInfo tab : tabsWithCardsToMerge) {
            if (tab.tabDeveloperName == 'System_IDs' 
                    || (tabNameOverrides.containsKey('System IDs') && tabNameOverrides.get('System IDs').contains(tab.tabDeveloperName))) {
                processSystemIDsDefault(tab);
            } else if (tab.tabDeveloperName == 'Additional_Info' 
                    || (tabNameOverrides.containsKey('Additional Info') && tabNameOverrides.get('Additional Info').contains(tab.tabDeveloperName))) {
                processAdditionalInfoDefault(tab);
            } else {
                if (tab.targetTabType == 'Info') {
                    performCardMergeDefaultLogicForInfoTarget(tab);
                }
            }
        }
    }

    /**
     *  Override ascend function to include custom merge tabs
     *
     * @param       tab: all information about a tab, necessary for processing.
     */
    global override void performInterimCardMergeForRelatedListTargetsOnly() {
        for (TabInfo tab : tabsWithCardsToMerge) {
            if (tab.tabDeveloperName == 'Address_Relation' 
                    || (tabNameOverrides.containsKey('Address Relation') && tabNameOverrides.get('Address Relation').contains(tab.tabDeveloperName))) {
                processAddressTabDefault(tab);
            } else if (tab.tabDeveloperName == 'Phone' 
                    || (tabNameOverrides.containsKey('Phone') && tabNameOverrides.get('Phone').contains(tab.tabDeveloperName))) {
                processPhoneTabDefault(tab);
            } else if (tab.tabDeveloperName == 'Email' 
                    || (tabNameOverrides.containsKey('Email') && tabNameOverrides.get('Email').contains(tab.tabDeveloperName))) {
                processEmailTabDefault(tab);
            } else if (tab.tabDeveloperName == 'Constituent_Name' 
                    || (tabNameOverrides.containsKey('Constituent Name') && tabNameOverrides.get('Constituent Name').contains(tab.tabDeveloperName))) {
                processNameTabDefault(tab);
            } else if (tab.tabDeveloperName == 'Relationship' 
                    || (tabNameOverrides.containsKey('Relationship') && tabNameOverrides.get('Relationship').contains(tab.tabDeveloperName))) {
                processRelationshipDefault(tab);
            } else {
                if (tab.targetTabType == 'Related List' && tab.parentObjectLookupAPIName != null) {
                    List<SObjectJunctionWrapper> sobjectWrapperList = performCardMergeDefaultLogicForRelatedListTargetWithJunction(tab);
                    List<SObject> parentSObjects = preProcessJunctionInfo(tab, sobjectWrapperList);

                    for (SObject parentSObject : parentSObjects) {
                        if (parentSObject.Id != null) {
                            sObjectsToUpdateFirst.add(parentSObject);
                        } else {
                            sObjectsToInsertFirst.add(parentSObject);
                        }
                    }

                    sobjectJunctionWrapperList.addAll(sobjectWrapperList);

                } else if (tab.targetTabType == 'Related List') {
                    List<SObject> relatedSObjects = performCardMergeDefaultLogicForRelatedListTarget(tab);

                    for (SObject relatedSObject : relatedSObjects) {
                        if (relatedSObject.Id != null) {
                            sObjectsToUpdate.add(relatedSObject);
                        } else {
                            sObjectsToInsert.add(relatedSObject);
                        }
                    }
                }
            }
        }
    }

    /**
     *  Override ascend function to include custom merge tabs
     *
     * @param       tab: all information about a tab, necessary for processing.
     * @since       1.71
     */
    global override void performInterimCardMerge() {
        for (TabInfo tab : tabsWithCardsToMerge) {
            if (tab.tabDeveloperName == 'Address_Relation' 
                    || (tabNameOverrides.containsKey('Address Relation') && tabNameOverrides.get('Address Relation').contains(tab.tabDeveloperName))) {
                processAddressTabDefault(tab);
            } else if (tab.tabDeveloperName == 'Phone' 
                    || (tabNameOverrides.containsKey('Phone') && tabNameOverrides.get('Phone').contains(tab.tabDeveloperName))) {
                processPhoneTabDefault(tab);
            } else if (tab.tabDeveloperName == 'Email' 
                    || (tabNameOverrides.containsKey('Email') && tabNameOverrides.get('Email').contains(tab.tabDeveloperName))) {
                processEmailTabDefault(tab);
            } else if (tab.tabDeveloperName == 'Constituent_Name' 
                    || (tabNameOverrides.containsKey('Constituent Name') && tabNameOverrides.get('Constituent Name').contains(tab.tabDeveloperName))) {
                processNameTabDefault(tab);
            } else if (tab.tabDeveloperName == 'System_IDs' 
                    || (tabNameOverrides.containsKey('System IDs') && tabNameOverrides.get('System IDs').contains(tab.tabDeveloperName))) {
                processSystemIDsDefault(tab);
            } else if (tab.tabDeveloperName == 'Additional_Info' 
                    || (tabNameOverrides.containsKey('Additional Info') && tabNameOverrides.get('Additional Info').contains(tab.tabDeveloperName))) {
                processAdditionalInfoDefault(tab);
            } else if (tab.tabDeveloperName == 'Relationship' 
                    || (tabNameOverrides.containsKey('Relationship') && tabNameOverrides.get('Relationship').contains(tab.tabDeveloperName))) {
                processRelationshipDefault(tab);
            } else {
                if (tab.targetTabType == 'Info') {
                    performCardMergeDefaultLogicForInfoTarget(tab);
                } else if (tab.targetTabType == 'Related List' && tab.parentObjectLookupAPIName != null) {

                    List<SObjectJunctionWrapper> sobjectWrapperList = performCardMergeDefaultLogicForRelatedListTargetWithJunction(tab);
                    List<SObject> parentSObjects = preProcessJunctionInfo(tab, sobjectWrapperList);

                    for (SObject parentSObject : parentSObjects) {
                        if (parentSObject.Id != null) {
                            sObjectsToUpdateFirst.add(parentSObject);
                        } else {
                            sObjectsToInsertFirst.add(parentSObject);
                        }
                    }

                    sobjectJunctionWrapperList.addAll(sobjectWrapperList);

                } else if (tab.targetTabType == 'Related List') {
                    List<SObject> relatedSObjects = performCardMergeDefaultLogicForRelatedListTarget(tab);

                    for (SObject relatedSObject : relatedSObjects) {
                        if (relatedSObject.Id != null) {
                            sObjectsToUpdate.add(relatedSObject);
                        } else {
                            sObjectsToInsert.add(relatedSObject);
                        }
                    }
                }
            }
        }
    }
}