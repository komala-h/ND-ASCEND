@isTest
private class asc_TRIG_ContactHandlerTest {
    @TestSetup
    public static void testSetup() {
        ucinn_ascendv2__Trigger_Handler__c contactHandler2 = new ucinn_ascendv2__Trigger_Handler__c();
        contactHandler2.Name = 'Custom Contact Handler';
        contactHandler2.ucinn_ascendv2__Class__c = 'asc_TRIG_ContactHandler';
        contactHandler2.ucinn_ascendv2__Is_Active__c = true;
        contactHandler2.ucinn_ascendv2__Object__c = 'Contact';
        contactHandler2.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;BeforeDelete;AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
        contactHandler2.ucinn_ascendv2__Load_Order__c = 2;
        insert contactHandler2;

        ucinn_ascendv2__Trigger_Handler__c addRelHandler2 = new ucinn_ascendv2__Trigger_Handler__c();
        addRelHandler2.Name = 'Custom Address Relation Handler';
        addRelHandler2.ucinn_ascendv2__Class__c = 'asc_TRIG_AddressRelationHandler';
        addRelHandler2.ucinn_ascendv2__Is_Active__c = true;
        addRelHandler2.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Address_Relation__c';
        addRelHandler2.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;BeforeDelete;AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
        addRelHandler2.ucinn_ascendv2__Load_Order__c = 2;
        insert addRelHandler2;
        
        Id corpOrgRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporations and Organizations').getRecordTypeId();
        Id householdRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();

        Account org01 = new Account();
        org01.Name = 'TEST ORG 01';
        org01.BillingStreet = 'Test St';
        org01.BillingCity = 'City of Test';
        org01.BillingCountry = 'United States';
        org01.RecordTypeId = corpOrgRecTypeId;
        insert org01;

        Account household01 = new Account();
        household01.Name = 'TEST HOUSEHOLD 01';
        household01.BillingStreet = 'Test St';
        household01.BillingCity = 'City of Test';
        household01.BillingCountry = 'United States';
        household01.RecordTypeId = householdRecTypeId;
        insert household01;
        
        Contact h01 = new Contact();
        h01.AccountId = household01.Id;
        h01.FirstName = 'h01';
        h01.LastName = 'TEST';
        h01.ucinn_ascendv2__Gender__c = 'Male';
        h01.ucinn_ascendv2__Contact_Type__c = 'AL';
        h01.ucinn_ascendv2__Personal_Email__c = 'sample@uci.com';
        h01.Constituent_Status__c = 'A';
        h01.ucinn_ascendv2__Preferred_Class_Year__c = '2014';
        insert h01;
        
        Contact w01 = new Contact();
        w01.AccountId = household01.Id;
        w01.FirstName = 'w01';
        w01.LastName = 'TEST';
        w01.ucinn_ascendv2__Gender__c = 'Female';
        w01.ucinn_ascendv2__Contact_Type__c = 'AL';
        w01.ucinn_ascendv2__Personal_Email__c = 'sample2@uci.com';
        w01.Constituent_Status__c = 'A';
        w01.ucinn_ascendv2__Preferred_Class_Year__c = '2015';
        insert w01;
        
        Contact c01 = new Contact();
        c01.AccountId = household01.Id;
        c01.FirstName = 'c01';
        c01.LastName = 'TEST';
        c01.ucinn_ascendv2__Gender__c = 'Female';
        c01.ucinn_ascendv2__Contact_Type__c = 'AL';
        c01.ucinn_ascendv2__Personal_Email__c = 'child@uci.com';
        c01.Constituent_Status__c = 'A';
        insert c01;

        household01.ucinn_ascendv2__Primary_Contact__c = h01.Id;
        household01.Secondary_Constituent__c = w01.Id;
        update household01;
        
        ucinn_ascendv2__Address__c add01 = new ucinn_ascendv2__Address__c();
        add01.Name = 'TEST Address 01';
        add01.ucinn_ascendv2__Address_Line_1__c = 'Test 01 ave';
        add01.ucinn_ascendv2__City__c = 'City';
        add01.ucinn_ascendv2__State__c = 'CA';
        add01.ucinn_ascendv2__Country__c = 'United States';
        insert add01;
        
        Id conAddRelRecTypeId = Schema.SObjectType.ucinn_ascendv2__Address_Relation__c.getRecordTypeInfosByName().get('Constituent Address Relation').getRecordTypeId();

        ucinn_ascendv2__Address_Relation__c addrel = new ucinn_ascendv2__Address_Relation__c();
        addrel.ucinn_ascendv2__Address__c = add01.Id;
        addrel.ucinn_ascendv2__Account__c = h01.AccountId;
        addrel.ucinn_ascendv2__Contact__c = h01.Id;
        addrel.ucinn_ascendv2__Status__c = 'Current';
        addrel.ucinn_ascendv2__Type__c = 'H';
        addrel.RecordTypeId = conAddRelRecTypeId;
        insert addrel;
        
        List<ucinn_ascendv2__Service_Indicator_Value__c> sivList = new List<ucinn_ascendv2__Service_Indicator_Value__c>();
        ucinn_ascendv2__Service_Indicator_Value__c siv01 = new ucinn_ascendv2__Service_Indicator_Value__c();
        siv01.Name = 'Quiet Phase';
        siv01.ucinn_ascendv2__Code__c = 'DNQ';
        sivList.add(siv01);
        ucinn_ascendv2__Service_Indicator_Value__c siv02 = new ucinn_ascendv2__Service_Indicator_Value__c();
        siv02.Name = 'Do Not Phone';
        siv02.ucinn_ascendv2__Code__c = 'DNP';
        sivList.add(siv02);
        insert sivList;

        ucinn_ascendv2__Involvement_Value__c inv01 = new ucinn_ascendv2__Involvement_Value__c();
        inv01.Name = 'Monogram';
        inv01.ucinn_ascendv2__Involvement_Description__c = 'Monogram';
        inv01.ucinn_ascendv2__Type__c = 'ALC';
        inv01.ucinn_ascendv2__Code__c = 'MC';
        insert inv01;

        ucinn_ascendv2__Giving_Society__c gs01 = new ucinn_ascendv2__Giving_Society__c();
        gs01.Name = 'Monogram Membership';
        gs01.nd_Giving_Society_Code__c = 'MC';
        gs01.ucinn_ascendv2__Status__c = 'Active';
        insert gs01;

    }
    
