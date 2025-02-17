@isTest(SeeAllData=false)
private class PicklistSyncBatchTest {
     @testSetup 
    static void setup() {
		/** The code in this section will create test records only once
		 *  The test data can then be used by multiple test methods in
		 *  this test class
		 */
		Account a = new Account(name='Sirius Satellite');
        Account a2 = new Account(name='EMPLOYER IN NAME ONLY');
        Account a3 = new Account(name='Pirate Radio');
        insert new List<Account>{a, a2, a3};

        Contact c = new Contact(accountid = a.Id, firstname = 'Sarah', lastname = 'Farris', ucinn_ascendv2__Personal_Email__c = 'sfarris@uci.com', Constituent_Status__c ='A');
        Contact c2 = new Contact(accountid = a2.Id, firstname = 'Danuel', lastname = 'House', ucinn_ascendv2__Personal_Email__c = 'house@uci.com', Constituent_Status__c ='A' );
        /*
        insert new List<Contact>{c, c2};
        //insert c;  
        nd_picklist__c ndp = new nd_picklist__c(description__c='first_test', field_api_name__c='first_test', object_api_name__c='Account', code__c='OT',unique_id__c = 'accountfirst_testOT');
         insert ndp;*/
        
    }
    
    static testmethod void test() {
        Test.setMock(WebServiceMock.class, new MockResponseforMetadataApiCalls());

        nd_picklist__c ndp = new nd_picklist__c(description__c='this_test', field_api_name__c='this_test', unique_id__c='123',object_api_name__c='Account', code__c='TT');
        insert ndp;
        
        //this is where you need to create  picklist value using metadata api?
        test.starttest();
              PicklistSyncBatch u = new PicklistSyncBatch(); 
        list<string> input = u.objNames;
        u.objNames = new list<string>{'Account'};
                 database.executebatch(u, 1);
        test.stoptest();
        
        system.assert( [select count() from nd_picklist__c ] > 1);
        
    }
   
    // static testmethod void testGlobals() {
    //     Test.setMock(WebServiceMock.class, new MockResponseforMetadataApiCalls());

    //     nd_picklist__c ndp = new nd_picklist__c(description__c='this_test', field_api_name__c='this_test', unique_id__c='123',object_api_name__c='Contact', code__c='TT');
    //     insert ndp;
        
    //     //this is where you need to create  picklist value using metadata api?
    //     test.starttest();
    //           PicklistSyncBatch u = new PicklistSyncBatch(); 
    //     list<string> input = u.objNames;
    //     u.objNames = new list<string>{'Contact'};
    //              database.executebatch(u, 1);
    //     test.stoptest();
        
    //     system.assert( [select count() from nd_picklist__c ] > 1);
        
    // }
   
    static testmethod void testupdate() {
        Test.setMock(WebServiceMock.class, new MockResponseforMetadataApiCalls());

        nd_picklist__c ndp = new nd_picklist__c(description__c='2018 Freshman ', unique_id__c='123',field_api_name__c='Source_Code__c', object_api_name__c='Account', code__c='P18');
        insert ndp;
        
        
        
        test.starttest();
              PicklistSyncBatch u = new PicklistSyncBatch(); 
        u.objNames = new list<string>{'Account'};
                 database.executebatch(u, 1);
        test.stoptest();
        
        system.assert( [select count() from nd_picklist__c ] > 1);
        
    }
 /** doesnt work  
 static testmethod void testBatchableGreaterThan() {
       Test.setMock(WebServiceMock.class, new MockResponseforMetadataApiCalls());

       nd_picklist__c ndp = new nd_picklist__c(description__c='this_test', field_api_name__c='this_test', object_api_name__c='Account', code__c='TT');
       insert ndp;
     
       test.starttest();
       List<nd_picklist__c> intList= new List<nd_picklist__c>();    
       for (Integer i=0;i<10000;i++) {
           nd_picklist__c ii = new nd_picklist__c(
                                   description__c='this test_'+i+'_', 
                                   field_api_name__c='this_test_'+i+'_',
                                   object_api_name__c='Account', 
                                   code__c='TT_'+i+'_'
                                   );

           intList.add(ii);
       }
        upsert intList;
        
        //this is where you need to create  picklist value using metadata api?
        
              PicklistSyncBatch u = new PicklistSyncBatch(); 
        u.objNames = new list<string>{'Account'};
                 database.executebatch(u, 1);
        test.stoptest();
        //system.debug('nd_picklist__c.size() : '+nd_picklist__c.size());
        system.assert( [select count() from nd_picklist__c ] >= 10001);
  
    }    */
   /*
    static testmethod void testSchedule() {
        test.starttest();
        SchedulePicklistSyncBatch();
        
        test.stoptest();
        
    }*/
}