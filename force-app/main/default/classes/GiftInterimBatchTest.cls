@isTest(SeeAllData=false)
private class GiftInterimBatchTest {
    @testSetup 
    static void setup() {
        recordtype GenType = [SELECT ID from recordtype where  DeveloperName ='General_Transaction' limit 1];
        ucinn_ascendv2__Review_Transaction_v2__c review = new ucinn_ascendv2__Review_Transaction_v2__c( 
        name = 'GNRL-0030785',
        nd_gift_source__c = 'Giving Form',
        In_Memory_of__c = 'tribute name',
        ND_Pipeline__c = 'GC',
        ucinn_ascendv2__Transaction_Type__c = 'Recurring Gift Payment',
        ucinn_ascendv2__First_Name__c = 'Dan',
        ucinn_ascendv2__Last_Name__c = 'LeBatard', 
        nd_data_source__c = 'HVG', 
        ucinn_ascendv2__Transaction_Date__c = Date.valueOf('2024-01-11'),
        ucinn_ascendv2__Tender_Type_1__c = 'Credit Card',
        ucinn_ascendv2__Opportunity_Type__c = 'Outright',
        ucinn_ascendv2__Send_to_G_L__c = true,
        ucinn_ascendv2__Payment_Amount_1_1__c =  50.00,
        ucinn_ascendv2__External_System_ID__c = 'GNRL-0030785',
        ucinn_ascendv2__Phone_1__c = '5742146989',
        ucinn_ascendv2__Phone_1_Type__c ='M',
        ucinn_ascendv2__Address_1_Line_1__c ='404 south st.',
        ucinn_ascendv2__City_1__c = 'New City',
        ucinn_ascendv2__State_1__c = 'New State',
        ucinn_ascendv2__Postal_Code_1__c = '45567',
        ucinn_ascendv2__Country_1__c ='US',
        nd_spouse_first_name__c = 'Mya',
        nd_spouse_last_name__c = 'Wife',
        ucinn_ascendv2__Email_1__c ='email@google.com',
        ucinn_ascendv2__Response__c = '{"subscription":{"state":"active","period":"monthly","length":"5","installment_number":"4","indefinite":false,"id":93343}}',
        RecordTypeId =GenType.id
                );
        insert review;
    }

    static testmethod void testNoSkip() {


        Test.startTest();
            Database.executeBatch(new GiftInterimBatch(),15);
        Test.stopTest();
        ucinn_ascendv2__Review_Transaction_v2__c rtv2 = [select id, name, ucinn_ascendv2__Status__c,   ucinn_ascendv2__Interim__c
        from ucinn_ascendv2__Review_Transaction_v2__c where name ='GNRL-0030785' limit 1];
		
        System.assert(rtv2.ucinn_ascendv2__Interim__c != null);
  
    }

}