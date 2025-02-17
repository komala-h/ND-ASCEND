@isTest(SeeAllData=false)
public class TRIG_degree_codeTest {
        @TestSetup
    public static void testSetup() {
        ucinn_ascendv2__Trigger_Handler__c customHandler1 = new ucinn_ascendv2__Trigger_Handler__c();
            customHandler1.Name = 'Degree Code Int out Handler';
            customHandler1.ucinn_ascendv2__Class__c = 'TRIG_IntegrationOutHandler';
            customHandler1.ucinn_ascendv2__Is_Active__c = true;
            customHandler1.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Degree_Code__c';
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
        ucinn_ascendv2__Degree_Code__c new_ar = new ucinn_ascendv2__Degree_Code__c();
        new_ar.ucinn_ascendv2__Degree_Level__c = 'M';
        new_ar.ucinn_ascendv2__Description__c = 'This is a test';
        

        insert new_ar;
        Test.stopTest();
        
		ucinn_ascendv2__Degree_Code__c n01 =[select id, ucinn_ascendv2__Description__c from ucinn_ascendv2__Degree_Code__c where id = :new_ar.id];
        
        System.assertEquals('This is a test', n01.ucinn_ascendv2__Description__c);


    }      
}