@isTest(SeeAllData=false)
public class TRIG_beat_alertTest {
        @TestSetup
    public static void testSetup() {
        ucinn_ascendv2__Trigger_Handler__c customHandler1 = new ucinn_ascendv2__Trigger_Handler__c();
            customHandler1.Name = 'Beat Alert Int out Handler';
            customHandler1.ucinn_ascendv2__Class__c = 'TRIG_IntegrationOutHandler';
            customHandler1.ucinn_ascendv2__Is_Active__c = true;
            customHandler1.ucinn_ascendv2__Object__c = 'BEAT_Alert__c';
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

                                        
        Test.startTest();
        BEAT_Alert__c new_ar = new BEAT_Alert__c();
        new_ar.Alert_Type__c = 'INFO';
        new_ar.Message__c = 'This is a test';
        

        insert new_ar;
        Test.stopTest();
        
		BEAT_Alert__c n01 =[select id, Alert_Type__c, Message__c from BEAT_Alert__c where id = :new_ar.id];
        System.assertEquals('INFO', n01.Alert_Type__c);
        System.assertEquals('This is a test', n01.Message__c);


    }      
}