/**
 * @author UC Innovation
 * @date 3/28/2023
 * @description Test class for Contact Card Trigger
 */
@isTest
private class TRIG_ContactCardHandlerTest {
    @TestSetup
    public static void testSetup() {

        ucinn_ascendv2__Reciprocal_Relationships__c setting1 = new ucinn_ascendv2__Reciprocal_Relationships__c();
        setting1.Name = 'Spouse';
        setting1.ucinn_ascendv2__Reciprocal__c = 'Spouse';
        insert setting1;

        ucinn_ascendv2__Reciprocal_Relationships__c setting2 = new ucinn_ascendv2__Reciprocal_Relationships__c();
        setting2.Name = 'Partner/Significant Other';
        setting2.ucinn_ascendv2__Reciprocal__c = 'Partner/Significant Other';
        insert setting2;

        ucinn_ascendv2__Reciprocal_Relationships__c setting3 = new ucinn_ascendv2__Reciprocal_Relationships__c();
        setting3.Name = 'Child';
        setting3.ucinn_ascendv2__Reciprocal__c = 'Child';
        insert setting3;

        ucinn_ascendv2__Trigger_Handler__c customHandler01 = new ucinn_ascendv2__Trigger_Handler__c();
        customHandler01.Name = 'Custom Contact Card Handler';
        customHandler01.ucinn_ascendv2__Class__c = 'TRIG_ContactCardHandler';
        customHandler01.ucinn_ascendv2__Is_Active__c = true;
        customHandler01.ucinn_ascendv2__Object__c = 'Contact_Card__c';
        customHandler01.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;BeforeDelete;AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
        customHandler01.ucinn_ascendv2__Load_Order__c = 1;
        insert customHandler01;

        ucinn_ascendv2__Trigger_Handler__c customHandler02 = new ucinn_ascendv2__Trigger_Handler__c();
        customHandler02.Name = 'Custom Relationship Handler';
        customHandler02.ucinn_ascendv2__Class__c = 'asc_TRIG_RelationshipHandler';
        customHandler02.ucinn_ascendv2__Is_Active__c = true;
        customHandler02.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Relationship__c';
        customHandler02.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;BeforeDelete;AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
        customHandler02.ucinn_ascendv2__Load_Order__c = 1;
        insert customHandler02;
        
        ucinn_ascendv2__Trigger_Handler__c handler = new ucinn_ascendv2__Trigger_Handler__c();
        handler.Name = 'Relationship Handler';
        handler.ucinn_ascendv2__Class__c = 'ascend_TRIG_RelationshipHandler';
        handler.ucinn_ascendv2__Is_Active__c = true;
        handler.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Relationship__c';
        handler.ucinn_ascendv2__Owned_by_Namespace__c = 'ucinn_ascendv2';
        handler.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;BeforeDelete;AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
        handler.ucinn_ascendv2__Load_Order__c = 2;
        insert handler;

        ucinn_ascendv2__Trigger_Handler__c handler2 = new ucinn_ascendv2__Trigger_Handler__c();
        handler2.Name = 'Relationship Handler';
        handler2.ucinn_ascendv2__Class__c = 'ascend_TRIG_AccountHandler';
        handler2.ucinn_ascendv2__Is_Active__c = true;
        handler2.ucinn_ascendv2__Object__c = 'Account';
        handler2.ucinn_ascendv2__Owned_by_Namespace__c = 'ucinn_ascendv2';
        handler2.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;BeforeDelete;AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
        handler2.ucinn_ascendv2__Load_Order__c = 2;
        insert handler2;

        Account acct1 = new Account(
            Name = 'acct1'
        );
        insert acct1;

        Account acct2 = new Account(
            Name = 'acct2'
        );
        insert acct2;
        
        Contact h01 = new Contact();
        h01.FirstName = 'h01';
        h01.LastName = 'TEST';
        h01.ucinn_ascendv2__Gender__c = 'Male';
        h01.ucinn_ascendv2__Contact_Type__c = 'AL';
        h01.ucinn_ascendv2__Personal_Email__c = 'sample@uci.com';
        h01.Constituent_Status__c = 'A';
        h01.AccountId = acct1.Id;
        insert h01;
        
        Contact contact_h01 = [Select Id, AccountId From Contact Where Id = :h01.Id];
        
        Contact w01 = new Contact();
        w01.AccountId = contact_h01.AccountId;
        w01.FirstName = 'w01';
        w01.LastName = 'TEST';
        w01.ucinn_ascendv2__Gender__c = 'Female';
        w01.ucinn_ascendv2__Contact_Type__c = 'AL';
        w01.ucinn_ascendv2__Preferred_Spouse__c = h01.Id;
        w01.ucinn_ascendv2__Personal_Email__c = 'sample2@uci.com';
        w01.Constituent_Status__c = 'A';
        w01.AccountId = acct2.Id;
        insert w01;
        
        h01.ucinn_ascendv2__Preferred_Spouse__c = w01.Id;
        update h01;
        
        Contact c01_01 = new Contact();
        c01_01.AccountId = contact_h01.AccountId;
        c01_01.FirstName = 'c01_01';
        c01_01.LastName = 'TEST';
        c01_01.ucinn_ascendv2__Gender__c = 'Female';
        c01_01.ucinn_ascendv2__Contact_Type__c = 'AL;ST';
        c01_01.ucinn_ascendv2__Personal_Email__c = 'sample3@uci.com';
        c01_01.Constituent_Status__c = 'A';
        insert c01_01;
        
        Contact c01_02 = new Contact();
        c01_02.AccountId = contact_h01.AccountId;
        c01_02.FirstName = 'c01_02';
        c01_02.LastName = 'TEST';
        c01_02.ucinn_ascendv2__Gender__c = 'Male';
        c01_02.ucinn_ascendv2__Contact_Type__c = 'AL;ST';
        c01_02.ucinn_ascendv2__Personal_Email__c = 'sample4@uci.com';
        c01_02.Constituent_Status__c = 'A';
        insert c01_02;

    }

