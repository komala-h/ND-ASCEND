@isTest(SeeAllData=false)
private class TRIG_CampaignTest {

    @isTest(SeeAllData=false) 
    static void insertAR() {
        
        Test.startTest();
        Campaign new_ar = new Campaign();

        new_ar.name	 = 'test';
        new_ar.status ='In Progress';
        //new_ar.Original_Data_Source__c = 'Constituent';
        //new_ar.Sort_Order__c = 1;
        insert new_ar;
        Test.stopTest();

        Campaign s01 = [SELECT Id, status FROM Campaign WHERE name	 = 'test'  LIMIT 1];
        System.assertEquals('In Progress', s01.status);
        //System.assertEquals(1, s01.Sort_Order__c);
        

    }
}