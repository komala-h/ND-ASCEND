@isTest(SeeAllData=false)
public class TRIG_Clipboard_Saved_ListTest {
        @TestSetup
    public static void testSetup() {
        ucinn_ascendv2__Trigger_Handler__c customHandler1 = new ucinn_ascendv2__Trigger_Handler__c();
            customHandler1.Name = 'Clipboard Saved List Int out Handler';
            customHandler1.ucinn_ascendv2__Class__c = 'TRIG_IntegrationOutHandler';
            customHandler1.ucinn_ascendv2__Is_Active__c = true;
            customHandler1.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Clipboard_Saved_List__c';
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
        ucinn_ascendv2__Clipboard_Saved_List__c new_clip = new ucinn_ascendv2__Clipboard_Saved_List__c();
        new_clip.Name ='Tester save';
        new_clip.ucinn_ascendv2__Is_Clipboard__c = true;
        insert new_clip;
        Test.stopTest();
        
		ucinn_ascendv2__Clipboard_Saved_List__c n01 =[select id, Name, ucinn_ascendv2__Is_Clipboard__c from ucinn_ascendv2__Clipboard_Saved_List__c where id = :new_clip.id];
        //System.assertEquals('test', Name);
        System.assertEquals(true, n01.ucinn_ascendv2__Is_Clipboard__c);
        System.assertEquals('Tester save', n01.Name);


    }      
}