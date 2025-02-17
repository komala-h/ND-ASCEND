/**
 * @author UC Innovation
 * @date 3/9/2022
 * @description Test class for Phone Trigger
 */
@isTest
private class asc_TRIG_PhoneHandlerTest {
    @TestSetup
    public static void testSetup() {
        ucinn_ascendv2__Trigger_Handler__c customHandler02 = new ucinn_ascendv2__Trigger_Handler__c();
        customHandler02.Name = 'Custom Address Relation Handler';
        customHandler02.ucinn_ascendv2__Class__c = 'asc_TRIG_AddressRelationHandler';
        customHandler02.ucinn_ascendv2__Is_Active__c = true;
        customHandler02.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Address_Relation__c';
        customHandler02.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;BeforeDelete;AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
        customHandler02.ucinn_ascendv2__Load_Order__c = 2;
        insert customHandler02;

        ucinn_ascendv2__Trigger_Handler__c customHandler03 = new ucinn_ascendv2__Trigger_Handler__c();
        customHandler03.Name = 'Custom Phone Handler';
        customHandler03.ucinn_ascendv2__Class__c = 'asc_TRIG_PhoneHandler';
        customHandler03.ucinn_ascendv2__Is_Active__c = true;
        customHandler03.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Phone__c';
        customHandler03.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;BeforeDelete;AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
        customHandler03.ucinn_ascendv2__Load_Order__c = 2;
        insert customHandler03;

        ucinn_ascendv2__Trigger_Handler__c customHandler04 = new ucinn_ascendv2__Trigger_Handler__c();
        customHandler04.Name = 'Custom Email Handler';
        customHandler04.ucinn_ascendv2__Class__c = 'asc_TRIG_EmailHandler';
        customHandler04.ucinn_ascendv2__Is_Active__c = true;
        customHandler04.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Email__c';
        customHandler04.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;BeforeDelete;AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
        customHandler04.ucinn_ascendv2__Load_Order__c = 2;
        insert customHandler04;        
        
        ucinn_ascendv2__Trigger_Handler__c customHandler05 = new ucinn_ascendv2__Trigger_Handler__c();
        customHandler05.Name = 'Custom Affiliation Handler';
        customHandler05.ucinn_ascendv2__Class__c = 'asc_TRIG_AffiliationHandler';
        customHandler05.ucinn_ascendv2__Is_Active__c = true;
        customHandler05.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Affiliation__c';
        customHandler05.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;BeforeDelete;AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
        customHandler05.ucinn_ascendv2__Load_Order__c = 2;
        insert customHandler05;   
        
        Contact h01 = new Contact();
        h01.FirstName = 'h01';
        h01.LastName = 'TEST';
        h01.ucinn_ascendv2__Gender__c = 'Male';
        h01.ucinn_ascendv2__Contact_Type__c = 'AL';
        h01.ucinn_ascendv2__Personal_Email__c = 'sample@uci.com';
        h01.Constituent_Status__c = 'A';
        insert h01;

        Account a01 = new Account();
        a01.Name = 'AccountName';
        insert a01;

        ucinn_ascendv2__Affiliation__c affil = new ucinn_ascendv2__Affiliation__c();
        affil.ucinn_ascendv2__Account__c = a01.Id;
        affil.ucinn_ascendv2__Contact__c = h01.Id;
        affil.ucinn_ascendv2__Status__c = 'Current';
        affil.ucinn_ascendv2__Data_Source__c = 'AC';
        affil.ucinn_ascendv2__Constituent_Role__c = 'Employee';
        insert affil;

        ucinn_ascendv2__Phone__c phone = new ucinn_ascendv2__Phone__c();
        phone.ucinn_ascendv2__Type__c = 'B';
        phone.ucinn_ascendv2__Status__c = 'Former';
        phone.ucinn_ascendv2__Phone_Number__c = '1234567890';
        phone.ucinn_ascendv2__Contact__c = h01.Id;
        phone.ucinn_ascendv2__End_Date__c = system.today();
        insert phone;
        

    }
    
    @isTest(SeeAllData=false) 
    static void testSyncAffiliationFromPhone() {

        ucinn_ascendv2__Phone__c phone = [SELECT Id
                                          FROM ucinn_ascendv2__Phone__c
                                          WHERE (ucinn_ascendv2__Type__c = 'B')
                                          LIMIT 1];

        ucinn_ascendv2__Affiliation__c affil = [SELECT Id, Business_Phone__c 
                                                FROM ucinn_ascendv2__Affiliation__c 
                                                WHERE (ucinn_ascendv2__Status__c = 'Current')
                                                LIMIT 1];


        system.assert(affil.Business_Phone__c == null);

        Test.startTest();
        phone.Affiliation__c = affil.Id;
        update phone;
        Test.stopTest();

        affil = [SELECT Id, Business_Phone__c 
                FROM ucinn_ascendv2__Affiliation__c 
                WHERE (ucinn_ascendv2__Status__c = 'Current')
                LIMIT 1];
            
        system.assert(affil.Business_Phone__c == phone.Id);
        
    }
    
    @isTest(SeeAllData=false) 
    static void FormertoCurrentPhoneStatus() {
        ucinn_ascendv2__Phone__c phone = [SELECT Id, ucinn_ascendv2__status__c
                                          FROM ucinn_ascendv2__Phone__c
                                          WHERE (ucinn_ascendv2__Type__c = 'B')
                                          LIMIT 1];
        Test.startTest();
        phone.ucinn_ascendv2__status__c = 'Current';
        update phone;
        Test.stopTest();
        
        ucinn_ascendv2__Phone__c phone1 = [SELECT Id, ucinn_ascendv2__end_date__c
                                          FROM ucinn_ascendv2__Phone__c
                                          WHERE (ucinn_ascendv2__Type__c = 'B')
                                          LIMIT 1];
                                          
        system.assert(phone1.ucinn_ascendv2__End_Date__c == null);
    }

}