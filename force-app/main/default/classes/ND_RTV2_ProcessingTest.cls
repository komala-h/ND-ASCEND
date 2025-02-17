@isTest(SeeAllData=false)
private class ND_RTV2_ProcessingTest {
    @testSetup 
    static void setup() {
        recordtype GenType = [SELECT ID from recordtype where  DeveloperName ='General_Transaction' limit 1];
        Account a3 = new Account(name='University Of Notre Dame', ucinn_ascendv2__Donor_ID__c='307129',institution_code__c='184100');
        insert  a3;
        Contact c3 = new Contact(accountid = a3.Id, firstname = 'First', lastname = 'Wife', Constituent_Status__c='X', ucinn_ascendv2__Personal_Email__c='fwife@espn.com', ucinn_ascendv2__Contact_Type__c = 'AL'); 
        insert c3;
        Contact c4 = new Contact(accountid = a3.Id, firstname = 'Dan', lastname = 'LeBatard', Constituent_Status__c='X', ucinn_ascendv2__Personal_Email__c='lebatard@espn.com', ucinn_ascendv2__Contact_Type__c = 'AL', ucinn_ascendv2__Preferred_Spouse__c = c3.id); 
        insert c4;

        recordtype appealType = [SELECT ID from recordtype where  DeveloperName ='Appeal' limit 1];

        ucinn_ascendv2__Academic_Organization__c sub = new ucinn_ascendv2__Academic_Organization__c(
            name = 'Central Financial Management',
            ucinn_ascendv2__Type__c = 'desig_sub-dept',
            ucinn_ascendv2__Code__c = 'S288',
            ucinn_ascendv2__External_System_ID__c = 'J5;S288;'
        );
        insert sub;
        
        ucinn_ascendv2__Designation__c des = new ucinn_ascendv2__Designation__c(
            name ='UNRESTRICTED',
            ucinn_ascendv2__External_System_ID__c ='UNRESTRICTED',
            ucinn_ascendv2__G_L_Account__c = '100000-58050-59003-99000',
            ucinn_ascendv2__G_L_Acknowledgement_Description__c = 'The Notre Dame Fund',
            ucinn_ascendv2__G_L_FASB_Type__c = '1',
            ucinn_ascendv2__G_L_Effective_Date__c = Date.valueOf('1987-09-08'),
            Purpose__c = 'U0001',
            ucinn_ascendv2__CASE_Type__c = 'CU',
            Unrestricted_Type__c = 'UNIVUNR',
            Flex_Indicator__c = 'UNV',
            Sub_Department__c = sub.id

        );
        insert des;

        Campaign cmpn01 = new Campaign();
        cmpn01.Name = 'TEST CAMPAIGN 01';
        cmpn01.ucinn_ascendv2__Motivation_Code__c ='05778';
        cmpn01.RecordTypeId = appealType.id;
        cmpn01.isActive =True;
        cmpn01.StartDate = Date.valueOf('2014-01-11');
        cmpn01.gift_processing_note__c = 'Test';
        insert cmpn01;

        ucinn_ascendv2__Review_Transaction_v2__c review = new ucinn_ascendv2__Review_Transaction_v2__c( 
        name = 'GNRL-0030785',
        ucinn_ascendv2__First_Name__c = 'Dan',
        ucinn_ascendv2__Last_Name__c = 'LeBatard', 
        nd_data_source__c = 'HVG', 
        ND_Pipeline__c = 'OT', 
        ucinn_ascendv2__Transaction_Date__c = Date.valueOf('2024-01-11'),
        ucinn_ascendv2__Tender_Type_1__c = 'Credit Card',
        ucinn_ascendv2__Transaction_Type__c ='Gift',
        ucinn_ascendv2__Opportunity_Type__c = 'Outright',
        ucinn_ascendv2__Send_to_G_L__c = true,
        ucinn_ascendv2__Payment_Amount_1_1__c =  50.00,
        ucinn_ascendv2__Total_Transaction_Amount__c = 50.00,
        ucinn_ascendv2__External_System_ID__c = 'GNRL-0030785',
        ucinn_ascendv2__Designation_1__c = des.id,
        ucinn_ascendv2__Designation_External_ID_1__c = 'UNRESTRICTED',
        ucinn_ascendv2__Contact__c =  c4.id,
        ucinn_ascendv2__Hard_and_Soft_Credit_Contact_1_1__c = c4.id,
        RecordTypeId =GenType.id
                );
        insert review;
        ucinn_ascendv2__Review_Transaction_v2__c review2 = new ucinn_ascendv2__Review_Transaction_v2__c( 
            name = 'GNRL-9930785',
            ucinn_ascendv2__First_Name__c = 'Test',
            ucinn_ascendv2__Last_Name__c = 'Number2', 
            nd_data_source__c = 'HVG', 
            ND_Pipeline__c = 'OT', 
            ucinn_ascendv2__Transaction_Date__c = Date.valueOf('2024-01-11'),
            ucinn_ascendv2__Tender_Type_1__c = 'Credit Card',
            ucinn_ascendv2__Transaction_Type__c ='Gift',
            ucinn_ascendv2__Opportunity_Type__c = 'Outright',
            ucinn_ascendv2__Send_to_G_L__c = true,
            ucinn_ascendv2__Payment_Amount_1_1__c =  50.00,
            ucinn_ascendv2__Total_Transaction_Amount__c = 50.00,
            ucinn_ascendv2__External_System_ID__c = 'GNRL-9930785',
            ucinn_ascendv2__Designation_External_ID_1__c = 'UNRESTRICTEDTESTS',
            ucinn_ascendv2__Contact__c =  c4.id,
            RecordTypeId =GenType.id
                    );
            insert review2;
    }

