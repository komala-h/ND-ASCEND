/**
 * @author UC Innovation
 * @date 3/10/2022
 * @description Test class for Email Trigger
 */
@isTest
private class asc_TRIG_EmailHandlerTest {
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
        
        List<Account> acctsList = new List<Account>();

        Account hh01 = new Account();
        hh01.Name = 'TEST Household';
        hh01.ucinn_ascendv2__PRM__c = UserInfo.getUserId();
        hh01.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Household').getRecordTypeId();
        acctsList.add(hh01);

        Account UNDAccount = new Account();
        UNDAccount.Name = 'University of Notre Dame';
        UNDAccount.ucinn_ascendv2__Donor_ID__c = '307129';
        UNDAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporations_and_Organizations').getRecordTypeId();
        acctsList.add(UNDAccount);

        insert acctsList;

        Contact h01 = new Contact();
        h01.FirstName = 'h01';
        h01.LastName = 'TEST';
        h01.ucinn_ascendv2__Gender__c = 'Male';
        h01.ucinn_ascendv2__Contact_Type__c = 'AL';
        h01.ucinn_ascendv2__Personal_Email__c = 'sample@uci.com';
        h01.Constituent_Status__c = 'A';
        h01.ucinn_ascendv2__Data_Source__c = 'B';
        h01.AccountId = hh01.Id;
        insert h01;

        Account a01 = new Account();
        a01.Name = 'AccountName';
        insert a01;

        ucinn_ascendv2__Affiliation__c affil = new ucinn_ascendv2__Affiliation__c();
        affil.ucinn_ascendv2__Account__c = a01.Id;
        affil.ucinn_ascendv2__Contact__c = h01.Id;
        affil.ucinn_ascendv2__Status__c = 'Current';
        affil.ucinn_ascendv2__Constituent_Role__c = 'Employee';
        affil.ucinn_ascendv2__Data_Source__c = 'B';
        affil.Name = '[Default Name]';
        affil.ucinn_ascendv2__Start_Date__c = date.today();
        insert affil;

        ucinn_ascendv2__Email__c email = new ucinn_ascendv2__Email__c();
        email.ucinn_ascendv2__Type__c = 'U';
        email.ucinn_ascendv2__Status__c = 'Current';
        email.ucinn_ascendv2__Data_Source__c = 'AA';
        email.ucinn_ascendv2__Contact__c = h01.Id;
        insert email;
        

    }
    
    @isTest(SeeAllData=false) 
    static void testSyncAffiliationFromEmail() {

        ucinn_ascendv2__Email__c email = [SELECT Id
                                          FROM ucinn_ascendv2__Email__c
                                          WHERE (ucinn_ascendv2__Type__c = 'U')
                                          LIMIT 1];

        ucinn_ascendv2__Affiliation__c affil = [SELECT Id, Business_Email__c 
                                                FROM ucinn_ascendv2__Affiliation__c 
                                                WHERE (ucinn_ascendv2__Status__c = 'Current')
                                                LIMIT 1];


        system.assert(affil.Business_Email__c == null);

        Test.startTest();
        email.Affiliation__c = affil.Id;
        update email;
        Test.stopTest();

        affil = [SELECT Id, Business_Email__c 
                FROM ucinn_ascendv2__Affiliation__c 
                WHERE (ucinn_ascendv2__Status__c = 'Current')
                LIMIT 1];
            
        system.assert(affil.Business_Email__c == email.Id);
        
    }
    
    @isTest(SeeAllData=false) 
    static void CurrenttoFormerPhoneStatus() {
        ucinn_ascendv2__Email__c email = [SELECT Id, ucinn_ascendv2__status__c
                                          FROM ucinn_ascendv2__Email__c
                                          WHERE (ucinn_ascendv2__Type__c = 'U')
                                          LIMIT 1];
        Test.startTest();
        email.ucinn_ascendv2__status__c = 'Former';
        update email;
        Test.stopTest();
        
        ucinn_ascendv2__Email__c email1 = [SELECT Id, ucinn_ascendv2__end_date__c
                                          FROM ucinn_ascendv2__Email__c
                                          WHERE (ucinn_ascendv2__Type__c = 'U')
                                          LIMIT 1];
                                          
        system.assert(email1.ucinn_ascendv2__End_Date__c == system.today());
    }

}