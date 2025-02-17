/**
 * @author UC Innovation
 * @date 9/2/2020
 * @description Test class for Address Relation Trigger
 */
@isTest
private class asc_TRIG_AddressRelationHandlerTest {
    @TestSetup
    public static void testSetup() {
        ucinn_ascendv2__Trigger_Handler__c customHandler02 = new ucinn_ascendv2__Trigger_Handler__c();
        customHandler02.Name = 'Custom Address Relation Handler';
        customHandler02.ucinn_ascendv2__Class__c = 'asc_TRIG_AddressRelationHandler';
        customHandler02.ucinn_ascendv2__Is_Active__c = true;
        customHandler02.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Address_Relation__c';
        customHandler02.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;BeforeDelete;AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
        customHandler02.ucinn_ascendv2__Load_Order__c = 2;
        insert customHandler02;
        
        List<Account> acctsList = new List<Account>();

        // clin Added on 09/20/2023 - PRM assigned to the household record of the constituents is needed for Action Center related flows
        // clin 09/20/2023 - Action Center related flows run into errors when no PRM is assigned to household or if there is no household record for a constituent
        Account hh01 = new Account();
        hh01.Name = 'TEST Household';
        hh01.ucinn_ascendv2__PRM__c = UserInfo.getUserId();
        hh01.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Household').getRecordTypeId();
        acctsList.add(hh01);

        insert acctsList;

        Contact h01 = new Contact();
        h01.FirstName = 'h01';
        h01.LastName = 'TEST';
        h01.ucinn_ascendv2__Gender__c = 'Male';
        h01.ucinn_ascendv2__Contact_Type__c = 'AL';
        h01.ucinn_ascendv2__Personal_Email__c = 'sample@uci.com';
        h01.Constituent_Status__c = 'A';
        h01.AccountId = hh01.Id;
        insert h01;
        
        Contact w01 = new Contact();
        w01.AccountId = hh01.Id;
        w01.FirstName = 'w01';
        w01.LastName = 'TEST';
        w01.ucinn_ascendv2__Gender__c = 'Female';
        w01.ucinn_ascendv2__Contact_Type__c = 'AL';
        w01.ucinn_ascendv2__Preferred_Spouse__c = h01.Id;
        w01.ucinn_ascendv2__Personal_Email__c = 'sample2@uci.com';
        w01.Constituent_Status__c = 'A';
        insert w01;
        
        h01.ucinn_ascendv2__Preferred_Spouse__c = w01.Id;
        update h01;
        
        Contact c01_01 = new Contact();
        c01_01.AccountId = hh01.Id;
        c01_01.FirstName = 'c01-01';
        c01_01.LastName = 'TEST';
        c01_01.ucinn_ascendv2__Gender__c = 'Female';
        c01_01.ucinn_ascendv2__Contact_Type__c = 'AL;ST';
        c01_01.ucinn_ascendv2__Personal_Email__c = 'sample3@uci.com';
        c01_01.Constituent_Status__c = 'A';
        insert c01_01;
        
        ucinn_ascendv2__Address__c add01 = new ucinn_ascendv2__Address__c();
        add01.Name = 'TEST Address 01';
        add01.ucinn_ascendv2__Address_Line_1__c = 'Test 01 ave';
        add01.ucinn_ascendv2__City__c = 'City';
        add01.ucinn_ascendv2__State__c = 'CA';
        add01.ucinn_ascendv2__Country__c = 'United States';
        insert add01;
        
        ucinn_ascendv2__Address__c add02 = new ucinn_ascendv2__Address__c();
        add02.Name = 'TEST Address 02';
        add02.ucinn_ascendv2__Address_Line_1__c = 'Test 02 ave';
        add02.ucinn_ascendv2__City__c = 'City';
        add02.ucinn_ascendv2__State__c = 'CA';
        add02.ucinn_ascendv2__Country__c = 'United States';
        insert add02;
        
        ucinn_ascendv2__Address__c add03 = new ucinn_ascendv2__Address__c();
        add03.Name = 'TEST Address 03';
        add03.ucinn_ascendv2__Address_Line_1__c = 'Test 03 ave';
        add03.ucinn_ascendv2__City__c = 'City';
        add03.ucinn_ascendv2__State__c = 'CA';
        add03.ucinn_ascendv2__Country__c = 'United States';
        insert add03;
        
        ucinn_ascendv2__Relationship__c relationship01 = new ucinn_ascendv2__Relationship__c();
        relationship01.ucinn_ascendv2__Contact__c = h01.Id;
        relationship01.ucinn_ascendv2__Related_Contact__c = w01.Id;
        //changed from PP to FC because PP does not exist
        // changed from FC to Spouse because h01's preferred spouse is w01
        relationship01.ucinn_ascendv2__Related_Contact_Role__c = 'Spouse';
        relationship01.ucinn_ascendv2__Data_Source__c ='AA';
        relationship01.nd_Do_Not_Sync_Home_Address__c = false;
        relationship01.nd_Do_Not_Sync_Seasonal_Address__c = false;
        insert relationship01;
        
        ucinn_ascendv2__Relationship__c relationship02 = new ucinn_ascendv2__Relationship__c();
        relationship02.ucinn_ascendv2__Contact__c = h01.Id;
        relationship02.ucinn_ascendv2__Related_Contact__c = c01_01.Id;
        relationship02.ucinn_ascendv2__Related_Contact_Role__c = 'Child';
        relationship02.ucinn_ascendv2__Data_Source__c ='AA';
        relationship02.nd_Do_Not_Sync_Home_Address__c = false;
        relationship02.nd_Do_Not_Sync_Seasonal_Address__c = false;
        insert relationship02;
        
        
        ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger('ucinn_ascendv2__Relationship__c', false);
        
        ucinn_ascendv2__Relationship__c relationship01b = new ucinn_ascendv2__Relationship__c();
        relationship01b.ucinn_ascendv2__Contact__c = w01.Id;
        relationship01b.ucinn_ascendv2__Related_Contact__c = h01.Id;
        //changed from PP to FC because PP does not exist
        // changed from FC to Spouse because h01's preferred spouse is w01
        relationship01b.ucinn_ascendv2__Related_Contact_Role__c = 'Spouse';
        relationship01b.ucinn_ascendv2__Data_Source__c ='AA';
        relationship01b.nd_Do_Not_Sync_Home_Address__c = false;
        relationship01b.nd_Do_Not_Sync_Seasonal_Address__c = false;
        insert relationship01b;
        
        ucinn_ascendv2__Relationship__c relationship02b = new ucinn_ascendv2__Relationship__c();
        relationship02b.ucinn_ascendv2__Contact__c = c01_01.Id;
        relationship02b.ucinn_ascendv2__Related_Contact__c = h01.Id;
        relationship02b.ucinn_ascendv2__Related_Contact_Role__c = 'Parent';
        relationship02b.ucinn_ascendv2__Data_Source__c ='AA';
        relationship02b.nd_Do_Not_Sync_Home_Address__c = false;
        relationship02b.nd_Do_Not_Sync_Seasonal_Address__c = false;
        relationship02.ucinn_ascendv2__Reciprocal_Relationship__c = relationship02.Id;
        insert relationship02b;
        
        relationship01.ucinn_ascendv2__Reciprocal_Relationship__c = relationship01b.Id;
        update relationship01;
        
        relationship02.ucinn_ascendv2__Reciprocal_Relationship__c = relationship02b.Id;
        update relationship02;
        ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger('ucinn_ascendv2__Relationship__c', true);
    }
    