    static testmethod void testNoGiftGroup() {


        Test.startTest();
            Database.executeBatch(new ND_RTV2_Processing(),15);
        Test.stopTest();

        ucinn_ascendv2__Review_Transaction_v2__c rtv2 = [select id, name, ucinn_ascendv2__Status__c,   nd_gift_group__c, nd_process_status__c from ucinn_ascendv2__Review_Transaction_v2__c where name ='GNRL-0030785' limit 1];
       // System.debug(rtv2);
        System.assert(rtv2.nd_process_status__c =='Done');
  
    }

    static testmethod void testBadAppeal() {


        Test.startTest();
        ucinn_ascendv2__Review_Transaction_v2__c rtv2a = [select id, name, ucinn_ascendv2__Status__c,   nd_gift_group__c, nd_Appeal__c, ucinn_ascendv2__Total_Transaction_Amount__c,
        nd_process_status__c, nd_appeal_code__c, ucinn_ascendv2__Designation_1__c from ucinn_ascendv2__Review_Transaction_v2__c where name ='GNRL-0030785' limit 1];
        rtv2a.nd_appeal_code__c = '000000000';
        rtv2a.ucinn_ascendv2__Total_Transaction_Amount__c = 20000.00;
        rtv2a.ucinn_ascendv2__Designation_1__c = null;

        update rtv2a;
            Database.executeBatch(new ND_RTV2_Processing(),15);
        Test.stopTest();

        ucinn_ascendv2__Review_Transaction_v2__c rtv2 = [select id, name, ucinn_ascendv2__Status__c,   nd_gift_group__c, nd_process_status__c, nd_appeal_code__c , nd_Appeal__c
        from ucinn_ascendv2__Review_Transaction_v2__c where name ='GNRL-0030785' limit 1];
        //System.debug(rtv2);
        System.assert(rtv2.nd_process_status__c =='Error');
    }


    static testmethod void testWithComments() {


        Test.startTest();
        Campaign app = [select id from Campaign where ucinn_ascendv2__Motivation_Code__c ='05778' limit 1]; 
        ucinn_ascendv2__Review_Transaction_v2__c rtv2a = [select id, name, ucinn_ascendv2__Status__c,   nd_gift_group__c, nd_gift_comment__c, ND_Pipeline__c,
        nd_process_status__c, nd_appeal_code__c from ucinn_ascendv2__Review_Transaction_v2__c where name ='GNRL-0030785' limit 1];
        rtv2a.nd_gift_comment__c = 'gift comment';
        rtv2a.ND_Pipeline__c = 'CF';
        rtv2a.nd_appeal_code__c = '05778';
        rtv2a.nd_Appeal__c = app.id;
        //System.debug('rtv2a ' + rtv2a);
        update rtv2a;
            Database.executeBatch(new ND_RTV2_Processing(),15);
        Test.stopTest();

        ucinn_ascendv2__Review_Transaction_v2__c rtv2 = [select id, name, ucinn_ascendv2__Status__c,   nd_gift_group__c, nd_process_status__c, nd_appeal_code__c , nd_Appeal__c
        from ucinn_ascendv2__Review_Transaction_v2__c where name ='GNRL-0030785' limit 1];
        //System.debug(rtv2);
        System.assert(rtv2.nd_process_status__c =='Done');
    }

