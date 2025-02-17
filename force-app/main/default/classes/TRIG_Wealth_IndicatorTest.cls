@isTest(SeeAllData=false)
private class TRIG_Wealth_IndicatorTest {
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
        Wealth_Indicator__c new_ar2 = new Wealth_Indicator__c();

        new_ar2.Constituent__c	 = h01.Id;
        new_ar2.Comments__c = 'test';
        new_ar2.Value__c=1;

        insert new_ar2;
        Test.stopTest();

        Wealth_Indicator__c s01 = [SELECT Id, Comments__c FROM Wealth_Indicator__c WHERE Value__c	 = 1  LIMIT 1];
        System.assertEquals('test', s01.Comments__c);
        

    }
}