    @isTest(SeeAllData=false) 
    static void testSyncAddress() {
        Contact contact_h01 = [Select Id, AccountId From Contact Where FirstName='h01' And LastName='TEST'];
        Contact contact_w01 = [Select Id, AccountId From Contact Where FirstName='w01' And LastName='TEST'];
        ucinn_ascendv2__Address__c addrress01 = [Select Id From ucinn_ascendv2__Address__c Where Name='TEST Address 01'];
        ucinn_ascendv2__Address__c addrress02 = [Select Id From ucinn_ascendv2__Address__c Where Name='TEST Address 02'];
        
        Test.startTest();
        
        Id conAddRelRecTypeId = Schema.SObjectType.ucinn_ascendv2__Address_Relation__c.getRecordTypeInfosByName().get('Constituent Address Relation').getRecordTypeId();

        for (ucinn_ascendv2__Relationship__c relDebug : [SELECT Id, Name, ucinn_ascendv2__Contact__c, ucinn_ascendv2__Related_Contact__c, ucinn_ascendv2__Related_Contact_Role__c FROM ucinn_ascendv2__Relationship__c]) {
            System.debug('relDebug===> ' + relDebug);
        }

        ucinn_ascendv2__Address_Relation__c addrel = new ucinn_ascendv2__Address_Relation__c();
        addrel.ucinn_ascendv2__Address__c = addrress01.Id;
        addrel.ucinn_ascendv2__Account__c = contact_h01.AccountId;
        addrel.ucinn_ascendv2__Contact__c = contact_h01.Id;
        addrel.ucinn_ascendv2__Status__c = 'Current';
        addrel.ucinn_ascendv2__Type__c = 'H';
        addrel.RecordTypeId = conAddRelRecTypeId;
        addrel.ucinn_ascendv2__Is_Preferred__c = true;
        insert addrel;
        
        System.assertEquals(1, ([Select Id From ucinn_ascendv2__Address_Relation__c Where ucinn_ascendv2__Contact__c=:contact_w01.Id]).size());
        
        //Test update status
        asc_TRIG_AddressRelationHandler.canInvokeSyncUpdateSettings = true;
        asc_TRIG_AddressRelationHandler.canInvokeSyncAddressRelations = true;
        asc_TRIG_AddressRelationHandler.canInvokeDeleteSyncedAddressRelations = true;
        addrel.ucinn_ascendv2__Status__c = 'Former';
        addrel.ucinn_ascendv2__End_Date__c = System.today();
        update addrel;
        
        //Test update setting
        System.assertEquals(true, ([Select Id, Update_Spouse_Address__c From ucinn_ascendv2__Address_Relation__c Where ucinn_ascendv2__Contact__c=:contact_w01.Id])[0].Update_Spouse_Address__c);
        
        asc_TRIG_AddressRelationHandler.canInvokeSyncUpdateSettings = true;
        asc_TRIG_AddressRelationHandler.canInvokeSyncAddressRelations = true;
        asc_TRIG_AddressRelationHandler.canInvokeDeleteSyncedAddressRelations = true;
        addrel.Update_Spouse_Address__c = false;
        update addrel;
        
        //Test update
        asc_TRIG_AddressRelationHandler.canInvokeSyncUpdateSettings = true;
        asc_TRIG_AddressRelationHandler.canInvokeSyncAddressRelations = true;
        asc_TRIG_AddressRelationHandler.canInvokeDeleteSyncedAddressRelations = true;
        addrel.ucinn_ascendv2__Address__c = addrress02.Id;
        update addrel;
        
        // Test delete
        delete addrel;
        
        Test.stopTest();
    }
    
