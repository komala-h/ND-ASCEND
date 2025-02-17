@isTest(SeeAllData=false)
public class TRIG_Knowtify_CommentTest {

    @testSetup
    static void setup() {
        /** The code in this section will create test records only once
         *  The test data can then be used by multiple test methods in
         *  this test class
         */
    List<Account> accts = new List<Account>{ 
        new Account(name='Sirius Satellite', ucinn_ascendv2__Donor_ID__c = 'C1'),
        new Account(name='EMPLOYER IN NAME ONLY', ucinn_ascendv2__Donor_ID__c = 'C2'),
        new Account(name='University Of Notre Dame', ucinn_ascendv2__Donor_ID__c='307129'),
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
    }
    
        @isTest(SeeAllData=false) 
    static void insertAR() {
        Contact newConstituent = [select id, ucinn_ascendv2__External_System_ID__c from contact where ucinn_ascendv2__External_System_ID__c = 'sfarris38' limit 1];
        Account newAccount = [select id, ucinn_ascendv2__Donor_ID__c from account where ucinn_ascendv2__Donor_ID__c = 'C1' limit 1];
        
        
        Test.startTest();
        Knowtify_Comment__c new_ar = new Knowtify_Comment__c(
            Category__c = 'Gift Processing'
        );

        new_ar.Constituent__c =newConstituent.id;
        new_ar.Organization__c=newAccount.id;
        new_ar.Comment__c = 'this is a test';
        insert new_ar;
        Test.stopTest();

        Knowtify_Comment__c s01 = [SELECT Id, Comment__c FROM Knowtify_Comment__c];
        System.assertEquals('this is a test', s01.Comment__c);

    }
}