@isTest(SeeAllData=false)
public class ND_EmailAffiliationRelationBatchTest {

    @testSetup
    static void setup() {
        /** The code in this section will create test records only once
         *  The test data can then be used by multiple test methods in
         *  this test class
         */
        
        ucinn_ascendv2__Trigger_Handler__c customHandler04 = new ucinn_ascendv2__Trigger_Handler__c();
        customHandler04.Name = 'Custom Email Handler';
        customHandler04.ucinn_ascendv2__Class__c = 'asc_TRIG_EmailHandler';
        customHandler04.ucinn_ascendv2__Is_Active__c = true;
        customHandler04.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Email__c';
        customHandler04.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;BeforeDelete;AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
        customHandler04.ucinn_ascendv2__Load_Order__c = 2;
        insert customHandler04; 
        
        List<Account> accts = new List<Account>{ 
        new Account(name='Sirius Satellite', ucinn_ascendv2__Donor_ID__c = 'C1'),
        new Account(name='EMPLOYER IN NAME ONLY', ucinn_ascendv2__Donor_ID__c = 'C2'),
        new Account(name='University Of Notre Dame', ucinn_ascendv2__Donor_ID__c='307129',institution_code__c='184100'),
        new Account(name='Sara Faris Household', ucinn_ascendv2__Donor_ID__c = 'hh1'),
        new Account(name='Danuel Household', ucinn_ascendv2__Donor_ID__c = 'hh2'),
        new Account(name='John Stugotz household', ucinn_ascendv2__Donor_ID__c='hh3')
        };
        insert accts;
        //insert new List<Account>{a1, a2, a3};
        //Account newOrganization = [select id from Account where name = 'Sirius Satellite' limit 1];
         
        List<Contact> conts = new List<Contact>{ 
        new Contact(accountid = accts[3].Id, ucinn_ascendv2__Donor_ID__c='38', ucinn_ascendv2__External_System_ID__c='sfarris38', firstname = 'Sarah', lastname = 'Farris', ucinn_ascendv2__Personal_Email__c='sfarris@ttech.edu', Constituent_Status__c='A'),
        new Contact(accountid = accts[4].Id, ucinn_ascendv2__Donor_ID__c='402', firstname = 'Danuel', lastname = 'House', ucinn_ascendv2__Personal_Email__c = 'house@uci.com', Constituent_Status__c ='A' ),
        new Contact(accountid = accts[5].Id, ucinn_ascendv2__Donor_ID__c='508', firstname = 'John', lastname = 'Stugotz', Constituent_Status__c='F', ucinn_ascendv2__Personal_Email__c='stuyougotz@meadowlark.com' ),
        new Contact(accountid = accts[5].Id, firstname = 'Dan', lastname = 'LeBatard', Constituent_Status__c='X', ucinn_ascendv2__Personal_Email__c='lebatard@espn.com')
        };
        insert conts;
        //insert new List<Contact>{c1, c2, c3, c4};
        //insert c1;
        
        ucinn_ascendv2__Affiliation__c af1 = new ucinn_ascendv2__Affiliation__c( ucinn_ascendv2__Contact__c=conts[0].Id
                , ucinn_ascendv2__Data_Source__c='B'
                , ucinn_ascendv2__Account__c=accts[2].Id
                , ucinn_ascendv2__Status__c='Current'
                , ucinn_ascendv2__Constituent_Role__c = 'Employee'
                , ucinn_ascendv2__Organization_Role__c = 'Employer'
                , name ='Test Affi');
        insert af1;

        /*
        ucinn_ascendv2__Email__c email = new ucinn_ascendv2__Email__c();
        email.ucinn_ascendv2__Type__c = 'U';
        email.ucinn_ascendv2__Status__c = 'Current';
        email.ucinn_ascendv2__Data_Source__c = 'B';
        email.ucinn_ascendv2__Contact__c = c1.Id;
        email.ucinn_ascendv2__Email_Address__c ='test@blue.com';
        insert email;*/
        
        Id emRTId = Schema.SObjectType.ucinn_ascendv2__Email__c.getRecordTypeInfosByDeveloperName().get('Contact_Email').getRecordTypeId();
        system.debug('emRTId: ' + emRTId);
        
        ucinn_ascendv2__Email__c em1 = new ucinn_ascendv2__Email__c(
            ucinn_ascendv2__Contact__c=conts[0].Id, 
            ucinn_ascendv2__Status__c = 'Current', 
            ucinn_ascendv2__Data_Source__c ='B', 
            ND_Created_from_Interim_Auto_Affiliation__c = true, 
            ucinn_ascendv2__Type__c = 'U', 
            ucinn_ascendv2__Email_Address__c ='test@blue.com', 
            recordtypeId = emRTId,
            name = '[Default Name]'
        );
                
        system.debug('em1: ' + em1);        
        insert em1;
    }
    
    @isTest    
    static void testLinkofAffil() {

        system.debug ('Before query');
        Contact newConstituent = [select id, ucinn_ascendv2__External_System_ID__c from contact where ucinn_ascendv2__External_System_ID__c = 'sfarris38' limit 1];
        system.debug ('newConstituent: '+newConstituent);
        /*
       ucinn_ascendv2__Email__c em1 = new ucinn_ascendv2__Email__c(
                  ucinn_ascendv2__Contact__c=newConstituent.Id
                , ucinn_ascendv2__Status__c = 'Current'
                , ucinn_ascendv2__Data_Source__c ='B'
                , ND_Created_from_Interim_Auto_Affiliation__c = true
                , ucinn_ascendv2__Type__c = 'U'
                , ucinn_ascendv2__Email_Address__c ='test@blue.com');
        insert em1;*/
        
        ucinn_ascendv2__Email__c em1 = [select id, affiliation__c, ND_process_id__c from ucinn_ascendv2__Email__c where ucinn_ascendv2__Email_Address__c ='test@blue.com' limit 1];
        ucinn_ascendv2__Affiliation__c af1 = [select id from ucinn_ascendv2__Affiliation__c where name ='Test Affi'];


        Test.startTest();
        ND_EmailAffiliationRelationBatch icb =  new ND_EmailAffiliationRelationBatch();
        database.executeBatch(icb);
        Test.stopTest();


        ucinn_ascendv2__Email__c em2 = [select id, affiliation__c, ND_process_id__c from ucinn_ascendv2__Email__c where ucinn_ascendv2__Contact__c =:newConstituent.Id limit 1];
        system.debug('em2: '+ em2);

        system.assertEquals(af1.Id, em2.affiliation__c, 'Affiliation now tied to email');
        system.assertNotEquals(em2.ND_process_id__c, null);

    }

}