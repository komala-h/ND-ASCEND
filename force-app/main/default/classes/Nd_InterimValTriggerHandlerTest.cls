@isTest
public class Nd_InterimValTriggerHandlerTest {

    @TestSetup
    static void setupData() {
        ucinn_ascendv2__Trigger_Handler__c customHandler = new ucinn_ascendv2__Trigger_Handler__c();
        customHandler.Name = 'Interim Validation Trigger Handler';
        customHandler.ucinn_ascendv2__Class__c = 'Nd_InterimValTriggerHandler';
        customHandler.ucinn_ascendv2__Is_Active__c = true;
        customHandler.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Interim__c';
        customHandler.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert';
        customHandler.ucinn_ascendv2__Load_Order__c = 3;
        insert customHandler;
    }

    @isTest
    static void testInterimHandler() {
        ucinn_ascendv2__Interim__c interim = new ucinn_ascendv2__Interim__c();
        interim.ucinn_ascendv2__Status__c = 'New';
        interim.ucinn_ascendv2__Address_1_Line_1__c =null;
        interim.ucinn_ascendv2__City_1__c = 'Any City';
        interim.ucinn_ascendv2__State_1__c = 'CA';
        interim.ucinn_ascendv2__Postal_Code_1__c = '90001';
        interim.ND_Address_1_Type__c='H';
        insert interim;

        interim.ucinn_ascendv2__First_Name__c = 'John';
        interim.ucinn_ascendv2__Last_Name__c = 'Smith';
        update interim;
    }

}