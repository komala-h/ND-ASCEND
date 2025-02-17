@isTest(SeeAllData=false)
private class mobilecauseGiftProcessTest {
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
        /*
        insert new List<Contact>{c, c2, c3, c4};
        //insert c;  
        List<Integration_In__c> intList= new List<Integration_In__c>();
        Integration_In__c i2 = new Integration_In__c(json_message__c='{"object": {"event": {"event_id": "008108742629","event_modified_by": "Rosanna Henry (rmh825@gmail.com)","event_sequence_number": "79","event_time": "2024-01-08 21:50:00.000","event_type": "I","source_database": "mobilecause gift","source_schema": "none","source_table": "gift"},"target": {"BILLING_TRANSACTION": "008108742629","account": "University of Notre Dame","account_id": "2927","account_plan": "Paid","account_plan_price": "$499.00","activity_id": "208153","anonymous": "No","appeal_code": "05961","billing_response_code": "00","billing_status": "settled","billing_transaction_reference": "00890D","billing_type": "sale","campaign_name": "Bengal Bouts FY24","cc_expiration": "11/26","cc_type": "Visa","city": "Canonsburg","collected_amount": "$100.00","country": "US","discount": "$0.00","donation": "163024079","donation_amount": "$100.00","donation_date": "01/08/2024 16:49","email": "rmh825@gmail.com","entity_source_code": "BGB","first_name": "Rosanna","fmv_(fair_market_value)": "$0.00","form": "Online Form (Donation)","form_id": "403918","form_name": "Online Form","form_payment_type": "payment","form_type": "donation","frequency": "One Time","fulfillment_texts": "0","fund_allocation": "BENGAL BOUTS EXP","gsf_campaign_id": "130812","gsf_donor_id": "64709317","gsf_notes": "Online Form - Bengal on 71777 for Bengal Bouts FY24","ip_address": "2601:540:ca00:ae80:99f1:fa8a:9387:39d9","item_amount_collected": "$0.00","keyword": "Bengal55","last_4": "3049","last_name": "Henry","payment_gateway": "CardConnect","payment_method": "Card","phone": "14127192203","pledged_amount": "$100.00","processing_fee": "$0.00","shortcode": "71777","solicit_name": "Crowdfunding","source": "Paid via Mobile Web (Pledging)","state": "PA","street_address": "105 Enclave Dr","sub_solicit_name": "donation","tax_deductible_amt": "$100.00","ticket_amount_collected": "$0.00","transaction_date": "01/08/2024 16:50","transaction_id": "15473403","transaction_updated_at": "01/09/2024 12:34","type": "Crowdfunding","volunteer_fundraiser": "Sean Mullen","what_is_your_primary_relationship_with_notre_dame?": "Friend","what_is_your_primary_relationship_with_notre_dame?_(label)": "Friend","zip": "15317"}}}}');
        intList.add(i2);
        insert intList; */
    }

static testmethod void testLBCreate() {
    string json_message='{"object": {"event": {"event_id": "008108742629","event_modified_by": "Rosanna Henry (rmh825@gmail.com)","event_sequence_number": "79","event_time": "2024-01-08 21:50:00.000","event_type": "I","source_database": "mobilecause gift","source_schema": "none","source_table": "gift"},"target": {"BILLING_TRANSACTION": "008108742629","account": "University of Notre Dame","account_id": "2927","account_plan": "Paid","account_plan_price": "$499.00","activity_id": "208153","anonymous": "No","appeal_code": "05961","billing_response_code": "00","billing_status": "settled","billing_transaction_reference": "00890D","billing_type": "sale","campaign_name": "Bengal Bouts FY24","cc_expiration": "11/26","cc_type": "Visa","city": "Canonsburg","collected_amount": "$100.00","country": "US","discount": "$0.00","donation": "163024079","donation_amount": "$100.00","donation_date": "01/08/2024 16:49","email": "rmh825@gmail.com","entity_source_code": "BGB","first_name": "Rosanna","fmv_(fair_market_value)": "$0.00","form": "Online Form (Donation)","form_id": "403918","form_name": "Online Form","form_payment_type": "payment","form_type": "donation","frequency": "One Time","fulfillment_texts": "0","fund_allocation": "BENGAL BOUTS EXP","gsf_campaign_id": "130812","gsf_donor_id": "64709317","gsf_notes": "Online Form - Bengal on 71777 for Bengal Bouts FY24","ip_address": "2601:540:ca00:ae80:99f1:fa8a:9387:39d9","item_amount_collected": "$0.00","keyword": "Bengal55","last_4": "3049","last_name": "Henry","payment_gateway": "CardConnect","payment_method": "Card","phone": "14127192203","pledged_amount": "$100.00","processing_fee": "$0.00","shortcode": "71777","solicit_name": "Crowdfunding","source": "Paid via Mobile Web (Pledging)","state": "PA","street_address": "105 Enclave Dr","sub_solicit_name": "donation","tax_deductible_amt": "$100.00","ticket_amount_collected": "$0.00","transaction_date": "01/08/2024 16:50","transaction_id": "15473403","transaction_updated_at": "01/09/2024 12:34","type": "Crowdfunding","volunteer_fundraiser": "Sean Mullen","what_is_your_primary_relationship_with_notre_dame?": "Friend","what_is_your_primary_relationship_with_notre_dame?_(label)": "Friend","zip": "15317"}}}}';
    Map<String, Object> m =(Map<String, Object>) JSON.deserializeUntyped(json_message);
    Map<String, Object> newmap = (Map<String, Object>) m.get('object');
    Map<String, Object> target = (Map<String, Object>) newmap.get('target');
    map<string, ucinn_ascendv2__Review_Transaction_v2__c> newJustRTV2 = new map<string, ucinn_ascendv2__Review_Transaction_v2__c>();
    Test.startTest();
    ucinn_ascendv2__Review_Transaction_v2__c rt2 = mobilecauseGiftProcess.processGift(target);
    newJustRTV2.put('rtv2 test', rt2);
    Database.insert(newJustRTV2.values(), false);
    Test.stopTest();

    ucinn_ascendv2__Review_Transaction_v2__c rtv2 = [select id, nd_skip_interim__c, nd_process_message__c, nd_process_status__c, ucinn_ascendv2__First_Name__c,
    ucinn_ascendv2__Last_Name__c, ucinn_ascendv2__Address_1_Line_1__c, ucinn_ascendv2__Country_1__c, ucinn_ascendv2__State_1__c, ucinn_ascendv2__City_1__c, ucinn_ascendv2__Postal_Code_1__c,
    ucinn_ascendv2__Address_1_Type__c, ucinn_ascendv2__Email_1__c, ucinn_ascendv2__Email_1_Type__c from ucinn_ascendv2__Review_Transaction_v2__c where ucinn_ascendv2__First_Name__c = 'Rosanna' limit 1];
   
    System.assert(rtv2.nd_skip_interim__c == false);
    System.assert(rtv2.nd_process_message__c == null);
    System.assert(rtv2.nd_process_status__c == 'New');

    // Add more assertions for other fields as needed
}
}