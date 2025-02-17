@isTest(SeeAllData=false)
private class hivebriteGiftProcessTest {
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
    string json_message='{"object": {"event": {"event_id": "168339", "event_sequence_number": "772504","event_time": "21:44:44","event_type": "I","source_database": "hivebrite gift", "source_schema": "","source_table": "gift"},"target": {"AMOUNT": 100,"CAMPAIGN_ID": 2,"CURRENCY__CODE": "USD","CURRENCY__CREATED_AT": "2019-07-26 16:26:27.000","CURRENCY__ID": 2,"CURRENCY__NAME": "United States Dollar","CURRENCY__SYMBOL": "$","CURRENCY__UPDATED_AT": "2019-07-26 16:26:27.000","GIFT_DETAIL": [{"ALLOCATION_CODE": "UNRESTRICTED","AMOUNT": 100,"CAMPAIGN_ID": 2,"CUSTOM_FUND": "Dunne Hall Retreat and Spirituality Fund","FUND_ID": 527,"FUND_TITLE": "Other / Write-In"},{"ALLOCATION_CODE": "UNRESTRICTED","AMOUNT": 100,"CAMPAIGN_ID": 2,"CUSTOM_FUND": "Dunne Hall Retreat and Spirituality Fund","FUND_ID": 527,"FUND_TITLE": "Other / Write-In"},{"ALLOCATION_CODE": "UNRESTRICTED","AMOUNT": 100,"CAMPAIGN_ID": 2,"CUSTOM_FUND": "Dunne Hall Retreat and Spirituality Fund","FUND_ID": 527,"FUND_TITLE": "Other / Write-In"},{"ALLOCATION_CODE": "UNRESTRICTED","AMOUNT": 100,"CAMPAIGN_ID": 2,"CUSTOM_FUND": "Dunne Hall Retreat and Spirituality Fund","FUND_ID": 527,"FUND_TITLE": "Other / Write-In"},{"ALLOCATION_CODE": "UNRESTRICTED","AMOUNT": 100,"CAMPAIGN_ID": 2,"CUSTOM_FUND": "Dunne Hall Retreat and Spirituality Fund","FUND_ID": 527,"FUND_TITLE": "Other / Write-In"},{"ALLOCATION_CODE": "UNRESTRICTED","AMOUNT": 100,"CAMPAIGN_ID": 2,"CUSTOM_FUND": "Dunne Hall Retreat and Spirituality Fund","FUND_ID": 527,"FUND_TITLE": "Other / Write-In"}],"GIFT_IDS": "[185280]","HIST_ID": 772504,"ID": 588732,"IN_HONOR_OF": false,"IN_MEMORY_OF": false,"LIFELONG_PAYMENT_ENABLED": true,"MOBILE_PERSO": "15745144146","ON_BEHALF_OF": false,"ORDERS_FULL_KEY": "168339","ORDERS_SKEY": 944324512,"ORDER_BILLING_ADDRESS__ADDRESS_1": "1301 Brockton Ave","ORDER_BILLING_ADDRESS__ADDRESS_2": "203","ORDER_BILLING_ADDRESS__CITY": "Los Angeles","ORDER_BILLING_ADDRESS__COUNTRY": "US","ORDER_BILLING_ADDRESS__CREATED_AT": "2024-01-08 17:28:11.000","ORDER_BILLING_ADDRESS__ID": 8383221,"ORDER_BILLING_ADDRESS__POSTAL_CODE": "90066","ORDER_BILLING_ADDRESS__STATE": "CA","ORDER_BILLING_ADDRESS__UPDATED_AT": "2024-01-08 17:28:11.000","ORDER_CREATED_AT": "2024-01-08 17:28:11.000","ORDER_EMAIL": "adam.mazurek.j@gmail.com","ORDER_FIRSTNAME": "Adam","ORDER_HIST_EFFECTIVE_START_DTM": "2024-01-08 17:28:11.000","ORDER_HIST_RECORD_START_DTM": "2024-01-08 22:09:02.311","ORDER_ID": "168339","ORDER_LASTNAME": "Mazuewk","ORDER_SOURCE_PAYLOAD_MESSAGE_ID": 714541809,"PAYMENT_ACCOUNT_ID": 3,"PAYMENT_GATEWAY_INFORMATIONS__TRANSACTION__ID": "4s5w284r","PAYMENT_GATEWAY_INFORMATIONS__TRANSACTION__ORDER_ID": "client_4_1704734888_5eb29e","PAYMENT_GATEWAY_INFORMATIONS__TRANSACTION__PROCESSOR_AUTHORIZATION_CODE": "04298B","PAYMENT_STATUS": "paid","PERIODICITY": "none","PROMOTION_CODE": "04820","RECEIPTS_FULL_KEY": "588732","RECEIPTS_SKEY": 943995222,"RECEIPT_BILLING_ADDRESS__ADDRESS_1": "1301 Brockton Ave","RECEIPT_BILLING_ADDRESS__ADDRESS_2": "203","RECEIPT_BILLING_ADDRESS__CITY": "Los Angeles","RECEIPT_BILLING_ADDRESS__COUNTRY": "US","RECEIPT_BILLING_ADDRESS__CREATED_AT": "2024-01-08T17:28:11Z","RECEIPT_BILLING_ADDRESS__DEFAULT_BILLING_ADDRESS": false,"RECEIPT_BILLING_ADDRESS__ID": 8383222,"RECEIPT_BILLING_ADDRESS__POSTAL_CODE": "90066","RECEIPT_BILLING_ADDRESS__STATE": "CA","RECEIPT_BILLING_ADDRESS__UPDATED_AT": "2024-01-08 17:28:11.000","RECEIPT_CREATED_AT": "2024-01-08 17:28:10.000","RECEIPT_EMAIL": "adam.mazurek.j@gmail.com","RECEIPT_FIRSTNAME": "Adam","RECEIPT_HIST_EFFECTIVE_START_DTM": "2024-01-08 17:28:10.000","RECEIPT_HIST_RECORD_START_DTM": "2024-01-08 21:47:51.291","RECEIPT_ID": 588732,"RECEIPT_ITEMS": [{"fund_id": 527,"id": 699703,"product_id": 185280,"product_type": "Donation","quantity": 1,"total_price": "100.0","unit_price": "100.0","vat_name": null,"vat_rate": null}],"RECEIPT_NUMBER": "0004-235697","RECEIPT_SOURCE_PAYLOAD_MESSAGE_ID": 714619687,"RECIEPT_LASTNAME": "Mazuewk","RECURRING_PAYMENTS_LEFT": 2,"RECURRING_PAYMENT_ENABLED": false,"SEND_CONFIRMATION_EMAIL": true,"TOTAL_EXCL_TAX": 100,"TOTAL_INCL_TAX": 100,"UPDATED_AT": "2024-01-08 17:28:11.000","VAT_AMOUNT": 0}}}';
    Map<String, Object> m =(Map<String, Object>) JSON.deserializeUntyped(json_message);
    Map<String, Object> newmap = (Map<String, Object>) m.get('object');
    Map<String, Object> target = (Map<String, Object>) newmap.get('target');
    map<string, ucinn_ascendv2__Review_Transaction_v2__c> newJustRTV2 = new map<string, ucinn_ascendv2__Review_Transaction_v2__c>();
    Test.startTest();
    ucinn_ascendv2__Review_Transaction_v2__c rt2 = hivebriteGiftProcess.processGift(target);
    newJustRTV2.put('rtv2 test', rt2);
    Database.insert(newJustRTV2.values(), false);
    Test.stopTest();

    ucinn_ascendv2__Review_Transaction_v2__c rtv2 = [select id, nd_skip_interim__c, nd_process_message__c, nd_process_status__c, ucinn_ascendv2__First_Name__c,
    ucinn_ascendv2__Last_Name__c, ucinn_ascendv2__Address_1_Line_1__c, ucinn_ascendv2__Country_1__c, ucinn_ascendv2__State_1__c, ucinn_ascendv2__City_1__c, ucinn_ascendv2__Postal_Code_1__c,
    ucinn_ascendv2__Address_1_Type__c, ucinn_ascendv2__Email_1__c, ucinn_ascendv2__Email_1_Type__c from ucinn_ascendv2__Review_Transaction_v2__c where nd_gift_source_id__c = '168339' limit 1];
   
    System.assert(rtv2.nd_skip_interim__c == false);
    System.assert(rtv2.nd_process_message__c == null);
    System.assert(rtv2.nd_process_status__c == 'New');

    // Add more assertions for other fields as needed
}
}