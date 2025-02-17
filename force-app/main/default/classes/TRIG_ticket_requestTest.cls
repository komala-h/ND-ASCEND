@isTest(SeeAllData=false)
public class TRIG_ticket_requestTest {
        @TestSetup
    public static void testSetup() {
        ucinn_ascendv2__Trigger_Handler__c customHandler1 = new ucinn_ascendv2__Trigger_Handler__c();
            customHandler1.Name = 'Ticket Request Int out Handler';
            customHandler1.ucinn_ascendv2__Class__c = 'TRIG_IntegrationOutHandler';
            customHandler1.ucinn_ascendv2__Is_Active__c = true;
            customHandler1.ucinn_ascendv2__Object__c = 'Ticket_Request__c';
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
        
        Id campBeatRecTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('BEAT Event').getRecordTypeId();
        Campaign c01 = new Campaign();
        c01.RecordTypeId = campBeatRecTypeId;
        c01.Name = 'test Event';
        c01.nd_Grouping_Type__c ='Football';
        c01.status = 'Active';
        c01.StartDate = system.today();
        c01.nd_Year__c = String.valueOf(system.today().year());
        insert c01;
        
        Section__c s01 = new Section__c();
        s01.Event__c = c01.Id;
        s01.Type__c = 'Seat';
        s01.Name = 'test section';
        insert s01;

        

    }
    
 @isTest(SeeAllData=false) 
    static void insertAR() {

        Contact h01 = [SELECT Id FROM Contact WHERE FirstName='h01' LIMIT 1];
        Section__c s01 = [Select id,Event__c from section__c where name = 'test section' limit 1];
        

                                                
        Test.startTest();
        Ticket_Request__c new_ar = new Ticket_Request__c();
        new_ar.Section__c = s01.Id;
        new_ar.Responsible_Payer__c = 'No Charge';
        new_ar.ND_Ticket_Type__c = 'Seat'; //qluong added on 7/26/2023 because of the lookup filter on Section__c
        new_ar.Event__c = s01.Event__c; //qluong added on 7/26/2023 because of the lookup filter on Section__c
       
        insert new_ar;
        Test.stopTest();
        
        Ticket_Request__c n01 =[select id, Section__c, Responsible_Payer__c from Ticket_Request__c where id = :new_ar.id];
        System.assertEquals(s01.id, n01.Section__c);
        System.assertEquals('No Charge', n01.Responsible_Payer__c);


    }      
}