    @isTest
    static void mainTest() {
        ucinn_ascendv2__Trigger_Handler__c handler = new ucinn_ascendv2__Trigger_Handler__c();
            handler.Name = 'Contact Handler';
            handler.ucinn_ascendv2__Class__c = 'asc_TRIG_ContactHandler';
            handler.ucinn_ascendv2__Is_Active__c = true;
            handler.ucinn_ascendv2__Object__c = 'Contact';
            handler.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;BeforeDelete;AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
            handler.ucinn_ascendv2__Load_Order__c = 2;
        insert handler;
        
        List<Account> parents = new List<Account>();
        Id acctRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        for (Integer i = 0; i < 10; i++) {
            Account acct = new Account();
                acct.Name = 'Test '+i;
                acct.ucinn_ascendv2__Managers__c = 'Test PRM';
                acct.RecordTypeId = acctRT;
            parents.add(acct);
        }
        insert parents;

        List<Contact> children = new List<Contact>();
        Id conRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Constituent Details').getRecordTypeId();
        for (Account eachAcct : parents) {
            Contact con = new Contact();
                con.FirstName = 'Test';
                con.LastName = 'Test';
                con.AccountId = eachAcct.Id;
                con.RecordTypeId = conRT;
                con.ucinn_ascendv2__Personal_Email__c = 'sample3@uci.com';
                con.Constituent_Status__c = 'A';
            children.add(con);
        }
        insert children;

        update children;

        List<ucinn_ascendv2__Wealth_Rating__c> ratingsToInsert = new List<ucinn_ascendv2__Wealth_Rating__c>();
        Id ratingRT = Schema.SObjectType.ucinn_ascendv2__Wealth_Rating__c.getRecordTypeInfosByName().get('Contact Wealth Rating').getRecordTypeId();
        for (Integer i = 0; i < children.size(); i++) {
            ucinn_ascendv2__Wealth_Rating__c rating = new ucinn_ascendv2__Wealth_Rating__c();
                rating.ucinn_ascendv2__Contact__c = children[i].Id;
                rating.RecordTypeId = ratingRT;
                if (Math.mod(i, 2) == 0) {
                    rating.ucinn_ascendv2__Wealth_Rating__c = '$50,000,000UP';
                } else {
                    rating.ucinn_ascendv2__Wealth_Rating__c = '$100,000-$499,999';
                }
            ratingsToInsert.add(rating);
        }
        insert ratingsToInsert;

        delete children;
    }
    
