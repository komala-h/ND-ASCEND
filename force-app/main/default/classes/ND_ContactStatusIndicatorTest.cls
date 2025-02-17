@isTest
public class ND_ContactStatusIndicatorTest {
    
    @isTest
    static void method1(){
        TracHier.HierarchyAPI.setTriggerDisabled();
        Id HouseholdId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        Account accountWithDevCoordinator = new Account();
        accountWithDevCoordinator.Name = 'AccountWithDevCoordinator';
        accountWithDevCoordinator.recordTypeid=HouseholdId;
        insert accountWithDevCoordinator;
        Account accountWithDevCoordinator2 = new Account();
        accountWithDevCoordinator2.Name = 'AccountWithDevCoordinator';
        accountWithDevCoordinator2.recordTypeid=HouseholdId;
        insert accountWithDevCoordinator2;
        Contact h01 = new Contact();
        h01.FirstName = 'h01';
        h01.LastName = 'TEST';
        h01.ucinn_ascendv2__Gender__c = 'Male';
        h01.ucinn_ascendv2__Contact_Type__c = 'AL';
        h01.ucinn_ascendv2__Personal_Email__c = 'sample@test.com';
        h01.Constituent_Status__c = 'A';
        h01.Account = accountWithDevCoordinator;
        h01.AccountId = accountWithDevCoordinator.Id;
        insert h01;
        Contact h02 = new Contact();
        h02.FirstName = 'h01';
        h02.LastName = 'TEST';
        h02.ucinn_ascendv2__Gender__c = 'Male';
        h02.ucinn_ascendv2__Contact_Type__c = 'AL';
        h02.ucinn_ascendv2__Personal_Email__c = 'sample@test.com';
        h02.Constituent_Status__c = 'A';
        h02.Account = accountWithDevCoordinator;
        h02.AccountId = accountWithDevCoordinator2.Id;
        insert h02;
       
        Id pledgeRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Gift').getRecordTypeId();
        
        campaign cm = new campaign(name='Planned Gift',Type='Solicitation');
        insert cm;
        
        Opportunity oppWithDevCoord = new Opportunity(
            Name = 'oppWithDevCoord',
            RecordTypeId = pledgeRecordTypeId,
            AccountId = accountWithDevCoordinator.Id,
            ucinn_ascendv2__Contact__c = h01.Id,
            StageName = 'Active',
            CloseDate = date.today(),
            ucinn_ascendv2__Credit_Date__c = date.today(),
            Type='QC',
            ND_Net_Present_Value__c=10.0,
            ucinn_ascendv2__Pledge_Gift_Contact__c = h01.Id
        );
        insert oppWithDevCoord;
        Opportunity oppWithDevCoord2 = new Opportunity(
            Name = 'oppWithDevCoord',
            RecordTypeId = pledgeRecordTypeId,
            AccountId = accountWithDevCoordinator2.Id,
            ucinn_ascendv2__Contact__c = h02.Id,
            StageName = 'Active',
            CloseDate = date.today(),
            ucinn_ascendv2__Credit_Date__c = date.today(),
            campaignId=cm.Id,
            Type='GK',
            ND_Net_Present_Value__c=10.0,
            ucinn_ascendv2__Pledge_Gift_Contact__c = h02.Id
        );
        insert oppWithDevCoord2;        
        Test.startTest();
        ND_ContactStatusIndicator delBatchSchedule = new ND_ContactStatusIndicator();          
        String chron = '0 0 0 1 5 ?';        
        system.schedule('Test Sched', chron, delBatchSchedule);        	
        Test.stopTest();
        
    }
}