@isTest(SeeAllData=false)
private class Int_out_Trigger_Test {
    @testSetup 
    static void setup() {

        Account a3 = new Account(name='University Of Notre Dame', ucinn_ascendv2__Donor_ID__c='307129',institution_code__c='184100');
        insert a3;  
        Contact c3 = new Contact(accountid = a3.Id, ucinn_ascendv2__Donor_ID__c='508', firstname = 'John', lastname = 'Stugotz', Constituent_Status__c='F', ucinn_ascendv2__Personal_Email__c='stuyougotz@meadowlark.com' );
        insert c3;
      //  recordtype appealType = [SELECT ID from recordtype where  DeveloperName ='Appeal' limit 1];
      //  recordtype CampaignType = [SELECT ID from recordtype where  DeveloperName ='Comprehensive_Campaign' limit 1];
      //  recordtype GenType = [SELECT ID from recordtype where  DeveloperName ='General_Transaction' limit 1];

        Campaign cmpn01 = new Campaign();
        cmpn01.Name = 'TEST CAMPAIGN 01';
        cmpn01.nd_appeal_code__c ='05778';
        cmpn01.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Appeal').getRecordTypeId();
        cmpn01.isActive =True;
        cmpn01.StartDate = Date.valueOf('2014-01-11');

        Campaign cmpn02 = new Campaign();
        cmpn02.Name = 'For Good';
        cmpn02.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Comprehensive Campaign').getRecordTypeId();
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
        RecordTypeId =Schema.SObjectType.ucinn_ascendv2__Review_Transaction_v2__c.getRecordTypeInfosByName().get('General Transaction').getRecordTypeId());
        ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger('ucinn_ascendv2__Payment__c', false); // clin 01/22/2024 - Fix for Error: Methods defined as TestMethod do not support Web service callouts
        insert review;
        ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger('ucinn_ascendv2__Payment__c', true); // clin 01/22/2024 - Fix for Error: Methods defined as TestMethod do not support Web service callouts

    }
    
      static testmethod void testDeleteGift() {

        Test.startTest();
        ucinn_ascendv2__Review_Transaction_v2__c rtv2 = [select id, name, ucinn_ascendv2__Status__c,  ucinn_ascendv2__Opportunity__c, ucinn_ascendv2__Opportunity__r.Needs_G_L_Processing__c ,
        ucinn_ascendv2__Opportunity__r.Is_Session_Completed__c, ucinn_ascendv2__Opportunity__r.ND_RecordType_DeveloperName__c, ucinn_ascendv2__Opportunity__r.StageName
        from ucinn_ascendv2__Review_Transaction_v2__c where name ='GNRL-0030785' limit 1];
          
        opportunity opp = [select id, Needs_G_L_Processing__c, name from opportunity where id = :rtv2.ucinn_ascendv2__Opportunity__c limit 1];
		
        ucinn_ascendv2__Payment__c pay = [select id from ucinn_ascendv2__Payment__c where ucinn_ascendv2__Opportunity__c = :opp.id limit 1];
        
        ucinn_ascendv2__Hard_and_Soft_Credit__c hc = [select id from ucinn_ascendv2__Hard_and_Soft_Credit__c where ucinn_ascendv2__Opportunity__c = :opp.id limit 1];
        delete pay;
        delete hc;
        delete opp;
        ucinn_ascendv2__Designation__c desd = [select id from ucinn_ascendv2__Designation__c limit 1];
        delete desd;

        Contact cd = [select id from Contact limit 1];
    //    delete cd;
        Account ad = [select id from Account limit 1];
   //     delete ad;
        Test.stopTest();
  
    }


}