    @isTest(SeeAllData=false) 
    static void testUpdateSpouse() {
        Contact contact_h01 = [Select Id, AccountId, RecordType.DeveloperName, ucinn_ascendv2__Salutation_Preference__c, nd_Partner_Significant_Other__c, ucinn_ascendv2__Preferred_Spouse__c From Contact Where FirstName='h01' And LastName='TEST'];
        Contact contact_w01 = [Select Id, AccountId, RecordType.DeveloperName, ucinn_ascendv2__Salutation_Preference__c, nd_Partner_Significant_Other__c, ucinn_ascendv2__Preferred_Spouse__c From Contact Where FirstName='w01' And LastName='TEST'];
        
        Test.startTest();
        
        System.assertEquals(0, ([Select Id From ucinn_ascendv2__Address_Relation__c Where ucinn_ascendv2__Contact__c=:contact_w01.Id]).size());
        
        List<Contact> conListToUpdate = new List<Contact>();

        contact_h01.ucinn_ascendv2__Preferred_Spouse__c = contact_w01.Id;
        conListToUpdate.add(contact_h01);
        contact_w01.ucinn_ascendv2__Preferred_Spouse__c = contact_h01.Id;
        conListToUpdate.add(contact_w01);
        update conListToUpdate;
                
        //System.assertEquals(1, ([Select Id From ucinn_ascendv2__Address_Relation__c Where ucinn_ascendv2__Contact__c=:contact_w01.Id]).size());
        
        Test.stopTest();
    }
    
    @isTest(SeeAllData=false) 
    static void testInserHouseholdMember() {
        Contact contact_h01 = [Select Id, AccountId From Contact Where FirstName='h01' And LastName='TEST'];
        ucinn_ascendv2__Address__c addrress01 = [Select Id From ucinn_ascendv2__Address__c Where Name='TEST Address 01'];
        ucinn_ascendv2__Address_Relation__c addrel01 = [Select Id From ucinn_ascendv2__Address_Relation__c Where ucinn_ascendv2__Address__c=:addrress01.Id Limit 1];
        
        Test.startTest();
        
        System.assertEquals(1, ([Select Id From ucinn_ascendv2__Address_Relation__c Where ucinn_ascendv2__Address__c=:addrress01.Id]).size());
        
        addrel01.Update_Household_Member_Addresses__c = true;
        update addrel01;
        
        asc_TRIG_AddressRelationHandler.canInvokeSyncUpdateSettings = true;
        asc_TRIG_AddressRelationHandler.canInvokeSyncAddressRelations = true;
        asc_TRIG_AddressRelationHandler.canInvokeDeleteSyncedAddressRelations = true;
        
        //Contact c01_01 = new Contact();
        //c01_01.AccountId = contact_h01.AccountId;
        //c01_01.FirstName = 'c01-01';
        //c01_01.LastName = 'TEST';
        //c01_01.ucinn_ascendv2__Gender__c = 'Female';
        //c01_01.ucinn_ascendv2__Contact_Type__c = 'Child';
        //insert c01_01;
                
        //System.assertEquals(3, ([Select Id From ucinn_ascendv2__Address_Relation__c Where ucinn_ascendv2__Address__c=:addrress01.Id]).size());
        
        Test.stopTest();
    }
    
    @isTest(SeeAllData=false) 
    static void testUpdateDeceasedRelatedRecords() {
        Contact contact_h01 = [Select Id, AccountId From Contact Where FirstName='h01' And LastName='TEST'];
        Contact contact_w01 = [Select Id, AccountId From Contact Where FirstName='w01' And LastName='TEST'];
        Contact contact_c01 = [Select Id, AccountId From Contact Where FirstName='c01' And LastName='TEST'];
        
        List<Contact> conListToUpdate = new List<Contact>();

        contact_h01.ucinn_ascendv2__Preferred_Spouse__c = contact_w01.Id;
        conListToUpdate.add(contact_h01);
        contact_w01.ucinn_ascendv2__Preferred_Spouse__c = contact_h01.Id;
        conListToUpdate.add(contact_w01);
        update conListToUpdate;
        
        ucinn_ascendv2__Relationship__c rel01 = new ucinn_ascendv2__Relationship__c();
        rel01.ucinn_ascendv2__Contact__c = contact_h01.Id;
        rel01.ucinn_ascendv2__Related_Contact__c = contact_c01.Id;
        rel01.ucinn_ascendv2__Related_Contact_Role__c = 'Child';
        insert rel01;
        
        // Delete to test missing child
        List<ucinn_ascendv2__Relationship__c> w01_childrel = [Select Id From ucinn_ascendv2__Relationship__c Where ucinn_ascendv2__Related_Contact_Role__c = 'Child' And ucinn_ascendv2__Contact__c = :contact_w01.Id];
        if (!w01_childrel.isEmpty()) {
            delete w01_childrel;
        }
        
        Test.startTest();
        
        contact_h01.ucinn_ascendv2__Is_Deceased__c = true;
        contact_h01.ucinn_ascendv2__Date_Marked_Deceased__c = Date.today();
        contact_h01.ucinn_ascendv2__Deceased_Date__c = Date.today();
        contact_h01.ucinn_ascendv2__Deceased_Source__c = 'LF';
        update contact_h01;
        
        Test.stopTest();
    }

