@isTest
public with sharing class ND_InterimProcessorTest {

    @TestSetup 
    static void setupData() {
        ucinn_ascendv2__Trigger_Handler__c customHandler = new ucinn_ascendv2__Trigger_Handler__c();
        customHandler.Name = 'asc_TRIG_InterimHandler';
        customHandler.ucinn_ascendv2__Class__c = 'asc_TRIG_InterimHandler';
        customHandler.ucinn_ascendv2__Is_Active__c = true;
        customHandler.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Interim__c';
        customHandler.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;BeforeDelete;AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
        customHandler.ucinn_ascendv2__Load_Order__c = 2;
        insert customHandler;

    }

    @isTest
    static void testUpdateContactRTv2() {
        ucinn_ascendv2__Interim__c interim = new ucinn_ascendv2__Interim__c();
        interim.ucinn_ascendv2__Status__c = 'New';
        interim.ucinn_ascendv2__Address_1_Line_1__c = '123 Any St';
        interim.ucinn_ascendv2__City_1__c = 'Any City';
        interim.ucinn_ascendv2__State_1__c = 'CA';
        interim.ucinn_ascendv2__Postal_Code_1__c = '90001';
        interim.ucinn_ascendv2__Verification_Source__c = 'SmartyStreets API';
        insert interim;

        ucinn_ascendv2__Review_Transaction_v2__c rtv2 = new ucinn_ascendv2__Review_Transaction_v2__c();
        rtv2.ucinn_ascendv2__External_System_ID__c = 'RTV2-001';
        rtv2.ucinn_ascendv2__Interim__c = interim.Id;
        rtv2.ucinn_ascendv2__Transaction_Type__c = 'Gift';
        rtv2.ucinn_ascendv2__Transaction_Date__c = System.today();
        insert rtv2;

        Contact con = new Contact();
        con.LastName = 'Ncoa';
        con.FirstName = 'Test';
        con.Constituent_Status__c = 'A';
        insert con;

        interim.ucinn_ascendv2__Contact__c = con.Id;
        update interim;
    }

    @isTest
    static void testInterimAddressVerifier() {
        Contact con = new Contact();
        con.LastName = 'Addr';
        con.FirstName = 'Test';
        con.Constituent_Status__c = 'A';
        insert con;

        ucinn_ascendv2__Interim__c interim = new ucinn_ascendv2__Interim__c();
        interim.ucinn_ascendv2__Status__c = 'New';
        interim.ucinn_ascendv2__Contact__c = con.Id;
        interim.ucinn_ascendv2__Address_1_Line_1__c = '123 Any St';
        interim.ucinn_ascendv2__City_1__c = 'Any City';
        interim.ucinn_ascendv2__State_1__c = 'CA';
        interim.ucinn_ascendv2__Postal_Code_1__c = '90001';
        insert interim;

        //ND_InterimProcessor.InterimAddressVerifier();
    }
    /*
    @isTest
    static void testLostContact() {
        Contact con = new Contact();
        con.LastName = 'Ncoa';
        con.FirstName = 'Test';
        con.Constituent_Status__c = 'L';
        con.ucinn_ascendv2__Preferred_Address_Line_1__c = '123 Any St';
        con.ucinn_ascendv2__Preferred_Address_City__c = 'Any City';
        insert con;

        Id interimNcoaRecTypeId = Schema.SObjectType.ucinn_ascendv2__Interim__c.getRecordTypeInfosByDeveloperName().get('NCOA').getRecordTypeId();
        ucinn_ascendv2__Interim__c interim = new ucinn_ascendv2__Interim__c();
        interim.ucinn_ascendv2__Status__c = 'New';
        interim.ucinn_ascendv2__Contact__c = con.Id;
        interim.ucinn_ascendv2__Address_1_Line_1__c = '123 Any St';
        interim.ucinn_ascendv2__City_1__c = 'Any City';
        interim.ucinn_ascendv2__State_1__c = 'CA';
        interim.ucinn_ascendv2__Postal_Code_1__c = '90001';
        interim.ucinn_ascendv2__Manual_Review_Reason_Multiple_Line__c = 'test non-blank';
        interim.RecordTypeId = interimNcoaRecTypeId;
        insert interim;
    }

    @isTest
    static void testUncleanedAddress() {
        Id interimNcoaRecTypeId = Schema.SObjectType.ucinn_ascendv2__Interim__c.getRecordTypeInfosByDeveloperName().get('NCOA').getRecordTypeId();
        ucinn_ascendv2__Interim__c interim = new ucinn_ascendv2__Interim__c();
        interim.ucinn_ascendv2__Status__c = 'New';
        interim.ucinn_ascendv2__Address_1_Line_1__c = '123 Any St';
        interim.ucinn_ascendv2__City_1__c = 'Any City';
        interim.ucinn_ascendv2__State_1__c = 'CA';
        interim.ucinn_ascendv2__Postal_Code_1__c = '90001';
        interim.ucinn_ascendv2__Verification_Source__c = 'SmartyStreets API';
        interim.RecordTypeId = interimNcoaRecTypeId;
        insert interim;
    }
    */
}