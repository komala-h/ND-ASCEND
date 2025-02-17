@isTest
public class AdvisoryCouncilSuffixBatchTest {
    
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
        ucinn_ascendv2__Involvement_Value__c IValue= new ucinn_ascendv2__Involvement_Value__c(nd_Affiliation_Symbol__c='CN',name='test',ucinn_ascendv2__Type__c='ADC',ucinn_ascendv2__Involvement_Description__c='test');
        insert IValue;
        ucinn_ascendv2__Involvement__c inv1 = new ucinn_ascendv2__Involvement__c (ucinn_ascendv2__Involvement_Code__c=IValue.id, Name ='Test 1',Data_Source__c ='AL',ucinn_ascendv2__Contact__c = c.Id,
                                                                                  RecordTypeId = Schema.SObjectType.ucinn_ascendv2__Involvement__c.getRecordTypeInfosByName().get('Advisory Council').getRecordTypeId(),
                                                                                 ucinn_ascendv2__Start_Date__c = System.Today(),ucinn_ascendv2__End_Date__c = System.Today()+3);        
        inv1.ucinn_ascendv2__Status__c = 'A';
        //inv1.nd_Affiliation_Symbol__c = 'CN';
        insert inv1;
        
        database.executebatch(new AdvisoryCouncilSuffixBatch());
                
        Test.stopTest();
    }

}