    @isTest(SeeAllData=false) 
    static void testDeceasedConstituentWithSpouse() {
        Contact contact_h01 = [Select Id, AccountId From Contact Where FirstName='h01' And LastName='TEST'];
        Contact contact_w01 = [Select Id, AccountId From Contact Where FirstName='w01' And LastName='TEST'];
        Account org01 = [SELECT Id, Name FROM Account WHERE Name = 'TEST ORG 01'];
        
        List<Contact> conListToUpdate = new List<Contact>();
        
         contact_h01.ucinn_ascendv2__Marital_Status__c = 'M';
         contact_w01.ucinn_ascendv2__Marital_Status__c = 'M';

        contact_h01.ucinn_ascendv2__Preferred_Spouse__c = contact_w01.Id;
        conListToUpdate.add(contact_h01);
        contact_w01.ucinn_ascendv2__Preferred_Spouse__c = contact_h01.Id;
        conListToUpdate.add(contact_w01);
        update conListToUpdate;
        
        ucinn_ascendv2__Relationship__c rel01 = new ucinn_ascendv2__Relationship__c();
        rel01.ucinn_ascendv2__Contact__c = contact_h01.Id;
        rel01.ucinn_ascendv2__Related_Contact__c = contact_w01.Id;
        rel01.ucinn_ascendv2__Related_Contact_Role__c = 'Spouse';
        rel01.ucinn_ascendv2__Status__c = 'Current';
        rel01.ucinn_ascendv2__Merge_Option__c = 'Merge Household';
        insert rel01;

        Id conEmailRecTypeId = Schema.SObjectType.ucinn_ascendv2__Email__c.getRecordTypeInfosByName().get('Contact Email').getRecordTypeId();

        ucinn_ascendv2__Email__c email01 = new ucinn_ascendv2__Email__c();
        email01.ucinn_ascendv2__Contact__c = contact_h01.Id;
        email01.ucinn_ascendv2__Status__c = 'Current';
        email01.ucinn_ascendv2__Is_Preferred__c = true;
        email01.RecordTypeId = conEmailRecTypeId;
        email01.ucinn_ascendv2__Type__c = 'M';
        email01.ucinn_ascendv2__Email_Address__c = 'sample@uci.com';
        email01.ucinn_ascendv2__Start_Date__c = System.today().addDays(-30);
        insert email01;

        Id conPhoneRecTypeId = Schema.SObjectType.ucinn_ascendv2__Phone__c.getRecordTypeInfosByName().get('Contact Phone').getRecordTypeId();

        ucinn_ascendv2__Phone__c phone01 = new ucinn_ascendv2__Phone__c();
        phone01.ucinn_ascendv2__Contact__c = contact_h01.Id;
        phone01.ucinn_ascendv2__Status__c = 'Current';
        phone01.ucinn_ascendv2__Is_Preferred__c = true;
        phone01.RecordTypeId = conPhoneRecTypeId;
        phone01.ucinn_ascendv2__Type__c = 'M';
        phone01.ucinn_ascendv2__Phone_Number__c = '7141111111';
        phone01.ucinn_ascendv2__Start_Date__c = System.today().addDays(-30);
        insert phone01;

        List<ucinn_ascendv2__Service_Indicator_Value__c> sivList = [SELECT Id, ucinn_ascendv2__Code__c FROM ucinn_ascendv2__Service_Indicator_Value__c WHERE ucinn_ascendv2__Code__c = 'DNP'];

        ucinn_ascendv2__Service_Indicator__c si01 = new ucinn_ascendv2__Service_Indicator__c();
        si01.ucinn_ascendv2__Contact__c = contact_h01.Id;
        si01.ucinn_ascendv2__Is_Active__c = true;
        si01.ucinn_ascendv2__Service_Indicator_Value__c = sivList.size() > 0 ? sivList[0].Id : null;
        si01.ucinn_ascendv2__Start_Date__c = System.today().addDays(-30);
        si01.Data_Source__c = 'X';
        insert si01;

        List<ucinn_ascendv2__Involvement_Value__c> invValList = [SELECT Id, ucinn_ascendv2__Code__c FROM ucinn_ascendv2__Involvement_Value__c WHERE ucinn_ascendv2__Code__c = 'MC'];

        ucinn_ascendv2__Involvement__c inv01 = new ucinn_ascendv2__Involvement__c();
        inv01.ucinn_ascendv2__Contact__c = contact_h01.Id;
        inv01.ucinn_ascendv2__Status__c = 'A';
        inv01.ucinn_ascendv2__Involvement_Code__c = invValList.size() > 0 ? invValList[0].Id : null;
        inv01.ucinn_ascendv2__Start_Date__c = System.today().addDays(-30);
        inv01.Data_Source__c = 'X';
        insert inv01;

        List<ucinn_ascendv2__Giving_Society__c> gsList = [SELECT Id, nd_Giving_Society_Code__c FROM ucinn_ascendv2__Giving_Society__c WHERE nd_Giving_Society_Code__c = 'MC'];

        List<ucinn_ascendv2__Society_Membership__c> smList = new List<ucinn_ascendv2__Society_Membership__c>();
        ucinn_ascendv2__Society_Membership__c sm01 = new ucinn_ascendv2__Society_Membership__c();
        sm01.ucinn_ascendv2__Contact__c = contact_h01.Id;
        sm01.ucinn_ascendv2__Giving_Society__c = gsList.size() > 0 ? gsList[0].Id : null;
        sm01.nd_Membership_Type__c = 'Member';
        sm01.ucinn_ascendv2__Member_Since__c = System.today().addDays(-30);
        sm01.ucinn_ascendv2__Expiration_Date__c = System.today().addDays(30);
        sm01.nd_Status__c = 'A';
        sm01.ucinn_ascendv2__Is_Primary__c = true;
        smList.add(sm01);
        ucinn_ascendv2__Society_Membership__c sm02 = new ucinn_ascendv2__Society_Membership__c();
        sm02.ucinn_ascendv2__Contact__c = contact_w01.Id;
        sm02.ucinn_ascendv2__Giving_Society__c = gsList.size() > 0 ? gsList[0].Id : null;
        sm02.nd_Membership_Type__c = 'Non-Member Spouse';
        sm02.ucinn_ascendv2__Member_Since__c = System.today().addDays(-30);
        sm02.ucinn_ascendv2__Expiration_Date__c = System.today().addDays(30);
        sm02.nd_Status__c = 'A';
        sm02.ucinn_ascendv2__Is_Primary__c = false;
        smList.add(sm02);
        insert smList;

        List<ucinn_ascendv2__Affiliation__c> affList = new List<ucinn_ascendv2__Affiliation__c>();
        ucinn_ascendv2__Affiliation__c aff01 = new ucinn_ascendv2__Affiliation__c();
        aff01.ucinn_ascendv2__Contact__c = contact_h01.Id;
        aff01.ucinn_ascendv2__Status__c = 'Current';
        aff01.nd_Employee_Type__c = 'S1';
        aff01.ucinn_ascendv2__Account__c = org01.Id;
        aff01.ucinn_ascendv2__Constituent_Role__c = 'Affiliation';
        aff01.ucinn_ascendv2__Start_Date__c = System.today().addDays(-30);
        aff01.ucinn_ascendv2__Data_Source__c = 'X';
        affList.add(aff01);
      /*  ucinn_ascendv2__Affiliation__c aff02 = new ucinn_ascendv2__Affiliation__c();
        aff02.ucinn_ascendv2__Contact__c = contact_w01.Id;
        aff02.ucinn_ascendv2__Status__c = 'Current';
        aff02.nd_Employee_Type__c = 'S1';
        aff02.ucinn_ascendv2__Account__c = org01.Id;
        aff02.ucinn_ascendv2__Constituent_Role__c = 'Affiliation';
        aff02.ucinn_ascendv2__Start_Date__c = System.today().addDays(-30);
        aff02.ucinn_ascendv2__Data_Source__c = 'X';
        affList.add(aff02);*/
        insert affList;

        Test.startTest();
        
        contact_h01.ucinn_ascendv2__Is_Deceased__c = true;
        contact_h01.ucinn_ascendv2__Date_Marked_Deceased__c = System.today();
        contact_h01.ucinn_ascendv2__Deceased_Date__c = System.today();
        contact_h01.ucinn_ascendv2__Deceased_Source__c = 'LF';
        update contact_h01;
        
        Test.stopTest();
    }

