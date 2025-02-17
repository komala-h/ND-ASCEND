@isTest(SeeAllData=false)
public class TRIG_Giving_SocietyTest {
        @TestSetup
    public static void testSetup() {
        ucinn_ascendv2__Trigger_Handler__c customHandler1 = new ucinn_ascendv2__Trigger_Handler__c();
            customHandler1.Name = 'Giving Society Int out Handler';
            customHandler1.ucinn_ascendv2__Class__c = 'TRIG_IntegrationOutHandler';
            customHandler1.ucinn_ascendv2__Is_Active__c = true;
            customHandler1.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Giving_Society__c';
            customHandler1.ucinn_ascendv2__Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
            customHandler1.ucinn_ascendv2__Load_Order__c = 1;
        insert customHandler1;
        
		Account a = new Account(name='Sirius Satellite');
        Account a2 = new Account(name='EMPLOYER IN NAME ONLY');
        insert new List<Account>{a, a2};
            
        Contact h01 = new Contact();
        h01.FirstName = 'h01';
        h01.LastName = 'TEST';
        h01.ucinn_ascendv2__Gender__c = 'Male';
        h01.ucinn_ascendv2__Contact_Type__c = 'Alumni';
        h01.ucinn_ascendv2__Data_Source__c = 'WBB';
        h01.ucinn_ascendv2__Personal_Email__c = 'sample@uci.com';
        h01.Constituent_Status__c ='A';
        insert h01;
	}
    
 @isTest(SeeAllData=false) 
    static void insertAR() {

        Contact c02 = [select id from Contact where LastName ='TEST'];                                     
        Test.startTest();
        ucinn_ascendv2__Giving_Society__c new_ar = new ucinn_ascendv2__Giving_Society__c();
        new_ar.name = 'Cardinal Ohara';        
        new_ar.ucinn_ascendv2__School__c = 'University Relations';
        new_ar.ucinn_ascendv2__Society_Website__c = 'https://giving.nd.edu/giving-societies/ohara-society/';
        new_ar.ucinn_ascendv2__Status__c = 'Active';
        

        insert new_ar;
        ucinn_ascendv2__Society_Membership__c testIns = new ucinn_ascendv2__Society_Membership__c();
        testIns.ucinn_ascendv2__Contact__c = c02.id;
        testIns.ucinn_ascendv2__Giving_Society__c  = new_ar.id;
        insert testIns;

        
        Test.stopTest();
		ucinn_ascendv2__Giving_Society__c n01 =[select id, name, ucinn_ascendv2__School__c, ucinn_ascendv2__Society_Website__c, ucinn_ascendv2__Status__c, ucinn_ascendv2__Number_of_Members_Roll_Up__c  from ucinn_ascendv2__Giving_Society__c where id = :new_ar.id];
        System.assertEquals('Cardinal Ohara', n01.name);
        System.assertEquals('University Relations', n01.ucinn_ascendv2__School__c);
        System.assertEquals('Active', n01.ucinn_ascendv2__Status__c);
        System.assertEquals('https://giving.nd.edu/giving-societies/ohara-society/', n01.ucinn_ascendv2__Society_Website__c);
        System.assertEquals(1, n01.ucinn_ascendv2__Number_of_Members_Roll_Up__c);
        
    }      
}