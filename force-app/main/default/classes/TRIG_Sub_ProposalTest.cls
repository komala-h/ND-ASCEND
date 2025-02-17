@isTest(SeeAllData=false)
public class TRIG_Sub_ProposalTest {

    
        @TestSetup
    public static void testSetup() {
        ucinn_ascendv2__Trigger_Handler__c customHandler1 = new ucinn_ascendv2__Trigger_Handler__c();
            customHandler1.Name = 'Sub Proposal Int out Handler';
            customHandler1.ucinn_ascendv2__Class__c = 'TRIG_IntegrationOutHandler';
            customHandler1.ucinn_ascendv2__Is_Active__c = true;
            customHandler1.ucinn_ascendv2__Object__c = 'Sub_Proposal__c';
            customHandler1.ucinn_ascendv2__Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
            customHandler1.ucinn_ascendv2__Load_Order__c = 1;
        insert customHandler1;
          
        Contact h01 = new Contact();
        h01.FirstName = 'h01';
        h01.LastName = 'TEST';
        h01.ucinn_ascendv2__Gender__c = 'Male';
        h01.ucinn_ascendv2__Contact_Type__c = 'Alumni';
        h01.ucinn_ascendv2__Data_Source__c = 'WBB';
        h01.ucinn_ascendv2__Personal_Email__c = 'sample@uci.com';
        h01.Constituent_Status__c ='A';
        insert h01;
        
        Opportunity o1 = new Opportunity();
        o1.name='test opp';
        o1.StageName='Submitted';
        o1.ucinn_ascendv2__Contact__c = h01.id;
        o1.CloseDate = system.today();
        o1.ucinn_ascendv2__Credit_Date__c = System.today();
        //o1.CloseDate = Date.valueOf('2021-09-08');
        //o1.nd_Likelihood_to_Close__c = ''
        //o1.Campaign ='';
        insert o1;
        
        ucinn_ascendv2__Work_Plan_Unit__c w1 = new ucinn_ascendv2__Work_Plan_Unit__c();
        w1.name  = 'test';
        w1.ucinn_ascendv2__Code__c ='GH';
        //new_ar.Original_Data_Source__c = 'Constituent';
        w1.Sort_Order__c = 1; 
        insert w1;
   
    }
    
    @isTest(SeeAllData=false) 
    static void insertAR() {
        
        Opportunity o01 = [SELECT Id FROM Opportunity WHERE name='test opp' LIMIT 1];
        ucinn_ascendv2__Work_Plan_Unit__c w01 = [SELECT Id FROM ucinn_ascendv2__Work_Plan_Unit__c WHERE name='test' LIMIT 1];
        Test.startTest();
        Sub_Proposal__c new_ar = new Sub_Proposal__c();
        new_ar.Opportunity__c = o01.Id;
        new_ar.Funding_Priority__c= w01.Id;
        new_ar.Type__c = 'E';
        new_ar.Amount__c = 1000.00;
        //new_ar.Original_Data_Source__c = 'Constituent';
        insert new_ar;
        Test.stopTest();

        Sub_Proposal__c s01 = [SELECT Id, Type__c, Amount__c FROM Sub_Proposal__c WHERE id = :new_ar.Id  LIMIT 1];
        System.assertEquals('E', s01.Type__c);
        System.assertEquals(1000.00, s01.Amount__c);

    }
}