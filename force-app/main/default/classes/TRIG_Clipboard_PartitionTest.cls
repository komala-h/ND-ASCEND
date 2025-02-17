@isTest(SeeAllData=false)
public class TRIG_Clipboard_PartitionTest {
        @TestSetup
    public static void testSetup() {
        ucinn_ascendv2__Trigger_Handler__c customHandler1 = new ucinn_ascendv2__Trigger_Handler__c();
            customHandler1.Name = 'Clipboard Partition Int out Handler';
            customHandler1.ucinn_ascendv2__Class__c = 'TRIG_IntegrationOutHandler';
            customHandler1.ucinn_ascendv2__Is_Active__c = true;
            customHandler1.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Clipboard_Partition__c';
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
        
        ucinn_ascendv2__Clipboard_Saved_List__c new_clip = new ucinn_ascendv2__Clipboard_Saved_List__c();
        new_clip.Name ='Tester save';
        new_clip.ucinn_ascendv2__Is_Clipboard__c = true;
        insert new_clip;
        
	}
    
 @isTest(SeeAllData=false) 
    static void insertAR() {

        ucinn_ascendv2__Clipboard_Saved_List__c c01 =[SELECT Id, Name FROM ucinn_ascendv2__Clipboard_Saved_List__c Limit 1];
        system.debug('c01 = '+c01);
                                                
        Test.startTest();
        ucinn_ascendv2__Clipboard_Partition__c new_ar = new ucinn_ascendv2__Clipboard_Partition__c();
        //new_ar.Name = 'test';
        new_ar.ucinn_ascendv2__Clipboard_Saved_List__c = c01.Id;
        new_ar.ucinn_ascendv2__Content_0__c = 'test 1 2 3';
        insert new_ar;
        Test.stopTest();
        
		ucinn_ascendv2__Clipboard_Partition__c n01 =[select id, ucinn_ascendv2__Clipboard_Saved_List__c, ucinn_ascendv2__Content_0__c from ucinn_ascendv2__Clipboard_Partition__c where id = :new_ar.id];
        //System.assertEquals('test', Name);
        System.assertEquals(c01.id, n01.ucinn_ascendv2__Clipboard_Saved_List__c);
        System.assertEquals('test 1 2 3', n01.ucinn_ascendv2__Content_0__c);


    }      
}