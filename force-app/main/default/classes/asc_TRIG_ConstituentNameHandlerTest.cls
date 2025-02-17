/**
 * @author UC Innovation
 * @date 4/20/2021
 * @description Test class for Constituent Name Trigger
 */
@isTest
private class asc_TRIG_ConstituentNameHandlerTest {
    @TestSetup
    public static void testSetup() {
        ucinn_ascendv2__Trigger_Handler__c customHandler = new ucinn_ascendv2__Trigger_Handler__c();
        customHandler.Name = 'Custom Constituent Name Handler';
        customHandler.ucinn_ascendv2__Class__c = 'asc_TRIG_ConstituentNameHandler';
        customHandler.ucinn_ascendv2__Is_Active__c = true;
        customHandler.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Contact_Name__c';
        customHandler.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;BeforeDelete;AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
        customHandler.ucinn_ascendv2__Load_Order__c = 1;
        insert customHandler;
        
        Contact contact01 = new Contact();
        contact01.FirstName = 'h01';
        contact01.LastName = 'TEST';
        contact01.ucinn_ascendv2__Gender__c = 'Male';
        contact01.ucinn_ascendv2__Contact_Type__c = 'Alumni';
        contact01.Email = 'test@test.com';
        contact01.Constituent_Status__c = 'A';
        insert contact01;
        
        
    }
    
    @isTest(SeeAllData=false) 
    static void testCustomSalutation() {
        Contact contact_h01 = [Select Id, AccountId From Contact Where FirstName='h01' And LastName='TEST'];
        
        Test.startTest();
        
        // Manually create the constituent name record
        ucinn_ascendv2__Contact_Name__c cn01 = new ucinn_ascendv2__Contact_Name__c();
        cn01.ucinn_ascendv2__Contact__c = contact_h01.Id;
        cn01.ucinn_ascendv2__First_Name__c = 'h01';
        cn01.ucinn_ascendv2__Last_Name__c = 'TEST';
        cn01.ucinn_ascendv2__Type__c = 'Full Name';
        insert cn01;
        
        cn01.ucinn_ascendv2__Middle_Name__c = 'G';
        cn01.ucinn_ascendv2__Nickname__c = 'Me';
        update cn01;
        
        Test.stopTest();
    }
}