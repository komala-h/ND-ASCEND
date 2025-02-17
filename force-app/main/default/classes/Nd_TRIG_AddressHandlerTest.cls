@isTest
public class Nd_TRIG_AddressHandlerTest {
 @testsetup
     Static void testData(){
         ucinn_ascendv2__Trigger_Handler__c customHandler02 = new ucinn_ascendv2__Trigger_Handler__c();
        customHandler02.Name = 'Custom AddressHandler';
        customHandler02.ucinn_ascendv2__Class__c = 'Nd_TRIG_AddressHandler';
        customHandler02.ucinn_ascendv2__Is_Active__c = true;
        customHandler02.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Address__c';
        customHandler02.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;BeforeDelete;AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
        customHandler02.ucinn_ascendv2__Load_Order__c = 2;
        insert customHandler02;
        List<Account> accts = new List<Account>{
        new Account(Name = 'TEST, h01 h123 Household',ucinn_ascendv2__Donor_ID__c = 'h123'),
        new Account(Name = 'University of Notre Dame',ucinn_ascendv2__Donor_ID__c = '307129')
        };
        insert accts;
        system.debug('accts '+accts);
        //insert Contact
        Contact h01 = new Contact();
        h01.FirstName = 'h01';
        h01.LastName = 'TEST';
        h01.AccountId = accts[0].Id;
        h01.ucinn_ascendv2__Gender__c = 'Male';
        h01.ucinn_ascendv2__Contact_Type__c = 'AL';
        h01.ucinn_ascendv2__Personal_Email__c = 'sample@uci.com';
        h01.Constituent_Status__c = 'A';
        insert h01;
		system.debug('contact '+h01);
         
         // Create Secondary Contact
         Contact secondaryContact = new Contact();
         secondaryContact.FirstName = 'Secondary';
         secondaryContact.LastName = 'Contact';
         secondaryContact.AccountId = accts[0].Id;
         secondaryContact.ucinn_ascendv2__Gender__c = 'Female';
         secondaryContact.ucinn_ascendv2__Contact_Type__c = 'AL';
         secondaryContact.Constituent_Status__c = 'A';
         insert secondaryContact;
         
        
         
		//insert Geo Group for US,Canada,Others
     ND_Geo_Group_Region__c gr1 = new ND_Geo_Group_Region__c(Postal_Code__c='11',MSA_Code__c=123,MSA_Name__c='test',ND_Club_Region__c='01010',
                                                              Prospect_Region__c = '1',nd_Country_Full_Name__c='United States');
        insert gr1;
        system.debug('gr1 '+gr1);
        ND_Geo_Group_Region__c gr2 = new ND_Geo_Group_Region__c(Postal_Code__c='12',MSA_Code__c=123,MSA_Name__c='test1',ND_Club_Region__c='92051',
                                                              Prospect_Region__c = '2',nd_Country_Full_Name__c='Canada');
        insert gr2;
        system.debug('gr2 '+gr2);
         ND_Geo_Group_Region__c gr3 = new ND_Geo_Group_Region__c(Postal_Code__c='13',MSA_Code__c=123,MSA_Name__c='test2',ND_Club_Region__c='96000',
                                                              Prospect_Region__c = '3',nd_Country_Full_Name__c='India');
        insert gr3; 
        system.debug('gr3 '+gr3);
         ND_Geo_Group_Region__c gr4 = new ND_Geo_Group_Region__c(Postal_Code__c='14',MSA_Code__c=120,MSA_Name__c='test3',ND_Club_Region__c='02010',
                                                              Prospect_Region__c = '4',nd_Country_Full_Name__c='United States');
        insert gr4;  
        system.debug('gr4 '+gr4);
        ND_Geo_Group_Region__c gr5 = new ND_Geo_Group_Region__c(Postal_Code__c='15',MSA_Code__c=120,MSA_Name__c='test3',ND_Club_Region__c='92050',
                                                              Prospect_Region__c = '4',nd_Country_Full_Name__c='Canada');
        insert gr5;  
        system.debug('gr5 '+gr5); 
  		accts[0].ucinn_ascendv2__PRM__c = [select id from user where id=:userinfo.getuserid()].Id;
        accts[0].ucinn_ascendv2__Primary_Contact__c=h01.id;
        accts[0].Secondary_Constituent__c=secondaryContact.id;  
        update accts;
         
        // Create Assignment
        ucinn_ascendv2__Assignment__c newAssignment = new ucinn_ascendv2__Assignment__c(
        ucinn_ascendv2__Account__c = accts[0].Id,
        Comments__c='Test Comment',
        ucinn_ascendv2__Assigned_Relationship_Manager_User__c= accts[0].ucinn_ascendv2__PRM__c,
        ucinn_ascendv2__Assignment_Type__c = 'Primary Relationship Manager'
        );
        insert newAssignment;
         
        //Create Address & Address Relation
        ucinn_ascendv2__Address__c add01 = new ucinn_ascendv2__Address__c();
        add01.Name = 'TEST Address 01';
        add01.ucinn_ascendv2__Address_Line_1__c = 'Test 01 ave';
        add01.ucinn_ascendv2__City__c = 'City';
        add01.ucinn_ascendv2__State__c = 'CA';
        add01.ucinn_ascendv2__Postal_Code__c= '11';
        add01.ucinn_ascendv2__Country__c = 'United States';
        insert add01;
		system.debug('address '+add01);
        Id conAddRelRecTypeId = Schema.SObjectType.ucinn_ascendv2__Address_Relation__c.getRecordTypeInfosByName().get('Constituent Address Relation').getRecordTypeId();

        ucinn_ascendv2__Address_Relation__c addrel = new ucinn_ascendv2__Address_Relation__c();
        addrel.ucinn_ascendv2__Address__c = add01.Id;
        addrel.ucinn_ascendv2__Account__c = accts[0].Id;
        addrel.ucinn_ascendv2__Contact__c = h01.Id;
        addrel.ucinn_ascendv2__Status__c = 'Current';
        addrel.ucinn_ascendv2__Type__c = 'H';
        addrel.RecordTypeId = conAddRelRecTypeId;
        addrel.ucinn_ascendv2__End_Date__c = null;
        addrel.ucinn_ascendv2__Start_Date__c = null;
        addrel.ucinn_ascendv2__Is_Preferred__c = true;
        insert addrel;   
       system.debug('addrel '+addrel);
         ucinn_ascendv2__Address_Relation__c secondaryAddressRel = new ucinn_ascendv2__Address_Relation__c();
        secondaryAddressRel.ucinn_ascendv2__Address__c = add01.Id;
        secondaryAddressRel.ucinn_ascendv2__Account__c = accts[0].Id;
        secondaryAddressRel.ucinn_ascendv2__Contact__c = secondaryContact.Id;
        secondaryAddressRel.ucinn_ascendv2__Status__c = 'Current';
        secondaryAddressRel.ucinn_ascendv2__Type__c = 'H';
        secondaryAddressRel.RecordTypeId = conAddRelRecTypeId;
        secondaryAddressRel.ucinn_ascendv2__End_Date__c = null;
        secondaryAddressRel.ucinn_ascendv2__Start_Date__c = null;
        secondaryAddressRel.ucinn_ascendv2__Is_Preferred__c = true;
        insert secondaryAddressRel; 
     }
      @isTest
    Static void method1(){
        List<Account>accList=[Select id,name,ucinn_ascendv2__PRM__c from Account];
		List<Contact>conList=[Select id,FirstName from Contact];       
        list<ucinn_ascendv2__Address__c>addList=[Select id,ucinn_ascendv2__Postal_Code__c,ucinn_ascendv2__Country__c from ucinn_ascendv2__Address__c];      
        List< ucinn_ascendv2__Address_Relation__c>addrelList =[Select id, ucinn_ascendv2__Address__c, ucinn_ascendv2__Contact__c  from  ucinn_ascendv2__Address_Relation__c];
         ucinn_ascendv2__Address__c oldAddress =addList[0];
       Map<Id, ucinn_ascendv2__Address__c> oldMap = new Map<Id, ucinn_ascendv2__Address__c>();
        oldMap.put(oldAddress.Id,
            new ucinn_ascendv2__Address__c(
                Id = oldAddress.Id,
                ucinn_ascendv2__Postal_Code__c = oldAddress.ucinn_ascendv2__Postal_Code__c,
        		ucinn_ascendv2__Country__c = oldAddress.ucinn_ascendv2__Country__c                
            )
        );
         oldAddress.ucinn_ascendv2__Postal_Code__c = '14';
        update oldAddress;
        Test.startTest();
      Nd_TRIG_AddressHandler.processAddressRelations(new List<ucinn_ascendv2__Address__c>{oldAddress}, oldMap);
        Test.stopTest();
    }   
     @isTest
    Static void method2(){
        List<Account>accList=[Select id,name,ucinn_ascendv2__PRM__c from Account];
		List<Contact>conList=[Select id,FirstName from Contact];
        list<ucinn_ascendv2__Address__c>addList=[Select id,ucinn_ascendv2__Postal_Code__c,ucinn_ascendv2__Country__c from ucinn_ascendv2__Address__c];
        List< ucinn_ascendv2__Address_Relation__c>addrelList =[Select id,ucinn_ascendv2__Address__c, ucinn_ascendv2__Contact__c from  ucinn_ascendv2__Address_Relation__c];
         ucinn_ascendv2__Address__c oldAddress =addList[0];
        oldAddress.ucinn_ascendv2__Country__c='Canada';
        update oldAddress;
          Map<Id, ucinn_ascendv2__Address__c> oldMap = new Map<Id, ucinn_ascendv2__Address__c>();
        oldMap.put(oldAddress.Id,
            new ucinn_ascendv2__Address__c(
                Id = oldAddress.Id,
                ucinn_ascendv2__Postal_Code__c = oldAddress.ucinn_ascendv2__Postal_Code__c,
        		ucinn_ascendv2__Country__c = oldAddress.ucinn_ascendv2__Country__c                
            )
        );
         oldAddress.ucinn_ascendv2__Postal_Code__c = '15';
        update oldAddress;
        Test.startTest(); 
      Nd_TRIG_AddressHandler.processAddressRelations(new List<ucinn_ascendv2__Address__c>{oldAddress}, oldMap);
        Test.stopTest();        
    }  
    /* @isTest
    Static void method3(){
        List<Account>accList=[Select id,name,ucinn_ascendv2__PRM__c from Account];
		List<Contact>conList=[Select id,FirstName from Contact]; 
        accList[0].ucinn_ascendv2__PRM__c=null;
        update acclist;
        list<ucinn_ascendv2__Address__c>addList=[Select id,ucinn_ascendv2__Postal_Code__c,ucinn_ascendv2__Country__c from ucinn_ascendv2__Address__c];
        List< ucinn_ascendv2__Address_Relation__c>addrelList =[Select id,ucinn_ascendv2__Address__c, ucinn_ascendv2__Contact__c from  ucinn_ascendv2__Address_Relation__c];
         ucinn_ascendv2__Address__c oldAddress =addList[0];
        oldAddress.ucinn_ascendv2__Country__c='Canada';
        update oldAddress;
          Map<Id, ucinn_ascendv2__Address__c> oldMap = new Map<Id, ucinn_ascendv2__Address__c>();
        oldMap.put(oldAddress.Id,
            new ucinn_ascendv2__Address__c(
                Id = oldAddress.Id,
                ucinn_ascendv2__Postal_Code__c = oldAddress.ucinn_ascendv2__Postal_Code__c,
        		ucinn_ascendv2__Country__c = oldAddress.ucinn_ascendv2__Country__c                
            )
        );
         oldAddress.ucinn_ascendv2__Postal_Code__c = '15';
        update oldAddress;
        Test.startTest(); 
      Nd_TRIG_AddressHandler.processAddressRelations(new List<ucinn_ascendv2__Address__c>{oldAddress}, oldMap);
        Test.stopTest();        
    } */
    @isTest
  static void testSameAddressDifferentRelations() {
     List<Account>accList=[Select id,name,ucinn_ascendv2__PRM__c from Account];
		List<Contact>conList=[Select id,FirstName from Contact];       
        list<ucinn_ascendv2__Address__c>addList=[Select id,ucinn_ascendv2__Postal_Code__c,ucinn_ascendv2__Country__c from ucinn_ascendv2__Address__c];
        List< ucinn_ascendv2__Address_Relation__c>addrelList =[Select id,ucinn_ascendv2__Address__c, ucinn_ascendv2__Contact__c from  ucinn_ascendv2__Address_Relation__c];
       ucinn_ascendv2__Address__c oldAddress =addList[0];
    Map<Id, ucinn_ascendv2__Address__c> oldMap = new Map<Id, ucinn_ascendv2__Address__c>();
    oldMap.put(oldAddress.Id, new ucinn_ascendv2__Address__c(Id = oldAddress.Id,
                                                            ucinn_ascendv2__Postal_Code__c = oldAddress.ucinn_ascendv2__Postal_Code__c,
        		ucinn_ascendv2__Country__c = oldAddress.ucinn_ascendv2__Country__c  ));

    // Update the shared address to trigger the handler
    oldAddress.ucinn_ascendv2__Postal_Code__c = '20';
    update oldAddress;

    // Execute the trigger logic
    Test.startTest();
    Nd_TRIG_AddressHandler.processAddressRelations(new List<ucinn_ascendv2__Address__c>{oldAddress}, oldMap);
    Test.stopTest();   
}
}