    static testmethod void testNR() {


        Test.startTest();
        ucinn_ascendv2__Review_Transaction_v2__c rtv2a = [select id, name, ucinn_ascendv2__Status__c,   nd_gift_group__c, nd_gift_comment__c, ND_Pipeline__c,
        nd_process_status__c, nd_appeal_code__c from ucinn_ascendv2__Review_Transaction_v2__c where name ='GNRL-0030785' limit 1];
        rtv2a.ND_Pipeline__c = 'CF';
        rtv2a.ucinn_ascendv2__Total_Transaction_Amount__c = null;
        rtv2a.ucinn_ascendv2__Hard_Soft_Credit_Contact_External_ID_1_1__c = '4534';
        rtv2a.nd_appeal_code__c = '000000000';
        rtv2a.ucinn_ascendv2__Tender_Type_1__c = null;

       // System.debug('rtv2a ' + rtv2a);
        update rtv2a;
            Database.executeBatch(new ND_RTV2_Processing(),15);
        Test.stopTest();

        ucinn_ascendv2__Review_Transaction_v2__c rtv2 = [select id, name, ucinn_ascendv2__Status__c,   nd_gift_group__c, nd_process_status__c, nd_appeal_code__c , nd_Appeal__c
        from ucinn_ascendv2__Review_Transaction_v2__c where name ='GNRL-0030785' limit 1];
       // System.debug(rtv2);
        System.assert(rtv2.nd_process_status__c =='Done');
    }


    static testmethod void testBusiness() {



        Test.startTest();
        Account a1 = [select id from Account limit 1];

        ucinn_ascendv2__Review_Transaction_v2__c rtv2a = [select id, name, ucinn_ascendv2__Status__c, nd_gift_comment__c, ND_Pipeline__c, ucinn_ascendv2__Contact__c,
        nd_process_status__c, nd_appeal_code__c from ucinn_ascendv2__Review_Transaction_v2__c where name ='GNRL-0030785' limit 1];
        rtv2a.ND_Pipeline__c = 'CF';
        rtv2a.nd_appeal_code__c = '000000000';
        rtv2a.ucinn_ascendv2__Tender_Type_1__c = null;
        rtv2a.ucinn_ascendv2__Hard_and_Soft_Credit_Contact_1_1__c = rtv2a.ucinn_ascendv2__Contact__c;
        rtv2a.ucinn_ascendv2__Account__c = a1.id; 
        System.debug('testBusiness rtv2a ' + rtv2a);
        update rtv2a;
            Database.executeBatch(new ND_RTV2_Processing(),15);
        Test.stopTest();

        ucinn_ascendv2__Review_Transaction_v2__c rtv2 = [select id, name, ucinn_ascendv2__Status__c,   nd_gift_group__c, nd_process_status__c, nd_appeal_code__c , nd_Appeal__c
        from ucinn_ascendv2__Review_Transaction_v2__c where name ='GNRL-0030785' limit 1];
        //System.debug(rtv2);
        System.assert(rtv2.nd_process_status__c =='New');
    }

    static testmethod void testBusinessNoBDonor() {



        Test.startTest();
        Account a1 = [select id from Account limit 1];
        ucinn_ascendv2__Review_Transaction_v2__c rtv2a = [select id, name, ucinn_ascendv2__Status__c, nd_gift_comment__c, ND_Pipeline__c, ucinn_ascendv2__Hard_and_Soft_Credit_Contact_1_1__c,
        nd_process_status__c, nd_appeal_code__c from ucinn_ascendv2__Review_Transaction_v2__c where name ='GNRL-9930785' limit 1];
        rtv2a.ucinn_ascendv2__Account__c = a1.id; 
        System.debug(' testBusinessNoBDonor rtv2a ' + rtv2a);
        update rtv2a;
            Database.executeBatch(new ND_RTV2_Processing(),15);
        Test.stopTest();

        ucinn_ascendv2__Review_Transaction_v2__c rtv2 = [select id, name, ucinn_ascendv2__Status__c,   nd_gift_group__c, nd_process_status__c, nd_appeal_code__c , nd_Appeal__c
        from ucinn_ascendv2__Review_Transaction_v2__c where name ='GNRL-9930785' limit 1];
        System.debug('testBusinessNoBDonor after ' + rtv2);
        System.assert(rtv2.nd_process_status__c =='Error');
    }



    static testmethod void testInterim() {




        Test.startTest();
        ucinn_ascendv2__Review_Transaction_v2__c rtv2a = [select id, name, ucinn_ascendv2__Status__c,  ND_Pipeline__c, ucinn_ascendv2__Contact__c, 
        nd_spouse_first_name__c, nd_spouse_last_name__c, 
        nd_process_status__c from ucinn_ascendv2__Review_Transaction_v2__c where name ='GNRL-0030785' limit 1];
        rtv2a.nd_spouse_first_name__c = 'Mya';
        rtv2a.nd_spouse_last_name__c = 'Wife';

        //System.debug('rtv2a ' + rtv2a);
        update rtv2a;
            Database.executeBatch(new GiftInterimBatch(),15);
            Database.executeBatch(new ND_RTV2_Processing(),15);
        Test.stopTest();

        ucinn_ascendv2__Review_Transaction_v2__c rtv2 = [select id, name, ucinn_ascendv2__Status__c,  nd_gift_group__c, nd_process_status__c , ucinn_ascendv2__Interim__c
        from ucinn_ascendv2__Review_Transaction_v2__c where name ='GNRL-0030785' limit 1];
        //System.debug(rtv2);
        System.assert(rtv2.nd_process_status__c =='Waiting');
    }

