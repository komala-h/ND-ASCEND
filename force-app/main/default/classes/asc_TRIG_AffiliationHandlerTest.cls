/**
 * @author UC Innovation
 * @date 3/10/2022
 * @description Test class for Affiliation Trigger
 */
@isTest
private class asc_TRIG_AffiliationHandlerTest {
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
        
        ucinn_ascendv2__Trigger_Handler__c customHandler05 = new ucinn_ascendv2__Trigger_Handler__c();
        customHandler05.Name = 'Custom Affiliation Handler';
        customHandler05.ucinn_ascendv2__Class__c = 'asc_TRIG_AffiliationHandler';
        customHandler05.ucinn_ascendv2__Is_Active__c = true;
        customHandler05.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Affiliation__c';
        customHandler05.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;BeforeDelete;AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
        customHandler05.ucinn_ascendv2__Load_Order__c = 2;
        insert customHandler05;
        
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

        ucinn_ascendv2__Affiliation__c affil = new ucinn_ascendv2__Affiliation__c();
        affil.ucinn_ascendv2__Account__c = accts[1].Id;
        affil.ucinn_ascendv2__Contact__c = h01.Id;
        affil.ucinn_ascendv2__Status__c = 'Current';
        affil.ucinn_ascendv2__Data_Source__c = 'AC';
        affil.ucinn_ascendv2__Constituent_Role__c = 'Employee';
        affil.ucinn_ascendv2__Organization_Role__c = 'Employer';
        insert affil;

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

        Id conAddRelRecTypeId = Schema.SObjectType.ucinn_ascendv2__Address_Relation__c.getRecordTypeInfosByName().get('Constituent Address Relation').getRecordTypeId();

