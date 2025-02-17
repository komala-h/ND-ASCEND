@isTest
public class NDAddressBatchTest{

    @testsetup
     Static void testData(){
        ucinn_ascendv2__Trigger_Handler__c customHandler02 = new ucinn_ascendv2__Trigger_Handler__c();
        customHandler02.Name = 'Custom Address Relation Handler';
        customHandler02.ucinn_ascendv2__Class__c = 'asc_TRIG_AddressRelationHandler';
        customHandler02.ucinn_ascendv2__Is_Active__c = true;
        customHandler02.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Address_Relation__c';
        customHandler02.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;BeforeDelete;AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
        customHandler02.ucinn_ascendv2__Load_Order__c = 2;
        insert customHandler02;
          //Insert Account and Contact
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
    // Insert Geo Group Region for US,Canada,Others
     ND_Geo_Group_Region__c gr1 = new ND_Geo_Group_Region__c(Postal_Code__c='11',MSA_Code__c=123,MSA_Name__c='test',ND_Club_Region__c='01010',
                                                              Prospect_Region__c = '1',nd_Country_Full_Name__c='United States');
        insert gr1;
        ND_Geo_Group_Region__c gr2 = new ND_Geo_Group_Region__c(Postal_Code__c='12',MSA_Code__c=123,MSA_Name__c='test1',ND_Club_Region__c='92051',
                                                              Prospect_Region__c = '2',nd_Country_Full_Name__c='Canada');
        insert gr2;      
         ND_Geo_Group_Region__c gr3 = new ND_Geo_Group_Region__c(Postal_Code__c='13',MSA_Code__c=123,MSA_Name__c='test2',ND_Club_Region__c='96000',
                                                              Prospect_Region__c = '3',nd_Country_Full_Name__c='India');
        insert gr3;         
  		accts[0].ucinn_ascendv2__PRM__c = [select id from user where id=:userinfo.getuserid()].Id;
        accts[0].ucinn_ascendv2__Primary_Contact__c=h01.id;
        update accts;
     }
        @isTest
    Static void method1(){
        
        List<Account>accList=[Select id,name,ucinn_ascendv2__PRM__c from Account];
		List<Contact>conList=[Select id,FirstName from Contact];
        //Insert Address and AddressRelation
        ucinn_ascendv2__Address__c add01 = new ucinn_ascendv2__Address__c();
        add01.Name = 'TEST Address 01';
        add01.ucinn_ascendv2__Address_Line_1__c = 'Test 01 ave';
        add01.ucinn_ascendv2__City__c = 'City';
        add01.ucinn_ascendv2__State__c = 'CA';
        add01.ucinn_ascendv2__Postal_Code__c= '11';
        add01.ucinn_ascendv2__Country__c = 'United States';
         add01.ND_ToBeProcessedByBatchJob__c = system.today().adddays(-1);
        insert add01;
   
       Id conAddRelRecTypeId = Schema.SObjectType.ucinn_ascendv2__Address_Relation__c.getRecordTypeInfosByName().get('Constituent Address Relation').getRecordTypeId();
        ucinn_ascendv2__Address_Relation__c addrel = new ucinn_ascendv2__Address_Relation__c();
        addrel.ucinn_ascendv2__Address__c = add01.Id;
        addrel.ucinn_ascendv2__Account__c = accList[0].Id;
        addrel.ucinn_ascendv2__Contact__c = conList[0].Id;
        addrel.ucinn_ascendv2__Status__c = 'Current';
        addrel.ucinn_ascendv2__Type__c = 'H';
        addrel.RecordTypeId = conAddRelRecTypeId;
        addrel.ucinn_ascendv2__End_Date__c = null;
        addrel.ucinn_ascendv2__Start_Date__c = null;
        addrel.ucinn_ascendv2__Is_Preferred__c = true;
        insert addrel;         
        
      
        test.startTest();
        database.executebatch(new NDAddressBatch());
        test.stopTest();
    }    
    @isTest
    Static void method2(){
        List<Account>accList=[Select id,name,ucinn_ascendv2__PRM__c from Account];
		List<Contact>conList=[Select id,FirstName from Contact];
        ucinn_ascendv2__Address__c add01 = new ucinn_ascendv2__Address__c();
        add01.Name = 'TEST Address 01';
        add01.ucinn_ascendv2__Address_Line_1__c = 'Test 01 ave';
        add01.ucinn_ascendv2__City__c = 'City';
        add01.ucinn_ascendv2__State__c = 'CA';
        add01.ucinn_ascendv2__Postal_Code__c= '11';
        add01.ucinn_ascendv2__Country__c = 'United States';
        add01.ND_ToBeProcessedByBatchJob__c = system.today().adddays(-1);
        insert add01;
        Id conAddRelRecTypeId = Schema.SObjectType.ucinn_ascendv2__Address_Relation__c.getRecordTypeInfosByName().get('Constituent Address Relation').getRecordTypeId();

        ucinn_ascendv2__Address_Relation__c addrel = new ucinn_ascendv2__Address_Relation__c();
        addrel.ucinn_ascendv2__Address__c = add01.Id;
        addrel.ucinn_ascendv2__Account__c = accList[0].Id;
        addrel.ucinn_ascendv2__Contact__c = conList[0].Id;
        addrel.ucinn_ascendv2__Status__c = 'Current';
        addrel.ucinn_ascendv2__Type__c = 'B';
        addrel.RecordTypeId = conAddRelRecTypeId;
        addrel.ucinn_ascendv2__End_Date__c = null;
        addrel.ucinn_ascendv2__Start_Date__c = null;
        addrel.ucinn_ascendv2__Is_Preferred__c = true;
        insert addrel;
      
        test.startTest();
        database.executebatch(new NDAddressBatch());
        test.stopTest();
    }    
     @isTest
    Static void method3(){
        List<Account>accList=[Select id,name,ucinn_ascendv2__PRM__c from Account];
		List<Contact>conList=[Select id,FirstName from Contact];
        ucinn_ascendv2__Address__c add01 = new ucinn_ascendv2__Address__c();
        add01.Name = 'TEST Address 01';
        add01.ucinn_ascendv2__Address_Line_1__c = 'Test 01 ave';
        add01.ucinn_ascendv2__City__c = 'City';
        add01.ucinn_ascendv2__State__c = 'CA';
        add01.ucinn_ascendv2__Postal_Code__c= '12';
        add01.ucinn_ascendv2__Country__c = 'Canada';
        add01.ND_ToBeProcessedByBatchJob__c = system.today().adddays(-1);
        insert add01;
        Id conAddRelRecTypeId = Schema.SObjectType.ucinn_ascendv2__Address_Relation__c.getRecordTypeInfosByName().get('Constituent Address Relation').getRecordTypeId();

        ucinn_ascendv2__Address_Relation__c addrel = new ucinn_ascendv2__Address_Relation__c();
        addrel.ucinn_ascendv2__Address__c = add01.Id;
        addrel.ucinn_ascendv2__Account__c = accList[0].Id;
        addrel.ucinn_ascendv2__Contact__c = conList[0].Id;
        addrel.ucinn_ascendv2__Status__c = 'Current';
        addrel.ucinn_ascendv2__Type__c = 'H';
        addrel.RecordTypeId = conAddRelRecTypeId;
        addrel.ucinn_ascendv2__End_Date__c = null;
        addrel.ucinn_ascendv2__Start_Date__c = null;
        addrel.ucinn_ascendv2__Is_Preferred__c = true;
        insert addrel;
      
        test.startTest();
        database.executebatch(new NDAddressBatch());
        test.stopTest();
    }  
     @isTest
    Static void method4(){
        List<Account>accList=[Select id,name,ucinn_ascendv2__PRM__c from Account];
		List<Contact>conList=[Select id,FirstName from Contact];
        ucinn_ascendv2__Address__c add01 = new ucinn_ascendv2__Address__c();
        add01.Name = 'TEST Address 01';
        add01.ucinn_ascendv2__Address_Line_1__c = 'Test 01 ave';
        add01.ucinn_ascendv2__City__c = 'City';
        add01.ucinn_ascendv2__State__c = 'CA';
        add01.ucinn_ascendv2__Postal_Code__c= '12';
        add01.ucinn_ascendv2__Country__c = 'Canada';
        add01.ND_ToBeProcessedByBatchJob__c = system.today().adddays(-1);
        insert add01;
        Id conAddRelRecTypeId = Schema.SObjectType.ucinn_ascendv2__Address_Relation__c.getRecordTypeInfosByName().get('Constituent Address Relation').getRecordTypeId();

        ucinn_ascendv2__Address_Relation__c addrel = new ucinn_ascendv2__Address_Relation__c();
        addrel.ucinn_ascendv2__Address__c = add01.Id;
        addrel.ucinn_ascendv2__Account__c = accList[0].Id;
        addrel.ucinn_ascendv2__Contact__c = conList[0].Id;
        addrel.ucinn_ascendv2__Status__c = 'Current';
        addrel.ucinn_ascendv2__Type__c = 'B';
        addrel.RecordTypeId = conAddRelRecTypeId;
        addrel.ucinn_ascendv2__End_Date__c = null;
        addrel.ucinn_ascendv2__Start_Date__c = null;
        addrel.ucinn_ascendv2__Is_Preferred__c = true;
        insert addrel;
      
        test.startTest();
        database.executebatch(new NDAddressBatch());
        test.stopTest();
    }  
       @isTest
    Static void method5(){
        List<Account>accList=[Select id,name,ucinn_ascendv2__PRM__c from Account];
		List<Contact>conList=[Select id,FirstName from Contact];
        accList[0].ucinn_ascendv2__PRM__c=null;
        update acclist;
        ucinn_ascendv2__Address__c add01 = new ucinn_ascendv2__Address__c();
        add01.Name = 'TEST Address 01';
        add01.ucinn_ascendv2__Address_Line_1__c = 'Test 01 ave';
        add01.ucinn_ascendv2__City__c = 'City';
        add01.ucinn_ascendv2__State__c = 'CA';
        add01.ucinn_ascendv2__Postal_Code__c= '11';
        add01.ucinn_ascendv2__Country__c = 'United States';
        add01.ND_ToBeProcessedByBatchJob__c = system.today().adddays(-1);
        insert add01;
        Id conAddRelRecTypeId = Schema.SObjectType.ucinn_ascendv2__Address_Relation__c.getRecordTypeInfosByName().get('Constituent Address Relation').getRecordTypeId();

        ucinn_ascendv2__Address_Relation__c addrel = new ucinn_ascendv2__Address_Relation__c();
        addrel.ucinn_ascendv2__Address__c = add01.Id;
        addrel.ucinn_ascendv2__Account__c = accList[0].Id;
        addrel.ucinn_ascendv2__Contact__c = conList[0].Id;
        addrel.ucinn_ascendv2__Status__c = 'Current';
        addrel.ucinn_ascendv2__Type__c = 'H';
        addrel.RecordTypeId = conAddRelRecTypeId;
        addrel.ucinn_ascendv2__End_Date__c = null;
        addrel.ucinn_ascendv2__Start_Date__c = null;
        addrel.ucinn_ascendv2__Is_Preferred__c = true;
        insert addrel;
      
        test.startTest();
        database.executebatch(new NDAddressBatch());
        test.stopTest();
    }
        @isTest
    Static void method6(){
        List<Account>accList=[Select id,name,ucinn_ascendv2__PRM__c from Account];
		List<Contact>conList=[Select id,FirstName from Contact];
        accList[0].ucinn_ascendv2__PRM__c=null;
        update acclist;
        ucinn_ascendv2__Address__c add01 = new ucinn_ascendv2__Address__c();
        add01.Name = 'TEST Address 01';
        add01.ucinn_ascendv2__Address_Line_1__c = 'Test 01 ave';
        add01.ucinn_ascendv2__City__c = 'City';
        add01.ucinn_ascendv2__State__c = 'CA';
        add01.ucinn_ascendv2__Postal_Code__c= '12';
        add01.ucinn_ascendv2__Country__c = 'Canada';
        add01.ND_ToBeProcessedByBatchJob__c = system.today().adddays(-1);
        insert add01;
        Id conAddRelRecTypeId = Schema.SObjectType.ucinn_ascendv2__Address_Relation__c.getRecordTypeInfosByName().get('Constituent Address Relation').getRecordTypeId();

        ucinn_ascendv2__Address_Relation__c addrel = new ucinn_ascendv2__Address_Relation__c();
        addrel.ucinn_ascendv2__Address__c = add01.Id;
        addrel.ucinn_ascendv2__Account__c = accList[0].Id;
        addrel.ucinn_ascendv2__Contact__c = conList[0].Id;
        addrel.ucinn_ascendv2__Status__c = 'Current';
        addrel.ucinn_ascendv2__Type__c = 'H';
        addrel.RecordTypeId = conAddRelRecTypeId;
        addrel.ucinn_ascendv2__End_Date__c = null;
        addrel.ucinn_ascendv2__Start_Date__c = null;
        addrel.ucinn_ascendv2__Is_Preferred__c = true;
        insert addrel;
      
        test.startTest();
        database.executebatch(new NDAddressBatch());
        test.stopTest();
    }
}