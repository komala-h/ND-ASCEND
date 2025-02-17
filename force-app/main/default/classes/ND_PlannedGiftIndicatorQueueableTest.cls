@isTest
    public class ND_PlannedGiftIndicatorQueueableTest {

    @isTest
    Static void method1(){
        ucinn_ascendv2__Trigger_Handler__c customHandler01 = new ucinn_ascendv2__Trigger_Handler__c();
        customHandler01.Name = 'ND Handler';
        customHandler01.ucinn_ascendv2__Class__c = 'NdOpportunityHandler';
        customHandler01.ucinn_ascendv2__Is_Active__c = true;
        customHandler01.ucinn_ascendv2__Object__c = 'Opportunity';
        customHandler01.ucinn_ascendv2__Trigger_Action__c = 'AfterUpdate;AfterDelete;';
        customHandler01.ucinn_ascendv2__Load_Order__c = 1.0;
        insert customHandler01;        
       Id HouseholdId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
         Account accountWithDevCoordinator = new Account();
         accountWithDevCoordinator.Name = 'AccountWithDevCoordinator';
         accountWithDevCoordinator.recordTypeid=HouseholdId;
        insert accountWithDevCoordinator;

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

        Id pledgeRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Pledge').getRecordTypeId();
       

        Opportunity oppWithDevCoord = new Opportunity(
            Name = 'oppWithDevCoord',
            RecordTypeId = pledgeRecordTypeId,
            AccountId = accountWithDevCoordinator.Id,
            ucinn_ascendv2__Contact__c = h01.Id,
            StageName = 'Active',
            CloseDate = date.today(),
            Type='QC',
            ND_Net_Present_Value__c=10.0,
            ucinn_ascendv2__Pledge_Gift_Contact__c = h01.Id,
            ucinn_ascendv2__Credit_Date__c = System.today()
        );
        insert oppWithDevCoord;

        
        Test.startTest();
            oppWithDevCoord.StageName='Cancelled';
            Update oppWithDevCoord;  
            
        Test.stopTest();        
    }
}