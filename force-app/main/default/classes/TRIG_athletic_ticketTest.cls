@isTest(SeeAllData=false)
public class TRIG_athletic_ticketTest {
        @TestSetup
    public static void testSetup() {
        ucinn_ascendv2__Trigger_Handler__c customHandler1 = new ucinn_ascendv2__Trigger_Handler__c();
            customHandler1.Name = 'Athletic Ticket Int out Handler';
            customHandler1.ucinn_ascendv2__Class__c = 'TRIG_IntegrationOutHandler';
            customHandler1.ucinn_ascendv2__Is_Active__c = true;
            customHandler1.ucinn_ascendv2__Object__c = 'Athletic_Ticket__c';
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

		Contact h01 = [SELECT Id FROM Contact WHERE FirstName='h01' LIMIT 1];

                                                
        Test.startTest();
        Athletic_Ticket__c new_ar = new Athletic_Ticket__c();
        new_ar.Constituent__c = h01.Id;
        new_ar.type__c = 'Ticket';
        new_ar.Ticket_Parking_Type__c = 'BO';
        new_ar.Year__c ='2022';
        

        insert new_ar;
        Test.stopTest();
        
		Athletic_Ticket__c n01 =[select id, Constituent__c, type__c, Ticket_Parking_Type__c, Year__c from Athletic_Ticket__c where id = :new_ar.id];
        System.assertEquals(h01.id, n01.Constituent__c);
        System.assertEquals('BO', n01.Ticket_Parking_Type__c);
        System.assertEquals('Ticket', n01.type__c);
        System.assertEquals('2022', n01.Year__c);


    }      
}