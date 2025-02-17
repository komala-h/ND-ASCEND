/**
 * @author UC Innovation
 * @date 2/2/2023
 * @description Test class for Session Trigger
 */

@isTest
private class asc_TRIG_SessionHandlerTest {

    @TestSetup
    public static void testSetup() {
        
        TracHier.HierarchyAPI.setTriggerDisabled();
     
        ucinn_ascendv2__Trigger_Handler__c customHandler01 = new ucinn_ascendv2__Trigger_Handler__c();
        customHandler01.Name = 'ND Session Handler';
        customHandler01.ucinn_ascendv2__Class__c = 'asc_TRIG_SessionHandler';
        customHandler01.ucinn_ascendv2__Is_Active__c = true;
        customHandler01.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Session__c';
        customHandler01.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;BeforeDelete;AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
        customHandler01.ucinn_ascendv2__Load_Order__c = 1.0;
        insert customHandler01;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User userIsDevCoordinator = new User(
            // UserRoleId = ur.Id,
            ProfileId = p.Id,
            Username = System.now().millisecond() + 'testUC1@testUC1.com',
            Alias = 'bwyane',
            Email='bruce.wayne@wayneenterprises.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        insert userIsDevCoordinator;                     

        User userWithDevCoordinator = new User(
            // UserRoleId = ur.Id,
            ProfileId = p.Id,
            Username = System.now().millisecond() + '2testUC1@testUC1.com',
            Alias = '2bwyane',
            Email='2bruce.wayne@wayneenterprises.com',
            EmailEncodingKey='UTF-8',
            Firstname='2Bruce',
            Lastname='2Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago',
            Development_Coordinator__c = userIsDevCoordinator.Id
        );
        insert userWithDevCoordinator;
        
        User userWithoutDevCoordinator = new User(
            // UserRoleId = ur.Id,
            ProfileId = p.Id,
            Username = System.now().millisecond() + '3testUC1@testUC1.com',
            Alias = '3bwyane',
            Email='3bruce.wayne@wayneenterprises.com',
            EmailEncodingKey='UTF-8',
            Firstname='3Bruce',
            Lastname='3Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        insert userWithoutDevCoordinator;

        Account accountWithDevCoordinator = new Account();
        accountWithDevCoordinator.Name = 'AccountWithDevCoordinator';
        accountWithDevCoordinator.ucinn_ascendv2__PRM__c = userWithDevCoordinator.Id;
        insert accountWithDevCoordinator;

        Account accountNoDevCoordinator = new Account();
        accountNoDevCoordinator.Name = 'AccountNoDevCoordinator';
        accountNoDevCoordinator.ucinn_ascendv2__PRM__c = userWithoutDevCoordinator.Id;
        insert accountNoDevCoordinator;

        Contact h01 = new Contact();
        h01.FirstName = 'h01';
        h01.LastName = 'TEST';
        h01.ucinn_ascendv2__Gender__c = 'Male';
        h01.ucinn_ascendv2__Contact_Type__c = 'AL';
        h01.ucinn_ascendv2__Personal_Email__c = 'sample@uci.com';
        h01.Constituent_Status__c = 'A';
        h01.Account = accountWithDevCoordinator;
        h01.AccountId = accountWithDevCoordinator.Id;
        insert h01;

        Contact h02 = new Contact();
        h02.FirstName = 'h02';
        h02.LastName = 'TEST';
        h02.ucinn_ascendv2__Gender__c = 'Male';
        h02.ucinn_ascendv2__Contact_Type__c = 'AL';
        h02.ucinn_ascendv2__Personal_Email__c = 'sample2@uci.com';
        h02.Constituent_Status__c = 'A';
        h02.Account = accountNoDevCoordinator;
        h02.AccountId = accountNoDevCoordinator.Id;
        insert h02;

        ucinn_ascendv2__Session__c sessionOppWithDevCoord = new ucinn_ascendv2__Session__c(
            Name = 'sessionOppWithDevCoord'
        );
        insert sessionOppWithDevCoord;

        ucinn_ascendv2__Session__c sessionOppNoDevCoord = new ucinn_ascendv2__Session__c(
            Name = 'sessionOppNoDevCoord'
        );
        insert sessionOppNoDevCoord;

        Id pledgeRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Pledge').getRecordTypeId();

        Opportunity oppWithDevCoord = new Opportunity(
            Name = 'oppWithDevCoord',
            RecordTypeId = pledgeRecordTypeId,
            AccountId = accountWithDevCoordinator.Id,
            ucinn_ascendv2__Contact__c = h01.Id,
            StageName = 'Active',
            CloseDate = date.today(),
            ucinn_ascendv2__Session__c = sessionOppWithDevCoord.Id,
            ucinn_ascendv2__Pledge_Gift_Contact__c = h01.Id,
            ucinn_ascendv2__Credit_Date__c = System.today()
        );
        insert oppWithDevCoord;

        Opportunity oppNoDevCoord = new Opportunity(
            Name = 'oppNoDevCoord',
            RecordTypeId = pledgeRecordTypeId,
            AccountId = accountNoDevCoordinator.Id,
            ucinn_ascendv2__Contact__c = h02.Id,
            StageName = 'Active',
            CloseDate = date.today(),
            ucinn_ascendv2__Session__c = sessionOppNoDevCoord.Id,
            ucinn_ascendv2__Pledge_Gift_Contact__c = h02.Id,
            ucinn_ascendv2__Credit_Date__c = System.today()
        );
        insert oppNoDevCoord;

        // system.debug('!!! h01.Account.Id ' + h01.Account.Id);

        // // ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger('Opportunity', true);
        // h01.Account = accountWithDevCoordinator;
        // h01.AccountId = accountWithDevCoordinator.Id;
        // update h01;

        // system.debug('h01 ' + h01);
        
        // List<Opportunity> opps = [SELECT Id, Name, RecordTypeId, AccountId, ucinn_ascendv2__Contact__c, StageName, CloseDate, ucinn_ascendv2__Session__c, ucinn_ascendv2__Pledge_Gift_Contact__c, ucinn_ascendv2__Pledge_Gift_Contact__r.Account.Id, ucinn_ascendv2__Pledge_Gift_Contact__r.AccountId
        //             FROM Opportunity];
        // for (Opportunity opp : opps) {
        //     system.debug('!!! opp '  + opp);
        //     system.debug(opp.ucinn_ascendv2__Pledge_Gift_Contact__r.AccountId);
        //     system.debug(opp.ucinn_ascendv2__Pledge_Gift_Contact__r.Account);
        //     system.debug(opp.ucinn_ascendv2__Pledge_Gift_Contact__r.Account.Id);
        // }

        ucinn_ascendv2__Designation_Detail__c desig = new ucinn_ascendv2__Designation_Detail__c();
        desig.ucinn_ascendv2__Opportunity__c = oppWithDevCoord.Id;
        insert desig;

        ucinn_ascendv2__Payment__c paymentWithDevCoord = new ucinn_ascendv2__Payment__c(
            ucinn_ascendv2__Opportunity__c = oppWithDevCoord.Id,
            ucinn_ascendv2__Status__c = 'Paid',
            ucinn_ascendv2__Transaction_Type__c = 'Pledge Payment',
            ucinn_ascendv2__Designation_Detail__c = desig.Id,
            ucinn_ascendv2__Session__c = sessionOppWithDevCoord.Id,
            ucinn_ascendv2__Contact__c = h01.Id,
            ucinn_ascendv2__Account__c = accountWithDevCoordinator.Id,
            ND_Pledge_Payment_Type__c = 'GP'
        );
        insert paymentWithDevCoord;


        ucinn_ascendv2__Payment__c paymentNoDevCoord = new ucinn_ascendv2__Payment__c(
            ucinn_ascendv2__Opportunity__c = oppNoDevCoord.Id,
            ucinn_ascendv2__Status__c = 'Paid',
            ucinn_ascendv2__Transaction_Type__c = 'Pledge Payment',
            ucinn_ascendv2__Designation_Detail__c = desig.Id,
            ucinn_ascendv2__Session__c = sessionOppNoDevCoord.Id,
            ucinn_ascendv2__Contact__c = h02.Id,
            ucinn_ascendv2__Account__c = accountNoDevCoordinator.Id,
            ND_Pledge_Payment_Type__c = 'GP'
        );
        insert paymentNoDevCoord;

    }


    @isTest
    static void testActionCenterNotificationsWithDevCoord() {
        TracHier.HierarchyAPI.setTriggerDisabled();
        List<ucinn_ascendv2__Action_Center_Staging__c> actionCenterNotifications = [SELECT Id FROM ucinn_ascendv2__Action_Center_Staging__c];
        system.assert(actionCenterNotifications.size() == 0, 'Begin with no Action Center Staging notifications');

        ucinn_ascendv2__Session__c ses = [SELECT Id FROM ucinn_ascendv2__Session__c WHERE (Name = 'sessionOppWithDevCoord') LIMIT 1];

        Test.startTest();
        TracHier.HierarchyAPI.setTriggerDisabled();
        ses.ucinn_ascendv2__Session_Totals_Approved__c = date.today();
        update ses;
        actionCenterNotifications = [SELECT Id FROM ucinn_ascendv2__Action_Center_Staging__c];
        system.assert(actionCenterNotifications.size() == 2, 'After updating, needs 2 Action Center Staging notifications');
        Test.stopTest();

    }

    @isTest
    static void testActionCenterNotificationsNoDevCoord() {
        TracHier.HierarchyAPI.setTriggerDisabled();
        List<ucinn_ascendv2__Action_Center_Staging__c> actionCenterNotifications = [SELECT Id FROM ucinn_ascendv2__Action_Center_Staging__c];
        system.assert(actionCenterNotifications.size() == 0, 'Begin with no Action Center Staging notifications');

        ucinn_ascendv2__Session__c ses = [SELECT Id FROM ucinn_ascendv2__Session__c WHERE (Name = 'sessionOppNoDevCoord') LIMIT 1];

        Test.startTest();
        TracHier.HierarchyAPI.setTriggerDisabled();
        ses.ucinn_ascendv2__Session_Totals_Approved__c = date.today();
        update ses;
        actionCenterNotifications = [SELECT Id FROM ucinn_ascendv2__Action_Center_Staging__c];
        system.assert(actionCenterNotifications.size() == 1, 'After updating, needs 1 Action Center Staging notification');
        Test.stopTest();

        
    }
}