    @isTest
    static void testSyncContactCardsWithSpouse() {
        Contact h01 = [Select Id, AccountId From Contact Where FirstName='h01' And LastName='TEST'];
        Contact w01 = [Select Id, AccountId From Contact Where FirstName='w01' And LastName='TEST'];

        String ncrRecordTypeID = Schema.SObjectType.Contact_Card__c.getRecordTypeInfosByName().get('Non-Constituent Relationship').getRecordTypeId();

        Contact_Card__c h01cc1 = new Contact_Card__c(
            First_Name__c = 'Batman',
            Last_Name__c = 'Test',
            Contact_Type__c = 'Child',
            Data_Source__c = 'AL',
            RecordTypeId = ncrRecordTypeID,
            Related_Constituent__c = h01.Id
        );
        insert h01cc1;

        ucinn_ascendv2__Relationship__c relationship01 = new ucinn_ascendv2__Relationship__c();
        relationship01.ucinn_ascendv2__Contact__c = h01.Id;
        relationship01.ucinn_ascendv2__Related_Contact__c = w01.Id;
        relationship01.ucinn_ascendv2__Related_Contact_Role__c = 'Spouse';
        relationship01.ucinn_ascendv2__Data_Source__c ='AA';
        relationship01.nd_Do_Not_Sync_Home_Address__c = false;
        relationship01.nd_Do_Not_Sync_Seasonal_Address__c = false;

        ucinn_ascendv2__Relationship__c relationship02 = new ucinn_ascendv2__Relationship__c();
        relationship02.ucinn_ascendv2__Contact__c = w01.Id;
        relationship02.ucinn_ascendv2__Related_Contact__c = h01.Id;
        relationship02.ucinn_ascendv2__Related_Contact_Role__c = 'Spouse';
        relationship02.ucinn_ascendv2__Data_Source__c ='AA';
        relationship02.nd_Do_Not_Sync_Home_Address__c = false;
        relationship02.nd_Do_Not_Sync_Seasonal_Address__c = false;

        ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger('ucinn_ascendv2__Relationship__c', false);
        insert relationship01;
        insert relationship02;
        ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger('ucinn_ascendv2__Relationship__c', true);

        List<Contact_Card__c> contactCardsOnh01 = [SELECT Id FROM Contact_Card__c WHERE (Related_Constituent__c =: h01.Id)];
        List<Contact_Card__c> contactCardsOnw01 = [SELECT Id FROM Contact_Card__c WHERE (Related_Constituent__c =: w01.Id)];
        system.assert(contactCardsOnh01.size() == 1, 'Number of Contact Cards before sync on h01 should be 1');
        system.assert(contactCardsOnw01.size() == 0, 'Number of Contact Cards before sync on w01 should be 0');

        Contact_Card__c w01cc1 = new Contact_Card__c(
            First_Name__c = 'Batman',
            Last_Name__c = 'Test',
            Contact_Type__c = 'Child',
            Data_Source__c = 'AL',
            RecordTypeId = ncrRecordTypeID,
            Related_Constituent__c = w01.Id
        );
        insert w01cc1;

        contactCardsOnh01 = [SELECT Id FROM Contact_Card__c WHERE (Related_Constituent__c =: h01.Id)];
        contactCardsOnw01 = [SELECT Id FROM Contact_Card__c WHERE (Related_Constituent__c =: w01.Id)];
        system.assert(contactCardsOnh01.size() == 1, 'Number of Contact Cards after sync on h01 should still be 1 from redundancy');
        system.assert(contactCardsOnw01.size() == 1, 'Number of Contact Cards after sync on w01 should now be 1');       
        
        Contact_Card__c h01cc2 = new Contact_Card__c(
            First_Name__c = 'Robin',
            Last_Name__c = 'Test',
            Contact_Type__c = 'Child',
            Data_Source__c = 'AL',
            RecordTypeId = ncrRecordTypeID,
            Related_Constituent__c = h01.Id
        );
        insert h01cc2;

        contactCardsOnh01 = [SELECT Id FROM Contact_Card__c WHERE (Related_Constituent__c =: h01.Id)];
        contactCardsOnw01 = [SELECT Id FROM Contact_Card__c WHERE (Related_Constituent__c =: w01.Id)];
        system.assert(contactCardsOnh01.size() == 2, 'Number of Contact Cards after sync on h01 should now be 2');
        system.assert(contactCardsOnw01.size() == 2, 'Number of Contact Cards after sync on w01 should now be 2');    


    }
}