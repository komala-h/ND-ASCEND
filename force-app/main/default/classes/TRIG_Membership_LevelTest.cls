@isTest(SeeAllData=false)
public class TRIG_Membership_LevelTest {
        @TestSetup
    public static void testSetup() {
        ucinn_ascendv2__Trigger_Handler__c customHandler1 = new ucinn_ascendv2__Trigger_Handler__c();
            customHandler1.Name = 'Mebership Level Int out Handler';
            customHandler1.ucinn_ascendv2__Class__c = 'TRIG_IntegrationOutHandler';
            customHandler1.ucinn_ascendv2__Is_Active__c = true;
            customHandler1.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Membership_Level__c';
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
        
        ucinn_ascendv2__Membership_Level__c levelIns = new ucinn_ascendv2__Membership_Level__c();
        levelIns.ucinn_ascendv2__Giving_Society__c = new_ar.id;
        levelIns.name='director circle';
        levelIns.ucinn_ascendv2__Minimum__c= 2500;
        levelIns.ucinn_ascendv2__Maximum__c=5000;
        levelIns.ucinn_ascendv2__Order__c=2;
        insert levelIns;

        Test.stopTest();
		ucinn_ascendv2__Membership_Level__c n01 =[select id, name, ucinn_ascendv2__Giving_Society__c, ucinn_ascendv2__Minimum__c, ucinn_ascendv2__Maximum__c, ucinn_ascendv2__Order__c, ucinn_ascendv2__School_Formula__c  from ucinn_ascendv2__Membership_Level__c where id = :levelIns.id];
        System.assertEquals('director circle', n01.name);
        System.assertEquals(2500, n01.ucinn_ascendv2__Minimum__c);
        System.assertEquals(5000, n01.ucinn_ascendv2__Maximum__c);
        System.assertEquals(2, n01.ucinn_ascendv2__Order__c);
        System.assertEquals('University Relations', n01.ucinn_ascendv2__School_Formula__c);
   
    }      
}