    @isTest(SeeAllData=false) 
    static void testDeceasedConstituentNoSpouse() {
        Contact contact_h01 = [Select Id, AccountId,nd_Partner_Significant_Other__c From Contact Where FirstName='h01' And LastName='TEST'];
        Contact contact_w01 = [Select Id, AccountId,nd_Partner_Significant_Other__c From Contact Where FirstName='w01' And LastName='TEST'];
        List<Contact> conListToUpdate = new List<Contact>();
        contact_h01.ucinn_ascendv2__Marital_Status__c = 'P';
        contact_h01.nd_Partner_Significant_Other__c = contact_w01.Id;
        conListToUpdate.add(contact_h01);
        contact_w01.ucinn_ascendv2__Marital_Status__c = 'P';
        contact_w01.nd_Partner_Significant_Other__c = contact_h01.Id;
        conListToUpdate.add(contact_w01);
        update conListToUpdate;
        
        Id conEmailRecTypeId = Schema.SObjectType.ucinn_ascendv2__Email__c.getRecordTypeInfosByName().get('Contact Email').getRecordTypeId();

        ucinn_ascendv2__Email__c email01 = new ucinn_ascendv2__Email__c();
        email01.ucinn_ascendv2__Contact__c = contact_h01.Id;
        email01.ucinn_ascendv2__Status__c = 'Current';
        email01.ucinn_ascendv2__Is_Preferred__c = true;
        email01.RecordTypeId = conEmailRecTypeId;
        email01.ucinn_ascendv2__Type__c = 'M';
        email01.ucinn_ascendv2__Email_Address__c = 'sample@uci.com';
        email01.ucinn_ascendv2__Start_Date__c = System.today().addDays(-30);
        insert email01;
        
        Id conPhoneRecTypeId = Schema.SObjectType.ucinn_ascendv2__Phone__c.getRecordTypeInfosByName().get('Contact Phone').getRecordTypeId();

        ucinn_ascendv2__Phone__c phone01 = new ucinn_ascendv2__Phone__c();
        phone01.ucinn_ascendv2__Contact__c = contact_h01.Id;
        phone01.ucinn_ascendv2__Status__c = 'Current';
        phone01.ucinn_ascendv2__Is_Preferred__c = true;
        phone01.RecordTypeId = conPhoneRecTypeId;
        phone01.ucinn_ascendv2__Type__c = 'M';
        phone01.ucinn_ascendv2__Phone_Number__c = '7141111111';
        phone01.ucinn_ascendv2__Start_Date__c = System.today().addDays(-30);
        insert phone01;

        List<ucinn_ascendv2__Service_Indicator_Value__c> sivList = [SELECT Id, ucinn_ascendv2__Code__c FROM ucinn_ascendv2__Service_Indicator_Value__c WHERE ucinn_ascendv2__Code__c = 'DNP'];

        ucinn_ascendv2__Service_Indicator__c si01 = new ucinn_ascendv2__Service_Indicator__c();
        si01.ucinn_ascendv2__Contact__c = contact_h01.Id;
        si01.ucinn_ascendv2__Is_Active__c = true;
        si01.ucinn_ascendv2__Service_Indicator_Value__c = sivList.size() > 0 ? sivList[0].Id : null;
        si01.ucinn_ascendv2__Start_Date__c = System.today().addDays(-30);
        si01.Data_Source__c = 'X';
        insert si01;

        List<ucinn_ascendv2__Involvement_Value__c> invValList = [SELECT Id, ucinn_ascendv2__Code__c FROM ucinn_ascendv2__Involvement_Value__c WHERE ucinn_ascendv2__Code__c = 'MC'];

        ucinn_ascendv2__Involvement__c inv01 = new ucinn_ascendv2__Involvement__c();
        inv01.ucinn_ascendv2__Contact__c = contact_h01.Id;
        inv01.ucinn_ascendv2__Status__c = 'A';
        inv01.ucinn_ascendv2__Involvement_Code__c = invValList.size() > 0 ? invValList[0].Id : null;
        inv01.ucinn_ascendv2__Start_Date__c = System.today().addDays(-30);
        inv01.Data_Source__c = 'X';
        insert inv01;

        List<ucinn_ascendv2__Giving_Society__c> gsList = [SELECT Id, nd_Giving_Society_Code__c FROM ucinn_ascendv2__Giving_Society__c WHERE nd_Giving_Society_Code__c = 'MC'];

        List<ucinn_ascendv2__Society_Membership__c> smList = new List<ucinn_ascendv2__Society_Membership__c>();
        ucinn_ascendv2__Society_Membership__c sm01 = new ucinn_ascendv2__Society_Membership__c();
        sm01.ucinn_ascendv2__Contact__c = contact_h01.Id;
        sm01.ucinn_ascendv2__Giving_Society__c = gsList.size() > 0 ? gsList[0].Id : null;
        sm01.nd_Membership_Type__c = 'Member';
        sm01.ucinn_ascendv2__Member_Since__c = System.today().addDays(-30);
        sm01.ucinn_ascendv2__Expiration_Date__c = System.today().addDays(30);
        sm01.nd_Status__c = 'A';
        sm01.ucinn_ascendv2__Is_Primary__c = true;
        smList.add(sm01);
        insert smList;

        Test.startTest();
        
        contact_h01.ucinn_ascendv2__Is_Deceased__c = true;
        contact_h01.ucinn_ascendv2__Date_Marked_Deceased__c = System.today();
        contact_h01.ucinn_ascendv2__Deceased_Date__c = System.today();
        // contact_h01.ND_Decease_Confirmed_Date__c = System.today();
        contact_h01.ucinn_ascendv2__Deceased_Source__c = 'LF';
        update contact_h01;
        
        Test.stopTest();
    }

