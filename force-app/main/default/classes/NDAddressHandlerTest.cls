@isTest
public class NDAddressHandlerTest {

    @isTest
    Static void method1(){
        ucinn_ascendv2__Trigger_Handler__c customHandler02 = new ucinn_ascendv2__Trigger_Handler__c();
        customHandler02.Name = 'NDAddressHandler';
        customHandler02.ucinn_ascendv2__Class__c = 'NDAddressHandler';
        customHandler02.ucinn_ascendv2__Is_Active__c = true;
        customHandler02.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Address__c';
        customHandler02.ucinn_ascendv2__Trigger_Action__c = 'AfterUpdate;';
        customHandler02.ucinn_ascendv2__Load_Order__c = 2;
        insert customHandler02;
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
		ND_Geo_Group_Region__c gr = new ND_Geo_Group_Region__c(Postal_Code__c='11',MSA_Code__c=123,MSA_Name__c='test',ND_Club_Region__c='01010',
                                                              Prospect_Region__c = '1');
        insert gr;
        
        ucinn_ascendv2__Address__c add01 = new ucinn_ascendv2__Address__c();
        add01.Name = 'TEST Address 01';
        add01.ucinn_ascendv2__Address_Line_1__c = 'Test 01 ave';
        add01.ucinn_ascendv2__City__c = 'City';
        add01.ucinn_ascendv2__State__c = 'CA';
        add01.ucinn_ascendv2__Country__c = 'United States';
        
        insert add01;
        
        Id conAddRelRecTypeId = Schema.SObjectType.ucinn_ascendv2__Address_Relation__c.getRecordTypeInfosByName().get('Constituent Address Relation').getRecordTypeId();

        ucinn_ascendv2__Address_Relation__c addrel = new ucinn_ascendv2__Address_Relation__c();
        addrel.ucinn_ascendv2__Address__c = add01.Id;
        addrel.ucinn_ascendv2__Account__c = accts[0].Id;
        addrel.ucinn_ascendv2__Contact__c = h01.Id;
        addrel.ucinn_ascendv2__Status__c = 'Current';
        addrel.ucinn_ascendv2__Type__c = 'B';
        addrel.ucinn_ascendv2__Is_Preferred__c = true;
        addrel.RecordTypeId = conAddRelRecTypeId;
        insert addrel;
        
        add01.ucinn_ascendv2__Postal_Code__c ='11';
        update add01;
      
    }
    @isTest
    Static void method2(){
        ucinn_ascendv2__Trigger_Handler__c customHandler02 = new ucinn_ascendv2__Trigger_Handler__c();
        customHandler02.Name = 'NDAddressHandler';
        customHandler02.ucinn_ascendv2__Class__c = 'NDAddressHandler';
        customHandler02.ucinn_ascendv2__Is_Active__c = true;
        customHandler02.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Address__c';
        customHandler02.ucinn_ascendv2__Trigger_Action__c = 'AfterUpdate;';
        customHandler02.ucinn_ascendv2__Load_Order__c = 2;
        insert customHandler02;
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
		ND_Geo_Group_Region__c gr = new ND_Geo_Group_Region__c(Postal_Code__c='11',MSA_Code__c=123,MSA_Name__c='test',ND_Club_Region__c='01010',
                                                              Prospect_Region__c = '1');
        insert gr;
        
        ucinn_ascendv2__Address__c add01 = new ucinn_ascendv2__Address__c();
        add01.Name = 'TEST Address 01';
        add01.ucinn_ascendv2__Address_Line_1__c = 'Test 01 ave';
        add01.ucinn_ascendv2__City__c = 'City';
        add01.ucinn_ascendv2__State__c = 'CA';
        add01.ucinn_ascendv2__Country__c = 'United States';
        
        insert add01;
        
        Id conAddRelRecTypeId = Schema.SObjectType.ucinn_ascendv2__Address_Relation__c.getRecordTypeInfosByName().get('Constituent Address Relation').getRecordTypeId();

        ucinn_ascendv2__Address_Relation__c addrel = new ucinn_ascendv2__Address_Relation__c();
        addrel.ucinn_ascendv2__Address__c = add01.Id;
        addrel.ucinn_ascendv2__Account__c = accts[0].Id;
        addrel.ucinn_ascendv2__Contact__c = h01.Id;
        addrel.ucinn_ascendv2__Status__c = 'Current';
        addrel.ucinn_ascendv2__Type__c = 'B';
        addrel.ucinn_ascendv2__Is_Preferred__c = true;
        addrel.RecordTypeId = conAddRelRecTypeId;
        insert addrel;
        
        add01.ucinn_ascendv2__Postal_Code__c ='12';
        update add01;
      
    }    
        @isTest
    Static void method3(){
        ucinn_ascendv2__Trigger_Handler__c customHandler02 = new ucinn_ascendv2__Trigger_Handler__c();
        customHandler02.Name = 'NDAddressHandler';
        customHandler02.ucinn_ascendv2__Class__c = 'NDAddressHandler';
        customHandler02.ucinn_ascendv2__Is_Active__c = true;
        customHandler02.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Address__c';
        customHandler02.ucinn_ascendv2__Trigger_Action__c = 'AfterUpdate;';
        customHandler02.ucinn_ascendv2__Load_Order__c = 2;
        insert customHandler02;
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
		ND_Geo_Group_Region__c gr = new ND_Geo_Group_Region__c(Postal_Code__c='11',MSA_Code__c=123,MSA_Name__c='test',ND_Club_Region__c='01010',
                                                              Prospect_Region__c = '1');
        insert gr;
        
        ucinn_ascendv2__Address__c add01 = new ucinn_ascendv2__Address__c();
        add01.Name = 'TEST Address 01';
        add01.ucinn_ascendv2__Address_Line_1__c = 'Test 01 ave';
        add01.ucinn_ascendv2__City__c = 'City';
        add01.ucinn_ascendv2__State__c = 'CA';
        add01.ucinn_ascendv2__Country__c = 'United State';
        
        insert add01;
        
        Id conAddRelRecTypeId = Schema.SObjectType.ucinn_ascendv2__Address_Relation__c.getRecordTypeInfosByName().get('Constituent Address Relation').getRecordTypeId();

        ucinn_ascendv2__Address_Relation__c addrel = new ucinn_ascendv2__Address_Relation__c();
        addrel.ucinn_ascendv2__Address__c = add01.Id;
        addrel.ucinn_ascendv2__Account__c = accts[0].Id;
        addrel.ucinn_ascendv2__Contact__c = h01.Id;
        addrel.ucinn_ascendv2__Status__c = 'Current';
        addrel.ucinn_ascendv2__Type__c = 'B';
        addrel.ucinn_ascendv2__Is_Preferred__c = true;
        addrel.RecordTypeId = conAddRelRecTypeId;
        insert addrel;
        
        add01.ucinn_ascendv2__Postal_Code__c ='12';
        update add01;
      
    } 
}