    @isTest(SeeAllData=false) 
    static void testValidatePrefereedType() {
        Contact contact_h01 = [Select Id, AccountId From Contact Where FirstName='h01' And LastName='TEST'];
        Contact contact_w01 = [Select Id, AccountId From Contact Where FirstName='w01' And LastName='TEST'];
        ucinn_ascendv2__Address__c addrress01 = [Select Id From ucinn_ascendv2__Address__c Where Name='TEST Address 01'];
        ucinn_ascendv2__Address__c addrress02 = [Select Id From ucinn_ascendv2__Address__c Where Name='TEST Address 02'];
        ucinn_ascendv2__Address__c addrress03 = [Select Id From ucinn_ascendv2__Address__c Where Name='TEST Address 03'];
        
        Test.startTest();
        
        System.assertEquals(0, ([Select Id From ucinn_ascendv2__Address_Relation__c Where ucinn_ascendv2__Contact__c=:contact_w01.Id]).size());
        
        Id conAddRelRecTypeId = Schema.SObjectType.ucinn_ascendv2__Address_Relation__c.getRecordTypeInfosByName().get('Constituent Address Relation').getRecordTypeId();

        ucinn_ascendv2__Address_Relation__c addrel = new ucinn_ascendv2__Address_Relation__c();
        addrel.ucinn_ascendv2__Address__c = addrress01.Id;
        addrel.ucinn_ascendv2__Account__c = contact_h01.AccountId;
        addrel.ucinn_ascendv2__Contact__c = contact_h01.Id;
        addrel.ucinn_ascendv2__Status__c = 'Current';
        addrel.ucinn_ascendv2__Type__c = 'H';
        addrel.ucinn_ascendv2__Is_Preferred__c = true;
        addrel.RecordTypeId = conAddRelRecTypeId;
        insert addrel;
        
        ucinn_ascendv2__Address_Relation__c addrel2 = new ucinn_ascendv2__Address_Relation__c();
        addrel2.ucinn_ascendv2__Address__c = addrress02.Id;
        addrel2.ucinn_ascendv2__Account__c = contact_w01.AccountId;
        addrel2.ucinn_ascendv2__Contact__c = contact_w01.Id;
        addrel2.ucinn_ascendv2__Status__c = 'Current';
        addrel2.ucinn_ascendv2__Type__c = 'B';
        addrel2.ucinn_ascendv2__Is_Preferred__c = true;
        addrel2.RecordTypeId = conAddRelRecTypeId;
        
        try {
            insert addrel2;
        } catch(Exception ex) {}
        
        
        ucinn_ascendv2__Address_Relation__c addrel3 = new ucinn_ascendv2__Address_Relation__c();
        addrel3.ucinn_ascendv2__Address__c = addrress03.Id;
        addrel3.ucinn_ascendv2__Account__c = contact_w01.AccountId;
        addrel3.ucinn_ascendv2__Contact__c = contact_w01.Id;
        addrel3.ucinn_ascendv2__Status__c = 'Current';
        addrel3.ucinn_ascendv2__Type__c = 'B';
        addrel3.ucinn_ascendv2__Is_Preferred__c = false;
        addrel3.RecordTypeId = conAddRelRecTypeId;
        
        try {
            insert addrel3;
        } catch(Exception ex) {}
        
        Test.stopTest();
    }

