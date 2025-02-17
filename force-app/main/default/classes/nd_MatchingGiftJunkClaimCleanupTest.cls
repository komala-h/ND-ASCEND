/*
* Description: Test Class for nd_MatchingGiftJunkClaimCleanup
* 
*/
@isTest
public class nd_MatchingGiftJunkClaimCleanupTest {
 
    @testsetup
    static void setuprecords(){
        Account a = new Account(Name = 'Test',ucinn_ascendv2__Email__c='abc@test.com',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporations and Organizations').getRecordTypeId());        
        insert a;
        
        Contact c = new Contact(FirstName = 'Test 1', LastName = 'Contact', AccountId = a.Id,email='abc@def.com',Constituent_Status__c = 'A',nd_SIG__c=true);
        insert c;
        
        ucinn_ascendv2__Trigger_Handler__c customHandler01 = new ucinn_ascendv2__Trigger_Handler__c();
        customHandler01.Name = 'Opportunity Handler';
        customHandler01.ucinn_ascendv2__Class__c = 'NdOpportunityHandler';
        customHandler01.ucinn_ascendv2__Is_Active__c = true;
        customHandler01.ucinn_ascendv2__Object__c = 'Opportunity';
        customHandler01.ucinn_ascendv2__Trigger_Action__c = 'BeforeDelete;AfterInsert;AfterDelete;';
        customHandler01.ucinn_ascendv2__Load_Order__c = 1.0;
        insert customHandler01; 
            
        ucinn_ascendv2__Trigger_Handler__c customHandler02 = new ucinn_ascendv2__Trigger_Handler__c();
        customHandler02.Name = 'Opportunity Handler';
        customHandler02.ucinn_ascendv2__Class__c = 'ascend_TRIG_OpportunityHandler';
        customHandler02.ucinn_ascendv2__Is_Active__c = true;
        customHandler02.ucinn_ascendv2__Object__c = 'Opportunity';
        customHandler02.ucinn_ascendv2__Trigger_Action__c = 'BeforeDelete;AfterInsert;AfterDelete;';
        customHandler02.ucinn_ascendv2__Load_Order__c = 2.0;
        insert customHandler02;    
        
        ucinn_ascendv2__Session__c sess1 = new ucinn_ascendv2__Session__c();
        sess1.ucinn_ascendv2__Session_Date__c = System.today();
        sess1.ucinn_ascendv2__Gift_Pledge_Payment_Amount__c = 2000000;
        insert sess1;
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Default Name 1';
        opp1.ucinn_ascendv2__Contact__c = c.Id;
        opp1.StageName = 'Withdrawn';
        opp1.ucinn_ascendv2__Tender_Type_for_Gifts__c = 'Cash';
        opp1.Amount =125000;
        opp1.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Pledge').getRecordTypeId();
        opp1.ucinn_ascendv2__Adjusted_Gift__c = null;
        opp1.ucinn_ascendv2__Credit_Date__c = System.today();
        opp1.Type =  'Outright';
        opp1.CloseDate =  System.today();
        opp1.ucinn_ascendv2__Disbursement__c =null;
        opp1.ucinn_ascendv2__Session__c = sess1.Id;
        insert opp1;
        
        List<ucinn_ascendv2__Academic_Organization__c> aoList = new List<ucinn_ascendv2__Academic_Organization__c>();
        ucinn_ascendv2__Academic_Organization__c ao1 = new ucinn_ascendv2__Academic_Organization__c();
        ao1.Name = 'Athletics';
        ao1.ucinn_ascendv2__Type__c = 'desig_div';
        ao1.ucinn_ascendv2__Code__c = 'V025';
        aoList.add(ao1);
        
        ucinn_ascendv2__Academic_Organization__c ao2 = new ucinn_ascendv2__Academic_Organization__c();
        ao2.Name = 'Athletics';
        ao2.ND_Parent_Department__c = ao1.Id;
        ao2.ucinn_ascendv2__Type__c = 'desig_sub-dept';
        ao2.ucinn_ascendv2__Code__c = 'S025';
        aoList.add(ao2);
        insert aoList;
        
        ucinn_ascendv2__Designation__c desig1 = new ucinn_ascendv2__Designation__c();
        desig1.Name = 'ROCKNE TEST';
        desig1.ucinn_ascendv2__Designation_Name__c = 'Rockne Test';
        desig1.Unrestricted_Type__c = 'UNIVUNR';
        desig1.ucinn_ascendv2__G_L_Effective_Date__c = System.today();
        desig1.Sub_Department__c = ao2.Id;
        insert desig1;
        
        ucinn_ascendv2__Designation_Detail__c d1 = new ucinn_ascendv2__Designation_Detail__c(Name='Test1',ucinn_ascendv2__Opportunity__c=opp1.id);
        insert d1;
        
        ucinn_ascendv2__Payment__c pmt1 = new ucinn_ascendv2__Payment__c();
        pmt1.ucinn_ascendv2__Contact__c = c.Id;
        pmt1.ucinn_ascendv2__Transaction_Type__c = 'Matching Gift Payment';
        pmt1.ucinn_ascendv2__Status__c = 'Paid';
        pmt1.ucinn_ascendv2__Tender_Type_for_Gifts__c = 'Cash';
        pmt1.ucinn_ascendv2__Payment_Amount__c = 20000;
        pmt1.ucinn_ascendv2__Credit_Date__c = System.today();
        pmt1.ucinn_ascendv2__Session__c = sess1.Id;
        pmt1.ucinn_ascendv2__Opportunity__c = opp1.Id;
        pmt1.ucinn_ascendv2__Designation__c = desig1.Id;
        pmt1.ucinn_ascendv2__Designation_Detail__c = d1.Id;
        pmt1.ucinn_ascendv2__Receipt_Number__c ='1234';
        insert pmt1;
        
		ucinn_ascendv2__Matching_Gift_Origination__c mg01 = new ucinn_ascendv2__Matching_Gift_Origination__c();
        mg01.ucinn_ascendv2__Payment__c = pmt1.id;
		mg01.ucinn_ascendv2__Opportunity__c = opp1.id;
        insert  mg01;   
    } 

    @isTest
    static void testMethod1(){
        
        list<ucinn_ascendv2__Matching_Gift_Origination__c> mgList = [SELECT Id, ucinn_ascendv2__Payment__c, ucinn_ascendv2__Opportunity__c ,ucinn_ascendv2__Opportunity__r.StageName,ucinn_ascendv2__Opportunity__r.ucinn_ascendv2__Session__c,ucinn_ascendv2__Opportunity__r.ucinn_ascendv2__Disbursement__c
                                             FROM ucinn_ascendv2__Matching_Gift_Origination__c where ucinn_ascendv2__Payment__c != null                                            
                                             AND ucinn_ascendv2__Opportunity__c!=null 
                                             AND ND_Payment_Transaction_Type__c ='Matching Gift Payment'
                                             limit 1 ];
     
        Test.startTest();
        nd_MatchingGiftJunkClaimCleanup t = new nd_MatchingGiftJunkClaimCleanup();
        DataBase.executeBatch(t,200); 
        Test.stopTest();
    }
    
    static testMethod void scheduleBatch() {    
        TracHier.HierarchyAPI.setTriggerDisabled();
        test.starttest();
        nd_MatchingGiftJunkClaimCleanup i = new nd_MatchingGiftJunkClaimCleanup();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, i);
        test.stopTest();
    }

}