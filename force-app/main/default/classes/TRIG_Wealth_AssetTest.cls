@isTest(SeeAllData=false)
private class TRIG_Wealth_AssetTest {

    @isTest(SeeAllData=false) 
    static void insertAR() {
       
        Test.startTest();
        Wealth_Asset__c new_ar = new Wealth_Asset__c();

        new_ar.name	 = 'Company Valuation';
        new_ar.Category__c ='Company Valuation';
        new_ar.Status__c = 'Active';
        new_ar.Value_Evaluation_Date__c = system.today();
        insert new_ar;
        Test.stopTest();

        
        Wealth_Asset__c s01 = [SELECT Id, Category__c FROM Wealth_Asset__c where name	 = 'Company Valuation'  LIMIT 1];
        System.assertEquals('Company Valuation', s01.Category__c);
    }
}