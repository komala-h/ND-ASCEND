@isTest(SeeAllData=false)
private class TRIG_Advisory_Council_RecommendationTest {

    @isTest(SeeAllData=false) 
    static void insertAR() {
        
        Test.startTest();
        TracHier.HierarchyAPI.setTriggerDisabled();
        Account hh01 = new Account();
        hh01.Name = 'TEST Household';
        hh01.ucinn_ascendv2__PRM__c = UserInfo.getUserId();
        hh01.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Household').getRecordTypeId();
        insert hh01;
        
        Contact con1 = new Contact();
        con1.FirstName = 'h01';
        con1.LastName = 'TEST';
        con1.ucinn_ascendv2__Gender__c = 'Male';
        con1.ucinn_ascendv2__Contact_Type__c = 'AL';
        con1.ucinn_ascendv2__Personal_Email__c = 'sample@uci.com';
        con1.Constituent_Status__c = 'A';
        con1.AccountId = hh01.Id;
        insert con1;

        ucinn_ascendv2__Involvement_Value__c IValue= new ucinn_ascendv2__Involvement_Value__c();
        
        IValue.name='test';
        IValue.ucinn_ascendv2__Type__c='ADC';
        IValue.ucinn_ascendv2__Involvement_Description__c='test';
        IValue.RecordTypeId = Schema.SObjectType.ucinn_ascendv2__Involvement_Value__c.getRecordTypeInfosByName().get('Advisory Council').getRecordTypeId();
        insert IValue;

        ND_Advisory_Council_Recommendation__c new_ar = new ND_Advisory_Council_Recommendation__c();
        new_ar.RecordTypeId = Schema.SObjectType.ND_Advisory_Council_Recommendation__c.getRecordTypeInfosByDeveloperName().get('Nomination').getRecordTypeId();
        new_ar.ND_Constituent__c = con1.Id;
        new_ar.ND_Advisory_Council__c   = IValue.Id;
        new_ar.ND_Decision_Summary__c = 'test test';

        insert new_ar;
        Test.stopTest();

        ND_Advisory_Council_Recommendation__c s01 = [SELECT Id, ND_Constituent__c, ND_Advisory_Council__c FROM ND_Advisory_Council_Recommendation__c where id = :new_ar.id  LIMIT 1];
        System.assertEquals(con1.Id, s01.ND_Constituent__c);
        System.assertEquals(IValue.Id, s01.ND_Advisory_Council__c);
        

    }
}