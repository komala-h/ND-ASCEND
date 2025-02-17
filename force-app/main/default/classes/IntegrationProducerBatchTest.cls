@isTest(SeeAllData=false)
public class IntegrationProducerBatchTest {

    
     @testSetup 
    static void setup() {
		/** The code in this section will create test records only once
		 *  The test data can then be used by multiple test methods in
		 *  this test class
		 */
		Account a = new Account(name='Sirius Satellite');
        Account a2 = new Account(name='EMPLOYER IN NAME ONLY');
        insert new List<Account>{a, a2};
        //Account newOrganization = [select id from Account where name = 'Sirius Satellite' limit 1];
         
        Contact c = new Contact(accountid = a.Id, firstname = 'Sarah', lastname = 'Farris', Email='sfarris@ttech.edu', Constituent_Status__c='A');
        Contact c2 = new Contact(accountid = a2.Id, firstname = 'Dan', lastname = 'Lebatard', Email='lebatard@espn.com', Constituent_Status__c='A' );
        insert new List<Contact>{c, c2};
        //insert c;  
        
    }
    static testmethod void testContact() {
        
        Contact newConstituent = [select id from contact where name='Sarah Farris' limit 1];
        Account newOrganization = [select id from Account where name = 'Sirius Satellite' limit 1];
        //List<Integration_Out__c> intList= new List<Integration_Out__c>();
         datetime today = system.now();
        Integration_Out__c intOut = new Integration_Out__c(Name = newConstituent.Id, Modified_Record_Id__c = newConstituent.Id, event_type__c='I', Object_Api_Name__c='Contact', Status__c = 'N', Date_Modified__c=today);
        insert intOut;
        
        
        Test.startTest();
        // CRON expression: midnight on March 15. Because this is a test, 
    	// job is supposed to execute immediately after Test.stopTest()
    	/*
        String cronExpr = '0 0 0 15 3 ? 2022';
		IntegrationProducerBatchScheduler abs= new IntegrationProducerBatchScheduler();
		String jobId = System.schedule('IntegrationProducerBatchTest', cronExpr, abs);
		abs.execute(null);
        */
        Database.executeBatch(new IntegrationProducerBatch(false), 200);
		Test.stopTest();
        
        Integration_Out__c[] ints = [select id, name, Modified_Record_Id__c, json_message__c, event_type__c, status__c, Message__c from Integration_Out__c where Modified_Record_Id__c = :newConstituent.Id];
        system.debug('json message: ' + ints[0].json_message__c);
        
         Map<String, Object> m =(Map<String, Object>) JSON.deserializeUntyped(ints[0].json_message__c);
         Map<String, Object> newMap = (Map<String, Object>) m.get('object');
         Map<String, Object> newEvent = (Map<String, Object>) newmap.get('event');
         Map<String, Object> newtarget = (Map<String, Object>) newmap.get('target');
        //system.debug('testContact newtarget: '+newtarget);

        
        System.assertEquals('Sarah Farris', newtarget.get('Name'));
        System.assertEquals(newOrganization.id, newtarget.get('AccountId'));
        

        system.assert(ints[0].status__c == 'R'); 
        //system.assert(c. == 'R'); 
   
    }
    static testmethod void testDelete() {
        Contact newConstituent = [select id from contact where name='Sarah Farris' limit 1];
        Id conId = newConstituent.id;
        List<Contact> deleteList = new List<Contact>();
        deleteList.add(newConstituent);
        delete deleteList;
        
        
        datetime today = system.now();
        Integration_Out__c intOut = new Integration_Out__c(Name = conId, Modified_Record_Id__c = conId, event_type__c='U', Object_Api_Name__c='Contact', Status__c = 'N', Date_Modified__c=today);
        insert intOut;
        
        
        Test.startTest();
        // CRON expression: midnight on March 15. Because this is a test, 
    	// job is supposed to execute immediately after Test.stopTest()
    	/*
        String cronExpr = '0 0 0 15 3 ? 2022';
		IntegrationProducerBatchScheduler abs= new IntegrationProducerBatchScheduler();
		String jobId = System.schedule('IntegrationProducerBatchTest', cronExpr, abs);
		abs.execute(null);*/
        Database.executeBatch(new IntegrationProducerBatch(false), 200);
        
		Test.stopTest();
        
        Integration_Out__c[] ints = [select id, name, Modified_Record_Id__c, json_message__c, event_type__c, status__c, Message__c from Integration_Out__c where Modified_Record_Id__c = :conId];
        system.assert(ints[0].event_type__c == 'D'); 
        system.assert(ints[0].status__c == 'R'); 
        
        Map<String, Object> m =(Map<String, Object>) JSON.deserializeUntyped(ints[0].json_message__c);
         Map<String, Object> newMap = (Map<String, Object>) m.get('object');
         Map<String, Object> newEvent = (Map<String, Object>) newmap.get('event');
         Map<String, Object> newtarget = (Map<String, Object>) newmap.get('target');
        
        System.assert(newtarget.isEmpty());
        
        
        
        
    }
    
}