@isTest
public with sharing class asc_BATCH_ProcessNcoaInterimsTest {
    @TestSetup
    static void setupData() {
        TracHier.HierarchyAPI.setTriggerDisabled();
        Contact con = new Contact();
        con.LastName = 'Ncoa';
        con.FirstName = 'Test';
        con.Constituent_Status__c = 'L';
        con.ucinn_ascendv2__Preferred_Address_Line_1__c = '123 Any St';
        con.ucinn_ascendv2__Preferred_Address_City__c = 'Any City';
        insert con;

        Contact spouse = new Contact();
        spouse.LastName = 'Ncoa';
        spouse.FirstName = 'Spouse';
        spouse.Constituent_Status__c = 'A';
        spouse.ucinn_ascendv2__Preferred_Address_Line_1__c = '555 First St';
        spouse.ucinn_ascendv2__Preferred_Address_City__c = 'Los Angeles';
        insert spouse;

        ucinn_ascendv2__Reciprocal_Relationships__c setting1 = new ucinn_ascendv2__Reciprocal_Relationships__c();
        setting1.Name = 'Spouse';
        setting1.ucinn_ascendv2__Reciprocal__c = 'Spouse';
        insert setting1;

        ucinn_ascendv2__Relationship__c rel = new ucinn_ascendv2__Relationship__c();
        rel.ucinn_ascendv2__Contact__c = con.Id;
        rel.ucinn_ascendv2__Related_Contact__c = spouse.Id;
        rel.ucinn_ascendv2__Related_Contact_Role__c = 'Spouse';
        rel.ucinn_ascendv2__Data_Source__c ='AA';
        rel.nd_Do_Not_Sync_Home_Address__c = true;
        rel.nd_Do_Not_Sync_Seasonal_Address__c = true;
        insert rel;

        ucinn_ascendv2__Address__c addr1 = new ucinn_ascendv2__Address__c();
        addr1.ucinn_ascendv2__Address_Line_1__c = '123 Any St';
        addr1.ucinn_ascendv2__City__c = 'Any City';
        addr1.ucinn_ascendv2__State__c = 'CA';
        addr1.ucinn_ascendv2__Postal_Code__c = '90001';
        insert addr1;

        ucinn_ascendv2__Address__c addr2 = new ucinn_ascendv2__Address__c();
        addr2.ucinn_ascendv2__Address_Line_1__c = '555 First St';
        addr2.ucinn_ascendv2__City__c = 'Los Angeles';
        addr2.ucinn_ascendv2__State__c = 'CA';
        addr2.ucinn_ascendv2__Postal_Code__c = '90017';
        insert addr2;

        ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger('ucinn_ascendv2__Address_Relation__c', false);
        Id conAddRelRecTypeId = Schema.SObjectType.ucinn_ascendv2__Address_Relation__c.getRecordTypeInfosByDeveloperName().get('Contact_Address_Relation').getRecordTypeId();
        ucinn_ascendv2__Address_Relation__c addrRel1 = new ucinn_ascendv2__Address_Relation__c();
        addrRel1.ucinn_ascendv2__Contact__c = con.Id;
        addrRel1.ucinn_ascendv2__Address__c = addr1.Id;
        addrRel1.ucinn_ascendv2__Status__c = 'Current';
        addrRel1.ucinn_ascendv2__Seasonal_Start_Day__c = '01';
        addrRel1.ucinn_ascendv2__Seasonal_Start_Month__c = '08';
        addrRel1.ucinn_ascendv2__Seasonal_End_Day__c = '31';
        addrRel1.ucinn_ascendv2__Seasonal_End_Month__c = '05';
        addrRel1.ucinn_ascendv2__Type__c = 'Seasonal';
        addrRel1.RecordTypeId = conAddRelRecTypeId;
        insert addrRel1;

        ucinn_ascendv2__Address_Relation__c addrRel2 = new ucinn_ascendv2__Address_Relation__c();
        addrRel2.ucinn_ascendv2__Contact__c = spouse.Id;
        addrRel2.ucinn_ascendv2__Address__c = addr2.Id;
        addrRel2.ucinn_ascendv2__Status__c = 'Current';
        addrRel2.ucinn_ascendv2__Type__c = 'H';
        addrRel2.RecordTypeId = conAddRelRecTypeId;
        insert addrRel2;
        ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger('ucinn_ascendv2__Address_Relation__c', true);
    }

    @isTest
    static void testProcessNcoaInterims() {
        TracHier.HierarchyAPI.setTriggerDisabled();
        Id interimNcoaRecTypeId = Schema.SObjectType.ucinn_ascendv2__Interim__c.getRecordTypeInfosByDeveloperName().get('NCOA').getRecordTypeId();

        Contact con = [SELECT Id FROM Contact WHERE Name = 'Test Ncoa' LIMIT 1];

        ucinn_ascendv2__Interim__c interim = new ucinn_ascendv2__Interim__c();
        interim.ucinn_ascendv2__Status__c = 'New';
        interim.ucinn_ascendv2__Contact__c = con.Id;
        interim.ucinn_ascendv2__Address_1_Line_1__c = '123 Any St';
        interim.ucinn_ascendv2__City_1__c = 'Any City';
        interim.ucinn_ascendv2__State_1__c = 'CA';
        interim.ucinn_ascendv2__Postal_Code_1__c = '90001';
        interim.ucinn_ascendv2__Verification_Source__c = 'SmartyStreets API';
        interim.RecordTypeId = interimNcoaRecTypeId;
        insert interim;

        Test.startTest();
        TracHier.HierarchyAPI.setTriggerDisabled();
        Database.executeBatch(new asc_BATCH_ProcessNcoaInterims());
        Test.stopTest();
    }

    @isTest
    static void testProcessNcoaInterimsWithSourceFile() {
        TracHier.HierarchyAPI.setTriggerDisabled();
        Id interimNcoaRecTypeId = Schema.SObjectType.ucinn_ascendv2__Interim__c.getRecordTypeInfosByDeveloperName().get('NCOA').getRecordTypeId();

        Contact con = [SELECT Id FROM Contact WHERE Name = 'Test Ncoa' LIMIT 1];

        ucinn_ascendv2__Interim__c interim = new ucinn_ascendv2__Interim__c();
        interim.ucinn_ascendv2__Status__c = 'New';
        interim.ucinn_ascendv2__Contact__c = con.Id;
        interim.ucinn_ascendv2__Address_1_Line_1__c = '123 Any St';
        interim.ucinn_ascendv2__City_1__c = 'Any City';
        interim.ucinn_ascendv2__State_1__c = 'CA';
        interim.ucinn_ascendv2__Postal_Code_1__c = '90001';
        interim.ucinn_ascendv2__Source_File__c = 'NCOA_Test';
        interim.RecordTypeId = interimNcoaRecTypeId;
        insert interim;

        Test.startTest();
        TracHier.HierarchyAPI.setTriggerDisabled();
        Database.executeBatch(new asc_BATCH_ProcessNcoaInterims('NCOA_Test'));
        Test.stopTest();
    }

    @isTest
    static void testProcessNcoaInterimsWithOnFinishEnabled() {
        TracHier.HierarchyAPI.setTriggerDisabled();
        Id interimNcoaRecTypeId = Schema.SObjectType.ucinn_ascendv2__Interim__c.getRecordTypeInfosByDeveloperName().get('NCOA').getRecordTypeId();

        Contact con = [SELECT Id FROM Contact WHERE Name = 'Test Ncoa' LIMIT 1];

        ucinn_ascendv2__Interim__c interim = new ucinn_ascendv2__Interim__c();
        interim.ucinn_ascendv2__Status__c = 'New';
        interim.ucinn_ascendv2__Contact__c = con.Id;
        interim.ucinn_ascendv2__Address_1_Line_1__c = '123 Any St';
        interim.ucinn_ascendv2__City_1__c = 'Any City';
        interim.ucinn_ascendv2__State_1__c = 'CA';
        interim.ucinn_ascendv2__Postal_Code_1__c = '90001';
        interim.ucinn_ascendv2__Verification_Source__c = 'SmartyStreets API';
        interim.ucinn_ascendv2__Is_Verified__c = true;
        interim.ucinn_ascendv2__DPV_Match_Code__c = 'Y';
        interim.RecordTypeId = interimNcoaRecTypeId;
        insert interim;

        Test.startTest();
        TracHier.HierarchyAPI.setTriggerDisabled();
        Database.executeBatch(new asc_BATCH_ProcessNcoaInterims(true));
        Test.stopTest();
    }

}