    @isTest(SeeAllData=false) 
    static void testSyncAffiliationFromEmail() {
        
        ucinn_ascendv2__Trigger_Handler__c customHandler05 = new ucinn_ascendv2__Trigger_Handler__c();
        customHandler05.Name = 'Custom Affiliation Handler';
        customHandler05.ucinn_ascendv2__Class__c = 'asc_TRIG_AffiliationHandler';
        customHandler05.ucinn_ascendv2__Is_Active__c = true;
        customHandler05.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Affiliation__c';
        customHandler05.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;BeforeDelete;AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
        customHandler05.ucinn_ascendv2__Load_Order__c = 2;
        insert customHandler05;   
     
        Account a01 = new Account();
        a01.Name = 'AccountName';
        a01.ucinn_ascendv2__Donor_ID__c = '307129';
        insert a01;
        
        Contact h01 = [SELECT Id
                       FROM Contact
                       WHERE (FirstName = 'h01')
                       LIMIT 1];

        ucinn_ascendv2__Affiliation__c affil = new ucinn_ascendv2__Affiliation__c();
        affil.ucinn_ascendv2__Account__c = a01.Id;
        affil.ucinn_ascendv2__Contact__c = h01.Id;
        affil.ucinn_ascendv2__Status__c = 'Current';
        affil.ucinn_ascendv2__Data_Source__c = 'AC';
        affil.ucinn_ascendv2__Constituent_Role__c = 'Employee';
        affil.ucinn_ascendv2__Organization_Role__c = 'Employer';
        insert affil;

        ucinn_ascendv2__Address__c add01 = [SELECT Id
                                            FROM ucinn_ascendv2__Address__c
                                            WHERE (Name = 'TEST Address 01')
                                            LIMIT 1];

        Id conAddRelRecTypeId = Schema.SObjectType.ucinn_ascendv2__Address_Relation__c.getRecordTypeInfosByName().get('Constituent Address Relation').getRecordTypeId();

        ucinn_ascendv2__Address_Relation__c addrel = new ucinn_ascendv2__Address_Relation__c();
        addrel.ucinn_ascendv2__Address__c = add01.Id;
        addrel.ucinn_ascendv2__Account__c = a01.Id;
        addrel.ucinn_ascendv2__Contact__c = h01.Id;
        addrel.ucinn_ascendv2__Status__c = 'Current';
        addrel.ucinn_ascendv2__Type__c = 'B';
        addrel.RecordTypeId = conAddRelRecTypeId;
        insert addrel;

        system.assert(affil.Business_Address__c == null);

        Test.startTest();
        addrel.Affiliation__c = affil.Id;
        update addrel;
        Test.stopTest();

        affil = [SELECT Id, Business_Address__c
                FROM ucinn_ascendv2__Affiliation__c 
                WHERE (ucinn_ascendv2__Status__c = 'Current')
                LIMIT 1];
            
        system.assert(affil.Business_Address__c == addrel.Id);
        
    }

