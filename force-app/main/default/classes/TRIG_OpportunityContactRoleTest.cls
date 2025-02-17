@isTest(SeeAllData=false)
public class TRIG_OpportunityContactRoleTest {

    
        @TestSetup
    public static void testSetup() {
        ucinn_ascendv2__Trigger_Handler__c customHandler1 = new ucinn_ascendv2__Trigger_Handler__c();
            customHandler1.Name = 'Opportunity Contact Role Int out Handler';
            customHandler1.ucinn_ascendv2__Class__c = 'TRIG_IntegrationOutHandler';
            customHandler1.ucinn_ascendv2__Is_Active__c = true;
            customHandler1.ucinn_ascendv2__Object__c = 'OpportunityContactRole';
            customHandler1.ucinn_ascendv2__Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
            customHandler1.ucinn_ascendv2__Load_Order__c = 1;
        insert customHandler1;
        
        Account a = new Account(name='Sirius Satellite');
        Account a2 = new Account(name='EMPLOYER IN NAME ONLY');
        insert new List<Account>{a, a2};
          
        Contact h01 = new Contact();
        h01.AccountId = a.id;
        h01.FirstName = 'h01';
        h01.LastName = 'TEST';
        h01.ucinn_ascendv2__Gender__c = 'Male';
        h01.ucinn_ascendv2__Contact_Type__c = 'Alumni';
        h01.ucinn_ascendv2__Data_Source__c = 'WBB';
        h01.ucinn_ascendv2__Personal_Email__c = 'sample@uci.com';
        h01.Constituent_Status__c ='A';
        insert h01;
        
       /* Opportunity o1 = new Opportunity();
        o1.name='test opp';
        o1.StageName='Submitted';
        o1.ucinn_ascendv2__Contact__c = h01.id;
        o1.CloseDate = System.today(); //Date.valueOf('2021-09-08');
        o1.ucinn_ascendv2__Credit_Date__c = System.today();
        //o1.nd_Likelihood_to_Close__c = ''
        //o1.Campaign ='';
        insert o1;*/
        
        Opportunity o01 = new Opportunity();
        o01.AccountId = a.id;
        o01.Name = 'test opp';
        o01.ucinn_ascendv2__Contact__c = h01.Id;
        o01.StageName = 'Planned';
        o01.ucinn_ascendv2__Tender_Type_for_Gifts__c = 'Cash';
        o01.Amount =125000;
        o01.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Pledge').getRecordTypeId();
        o01.ucinn_ascendv2__Adjusted_Gift__c = null;
        o01.ucinn_ascendv2__Credit_Date__c = System.today();
        o01.Type =  'Outright';
        o01.CloseDate =  System.today();
        insert o01;
   
    }
    
    @isTest(SeeAllData=false) 
    static void insertAR() {
        Contact h01 = [SELECT Id FROM Contact WHERE FirstName='h01' LIMIT 1];
        Opportunity o01 = [SELECT Id FROM Opportunity WHERE name='test opp' LIMIT 1];
        
        Test.startTest();
        OpportunityContactRole new_ar = new OpportunityContactRole();
        new_ar.OpportunityId = o01.Id;
        new_ar.ContactId= h01.Id;
        new_ar.IsPrimary = true;
        new_ar.role = 'Primary Investigator';

        insert new_ar;
        Test.stopTest();

        OpportunityContactRole s01 = [SELECT Id, role, IsPrimary FROM OpportunityContactRole WHERE id = :new_ar.Id  LIMIT 1];
        System.assertEquals('Primary Investigator', s01.role);
        System.assertEquals(true, s01.IsPrimary);

    }
}