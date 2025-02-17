@isTest
public class TRIG_Lottery_ApplicationTest {
    
    @testsetup
     static void setup() {
        ucinn_ascendv2__Trigger_Handler__c invHandler = new ucinn_ascendv2__Trigger_Handler__c();
        invHandler.Name = 'Lottery App Handler';
        invHandler.ucinn_ascendv2__Class__c = 'TRIG_Lottery_Application';
        invHandler.ucinn_ascendv2__Is_Active__c = true;
        invHandler.ucinn_ascendv2__Object__c = 'Lottery_Application__c';
        invHandler.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;BeforeDelete;AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
  //      invHandler.ucinn_ascendv2__Load_Order__c = 2;
        insert invHandler; 
         
                 
        Test.startTest();
        Account a1 = new Account(Name = 'ND Club Of Test',ucinn_ascendv2__Email__c='edf@gf.com',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporations and Organizations').getRecordTypeId());        
        insert a1;
        //Create a Contact    
        Contact c = new Contact(FirstName = 'Test', LastName = 'Contact',Constituent_Status__c = 'A', AccountId = a1.Id,email='abc@def.com');
        insert c;
        Test.stopTest();
    }
    
	@isTest(SeeAllData=false) 
    static void insertAR() {
       Contact h01 = [SELECT Id FROM Contact WHERE FirstName='Test' LIMIT 1];
        Test.startTest();
        Lottery_Application__c new_ar = new Lottery_Application__c();

        new_ar.Constituent__c	 = h01.Id;
        new_ar.Lottery_Application_Level__c ='LE';
        
        insert new_ar;
        Test.stopTest();

        
        Lottery_Application__c s01 = [SELECT Id, Constituent__c, Lottery_Application_Level__c FROM Lottery_Application__c where Lottery_Application_Level__c ='LE'  LIMIT 1];
        System.assertEquals('LE', s01.Lottery_Application_Level__c);
    }

}