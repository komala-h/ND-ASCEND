@isTest(SeeAllData=false)
public class TRIG_Foundation_Funding_InterestTest {
    @isTest(SeeAllData=false) 
    static void insertAR() {
        
        Test.startTest();
        ucinn_ascendv2__Foundation_Funding_Interests__c new_ar = new ucinn_ascendv2__Foundation_Funding_Interests__c();

        new_ar.name	 = 'test';
        
        insert new_ar;
        Test.stopTest();

        ucinn_ascendv2__Foundation_Funding_Interests__c s01 = [SELECT Id, name FROM ucinn_ascendv2__Foundation_Funding_Interests__c WHERE name	 = 'test'  LIMIT 1];
        System.assertEquals('test', s01.name);
        
        

    }

}