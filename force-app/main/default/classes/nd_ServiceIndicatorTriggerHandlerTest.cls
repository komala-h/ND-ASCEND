/*
 * Description: Test Class for nd_ServiceIndicatorTriggerHandlerCls
 * Created Date: 25/01/2023
*/


@isTest
public class nd_ServiceIndicatorTriggerHandlerTest {
 @testsetup
    static void insertrec(){
        ucinn_ascendv2__Trigger_Handler__c siHandler = new ucinn_ascendv2__Trigger_Handler__c();
        siHandler.Name = 'nd ServiceIndicatorTriggerr';
        siHandler.ucinn_ascendv2__Class__c = 'nd_ServiceIndicatorTriggerHandlerCls';
        siHandler.ucinn_ascendv2__Is_Active__c = true;
        siHandler.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Service_Indicator__c';
        siHandler.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;BeforeDelete;AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
        insert siHandler; 
        
        
        Test.startTest();
        list<ucinn_ascendv2__Service_Indicator__c> ndServInd = new list<ucinn_ascendv2__Service_Indicator__c>();
         Account a = new Account(Name = 'Test',ucinn_ascendv2__Email__c='abc@test.com',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporations and Organizations').getRecordTypeId());        
        insert a;
        //Create a Contact    
        Contact c = new Contact(FirstName = 'Test 1', LastName = 'Contact', AccountId = a.Id,email='abc@def.com',Constituent_Status__c = 'A');
        insert c;
        //Service Indicator
        ucinn_ascendv2__Service_Indicator__c serv = new ucinn_ascendv2__Service_Indicator__c(ucinn_ascendv2__Contact__c = c.Id, Data_Source__c = 'AC');
        insert serv;
        ndServInd.add(serv);
        Test.stopTest();
    }
    @isTest
    static void method1() {
        Test.startTest();
    list<ucinn_ascendv2__Service_Indicator__c> SI = new list<ucinn_ascendv2__Service_Indicator__c>();
         Account a = [select id,ucinn_ascendv2__Email__c,RecordTypeId from Account where Name = 'Test' limit 1];
        Contact c = [select id,FirstName,LastName,AccountId,nd_SIG__c,email from Contact limit 1];
        ucinn_ascendv2__Service_Indicator_Value__c Servalue = new ucinn_ascendv2__Service_Indicator_Value__c(name='Daily List' , RecordTypeId = Schema.SObjectType.ucinn_ascendv2__Service_Indicator_Value__c.getRecordTypeInfosByName().get('Mailing List Service Indicator').getRecordTypeId());
       insert Servalue;
         ucinn_ascendv2__Service_Indicator__c serv = new ucinn_ascendv2__Service_Indicator__c(ucinn_ascendv2__Contact__c = c.Id,Data_Source__c = 'AC',ucinn_ascendv2__Service_Indicator_Value__c = Servalue.Id );
        
        insert serv;
        serv.name='aa';
	update serv;
       
        Test.stopTest();
        // delete serv;
    }
     @isTest
    static void method2() {
        Test.startTest();
        list<ucinn_ascendv2__Service_Indicator__c> SI = new list<ucinn_ascendv2__Service_Indicator__c>();
             Account a = [select id,ucinn_ascendv2__Email__c,RecordTypeId from Account where Name = 'Test' limit 1];
            Contact c = [select id,FirstName,LastName,AccountId,nd_SIG__c,email from Contact limit 1];
            c.nd_SIG__c=true;
            update c;
            ucinn_ascendv2__Service_Indicator_Value__c Servalue = new ucinn_ascendv2__Service_Indicator_Value__c(name='Daily Lists' , RecordTypeId = Schema.SObjectType.ucinn_ascendv2__Service_Indicator_Value__c.getRecordTypeInfosByName().get('Mailing List Service Indicator').getRecordTypeId());
           insert Servalue;
             ucinn_ascendv2__Service_Indicator__c serv = new ucinn_ascendv2__Service_Indicator__c(ucinn_ascendv2__Contact__c = c.Id,Data_Source__c = 'AC',ucinn_ascendv2__Service_Indicator_Value__c = Servalue.Id );
            
            insert serv;
            serv.name='aa';
        update serv;
       
        Test.stopTest();
        // delete serv;
    }
    
}