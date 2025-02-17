@isTest(SeeAllData=false)
public class TRIG_NoteTest {
        @TestSetup
    public static void testSetup() {
        ucinn_ascendv2__Trigger_Handler__c customHandler1 = new ucinn_ascendv2__Trigger_Handler__c();
            customHandler1.Name = 'Note Int out Handler';
            customHandler1.ucinn_ascendv2__Class__c = 'TRIG_IntegrationOutHandler';
            customHandler1.ucinn_ascendv2__Is_Active__c = true;
            customHandler1.ucinn_ascendv2__Object__c = 'ascend_Note__c';
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
        ascend_Note__c new_ar = new ascend_Note__c();
        new_ar.nd_Constituent__c = c02.id;
        new_ar.nd_Comment__c = 'This is a test';
        

        insert new_ar;
        Test.stopTest();
        
		ascend_Note__c n01 =[select id, nd_Comment__c from ascend_Note__c where id = :new_ar.id];
        
        System.assertEquals('This is a test', n01.nd_Comment__c);


    }      
}