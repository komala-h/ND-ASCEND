@isTest
private class Nd_ReviewTransactionV2HandlerTest {

    
     @testsetup
     static void setup() {       
        ucinn_ascendv2__Trigger_Handler__c socHandler = new ucinn_ascendv2__Trigger_Handler__c();
        socHandler.Name = 'ND';
        socHandler.ucinn_ascendv2__Class__c = 'Nd_ReviewTransactionV2Handler';
        socHandler.ucinn_ascendv2__Is_Active__c = true;
        socHandler.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Review_Transaction_v2__c';
        socHandler.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;';
        socHandler.ucinn_ascendv2__Load_Order__c=3; 
        insert socHandler; 
     }
    
    @isTest
    static void method1(){
        ucinn_ascendv2__Review_Transaction_v2__c rtv2 = new ucinn_ascendv2__Review_Transaction_v2__c(name='test',ucinn_ascendv2__External_System_ID__c='test');
       // Id rtId = Schema.SObjectType.ucinn_ascendv2__Review_Transaction_v2__c.getRecordTypeInfosByDeveloperName().get('General_Summary').getRecordTypeId();
       // rtv2.RecordTypeId=rtId;
        insert rtv2;
        ucinn_ascendv2__Review_Transaction_v2__c rtv2_1 = rtv2.clone();

        insert rtv2_1;

    }
}