    @isTest(SeeAllData=false) 
    static void testPopulateDateOnStatus() {

        Account a01 = new Account();
        a01.Name = 'AccountName';
        insert a01;

        Contact h01 = [SELECT Id
                       FROM Contact
                       WHERE (FirstName = 'h01')
                       LIMIT 1];

        ucinn_ascendv2__Address__c add01 = [SELECT Id
                                            FROM ucinn_ascendv2__Address__c
                                            WHERE (Name = 'TEST Address 01')
                                            LIMIT 1];

        Id conAddRelRecTypeId = Schema.SObjectType.ucinn_ascendv2__Address_Relation__c.getRecordTypeInfosByName().get('Constituent Address Relation').getRecordTypeId();

        ucinn_ascendv2__Address_Relation__c addrel = new ucinn_ascendv2__Address_Relation__c();
        addrel.ucinn_ascendv2__Address__c = add01.Id;
        addrel.ucinn_ascendv2__Account__c = a01.Id;
        addrel.ucinn_ascendv2__Contact__c = h01.Id;
        addrel.ucinn_ascendv2__Status__c = 'Current';
        addrel.ucinn_ascendv2__Type__c = 'B';
        addrel.RecordTypeId = conAddRelRecTypeId;
        addrel.ucinn_ascendv2__End_Date__c = null;
        addrel.ucinn_ascendv2__Start_Date__c = null;
        addrel.ucinn_ascendv2__Is_Preferred__c = false;
        insert addrel;
        
        addrel = [SELECT ucinn_ascendv2__Start_Date__c, ucinn_ascendv2__End_Date__c
                  FROM ucinn_ascendv2__Address_Relation__c
                  WHERE (ucinn_ascendv2__Type__c = 'B')
                  LIMIT 1];

        system.assert(addrel.ucinn_ascendv2__Start_Date__c == date.today());

        addrel.ucinn_ascendv2__Status__c = 'Former';
        update addrel;

        addrel = [SELECT ucinn_ascendv2__Start_Date__c, ucinn_ascendv2__End_Date__c
                  FROM ucinn_ascendv2__Address_Relation__c
                  WHERE (ucinn_ascendv2__Type__c = 'B')
                  LIMIT 1];
        
        system.assert(addrel.ucinn_ascendv2__End_Date__c == date.today());        
    }

}