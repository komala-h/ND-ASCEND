@isTest(SeeAllData=false)
public class TRIG_Seat_Lot_AssignmentTest {
        @TestSetup
    public static void testSetup() {
        ucinn_ascendv2__Trigger_Handler__c customHandler1 = new ucinn_ascendv2__Trigger_Handler__c();
            customHandler1.Name = 'Seat Lot Assignment Int out Handler';
            customHandler1.ucinn_ascendv2__Class__c = 'TRIG_IntegrationOutHandler';
            customHandler1.ucinn_ascendv2__Is_Active__c = true;
            customHandler1.ucinn_ascendv2__Object__c = 'Seat_Lot_Assignment__c';
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
        
        /*  qluong 2/16/2023 The BEAT_Request__c is no longer used.
        BEAT_Request__c b01 = new BEAT_Request__c();
        b01.Event__c = c01.Id;
        b01.Requested_By__c = UserInfo.getUserId();
        b01.Constituent__c = h01.id;
        insert b01;
        */
        
        Ticket_Request__c t01 = new Ticket_Request__c();
        t01.Section__c = s01.Id;
        t01.Responsible_Payer__c = 'No Charge';
        //t01.BEAT_Request__c = b01.id; qluong 2/16/2023 The BEAT_Request__c is no longer used.
        t01.ND_Ticket_Type__c = 'Seat'; //qluong 7/26/2023 added because lookup fitler on Section__c
        t01.Event__c = c01.Id; //qluong 7/26/2023 added because lookup fitler on Section__c
        insert t01;
        

    }
    
 @isTest(SeeAllData=false) 
    static void insertAR() {

        Contact h01 = [SELECT Id FROM Contact WHERE FirstName='h01' LIMIT 1];
        Section__c s01 = [Select id from section__c where name = 'test section' limit 1];
        Ticket_Request__c t01 = [select id from Ticket_Request__c limit 1];
        //BEAT_Request__c b01 = [select id from BEAT_Request__c limit 1]; qluong 2/16/2023 The BEAT_Request__c is no longer used.
        Campaign c01 = [select Id, Name from campaign limit 1];
        

                                                
        Test.startTest();
        Seat_Lot_Assignment__c new_ar = new Seat_Lot_Assignment__c();

        new_ar.Ticket_Request__c = t01.id;
        
        insert new_ar;
        Test.stopTest();
        
        Seat_Lot_Assignment__c n01 =[select id, Ticket_Request__c from Seat_Lot_Assignment__c where id = :new_ar.id]; 
        System.assertEquals(t01.id, n01.Ticket_Request__c);
        //System.assertEquals(b01.id, n01.BEAT_Request__c); qluong 2/16/2023 The BEAT_Request__c is no longer used.


    }      
}