/**
 * Custom trigger Handler class for Hard and Soft Credits
 * 
 * @author  UC Innovation
 * @version  1.0, 2021-10-04
 * @since  1.0
 * @description Handler class for Hard and Soft Credits on empty Membership Amounts
 */
global class asc_TRIG_HSCHandler extends TRIG_BaseHandler {
    
    protected override void afterInsert(Trigger_ContextVariables trigContextVars, ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper) {
        // defaultLogicSimplified(trigContextVars, dmlWrapper);
        membershipCreditDefaultLogic(trigContextVars, dmlWrapper);
    }
    
    protected override void afterDelete(Trigger_ContextVariables trigContextVars, ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper) {    

    }

    protected override void afterUpdate(Trigger_ContextVariables trigContextVars, ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper) {
        // defaultLogicSimplified(trigContextVars, dmlWrapper);
        membershipCreditDefaultLogic(trigContextVars, dmlWrapper);
    }

    protected override void afterUndelete(Trigger_ContextVariables trigContextVars, ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper) {

    }

    public void membershipCreditDefaultLogic(Trigger_ContextVariables trigContextVars, ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper) {
        List<ucinn_ascendv2__Hard_and_Soft_Credit__c> triggerNew = (List<ucinn_ascendv2__Hard_and_Soft_Credit__c>) trigContextVars.triggerNew;
        // String DESIG_UNRESTRICTED_TYPE_UNIVUNR = 'UNIVUNR'; // 02/15/2023 - Moved to a different method
        Set<Id> opportunityIds = new Set<Id>();
        Map<Id, ucinn_ascendv2__Hard_and_Soft_Credit__c> hscIdToTriggerNewRecMap = new Map<Id, ucinn_ascendv2__Hard_and_Soft_Credit__c>();
        // Map<Id, List<ucinn_ascendv2__Hard_and_Soft_Credit__c>> ddIdToHSCRecsMap = new Map<Id, List<ucinn_ascendv2__Hard_and_Soft_Credit__c>>();
        // Map<Id, List<ucinn_ascendv2__Hard_and_Soft_Credit__c>> ddIdToHSCRecsFinalMap = new Map<Id, List<ucinn_ascendv2__Hard_and_Soft_Credit__c>>();
        List<ucinn_ascendv2__Hard_and_Soft_Credit__c> hscListToUpdate = new List<ucinn_ascendv2__Hard_and_Soft_Credit__c>();
        Map<Id, Map<Id, List<ucinn_ascendv2__Hard_and_Soft_Credit__c>>> pldgPmtIdToDDIdToHSCRecsMap = new Map<Id, Map<Id, List<ucinn_ascendv2__Hard_and_Soft_Credit__c>>>();
        Map<Id, Map<Id, List<ucinn_ascendv2__Hard_and_Soft_Credit__c>>> pldgPmtIdToDDIdToHSCRecsFinalMap = new Map<Id, Map<Id, List<ucinn_ascendv2__Hard_and_Soft_Credit__c>>>();
        
        for (ucinn_ascendv2__Hard_and_Soft_Credit__c hsc : triggerNew) {
            // Run "Default Logic" whenever Membership_Amount__c field is blank during Gift Processing
            // "Default logic" only applies to Gift/s with Designation/s of Unrestricted Type "UNIVUNR"
                // Change Request 02/15/2023 - Apply "Default Logic" to Other Gifts that are not "UNIVUNR"
                // Change Request 02/15/2023 - Removed condition "&& hsc.Designation_Unrestricted_Type__c == DESIG_UNRESTRICTED_TYPE_UNIVUNR"
            if (hsc.ucinn_ascendv2__Credit_Amount__c != null) {
                opportunityIds.add(hsc.ucinn_ascendv2__Opportunity__c);
            }

            if (hsc.Id != null) {
                hscIdToTriggerNewRecMap.put(hsc.Id, hsc);
            }
        }

        // Create a new SOQL Query to get all HSC records related to the affected Opportunity.
        // Using triggerNew can potentially cause missing HSC records that didn't go through the same DML operation.
        if (!opportunityIds.isEmpty()) {
            // Only retrieve HSC records that are ucinn_ascendv2__Contact__c != NULL to exclude hard credited Organization gifts
            // We only need to evaluate the Constituents for the "Default Logic"
            // clin 01/04/2024 - Removed nd_Allocation_Division_Code__c and added ucinn_ascendv2__Designation__r.ND_Division_Code__c
            // clin 02/05/2024 - Added ucinn_ascendv2__Account__c field as per Case 00002291 / W-002042
            for (ucinn_ascendv2__Hard_and_Soft_Credit__c hsc : [SELECT Id, Name, ucinn_ascendv2__Contact__c, ucinn_ascendv2__Account__c, ucinn_ascendv2__Designation_Detail__c, ucinn_ascendv2__Designation__r.ND_Division_Code__c, 
                                                                Membership_Amount__c, ucinn_ascendv2__Credit_Amount__c, ucinn_ascendv2__Credit_Type__c, ucinn_ascendv2__Is_Donor_Control__c, 
                                                                ucinn_ascendv2__Contact__r.ucinn_ascendv2__Preferred_Spouse__c, ucinn_ascendv2__Contact__r.nd_Partner_Significant_Other__c, 
                                                                ucinn_ascendv2__Source__c, ucinn_ascendv2__Opportunity__c, ucinn_ascendv2__Payment__c, ucinn_ascendv2__Payment__r.ND_Gift_Amount__c,
                                                                ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__Primary_Contact__c, Designation_Unrestricted_Type__c, ucinn_ascendv2__Designation_Detail__r.ND_Gift_Amount__c, ND_Gift_Amount__c
                                                            FROM ucinn_ascendv2__Hard_and_Soft_Credit__c 
                                                            WHERE ucinn_ascendv2__Opportunity__c IN :opportunityIds AND ucinn_ascendv2__Opportunity__r.RecordType.Name != 'Matching Gift']) {
                
                if (hsc.ucinn_ascendv2__Source__c == 'Pledge') {
                    if (hsc.ucinn_ascendv2__Opportunity__c != null && hsc.ucinn_ascendv2__Designation_Detail__c != null) {
                        // Group HSC records under the same Designation Detail by creating a map
                        // Grouped HSC records will be evaluated based on a given set of criteria to determine which Constituent should have Membership Amount populated
                        /* if (ddIdToHSCRecsMap.containsKey(hsc.ucinn_ascendv2__Designation_Detail__c)) {
                            ddIdToHSCRecsMap.get(hsc.ucinn_ascendv2__Designation_Detail__c).add(hsc);
                        } else {
                            ddIdToHSCRecsMap.put(hsc.ucinn_ascendv2__Designation_Detail__c, new List<ucinn_ascendv2__Hard_and_Soft_Credit__c>{hsc});
                        } */

                        if (pldgPmtIdToDDIdToHSCRecsMap.containsKey(hsc.ucinn_ascendv2__Opportunity__c)) {
                            if (pldgPmtIdToDDIdToHSCRecsMap.get(hsc.ucinn_ascendv2__Opportunity__c).containsKey(hsc.ucinn_ascendv2__Designation_Detail__c)) {
                                pldgPmtIdToDDIdToHSCRecsMap.get(hsc.ucinn_ascendv2__Opportunity__c).get(hsc.ucinn_ascendv2__Designation_Detail__c).add(hsc);
                            } else {
                                pldgPmtIdToDDIdToHSCRecsMap.get(hsc.ucinn_ascendv2__Opportunity__c).put(hsc.ucinn_ascendv2__Designation_Detail__c, new List<ucinn_ascendv2__Hard_and_Soft_Credit__c>{hsc});
                            }
                        } else {
                            List<ucinn_ascendv2__Hard_and_Soft_Credit__c> hscList = new List<ucinn_ascendv2__Hard_and_Soft_Credit__c>{hsc};
                            pldgPmtIdToDDIdToHSCRecsMap.put(hsc.ucinn_ascendv2__Opportunity__c, new Map<Id, List<ucinn_ascendv2__Hard_and_Soft_Credit__c>>{hsc.ucinn_ascendv2__Designation_Detail__c=>hscList});
                        }
                    }
                } else if (hsc.ucinn_ascendv2__Source__c.contains('Payment')) {
                    if (hsc.ucinn_ascendv2__Payment__c != null && hsc.ucinn_ascendv2__Designation_Detail__c != null) {
                        // Group HSC records under the same Designation Detail by creating a map
                        // Grouped HSC records will be evaluated based on a given set of criteria to determine which Constituent should have Membership Amount populated
                        /* if (ddIdToHSCRecsMap.containsKey(hsc.ucinn_ascendv2__Designation_Detail__c)) {
                            ddIdToHSCRecsMap.get(hsc.ucinn_ascendv2__Designation_Detail__c).add(hsc);
                        } else {
                            ddIdToHSCRecsMap.put(hsc.ucinn_ascendv2__Designation_Detail__c, new List<ucinn_ascendv2__Hard_and_Soft_Credit__c>{hsc});
                        } */

                        if (pldgPmtIdToDDIdToHSCRecsMap.containsKey(hsc.ucinn_ascendv2__Payment__c)) {
                            if (pldgPmtIdToDDIdToHSCRecsMap.get(hsc.ucinn_ascendv2__Payment__c).containsKey(hsc.ucinn_ascendv2__Designation_Detail__c)) {
                                pldgPmtIdToDDIdToHSCRecsMap.get(hsc.ucinn_ascendv2__Payment__c).get(hsc.ucinn_ascendv2__Designation_Detail__c).add(hsc);
                            } else {
                                pldgPmtIdToDDIdToHSCRecsMap.get(hsc.ucinn_ascendv2__Payment__c).put(hsc.ucinn_ascendv2__Designation_Detail__c, new List<ucinn_ascendv2__Hard_and_Soft_Credit__c>{hsc});
                            }
                        } else {
                            List<ucinn_ascendv2__Hard_and_Soft_Credit__c> hscList = new List<ucinn_ascendv2__Hard_and_Soft_Credit__c>{hsc};
                            pldgPmtIdToDDIdToHSCRecsMap.put(hsc.ucinn_ascendv2__Payment__c, new Map<Id, List<ucinn_ascendv2__Hard_and_Soft_Credit__c>>{hsc.ucinn_ascendv2__Designation_Detail__c=>hscList});
                        }
                    }
                }
            }
        }

        for (Id pldgPmtId : pldgPmtIdToDDIdToHSCRecsMap.keySet()) {
            // Evaluate the HSC records for each Designation Detail to determine the Membership Amount
            for (Id ddId : pldgPmtIdToDDIdToHSCRecsMap.get(pldgPmtId).keySet()) {
                Boolean isMembershipAmountManual = false;
                List<ucinn_ascendv2__Hard_and_Soft_Credit__c> hscContactsOnlyList = new List<ucinn_ascendv2__Hard_and_Soft_Credit__c>();
                List<ucinn_ascendv2__Hard_and_Soft_Credit__c> hscOrgOnlyList = new List<ucinn_ascendv2__Hard_and_Soft_Credit__c>();

                for (ucinn_ascendv2__Hard_and_Soft_Credit__c hsc : pldgPmtIdToDDIdToHSCRecsMap.get(pldgPmtId).get(ddId)) {
                    if (hsc.Membership_Amount__c != null) {
                        isMembershipAmountManual = true;
                    }

                    // create a new list of HSC which contains only those with ucinn_ascendv2__Contact__c != null
                    if (hsc.ucinn_ascendv2__Contact__c != null) {
                        hscContactsOnlyList.add(hsc);
                    }

                    // clin 02/05/2024 - create a new list of HSC which contains only those with ucinn_ascendv2__Account__c != null
                    if (hsc.ucinn_ascendv2__Account__c != null) {
                        hscOrgOnlyList.add(hsc);
                    }
                }
                
                // Continue with "Default Logic" only if HSC records have at least 1 ucinn_ascendv2__Contact__c
                // if (!hscContactsOnlyList.isEmpty()) {
                    // Continue with "Default Logic" only if all HSC records don't have Membership Amount
                    // If one HSC record has Membership Amount populated means that was manually entered and "Default Logic" should not apply
                    if (!isMembershipAmountManual) {
                        // If there's more than 1 HSC records for this Designation Detail,
                        // Check if constituents of the HSC records are in a spousal relationship or not
                        if (hscContactsOnlyList.size() > 1) {
                            // Throw a validation error if the HSC records are not in a spousal relationship
                            // Validation Error: Manually populate Membership Amount field
                            // Error thrown should be in triggerNew and should be before processing the "Default Logic"
                            if (!validateHSCsAreSpouseRelated(hscContactsOnlyList)) {
                                for (ucinn_ascendv2__Hard_and_Soft_Credit__c hsc : hscContactsOnlyList) {
                                    if (hscIdToTriggerNewRecMap.containsKey(hsc.Id)) {
                                        hscIdToTriggerNewRecMap.get(hsc.Id).adderror('Membership_Amount__c', 'Please enter Membership Amount.');
                                    }
                                }
                            }
                            // If HSC records are in a spousal relationship, add them to the new map for further evaluation
                            // Grouped HSC records by Designation Detail and will be evaluated based on a given set of criteria(found in CMT) to determine which Constituent should have Membership Amount populated
                            else {
                                // ddIdToHSCRecsFinalMap.put(ddId, hscContactsOnlyList);
                                pldgPmtIdToDDIdToHSCRecsFinalMap.put(pldgPmtId, new Map<Id, List<ucinn_ascendv2__Hard_and_Soft_Credit__c>>{ddId=>hscContactsOnlyList});
                            }
                        }
                        // If there is only 1 HSC record for this Designation Detail, populate the HSC record's Membership Amount w/ Gift Amount
                        else if (hscContactsOnlyList.size() == 1) { // clin 02/05/2024 - updated else if condition logic to set Membership Amount for 1 constituent only
                            ucinn_ascendv2__Hard_and_Soft_Credit__c hscRec = hscContactsOnlyList[0];
                            if (hscRec.ucinn_ascendv2__Source__c == 'Pledge') {
                                hscRec.Membership_Amount__c = hscRec.ucinn_ascendv2__Credit_Amount__c;
                            } else {
                                hscRec.Membership_Amount__c = hscRec.ucinn_ascendv2__Payment__r.ND_Gift_Amount__c;
                            }
                            
                            hscListToUpdate.add(hscRec);
                        } else if (hscOrgOnlyList.size() == 1) { // clin 02/05/2024 - added else if condition logic to set Membership Amount for 1 organization only without constituents
                            ucinn_ascendv2__Hard_and_Soft_Credit__c hscRec = hscOrgOnlyList[0];
                            if (hscRec.ucinn_ascendv2__Source__c == 'Pledge') {
                                hscRec.Membership_Amount__c = hscRec.ucinn_ascendv2__Credit_Amount__c;
                            } else {
                                hscRec.Membership_Amount__c = hscRec.ucinn_ascendv2__Payment__r.ND_Gift_Amount__c;
                            }
                            
                            hscListToUpdate.add(hscRec);
                        }
                    } else {
                        // Add validation to check the total of the Membership Amount entered is equal to the Credit Amount of the Hard Credit record
                        Decimal hardGiftAmount = 0;
                        Decimal totalMembershipAmt = 0;
                        // clin 03/25/2024 - Updated code to handle multiple hard credit records(ex: splitting the hard credit into different years)
                        for (ucinn_ascendv2__Hard_and_Soft_Credit__c hsc : pldgPmtIdToDDIdToHSCRecsMap.get(pldgPmtId).get(ddId)) {
                            if (hsc.ucinn_ascendv2__Credit_Type__c == 'Hard' && hsc.ucinn_ascendv2__Credit_Amount__c != null) {
                                system.debug('@@ source is '+hsc.ucinn_ascendv2__Source__c);
                                if (hsc.ucinn_ascendv2__Source__c == 'Pledge') {
                                    hardGiftAmount += hsc.ucinn_ascendv2__Credit_Amount__c;
                                    System.debug('@@hardGiftAmount'+hsc.Id+ '=>'+hsc.ucinn_ascendv2__Credit_Amount__c);
                                       System.debug('@@recordid'+hsc.Id);
                                } else {
                                
                                    hardGiftAmount += hsc.ucinn_ascendv2__Payment__r.ND_Gift_Amount__c;
                                    System.debug('@@hardGiftAmount2'+hsc.Id+ '=>'+hsc.ucinn_ascendv2__Payment__r.ND_Gift_Amount__c);
                                    break; // clin 03/25/2024 - break the loop once we get the gift amount for non-Pledges
                                }
                            }
                        }
                        // clin 03/25/2024 - moved the logic to get the total of membership amount in a separate for loop
                        for (ucinn_ascendv2__Hard_and_Soft_Credit__c hsc : pldgPmtIdToDDIdToHSCRecsMap.get(pldgPmtId).get(ddId)) {
                          System.debug('@@'+hsc.Id+ '=>'+hsc.Membership_Amount__c);
                            if (hsc.Membership_Amount__c != null) {
                                System.debug('@@recordid'+hsc.Id);
                                totalMembershipAmt += hsc.Membership_Amount__c;
                            }
                        }
                         System.debug('@@totalMembershipAmt=>'+totalMembershipAmt);
                         System.debug('@@hardGiftAmount=>'+hardGiftAmount);
                        if (totalMembershipAmt != hardGiftAmount) {
                            for (ucinn_ascendv2__Hard_and_Soft_Credit__c hsc : pldgPmtIdToDDIdToHSCRecsMap.get(pldgPmtId).get(ddId)) {
                                if (hscIdToTriggerNewRecMap.containsKey(hsc.Id)) {
                        //            hscIdToTriggerNewRecMap.get(hsc.Id).adderror('Membership_Amount__c', 'Membership Amount should be equal to the Gift Amount of the Hard Credit.');
                                    hscIdToTriggerNewRecMap.get(hsc.Id).adderror('Membership_Amount__c', 'University Credit Amount must be equal to the Gift Amount of the Hard Credit.');
                                }
                            }
                        }
                    }
                // }
            }
        }

        // Further evaluation of HSC records with spouses to determine which Constituent should have Membership Amount populated
        if (!pldgPmtIdToDDIdToHSCRecsFinalMap.isEmpty()) {
            List<ucinn_ascendv2__Hard_and_Soft_Credit__c> hscList = getHSCMembershipCredit(pldgPmtIdToDDIdToHSCRecsFinalMap);
            hscListToUpdate.addAll(hscList);
        }

        // Execute Update DML on hscListToUpdate to update Membership_Amount__c of HSC record/s
        if (!hscListToUpdate.isEmpty()) {
            try {
                ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger('ucinn_ascendv2__Hard_and_Soft_Credit__c', false); // clin 01/04/2024 - Added fix to prevent recursion issue when creating a pledge
                update hscListToUpdate;
                ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger('ucinn_ascendv2__Hard_and_Soft_Credit__c', true); // clin 01/04/2024 - Added fix to prevent recursion issue when creating a pledge
            } catch (Exception e) {
                System.debug('e: ' + e);
                System.debug('e.getMessage(): ' + e.getMessage());
                triggerNew.get(0).adderror(e.getMessage());
            }
        }
    }

    public Boolean validateHSCsAreSpouseRelated(List<ucinn_ascendv2__Hard_and_Soft_Credit__c> hscRecsList) {
        Boolean isValidHSCs = false;
        Set<Id> spousesIdsSet = new Set<Id>();

        // Collect the Constituent Ids of the Spouses
        for (ucinn_ascendv2__Hard_and_Soft_Credit__c hsc : hscRecsList) {
            if (hsc.ucinn_ascendv2__Contact__c != null) {
                if (hsc.ucinn_ascendv2__Contact__r.ucinn_ascendv2__Preferred_Spouse__c != null) {
                    spousesIdsSet.add(hsc.ucinn_ascendv2__Contact__r.ucinn_ascendv2__Preferred_Spouse__c);
                } else if (hsc.ucinn_ascendv2__Contact__r.nd_Partner_Significant_Other__c != null) {
                    spousesIdsSet.add(hsc.ucinn_ascendv2__Contact__r.nd_Partner_Significant_Other__c);
                }
            }
        }

        // Check each Constituent of HSC record is in spousesIdsSet to verify that the HSC records are of spousal relationship
        for (ucinn_ascendv2__Hard_and_Soft_Credit__c hsc : hscRecsList) {
            if (hsc.ucinn_ascendv2__Contact__c != null && spousesIdsSet.contains(hsc.ucinn_ascendv2__Contact__c)) {
                isValidHSCs = true;
            } else {
                isValidHSCs = false;
                break; // exit loop if one of the HSC record is not spouse related
            }
        }

        return isValidHSCs;
    }

    public List<ucinn_ascendv2__Hard_and_Soft_Credit__c> getHSCMembershipCredit(Map<Id, Map<Id, List<ucinn_ascendv2__Hard_and_Soft_Credit__c>>> pldgPmtIdToDDIdToHSCRecsMap) {
        String DESIG_UNRESTRICTED_TYPE_UNIVUNR = 'UNIVUNR';
        String ALLOCATION_DIVISION_CODE_ROCKNE = 'V025';
        Map<Id, Boolean> ddIdToIsRockneDivisionMap = new Map<Id, Boolean>();
        Set<Id> nonUNIVUNRddIdSet = new Set<Id>();
        List<ucinn_ascendv2__Hard_and_Soft_Credit__c> hscListToUpdate = new List<ucinn_ascendv2__Hard_and_Soft_Credit__c>();
        Set<Id> conIdsRockne = new Set<Id>();
        Set<Id> conIdsNonRockne = new Set<Id>();
        Set<Id> conIdsNonUNIVUNR = new Set<Id>();
        List<Membership_Credit_Setting__mdt> rockneSettings;
        List<Membership_Credit_Setting__mdt> nonRockneSettings;
        List<Membership_Credit_Setting__mdt> nonUNIVUNRSettings;
        Map<String, Map<Id, List<sObject>>> rockneMdtToConIdToRelatedRecsMap;
        Map<String, Map<Id, List<sObject>>> nonRockneMdtToConIdToRelatedRecsMap;
        Map<String, Map<Id, List<sObject>>> nonUNIVUNRMdtToConIdToRelatedRecsMap;

        for (Id pldgPmtId: pldgPmtIdToDDIdToHSCRecsMap.keySet()) {
            for (Id ddId : pldgPmtIdToDDIdToHSCRecsMap.get(pldgPmtId).keySet()) {
                for (ucinn_ascendv2__Hard_and_Soft_Credit__c hsc : pldgPmtIdToDDIdToHSCRecsMap.get(pldgPmtId).get(ddId)) {
                    if (hsc.ucinn_ascendv2__Designation_Detail__c != null) {
                        // Create a map to determine whether a Designation Detail is UNIVUNR or not
                        if (hsc.Designation_Unrestricted_Type__c == DESIG_UNRESTRICTED_TYPE_UNIVUNR) {
                            // Create a map to determine whether a Designation Detail is of Allocation Division Code "V025" (Rockne) or not
                            if (!ddIdToIsRockneDivisionMap.containsKey(hsc.ucinn_ascendv2__Designation_Detail__c)) {
                                if (hsc.ucinn_ascendv2__Designation__r.ND_Division_Code__c == ALLOCATION_DIVISION_CODE_ROCKNE) { // clin 01/04/2024 - changed nd_Allocation_Division_Code__c to ucinn_ascendv2__Designation__r.ND_Division_Code__c
                                    ddIdToIsRockneDivisionMap.put(hsc.ucinn_ascendv2__Designation_Detail__c, true);
                                } else {
                                    ddIdToIsRockneDivisionMap.put(hsc.ucinn_ascendv2__Designation_Detail__c, false);
                                }
                            }
                        } else {
                            nonUNIVUNRddIdSet.add(hsc.ucinn_ascendv2__Designation_Detail__c);
                        }
                    }

                    // collect all Constituent Ids to use for getting the related records
                    if (hsc.ucinn_ascendv2__Contact__c != null) {
                        if (hsc.Designation_Unrestricted_Type__c == DESIG_UNRESTRICTED_TYPE_UNIVUNR) {
                            if (hsc.ucinn_ascendv2__Designation__r.ND_Division_Code__c == ALLOCATION_DIVISION_CODE_ROCKNE) { // clin 01/04/2024 - changed nd_Allocation_Division_Code__c to ucinn_ascendv2__Designation__r.ND_Division_Code__c
                                conIdsRockne.add(hsc.ucinn_ascendv2__Contact__c);
                            } else {
                                conIdsNonRockne.add(hsc.ucinn_ascendv2__Contact__c);
                            }
                        } else {
                            conIdsNonUNIVUNR.add(hsc.ucinn_ascendv2__Contact__c);
                        }
                    }
                }
            }
        }

        // Retrieve related records of contacts for rockne criteria evaluation
        if (!conIdsRockne.isEmpty()) {
            rockneSettings = getUNIVUNRMembershipCreditSettings(true);
            rockneMdtToConIdToRelatedRecsMap = getContactsRelatedRecs(rockneSettings, conIdsRockne);
        }

        // Retrieve related records of contacts for non-rockne criteria evaluation
        if (!conIdsNonRockne.isEmpty()) {
            nonRockneSettings = getUNIVUNRMembershipCreditSettings(false);
            nonRockneMdtToConIdToRelatedRecsMap = getContactsRelatedRecs(nonRockneSettings, conIdsNonRockne);
        }

        // Retrieve related records of contacts for non-UNIVUNR criteria evaluation
        if (!conIdsNonUNIVUNR.isEmpty()) {
            nonUNIVUNRSettings = getNonUNIVUNRMembershipCreditSettings();
            nonUNIVUNRMdtToConIdToRelatedRecsMap = getContactsRelatedRecs(nonUNIVUNRSettings, conIdsNonUNIVUNR);

        }

        for (Id pldgPmtId: pldgPmtIdToDDIdToHSCRecsMap.keySet()) {
            for (Id ddId : pldgPmtIdToDDIdToHSCRecsMap.get(pldgPmtId).keySet()) {
                // Identify if Designation Detail is UNIVUNR or not
                if (nonUNIVUNRddIdSet.contains(ddId)) {
                    // Run "non-UNIVUNR/Other Gift Membership Credit Default Logic" here
                    ucinn_ascendv2__Hard_and_Soft_Credit__c nonUNIVUNRHSC = evaluateSpouseMembershipCredit(pldgPmtIdToDDIdToHSCRecsMap.get(pldgPmtId).get(ddId), nonUNIVUNRSettings, nonUNIVUNRMdtToConIdToRelatedRecsMap);
                    if (nonUNIVUNRHSC != null) {
                        if (nonUNIVUNRHSC.ucinn_ascendv2__Source__c == 'Pledge') {
                            nonUNIVUNRHSC.Membership_Amount__c = nonUNIVUNRHSC.ucinn_ascendv2__Credit_Amount__c;
                        } else {
                            nonUNIVUNRHSC.Membership_Amount__c = nonUNIVUNRHSC.ucinn_ascendv2__Payment__r.ND_Gift_Amount__c;
                        }
                        
                        hscListToUpdate.add(nonUNIVUNRHSC);
                    }
                } else {
                    // If HSC records are in a spousal relationship, identify if Designation Detail is Rockne or not
                    if (ddIdToIsRockneDivisionMap.containsKey(ddId)) {
                        if (ddIdToIsRockneDivisionMap.get(ddId)) {
                            // Run "Rockne Membership Credit Default Logic" here
                            ucinn_ascendv2__Hard_and_Soft_Credit__c rockneHSC = evaluateSpouseMembershipCredit(pldgPmtIdToDDIdToHSCRecsMap.get(pldgPmtId).get(ddId), rockneSettings, rockneMdtToConIdToRelatedRecsMap);
                            if (rockneHSC != null) {
                                if (rockneHSC.ucinn_ascendv2__Source__c == 'Pledge') {
                                    rockneHSC.Membership_Amount__c = rockneHSC.ucinn_ascendv2__Credit_Amount__c;
                                } else {
                                    rockneHSC.Membership_Amount__c = rockneHSC.ucinn_ascendv2__Payment__r.ND_Gift_Amount__c;
                                }
                                
                                hscListToUpdate.add(rockneHSC);
                            }

                            // ddIdToHSCRecsRockneMap.put(ddId, ddIdToHSCRecsFinalMap.get(ddId));
                        } else {
                            // Run "Non-Rockne Membership Credit Default Logic" here
                            ucinn_ascendv2__Hard_and_Soft_Credit__c nonRockneHSC = evaluateSpouseMembershipCredit(pldgPmtIdToDDIdToHSCRecsMap.get(pldgPmtId).get(ddId), nonRockneSettings, nonRockneMdtToConIdToRelatedRecsMap);
                            if (nonRockneHSC != null) {
                                if (nonRockneHSC.ucinn_ascendv2__Source__c == 'Pledge') {
                                    nonRockneHSC.Membership_Amount__c = nonRockneHSC.ucinn_ascendv2__Credit_Amount__c;
                                } else {
                                    nonRockneHSC.Membership_Amount__c = nonRockneHSC.ucinn_ascendv2__Payment__r.ND_Gift_Amount__c;
                                }
                                
                                hscListToUpdate.add(nonRockneHSC);
                            }

                            // ddIdToHSCRecsNonRockneMap.put(ddId, ddIdToHSCRecsFinalMap.get(ddId));
                        }
                    }
                }
            }
        }

        return hscListToUpdate;
    }

    public List<Membership_Credit_Setting__mdt> getUNIVUNRMembershipCreditSettings(Boolean isRockne) {
        return [SELECT Id, DeveloperName, MasterLabel, Is_Rockne__c, Order__c, Related_Object__c, Object_Filter_Crtieria__c, 
                    Match_Membership_Division_Code__c, Hard_Creditor_DCO__c, Contact_Field__c, Unrestricted_Type__c 
                FROM Membership_Credit_Setting__mdt WHERE Unrestricted_Type__c = 'UNIVUNR' AND Is_Rockne__c = :isRockne ORDER BY Order__c ASC];
    }

    public List<Membership_Credit_Setting__mdt> getNonUNIVUNRMembershipCreditSettings() {
        return [SELECT Id, DeveloperName, MasterLabel, Is_Rockne__c, Order__c, Related_Object__c, Object_Filter_Crtieria__c, 
                    Match_Membership_Division_Code__c, Hard_Creditor_DCO__c, Contact_Field__c, Unrestricted_Type__c 
                FROM Membership_Credit_Setting__mdt WHERE Unrestricted_Type__c = 'Other' ORDER BY Order__c ASC];
    }

    public Map<String, Map<Id, List<sObject>>> getContactsRelatedRecs(List<Membership_Credit_Setting__mdt> settingsMdt, Set<Id> contactIds) {
        Map<String, Map<Id, List<sObject>>> mdtNameToConIdToRelatedRecsMap = new Map<String, Map<Id, List<sObject>>>();

        for (Membership_Credit_Setting__mdt setting : settingsMdt) {
            if (setting.Related_Object__c != null && setting.Contact_Field__c != null) {
                String soqlString = 'SELECT';
                List<String> fieldsToQueryList = new List<String>();
                Set<String> fieldsToQuery = new Set<String>{'Id', 'Name'};
                fieldsToQuery.add(setting.Contact_Field__c);
                if (setting.Match_Membership_Division_Code__c) {
                    fieldsToQuery.add('ucinn_ascendv2__Giving_Society__r.nd_Division_Code__c');
                }
                fieldsToQueryList.addAll(fieldsToQuery);

                soqlString += ' ' + String.join(fieldsToQueryList, ', ');
                
                soqlString += ' FROM ' + setting.Related_Object__c;
                
                soqlString += ' WHERE ' + setting.Contact_Field__c + ' IN :contactIds';

                if (setting.Object_Filter_Crtieria__c != null) {
                    soqlString += ' AND (' + setting.Object_Filter_Crtieria__c + ')';
                }

                Map<Id, List<sObject>> conIdToRelatedRecsMap = new Map<Id, List<sObject>>();
                
                for (SObject relatedObjRec : Database.query(soqlString)) {
                    if (relatedObjRec.get(setting.Contact_Field__c) != null) {
                        Id conId = String.valueOf(relatedObjRec.get(setting.Contact_Field__c));

                        if (conIdToRelatedRecsMap.containsKey(conId)) {
                            conIdToRelatedRecsMap.get(conId).add(relatedObjRec);
                        } else {
                            conIdToRelatedRecsMap.put(conId, new List<sObject>{relatedObjRec});
                        }
                    }
                }

                mdtNameToConIdToRelatedRecsMap.put(setting.DeveloperName, conIdToRelatedRecsMap);
            }
        }

        return mdtNameToConIdToRelatedRecsMap;
    }

    public ucinn_ascendv2__Hard_and_Soft_Credit__c evaluateSpouseMembershipCredit(List<ucinn_ascendv2__Hard_and_Soft_Credit__c> hscRecsList, List<Membership_Credit_Setting__mdt> settingMdts, Map<String, Map<Id, List<sObject>>> mdtNameToConIdToRelatedRecsMap) {
        ucinn_ascendv2__Hard_and_Soft_Credit__c hscMemberCredit;
        
        if (settingMdts != null) {
            List<ucinn_ascendv2__Hard_and_Soft_Credit__c> hscRecsResults;
            
            // for each Setting MDT, evaluate the hscRecsList which contains the constituents in a spousal relationship
            for (Membership_Credit_Setting__mdt mdt : settingMdts) {
                hscRecsResults = new List<ucinn_ascendv2__Hard_and_Soft_Credit__c>();

                // Check each constituent of the HSC record if they have the criteria of this Setting MDT or not
                for (ucinn_ascendv2__Hard_and_Soft_Credit__c hsc : hscRecsList) {
                    // Setting MDT with Hard_Creditor_DCO__c == TRUE does not require checking the related records of the constituents and only check HSC details
                    if (mdt.Hard_Creditor_DCO__c) {
                        // Check which HSC record is Hard Credit or DCO
                        if (hsc.ucinn_ascendv2__Credit_Type__c == 'Hard' || hsc.ucinn_ascendv2__Is_Donor_Control__c) {
                            hscRecsResults.add(hsc);
                            // break; // exit loop once criteria matches. this will return the first HSC record found that is ucinn_ascendv2__Credit_Type__c == 'Hard' or ucinn_ascendv2__Is_Donor_Control__c == TRUE
                        }
                    }
                    // Setting MDT with Hard_Creditor_DCO__c == FALSE requires checking the related records of the constituents
                    else {
                        if (mdtNameToConIdToRelatedRecsMap.containsKey(mdt.DeveloperName)) {
                            // Check if constituent has the Related Records based on the criteria of this Setting MDT
                            if (mdtNameToConIdToRelatedRecsMap.get(mdt.DeveloperName).containsKey(hsc.ucinn_ascendv2__Contact__c)) {
                                // Setting MDT with Match_Membership_Division_Code__c == TRUE requires matching the ucinn_ascendv2__Giving_Society__r.nd_Division_Code__c of related Society Membership records to the HSC records's nd_Allocation_Division_Code__c
                                if (mdt.Match_Membership_Division_Code__c) {
                                    for (sObject relatedRec : mdtNameToConIdToRelatedRecsMap.get(mdt.DeveloperName).get(hsc.ucinn_ascendv2__Contact__c)) {
                                        if (hsc.ucinn_ascendv2__Designation__r.ND_Division_Code__c == relatedRec.getSobject('ucinn_ascendv2__Giving_Society__r').get('nd_Division_Code__c')) { // clin 01/04/2024 - changed nd_Allocation_Division_Code__c to ucinn_ascendv2__Designation__r.ND_Division_Code__c
                                            hscRecsResults.add(hsc);
                                            break; // exit loop if one of the related records matches. this is to avoid adding duplicate HSC record in hscRecsResults.
                                        }
                                    }
                                }
                                // Setting MDT with Match_Membership_Division_Code__c == FALSE requires checking the related records of the constituents if they exist or not
                                // if constituent has the Related Records, add this to the hscRecsResults list which means the constituent matches the criteria of the Setting MDT
                                else {
                                    hscRecsResults.add(hsc);
                                }
                            }
                            // else loop to the next HSC record or constituent to see if it matches the criteria of this Setting MDT
                        }
                        // else loop to the next HSC record or constituent to see if it matches the criteria of this Setting MDT
                    }
                }

                // return HSC record if only 1 HSC resulted a match with the criteria of this Setting MDT
                // else loop to the next Setting MDT for further evaluation(if no HSC or more than 1 HSCs matched then check next criteria)
                if (hscRecsResults.size() == 1) {
                    hscMemberCredit = hscRecsResults[0];
                    break; // exit loop if 1 result is returned. this HSC record is where the Membership Amount should apply to.
                }
            }

            // get the Primary Contact of the household if both constituents meet all criteria in the MDT
            if (hscRecsResults != null && hscRecsResults.size() == 2) {
                for (ucinn_ascendv2__Hard_and_Soft_Credit__c hsc : hscRecsResults) {
                    if (hsc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__Primary_Contact__c == hsc.ucinn_ascendv2__Contact__c) {
                        hscMemberCredit = hsc;
                    }
                }
            }
        } else {
            // No Membership_Credit_Setting__mdt records mean there's nothing to evaluate
            return null;
        }
        
        return hscMemberCredit;
    }

    /* public void defaultLogicSimplified(Trigger_ContextVariables trigContextVars, ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper) {
        system.debug('!new logic');
        List<ucinn_ascendv2__Hard_and_Soft_Credit__c> triggerNew = (List<ucinn_ascendv2__Hard_and_Soft_Credit__c>) trigContextVars.triggerNew;

        Set<Id> relatedOpportunityIds = new Set<Id>();
        Set<Id> relatedContactIds = new Set<Id>();
        Map<Id, ucinn_ascendv2__Hard_and_Soft_Credit__c> mapHscIdToHscDefaultLogicRocne = new Map<Id, ucinn_ascendv2__Hard_and_Soft_Credit__c>();
        Map<Id, ucinn_ascendv2__Hard_and_Soft_Credit__c> mapHscIdToHscDefaultLogicNonRocne = new Map<Id, ucinn_ascendv2__Hard_and_Soft_Credit__c>();


        for (ucinn_ascendv2__Hard_and_Soft_Credit__c hsc : triggerNew) {
            if (hsc.Designation_Unrestricted_Type__c == 'UNIVUNR' && hsc.Membership_Amount__c == null && hsc.ucinn_ascendv2__Contact__c != null) {
                relatedOpportunityIds.add(hsc.ucinn_ascendv2__Opportunity__c);
                relatedContactIds.add(hsc.ucinn_ascendv2__Contact__c);

                if (hsc.nd_Allocation_Division_Code__c == 'V025') {
                    mapHscIdToHscDefaultLogicRocne.put(hsc.Id, hsc);
                }
                else {
                    mapHscIdToHscDefaultLogicNonRocne.put(hsc.Id, hsc);
                }
            }
            // hsc.adderror('custom error2');
        }

        Map<Id, Contact> allRelatedContacts = new Map<Id, Contact>([SELECT Id, ucinn_ascendv2__Preferred_Spouse__c, nd_Partner_Significant_Other__c
                                                                    FROM Contact
                                                                    WHERE Id IN: relatedContactIds]);

        List<Opportunity> allRelatedOpportunities = [SELECT Id, (SELECT Id, ucinn_ascendv2__Credit_Amount__c, Membership_Amount__c, ucinn_ascendv2__Contact__c, ucinn_ascendv2__Designation__c, nd_Allocation_Division_Code__c, ucinn_ascendv2__Is_Donor_Control__c, ucinn_ascendv2__Credit_Type__c FROM ucinn_ascendv2__Hard_and_Soft_Credits_Opportunity__r)
                                                    FROM Opportunity 
                                                    WHERE Id IN: relatedOpportunityIds];

        for (Opportunity relatedOpportunity : allRelatedOpportunities) {
            List<ucinn_ascendv2__Hard_and_Soft_Credit__c> relatedHscs = relatedOpportunity.ucinn_ascendv2__Hard_and_Soft_Credits_Opportunity__r;
            for (ucinn_ascendv2__Hard_and_Soft_Credit__c relatedHsc : relatedHscs) {
                if (mapHscIdToHscDefaultLogicRocne.containsKey(relatedHsc.Id)) {
                    defaultLogicRocneSimplified(relatedOpportunity, relatedHsc, relatedHscs, allRelatedContacts);
                    //is rocne
                }
                else if (mapHscIdToHscDefaultLogicNonRocne.containsKey(relatedHsc.Id)) {
                    //is not rocne
                }
            }

        }

    } */

    /* public void defaultLogicRocneSimplified(Opportunity relatedOpportunity, ucinn_ascendv2__Hard_and_Soft_Credit__c initialHsc, List<ucinn_ascendv2__Hard_and_Soft_Credit__c> relatedHscs, Map<Id, Contact> allRelatedContacts) {
        Id personOneId;
        Id personTwoId;
        ucinn_ascendv2__Hard_and_Soft_Credit__c personOneHsc;
        ucinn_ascendv2__Hard_and_Soft_Credit__c personTwoHsc;

        personOneId = initialHsc.ucinn_ascendv2__Contact__c;
        if (allRelatedContacts.get(initialHsc.ucinn_ascendv2__Contact__c).ucinn_ascendv2__Preferred_Spouse__c != null) {
            personTwoId = allRelatedContacts.get(initialHsc.ucinn_ascendv2__Contact__c).ucinn_ascendv2__Preferred_Spouse__c;
        }
        else if (allRelatedContacts.get(initialHsc.ucinn_ascendv2__Contact__c).nd_Partner_Significant_Other__c != null) {
            personTwoId = allRelatedContacts.get(initialHsc.ucinn_ascendv2__Contact__c).nd_Partner_Significant_Other__c;
        }

        personOneHsc = initialHsc;

        for (ucinn_ascendv2__Hard_and_Soft_Credit__c relatedHsc : relatedHscs) {
            if (relatedHsc.ucinn_ascendv2__Contact__c == personTwoId) {
                personTwoHsc = relatedHsc;
            }
        }

    } */

    /* public void defaultLogicNotRocneSimplified(Map<Id, ucinn_ascendv2__Hard_and_Soft_Credit__c> mapHscIdToHscDefaultLogic) {
        for (Id hscId : mapHscIdToHscDefaultLogic.keySet()) {
            ucinn_ascendv2__Hard_and_Soft_Credit__c hsc = mapHscIdToHscDefaultLogic.get(hscId);

        }
    } */


    /* public void checkMembershipAmount(Trigger_ContextVariables trigContextVars, ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper) {
        List<ucinn_ascendv2__Hard_and_Soft_Credit__c> triggerNew = (List<ucinn_ascendv2__Hard_and_Soft_Credit__c>) trigContextVars.triggerNew;

        Set<Id> hscDefaultLogicIds = new Set<Id>();
        List<ucinn_ascendv2__Hard_and_Soft_Credit__c> hscsForDefaultLogic = new List<ucinn_ascendv2__Hard_and_Soft_Credit__c>();

        for (ucinn_ascendv2__Hard_and_Soft_Credit__c hsc : triggerNew) {
            if (hsc.Membership_Amount__c == null) {
                hscDefaultLogicIds.add(hsc.Id);
                hscsForDefaultLogic.add(hsc);
            }
            // hsc.adderror('custom error2');
        }

        if (hscDefaultLogicIds.size() > 0) {
            try {
                hscDefaultLogicNoBatch(hscsForDefaultLogic);
            }
            catch (Exception e) {
                triggerNew.get(0).adderror(e.getMessage());
            }


            // asc_HSCDefaultLogicBatch hscBatch = new asc_HSCDefaultLogicBatch(hscDefaultLogicIds);
            // database.executeBatch(hscBatch, 100);
        }
    } */

    /* public void hscDefaultLogicNoBatch(List<ucinn_ascendv2__Hard_and_Soft_Credit__c> hscs) {
        for (ucinn_ascendv2__Hard_and_Soft_Credit__c hsc : hscs) {
            //null check here and in the handler in case its related record was corrected in an earlier batch
            if (hsc.Membership_Amount__c == null) {
                List<ucinn_ascendv2__Hard_and_Soft_Credit__c> relatedHscs = getRelatedHscs(hsc);
                system.debug('!!! related hscs' + relatedHscs);
                defaultLogic(relatedHscs);

                
                //related hsc membership amount + related hsc membership amount = credit amount
            }
        }
    } */
    
    /**
     * @description                 Helper function turns List of failed Cases into Strings of legible URLs
     * 
     * @param   firstHsc            Hsc to request query from           
     * @return                      List of related hscs                
     */
    /* private List<ucinn_ascendv2__Hard_and_Soft_Credit__c> getRelatedHscs(ucinn_ascendv2__Hard_and_Soft_Credit__c firstHsc) {
        //get related Hscs from the first Hsc
        Opportunity oppo = [SELECT Id, (SELECT Id, ucinn_ascendv2__Credit_Amount__c, Membership_Amount__c, ucinn_ascendv2__Contact__c, ucinn_ascendv2__Designation__c, nd_Allocation_Division_Code__c, ucinn_ascendv2__Is_Donor_Control__c, ucinn_ascendv2__Credit_Type__c FROM ucinn_ascendv2__Hard_and_Soft_Credits_Opportunity__r)
                            FROM Opportunity 
                            WHERE Id =: firstHsc.ucinn_ascendv2__Opportunity__c LIMIT 1];
        //get the Hscs that are related from them and return them
        List<ucinn_ascendv2__Hard_and_Soft_Credit__c> relatedHscs = oppo.ucinn_ascendv2__Hard_and_Soft_Credits_Opportunity__r;
        return relatedHscs; 
    } */

    /* private void defaultLogic(List<ucinn_ascendv2__Hard_and_Soft_Credit__c> relatedHscs) {

        //Check if dco or not
        ucinn_ascendv2__Hard_and_Soft_Credit__c personOneHsc = getHscWithDco(relatedHscs);
        ucinn_ascendv2__Hard_and_Soft_Credit__c personTwoHsc;

        if (personOneHsc != null) {
            system.debug('!!! is Dco ');
            ucinn_ascendv2__Hard_and_Soft_Credit__c hscOfPersonTwo;

            Id spouseIdFromHsc = getSpouseIdFromHsc(personOneHsc);

            if (spouseIdFromHsc != null) {
                //find if the spouse is present in the related hscs
                for (ucinn_ascendv2__Hard_and_Soft_Credit__c hsc : relatedHscs) {
                    if (hsc.ucinn_ascendv2__Contact__c == spouseIdFromHsc) {
                        //this is hsc of personTwo
                        personTwoHsc = hsc;
                    }
                }
            }
        }
        else {
            system.debug('!!! is not Dco ');
            personOneHsc = getHscWithoutDco(relatedHscs);
system.debug('personOneHsc?' + personOneHsc);
system.debug('personOneHsc? Contact' + personOneHsc.ucinn_ascendv2__Contact__c);

            Id spouseIdFromHsc = getSpouseIdFromHsc(personOneHsc);
system.debug('spouseIdFromHsc ?' + spouseIdFromHsc );

            if (spouseIdFromHsc != null) {
                for (ucinn_ascendv2__Hard_and_Soft_Credit__c hsc : relatedHscs) {
                    if (hsc.ucinn_ascendv2__Contact__c == spouseIdFromHsc) {
                        //this is hsc of personTwo
                        personTwoHsc = hsc;
                    }                    
                }
            }
            // for (ucinn_ascendv2__Hard_and_Soft_Credit__c hsc : relatedHscs) {
            //     if (hsc.ucinn_ascendv2__Contact__c != null) {
            //         if (spouseIdFromHsc == null) {
            //             spouseIdFromHsc = 
            //             personOneHsc = hsc;
            //         }
            //         else if (hsc.ucinn_ascendv2__Contact__c == spouseIdFromHsc) {
            //             personTwoHsc = hsc;
            //         }
            //     }
            // }
        }
        
        ucinn_ascendv2__Hard_and_Soft_Credit__c hscToCreditTo = getHscToCreditTo(personOneHsc, personTwoHsc, relatedHscs);
        hscToCreditTo.Membership_Amount__c = hscToCreditTo.ucinn_ascendv2__Credit_Amount__c;
        system.debug('!!! updating hsc' + hscToCreditTo);
        update hscToCreditTo;
    } */


    /* private ucinn_ascendv2__Hard_and_Soft_Credit__c getHscToCreditTo(ucinn_ascendv2__Hard_and_Soft_Credit__c personOneHsc, ucinn_ascendv2__Hard_and_Soft_Credit__c personTwoHsc, List<ucinn_ascendv2__Hard_and_Soft_Credit__c> relatedHscs) {

        Contact personOne;
        Contact personTwo;

        if (personOneHsc.ucinn_ascendv2__Contact__c != null) {
            personOne = [SELECT Id, ucinn_ascendv2__Contact_Type__c, AccountId,
                        (SELECT Id, nd_Status__c, Name FROM ucinn_ascendv2__Society_Memberships_Contact__r),
                        (SELECT Id, ucinn_ascendv2__Involvement_Code__r.Name FROM ucinn_ascendv2__Involvements_Contact__r)
                        FROM Contact
                        WHERE Id =: personOneHsc.ucinn_ascendv2__Contact__c
                        LIMIT 1];
        }

        if (personTwoHsc == null) {
            system.debug('!!! is just one');
            return personOneHsc;    
        }
        else {
            if (personTwoHsc.ucinn_ascendv2__Contact__c != null) {
                personTwo = [SELECT Id, ucinn_ascendv2__Contact_Type__c, AccountId,
                            (SELECT Id, nd_Status__c, Name FROM ucinn_ascendv2__Society_Memberships_Contact__r),
                            (SELECT Id, ucinn_ascendv2__Involvement_Code__r.Name FROM ucinn_ascendv2__Involvements_Contact__r)
                            FROM Contact
                            WHERE Id =: personTwoHsc.ucinn_ascendv2__Contact__c
                            LIMIT 1];        
            }
        }

        //1. check if designation is unrestricted or restricted
        Boolean isDesignationRestricted = getIsDesignationRestricted(relatedHscs);
        system.debug('!!! isDesignationRestricted ' + isDesignationRestricted);

        //3. check if the people are recsoc
        Boolean personOneIsRecSoc = getIsPersonRecSoc(personOne);
        Boolean personTwoIsRecSoc = getIsPersonRecSoc(personTwo);
        system.debug('!!! personOneIsRecSoc ' + personOneIsRecSoc);
        system.debug('!!! personTwoIsRecSoc ' + personTwoIsRecSoc);

        //4. check if the people are alumni
        Boolean personOneIsAlumni = getIsPersonAlumni(personOne);
        Boolean personTwoIsAlumni = getisPersonAlumni(personTwo);
        system.debug('!!! personOneIsAlumni ' + personOneIsAlumni);
        system.debug('!!! personTwoIsAlumni ' + personTwoIsAlumni);

        //5. check if they are rocne gift
        Boolean hscIsRocneGift = getIsHscRocneGift(relatedHscs);
        system.debug('!!! hscIsRocneGift ' + hscIsRocneGift);

        //6. check if they are monogram
        Boolean personOneIsMonogram = getIsPersonMonogram(personOne);
        Boolean personTwoIsMonogram = getIsPersonMonogram(personTwo);
        system.debug('!!! personOneIsMonogram ' + personOneIsMonogram);
        system.debug('!!! personTwoIsMonogram ' + personTwoIsMonogram);

        Contact personToCreditTo = new Contact();
        if (isDesignationRestricted) {
            //designation is restricted
            if (personOneIsAlumni && !personTwoIsAlumni) {
                return personOneHsc;
            }
            else if (!personOneIsAlumni && !personTwoIsAlumni) {
                return personOneHsc;
            }
            else if (!personOneIsAlumni && personTwoIsAlumni) {
                return personTwoHsc;
            }
            else {
                CalloutException e = new CalloutException();
                e.setMessage('Please review: There are two alumni in an restricted gift');
                throw e;
                //both are alum, fall to review (but give to personOne)
            }

        }
        else {
            //designation is not restricted
            return getHscToCreditToUnrestricted(personOneHsc, personTwoHsc, personOne, personTwo, personOneIsRecSoc, personTwoIsRecSoc, personOneIsAlumni, personTwoIsAlumni, hscIsRocneGift, personOneIsMonogram, personTwoIsMonogram);                  
        }
        // ucinn_ascendv2__Hard_and_Soft_Credit__c hscToCreditTo = mapContactIdToRelatedHsc.get(personToCreditTo.Id);
        // hscToCreditTo.Membership_Amount__c = hscToCreditTo.ucinn_ascendv2__Credit_Amount__c;
        // update hscToCreditTo;

    } */


    /* private Boolean getIsDesignationRestricted(List<ucinn_ascendv2__Hard_and_Soft_Credit__c> relatedHscs) {

        ucinn_ascendv2__Hard_and_Soft_Credit__c hsc1 = relatedHscs.get(0);
        ucinn_ascendv2__Designation__c designation1 = [SELECT Id, Unrestricted_Type__c
                                                       FROM ucinn_ascendv2__Designation__c 
                                                       WHERE (Id =: hsc1.ucinn_ascendv2__Designation__c) LIMIT 1];

        if ((designation1.Unrestricted_Type__c != null) && (designation1.Unrestricted_Type__c.contains('UNIVUNR'))) {
            return False;
        }
        return True;
    } */

    // private Boolean getIsDco(List<ucinn_ascendv2__Hard_and_Soft_Credit__c> relatedHscs) {
    //     for (ucinn_ascendv2__Hard_and_Soft_Credit__c hsc : relatedHscs) {
    //         if (hsc.ucinn_ascendv2__Is_Donor_Control__c != null && hsc.ucinn_ascendv2__Is_Donor_Control__c) {
    //             return True;
    //         }
    //     }
    //     return False;
    // }

    /* private ucinn_ascendv2__Hard_and_Soft_Credit__c getHscWithDco(List<ucinn_ascendv2__Hard_and_Soft_Credit__c> relatedHscs) {
        for (ucinn_ascendv2__Hard_and_Soft_Credit__c hsc : relatedHscs) {
            if (hsc.ucinn_ascendv2__Is_Donor_Control__c != null && hsc.ucinn_ascendv2__Is_Donor_Control__c) {
                return hsc;
            }
        }
        return null;
    } */

    /* private ucinn_ascendv2__Hard_and_Soft_Credit__c getHscWithoutDco(List<ucinn_ascendv2__Hard_and_Soft_Credit__c> relatedHscs) {
        for (ucinn_ascendv2__Hard_and_Soft_Credit__c hsc : relatedHscs) {
            if (hsc.ucinn_ascendv2__Credit_Type__c != null && hsc.ucinn_ascendv2__Credit_Type__c == 'Hard') {
                return hsc;
            }
        }
        return null;
    } */

    /* private Id getSpouseIdFromHsc(ucinn_ascendv2__Hard_and_Soft_Credit__c hsc) {
        //This prevents it from breaking when the hsc is for orgs and has no associated Contact
        if (hsc.ucinn_ascendv2__Contact__c == null)  {
            return null;
        }
        Contact personOne = [SELECT Id, ucinn_ascendv2__Preferred_Spouse__c, nd_Partner_Significant_Other__c
                             FROM Contact
                             WHERE (Id =: hsc.ucinn_ascendv2__Contact__c)
                             LIMIT 1];

        if (personOne.ucinn_ascendv2__Preferred_Spouse__c != null) {
            return personOne.ucinn_ascendv2__Preferred_Spouse__c;
        }
        else if (personOne.nd_Partner_Significant_Other__c != null) {
            return personOne.nd_Partner_Significant_Other__c;
        }
        return null;
    } */

    /* private Boolean getIsPersonAlumni(Contact person) {
        if ((person.ucinn_ascendv2__Contact_Type__c != null) && (person.ucinn_ascendv2__Contact_Type__c.contains('AL'))) {
            return True;
        }
        return False;
    } */

    /* private Boolean getIsPersonRecSoc(Contact personWithRecSoc) {
        // Contact personWithRecSoc = [SELECT Id, 
        //                             (SELECT ID, Name FROM ucinn_ascendv2__Society_Memberships_Contact__r)
        //                             FROM Contact
        //                             WHERE (Id =: person.Id) LIMIT 1];

        List<ucinn_ascendv2__Society_Membership__c> recSocs = personWithRecSoc.ucinn_ascendv2__Society_Memberships_Contact__r;
        for (ucinn_ascendv2__Society_Membership__c recSoc : recSocs) {
            //need to check if honorary member = false? where is that?
            if ((recSoc.nd_Status__c != null) && recSoc.nd_Status__c.contains('Active') && !recSoc.nd_Status__c.contains('Honorary')) {
                return True;
            }
        }
        return False;
    } */

    /* private Boolean getIsHscRocneGift(List<ucinn_ascendv2__Hard_and_Soft_Credit__c> relatedHscs) {
        for (ucinn_ascendv2__Hard_and_Soft_Credit__c hsc : relatedHscs) {
            if ((hsc.nd_Allocation_Division_Code__c != null) && (hsc.nd_Allocation_Division_Code__c == 'V025')) {
                return True;
            }
        }
        return False;
    } */

    /* private Boolean getIsPersonMonogram(Contact personWithInvolvement) {
        // Contact personWithInvolvement = [SELECT Id, 
        //                                         (SELECT Id, ucinn_ascendv2__Involvement_Code__r.Name FROM ucinn_ascendv2__Involvements_Contact__r)
        //                                 FROM Contact
        //                                 WHERE (Id =: person.Id) LIMIT 1];
        List<ucinn_ascendv2__Involvement__c> involvements = personWithInvolvement.ucinn_ascendv2__Involvements_Contact__r;
        for (ucinn_ascendv2__Involvement__c involvement : involvements) {

            if ((involvement.ucinn_ascendv2__Involvement_Code__r.Name != null) && involvement.ucinn_ascendv2__Involvement_Code__r.Name.contains('Monogram')) {
                return True;
            }
        }
        return False;
    } */

    /* private ucinn_ascendv2__Hard_and_Soft_Credit__c getHscToCreditToUnrestricted (ucinn_ascendv2__Hard_and_Soft_Credit__c personOneHsc, ucinn_ascendv2__Hard_and_Soft_Credit__c personTwoHsc, Contact personOne, Contact personTwo, Boolean personOneIsRecSoc, Boolean personTwoIsRecSoc, Boolean personOneIsAlumni, Boolean personTwoIsAlumni, Boolean hscIsRocneGift, Boolean personOneIsMonogram, Boolean personTwoIsMonogram) {
        if (personOneIsRecSoc || personTwoIsRecSoc) {
            //default to whoever is recsoc
            if (personOneIsRecSoc) {
                return personOneHsc;
            }
            else if (personTwoIsRecsoc) {
                return personTwoHsc;
            }
        }
        else if (personOneIsAlumni || personTwoIsAlumni) {
            //whoever is alum
            if (personOneIsAlumni) {
                return personOneHsc;
            }
            else if (personTwoIsAlumni) {
                return personTwoHsc;
            }
        }
        else if (hscIsRocneGift && personOneIsMonogram && personTwoIsMonogram) {
            if (personOneIsMonogram) {
                return personOneHsc;
            }
            else if (personTwoIsMonogram) {
                return personTwoHsc;
            }
        }
        CalloutException e = new CalloutException();
        e.setMessage('Please review: This gift falls under no category');
        throw e;
        // return personOneHsc;         
    } */

}