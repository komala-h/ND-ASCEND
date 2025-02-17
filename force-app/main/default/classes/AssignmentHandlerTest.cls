@isTest
public class AssignmentHandlerTest 
{
    @testsetup
     Static void testData(){
          ucinn_ascendv2__Trigger_Handler__c customHandler02 = new ucinn_ascendv2__Trigger_Handler__c();
        customHandler02.Name = 'Custom Assignment Handler';
        customHandler02.ucinn_ascendv2__Class__c = 'AssignmentHandler';
        customHandler02.ucinn_ascendv2__Is_Active__c = true;
        customHandler02.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Assignment__c';
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
          // Create Secondary Contact
         Contact secondaryContact = new Contact();
         secondaryContact.FirstName = 'Secondary';
         secondaryContact.LastName = 'Contact';
         secondaryContact.AccountId = accts[0].Id;
         secondaryContact.ucinn_ascendv2__Gender__c = 'Female';
         secondaryContact.ucinn_ascendv2__Contact_Type__c = 'AL';
         secondaryContact.Constituent_Status__c = 'A';
         insert secondaryContact;
         
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
        accts[0].Secondary_Constituent__c=secondaryContact.id;  
        update accts;
     }
  	  @isTest
    Static void method1(){
        List<Account>accList=[Select id,name,ucinn_ascendv2__PRM__c from Account];
		List<Contact>conList=[Select id,FirstName from Contact];       
        //Insert Address
        ucinn_ascendv2__Address__c add01 = new ucinn_ascendv2__Address__c();
        add01.Name = 'TEST Address 01';
        add01.ucinn_ascendv2__Address_Line_1__c = 'Test 01 ave';
        add01.ucinn_ascendv2__City__c = 'City';
        add01.ucinn_ascendv2__State__c = 'CA';
        add01.ucinn_ascendv2__Postal_Code__c= '11';
        add01.ucinn_ascendv2__Country__c = 'United States';
        insert add01;   
       Id conAddRelRecTypeId = Schema.SObjectType.ucinn_ascendv2__Address_Relation__c.getRecordTypeInfosByName().get('Constituent Address Relation').getRecordTypeId();
		 //Insert AddressRelation
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
        //Insert Assignment
        ucinn_ascendv2__Assignment__c newAssignment = new ucinn_ascendv2__Assignment__c(
            ucinn_ascendv2__Account__c = accList[0].Id,
            Comments__c='Test Comment',
            ucinn_ascendv2__Assigned_Relationship_Manager_User__c= accList[0].ucinn_ascendv2__PRM__c,
            ucinn_ascendv2__Assignment_Type__c = 'Primary Relationship Manager'
        );
        insert newAssignment;       
         ucinn_ascendv2__Assignment__c oldAssignment = new ucinn_ascendv2__Assignment__c(
            ucinn_ascendv2__Account__c = accList[1].Id,
             Comments__c='Test Comment1',
             ucinn_ascendv2__Assigned_Relationship_Manager_User__c= accList[0].ucinn_ascendv2__PRM__c,
            ucinn_ascendv2__Assignment_Type__c = 'Primary Relationship Manager' 
         );
        insert oldAssignment;
        Test.startTest();
      AssignmentHandler.processAddressRelations(new List<ucinn_ascendv2__Assignment__c>{ newAssignment }, new List<ucinn_ascendv2__Assignment__c>{ oldAssignment });
        Test.stopTest();  
    }	
     @isTest
    Static void method2(){
        List<Account>accList=[Select id,name,ucinn_ascendv2__PRM__c from Account];
		List<Contact>conList=[Select id,FirstName from Contact];       
        
        ucinn_ascendv2__Address__c add01 = new ucinn_ascendv2__Address__c();
        add01.Name = 'TEST Address 02';
        add01.ucinn_ascendv2__Address_Line_1__c = 'Test 02 ave';
        add01.ucinn_ascendv2__City__c = 'City';
        add01.ucinn_ascendv2__State__c = 'CA';
        add01.ucinn_ascendv2__Postal_Code__c= '12';
        add01.ucinn_ascendv2__Country__c = 'Canada';
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
        ucinn_ascendv2__Assignment__c newAssignment = new ucinn_ascendv2__Assignment__c(
            ucinn_ascendv2__Account__c = accList[0].Id,
            Comments__c='Test Comment',
            ucinn_ascendv2__Assigned_Relationship_Manager_User__c= accList[0].ucinn_ascendv2__PRM__c,
            ucinn_ascendv2__Assignment_Type__c = 'Primary Relationship Manager'
        );
        insert newAssignment;        
         ucinn_ascendv2__Assignment__c oldAssignment = new ucinn_ascendv2__Assignment__c(
            ucinn_ascendv2__Account__c = accList[1].Id,
             Comments__c='Test Comment1',
             ucinn_ascendv2__Assigned_Relationship_Manager_User__c= accList[0].ucinn_ascendv2__PRM__c,
            ucinn_ascendv2__Assignment_Type__c = 'Primary Relationship Manager'
        );
        insert oldAssignment;     
        Test.startTest();
      AssignmentHandler.processAddressRelations(new List<ucinn_ascendv2__Assignment__c>{ newAssignment }, new List<ucinn_ascendv2__Assignment__c>{ oldAssignment });
        Test.stopTest();
    }

