@isTest
public class BIO_UtilsTest {
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
        
        
        List<Account> accts = new List<Account>{
        new Account(Name = 'TEST, h01 h123 Household',ucinn_ascendv2__Donor_ID__c = 'h123'),
        new Account(Name = 'University of Notre Dame',ucinn_ascendv2__Donor_ID__c = '307129')
        };
        insert accts;
        
        Contact h01 = new Contact();
        h01.FirstName = 'h01';
        h01.LastName = 'TEST';
        h01.AccountId = accts[0].Id;
        h01.ucinn_ascendv2__Gender__c = 'Male';
        h01.ucinn_ascendv2__Contact_Type__c = 'AL';
        h01.ucinn_ascendv2__Personal_Email__c = 'sample@uci.com';
        h01.Constituent_Status__c = 'A';
        insert h01;


        ucinn_ascendv2__Phone__c phone = new ucinn_ascendv2__Phone__c();
        phone.ucinn_ascendv2__Type__c = 'B';
        phone.ucinn_ascendv2__Status__c = 'Former';
        phone.ucinn_ascendv2__Phone_Number__c = '1234567890';
        phone.ucinn_ascendv2__Contact__c = h01.Id;
        insert phone;

        ucinn_ascendv2__Email__c email = new ucinn_ascendv2__Email__c();
        email.ucinn_ascendv2__Type__c = 'U';
        email.ucinn_ascendv2__Status__c = 'Current';
        email.ucinn_ascendv2__Data_Source__c = 'AA';
        email.ucinn_ascendv2__Contact__c = h01.Id;
        insert email;

        ucinn_ascendv2__Address__c add01 = new ucinn_ascendv2__Address__c();
        add01.Name = 'TEST Address 01';
        add01.ucinn_ascendv2__Address_Line_1__c = 'Test 01 ave';
        add01.ucinn_ascendv2__City__c = 'City';
        add01.ucinn_ascendv2__State__c = 'CA';
        add01.ucinn_ascendv2__Country__c = 'United States';
        insert add01;
        
