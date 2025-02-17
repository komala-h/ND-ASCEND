/**
 * @author UC Innovation
 * @date 11/23/2021
 * @group LWC Controller
 * @description Test Class for SubProposalController
 */
@IsTest
public class SubProposalControllerTest {
    
    @testSetup
    static void setupTestData() {
        Campaign cmpn01 = new Campaign();
        cmpn01.Name = 'TEST CAMPAIGN 01';
        insert cmpn01;
        
        Account a01 = new Account();
        a01.Name = 'TEST ACCOUNT 01';
        a01.BillingStreet = 'Test St';
        a01.BillingCity = 'City of Test';
        a01.BillingCountry = 'United States';
        a01.ucinn_ascendv2__PRM__c = UserInfo.getUserId();
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
        
        Opportunity Opp01 = new Opportunity();
        Opp01.Name = 'Test';
        Opp01.Description = 'Test';
        Opp01.Type = 'Type';
        Opp01.StageName = 'Planning';
        opp01.CloseDate = Date.today()+30;
        Opp01.AccountId = a01.Id;
        Opp01.ucinn_ascendv2__Credit_Date__c = System.today();
        insert Opp01;
    }
    
    @isTest(seeAllData=false)
    static void testController() {
        Campaign cmpn01 = [Select Id From Campaign Limit 1];
        Account a01 = [Select Id, ucinn_ascendv2__PRM__c From Account Where Name='TEST ACCOUNT 01'];
        Contact h01 = [Select Id, AccountId From Contact Where FirstName='h01' And LastName='TEST'];
        Opportunity opp01 = [Select Id From Opportunity Limit 1];
        
        Opportunity opp = SubProposalController.getOpportunity(opp01.Id);
    }
}