    @isTest(SeeAllData=false) 
    static void testDeceasedConHouseholdRecords() {
        Contact contact_h01 = [Select Id, AccountId From Contact Where FirstName='h01' And LastName='TEST'];
        Contact contact_w01 = [Select Id, AccountId From Contact Where FirstName='w01' And LastName='TEST'];
        
        List<Contact> conListToUpdate = new List<Contact>();

        contact_h01.ucinn_ascendv2__Preferred_Spouse__c = contact_w01.Id;
        conListToUpdate.add(contact_h01);
        contact_w01.ucinn_ascendv2__Preferred_Spouse__c = contact_h01.Id;
        conListToUpdate.add(contact_w01);
        update conListToUpdate;
        
        ucinn_ascendv2__Relationship__c rel01 = new ucinn_ascendv2__Relationship__c();
        rel01.ucinn_ascendv2__Contact__c = contact_h01.Id;
        rel01.ucinn_ascendv2__Related_Contact__c = contact_w01.Id;
        rel01.ucinn_ascendv2__Related_Contact_Role__c = 'Spouse';
        rel01.ucinn_ascendv2__Status__c = 'Current';
        rel01.ucinn_ascendv2__Merge_Option__c = 'Merge Household';
        insert rel01;

        ucinn_ascendv2__Strategy__c strat01 = new ucinn_ascendv2__Strategy__c();
        strat01.ucinn_ascendv2__Contact__c = contact_h01.Id;
        insert strat01;

        ucinn_ascendv2__Research__c res01 = new ucinn_ascendv2__Research__c();
        res01.ucinn_ascendv2__Contact__c = contact_h01.Id;
        insert res01;

        Case case01 = new Case();
        case01.ContactId = contact_h01.Id;
        case01.Status = 'New';
        case01.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Research Requests').getRecordTypeId();
        case01.Requested_By__c = UserInfo.getUserId();
        case01.Request_Purpose__c = 'Other';
        case01.Initiate_Request__c = 'test';
        case01.Strategy_Change__c = 'test';
        case01.Research_Reason__c = 'Test';
        case01.Is_this_a_referral__c = 'No';
        case01.Is_this_request_for_an_upcoming_Ask__c = 'No';
        insert case01;

        ucinn_ascendv2__Wealth_Rating__c wr01 = new ucinn_ascendv2__Wealth_Rating__c();
        wr01.ucinn_ascendv2__Contact__c = contact_h01.Id;
        wr01.ucinn_ascendv2__Wealth_Rating__c = '$1,000,000-$2,499,999';
        wr01.RecordTypeId = Schema.SObjectType.ucinn_ascendv2__Wealth_Rating__c.getRecordTypeInfosByName().get('Contact Wealth Rating').getRecordTypeId();
        insert wr01;

        Opportunity opp01 = new Opportunity();
        opp01.ucinn_ascendv2__Contact__c = contact_h01.Id;
        opp01.ucinn_ascendv2__Proposal_Contact__c = contact_h01.Id;
        opp01.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Proposal').getRecordTypeId();
        opp01.StageName = 'Active';
        opp01.Name = 'Test Proposal 01';
        opp01.CloseDate = System.today();
        insert opp01;

        Wealth_Asset__c wealthAsset01 = new Wealth_Asset__c();
        wealthAsset01.Constituent__c = contact_h01.Id;
        wealthAsset01.Status__c = 'Active';
        wealthAsset01.Category__c = 'Real Estate';
        insert wealthAsset01;

        ucinn_ascendv2__Assignment__c ass01 = new ucinn_ascendv2__Assignment__c();
        ass01.ucinn_ascendv2__Account__c = contact_h01.AccountId;
        ass01.ucinn_ascendv2__Assignment_Type__c = 'Primary Relationship Manager';
        ass01.ucinn_ascendv2__Assigned_Relationship_Manager_User__c = UserInfo.getUserId();
        insert ass01;

        Test.startTest();
        
        contact_h01.ucinn_ascendv2__Donor_ID__c = '0000000000';
        contact_h01.ucinn_ascendv2__Is_Deceased__c = true;
        contact_h01.ucinn_ascendv2__Date_Marked_Deceased__c = System.today();
        contact_h01.ucinn_ascendv2__Deceased_Date__c = System.today();
        // contact_h01.ND_Decease_Confirmed_Date__c = System.today();
        contact_h01.ucinn_ascendv2__Deceased_Source__c = 'LF';
        update contact_h01;
        
        Test.stopTest();
    }
    
