@isTest(SeeAllData=false)
private class TRIG_CampaignMemberTest {

    @isTest(SeeAllData=false) 
    static void insertAR() {
        
        Test.startTest();
        Contact nc = new Contact();
        nc.FirstName ='Sarah';
        nc.LastName = 'Farris';
        nc.Email ='sarahfarris@tntech.edu';
        nc.Constituent_Status__c = 'A';
        insert nc;
        
        Campaign new_ac = new Campaign();
        new_ac.name	 = 'test';
        new_ac.status ='In Progress';
        insert new_ac;
        
        
        CampaignMember new_ar = new CampaignMember();
        new_ar.ContactId = nc.id;
        new_ar.campaignId = new_ac.id;
        new_ar.status ='Sent';
        insert new_ar;
        Test.stopTest();

        CampaignMember s01 = [SELECT Id, ContactId, campaignId, status FROM CampaignMember WHERE id	 =  :new_ar.id  LIMIT 1];
        System.assertEquals('Sent', s01.status);
        System.assertEquals(new_ac.id, s01.campaignId);
     }
}