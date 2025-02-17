@isTest
public class NdOpportunityHandlerTest {

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
            ucinn_ascendv2__Credit_Date__c = date.today(),
            Type='QC',
            ND_Net_Present_Value__c=10.0,
            ucinn_ascendv2__Pledge_Gift_Contact__c = h01.Id
        );
        
        insert oppWithDevCoord;

        
        Test.startTest();
            oppWithDevCoord.StageName='Cancelled';
            Update oppWithDevCoord;  
            
        Test.stopTest();        
    }
    @isTest
    Static void method2(){
        ucinn_ascendv2__Trigger_Handler__c customHandler01 = new ucinn_ascendv2__Trigger_Handler__c();
        customHandler01.Name = 'ND Handler';
        customHandler01.ucinn_ascendv2__Class__c = 'NdOpportunityHandler';
        customHandler01.ucinn_ascendv2__Is_Active__c = true;
        customHandler01.ucinn_ascendv2__Object__c = 'Opportunity';
        customHandler01.ucinn_ascendv2__Trigger_Action__c = 'AfterUpdate;AfterDelete;';
        customHandler01.ucinn_ascendv2__Load_Order__c = 1.0;
        insert customHandler01;        
       Id HouseholdId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();

        Account accountWithDevCoordinator2 = new Account();
        accountWithDevCoordinator2.Name = 'AccountWithDevCoordinator';
        accountWithDevCoordinator2.recordTypeid=HouseholdId;
        insert accountWithDevCoordinator2;

        Contact h02 = new Contact();
        h02.FirstName = 'h01';
        h02.LastName = 'TEST';
        h02.ucinn_ascendv2__Gender__c = 'Male';
        h02.ucinn_ascendv2__Contact_Type__c = 'AL';
        h02.ucinn_ascendv2__Personal_Email__c = 'sample@test.com';
        h02.Constituent_Status__c = 'A';
        h02.Account = accountWithDevCoordinator2;
        h02.AccountId = accountWithDevCoordinator2.Id;
        insert h02;
        Id pledgeRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Pledge').getRecordTypeId();
        
        campaign cm = new campaign(name='Planned Gift',Type='Solicitation');
        insert cm;

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
            delete  oppWithDevCoord2;
        Test.stopTest();        
    }    
        @isTest
    Static void method3(){
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
            ucinn_ascendv2__Credit_Date__c = date.today(),
            Type='QC',
            ND_Net_Present_Value__c=10.0,
            ucinn_ascendv2__Pledge_Gift_Contact__c = h01.Id
        );
        insert oppWithDevCoord;

        
        Test.startTest();
            oppWithDevCoord.StageName='Cancelled';
            delete oppWithDevCoord;  
            
        Test.stopTest();        
    }
    @isTest
    static void deleteValidation(){
        ucinn_ascendv2__Trigger_Handler__c customHandler01 = new ucinn_ascendv2__Trigger_Handler__c();
        customHandler01.Name = 'ND Handler';
        customHandler01.ucinn_ascendv2__Class__c = 'NdOpportunityHandler';
        customHandler01.ucinn_ascendv2__Is_Active__c = true;
        customHandler01.ucinn_ascendv2__Object__c = 'Opportunity';
        customHandler01.ucinn_ascendv2__Trigger_Action__c = 'BeforeDelete;';
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
            StageName = 'Booked',
            CloseDate = date.today(),
            ucinn_ascendv2__Credit_Date__c = date.today(),
            Type='QC',
            ND_Net_Present_Value__c=10.0,
            ucinn_ascendv2__Pledge_Gift_Contact__c = h01.Id
        );
        insert oppWithDevCoord;        
    } 
    
        @isTest
    Static void DeleteValidationmethod4(){
        ucinn_ascendv2__Trigger_Handler__c customHandler01 = new ucinn_ascendv2__Trigger_Handler__c();
        customHandler01.Name = 'ND Handler';
        customHandler01.ucinn_ascendv2__Class__c = 'NdOpportunityHandler';
        customHandler01.ucinn_ascendv2__Is_Active__c = true;
        customHandler01.ucinn_ascendv2__Object__c = 'Opportunity';
        customHandler01.ucinn_ascendv2__Trigger_Action__c = 'BeforeDelete;AfterInsert;AfterDelete;';
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
        accountWithDevCoordinator.ucinn_ascendv2__Primary_Contact__c = h01.id;
        update accountWithDevCoordinator;
        
        Id pledgeRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Proposal').getRecordTypeId();
       

        Opportunity oppWithDevCoord = new Opportunity(
            Name = 'oppWithDevCoord',
            RecordTypeId = pledgeRecordTypeId,
            AccountId = accountWithDevCoordinator.Id,
            ucinn_ascendv2__Contact__c = h01.Id,
            StageName = 'Booked',
            CloseDate = date.today(),
            ucinn_ascendv2__Credit_Date__c = date.today(),
            Type='QC',
            ND_Net_Present_Value__c=10.0,
            ucinn_ascendv2__Pledge_Gift_Contact__c = h01.Id
        );
        insert oppWithDevCoord;

        
        Test.startTest();
        //oppWithDevCoord.StageName ='Booked';
        try{
        
            delete oppWithDevCoord;  
        }Catch(Exception e){
            
        }
            
        Test.stopTest();        
    }      
}