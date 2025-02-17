@isTest(SeeAllData=false)
public class TRIG_Organization_Alternate_IdTest {
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
        Account A01 = [select id from account where name='Sirius Satellite'];
        
        Test.startTest();
        TracHier.HierarchyAPI.setTriggerDisabled();
        Organization_Alternate_Id__c new_ar = new Organization_Alternate_Id__c();
        new_ar.Organization__c = A01.Id;
        new_ar.ID_Other__c   = 'jimandsam';
        //new_ar.Original_Data_Source__c = 'Constituent';
        insert new_ar;
        Test.stopTest();

        Organization_Alternate_Id__c s01 = [SELECT Id, ID_Other__c FROM Organization_Alternate_Id__c WHERE Organization__c = :A01.Id  LIMIT 1];
        System.assertEquals('jimandsam', s01.ID_Other__c);

    }
}