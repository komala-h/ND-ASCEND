@isTest(SeeAllData=false)
public class TRIG_Contact_CardTest {
      @TestSetup
    public static void testSetup() {
        TracHier.HierarchyAPI.setTriggerDisabled();
        
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
        
        Contact h01 = [SELECT Id FROM Contact WHERE FirstName='h01' LIMIT 1];
        Test.startTest();
        TracHier.HierarchyAPI.setTriggerDisabled();
        Contact_Card__c new_ar = new Contact_Card__c();
        new_ar.Constituent__c = h01.Id;
        new_ar.Contact_Type__c   = 'BD';
        new_ar.data_source__c = 'WBB';
        //new_ar.Original_Data_Source__c = 'Constituent';
        insert new_ar;
        Test.stopTest();

        Contact_Card__c a01 = [SELECT Id, Contact_Type__c FROM Contact_Card__c WHERE Constituent__c = :h01.Id  LIMIT 1];
        System.assertEquals('BD', a01.Contact_Type__c);

    }
}