    @isTest(SeeAllData=false) 
    static void testUpdateChildRelationshipAddressSyncSettings() {
        Contact contact_h01 = [Select Id, AccountId From Contact Where FirstName='h01' And LastName='TEST'];
        Contact contact_w01 = [Select Id, AccountId From Contact Where FirstName='w01' And LastName='TEST'];
        Contact contact_c01 = [Select Id, AccountId From Contact Where FirstName='c01' And LastName='TEST'];
        
        Test.startTest();
        
        contact_c01.ucinn_ascendv2__Contact_Type__c = 'AL;ST';
        update contact_c01;
        
        ucinn_ascendv2__Relationship__c rel01 = new ucinn_ascendv2__Relationship__c();
        rel01.ucinn_ascendv2__Contact__c = contact_h01.Id;
        rel01.ucinn_ascendv2__Related_Contact__c = contact_c01.Id;
        rel01.ucinn_ascendv2__Related_Contact_Role__c = 'Child';
        rel01.nd_Do_Not_Sync_Home_Address__c = false;
        rel01.nd_Do_Not_Sync_Seasonal_Address__c = false;
        insert rel01;
        
        contact_c01.ucinn_ascendv2__Contact_Type__c = 'AL';
        update contact_c01;
        
        contact_c01.ucinn_ascendv2__Contact_Type__c = 'AL;ST';
        update contact_c01;
        
        Test.stopTest();
    }