        ucinn_ascendv2__Address__c add02 = new ucinn_ascendv2__Address__c();
        add02.Name = 'TEST Address 02';
        add02.ucinn_ascendv2__Address_Line_1__c = 'Test 01 ave';
        add02.ucinn_ascendv2__City__c = 'City';
        add02.ucinn_ascendv2__State__c = 'CA';
        add02.ucinn_ascendv2__Country__c = 'United States';
        insert add02;
      

    }    
    @isTest
    static void method1(){
    Id conAddRelRecTypeId = Schema.SObjectType.ucinn_ascendv2__Address_Relation__c.getRecordTypeInfosByName().get('Constituent Address Relation').getRecordTypeId();

        ucinn_ascendv2__Address_Relation__c addrel = new ucinn_ascendv2__Address_Relation__c();
        addrel.ucinn_ascendv2__Address__c = [Select id from ucinn_ascendv2__Address__c where name ='TEST Address 01' limit 1 ].Id;
        addrel.ucinn_ascendv2__Account__c = [Select id from account limit 1].Id;
        addrel.ucinn_ascendv2__Contact__c = [Select id from contact limit 1].Id;
        addrel.ucinn_ascendv2__Status__c = 'Current';
        addrel.ucinn_ascendv2__Type__c = 'B';
        addrel.ucinn_ascendv2__Is_Preferred__c = true;
        addrel.RecordTypeId = conAddRelRecTypeId;
        insert addrel;
        ucinn_ascendv2__Address_Relation__c addrel2 = new ucinn_ascendv2__Address_Relation__c();
        addrel2.ucinn_ascendv2__Address__c = [Select id from ucinn_ascendv2__Address__c where name ='TEST Address 02' limit 1 ].Id;
        addrel2.ucinn_ascendv2__Account__c = [Select id from account limit 1].Id;
        addrel2.ucinn_ascendv2__Contact__c = [Select id from contact limit 1].Id;
        addrel2.ucinn_ascendv2__Status__c = 'Current';
        addrel2.ucinn_ascendv2__Type__c = 'H';
        addrel2.RecordTypeId = conAddRelRecTypeId;
        insert addrel2;  
        addrel.ucinn_ascendv2__Is_Preferred__c = false;
        update addrel;

    }
    @isTest
    static void method2(){
    Id conAddRelRecTypeId = Schema.SObjectType.ucinn_ascendv2__Address_Relation__c.getRecordTypeInfosByName().get('Constituent Address Relation').getRecordTypeId();

        ucinn_ascendv2__Address_Relation__c addrel = new ucinn_ascendv2__Address_Relation__c();
        addrel.ucinn_ascendv2__Address__c = [Select id from ucinn_ascendv2__Address__c where name ='TEST Address 01' limit 1 ].Id;
        addrel.ucinn_ascendv2__Account__c = [Select id from account limit 1].Id;
        addrel.ucinn_ascendv2__Status__c = 'Current';
        addrel.ucinn_ascendv2__Type__c = 'B';
        addrel.ucinn_ascendv2__Contact__c = [Select id from contact limit 1].Id;
        addrel.RecordTypeId = conAddRelRecTypeId;
        insert addrel;
        ucinn_ascendv2__Address_Relation__c addrel2 = new ucinn_ascendv2__Address_Relation__c();
        addrel2.ucinn_ascendv2__Address__c = [Select id from ucinn_ascendv2__Address__c where name ='TEST Address 02' limit 1 ].Id;
        addrel2.ucinn_ascendv2__Account__c = [Select id from account limit 1].Id;
        addrel2.ucinn_ascendv2__Status__c = 'Current';
        addrel2.ucinn_ascendv2__Type__c = 'H';
        addrel2.RecordTypeId = conAddRelRecTypeId;
        addrel2.ucinn_ascendv2__Contact__c = [Select id from contact limit 1].Id;
        insert addrel2;

        Delete addrel;
    }
	@isTest
    static void method4(){
    Id conAddRelRecTypeId = Schema.SObjectType.ucinn_ascendv2__Address_Relation__c.getRecordTypeInfosByName().get('Constituent Address Relation').getRecordTypeId();

        ucinn_ascendv2__Address_Relation__c addrel = new ucinn_ascendv2__Address_Relation__c();
        addrel.ucinn_ascendv2__Address__c = [Select id from ucinn_ascendv2__Address__c where name ='TEST Address 01' limit 1 ].Id;
        addrel.ucinn_ascendv2__Account__c = [Select id from account limit 1].Id;
        addrel.ucinn_ascendv2__Status__c = 'Current';
        addrel.ucinn_ascendv2__Type__c = 'B';
        addrel.ucinn_ascendv2__Contact__c = [Select id from contact limit 1].Id;
        addrel.RecordTypeId = conAddRelRecTypeId;
        insert addrel;
        ucinn_ascendv2__Address_Relation__c addrel3 = new ucinn_ascendv2__Address_Relation__c();
        addrel3.ucinn_ascendv2__Address__c = [Select id from ucinn_ascendv2__Address__c where name ='TEST Address 01' limit 1 ].Id;
        addrel3.ucinn_ascendv2__Account__c = [Select id from account limit 1].Id;
        addrel3.ucinn_ascendv2__Status__c = 'Current';
        addrel3.ucinn_ascendv2__Type__c = 'B';
        addrel3.ucinn_ascendv2__Contact__c = [Select id from contact limit 1].Id;
        addrel3.RecordTypeId = conAddRelRecTypeId;
        insert addrel3;
        ucinn_ascendv2__Address_Relation__c addrel2 = new ucinn_ascendv2__Address_Relation__c();
        addrel2.ucinn_ascendv2__Address__c = [Select id from ucinn_ascendv2__Address__c where name ='TEST Address 02' limit 1 ].Id;
        addrel2.ucinn_ascendv2__Account__c = [Select id from account limit 1].Id;
        addrel2.ucinn_ascendv2__Status__c = 'Current';
        addrel2.ucinn_ascendv2__Type__c = 'H';
        addrel2.RecordTypeId = conAddRelRecTypeId;
        addrel2.ucinn_ascendv2__Is_Preferred__c=true;
        addrel2.ucinn_ascendv2__Contact__c = [Select id from contact limit 1].Id;
        insert addrel2;

        Delete addrel2;

    }
    @isTest
    static void method3(){
    Id conAddRelRecTypeId = Schema.SObjectType.ucinn_ascendv2__Address_Relation__c.getRecordTypeInfosByName().get('Constituent Address Relation').getRecordTypeId();

        ucinn_ascendv2__Address_Relation__c addrel = new ucinn_ascendv2__Address_Relation__c();
        addrel.ucinn_ascendv2__Address__c = [Select id from ucinn_ascendv2__Address__c where name ='TEST Address 01' limit 1 ].Id;
        addrel.ucinn_ascendv2__Account__c = [Select id from account limit 1].Id;
        addrel.ucinn_ascendv2__Status__c = 'Current';
        addrel.ucinn_ascendv2__Type__c = 'H';
        addrel.ucinn_ascendv2__Is_Preferred__c = true;
        addrel.RecordTypeId = conAddRelRecTypeId;
        insert addrel;
        ucinn_ascendv2__Address_Relation__c addrel2 = new ucinn_ascendv2__Address_Relation__c();
        addrel2.ucinn_ascendv2__Address__c = [Select id from ucinn_ascendv2__Address__c where name ='TEST Address 02' limit 1 ].Id;
        addrel2.ucinn_ascendv2__Account__c = [Select id from account limit 1].Id;
        addrel2.ucinn_ascendv2__Status__c = 'Current';
        addrel2.ucinn_ascendv2__Type__c = 'H';
        addrel2.RecordTypeId = conAddRelRecTypeId;
        insert addrel2;

        Delete addrel2;
    }
}