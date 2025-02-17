@isTest(SeeAllData=false)

public class IntegrationProducerBatchRestTest {
    @testSetup
    static void setup(){
        
		Account a = new Account(name='Sirius Satellite');
        Account a2 = new Account(name='EMPLOYER IN NAME ONLY');
        Account a3 = new Account(name='Pirate Radio');
        insert new List<Account>{a, a2, a3};
        //Account newOrganization = [select id from Account where name = 'Sirius Satellite' limit 1];
         
        Contact c = new Contact(accountid = a.Id, firstname = 'Sarah', lastname = 'Farris' , Email='sfarris@ttech.edu', Constituent_Status__c='A');
        Contact c2 = new Contact(accountid = a2.Id, firstname = 'Danuel', lastname = 'House' , Email='dhouse@gmail.com', Constituent_Status__c='A' );
        Contact c3 = new Contact(accountid = a3.Id, firstname = 'John', lastname = 'Stugotz' , Email='stuyougotz@espn.com', Constituent_Status__c='A');
        Contact c4 = new Contact(accountid = a3.Id, firstname = 'Dan', lastname = 'LeBatard', Email='lebatard@espn.com', Constituent_Status__c='A');
        
        insert new List<Contact>{c, c2, c3, c4};        
  
        
    	 
    }
    static testMethod void testPost()
    {    
        //Test.setMock(HttpCalloutMock.class, new MockRespGenProducerBatchRest());

         		List<Integration_Out__c> intList= new List<Integration_Out__c>();
        
        Contact newConstituent = [select id from contact where name='Sarah Farris' limit 1];
        Account newOrganization = [select id from Account where name = 'Sirius Satellite' limit 1];
        //List<Integration_Out__c> intList= new List<Integration_Out__c>();
         datetime today = system.now();
        Integration_Out__c intOut = new Integration_Out__c(Name = newConstituent.Id, Modified_Record_Id__c = newConstituent.Id, event_type__c='I', Object_Api_Name__c='Contact', Status__c = 'N', Date_Modified__c=today);
        insert intOut;
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Integration_out'; 
        req.addParameter('long_data', 'false');
        req.addParameter('batch_size', '200');
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json'); 

        RestContext.request = req;
        id batchid = IntegrationProducerBatchRest.execute();
        
        RestContext.response = res;
		//res = RestContext.response; //Set the response here
        

        Test.stopTest();
        
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
      TotalJobItems, CreatedBy.Email
      FROM AsyncApexJob WHERE Id =
      :batchid];
        
        system.debug('a.status - '+ a.status);
        system.debug('a.NumberOfErrors'+a.NumberOfErrors);
        System.assertEquals('Completed', a.status);
        System.assertEquals(0, a.NumberOfErrors);

        //System.assertEquals(0, [select count() from Integration_Out__c]);
        //Integration_Out__c[] ints = [select count() from Integration_Out__c];
        /*
        system.debug('res - '+res);
        System.assertEquals(200, res.statusCode);
*/
        
        
    }

}