public without sharing class asc_BATCH_ProcessNcoaInterims implements Database.Batchable<sObject> {

    String queryString;
    String sourceFile;
    Boolean enableOnFinish;

    public asc_BATCH_ProcessNcoaInterims() {
        enableOnFinish = false;
        queryString = 'SELECT Id, ucinn_ascendv2__Contact__c, ucinn_ascendv2__Status__c, ' +
                            'ucinn_ascendv2__Address_1_Line_1__c, ucinn_ascendv2__Address_1_Line_2__c, ' +
                            'ucinn_ascendv2__City_1__c, ucinn_ascendv2__State_1__c, ' +
                            'ucinn_ascendv2__Postal_Code_1__c, ucinn_ascendv2__Country_1__c, ' +
                            'ucinn_ascendv2__Verification_Source__c, ucinn_ascendv2__DPV_Match_Code__c, ' +
                            'ucinn_ascendv2__DPV_Vacant__c, ' + 
                            'ucinn_ascendv2__Manual_Review_Reason_Multiple_Line__c ' +
                      'FROM ucinn_ascendv2__Interim__c ' +
                      'WHERE nd_RecordType_DeveloperName__c = \'NCOA\' ' +
                            'AND ucinn_ascendv2__Status__c = \'New\' ' +
                            'AND ucinn_ascendv2__Contact__c != null';
    }

    public asc_BATCH_ProcessNcoaInterims(String sourceFileName) {
        enableOnFinish = false;
        sourceFile = sourceFileName;
        queryString = 'SELECT Id, ucinn_ascendv2__Contact__c, ucinn_ascendv2__Status__c, ' +
                            'ucinn_ascendv2__Address_1_Line_1__c, ucinn_ascendv2__Address_1_Line_2__c, ' +
                            'ucinn_ascendv2__City_1__c, ucinn_ascendv2__State_1__c, ' +
                            'ucinn_ascendv2__Postal_Code_1__c, ucinn_ascendv2__Country_1__c, ' +
                            'ucinn_ascendv2__Verification_Source__c, ucinn_ascendv2__DPV_Match_Code__c, ' +
                            'ucinn_ascendv2__DPV_Vacant__c, ' + 
                            'ucinn_ascendv2__Manual_Review_Reason_Multiple_Line__c ' +
                      'FROM ucinn_ascendv2__Interim__c ' +
                      'WHERE nd_RecordType_DeveloperName__c = \'NCOA\' ' +
                            'AND ucinn_ascendv2__Status__c != \'Completed\' ' +
                            'AND ucinn_ascendv2__Contact__c != null ' + 
                            'AND ucinn_ascendv2__Source_File__c = :sourceFile';
    }

    public asc_BATCH_ProcessNcoaInterims(Boolean ascendInterimBatchesOnFinish) {
        enableOnFinish = ascendInterimBatchesOnFinish;
        queryString = 'SELECT Id, ucinn_ascendv2__Contact__c, ucinn_ascendv2__Status__c, ' +
                            'ucinn_ascendv2__Address_1_Line_1__c, ucinn_ascendv2__Address_1_Line_2__c, ' +
                            'ucinn_ascendv2__City_1__c, ucinn_ascendv2__State_1__c, ' +
                            'ucinn_ascendv2__Postal_Code_1__c, ucinn_ascendv2__Country_1__c, ' +
                            'ucinn_ascendv2__Verification_Source__c, ucinn_ascendv2__DPV_Match_Code__c, ' +
                            'ucinn_ascendv2__DPV_Vacant__c, ' + 
                            'ucinn_ascendv2__Manual_Review_Reason_Multiple_Line__c ' +
                      'FROM ucinn_ascendv2__Interim__c ' +
                      'WHERE nd_RecordType_DeveloperName__c = \'NCOA\' ' +
                            'AND ucinn_ascendv2__Status__c = \'New\' ' +
                            'AND ucinn_ascendv2__Contact__c != null';
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(queryString);
    }

    public void execute(Database.BatchableContext bc, List<ucinn_ascendv2__Interim__c> interimList){
        Set<Id> contactIdSet = new Set<Id>();
        for (ucinn_ascendv2__Interim__c interim : interimList) {
            contactIdSet.add(interim.ucinn_ascendv2__Contact__c);
        }

        // get contacts along with seasonal address records and spouse relationships
        Map<Id, Contact> contactMap = new Map<Id, Contact>([
            SELECT Id, Constituent_Status__c,
                (SELECT Id, ucinn_ascendv2__Address__r.ucinn_ascendv2__Address_Line_1__c,
                    ucinn_ascendv2__Address__r.ucinn_ascendv2__Address_Line_2__c, ucinn_ascendv2__Address__r.ucinn_ascendv2__City__c,
                    ucinn_ascendv2__Address__r.ucinn_ascendv2__State__c, ucinn_ascendv2__Address__r.ucinn_ascendv2__Postal_Code__c,
                    ucinn_ascendv2__Address__r.ucinn_ascendv2__Country__c
                 FROM ucinn_ascendv2__Address_Relations_Contact__r
                 WHERE ucinn_ascendv2__Type__c = 'Seasonal' AND ucinn_ascendv2__Is_Active_Seasonal_Address__c = TRUE),
                 (SELECT Id, ucinn_ascendv2__Related_Contact__c
                  FROM ucinn_ascendv2__Relationships_Contact__r
                  WHERE ucinn_ascendv2__Related_Contact_Role__c = 'Spouse')
            FROM Contact
            WHERE Id IN :contactIdSet
        ]);

        // get spouse ids
        Set<Id> contactAndSpouseIdSet = new Set<Id>();
        for (Contact con : contactMap.values()) {
            if (con.ucinn_ascendv2__Relationships_Contact__r != null && con.ucinn_ascendv2__Relationships_Contact__r.size() > 0) {
                contactAndSpouseIdSet.add(con.Id);
                contactAndSpouseIdSet.add(con.ucinn_ascendv2__Relationships_Contact__r[0].ucinn_ascendv2__Related_Contact__c);
            }
        }

        // get contacts and spouses along with their preferred address and joint mailing service indicator
        Map<Id, Contact> contactAndSpouseMap = new Map<Id, Contact> ([
            SELECT Id, ucinn_ascendv2__Salutation_Preference__c,
                   ucinn_ascendv2__Preferred_Address_Line_1__c, ucinn_ascendv2__Preferred_Address_City__c,
                (SELECT Id
                 FROM ucinn_ascendv2__Service_Indicators_Contact__r
                 WHERE ucinn_ascendv2__Code_Formula__c = 'DNS' AND ucinn_ascendv2__Is_Active__c = TRUE)
            FROM Contact
            WHERE ID IN :contactAndSpouseIdSet
        ]);

        List<ucinn_ascendv2__Interim__c> interimsToUpdate = new List<ucinn_ascendv2__Interim__c>();
        for (ucinn_ascendv2__Interim__c interim : interimList) {
            Boolean bUpdateInterim = false;

            addressContainer interimAddress = new addressContainer(interim.ucinn_ascendv2__Address_1_Line_1__c,
                                                                   interim.ucinn_ascendv2__Address_1_Line_2__c,
                                                                   interim.ucinn_ascendv2__City_1__c,
                                                                   interim.ucinn_ascendv2__State_1__c,
                                                                   interim.ucinn_ascendv2__Postal_Code_1__c,
                                                                   interim.ucinn_ascendv2__Country_1__c);
            System.debug('interimAddress=' + interimAddress);

            // check for lost contact
            if (contactMap.containsKey(interim.ucinn_ascendv2__Contact__c)) {
                if (contactMap.get(interim.ucinn_ascendv2__Contact__c).Constituent_Status__c == 'L') {
                    bUpdateInterim = true;
                    addManualReviewReason(interim, 'This constituent\'s status is Lost');
                }
            }

            // check for uncleaned address
            if (interim.ucinn_ascendv2__Verification_Source__c  != null
                    && (interim.ucinn_ascendv2__DPV_Match_Code__c == 'N' /*|| interim.ucinn_ascendv2__DPV_Match_Code__c == 'S'
                    || interim.ucinn_ascendv2__DPV_Match_Code__c == 'D'*/ || interim.ucinn_ascendv2__DPV_Match_Code__c == null)
                    && (interim.ucinn_ascendv2__DPV_Vacant__c == 'N' || interim.ucinn_ascendv2__DPV_Vacant__c == null)) {
                bUpdateInterim = true;
                addManualReviewReason(interim, 'NCOA address is not clean');
            }

            // check for seasonal address
            if (contactMap.containsKey(interim.ucinn_ascendv2__Contact__c)) {
                Contact interimContact = contactMap.get(interim.ucinn_ascendv2__Contact__c);
                if (interimContact.ucinn_ascendv2__Address_Relations_Contact__r != null
                        && interimContact.ucinn_ascendv2__Address_Relations_Contact__r.size() > 0) {
                    // for (ucinn_ascendv2__Address_Relation__c ar : interimContact.ucinn_ascendv2__Address_Relations_Contact__r) {
                    //     addressContainer contactAddress = new addressContainer(ar.ucinn_ascendv2__Address__r.ucinn_ascendv2__Address_Line_1__c,
                    //                                                            ar.ucinn_ascendv2__Address__r.ucinn_ascendv2__Address_Line_2__c,
                    //                                                            ar.ucinn_ascendv2__Address__r.ucinn_ascendv2__City__c,
                    //                                                            ar.ucinn_ascendv2__Address__r.ucinn_ascendv2__State__c,
                    //                                                            ar.ucinn_ascendv2__Address__r.ucinn_ascendv2__Postal_Code__c,
                    //                                                            ar.ucinn_ascendv2__Address__r.ucinn_ascendv2__Country__c);
                    //     System.debug('contactAddress=' + contactAddress);
                    //     if (compareAddress(contactAddress, interimAddress) == true) {
                            bUpdateInterim = true;
                            addManualReviewReason(interim, 'This constituent has a seasonal address');
                    //         break;
                    //     }
                    // }
                }
            }
/* jrizzi1 - removed per TASK0196606
            // check for spouses with different mailing addresses
            if (contactAndSpouseMap.containsKey(interim.ucinn_ascendv2__Contact__c)) {
                if (contactMap.containsKey(interim.ucinn_ascendv2__Contact__c)) {
                    List<ucinn_ascendv2__Relationship__c> relationships = contactMap.get(interim.ucinn_ascendv2__Contact__c).ucinn_ascendv2__Relationships_Contact__r;
                    if (relationships != null && relationships.size() > 0) {
                        Id spouseId = relationships[0].ucinn_ascendv2__Related_Contact__c;
                        Contact con = contactAndSpouseMap.get(interim.ucinn_ascendv2__Contact__c);
                        Contact spouse = contactAndSpouseMap.get(spouseId);
                        //if (con.ucinn_ascendv2__Service_Indicators_Contact__r != null && con.ucinn_ascendv2__Service_Indicators_Contact__r.size() > 0
                        if (con.ucinn_ascendv2__Salutation_Preference__c == 'Joint'
                                && spouse.ucinn_ascendv2__Salutation_Preference__c == 'Joint') {
                            if ((con.ucinn_ascendv2__Preferred_Address_Line_1__c != spouse.ucinn_ascendv2__Preferred_Address_Line_1__c)
                                    && (con.ucinn_ascendv2__Preferred_Address_City__c != spouse.ucinn_ascendv2__Preferred_Address_City__c)) {
                                bUpdateInterim = true;
                                addManualReviewReason(interim, 'Spouses with different addresses');
                            }
                        }
                    }
                }
            }

            if (bUpdateInterim == true) {
                interim.ucinn_ascendv2__Status__c = 'Manual Review';
                interimsToUpdate.add(interim);
            }*/
        }

        System.debug('interimsToUpdate[' + interimsToUpdate.size() + ']=' + interimsToUpdate);
        update interimsToUpdate;
    }

    public void finish(Database.BatchableContext bc)
    {
        if(enableOnFinish == true) {
            processVerifiedNCOAInterims();
        }
    }

    private Boolean compareAddress(addressContainer address1, addressContainer address2) {
        if (address1.line1 == address2.line1
            && address1.line2 == address2.line2
            && address1.city == address2.city
            && address1.state == address1.state
            && address1.postalCode == address2.postalCode
            && address1.country == address2.country) {
                return true;
            }
        return false;
    }

    private void addManualReviewReason(ucinn_ascendv2__Interim__c interim, String reason) {
        if (String.isBlank(interim.ucinn_ascendv2__Manual_Review_Reason_Multiple_Line__c)) {
            interim.ucinn_ascendv2__Manual_Review_Reason_Multiple_Line__c = reason; 
        }
        else {
            if(!interim.ucinn_ascendv2__Manual_Review_Reason_Multiple_Line__c.contains(reason)) {
                interim.ucinn_ascendv2__Manual_Review_Reason_Multiple_Line__c += ('\r\n' + reason);
            }
        }
    }

    class addressContainer {
        String line1;
        String line2;
        String city;
        String state;
        String postalCode;
        String country;

        addressContainer(String addrLine1, String addrLine2, String addrCity, String addrState, String addrPostalCode, String addrCountry) {
            line1 = addrline1;
            line2 = addrLine2;
            city = addrCity;
            state = addrState;
            postalCode = addrPostalCode;
            country = addrCountry;
        }
    }

    private void processVerifiedNCOAInterims() {
        Set<Id> interimIdSet = new Set<Id>();
        Map<Id, ucinn_ascendv2__Interim__c> interimMap = new Map<Id, ucinn_ascendv2__Interim__c>([
            SELECT Id
            FROM ucinn_ascendv2__Interim__c
            WHERE RecordType.DeveloperName = 'NCOA'
            AND ucinn_ascendv2__Status__c != 'Completed'
            AND ucinn_ascendv2__Contact__c != null
            AND ((ucinn_ascendv2__Is_Verified__c = TRUE
            AND ucinn_ascendv2__Verification_Source__c = 'SmartyStreets API'))
            //AND ucinn_ascendv2__DPV_Match_Code__c = 'Y' OR cVerification_Override__c = TRUE)
            LIMIT 50000
        ]);

        if (interimMap.keySet().isEmpty()) {
            return;
        }
        else {
            interimIdSet.addAll(interimMap.keySet());
        }

        Map<String, Object> interimBatchParams = new Map<String, Object>();
        interimBatchParams.put('customizedLogic_interimRecordTypeDeveloperName', 'NCOA');
        interimBatchParams.put('ascend_DEDUPE_ProcessInterimNewBatchSize', 100);
        interimBatchParams.put('ascend_DEDUPE_ProcessPendingBatchSize', 20);
        interimBatchParams.put('ascend_DEDUPE_ProcessInProgressBatchSize', 1);
        interimBatchParams.put('selectiveProcessing', true);
        interimBatchParams.put('selectedInterimIds', interimIdSet);
        try {
            ucinn_ascendv2.ascend_UTIL_RunBatch.processInterimsByRecordType(interimBatchParams);        
        } catch(Exception e) {
            System.debug('Error starting Interim Batch! ' + e.getMessage());
        }
    }
   
}