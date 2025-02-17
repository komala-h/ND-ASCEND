@isTest(SeeAllData=false)
private class TRIG_ConcentrationTest {

    @isTest(SeeAllData=false) 
    static void insertAR() {
        
        Test.startTest();
        ucinn_ascendv2__Specialty__c new_ar = new ucinn_ascendv2__Specialty__c();

        new_ar.name	 = 'test';
        new_ar.Concentration_Code__c ='GH';
        //new_ar.Original_Data_Source__c = 'Constituent';
        insert new_ar;
        Test.stopTest();

        ucinn_ascendv2__Specialty__c s01 = [SELECT Id, Concentration_Code__c FROM ucinn_ascendv2__Specialty__c WHERE name	 = 'test'  LIMIT 1];
        System.assertEquals('GH', s01.Concentration_Code__c);

    }
}