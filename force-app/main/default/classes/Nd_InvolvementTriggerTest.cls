@isTest
public class Nd_InvolvementTriggerTest {
    
    @testsetup
     static void setup() {
        ucinn_ascendv2__Trigger_Handler__c invHandler = new ucinn_ascendv2__Trigger_Handler__c();
        invHandler.Name = 'Involvement Handler';
        invHandler.ucinn_ascendv2__Class__c = 'nd_InvolvementTriggerHandlerCls';
        invHandler.ucinn_ascendv2__Is_Active__c = true;
        invHandler.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Involvement__c';
        invHandler.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;BeforeDelete;AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
  //      invHandler.ucinn_ascendv2__Load_Order__c = 2;
        insert invHandler; 
                 
        Test.startTest();
        List<ucinn_ascendv2__Involvement__c> ucinInvolList = new List<ucinn_ascendv2__Involvement__c>();
        //Create two Accounts with Record Type 'Boards and Council'
        Account a1 = new Account(Name = 'ND Club Of Test',ucinn_ascendv2__Email__c='edf@gf.com',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporations and Organizations').getRecordTypeId());        
        insert a1;
        //Create a Contact    
        Contact c = new Contact(FirstName = 'Test', LastName = 'Contact',Constituent_Status__c = 'A', AccountId = a1.Id,email='abc@def.com');
        insert c;
        // involvement
        ucinn_ascendv2__Involvement__c inv1 = new ucinn_ascendv2__Involvement__c (Name ='Test 1',Data_Source__c ='AL',ucinn_ascendv2__Contact__c = c.Id);        
        insert inv1;
        ucinInvolList.add(inv1);
        Test.stopTest();
    }
    
    @isTest
    static void method1() {
        Test.startTest();
        List<ucinn_ascendv2__Involvement__c> ucinInvolList = new List<ucinn_ascendv2__Involvement__c>();
        
        Account a1 = [select id,ucinn_ascendv2__Email__c,RecordTypeId from Account where ucinn_ascendv2__Email__c='edf@gf.com' limit 1];
        Contact c = [select id,FirstName,LastName,Constituent_Status__c,AccountId,email from Contact limit 1];
        ucinn_ascendv2__Involvement_Value__c IValue= new ucinn_ascendv2__Involvement_Value__c(name='test',ucinn_ascendv2__Type__c='ADC',ucinn_ascendv2__Involvement_Description__c='test');
        insert IValue;
        ucinn_ascendv2__Involvement__c inv1 = new ucinn_ascendv2__Involvement__c (ucinn_ascendv2__Involvement_Code__c=IValue.id, Name ='Test 1',Data_Source__c ='AL',ucinn_ascendv2__Contact__c = c.Id,
                                                                                  RecordTypeId = Schema.SObjectType.ucinn_ascendv2__Involvement__c.getRecordTypeInfosByName().get('Advisory Council').getRecordTypeId());        
        insert inv1;
               
        inv1.ucinn_ascendv2__Status__c = 'A';
        update inv1;
        Test.stopTest();
    }
    static testMethod void method2() {
        Test.startTest();
        List<ucinn_ascendv2__Involvement__c> ucinInvolList = new List<ucinn_ascendv2__Involvement__c>();
        
        Account a1 = [select id,ucinn_ascendv2__Email__c,RecordTypeId from Account limit 1];
        Contact c = [select id,FirstName,LastName,Constituent_Status__c,AccountId,email from Contact limit 1];
        ucinn_ascendv2__Involvement_Value__c IValue= new ucinn_ascendv2__Involvement_Value__c(name='test',ucinn_ascendv2__Type__c='ADC',ucinn_ascendv2__Involvement_Description__c='test');
        Insert IValue;
        ucinn_ascendv2__Involvement__c inv1 = new ucinn_ascendv2__Involvement__c (ucinn_ascendv2__Involvement_Code__c=IValue.id,Name ='Test 1',Data_Source__c ='AL',ucinn_ascendv2__Contact__c = c.Id, 
                                                                                  RecordTypeId = Schema.SObjectType.ucinn_ascendv2__Involvement__c.getRecordTypeInfosByName().get('Advisory Council').getRecordTypeId()
                                                                                  );        
        insert inv1;
        
        inv1.ucinn_ascendv2__Status__c = 'H';
        update ucinInvolList;
        Test.stopTest();
    }
        static testMethod void method6() {
        Test.startTest();
        List<ucinn_ascendv2__Involvement__c> ucinInvolList = new List<ucinn_ascendv2__Involvement__c>();
        
        Account a1 = [select id,ucinn_ascendv2__Email__c,RecordTypeId from Account limit 1];
        Contact c = [select id,FirstName,LastName,Constituent_Status__c,AccountId,email from Contact limit 1];
        ucinn_ascendv2__Involvement_Value__c IValue= new ucinn_ascendv2__Involvement_Value__c(name='test',ucinn_ascendv2__Type__c='BOT',ucinn_ascendv2__Involvement_Description__c='test');
        Insert IValue;
        ucinn_ascendv2__Involvement__c inv1 = new ucinn_ascendv2__Involvement__c (ucinn_ascendv2__Status__c='A',ucinn_ascendv2__Involvement_Code__c=IValue.id,Name ='Test 1',Data_Source__c ='AL',ucinn_ascendv2__Contact__c = c.Id,RecordTypeId = Schema.SObjectType.ucinn_ascendv2__Involvement__c.getRecordTypeInfosByName().get('Advisory Council').getRecordTypeId());        
        insert inv1;
        
        Test.stopTest();
    }
    static testMethod void afterDelete_Test() {
        Test.startTest();
        List<ucinn_ascendv2__Involvement__c> ucinInvolList = new List<ucinn_ascendv2__Involvement__c>();
        
        Account a1 = [select id,ucinn_ascendv2__Email__c,RecordTypeId from Account limit 1];
        Contact c = [select id,FirstName,LastName,Constituent_Status__c,AccountId,email from Contact limit 1];
        ucinn_ascendv2__Involvement_Value__c IValue= new ucinn_ascendv2__Involvement_Value__c(name='test',ucinn_ascendv2__Type__c='ADC',ucinn_ascendv2__Involvement_Description__c='test');
        insert IValue;
        ucinn_ascendv2__Involvement__c inv1 = new ucinn_ascendv2__Involvement__c (ucinn_ascendv2__Involvement_Code__c=IValue.id,Name ='Test 1',Data_Source__c ='AL',ucinn_ascendv2__Contact__c = c.Id,
                                                                                  RecordTypeId = Schema.SObjectType.ucinn_ascendv2__Involvement__c.getRecordTypeInfosByName().get('Advisory Council').getRecordTypeId()
                                                                                 );        
        insert inv1;
        
        inv1.ucinn_ascendv2__Status__c = 'F';
        update ucinInvolList;
        Test.stopTest();
    }
    @isTest
    static void method4() {
        Test.startTest();
        List<ucinn_ascendv2__Involvement__c> ucinInvolList = new List<ucinn_ascendv2__Involvement__c>();
        
        Account a1 = [select id,ucinn_ascendv2__Email__c,RecordTypeId from Account where ucinn_ascendv2__Email__c='edf@gf.com' limit 1];
        Contact c = [select id,FirstName,LastName,Constituent_Status__c,AccountId,email from Contact limit 1];
        c.ND_VIP__c = true;
        c.ND_VIP_Reason__c = 'I';
        update c;
        ucinn_ascendv2__Involvement_Value__c IValue= new ucinn_ascendv2__Involvement_Value__c(name='test',ucinn_ascendv2__Type__c='ADC',ucinn_ascendv2__Involvement_Description__c='test');
        insert IValue;
        ucinn_ascendv2__Involvement__c inv1 = new ucinn_ascendv2__Involvement__c (ucinn_ascendv2__Involvement_Code__c=IValue.id,Name ='Test 1',Data_Source__c ='AL',
                                                                                  ucinn_ascendv2__Contact__c = c.Id, RecordTypeId = Schema.SObjectType.ucinn_ascendv2__Involvement__c.getRecordTypeInfosByName().get('Advisory Council').getRecordTypeId() 
                                                                                 );        
        insert inv1;
               
        inv1.ucinn_ascendv2__Status__c = 'F';
        update inv1;
        Test.stopTest();
    }
    @isTest
    static void method5() {
        Test.startTest();
        List<ucinn_ascendv2__Involvement__c> ucinInvolList = new List<ucinn_ascendv2__Involvement__c>();
        
        Account a1 = [select id,ucinn_ascendv2__Email__c,RecordTypeId from Account where ucinn_ascendv2__Email__c='edf@gf.com' limit 1];
        Contact c = [select id,FirstName,LastName,Constituent_Status__c,AccountId,email from Contact limit 1];
        c.ND_VIP__c = true;
        c.ND_VIP_Reason__c = 'D;I';
        update c;
        ucinn_ascendv2__Involvement_Value__c IValue= new ucinn_ascendv2__Involvement_Value__c(name='test',ucinn_ascendv2__Type__c='ADC',ucinn_ascendv2__Involvement_Description__c='test');
        insert IValue;        
        ucinn_ascendv2__Involvement__c inv1 = new ucinn_ascendv2__Involvement__c (ucinn_ascendv2__Involvement_Code__c=IValue.id,Name ='Test 1',Data_Source__c ='AL',ucinn_ascendv2__Contact__c = c.Id, RecordTypeId = Schema.SObjectType.ucinn_ascendv2__Involvement__c.getRecordTypeInfosByName().get('Advisory Council').getRecordTypeId(), ucinn_ascendv2__Involvement_Type__c = 'Board');        
        insert inv1;
               
        inv1.ucinn_ascendv2__Status__c = 'F';
        update inv1;
        Test.stopTest();
    }
 @isTest
    static void beforeDelete() {
        
        Account a1 = [select id,ucinn_ascendv2__Email__c,RecordTypeId from Account where ucinn_ascendv2__Email__c='edf@gf.com' limit 1];
        Contact c1 = [select id,FirstName,LastName,Constituent_Status__c,AccountId,email from Contact limit 1];
        Id involvementRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='ucinn_ascendv2__Involvement__c' AND Name='Advisory Council'].Id; 
       
        Id involvementValueRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='ucinn_ascendv2__Involvement_Value__c' AND Name='Advisory Council'].Id; 
           
