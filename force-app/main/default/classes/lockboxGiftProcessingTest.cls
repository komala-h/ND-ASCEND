@isTest(SeeAllData=false)
private class lockboxGiftProcessingTest {
    @testSetup 
    static void setup() {
		/** The code in this section will create test records only once
		 *  The test data can then be used by multiple test methods in
		 *  this test class
		 */
        Account a = new Account(name='Sirius Satellite');
        Account a2 = new Account(name='EMPLOYER IN NAME ONLY');
        Account a3 = new Account(name='University Of Notre Dame', ucinn_ascendv2__Donor_ID__c='307129',institution_code__c='184100');
        insert new List<Account>{a, a2, a3};
        //Account newOrganization = [select id from Account where name = 'Sirius Satellite' limit 1];
         
        Contact c = new Contact(accountid =   a.Id, ucinn_ascendv2__Donor_ID__c='38', ucinn_ascendv2__External_System_ID__c='sfarris38', firstname = 'Sarah', lastname = 'Farris', ucinn_ascendv2__Personal_Email__c='sfarris@ttech.edu', Constituent_Status__c='A');
        Contact c2 = new Contact(accountid = a2.Id, ucinn_ascendv2__Donor_ID__c='402', firstname = 'Danuel', lastname = 'House', ucinn_ascendv2__Personal_Email__c = 'house@uci.com', Constituent_Status__c ='A' );
        Contact c3 = new Contact(accountid = a3.Id, ucinn_ascendv2__Donor_ID__c='508', firstname = 'John', lastname = 'Stugotz', Constituent_Status__c='F', ucinn_ascendv2__Personal_Email__c='stuyougotz@meadowlark.com' );
        Contact c4 = new Contact(accountid = a3.Id, firstname = 'Dan', lastname = 'LeBatard', Constituent_Status__c='X', ucinn_ascendv2__Personal_Email__c='lebatard@espn.com');
       

        recordtype appealType = [SELECT ID from recordtype where  DeveloperName ='Appeal' limit 1];
        recordtype CampaignType = [SELECT ID from recordtype where  DeveloperName ='Comprehensive_Campaign' limit 1];

        Campaign cmpn01 = new Campaign();
        cmpn01.Name = 'TEST CAMPAIGN 01';
        cmpn01.nd_appeal_code__c ='05778';
        cmpn01.RecordTypeId = appealType.id;
        cmpn01.isActive =True;
        insert cmpn01;

        Campaign cmpn02 = new Campaign();
        cmpn02.Name = 'For Good';
        cmpn02.RecordTypeId = CampaignType.id;
        cmpn02.isActive =True;
        insert cmpn02;
    }

static testmethod void testLBCreateWithoutDonorID() {
    string json_message='{"object": {"event": {"event_id": 14,"event_modified_by": "9999999999","event_sequence_number": "14","event_time": "01122024","event_type": "I","source_database": "lockbox gift","source_schema": "none","source_table": "gift"},"target": {"APPEAL_CODE": "00000","BATCH_ID": "676","CHECK_NUM": "00000000000001253","FILE_DATE": "01122024","GROUP_NUM": "05                      ","ID_NUM": "9999999999","ITEM_AMT": "0000005000","MESSAGE_STATUS": "in process","ND_UNIQUID": 14,"PROGRAM_CODE": "0802275","TRANS_ID": "005"}}}';
    Map<String, Object> m =(Map<String, Object>) JSON.deserializeUntyped(json_message);
    Map<String, Object> newmap = (Map<String, Object>) m.get('object');
    Map<String, Object> target = (Map<String, Object>) newmap.get('target');
    map<string, ucinn_ascendv2__Review_Transaction_v2__c> newJustRTV2 = new map<string, ucinn_ascendv2__Review_Transaction_v2__c>();

    Test.startTest();
    ucinn_ascendv2__Review_Transaction_v2__c rt2 = lockboxGiftProcessing.processGift(target);
    newJustRTV2.put('rtv2 test', rt2);
    Database.insert(newJustRTV2.values(), false);
    Test.stopTest();

    ucinn_ascendv2__Review_Transaction_v2__c rtv2 = [select id, nd_skip_interim__c, nd_process_message__c, nd_process_status__c, ucinn_ascendv2__First_Name__c,
    ucinn_ascendv2__Last_Name__c, nd_gift_source__c, nd_appeal__c, nd_data_source__c, ucinn_ascendv2__Contact__c,
    nd_appeal_code__c from ucinn_ascendv2__Review_Transaction_v2__c where nd_lockbox_batch_id__c ='676' limit 1];
   
    System.assert(rtv2.nd_skip_interim__c == true);
    System.assert(rtv2.nd_gift_source__c == 'Lockbox');
    System.assert(rtv2.nd_data_source__c == 'LBX');
    System.assert(rtv2.nd_appeal__c == null);
    System.debug(rtv2.nd_process_message__c );
    //System.assert(rtv2.nd_process_message__c == 'No donor id in Lockbox file ');


  
}

static testmethod void testLBCreateWithDonorID() {
    string json_message='{"object": {"event": {"event_id": 14,"event_modified_by": "38","event_sequence_number": "14","event_time": "01122024","event_type": "I","source_database": "lockbox gift","source_schema": "none","source_table": "gift"},"target": {"APPEAL_CODE": "00000","BATCH_ID": "677","CHECK_NUM": "00000000000001253","FILE_DATE": "01122024","GROUP_NUM": "05                      ","ID_NUM": "0000000508","ITEM_AMT": "0000005000","MESSAGE_STATUS": "in process","ND_UNIQUID": 14,"PROGRAM_CODE": "0802275","TRANS_ID": "005"}}}';
    Map<String, Object> m =(Map<String, Object>) JSON.deserializeUntyped(json_message);
    Map<String, Object> newmap = (Map<String, Object>) m.get('object');
    Map<String, Object> target = (Map<String, Object>) newmap.get('target');
    map<string, ucinn_ascendv2__Review_Transaction_v2__c> newJustRTV2 = new map<string, ucinn_ascendv2__Review_Transaction_v2__c>();

    Test.startTest();
    ucinn_ascendv2__Review_Transaction_v2__c rt2 = lockboxGiftProcessing.processGift(target);
    newJustRTV2.put('rtv2 test', rt2);
    Database.insert(newJustRTV2.values(), false);
    Test.stopTest();

    ucinn_ascendv2__Review_Transaction_v2__c rtv2 = [select id, nd_skip_interim__c, nd_process_message__c, nd_process_status__c, ucinn_ascendv2__First_Name__c,
    ucinn_ascendv2__Last_Name__c, nd_gift_source__c, nd_appeal__c, nd_data_source__c, ucinn_ascendv2__Contact__c,
    nd_appeal_code__c from ucinn_ascendv2__Review_Transaction_v2__c where nd_lockbox_batch_id__c ='677' limit 1];
   
    System.assert(rtv2.nd_skip_interim__c == true);
    System.assert(rtv2.nd_gift_source__c == 'Lockbox');
    System.assert(rtv2.nd_data_source__c == 'LBX');
    System.assert(rtv2.nd_appeal__c == null);
    System.debug(rtv2.nd_process_message__c );
    System.debug(rtv2.ucinn_ascendv2__Contact__c );

    //System.assert(rtv2.nd_process_message__c == 'No donor id in Lockbox file ');


  
}

}