    @isTest(SeeAllData=false)
    static void testCopyWealthAssetsOnHouseholdUnmerge() {


        Account testHousehold1 = new Account(Name='testContact1 Household',
                                             RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId());
        Account testHousehold2 = new Account(Name='testContact2 Household',
                                             RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId());


        insert testHousehold1;
        insert testHousehold2;


        Contact testContact1 = new Contact( FirstName='testContact1', 
                                            LastName='TEST', 
                                            ucinn_ascendv2__Personal_Email__c='sample1@uci.com',
                                            Constituent_Status__c='A',
                                            AccountId=testHousehold1.Id);
        Contact testContact2 = new Contact( FirstName='testContact2', 
                                            LastName='TEST', 
                                            ucinn_ascendv2__Personal_Email__c='sample2@uci.com',
                                            Constituent_Status__c='A',
                                            AccountId=testHousehold1.Id);
                    
        insert testContact1;
        insert testContact2;

        Wealth_Asset__c testHousehold1WealthAsset = new Wealth_Asset__c( Name='testWealthAsset1', 
                                                                         Status__c='Active',
                                                                         Organization__c=testHousehold1.Id,
                                                                         Estimated_Value__c=100000.00,
                                                                         Category__c='Real Estate');

        insert testHousehold1WealthAsset;

        Test.startTest();

        ucinn_ascendv2__Relationship__c divorcedRelationship = new ucinn_ascendv2__Relationship__c(Name='testRelationship', 
                                                                                                ucinn_ascendv2__Contact__c=testContact2.Id,
                                                                                                ucinn_ascendv2__Related_Contact__c=testContact1.Id,
                                                                                                ucinn_ascendv2__Related_Contact_Role__c='Ex-Spouse'
                                                                                                );
        insert divorcedRelationship;

        testContact2.AccountId = testHousehold2.Id;
        update testContact2;

        Test.stopTest();

        List<Wealth_Asset__c> household1WealthAssets = [SELECT Id, Status__c
                                                        FROM Wealth_Asset__c
                                                        WHERE Organization__c = :testHousehold1.Id];

        List<Wealth_Asset__c> household2WealthAssets = [SELECT Id, Status__c
                                                        FROM Wealth_Asset__c
                                                        WHERE Organization__c = :testHousehold2.Id];

        //system.assertEquals(1, household1WealthAssets.size());
        //system.assertEquals(1, household2WealthAssets.size());

        //system.assertEquals('Review', household1WealthAssets[0].Status__c);
        //system.assertEquals('Review', household2WealthAssets[0].Status__c);

    }
}