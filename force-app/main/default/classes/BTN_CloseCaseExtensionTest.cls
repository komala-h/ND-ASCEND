@isTest
private class BTN_CloseCaseExtensionTest {
    @TestSetup
    public static void testSetup() {
        Account a01 = new Account();
        a01.Name = 'TEST ACCOUNT 01';
        a01.BillingStreet = 'Test St';
        a01.BillingCity = 'City of Test';
        a01.BillingCountry = 'United States';
        insert a01;
        
        Contact h01 = new Contact();
        h01.AccountId = a01.Id;
        h01.FirstName = 'h01';
        h01.LastName = 'TEST';
        h01.ucinn_ascendv2__Gender__c = 'Male';
        h01.ucinn_ascendv2__Contact_Type__c = 'Alumni';
        h01.ucinn_ascendv2__Personal_Email__c = 'sample@uci.com';
        h01.Constituent_Status__c = 'A';
        insert h01;
        
        Contact w01 = new Contact();
        w01.AccountId = a01.Id;
        w01.FirstName = 'w01';
        w01.LastName = 'TEST';
        w01.ucinn_ascendv2__Gender__c = 'Female';
        w01.ucinn_ascendv2__Contact_Type__c = 'Alumni';
        w01.ucinn_ascendv2__Personal_Email__c = 'sample2@uci.com';
        w01.Constituent_Status__c = 'A';
        insert w01;
    }
    
    @isTest(SeeAllData=false) 
    static void testCloseCase01() {
        Contact contact_h01 = [Select Id, AccountId From Contact Where FirstName='h01' And LastName='TEST'];
        
        Case c = new Case();
        c.ContactId = contact_h01.Id;
        c.Status = 'New';
        c.Origin = 'Email';
        insert c;
        
        PageReference pageref = new PageReference('/'+c.id);
        test.setCurrentPage(pageref);
        
        Test.startTest();
        
        // Death date validation
        c.Death_Date__c = Date.today().addDays(1);
        update c;
            
        BTN_CloseCaseExtension cls1 = new BTN_CloseCaseExtension(new ApexPages.StandardController(c));
        cls1.closeCase();
        
        Test.stopTest();
    }
    
    @isTest(SeeAllData=false) 
    static void testCloseCase02() {
        Contact contact_h01 = [Select Id, AccountId From Contact Where FirstName='h01' And LastName='TEST'];
        
        Case c = new Case();
        c.ContactId = contact_h01.Id;
        c.Status = 'New';
        c.Origin = 'Email';
        insert c;
        
        PageReference pageref = new PageReference('/'+c.id);
        test.setCurrentPage(pageref);
        
        Test.startTest();
        
        // Obituary validation
        c.Notification_Type__c = 'Obituary';
        c.Death_Date__c = null;
        update c;
            
        BTN_CloseCaseExtension cls1 = new BTN_CloseCaseExtension(new ApexPages.StandardController(c));
        cls1.closeCase();
        
        Test.stopTest();
    }
    
    @isTest(SeeAllData=false) 
    static void testCloseCase03() {
        Contact contact_h01 = [Select Id, AccountId From Contact Where FirstName='h01' And LastName='TEST'];
        
        Case c = new Case();
        c.ContactId = contact_h01.Id;
        c.Status = 'New';
        c.Origin = 'Email';
        insert c;
        
        PageReference pageref = new PageReference('/'+c.id);
        test.setCurrentPage(pageref);
        
        Test.startTest();
        
        // Obituary validation
        c.Notification_Type__c = 'Obituary';
        c.Death_Date__c = null;
        update c;
            
        BTN_CloseCaseExtension cls1 = new BTN_CloseCaseExtension(new ApexPages.StandardController(c));
        cls1.closeCase();
        
        Test.stopTest();
    }
    
    @isTest(SeeAllData=false) 
    static void testCloseCase04() {
        Contact contact_h01 = [Select Id, AccountId From Contact Where FirstName='h01' And LastName='TEST'];
        
        Case c = new Case();
        c.ContactId = contact_h01.Id;
        c.Status = 'New';
        c.Origin = 'Email';
        insert c;
        
        PageReference pageref = new PageReference('/'+c.id);
        test.setCurrentPage(pageref);
        
        Test.startTest();
        
        c.Notification_Type__c = 'Obituary';
        c.Confirmed_Death_Date__c = Date.today();
        c.Death_Date__c = Date.today();
        update c;
            
        BTN_CloseCaseExtension cls1 = new BTN_CloseCaseExtension(new ApexPages.StandardController(c));
        cls1.closeCase();
        
        Test.stopTest();
    }
}