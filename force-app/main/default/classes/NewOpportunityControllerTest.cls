/**
 * @author UC Innovation
 * @date 10/24/2021
 * @group LWC Controller
 * @description Test Class for NewOpportunityController
 */
@IsTest
public class NewOpportunityControllerTest {
    
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
        
        ucinn_ascendv2__Strategy__c str1 = new ucinn_ascendv2__Strategy__c();
        str1.ucinn_ascendv2__Account__c = a01.Id;
        str1.ucinn_ascendv2__Strategy_Date__c = System.today();
        str1.ucinn_ascendv2__Strategy_Detail__c = 'test1';
        str1.ucinn_ascendv2__Strategy_Summary__c = 'test1';
        str1.nd_Unrestricted_Ask_Amount__c = 100;
        insert str1;
    }
    
    @isTest(seeAllData=false)
    static void testController() {
        Campaign cmpn01 = [Select Id From Campaign Limit 1];
        Account a01 = [Select Id, ucinn_ascendv2__PRM__c From Account Where Name='TEST ACCOUNT 01'];
        Contact h01 = [Select Id, AccountId From Contact Where FirstName='h01' And LastName='TEST'];
        ucinn_ascendv2__Strategy__c s01 = [Select Id From ucinn_ascendv2__Strategy__c Limit 1];
        
        Account acc = NewOpportunityController.getAccount(a01.Id);
        ucinn_ascendv2__Strategy__c stg = NewOpportunityController.getStrategy(s01.Id);
        Campaign cmp = NewOpportunityController.getCurrentComprehensiveCampaign();
        
        Map<String, Object> oppMap = new Map<String, Object>();
        oppMap.put('Name', 'Test');
        oppMap.put('Description', 'Test');
        oppMap.put('Type', 'Field');
        oppMap.put('StageName', 'Planning');
        oppMap.put('AccountId', a01.Id);
        oppMap.put('CampaignId', cmpn01.Id);
        oppMap.put('nd_Likelihood_to_Close__c', '50');
        oppMap.put('nd_Research_Award_Number__c', '123');
        oppMap.put('ucinn_ascendv2__Expected_Close_Date__c', '2021-12-31');
        oppMap.put('ucinn_ascendv2__Submitted_Date__c', '2021-12-31');
        oppMap.put('ucinn_ascendv2__Submitted_Amount__c', 100);
        oppMap.put('nd_Answer_Amount__c', 100);
        
        List<Map<String, Object>> subproposalMapList = new List<Map<String, Object>>();
        Map<String, Object> subproposalMap = new Map<String, Object>();
        subproposalMap.put('Type__c', 'PG');
        subproposalMap.put('Planned_Gift_Type__c', 'Z');
        subproposalMap.put('Amount__c', '100');
        subproposalMapList.add(subproposalMap);
        
        List<Map<String, Object>> oppteammemberMapList = new List<Map<String, Object>>();
        Map<String, Object> oppteammemberMap = new Map<String, Object>();
        oppteammemberMap.put('UserId', UserInfo.getUserId());
        oppteammemberMap.put('TeamMemberRole', 'RM');
        oppteammemberMapList.add(oppteammemberMap);
        
        List<Map<String, Object>> oppcontactroleMapList = new List<Map<String, Object>>();
        Map<String, Object> oppcontactroleMap = new Map<String, Object>();
        oppcontactroleMap.put('ContactId', h01.Id);
        oppcontactroleMap.put('Role', 'Influencer');
        oppcontactroleMapList.add(oppcontactroleMap);
        
        String helptext = NewOpportunityController.getFieldHelpText('Sub_Proposal__c', 'Funding_Priority__c');
        
        try {
            NewOpportunityController.saveOpportunity(oppMap, subproposalMapList, oppteammemberMapList, oppcontactroleMapList);
        }
        catch (Exception ex) {}
    }
}