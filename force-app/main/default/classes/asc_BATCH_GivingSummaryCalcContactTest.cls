@isTest
public class asc_BATCH_GivingSummaryCalcContactTest {

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
        Contact c2 = new Contact(accountid = a2.Id, ucinn_ascendv2__Donor_ID__c='0000000402', firstname = 'Sergei', lastname = 'Bobrovsky', ucinn_ascendv2__Personal_Email__c = 'bobs@panthersnhl.com', Constituent_Status__c ='A' );
        Contact c3 = new Contact(accountid = a3.Id, ucinn_ascendv2__Donor_ID__c='508', firstname = 'John', lastname = 'Stugotz', Constituent_Status__c='F', ucinn_ascendv2__Personal_Email__c='stuyougotz@meadowlark.com' );
        Contact c4 = new Contact(accountid = a3.Id, firstname = 'Dan', lastname = 'LeBatard', Constituent_Status__c='X', ucinn_ascendv2__Personal_Email__c='lebatard@espn.com');
        
        insert new List<Contact>{c, c2, c3, c4};
        //insert c;  
        
    }
      static testmethod void ReviewTransaction() {
          Contact newConstituent = [select id, ucinn_ascendv2__Donor_ID__c from contact where name='Sergei Bobrovsky' limit 1];
          //Contact newConstituent = [select id, ucinn_ascendv2__Donor_ID__c from contact where name='Sarah Farris' limit 1];
          //
          system.debug('donor id is '+newConstituent.ucinn_ascendv2__Donor_ID__c);
           Id clinicRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Comprehensive Campaign').getRecordTypeId();   
       
        Campaign newCampaign = new Campaign(
            Name = 'Test Campaign',  
            Status = 'Planned',
            RecordTypeId=clinicRecordTypeId,
            isActive=true
        );

        insert newCampaign;
          
        string json_message='{"object": {"event": {"event_id": 14,"event_modified_by": "'+newConstituent.ucinn_ascendv2__Donor_ID__c+'","event_sequence_number": "14","event_time": "01122024","event_type": "I","source_database": "lockbox gift","source_schema": "none","source_table": "gift"},"target": {"APPEAL_CODE": "00000","BATCH_ID": "676","CHECK_NUM": "00000000000001253","FILE_DATE": "01122024","GROUP_NUM": "05","ID_NUM": "'+newConstituent.ucinn_ascendv2__Donor_ID__c+'","ITEM_AMT": "0000005000","MESSAGE_STATUS": "in process","ND_UNIQUID": 14,"PROGRAM_CODE": "0802275","TRANS_ID": "005"}}}';
        Map<String, Object> m =(Map<String, Object>) JSON.deserializeUntyped(json_message);
        Map<String, Object> newmap = (Map<String, Object>) m.get('object');
        Map<String, Object> target = (Map<String, Object>) newmap.get('target');
        map<string, ucinn_ascendv2__Review_Transaction_v2__c> newJustRTV2 = new map<string, ucinn_ascendv2__Review_Transaction_v2__c>();
        
        ucinn_ascendv2__Review_Transaction_v2__c rt2 = lockboxGiftProcessing.processGift(target);
        newJustRTV2.put('rtv2 test', rt2);
        Database.insert(newJustRTV2.values(), false);
          List<ucinn_ascendv2__Review_Transaction_v2__c> rtv2 = [select id, ucinn_ascendv2__Contact__c, ucinn_ascendv2__Total_Transaction_Amount__c from ucinn_ascendv2__Review_Transaction_v2__c];
          system.debug('rtv2: '+rtv2);
        
        Test.startTest();
        asc_BATCH_GivingSummaryCalcContact batchInstance = new asc_BATCH_GivingSummaryCalcContact();
        Database.executeBatch(batchInstance);
        //Database.QueryLocator ql = batchInstance.start(null);
        //batchInstance.execute(null,newJustRTV2.values());
        Test.stopTest();
        /*  
        List<contact> con = [select id, ucinn_ascendv2__Lifetime_Fundraising__c from contact where id = :newConstituent.Id];
        system.assertEquals(5000.00, con[0].ucinn_ascendv2__Lifetime_Fundraising__c);*/
          system.assertEquals(50.00, rtv2[0].ucinn_ascendv2__Total_Transaction_Amount__c);
         
        
    }
}