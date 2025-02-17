@isTest(SeeAllData=false)
private class TRIG_Major_codeTest {
  
    @isTest(SeeAllData=false) 
    static void insertAR() {
        
        Test.startTest();
        ucinn_ascendv2__Post_Code__c new_ar = new ucinn_ascendv2__Post_Code__c();

        new_ar.name	 = 'test';
        new_ar.ucinn_ascendv2__Major_Specialty__c ='entomology';
        //new_ar.Original_Data_Source__c = 'Constituent';
        insert new_ar;
        Test.stopTest();

        ucinn_ascendv2__Post_Code__c s01 = [SELECT Id, ucinn_ascendv2__Major_Specialty__c FROM ucinn_ascendv2__Post_Code__c WHERE name	 = 'test'  LIMIT 1];
        System.assertEquals('entomology', s01.ucinn_ascendv2__Major_Specialty__c);

    }
}