    static testmethod void testHG() {


        Test.startTest();
        ucinn_ascendv2__Review_Transaction_v2__c rtv2a = [select id, name, ucinn_ascendv2__Status__c, nd_gift_comment__c, ND_Pipeline__c, ucinn_ascendv2__Tributee_1__c,
        nd_process_status__c, nd_appeal_code__c from ucinn_ascendv2__Review_Transaction_v2__c where name ='GNRL-0030785' limit 1];
        rtv2a.ND_Pipeline__c = 'CF';
        rtv2a.ucinn_ascendv2__Tributee_1__c = 'dead person';
        //System.debug('rtv2a ' + rtv2a);
        update rtv2a;
            Database.executeBatch(new ND_RTV2_Processing(),15);
        Test.stopTest();

        ucinn_ascendv2__Review_Transaction_v2__c rtv2 = [select id, name, ucinn_ascendv2__Status__c,   nd_gift_group__c, nd_process_status__c from ucinn_ascendv2__Review_Transaction_v2__c where name ='GNRL-0030785' limit 1];
       // System.debug(rtv2);
        System.assert(rtv2.nd_process_status__c =='Done');
  
    }

    static testmethod void testRC() {

        Test.startTest();
        ucinn_ascendv2__Review_Transaction_v2__c rtv2a = [select id, name, ucinn_ascendv2__Status__c, nd_gift_comment__c, ND_Pipeline__c, ucinn_ascendv2__Tributee_1__c,
        nd_process_status__c, nd_appeal_code__c from ucinn_ascendv2__Review_Transaction_v2__c where name ='GNRL-0030785' limit 1];
        rtv2a.ND_Pipeline__c = 'CF';
        rtv2a.ucinn_ascendv2__Payment_Amount_1_1__c =  15000.00;
        rtv2a.ucinn_ascendv2__Total_Transaction_Amount__c = 15000.00;
        update rtv2a;
        //System.debug('rtv2a ' + rtv2a);
            Database.executeBatch(new ND_RTV2_Processing(),15);
        Test.stopTest();

        ucinn_ascendv2__Review_Transaction_v2__c rtv2 = [select id, name, ucinn_ascendv2__Status__c,   nd_gift_group__c, nd_process_status__c from ucinn_ascendv2__Review_Transaction_v2__c where name ='GNRL-0030785' limit 1];
       // System.debug(rtv2);
        System.assert(rtv2.nd_process_status__c =='Done');
  
    }

    static testmethod void testYA() {
        //system.debug('before the test starts');

        Test.startTest();
        
        ucinn_ascendv2__Review_Transaction_v2__c rtv2a = [select id, name, ucinn_ascendv2__Status__c, nd_gift_comment__c, ND_Pipeline__c, ucinn_ascendv2__Contact__c,
        nd_process_status__c, nd_appeal_code__c from ucinn_ascendv2__Review_Transaction_v2__c where name ='GNRL-0030785' limit 1];
        rtv2a.ND_Pipeline__c = 'CF';
        rtv2a.ucinn_ascendv2__Payment_Amount_1_1__c =  550.00;
        rtv2a.ucinn_ascendv2__Total_Transaction_Amount__c = 550.00;
        //System.debug('rtv2a ' + rtv2a);

        
        Id degreeRecordTypeId = [select id,name from recordtype where sobjecttype='ucinn_ascendv2__Degree_Information__c' and name='School Degree Information'].Id;

        ucinn_ascendv2__Degree_Information__c deg= 
        new ucinn_ascendv2__Degree_Information__c(ucinn_ascendv2__Conferred_Degree_Year__c='2022',
                                                  ucinn_ascendv2__Contact__c= rtv2a.ucinn_ascendv2__Contact__c, Data_Source__c='ADV',
                                                 RecordtypeId=degreeRecordTypeId);
        insert deg;
        update rtv2a;
        Database.executeBatch(new ND_RTV2_Processing(),15);
        Test.stopTest();

        ucinn_ascendv2__Review_Transaction_v2__c rtv2 = [select id, name, ucinn_ascendv2__Status__c,   nd_gift_group__c, nd_process_status__c from ucinn_ascendv2__Review_Transaction_v2__c where name ='GNRL-0030785' limit 1];
       // System.debug(rtv2);
        System.assert(rtv2.nd_process_status__c =='Done');
  
    }

}