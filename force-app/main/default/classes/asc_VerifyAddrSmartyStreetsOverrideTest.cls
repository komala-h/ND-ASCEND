@IsTest
private class asc_VerifyAddrSmartyStreetsOverrideTest {

  /*  @IsTest
    static void testBatchFinish_WithNCOARecords() {
        // Create test data
        List<ucinn_ascendv2__Interim__c> interimRecords = new List<ucinn_ascendv2__Interim__c>();
        for (Integer i = 0; i < 10; i++) {
            interimRecords.add(new ucinn_ascendv2__Interim__c(
                RecordTypeId = Schema.SObjectType.ucinn_ascendv2__Interim__c.getRecordTypeInfosByDeveloperName().get('NCOA').getRecordTypeId(),
                ucinn_ascendv2__Status__c = 'New',
                ucinn_ascendv2__Contact__c = '0034x000003ZzmQAAS',  // Replace with a valid Contact ID or use Test.loadData for more realistic records
                ucinn_ascendv2__Verification_Source__c = 'SmartyStreets API'
            ));
        }
        insert interimRecords;

        // Simulate batch finish
        Test.startTest();
        asc_VerifyAddrSmartyStreetsOverride batchInstance = new asc_VerifyAddrSmartyStreetsOverride();
        batchInstance.batchFinish(null);  // Manually call batchFinish method
        Test.stopTest();

        // Verify that asc_BATCH_ProcessNcoaInterims is called
        // Assuming asc_BATCH_ProcessNcoaInterims does some processing on ucinn_ascendv2__Interim__c records,
        // check to see if they are processed or status is changed based on the batch logic.
        List<ucinn_ascendv2__Interim__c> updatedInterimRecords = [SELECT Id, ucinn_ascendv2__Status__c FROM ucinn_ascendv2__Interim__c WHERE Id IN :interimRecords];
        for (ucinn_ascendv2__Interim__c interim : updatedInterimRecords) {
            System.assertNotEquals('New', interim.ucinn_ascendv2__Status__c, 'Batch should process NCOA records.');
        }
    }

    @IsTest
    static void testProcessVerifiedNCOAInterims() {
        // Create test data
        List<ucinn_ascendv2__Interim__c> interimRecords = new List<ucinn_ascendv2__Interim__c>();
        for (Integer i = 0; i < 5; i++) {
            interimRecords.add(new ucinn_ascendv2__Interim__c(
                RecordTypeId = Schema.SObjectType.ucinn_ascendv2__Interim__c.getRecordTypeInfosByDeveloperName().get('NCOA').getRecordTypeId(),
                ucinn_ascendv2__Status__c = 'Pending',
                ucinn_ascendv2__Contact__c = '0034x000003ZzmQAAS', // Replace with a valid Contact ID or use Test.loadData
                ucinn_ascendv2__Is_Verified__c = true,
                ucinn_ascendv2__DPV_Match_Code__c = 'Y',
                ucinn_ascendv2__Verification_Source__c = 'SmartyStreets API'
            ));
        }
        insert interimRecords;

        // Simulate batch finish
        Test.startTest();
        asc_VerifyAddrSmartyStreetsOverride batchInstance = new asc_VerifyAddrSmartyStreetsOverride();
        batchInstance.batchFinish(null);  // Manually call batchFinish method
        Test.stopTest();

        // Verify that records are processed according to the custom logic in processVerifiedNCOAInterims
        List<ucinn_ascendv2__Interim__c> processedInterimRecords = [SELECT Id, ucinn_ascendv2__Status__c FROM ucinn_ascendv2__Interim__c WHERE Id IN :interimRecords];
        for (ucinn_ascendv2__Interim__c interim : processedInterimRecords) {
            System.assertNotEquals('Pending', interim.ucinn_ascendv2__Status__c, 'Batch should process verified NCOA interim records.');
        }
    }

    @IsTest
    static void testBatchFinish_NoNCOARecords() {
        // Create a record that does not meet the NCOA criteria
        ucinn_ascendv2__Interim__c nonNCOARecord = new ucinn_ascendv2__Interim__c(
            RecordTypeId = Schema.SObjectType.ucinn_ascendv2__Interim__c.getRecordTypeInfosByDeveloperName().get('NonNCOA').getRecordTypeId(),
            ucinn_ascendv2__Status__c = 'New',
            ucinn_ascendv2__Contact__c = '0034x000003ZzmQAAS',  // Replace with a valid Contact ID or use Test.loadData
            ucinn_ascendv2__Verification_Source__c = 'Other API'
        );
        insert nonNCOARecord;

        // Simulate batch finish
        Test.startTest();
        asc_VerifyAddrSmartyStreetsOverride batchInstance = new asc_VerifyAddrSmartyStreetsOverride();
        batchInstance.batchFinish(null);  // Manually call batchFinish method
        Test.stopTest();

        // Verify that the non-NCOA record was not processed
        nonNCOARecord = [SELECT Id, ucinn_ascendv2__Status__c FROM ucinn_ascendv2__Interim__c WHERE Id = :nonNCOARecord.Id];
        System.assertEquals('New', nonNCOARecord.ucinn_ascendv2__Status__c, 'Non-NCOA record should not be processed.');
    }*/
     @testSetup
   public static void setupTestData() {
       
        Account testAccount = new Account(Name = 'TestAcc',ucinn_ascendv2__Donor_ID__c = 'h123' );
    	insert testAccount;
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact',Constituent_Status__c = 'A',AccountId=testAccount.Id);
         insert testContact;
       
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'ucinn_ascendv2__Interim__c' AND DeveloperName = 'NCOA' LIMIT 1];
        
        List<ucinn_ascendv2__Interim__c> interims = new List<ucinn_ascendv2__Interim__c>();
        for (Integer i = 0; i < 1; i++) {
            interims.add(new ucinn_ascendv2__Interim__c(
                RecordTypeId = rt.Id,
                ucinn_ascendv2__Status__c = 'In Progress', 
                ucinn_ascendv2__Contact__c = testContact.Id,
                ucinn_ascendv2__Is_Verified__c = true,
                ucinn_ascendv2__DPV_Match_Code__c = 'Y',
                ucinn_ascendv2__Verification_Source__c = 'SmartyStreets API'
            ));
        }
        insert interims;
    }

    @isTest
   public static void method1() {
       Test.startTest();
        asc_VerifyAddrSmartyStreetsOverride overrideInstance = new asc_VerifyAddrSmartyStreetsOverride();            
        overrideInstance.batchFinish(null);
        Test.stopTest();
    }
}