@isTest
public with sharing class asc_TRIG_InterimHandlerTest {
    @TestSetup
    static void setupData() {
        ucinn_ascendv2__Trigger_Handler__c customHandler = new ucinn_ascendv2__Trigger_Handler__c();
        customHandler.Name = 'asc_TRIG_InterimHandler';
        customHandler.ucinn_ascendv2__Class__c = 'asc_TRIG_InterimHandler';
        customHandler.ucinn_ascendv2__Is_Active__c = true;
        customHandler.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Interim__c';
        customHandler.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;BeforeDelete;AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
        customHandler.ucinn_ascendv2__Load_Order__c = 2;
        insert customHandler;
    }

    @isTest
    static void testInterimHandler() {
        ucinn_ascendv2__Interim__c interim = new ucinn_ascendv2__Interim__c();
        interim.ucinn_ascendv2__Status__c = 'New';
        interim.ucinn_ascendv2__Address_1_Line_1__c = '123 Any St';
        interim.ucinn_ascendv2__City_1__c = 'Any City';
        interim.ucinn_ascendv2__State_1__c = 'CA';
        interim.ucinn_ascendv2__Postal_Code_1__c = '90001';
        insert interim;

        interim.ucinn_ascendv2__First_Name__c = 'John';
        interim.ucinn_ascendv2__Last_Name__c = 'Smith';
        update interim;
    }

    @isTest
    static void testUpdateConstituentType1 () {
        Contact c = new Contact(
            FirstName = 'First',
            LastName = 'Test',
            Email = 'first.test@email.com',
            Constituent_Status__c = 'A'
        );
        insert c;

        ucinn_ascendv2__Interim__c interim = new ucinn_ascendv2__Interim__c();
        interim.ucinn_ascendv2__Status__c = 'New';
        interim.ucinn_ascendv2__Contact__c = c.Id;
        interim.ND_Constituent_Type__c = 'SA';
        insert interim;

        // null to SA
        interim.ucinn_ascendv2__Status__c = 'Completed';
        update interim;
        Contact cont = [SELECT Id, ucinn_ascendv2__Contact_Type__c FROM Contact WHERE Id = :c.Id];
        System.assertEquals('SA', cont.ucinn_ascendv2__Contact_Type__c);

        // SA to SA
        interim.ucinn_ascendv2__Status__c = 'New';
        interim.ND_Constituent_Type__c = 'SA';
        update interim;
        interim.ucinn_ascendv2__Status__c = 'Completed';
        update interim;
        cont = [SELECT Id, ucinn_ascendv2__Contact_Type__c FROM Contact WHERE Id = :c.Id];
        System.assertEquals('SA', cont.ucinn_ascendv2__Contact_Type__c);

        // FR to SA
        c.ucinn_ascendv2__Contact_Type__c = 'FR';
        update c;
        interim.ucinn_ascendv2__Status__c = 'New';
        interim.ND_Constituent_Type__c = 'SA';
        update interim;
        interim.ucinn_ascendv2__Status__c = 'Completed';
        update interim;
        cont = [SELECT Id, ucinn_ascendv2__Contact_Type__c FROM Contact WHERE Id = :c.Id];
        System.assertEquals('SA', cont.ucinn_ascendv2__Contact_Type__c);

        // RE to SA
        c.ucinn_ascendv2__Contact_Type__c = 'RE';
        update c;
        interim.ucinn_ascendv2__Status__c = 'New';
        interim.ND_Constituent_Type__c = 'SA';
        update interim;
        interim.ucinn_ascendv2__Status__c = 'Completed';
        update interim;
        cont = [SELECT Id, ucinn_ascendv2__Contact_Type__c FROM Contact WHERE Id = :c.Id];
        System.assertEquals('SA', cont.ucinn_ascendv2__Contact_Type__c);

        // RC to SA
        c.ucinn_ascendv2__Contact_Type__c = 'RC';
        update c;
        interim.ucinn_ascendv2__Status__c = 'New';
        interim.ND_Constituent_Type__c = 'SA';
        update interim;
        interim.ucinn_ascendv2__Status__c = 'Completed';
        update interim;
        cont = [SELECT Id, ucinn_ascendv2__Contact_Type__c FROM Contact WHERE Id = :c.Id];
        System.assertEquals('SA', cont.ucinn_ascendv2__Contact_Type__c);

        // SW to SA
        c.ucinn_ascendv2__Contact_Type__c = 'SW';
        update c;
        interim.ucinn_ascendv2__Status__c = 'New';
        interim.ND_Constituent_Type__c = 'SA';
        update interim;
        interim.ucinn_ascendv2__Status__c = 'Completed';
        update interim;
        cont = [SELECT Id, ucinn_ascendv2__Contact_Type__c FROM Contact WHERE Id = :c.Id];
        System.assertEquals('SA', cont.ucinn_ascendv2__Contact_Type__c);

        // FR to ST
        c.ucinn_ascendv2__Contact_Type__c = 'FR';
        update c;
        interim.ucinn_ascendv2__Status__c = 'New';
        interim.ND_Constituent_Type__c = 'ST';
        update interim;
        interim.ucinn_ascendv2__Status__c = 'Completed';
        update interim;
        cont = [SELECT Id, ucinn_ascendv2__Contact_Type__c FROM Contact WHERE Id = :c.Id];
        System.assertEquals('ST', cont.ucinn_ascendv2__Contact_Type__c);

        // RE to ST
        c.ucinn_ascendv2__Contact_Type__c = 'RE';
        update c;
        interim.ucinn_ascendv2__Status__c = 'New';
        interim.ND_Constituent_Type__c = 'ST';
        update interim;
        interim.ucinn_ascendv2__Status__c = 'Completed';
        update interim;
        cont = [SELECT Id, ucinn_ascendv2__Contact_Type__c FROM Contact WHERE Id = :c.Id];
        System.assertEquals('ST', cont.ucinn_ascendv2__Contact_Type__c);

        // RC to ST
        c.ucinn_ascendv2__Contact_Type__c = 'RC';
        update c;
        interim.ucinn_ascendv2__Status__c = 'New';
        interim.ND_Constituent_Type__c = 'ST';
        update interim;
        interim.ucinn_ascendv2__Status__c = 'Completed';
        update interim;
        cont = [SELECT Id, ucinn_ascendv2__Contact_Type__c FROM Contact WHERE Id = :c.Id];
        System.assertEquals('ST', cont.ucinn_ascendv2__Contact_Type__c);

        // SA to ST
        c.ucinn_ascendv2__Contact_Type__c = 'SA';
        update c;
        interim.ucinn_ascendv2__Status__c = 'New';
        interim.ND_Constituent_Type__c = 'ST';
        update interim;
        interim.ucinn_ascendv2__Status__c = 'Completed';
        update interim;
        cont = [SELECT Id, ucinn_ascendv2__Contact_Type__c FROM Contact WHERE Id = :c.Id];
        System.assertEquals('ST', cont.ucinn_ascendv2__Contact_Type__c);

        // SW to ST
        c.ucinn_ascendv2__Contact_Type__c = 'SW';
        update c;
        interim.ucinn_ascendv2__Status__c = 'New';
        interim.ND_Constituent_Type__c = 'ST';
        update interim;
        interim.ucinn_ascendv2__Status__c = 'Completed';
        update interim;
        cont = [SELECT Id, ucinn_ascendv2__Contact_Type__c FROM Contact WHERE Id = :c.Id];
        System.assertEquals('ST', cont.ucinn_ascendv2__Contact_Type__c);
    }

    @isTest
    static void testUpdateConstituentType2 () {
        Contact c = new Contact(
            FirstName = 'First',
            LastName = 'Test',
            Email = 'first.test@email.com',
            Constituent_Status__c = 'A'
        );
        insert c;

        ucinn_ascendv2__Interim__c interim = new ucinn_ascendv2__Interim__c();
        interim.ucinn_ascendv2__Status__c = 'New';
        interim.ucinn_ascendv2__Contact__c = c.Id;
        interim.ND_Constituent_Type__c = 'SW';
        insert interim;

        // null to SW
        interim.ucinn_ascendv2__Status__c = 'Completed';
        update interim;
        Contact cont = [SELECT Id, ucinn_ascendv2__Contact_Type__c FROM Contact WHERE Id = :c.Id];
        System.assertEquals('SW', cont.ucinn_ascendv2__Contact_Type__c);

        // SA to SW
        c.ucinn_ascendv2__Contact_Type__c = 'SA';
        update c;
        interim.ucinn_ascendv2__Status__c = 'New';
        interim.ND_Constituent_Type__c = 'SW';
        update interim;
        interim.ucinn_ascendv2__Status__c = 'Completed';
        update interim;
        cont = [SELECT Id, ucinn_ascendv2__Contact_Type__c FROM Contact WHERE Id = :c.Id];
        System.assertEquals('SW', cont.ucinn_ascendv2__Contact_Type__c);

        // ST to SW
        c.ucinn_ascendv2__Contact_Type__c = 'ST';
        update c;
        interim.ucinn_ascendv2__Status__c = 'New';
        interim.ND_Constituent_Type__c = 'SW';
        update interim;
        interim.ucinn_ascendv2__Status__c = 'Completed';
        update interim;
        cont = [SELECT Id, ucinn_ascendv2__Contact_Type__c FROM Contact WHERE Id = :c.Id];
        System.assertEquals('SW', cont.ucinn_ascendv2__Contact_Type__c);

        // EM;ST to AL
        c.ucinn_ascendv2__Contact_Type__c = 'EM;ST';
        update c;
        interim.ucinn_ascendv2__Status__c = 'New';
        interim.ND_Constituent_Type__c = 'AL';
        update interim;
        interim.ucinn_ascendv2__Status__c = 'Completed';
        update interim;
        cont = [SELECT Id, ucinn_ascendv2__Contact_Type__c FROM Contact WHERE Id = :c.Id];
        System.assertEquals('AL;EM', cont.ucinn_ascendv2__Contact_Type__c);

        // AL:ST to AL
        c.ucinn_ascendv2__Contact_Type__c = 'AL;ST';
        update c;
        interim.ucinn_ascendv2__Status__c = 'New';
        interim.ND_Constituent_Type__c = 'AL';
        update interim;
        interim.ucinn_ascendv2__Status__c = 'Completed';
        update interim;
        cont = [SELECT Id, ucinn_ascendv2__Contact_Type__c FROM Contact WHERE Id = :c.Id];
        System.assertEquals('AL', cont.ucinn_ascendv2__Contact_Type__c);

        // AL:EM to AL;EM;SA
        c.ucinn_ascendv2__Contact_Type__c = 'AL;EM';
        update c;
        interim.ucinn_ascendv2__Status__c = 'New';
        interim.ND_Constituent_Type__c = 'SA';
        update interim;
        interim.ucinn_ascendv2__Status__c = 'Completed';
        update interim;
        cont = [SELECT Id, ucinn_ascendv2__Contact_Type__c FROM Contact WHERE Id = :c.Id];
        System.assertEquals('AL;EM;SA', cont.ucinn_ascendv2__Contact_Type__c);

        // AL:EM to AL;EM;ST
        c.ucinn_ascendv2__Contact_Type__c = 'AL;EM';
        update c;
        interim.ucinn_ascendv2__Status__c = 'New';
        interim.ND_Constituent_Type__c = 'ST';
        update interim;
        interim.ucinn_ascendv2__Status__c = 'Completed';
        update interim;
        cont = [SELECT Id, ucinn_ascendv2__Contact_Type__c FROM Contact WHERE Id = :c.Id];
        System.assertEquals('AL;EM;ST', cont.ucinn_ascendv2__Contact_Type__c);

        // AL;EM to AL;EM;SW
        c.ucinn_ascendv2__Contact_Type__c = 'AL;EM';
        update c;
        interim.ucinn_ascendv2__Status__c = 'New';
        interim.ND_Constituent_Type__c = 'SW';
        update interim;
        interim.ucinn_ascendv2__Status__c = 'Completed';
        update interim;
        cont = [SELECT Id, ucinn_ascendv2__Contact_Type__c FROM Contact WHERE Id = :c.Id];
        System.assertEquals('AL;EM;SW', cont.ucinn_ascendv2__Contact_Type__c);

        // FR;RE;RC;SW;SA to ST
        c.ucinn_ascendv2__Contact_Type__c = 'FR;RE;RC;SW;SA';
        update c;
        interim.ucinn_ascendv2__Status__c = 'New';
        interim.ND_Constituent_Type__c = 'ST';
        update interim;
        interim.ucinn_ascendv2__Status__c = 'Completed';
        update interim;
        cont = [SELECT Id, ucinn_ascendv2__Contact_Type__c FROM Contact WHERE Id = :c.Id];
        System.assertEquals('ST', cont.ucinn_ascendv2__Contact_Type__c);
    }
}