        ucinn_ascendv2__Involvement_Value__c involvementValue = new ucinn_ascendv2__Involvement_Value__c(Name='TEST450',ucinn_ascendv2__Involvement_Description__c='TEST',
        RecordTypeId=involvementValueRecordTypeId);    	
    	insert involvementValue;
        
        ucinn_ascendv2__Involvement__c involvement = new ucinn_ascendv2__Involvement__c(Name='InvolTest',
        ucinn_ascendv2__Contact__c=c1.Id,ucinn_ascendv2__Status__c='A',ucinn_ascendv2__Involvement_Code__c=involvementValue.Id,Data_Source__c='ACN',RecordTypeId=involvementRecordTypeId);
         insert involvement;
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Campaign' LIMIT 1];
        User u = [SELECT Id FROM User WHERE ProfileId = :p.Id LIMIT 1];
       System.runAs(u) {
        Test.startTest();
        //deleting the involvement record
        try {
            delete involvement;
            System.assert(false, 'The deletion should have been prevented by addError().');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('You do not have permission to delete this Involvement.'), 
                          'Expected error, but got: ' + e.getMessage());
        }       
        Test.stopTest();              
        }
    }
    @isTest
    static void beforeDelete1() {
        
        Account a1 = [select id,ucinn_ascendv2__Email__c,RecordTypeId from Account where ucinn_ascendv2__Email__c='edf@gf.com' limit 1];
        Contact c1 = [select id,FirstName,LastName,Constituent_Status__c,AccountId,email from Contact limit 1];
        Id involvementRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='ucinn_ascendv2__Involvement__c' AND Name='Advisory Council'].Id; 
        
        Id involvementValueRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='ucinn_ascendv2__Involvement_Value__c' AND Name='Advisory Council'].Id; 
        
        ucinn_ascendv2__Involvement_Value__c involvementValue = new ucinn_ascendv2__Involvement_Value__c(Name='TEST450',ucinn_ascendv2__Involvement_Description__c='TEST',
                                                                                                         RecordTypeId=involvementValueRecordTypeId);    	
        insert involvementValue;
        
        ucinn_ascendv2__Involvement__c involvement = new ucinn_ascendv2__Involvement__c(Name='InvolTest',
                                                                                        ucinn_ascendv2__Contact__c=c1.Id,ucinn_ascendv2__Status__c='A',ucinn_ascendv2__Involvement_Code__c=involvementValue.Id,Data_Source__c='ACN',RecordTypeId=involvementRecordTypeId);
        insert involvement;
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Advisory Council' LIMIT 1];
        User u = [SELECT Id FROM User WHERE ProfileId = :p.Id LIMIT 1];
        System.runAs(u) {
            Test.startTest();
            //deleting the involvement record
            delete involvement;
            Test.stopTest();              
        } 
    }
}