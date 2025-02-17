@isTest(SeeAllData=false)
public class TRIG_Involvement_ValueTest {
        @TestSetup
    public static void testSetup() {
        ucinn_ascendv2__Trigger_Handler__c customHandler1 = new ucinn_ascendv2__Trigger_Handler__c();
            customHandler1.Name = 'Involvement Value Int out Handler';
            customHandler1.ucinn_ascendv2__Class__c = 'TRIG_IntegrationOutHandler';
            customHandler1.ucinn_ascendv2__Is_Active__c = true;
            customHandler1.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Involvement_Value__c';
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
        ucinn_ascendv2__Involvement_Value__c new_ar = new ucinn_ascendv2__Involvement_Value__c();
        new_ar.RecordTypeId =  ucinn_ascendv2__Involvement_Value__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Other').getRecordTypeId();
        new_ar.Name = 'INFO';
        new_ar.ucinn_ascendv2__Involvement_Description__c = 'This is a test';
        

        insert new_ar;
        Test.stopTest();
        
		ucinn_ascendv2__Involvement_Value__c n01 =[select id, Name, ucinn_ascendv2__Involvement_Description__c from ucinn_ascendv2__Involvement_Value__c where id = :new_ar.id];
        System.assertEquals('INFO', n01.Name);
        System.assertEquals('This is a test', n01.ucinn_ascendv2__Involvement_Description__c);


    }      
}