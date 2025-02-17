@isTest(SeeAllData=false)
private class ND_JV_Process_Test {
    @testSetup 
    static void setup() {

        Account a3 = new Account(name='University Of Notre Dame', ucinn_ascendv2__Donor_ID__c='307129',institution_code__c='184100');
        insert a3;  
        Contact c3 = new Contact(accountid = a3.Id, ucinn_ascendv2__Donor_ID__c='508', firstname = 'John', lastname = 'Stugotz', Constituent_Status__c='F', ucinn_ascendv2__Personal_Email__c='stuyougotz@meadowlark.com' );
        insert c3;
        recordtype appealType = [SELECT ID from recordtype where  DeveloperName ='Appeal' limit 1];
        recordtype CampaignType = [SELECT ID from recordtype where  DeveloperName ='Comprehensive_Campaign' limit 1];
        recordtype GenType = [SELECT ID from recordtype where  DeveloperName ='General_Transaction' limit 1];

        Campaign cmpn01 = new Campaign();
        cmpn01.Name = 'TEST CAMPAIGN 01';
        cmpn01.nd_appeal_code__c ='05778';
        cmpn01.RecordTypeId = appealType.id;
        cmpn01.isActive =True;
        cmpn01.StartDate = Date.valueOf('2014-01-11');

        Campaign cmpn02 = new Campaign();
        cmpn02.Name = 'For Good';
        cmpn02.RecordTypeId = CampaignType.id;
        cmpn02.isActive =True;
        cmpn02.StartDate = Date.valueOf('2014-01-11');
        insert new List<Campaign>{cmpn01, cmpn02 };

        ucinn_ascendv2__Academic_Organization__c sub = new ucinn_ascendv2__Academic_Organization__c(
            name = 'Central Financial Management',
            ucinn_ascendv2__Type__c = 'desig_sub-dept',
            ucinn_ascendv2__Code__c = 'S288',
            ucinn_ascendv2__External_System_ID__c = 'J5;S288;'
        );
        insert sub;

        ucinn_ascendv2__Designation__c des = new ucinn_ascendv2__Designation__c(
            name ='UNRESTRICTED',
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


        ucinn_ascendv2__Review_Transaction_v2__c review = new ucinn_ascendv2__Review_Transaction_v2__c( 
        name = 'GNRL-0030785',
        ucinn_ascendv2__First_Name__c = 'Dan',
        ucinn_ascendv2__Last_Name__c = 'LeBatard', 
        nd_appeal__c = cmpn01.id,
        ucinn_ascendv2__Campaign__c = cmpn02.id,
        nd_data_source__c = 'HVG', 
        ucinn_ascendv2__Contact__c = c3.id ,
        ucinn_ascendv2__Transaction_Date__c = Date.valueOf('2024-01-11'),
        ucinn_ascendv2__Status__c='Reviewed', 
        ucinn_ascendv2__Tender_Type_1__c = 'Credit Card',
        ucinn_ascendv2__Transaction_Type__c ='Gift',
        nd_Pledge_Gift_Type__c = 'Outright',
        ucinn_ascendv2__Send_to_G_L__c = true,
        ucinn_ascendv2__Payment_Amount_1_1__c =  50.00,
        ucinn_ascendv2__Designation_1__c = des.id,
        ucinn_ascendv2__External_System_ID__c = 'GNRL-0030785',
        RecordTypeId =GenType.id
                );
        ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger('ucinn_ascendv2__Payment__c', false); // clin 01/22/2024 - Fix for Error: Methods defined as TestMethod do not support Web service callouts
        insert review;
        ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger('ucinn_ascendv2__Payment__c', true); // clin 01/22/2024 - Fix for Error: Methods defined as TestMethod do not support Web service callouts
/*
        ucinn_ascendv2__Review_Transaction_v2__c r2 = new ucinn_ascendv2__Review_Transaction_v2__c( 
            name = 'GNRL-0030785',
            ucinn_ascendv2__First_Name__c = 'Dan',
            ucinn_ascendv2__Last_Name__c = 'LeBatard', 
            nd_appeal__c = cmpn01.id,
            ucinn_ascendv2__Campaign__c = cmpn02.id,
            nd_data_source__c = 'HVG', 
            ucinn_ascendv2__Contact__c = c3.id ,
            ucinn_ascendv2__Transaction_Date__c = Date.valueOf('2024-01-11'),
            ucinn_ascendv2__Status__c='Reviewed', 
            ucinn_ascendv2__Tender_Type_1__c = 'Credit Card',
            ucinn_ascendv2__Send_to_G_L__c = true,
            ucinn_ascendv2__Payment_Amount_1_1__c =  50.00,
            ucinn_ascendv2__Designation_1__c = des.id,
            ucinn_ascendv2__External_System_ID__c = 'GNRL-0030785',
            RecordTypeId =GenType.id,
            ucinn_ascendv2__Transaction_Type__c ='Pledge Payment',
            ucinn_ascendv2__Opportunity_Type__c = 'Pledge Payment'
                    );
                    */
          //  insert r2;
    }

    static testmethod void testNewPayment() {
        ucinn_ascendv2__Review_Transaction_v2__c rtv2 = [select id, name, ucinn_ascendv2__Status__c,  ucinn_ascendv2__Opportunity__c, ucinn_ascendv2__Opportunity__r.Needs_G_L_Processing__c ,
        ucinn_ascendv2__Opportunity__r.Is_Session_Completed__c, ucinn_ascendv2__Opportunity__r.ND_RecordType_DeveloperName__c, ucinn_ascendv2__Opportunity__r.StageName
        from ucinn_ascendv2__Review_Transaction_v2__c where name ='GNRL-0030785' limit 1];
        System.debug('something posted ' + rtv2.ucinn_ascendv2__Status__c + ' gift ' +  rtv2.ucinn_ascendv2__Opportunity__c);
        System.Debug('does opportunity need to post ' + rtv2.ucinn_ascendv2__Opportunity__r.Needs_G_L_Processing__c);
        System.Debug('sesson complete ' + rtv2.ucinn_ascendv2__Opportunity__r.Is_Session_Completed__c);
        System.Debug('record developer name ' + rtv2.ucinn_ascendv2__Opportunity__r.ND_RecordType_DeveloperName__c);
        System.Debug('stage name ' + rtv2.ucinn_ascendv2__Opportunity__r.StageName);

        System.assert(rtv2.ucinn_ascendv2__Status__c == 'Posted');

        opportunity opp = [select id, Needs_G_L_Processing__c from opportunity where id = :rtv2.ucinn_ascendv2__Opportunity__c limit 1];
        opp.Needs_G_L_Processing__c = true;
        update opp;
    
        ucinn_ascendv2__Payment__c pay = [select id, ucinn_ascendv2__Sent_to_G_L_Date__c from ucinn_ascendv2__Payment__c where ucinn_ascendv2__Opportunity__c = :opp.id limit 1];
    pay.ucinn_ascendv2__Sent_to_G_L_Date__c = Date.valueOf('2014-01-11');
        update pay;

        List<Opportunity> GiftList = [ select id, name from Opportunity where Needs_G_L_Processing__c = true and
        ((ND_RecordType_DeveloperName__c in('Gift', 'Matching Gift') and Campaign.StartDate >= 2013-07-01 )
        or ND_RecordType_DeveloperName__c = 'Pledge')
         and stageName != 'Adjusted'];

        if( GiftList.size() < 1) {
            System.Debug('Something is wrong');
        }
        else{
            System.Debug('there is population to process');
        }

        opportunity opp2 = [select id, Needs_G_L_Processing__c, Campaign.StartDate from opportunity where id = :rtv2.ucinn_ascendv2__Opportunity__c limit 1];
        System.debug('opp after update ' + opp2.Needs_G_L_Processing__c);
        System.debug('opp after update campaign ' + opp2.Campaign.StartDate);

        Test.startTest();
            Database.executeBatch(new ND_JV_Process(),15);
        Test.stopTest();

        nd_jv_entry__c jv = [select id, name from nd_jv_entry__c limit 1];
        System.debug('jv record' + jv.id );
  
    }
    static testmethod void testAdjustPayment() {
        ucinn_ascendv2__Review_Transaction_v2__c rtv2 = [select id, name, ucinn_ascendv2__Status__c,  ucinn_ascendv2__Opportunity__c, ucinn_ascendv2__Opportunity__r.Needs_G_L_Processing__c ,
        ucinn_ascendv2__Opportunity__r.Is_Session_Completed__c, ucinn_ascendv2__Opportunity__r.ND_RecordType_DeveloperName__c, ucinn_ascendv2__Opportunity__r.StageName
        from ucinn_ascendv2__Review_Transaction_v2__c where name ='GNRL-0030785' limit 1];
        opportunity opp = [select id, Needs_G_L_Processing__c, name from opportunity where id = :rtv2.ucinn_ascendv2__Opportunity__c limit 1];
        opp.Needs_G_L_Processing__c = true;
        update opp;

        nd_jv_entry__c jvAdd = new nd_jv_entry__c(
            clearing_account__c ='100000-58050-20510-99000',
            clearing_amount__c = 238.4,
            designation_account__c = '100000-58050-59003-99000',
            designation_amount__c = 238.4,
            jv_status__c = 'processed in advance',
            jv_type__c = 'DV1',
            opportunity_name__c =  opp.name
        );

        insert jvAdd;

        Test.startTest();
            Database.executeBatch(new ND_JV_Process(),15);
        Test.stopTest();

        nd_jv_entry__c jv = [select id, name from nd_jv_entry__c where jv_type__c ='DV3' limit 1];



  
    }

}