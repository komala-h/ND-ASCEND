@isTest(SeeAllData=false)
public class TRIG_ND_Geo_Group_RegionTest {
      @TestSetup
    public static void testSetup() {

        Account a01 = new Account();
        a01.Name = 'TEST ACCOUNT 01';
        a01.BillingStreet = 'Test St';
        a01.BillingCity = 'City of Test';
        a01.BillingCountry = 'United States';
        a01.Online_Only__c = true;
        insert a01;
        
        Contact h01 = new Contact();
        h01.AccountId = a01.Id;
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

        Test.startTest();
        ND_Geo_Group_Region__c new_ar = new ND_Geo_Group_Region__c();
        new_ar.Postal_Code__c = '57426';
        new_ar.MSA_Name__c	 = 'Aberdeen, SD';
        
        insert new_ar;
        Test.stopTest();

        ND_Geo_Group_Region__c a01 = [SELECT Id, Postal_Code__c, MSA_Name__c FROM ND_Geo_Group_Region__c ];
        System.assertEquals('57426', a01.Postal_Code__c);
        System.assertEquals('Aberdeen, SD', a01.MSA_Name__c);

    }
}