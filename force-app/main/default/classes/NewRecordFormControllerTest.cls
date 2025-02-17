/**
 * @author UC Innovation
 * @date 2/11/2023
 * @group LWC Controller
 * @description Test Class for NewRecordFormController
 */
@IsTest
public class NewRecordFormControllerTest {
    
    
    @testSetup
    static void setupTestData() {
        
    }
    
    @isTest(seeAllData=false)
    static void testController() {
        TracHier.HierarchyAPI.setTriggerDisabled();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='otheruser@testorg.com');
        insert u;
        User u1 = [SELECT Id FROM User WHERE UserName = 'otheruser@testorg.com' LIMIT 1];
        
        
        Account a01 = new Account();
        a01.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get('Household').getRecordTypeId();
        a01.Name = 'TEST ACCOUNT 01';
        insert a01;
        Account a02 = [SELECT Id FROM Account WHERE Name = 'TEST ACCOUNT 01' LIMIT 1];
        
        Contact h01 = new Contact();
        h01.AccountId = a01.Id;
        h01.FirstName = 'h01';
        h01.LastName = 'TEST';
        h01.ucinn_ascendv2__Gender__c = 'Male';
        h01.ucinn_ascendv2__Contact_Type__c = 'Alumni';
        h01.ucinn_ascendv2__Data_Source__c = 'AA';
        h01.ucinn_ascendv2__Personal_Email__c = 'sample@uci.com';
        h01.Constituent_Status__c = 'A';
        insert h01;
        Contact h02 = [SELECT Id FROM Contact WHERE LastName = 'Test' LIMIT 1];
        
                
        ucinn_ascendv2__Contact_Report__c cr01 = new ucinn_ascendv2__Contact_Report__c();
        cr01.ucinn_ascendv2__Contact__c = h01.Id;
        cr01.OwnerId = u1.Id;
        cr01.Author__c = u1.id;
        //cr01.ucinn_ascendv2__Account__c = a01.Id;
        insert cr01;
        ucinn_ascendv2__Contact_Report__c cr02 = [SELECT Id FROM ucinn_ascendv2__Contact_Report__c WHERE (ucinn_ascendv2__Contact__c =: h02.Id) LIMIT 1];

        
        Task ts01 = new Task();
        ts01.WhoId = h01.Id;
        ts01.ActivityDate = date.today();
        ts01.Description = 'Test';
        insert ts01;
        Task ts02 = [SELECT Id FROM Task WHERE (WhoId =: h02.Id) LIMIT 1];
        
        Test.startTest(); 
        
        NewRecordFormController.getLayoutFromRecordType(Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get('Household').getRecordTypeId());
        NewRecordFormController.getPageLayoutFields('ucinn_ascendv2__Contact_Report__c', 'ucinn_ascendv2__Contact_Report__c-ucinn_ascendv2__Contact Report Layout');
        
        Test.stopTest();
    }
}