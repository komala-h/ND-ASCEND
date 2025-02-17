public without sharing class ui_ProcessInitiationDashboardController {
    public static final Integer BATCH_SIZE = 7;
    
    @AuraEnabled
    public static AsyncApexJob runProcess(String batchToRun, Object params) {
        try {
            Id batchJobId;

            switch on batchToRun {
                when 'processNCOA' {
                    Integer batchSize = 200;
                    String objParam = 'ucinn_ascendv2__Interim__c';
                    String whereClause = 'ucinn_ascendv2__Verification_Source__c = null and nd_RecordType_DeveloperName__c = \'NCOA\'';
                    Set<String> matchCodeSet = new Set<String>{'Y','S','N','D',null};
                    Set<String> vacantSet = new Set<String>{'N','Y',null};
                    Set<String> verificationStatusSet = new Set<String>{'Verified'};
                    Set<String> addressPrecisionSet = new Set<String>{'Premise', 'DeliveryPoint'};

                    Map<String, String> addressFieldMap = new Map<String, String>();
                    addressFieldMap.put('addressLine1', 'ucinn_ascendv2__Address_1_Line_1__c');
                    addressFieldMap.put('city', 'ucinn_ascendv2__City_1__c');
                    addressFieldMap.put('state', 'ucinn_ascendv2__State_1__c');
                    addressFieldMap.put('postalCode', 'ucinn_ascendv2__Postal_Code_1__c');
                    addressFieldMap.put('country', 'ucinn_ascendv2__Country_1__c');
                    addressFieldMap.put('request', 'ucinn_ascendv2__Address_Verification_API_Request__c');
                    addressFieldMap.put('response', 'ucinn_ascendv2__Address_Verification_API_Response__c');
                    addressFieldMap.put('isVerified', 'ucinn_ascendv2__Is_Verified__c');
                    addressFieldMap.put('verificationSource', 'ucinn_ascendv2__Verification_Source__c');
                    addressFieldMap.put('verificationResponse', 'ucinn_ascendv2__Verification_Response__c');
                    addressFieldMap.put('dataSource', 'ucinn_ascendv2__Data_Source__c');
                    addressFieldMap.put('latitude', 'ucinn_ascendv2__Geolocation_1_Latitude__c');
                    addressFieldMap.put('longitude', 'ucinn_ascendv2__Geolocation_1_Longitude__c');
                    addressFieldMap.put('verificationDateTime', 'ucinn_ascendv2__Verification_Date_Time__c');
                    //addressFieldMap.put('county','County__c');
                    
                    Map<String, Set<String>> uspsParam = new Map<String, Set<String>>();
                    uspsParam.put('ucinn_ascendv2__DPV_Match_Code__c', matchCodeSet);
                    uspsParam.put('ucinn_ascendv2__DPV_Vacant__c', vacantSet);
                    
                    Map<String, Set<String>> internationalParam = new Map<String, Set<String>>();
                    internationalParam.put('ucinn_ascendv2__Verification_Status__c', verificationStatusSet);
                    internationalParam.put('ucinn_ascendv2__Address_Precision__c', addressPrecisionSet);

                    try {
                        ucinn_ascendv2.ascend_UTIL_RunBatch.ascend_ADDR_VerifyAddrSmartyStreetsBatch(whereClause, 
                                                                                                    uspsParam,
                                                                                                    internationalParam,
                                                                                                    objParam,
                                                                                                    addressFieldMap,
                                                                                                    batchSize);
                    } catch(Exception e) {
                        AuraHandledException clientException = new AuraHandledException('Error starting NCOA Batch! ' + e.getMessage());
                        clientException.setMessage('Error starting NCOA Batch! ' + e.getMessage());
                        throw clientException;
                    }

                    return null;
                }
            }

            if (batchJobId == null) {
                AuraHandledException clientException = new AuraHandledException(batchToRun + ' did not match any options for Export');
                clientException.setMessage(batchToRun + ' did not match any options for Export');
                throw clientException;            
            }

            AsyncApexJob apexJobRan = [SELECT Id, ApexClass.Name, Status, JobItemsProcessed,NumberOfErrors, TotalJobItems FROM AsyncApexJob WHERE Id = :batchJobId];
            if (apexJobRan != null
                    && apexJobRan.Status != 'Failed') {
                return apexJobRan;
            }

            AuraHandledException clientException = new AuraHandledException('Failed to Schedule Process ' + batchToRun);
            clientException.setMessage('Failed to Schedule Process ' + batchToRun);
            throw clientException; 

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}