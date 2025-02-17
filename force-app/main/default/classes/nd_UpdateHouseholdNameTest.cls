@isTest
public class nd_UpdateHouseholdNameTest {
    @testsetup
    static void setuprecords(){
        Account acc = new Account(Name = 'Test Account',ucinn_ascendv2__Email__c='abc@test.com',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporations and Organizations').getRecordTypeId());        
        insert acc;
        
        Contact primaryContact = new Contact(FirstName = 'John', LastName = 'Liren', AccountId = acc.Id,email='abc@def.com',Constituent_Status__c = 'A', ucinn_ascendv2__Donor_ID__c = '12345');
        insert primaryContact;
        
        acc.ucinn_ascendv2__Primary_Contact__c = primaryContact.Id;
        update acc;
    }
    
    @isTest
    static void testBatchExecution() {
        Account testAccount = [SELECT Name, ucinn_ascendv2__Primary_Contact__r.FirstName, ucinn_ascendv2__Primary_Contact__r.LastName, ucinn_ascendv2__Primary_Contact__r.ucinn_ascendv2__Donor_ID__c 
                               FROM Account WHERE Name = 'Test Account' LIMIT 1];        
        update testAccount;
        System.assertNotEquals(null, testAccount.ucinn_ascendv2__Primary_Contact__r, 'Primary Contact should be associated with the account');
        
        Test.startTest();
        nd_UpdateHouseholdName batchJob = new nd_UpdateHouseholdName();
        Database.executeBatch(batchJob, 1); 
        Test.stopTest();
        
        // Verify the Account name was updated correctly
        Account updatedAccount = [SELECT Name FROM Account WHERE Id = :testAccount.Id];
        String expectedName = 'Liren John 12345 Household';
        System.assertEquals(expectedName, updatedAccount.Name, 'The account name should match the expected format');
    }
     static testMethod void scheduleBatch() {    
        TracHier.HierarchyAPI.setTriggerDisabled();
        test.starttest();
        nd_UpdateHouseholdName i = new nd_UpdateHouseholdName();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, i);
        test.stopTest();
    }
}