        ucinn_ascendv2__Address_Relation__c addrel = new ucinn_ascendv2__Address_Relation__c();
        addrel.ucinn_ascendv2__Address__c = add01.Id;
        addrel.ucinn_ascendv2__Account__c = accts[1].Id;
        addrel.ucinn_ascendv2__Contact__c = h01.Id;
        addrel.ucinn_ascendv2__Status__c = 'Current';
        addrel.ucinn_ascendv2__Type__c = 'B';
        addrel.RecordTypeId = conAddRelRecTypeId;
        insert addrel;
        

    }
    
    @isTest(SeeAllData=false) 
    static void testSyncPhoneFromAffiliation() {

        ucinn_ascendv2__Phone__c phone = [SELECT Id, Affiliation__c
                                          FROM ucinn_ascendv2__Phone__c
                                          WHERE (ucinn_ascendv2__Type__c = 'B')
                                          LIMIT 1];

        ucinn_ascendv2__Affiliation__c affil = [SELECT Id, Business_Phone__c 
                                                FROM ucinn_ascendv2__Affiliation__c 
                                                WHERE (ucinn_ascendv2__Status__c = 'Current')
                                                LIMIT 1];


        system.assert(phone.Affiliation__c == null);

        Test.startTest();
        affil.Business_Phone__c = phone.Id;
        update affil;
        Test.stopTest();

        phone = [SELECT Id, Affiliation__c 
                FROM ucinn_ascendv2__Phone__c 
                WHERE (ucinn_ascendv2__Type__c = 'B')
                LIMIT 1];

        system.assert(phone.Affiliation__c == affil.Id);
        
    }

    @isTest(SeeAllData=false) 
    static void testSyncEmailFromAffiliation() {

        ucinn_ascendv2__Email__c email = [SELECT Id, Affiliation__c
                                          FROM ucinn_ascendv2__Email__c
                                          WHERE (ucinn_ascendv2__Type__c = 'U')
                                          LIMIT 1];

        ucinn_ascendv2__Affiliation__c affil = [SELECT Id, Business_Email__c 
                                                FROM ucinn_ascendv2__Affiliation__c 
                                                WHERE (ucinn_ascendv2__Status__c = 'Current')
                                                LIMIT 1];


        system.assert(email.Affiliation__c == null);

        Test.startTest();
        affil.Business_Email__c = email.Id;
        update affil;
        Test.stopTest();

        email = [SELECT Id, Affiliation__c 
                FROM ucinn_ascendv2__Email__c 
                WHERE (ucinn_ascendv2__Type__c = 'U')
                LIMIT 1];
            
        system.assert(email.Affiliation__c == affil.Id);
        
    }
    
    @isTest(SeeAllData=false) 
    static void testSyncAddressRelationFromAffiliation() {

        ucinn_ascendv2__Address_Relation__c addrel = [SELECT Id, Affiliation__c
                                                      FROM ucinn_ascendv2__Address_Relation__c
                                                      WHERE (ucinn_ascendv2__Type__c = 'B')
                                                      LIMIT 1];

        ucinn_ascendv2__Affiliation__c affil = [SELECT Id, Business_Address__c 
                                                FROM ucinn_ascendv2__Affiliation__c 
                                                WHERE (ucinn_ascendv2__Status__c = 'Current')
                                                LIMIT 1];

        system.assert(addrel.Affiliation__c == null);

        Test.startTest();
        affil.Business_Address__c = addrel.Id;
        update affil;
        Test.stopTest();

        addrel = [SELECT Id, Affiliation__c
                  FROM ucinn_ascendv2__Address_Relation__c
                  WHERE (ucinn_ascendv2__Type__c = 'B')
                  LIMIT 1];
            
        system.assert(addrel.Affiliation__c == affil.Id);        
        
    }  
    
    @isTest(SeeAllData=false) 
    static void testSyncPhoneFromFormerAffiliation() {

        ucinn_ascendv2__Phone__c phone = [SELECT Id, Affiliation__c
                                          FROM ucinn_ascendv2__Phone__c
                                          WHERE (ucinn_ascendv2__Type__c = 'B')
                                          LIMIT 1];

        ucinn_ascendv2__Affiliation__c affil = [SELECT Id, Business_Phone__c 
                                                FROM ucinn_ascendv2__Affiliation__c 
                                                WHERE (ucinn_ascendv2__Status__c = 'Current')
                                                LIMIT 1];

        affil.ucinn_ascendv2__Status__c = 'Former';
        affil.ucinn_ascendv2__End_Date__c = date.today();
        update affil;

        system.assert(phone.Affiliation__c == null);

        Test.startTest();
        affil.Business_Phone__c = phone.Id;
        update affil;
        Test.stopTest();

        phone = [SELECT Id, Affiliation__c, ucinn_ascendv2__End_Date__c 
                FROM ucinn_ascendv2__Phone__c 
                WHERE (ucinn_ascendv2__Type__c = 'B')
                LIMIT 1];
            
        system.assert(phone.Affiliation__c == affil.Id);
        system.assert(phone.ucinn_ascendv2__End_Date__c == date.today());
        
    }

    @isTest(SeeAllData=false) 
    static void testSyncEmailFromFormerAffiliation() {

        ucinn_ascendv2__Email__c email = [SELECT Id, Affiliation__c
                                          FROM ucinn_ascendv2__Email__c
                                          WHERE (ucinn_ascendv2__Type__c = 'U')
                                          LIMIT 1];

        ucinn_ascendv2__Affiliation__c affil = [SELECT Id, Business_Email__c 
                                                FROM ucinn_ascendv2__Affiliation__c 
                                                WHERE (ucinn_ascendv2__Status__c = 'Current')
                                                LIMIT 1];

        affil.ucinn_ascendv2__Status__c = 'Former';
        affil.ucinn_ascendv2__End_Date__c = date.today();
        update affil;

        system.assert(email.Affiliation__c == null);

        Test.startTest();
        affil.Business_Email__c = email.Id;
        update affil;
        Test.stopTest();

        email = [SELECT Id, Affiliation__c, ucinn_ascendv2__End_Date__c
                FROM ucinn_ascendv2__Email__c 
                WHERE (ucinn_ascendv2__Type__c = 'U')
                LIMIT 1];
            
        system.assert(email.Affiliation__c == affil.Id);
        system.assert(email.ucinn_ascendv2__End_Date__c == date.today());
        
    }
   
    
    @isTest(SeeAllData=false) 
    static void testSyncAddressRelationFromFormerAffiliation() {

        ucinn_ascendv2__Address_Relation__c addrel = [SELECT Id, Affiliation__c
                                                      FROM ucinn_ascendv2__Address_Relation__c
                                                      WHERE (ucinn_ascendv2__Type__c = 'B')
                                                      LIMIT 1];

        ucinn_ascendv2__Affiliation__c affil = [SELECT Id, Business_Address__c 
                                                FROM ucinn_ascendv2__Affiliation__c 
                                                WHERE (ucinn_ascendv2__Status__c = 'Current')
                                                LIMIT 1];

        affil.ucinn_ascendv2__Status__c = 'Former';
        affil.ucinn_ascendv2__End_Date__c = date.today();
        update affil;

        system.assert(addrel.Affiliation__c == null);

        Test.startTest();
        affil.Business_Address__c = addrel.Id;
        update affil;
        Test.stopTest();

        addrel = [SELECT Id, Affiliation__c, ucinn_ascendv2__End_Date__c
                  FROM ucinn_ascendv2__Address_Relation__c
                  WHERE (ucinn_ascendv2__Type__c = 'B')
                  LIMIT 1];
            
        system.assert(addrel.Affiliation__c == affil.Id);        
        system.assert(addrel.ucinn_ascendv2__End_Date__c == date.today());
        
    }    

    @isTest(SeeAllData=false)
    static void testUpdateConstituentIfPrimaryAffiliation(){
        List<Account> accts = new List<Account>{
            new Account(Name = 'TEST1',ucinn_ascendv2__Donor_ID__c = '1'),
            new Account(Name = 'TEST2',ucinn_ascendv2__Donor_ID__c = '2'),
            new Account(Name = 'Test3',ucinn_ascendv2__Donor_ID__c = '3')
        };
        insert accts;
        
        Contact h01 = new Contact();
        h01.FirstName = 'testest';
        h01.LastName = 'testtest';
        h01.AccountId = accts[0].Id;
        h01.ucinn_ascendv2__Gender__c = 'Male';
        h01.ucinn_ascendv2__Contact_Type__c = 'AL';
        h01.ucinn_ascendv2__Personal_Email__c = 'sample@uci.com';
        h01.Constituent_Status__c = 'A';
        insert h01;

        Test.startTest();

        ucinn_ascendv2__Affiliation__c affil = new ucinn_ascendv2__Affiliation__c();
        affil.ucinn_ascendv2__Account__c = accts[1].Id;
        affil.ucinn_ascendv2__Contact__c = h01.Id;
        affil.Is_Primary_Employment__c = true;
        affil.ucinn_ascendv2__Status__c = 'Current';
        affil.ucinn_ascendv2__Business_Title__c = 'test1';
        affil.ucinn_ascendv2__Data_Source__c = 'AC';
        affil.ucinn_ascendv2__Constituent_Role__c = 'Employee';
        affil.ucinn_ascendv2__Organization_Role__c = 'Employer';
        insert affil;

        ucinn_ascendv2__Affiliation__c affil2 = new ucinn_ascendv2__Affiliation__c();
        affil2.ucinn_ascendv2__Account__c = accts[2].Id;
        affil2.ucinn_ascendv2__Contact__c = h01.Id;
        affil2.ucinn_ascendv2__Status__c = 'Former';
        affil2.Is_Primary_Employment__c = false;
        affil2.ucinn_ascendv2__Business_Title__c = 'test2';
        affil2.ucinn_ascendv2__Data_Source__c = 'AC';
        affil2.ucinn_ascendv2__Constituent_Role__c = 'Employee';
        affil2.ucinn_ascendv2__Organization_Role__c = 'Employer';
        insert affil2;

        Contact testCon = [SELECT id, Current_Employer__c, Employer_Name__c, Title FROM Contact WHERE id =: h01.id];
        System.assertEquals(testCon.Current_Employer__c, affil.ucinn_ascendv2__Account__c);
//        System.assertEquals(testCon.Employer_Name__c, accts[1].Name);
        System.assertEquals(testCon.Title, affil.ucinn_ascendv2__Business_Title__c);

        affil.ucinn_ascendv2__Status__c = 'Former';
        update affil;

        testCon = [SELECT id, Current_Employer__c, Employer_Name__c, Title FROM Contact WHERE id =: h01.id];
        System.assertEquals(testCon.Current_Employer__c, null);
        System.assertEquals(testCon.Employer_Name__c, null);
        System.assertEquals(testCon.Title, null);

        affil2.ucinn_ascendv2__Status__c = 'Current';
        affil2.Is_Primary_Employment__c = true;
        update affil2;

        testCon = [SELECT id, Current_Employer__c, Employer_Name__c, Title FROM Contact WHERE id =: h01.id];
        System.assertEquals(testCon.Current_Employer__c, affil2.ucinn_ascendv2__Account__c);
  //      System.assertEquals(testCon.Employer_Name__c, accts[2].Name);
        System.assertEquals(testCon.Title, affil2.ucinn_ascendv2__Business_Title__c);

        delete affil2;
        testCon = [SELECT id, Current_Employer__c, Employer_Name__c, Title FROM Contact WHERE id =: h01.id];
        System.assertEquals(testCon.Current_Employer__c, null);
        System.assertEquals(testCon.Employer_Name__c, null);
        System.assertEquals(testCon.Title, null);

        Test.stopTest();
    }
}