     @isTest
    Static void method3(){
        List<Account>accList=[Select id,name,ucinn_ascendv2__PRM__c from Account];
		List<Contact>conList=[Select id,FirstName from Contact];       
        accList[0].ucinn_ascendv2__PRM__c=null;
        update acclist;
        
        ucinn_ascendv2__Address__c add01 = new ucinn_ascendv2__Address__c();
        add01.Name = 'TEST Address 04';
        add01.ucinn_ascendv2__Address_Line_1__c = 'Test 04 ave';
        add01.ucinn_ascendv2__City__c = 'City';
        add01.ucinn_ascendv2__State__c = 'CA';
        add01.ucinn_ascendv2__Postal_Code__c= '12';
        add01.ucinn_ascendv2__Country__c = 'Canada';
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
        ucinn_ascendv2__Assignment__c newAssignment = new ucinn_ascendv2__Assignment__c(
            ucinn_ascendv2__Account__c = accList[0].Id,
            Comments__c='Test Comment',
            ucinn_ascendv2__Assigned_Relationship_Manager_User__c= accList[0].ucinn_ascendv2__PRM__c,
            ucinn_ascendv2__Assignment_Type__c ='Primary Relationship Manager'
        );
        insert newAssignment;        
         ucinn_ascendv2__Assignment__c oldAssignment = new ucinn_ascendv2__Assignment__c(
            ucinn_ascendv2__Account__c = accList[1].Id,
             Comments__c='Test Comment1',
             ucinn_ascendv2__Assigned_Relationship_Manager_User__c= accList[0].ucinn_ascendv2__PRM__c,
            ucinn_ascendv2__Assignment_Type__c = 'Primary Relationship Manager'
        );
        insert oldAssignment;
        Test.startTest();
      AssignmentHandler.processAddressRelations(new List<ucinn_ascendv2__Assignment__c>{ newAssignment }, new List<ucinn_ascendv2__Assignment__c>{ oldAssignment });
        Test.stopTest();
     
    }
     	  @isTest
    Static void method4(){
        List<Account>accList=[Select id,name,ucinn_ascendv2__PRM__c from Account];
		List<Contact>conList=[Select id,FirstName from Contact];       
        accList[0].ucinn_ascendv2__PRM__c=null;
        update acclist;
        
        ucinn_ascendv2__Address__c add01 = new ucinn_ascendv2__Address__c();
        add01.Name = 'TEST Address 04';
        add01.ucinn_ascendv2__Address_Line_1__c = 'Test 04 ave';
        add01.ucinn_ascendv2__City__c = 'City';
        add01.ucinn_ascendv2__State__c = 'CA';
        add01.ucinn_ascendv2__Postal_Code__c= '11';
        add01.ucinn_ascendv2__Country__c = 'United States';
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
        ucinn_ascendv2__Assignment__c newAssignment = new ucinn_ascendv2__Assignment__c(
            ucinn_ascendv2__Account__c = accList[0].Id,
            Comments__c='Test Comment',
            ucinn_ascendv2__Assigned_Relationship_Manager_User__c= accList[0].ucinn_ascendv2__PRM__c,
            ucinn_ascendv2__Assignment_Type__c = 'Primary Relationship Manager'
        );
        insert newAssignment;        
         ucinn_ascendv2__Assignment__c oldAssignment = new ucinn_ascendv2__Assignment__c(
            ucinn_ascendv2__Account__c = accList[1].Id,
             Comments__c='Test Comment1',
             ucinn_ascendv2__Assigned_Relationship_Manager_User__c= accList[0].ucinn_ascendv2__PRM__c,
            ucinn_ascendv2__Assignment_Type__c = 'Primary Relationship Manager'
        );
        insert oldAssignment;
        Test.startTest();
      AssignmentHandler.processAddressRelations(new List<ucinn_ascendv2__Assignment__c>{ newAssignment }, new List<ucinn_ascendv2__Assignment__c>{ oldAssignment });
        Test.stopTest();     
    }
     @isTest
     Static void method5(){
        List<Account>accList=[Select id,name,ucinn_ascendv2__PRM__c from Account];
		List<Contact>conList=[Select id,FirstName from Contact];       
        //Insert Address
        ucinn_ascendv2__Address__c add01 = new ucinn_ascendv2__Address__c();
        add01.Name = 'TEST Address 01';
        add01.ucinn_ascendv2__Address_Line_1__c = 'Test 01 ave';
        add01.ucinn_ascendv2__City__c = 'City';
        add01.ucinn_ascendv2__State__c = 'CA';
        add01.ucinn_ascendv2__Postal_Code__c= '11';
        add01.ucinn_ascendv2__Country__c = 'United States';
        insert add01;   
       Id conAddRelRecTypeId = Schema.SObjectType.ucinn_ascendv2__Address_Relation__c.getRecordTypeInfosByName().get('Constituent Address Relation').getRecordTypeId();
		 //Insert AddressRelation
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
        //Insert Assignment
        ucinn_ascendv2__Assignment__c newAssignment = new ucinn_ascendv2__Assignment__c(
            ucinn_ascendv2__Account__c = accList[0].Id,
            Comments__c='Test Comment',
            ucinn_ascendv2__Assigned_Relationship_Manager_User__c= accList[0].ucinn_ascendv2__PRM__c,
            ucinn_ascendv2__Assignment_Type__c = 'Primary Relationship Manager'
        );
        insert newAssignment;       
         ucinn_ascendv2__Assignment__c oldAssignment = new ucinn_ascendv2__Assignment__c(
            ucinn_ascendv2__Account__c = accList[1].Id,
             Comments__c='Test Comment1',
             ucinn_ascendv2__Assigned_Relationship_Manager_User__c= accList[0].ucinn_ascendv2__PRM__c,
            ucinn_ascendv2__Assignment_Type__c = 'Primary Relationship Manager' 
         );
        insert oldAssignment;
        Test.startTest();
      AssignmentHandler.processAddressRelations(new List<ucinn_ascendv2__Assignment__c>{ newAssignment }, new List<ucinn_ascendv2__Assignment__c>{ oldAssignment });
        Test.stopTest();  
    }	
}