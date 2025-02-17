@isTest(SeeAllData=false)
public class TRIG_Academic_OrganizationTest {
      @TestSetup
    public static void testSetup() { 
        TracHier.HierarchyAPI.setTriggerDisabled();   
        Account a = new Account(name='Sirius Satellite');
        Account a2 = new Account(name='EMPLOYER IN NAME ONLY');
        insert new List<Account>{a, a2};
            
        Contact h01 = new Contact();
        h01.FirstName = 'h01';
        h01.LastName = 'TEST';
        h01.ucinn_ascendv2__Gender__c = 'Male';
        h01.ucinn_ascendv2__Contact_Type__c = 'Alumni';
        h01.ucinn_ascendv2__Data_Source__c = 'WBB';
        h01.ucinn_ascendv2__Personal_Email__c = 'sample@uci.com';
        h01.Constituent_Status__c ='A';
        insert h01;

        
    }
    
    @isTest(SeeAllData=false) 
    static void insertAR() {
        TracHier.HierarchyAPI.setTriggerDisabled();
        Account A01 = [select id from account where name='Sirius Satellite'];
        
        Test.startTest();
        ucinn_ascendv2__Academic_Organization__c new_ar = new ucinn_ascendv2__Academic_Organization__c();
        new_ar.name='tester123';

        //new_ar.Original_Data_Source__c = 'Constituent';
        insert new_ar;
        Test.stopTest();

        ucinn_ascendv2__Academic_Organization__c s01 = [SELECT Id, name FROM ucinn_ascendv2__Academic_Organization__c WHERE name = 'tester123'  LIMIT 1];
        System.assertEquals('tester123', s01.name);

    }
}