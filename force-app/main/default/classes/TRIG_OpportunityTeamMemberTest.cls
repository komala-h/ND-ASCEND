@isTest(SeeAllData=false)
public class TRIG_OpportunityTeamMemberTest {
        @TestSetup
    public static void testSetup() {
        ucinn_ascendv2__Trigger_Handler__c customHandler1 = new ucinn_ascendv2__Trigger_Handler__c();
            customHandler1.Name = 'Opportunity Team Member Int out Handler';
            customHandler1.ucinn_ascendv2__Class__c = 'TRIG_IntegrationOutHandler';
            customHandler1.ucinn_ascendv2__Is_Active__c = true;
            customHandler1.ucinn_ascendv2__Object__c = 'OpportunityTeamMember';
            customHandler1.ucinn_ascendv2__Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
            customHandler1.ucinn_ascendv2__Load_Order__c = 1;
        insert customHandler1;
         
		Account a = new Account(name='Sirius Satellite');
        Account a2 = new Account(name='EMPLOYER IN NAME ONLY');
        insert new List<Account>{a, a2};
            
        Contact h01 = new Contact();
        h01.AccountId = a.id;
        h01.FirstName = 'h01';
        h01.LastName = 'TEST';
        h01.ucinn_ascendv2__Gender__c = 'Male';
        h01.ucinn_ascendv2__Contact_Type__c = 'Alumni';
        h01.ucinn_ascendv2__Data_Source__c = 'WBB';
        h01.ucinn_ascendv2__Personal_Email__c = 'sample@uci.com';
        h01.Constituent_Status__c ='A';
        insert h01;
        
        Opportunity o01 = new Opportunity();
        o01.AccountId = a.id;
        o01.Name = 'Test opportunity';
        o01.ucinn_ascendv2__Contact__c = h01.Id;
        o01.StageName = 'Planned';
        o01.ucinn_ascendv2__Tender_Type_for_Gifts__c = 'Cash';
        o01.Amount =125000;
        o01.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Pledge').getRecordTypeId();
        o01.ucinn_ascendv2__Adjusted_Gift__c = null;
        o01.ucinn_ascendv2__Credit_Date__c = System.today();
        o01.Type =  'Outright';
        o01.CloseDate =  System.today();
        insert o01;
        
 		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='jriz@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='jriz@testorg.com'); 
        insert u;
    }
 @isTest(SeeAllData=false) 
    static void insertAR() {

        user  u01 = [SELECT Id FROM user WHERE Alias = 'standt' LIMIT 1];
        Opportunity o02 = [select id from Opportunity where name ='Test opportunity'];                                     
        Test.startTest();
        OpportunityTeamMember new_ar = new OpportunityTeamMember();
        new_ar.UserId = u01.Id;
        new_ar.OpportunityId = o02.id;
        new_ar.OpportunityAccessLevel = 'Read';
        new_ar.TeamMemberRole = 'Account Manager';

        insert new_ar;
        Test.stopTest();

        OpportunityTeamMember m01 = [SELECT Id, TeamMemberRole, OpportunityAccessLevel FROM OpportunityTeamMember WHERE UserId = :new_ar.UserId  LIMIT 1];
        System.assertEquals('Account Manager', m01.TeamMemberRole);

    }    
}