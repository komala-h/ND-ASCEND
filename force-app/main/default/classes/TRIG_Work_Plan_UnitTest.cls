@isTest(SeeAllData=false)
private class TRIG_Work_Plan_UnitTest {

    @isTest(SeeAllData=false) 
    static void insertAR() {
        
        Test.startTest();
        ucinn_ascendv2__Work_Plan_Unit__c new_ar = new ucinn_ascendv2__Work_Plan_Unit__c();

        new_ar.name	 = 'test';
        new_ar.ucinn_ascendv2__Code__c ='GH';
        //new_ar.Original_Data_Source__c = 'Constituent';
        new_ar.Sort_Order__c = 1;
        insert new_ar;
        Test.stopTest();

        ucinn_ascendv2__Work_Plan_Unit__c s01 = [SELECT Id, ucinn_ascendv2__Code__c, Sort_Order__c FROM ucinn_ascendv2__Work_Plan_Unit__c WHERE name	 = 'test'  LIMIT 1];
        System.assertEquals('GH', s01.ucinn_ascendv2__Code__c);
        System.assertEquals(1, s01.Sort_Order__c);
        

    }
}