@isTest(SeeAllData=false)
public class TRIG_Alternate_IdTest {

    
        @TestSetup
    public static void testSetup() {
        ucinn_ascendv2__Trigger_Handler__c customHandler1 = new ucinn_ascendv2__Trigger_Handler__c();
            customHandler1.Name = 'Alternate Id Int out Handler';
            customHandler1.ucinn_ascendv2__Class__c = 'TRIG_IntegrationOutHandler';
            customHandler1.ucinn_ascendv2__Is_Active__c = true;
            customHandler1.ucinn_ascendv2__Object__c = 'Alternate_ID__c';
            customHandler1.ucinn_ascendv2__Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
            customHandler1.ucinn_ascendv2__Load_Order__c = 1;
        insert customHandler1;
        
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
        Alternate_ID__c new_ar = new Alternate_ID__c();
        new_ar.Constituent__c = h01.Id;
        new_ar.ID_Type__c = 'NET';
        new_ar.Other_ID__c = 'sfarris';
        //new_ar.Original_Data_Source__c = 'Constituent';
        insert new_ar;
        Test.stopTest();

        Alternate_ID__c a01 = [SELECT Id, Other_ID__c FROM Alternate_ID__c WHERE Constituent__c = :h01.Id  LIMIT 1];
        System.assertEquals('sfarris', a01.Other_ID__c);

    }
}