/*
* Description: Test Class for Nd_HardandSoftCreditTriggerHandler
* Created Date: 25/01/2023
*/

@isTest
public class Nd_HardandSoftCreditTriggerTestclass {
    @testsetup
    static void insertrec(){
        ucinn_ascendv2__Trigger_Handler__c hscHandler = new ucinn_ascendv2__Trigger_Handler__c();
        hscHandler.Name = 'Nd HardandSoftCreditTriggerHandler';
        hscHandler.ucinn_ascendv2__Class__c = 'Nd_HardandSoftCreditTriggerHandler';
        hscHandler.ucinn_ascendv2__Is_Active__c = true;
        hscHandler.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Hard_and_Soft_Credit__c';
        hscHandler.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;AfterUpdate';
        insert hscHandler; 
                
        Test.startTest();
        list<ucinn_ascendv2__Service_Indicator__c> ndServInd = new list<ucinn_ascendv2__Service_Indicator__c>();
        Account a = new Account(Name = 'Test',ucinn_ascendv2__Email__c='abc@test.com',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporations and Organizations').getRecordTypeId());        
        insert a;
        
        //Create a Contact    
        Contact c = new Contact(FirstName = 'Test 1', LastName = 'Contact', AccountId = a.Id,email='abc@def.com',Constituent_Status__c = 'A',nd_SIG__c=true);
        insert c;
        
        //create an Opportunity
        Opportunity opp = new Opportunity();
        opp.Name = '[Default Name]';
        opp.ucinn_ascendv2__Contact__c = c.Id;
        opp.StageName = 'Funded';
        opp.ucinn_ascendv2__Tender_Type_for_Gifts__c = 'Cash';
        opp.Amount = 5000;
        opp.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Pledge').getRecordTypeId();
        opp.ucinn_ascendv2__Adjusted_Gift__c = null;
        opp.ucinn_ascendv2__Credit_Date__c = System.today();
        opp.Type =  'Outright';
        opp.CloseDate =  System.today();
        insert opp;
        
        //create another Opportunity with RecordType='Gift' & opportunity Type='Grant'
        Opportunity opp1 = new Opportunity();
        opp1.Name = '[Default Name 1]';
        opp1.ucinn_ascendv2__Contact__c =c.Id;
        opp1.StageName = 'Funded';
        opp1.ucinn_ascendv2__Tender_Type_for_Gifts__c = 'Cash';
        opp1.Amount = 5000;
        opp1.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Gift').getRecordTypeId();
        opp1.ucinn_ascendv2__Adjusted_Gift__c = null;
        opp1.ucinn_ascendv2__Credit_Date__c = System.today();
        opp1.Type = 'Outright';
        opp1.CloseDate =  System.today();
        insert opp1;
                 
        
        //Create Designation
        ucinn_ascendv2__Designation_Detail__c d = new ucinn_ascendv2__Designation_Detail__c(Name='Test',ucinn_ascendv2__Opportunity__c=opp.id);
        insert d;
        
        //Create Designation
        ucinn_ascendv2__Designation_Detail__c d1 = new ucinn_ascendv2__Designation_Detail__c(Name='Test1',ucinn_ascendv2__Opportunity__c=opp1.id);
        insert d1;
      
        
        // Create a Tribute
        ucinn_ascendv2__Tribute__c t = new ucinn_ascendv2__Tribute__c(ucinn_ascendv2__Opportunity__c=opp.id,Name = 'TestTribute',ucinn_ascendv2__Tribute_Type__c='H',ucinn_ascendv2__Contact__c=c.id);
        insert t;
        
        //Create a Hard and Soft Credit
        ucinn_ascendv2__Hard_and_Soft_Credit__c hs = new ucinn_ascendv2__Hard_and_Soft_Credit__c(ucinn_ascendv2__Contact__c=c.id,ucinn_ascendv2__Credit_Type__c='Hard',Name='Test1',ucinn_ascendv2__Designation_Detail__c=d.id,
                                                                                                 ucinn_ascendv2__Opportunity__c=opp.id,ucinn_ascendv2__Credit_Amount__c=1000000);
        insert hs;
        Test.stopTest();
        
    }
    @isTest
    static void insertrec2(){
        Test.startTest();
        list<ucinn_ascendv2__Service_Indicator__c> ndServInd = new list<ucinn_ascendv2__Service_Indicator__c>();
        Account a = [select id,ucinn_ascendv2__Email__c,RecordTypeId from Account where Name = 'Test' limit 1];
        Contact c = [select id,FirstName,LastName,AccountId,nd_SIG__c,email from Contact limit 1];
        Opportunity o = [select id,Name,stageName,nd_Likelihood_to_Close__c,ucinn_ascendv2__Contact__c,Title__c,CloseDate from Opportunity  limit 1];
        ucinn_ascendv2__Designation_Detail__c d = [select id,Name,ucinn_ascendv2__Opportunity__c from ucinn_ascendv2__Designation_Detail__c where ucinn_ascendv2__Opportunity__c=:o.id limit 1];
        ucinn_ascendv2__Hard_and_Soft_Credit__c hs = new ucinn_ascendv2__Hard_and_Soft_Credit__c(ucinn_ascendv2__Contact__c=c.id,ucinn_ascendv2__Credit_Type__c='Hard',Name='Test1',ucinn_ascendv2__Designation_Detail__c=d.id,ucinn_ascendv2__Opportunity__c=o.id,ucinn_ascendv2__Credit_Amount__c=1000000);
        insert hs;
        Test.stopTest();
    }
    
    @isTest
    static void insertrec3(){
        Test.startTest();
        list<ucinn_ascendv2__Service_Indicator__c> ndServInd = new list<ucinn_ascendv2__Service_Indicator__c>();
        Account a = [select id,ucinn_ascendv2__Email__c,RecordTypeId from Account where Name = 'Test' limit 1];
        Contact c = [select id,FirstName,LastName,AccountId,nd_SIG__c,email from Contact limit 1];
        Opportunity o = [select id,Name,stageName,nd_Likelihood_to_Close__c,ucinn_ascendv2__Contact__c,Title__c,CloseDate from Opportunity  limit 1];
        ucinn_ascendv2__Designation_Detail__c d = [select id,Name,ucinn_ascendv2__Opportunity__c from ucinn_ascendv2__Designation_Detail__c where ucinn_ascendv2__Opportunity__c=:o.id limit 1];
        ucinn_ascendv2__Hard_and_Soft_Credit__c hs = new ucinn_ascendv2__Hard_and_Soft_Credit__c(ucinn_ascendv2__Contact__c=c.id,ucinn_ascendv2__Credit_Type__c='Hard',Name='Test1',ucinn_ascendv2__Designation_Detail__c=d.id,ucinn_ascendv2__Opportunity__c=o.id,ucinn_ascendv2__Credit_Amount__c=110.0);
                                                                                               
        insert hs;
        Test.stopTest();
        update hs;
    }
      @isTest
    static void insertrec4(){
        Test.startTest();
        ucinn_ascendv2__Session__c sess1 = new ucinn_ascendv2__Session__c();
        sess1.ucinn_ascendv2__Session_Date__c = System.today();
        sess1.ucinn_ascendv2__Gift_Pledge_Payment_Amount__c = 5000;
        insert sess1;
        list<ucinn_ascendv2__Service_Indicator__c> ndServInd = new list<ucinn_ascendv2__Service_Indicator__c>();
        Account a = [select id,ucinn_ascendv2__Email__c,RecordTypeId from Account where Name = 'Test' limit 1];
        Contact c = [select id,FirstName,LastName,AccountId,nd_SIG__c,email from Contact limit 1];
       List<ucinn_ascendv2__Academic_Organization__c> aoList = new List<ucinn_ascendv2__Academic_Organization__c>();

        ucinn_ascendv2__Academic_Organization__c ao1 = new ucinn_ascendv2__Academic_Organization__c();
        ao1.Name = 'Athletics';
        ao1.ucinn_ascendv2__Type__c = 'desig_div';
        ao1.ucinn_ascendv2__Code__c = 'V025';
        aoList.add(ao1);

        ucinn_ascendv2__Academic_Organization__c ao2 = new ucinn_ascendv2__Academic_Organization__c();
        ao2.Name = 'Arts & Letters';
        ao2.ucinn_ascendv2__Type__c = 'desig_div';
        ao2.ucinn_ascendv2__Code__c = 'V010';
        aoList.add(ao2);
        
        ucinn_ascendv2__Academic_Organization__c ao3 = new ucinn_ascendv2__Academic_Organization__c();
        ao3.Name = 'Athletics';
        ao3.ND_Parent_Department__c = ao1.Id;
        ao3.ucinn_ascendv2__Type__c = 'desig_sub-dept';
        ao3.ucinn_ascendv2__Code__c = 'S025';
        aoList.add(ao3);
        
        ucinn_ascendv2__Academic_Organization__c ao4 = new ucinn_ascendv2__Academic_Organization__c();
        ao4.Name = 'Arts & Letters';
        ao4.ND_Parent_Department__c = ao2.Id;
        ao4.ucinn_ascendv2__Type__c = 'desig_sub-dept';
        ao4.ucinn_ascendv2__Code__c = 'S010';
        aoList.add(ao4);

        insert aoList;
        
        ucinn_ascendv2__Designation__c desig1 = new ucinn_ascendv2__Designation__c();
        desig1.Name = 'ROCKNE TEST';
        desig1.ucinn_ascendv2__Designation_Name__c = 'Rockne Test';
        desig1.Unrestricted_Type__c = 'UNIVUNR';
        desig1.ucinn_ascendv2__G_L_Effective_Date__c = System.today();
        //desig1.ND_Division__c = ao1.Id;
        desig1.Sub_Department__c = ao3.Id;
        insert  desig1;  
        Opportunity o = [select id,Name,stageName,nd_Likelihood_to_Close__c,ucinn_ascendv2__Contact__c,Title__c,CloseDate from Opportunity  limit 1];
        ucinn_ascendv2__Designation_Detail__c dd2 = new ucinn_ascendv2__Designation_Detail__c();
        dd2.ucinn_ascendv2__Session__c = sess1.Id;
        dd2.ucinn_ascendv2__Opportunity__c = o.Id;
        dd2.ucinn_ascendv2__Contact__c = c.Id;
        dd2.ucinn_ascendv2__Amount__c = 2500;
        dd2.ucinn_ascendv2__Designation__c = desig1.Id;
        Insert dd2;        
        
        ucinn_ascendv2__Payment__c pmt1 = new ucinn_ascendv2__Payment__c();
        pmt1.ucinn_ascendv2__Contact__c = c.Id;
        pmt1.ucinn_ascendv2__Transaction_Type__c = 'Outright Gift';
        pmt1.ucinn_ascendv2__Status__c = 'Paid';
        pmt1.ucinn_ascendv2__Tender_Type_for_Gifts__c = 'Cash';
        pmt1.ucinn_ascendv2__Payment_Amount__c = 250000;
        pmt1.ucinn_ascendv2__Credit_Date__c = System.today();
        pmt1.ucinn_ascendv2__Session__c = sess1.Id;
        pmt1.ucinn_ascendv2__Opportunity__c = o.Id;
        pmt1.ucinn_ascendv2__Designation__c = desig1.Id;
        pmt1.ucinn_ascendv2__Designation_Detail__c = dd2.Id;
        pmt1.ucinn_ascendv2__Receipt_Number__c ='1234';
    

        insert pmt1;
        delete [select id from ucinn_ascendv2__Tribute__c limit 1];
                ucinn_ascendv2__Designation_Detail__c d = [select id,Name,ucinn_ascendv2__Opportunity__c from ucinn_ascendv2__Designation_Detail__c where ucinn_ascendv2__Opportunity__c=:o.id limit 1];
        ucinn_ascendv2__Hard_and_Soft_Credit__c hs = new ucinn_ascendv2__Hard_and_Soft_Credit__c(ucinn_ascendv2__Contact__c=c.id,ucinn_ascendv2__Credit_Type__c='Hard',Name='Test1',ucinn_ascendv2__Designation_Detail__c=d.id,ucinn_ascendv2__Opportunity__c=o.id,ucinn_ascendv2__Credit_Amount__c=110.0);
        insert hs;
        Test.stopTest();
        hs.nd_Acknowledgment_Status__c ='RE';
        update hs;
    }  
  
    @isTest
    static void insertrec5(){
        Test.startTest();
        list<ucinn_ascendv2__Service_Indicator__c> ndServInd = new list<ucinn_ascendv2__Service_Indicator__c>();
        Account a = [select id,ucinn_ascendv2__Email__c,RecordTypeId from Account where Name = 'Test' limit 1];
        Contact c = [select id,FirstName,LastName,AccountId,nd_SIG__c,email from Contact limit 1];
        Opportunity o1 = [select id,Name,stageName,nd_Likelihood_to_Close__c,ucinn_ascendv2__Contact__c,Title__c,CloseDate from Opportunity where Name= '[Default Name 1]'  limit 1];
        ucinn_ascendv2__Designation_Detail__c d1 = [select id,Name,ucinn_ascendv2__Opportunity__c from ucinn_ascendv2__Designation_Detail__c where ucinn_ascendv2__Opportunity__c=:o1.id limit 1];
        ucinn_ascendv2__Hard_and_Soft_Credit__c hs = new ucinn_ascendv2__Hard_and_Soft_Credit__c(ucinn_ascendv2__Contact__c=c.id,ucinn_ascendv2__Credit_Type__c='Hard',Name='Test1',ucinn_ascendv2__Designation_Detail__c=d1.id,ucinn_ascendv2__Opportunity__c=o1.id,ucinn_ascendv2__Credit_Amount__c=1000000);
        insert hs;
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateAckStatusandAckDate() {
        Account a = [SELECT Id, ucinn_ascendv2__Email__c, RecordTypeId FROM Account WHERE Name = 'Test' LIMIT 1];
        Contact c = [SELECT Id, FirstName, LastName, AccountId, nd_SIG__c, email FROM Contact LIMIT 1];
        Opportunity o1 = [SELECT Id, Name, StageName, nd_Likelihood_to_Close__c, ucinn_ascendv2__Contact__c, Title__c, CloseDate FROM Opportunity WHERE Name = '[Default Name 1]' LIMIT 1];
        ucinn_ascendv2__Designation_Detail__c d1 = [SELECT Id, Name, ucinn_ascendv2__Opportunity__c FROM ucinn_ascendv2__Designation_Detail__c WHERE ucinn_ascendv2__Opportunity__c = :o1.Id LIMIT 1];

        // Create initial record with 'RV' status
        ucinn_ascendv2__Hard_and_Soft_Credit__c initialRecord = new ucinn_ascendv2__Hard_and_Soft_Credit__c(
            nd_Acknowledgment_Status__c = 'RV',
            ucinn_ascendv2__Receipt_Number__c = '12345',
            ucinn_ascendv2__Credit_Type__c = 'Hard',
            ucinn_ascendv2__Designation_Detail__c = d1.Id,
            ucinn_ascendv2__Credit_Amount__c = 1000000
        );
        insert initialRecord;

        // Create another record with the same receipt number and 'RV' status
        ucinn_ascendv2__Hard_and_Soft_Credit__c anotherRecord = new ucinn_ascendv2__Hard_and_Soft_Credit__c(
            nd_Acknowledgment_Status__c = 'RV',
            ucinn_ascendv2__Receipt_Number__c = '12345',
            ucinn_ascendv2__Credit_Type__c = 'Hard',
            ucinn_ascendv2__Designation_Detail__c = d1.Id,
            ucinn_ascendv2__Credit_Amount__c = 1000000
        );
        insert anotherRecord;

        // Update initial record to 'RE' status to trigger the condition
        initialRecord.nd_Acknowledgment_Status__c = 'RE';
        update initialRecord;

        // Add the updated record to the list and map for the method call
        List<ucinn_ascendv2__Hard_and_Soft_Credit__c> newRec = new List<ucinn_ascendv2__Hard_and_Soft_Credit__c>{ initialRecord };
        Map<Id, ucinn_ascendv2__Hard_and_Soft_Credit__c> oldMap = new Map<Id, ucinn_ascendv2__Hard_and_Soft_Credit__c>{ initialRecord.Id => initialRecord };

        // Call the method
        Test.startTest();
        Nd_HardandSoftCreditTriggerHandler.updateAckStatusandAckDate(newRec, oldMap);
        Test.stopTest();

        // Verify the anotherRecord is updated
        anotherRecord = [SELECT nd_Acknowledgment_Status__c, nd_Acknowledgement_Status_Date__c FROM ucinn_ascendv2__Hard_and_Soft_Credit__c WHERE Id = :anotherRecord.Id];
        System.assertEquals('RE', anotherRecord.nd_Acknowledgment_Status__c);
        System.assertEquals(System.today(), anotherRecord.nd_Acknowledgement_Status_Date__c);
    }
  
}