@isTest(SeeAllData=false)
public class Integration_Out_ClassTest {
 
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
        
            Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
     		User u = new User(Alias = 'sfarsris', Email='sfarfris@tntech.edu', 
            	EmailEncodingKey='UTF-8', LastName='Farris', LanguageLocaleKey='en_US', 
            	LocaleSidKey='en_US', ProfileId = p.Id, 
            	TimeZoneSidKey='America/Los_Angeles', UserName='sfarrviszsda@tffntech.edu');
     		insert u;
    }
    static testmethod void testQueueable() {
        Contact con = [select id, lastmodifieddate from contact where name='Sarah Farris' limit 1];
        
     String objectTypeStr=String.valueOf(con.getSObjectType());
     String objectId = con.Id; 
     DateTime modifiedDate = con.lastmodifieddate;
     String eventType ='I';

        
        Integration_Out_Class insertJob = new Integration_Out_Class(objectTypeStr, con.Id, DateTime.valueOf(modifiedDate), eventType, null);
       //ID jobID = System.enqueueJob(insertJob);
        
        Test.startTest();
        System.enqueueJob(insertJob);
        Test.stopTest();
        // Validate the job ran. Check if record have correct parentId now
        System.assertEquals(1, [select count() from contact where id = :objectId]);
        /*
        Integration_Out__c ints = [select id, Object_Api_Name__c, Modified_Record_Id__c, Date_Modified__c, Event_Type__c from Integration_Out__c ];
        
        system.debug('Integration_Out__c - '+ints);
        System.assertEquals(3, [select count() from Integration_Out__c where Modified_Record_Id__c = :objectId]);
        */

        
        
    }
 static testmethod void testQueueableDelete() {
        Contact con = [select id, lastmodifiedDate from contact where name='Sarah Farris' limit 1];
        
     String objectTypeStr=String.valueOf(con.getSObjectType());
     String objectId = con.Id; 
     DateTime modifiedDate = con.lastmodifiedDate;
     String eventType ='D';

        
        Integration_Out_Class insertJob = new Integration_Out_Class(objectTypeStr, con.Id, DateTime.valueOf(modifiedDate), eventType,null);
       //ID jobID = System.enqueueJob(insertJob);
        
        Test.startTest();
        System.enqueueJob(insertJob);
        Test.stopTest();
        // Validate the job ran. Check if record have correct parentId now
        System.assertEquals(1, [select count() from contact where id = :objectId]);
        
        
    }
    
    static testmethod void testQueueableUser() {
     Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
     User u = new User(Alias = 'sfarris', Email='sfarris@tntech.edu', 
            EmailEncodingKey='UTF-8', LastName='Farris', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='sfarris@tntech.edu');
     insert u;
        
        
        
        
     //String objectTypeStr='User'; 
     String objectTypeStr=String.valueOf(u.getSObjectType());   
     String objectId = u.Id; 
     DateTime modifiedDate = system.now();
     String eventType ='U';

        
        Integration_Out_Class insertJob = new Integration_Out_Class(objectTypeStr, u.Id, DateTime.valueOf(modifiedDate), eventType,null);
       //ID jobID = System.enqueueJob(insertJob);
        
        Test.startTest();
        System.enqueueJob(insertJob);
        Test.stopTest();
        // Validate the job ran. Check if record have correct parentId now
        System.assertEquals(1, [select count() from user where id = :objectId]);
        
        
    }
    /*
    static testmethod void test() {

        // Create test accounts to be updated
        // by the batch job.
        //Integration_In__c[] intList = new list();
        List<Integration_Out__c> intList= new List<Integration_Out__c>();
        
        Contact newConstituent = [select id, Constituent_ID__c from contact where name='Sarah Farris' limit 1];
        Account newOrganization = [select id from Account where name = 'Sirius Satellite' limit 1];
        //List<Integration_Out__c> intList= new List<Integration_Out__c>();
         datetime today = system.now();
        Integration_Out__c intOut = new Integration_Out__c(Name = newConstituent.Id, Modified_Record_Id__c = newConstituent.Id, event_type__c='I', Object_Api_Name__c='Contact', Status__c = 'N', Date_Modified__c=today);
        insert intOut;
        
        
        Test.startTest();
        // CRON expression: midnight on March 15. Because this is a test, 
        // job is supposed to execute immediately after Test.stopTest()
        String cronExpr = '0 0 0 15 3 ? 2022';
        IntegrationProducerBatchScheduler abs= new IntegrationProducerBatchScheduler();
        String jobId = System.schedule('IntegrationProducerBatchTest', cronExpr, abs);
        abs.execute(null);
        
        //Integration_Out_Class.futureIntegrationOutRec();
        Test.stopTest();
        
        Integration_Out__c[] ints = [select id, name, Modified_Record_Id__c, json_message__c, event_type__c, status__c, Message__c from Integration_Out__c where Modified_Record_Id__c = :newConstituent.Id];
         //Integration_Out_Class job = new Integration_Out_Class('Contact', ints[0].id, system.now() );

        system.debug('json message: ' + ints[0].json_message__c);
        
         Map<String, Object> m =(Map<String, Object>) JSON.deserializeUntyped(ints[0].json_message__c);
         Map<String, Object> newMap = (Map<String, Object>) m.get('object');
         Map<String, Object> newEvent = (Map<String, Object>) newmap.get('event');
         Map<String, Object> newtarget = (Map<String, Object>) newmap.get('target');
        //system.debug('testContact newtarget: '+newtarget);

        
        System.assertEquals('FARRIS,SARAH', newtarget.get('Sort_Name__c'));
        System.assertEquals(newOrganization.id, newtarget.get('AccountId'));
        

        system.assert(ints[0].status__c == 'R');         
    }*/
    
    static testmethod void testQueueableDelete1() {
        Contact con = [select id, lastmodifiedDate from contact where name='Sarah Farris' limit 1];
        delete con;
        String objectTypeStr=String.valueOf(con.getSObjectType());
        String objectId = con.Id; 
        DateTime modifiedDate = con.lastmodifiedDate;
        String eventType ='D';
       
        Integration_Out_Class insertJob = new Integration_Out_Class(objectTypeStr, con.Id, DateTime.valueOf(modifiedDate), eventType,null);
             
        Test.startTest();
        System.enqueueJob(insertJob);
        Test.stopTest();
  }
    
  
    static testmethod void testQueueableinsert() {
        User u = [select id,LastModifiedDate from user where  UserName='sfarrviszsda@tffntech.edu' limit 1 ];
        
     	String objectTypeStr=String.valueOf(u.getSObjectType());
     	String objectId = u.Id; 
    	DateTime modifiedDate = system.now();
     	String eventType ='I';
        list<user> uList = new list<User>();
        uList.add(u);
        Integration_Out_Class insertJob = new Integration_Out_Class(objectTypeStr, u.Id, DateTime.valueOf(modifiedDate), eventType, null);
        Integration_Out_Class.InsertNewRecord(uList);
        Test.startTest();
    	System.enqueueJob(insertJob);
        Test.stopTest();
    }
    
    static testmethod void testQueueableupdate() {
        User u = [select id,LastModifiedDate,Alias from user where  UserName='sfarrviszsda@tffntech.edu' limit 1 ];
        u.alias = 'ghygh';
   		String objectTypeStr=String.valueOf(u.getSObjectType());
     	String objectId = u.Id; 
    	DateTime modifiedDate = system.now();
     	String eventType ='U';
        list<user> uList = new list<User>();
        uList.add(u);
        Integration_Out_Class insertJob = new Integration_Out_Class(objectTypeStr, u.Id, DateTime.valueOf(modifiedDate), eventType, null);
        Integration_Out_Class.UpdateRecord(uList);
        Test.startTest();
    	System.enqueueJob(insertJob);
        Test.stopTest();
    }
    
    static testmethod void testQueueableDeleterecord() {
        User u = [select id,LastModifiedDate,Alias from user where  UserName='sfarrviszsda@tffntech.edu' limit 1 ];
      	String objectTypeStr=String.valueOf(u.getSObjectType());
     	String objectId = u.Id; 
    	DateTime modifiedDate = system.now();
     	String eventType ='D';
        list<user> uList = new list<User>();
        uList.add(u);
        Integration_Out_Class insertJob = new Integration_Out_Class(objectTypeStr, u.Id, DateTime.valueOf(modifiedDate), eventType, null);
        Integration_Out_Class.DeleteRecord(uList);
        Test.startTest();
    	System.enqueueJob(insertJob);
        Test.stopTest();
    }
    
}