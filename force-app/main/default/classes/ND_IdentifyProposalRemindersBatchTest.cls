/*
 * Test class for : ND_IdentifyProposalRemindersBatch
 * 
*/
@isTest
private class ND_IdentifyProposalRemindersBatchTest {
	@testSetup
    public static void setup(){
        TracHier.HierarchyAPI.setTriggerDisabled();
        User prmUser= [select id FROM User limit 1 ];
        Campaign camp = new Campaign(name='testCampaign',status = 'In Progress');
        insert camp;
        
        Id householdRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        Id corpOrgRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporations and Organizations Details').getRecordTypeId();
        Id proposalRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Proposal').getRecordTypeId();
        
        Account household01 = new Account(name='test1',BillingStreet='Test St',BillingCity='City of Test',BillingCountry='United States',RecordTypeId=householdRecTypeId,nd_LastCRDate__c= Date.newInstance(2022, 06, 09),ucinn_ascendv2__PRM__c=prmUser.id);
        insert household01;
        Contact con01 = new Contact(FirstName = 'test01',LastName = 'Test02',AccountId = household01.Id,Constituent_Status__c='X');
        insert con01;
        Opportunity opp1 = new Opportunity(recordTypeid=proposalRecTypeId,accountID =household01.id ,type='V',name='testOpp1',Title__c='testOpp1',CampaignId=camp.id,stageName='Planning',nd_Likelihood_to_Close__c=2.0,ucinn_ascendv2__Submitted_Date__c=system.today(),closeDate = system.today(),ucinn_ascendv2__Submitted_Amount__c=2000,nd_ApprovedDate__c=null,nd_PendingDate__c=null,ContactId=con01.id);
        insert opp1;
   
        Account corp1 = new Account(name='test123',ucinn_ascendv2__Preferred_Address_Type__c='O',BillingStreet='Test St',BillingCity='City of Test',BillingCountry='United States',RecordTypeId=corpOrgRecTypeId,nd_LastCRDate__c= Date.newInstance(2022, 06, 09),ucinn_ascendv2__PRM__c=prmUser.id);
        insert corp1;
        Contact con02 = new Contact(FirstName = 'test01',LastName = 'Test02',AccountId = corp1.Id,Constituent_Status__c='X');
        insert con02;
        Opportunity opp2 = new Opportunity(recordTypeid=proposalRecTypeId,accountID =corp1.id ,type='V',ucinn_ascendv2__Submitted_Amount__c=1000,Title__c='testOpp2',name='test123',CampaignId=camp.id,stageName='Planning',nd_Likelihood_to_Close__c=2.0,ucinn_ascendv2__Submitted_Date__c=system.today(),closeDate = system.today(),nd_LeadPP__c=false,ContactId=con02.id);
        insert opp2; 
        
    }
        
    // Planning stage with no active proposal primary.
    @istest
    public static void HHTestMethod01(){
        TracHier.HierarchyAPI.setTriggerDisabled();
        Opportunity opp=[select id,accountId,ucinn_ascendv2__Submitted_Date__c,nd_Aging_Status_Code_Value__c,CloseDate,StageName from opportunity where title__c='testOpp1'];
    	opp.StageName='Planning';
        opp.nd_Aging_Status_Code_Value__c = 'R';
        update opp;
        Account acc = [select id,ucinn_ascendv2__PRM__c from account where id=:opp.AccountId];
        acc.ucinn_ascendv2__PRM__c=null;
        update acc;
        Test.startTest();
        ND_IdentifyProposalRemindersBatch t = new ND_IdentifyProposalRemindersBatch();
        DataBase.executeBatch(t); 
        Test.stopTest();
    }
    
    // Planning stage with no active proposal primary --> corporations and Org
    @istest
    public static void CORPTestMethod01(){
        TracHier.HierarchyAPI.setTriggerDisabled();
        Opportunity opp=[select id,accountId,nd_Aging_Status_Code_Value__c,ucinn_ascendv2__Submitted_Date__c,CloseDate,StageName,nd_LeadPP__c from opportunity where Title__c='testOpp2'];
    	opp.StageName='Planning';
        opp.nd_LeadPP__c= true;
        opp.nd_Aging_Status_Code_Value__c = 'R';
        update opp;
        Account acc = [select id,ucinn_ascendv2__PRM__c from account where id=:opp.AccountId];
        acc.ucinn_ascendv2__PRM__c=null;
        update acc;
        Test.startTest();
        ND_IdentifyProposalRemindersBatch t = new ND_IdentifyProposalRemindersBatch();
        DataBase.executeBatch(t); 
        Test.stopTest();
    }
    
    // Pending stage with no active proposal primary.
    @istest
    public static void HHTestMethodPendingNoActivePRM(){
        TracHier.HierarchyAPI.setTriggerDisabled();
        Opportunity opp=[select id,accountId,ucinn_ascendv2__Submitted_Date__c,nd_Aging_Status_Code_Value__c,CloseDate,StageName from opportunity where title__c='testOpp1'];
    	opp.StageName='Pending';
        opp.nd_Aging_Status_Code_Value__c = 'R';
        update opp;
        Account acc = [select id,ucinn_ascendv2__PRM__c from account where id=:opp.AccountId];
        acc.ucinn_ascendv2__PRM__c=null;
        update acc;
        Test.startTest();
        ND_IdentifyProposalRemindersBatch t = new ND_IdentifyProposalRemindersBatch();
        DataBase.executeBatch(t); 
        Test.stopTest();
    }
    
    // Planning stage with no active proposal primary --> corporations and Org
    @istest
    public static void CORPTestMethodPendingNoActivePRM(){
        TracHier.HierarchyAPI.setTriggerDisabled();
        Opportunity opp=[select id,accountId,nd_Aging_Status_Code_Value__c,ucinn_ascendv2__Submitted_Date__c,CloseDate,StageName,nd_LeadPP__c from opportunity where Title__c='testOpp2'];
    	opp.StageName='Pending';
        opp.nd_LeadPP__c= true;
        opp.nd_Aging_Status_Code_Value__c = 'R';
        update opp;
        Account acc = [select id,ucinn_ascendv2__PRM__c from account where id=:opp.AccountId];
        acc.ucinn_ascendv2__PRM__c=null;
        update acc;
        Test.startTest();
        ND_IdentifyProposalRemindersBatch t = new ND_IdentifyProposalRemindersBatch();
        DataBase.executeBatch(t); 
        Test.stopTest();
    }
    
    // approved stage for Household
    @istest
    public static void HHTestMethod08(){
        TracHier.HierarchyAPI.setTriggerDisabled();
        Opportunity opp=[select id,accountId,ucinn_ascendv2__Submitted_Date__c,nd_Aging_Status_Code_Value__c,nd_ApprovedDate__c,CloseDate,nd_PendingDate__c,StageName from opportunity where title__c='testOpp1'];
    	opp.nd_Answer_Date__c = system.today() + 15;
        opp.nd_Aging_Status_Code_Value__c = 'R';
      	opp.StageName='Approved';
        opp.nd_ApprovedDate__c = system.today().addDays(-32);
        update opp;
        Account acc = [select id,ucinn_ascendv2__PRM__c from account where id=:opp.AccountId];
        Test.startTest();
        ND_IdentifyProposalRemindersBatch t = new ND_IdentifyProposalRemindersBatch();
        DataBase.executeBatch(t); 
        Test.stopTest(); 
    }
    // approved stage --> corporations and Org  
    @istest
    public static void CORPTestMethod08(){
        TracHier.HierarchyAPI.setTriggerDisabled();
        Opportunity opp=[select id,accountId,ucinn_ascendv2__Submitted_Date__c,nd_Aging_Status_Code_Value__c,nd_ApprovedDate__c,CloseDate,nd_PendingDate__c,StageName,nd_LeadPP__c from opportunity where name='test123'];
    	opp.nd_Answer_Date__c = system.today();
        opp.StageName='Approved';
        opp.nd_Aging_Status_Code_Value__c = 'Y';
        opp.nd_ApprovedDate__c = system.today().addDays(-280);
        opp.nd_LeadPP__c=true;
        update opp;
        Account acc = [select id,ucinn_ascendv2__PRM__c from account where id=:opp.AccountId];
        Test.startTest();
        ND_IdentifyProposalRemindersBatch t = new ND_IdentifyProposalRemindersBatch();
        DataBase.executeBatch(t); 
        Test.stopTest(); 
    }
    
    // Pending stage with ask date within 30 days - household
    @istest
    public static void HHTestMethodPendingWithAskDatein30Days(){
        TracHier.HierarchyAPI.setTriggerDisabled();
        Opportunity opp=[select id,accountId,ucinn_ascendv2__Submitted_Date__c,nd_Aging_Status_Code_Value__c,StageName,CloseDate from opportunity where title__c='testOpp1'];
    	opp.ucinn_ascendv2__Submitted_Date__c = system.today() + 15;
        opp.StageName='Pending';
        opp.CloseDate = system.today() + 25;
        opp.nd_Aging_Status_Code_Value__c = 'Y';
        update opp;
        Account acc = [select id,ucinn_ascendv2__PRM__c from account where id=:opp.AccountId];
        Test.startTest();
        ND_IdentifyProposalRemindersBatch t = new ND_IdentifyProposalRemindersBatch();
        DataBase.executeBatch(t); 
        Test.stopTest();
    }
    
    // Pending stage with ask date within 30 days - Corporation
    @istest
    public static void CorpTestMethodPendingWithAskDatein30Days(){
        TracHier.HierarchyAPI.setTriggerDisabled();
        Opportunity opp=[select id,accountId,ucinn_ascendv2__Submitted_Date__c,nd_PendingDate__c,nd_Aging_Status_Code_Value__c,StageName,CloseDate from opportunity where title__c='testOpp2'];
    	opp.ucinn_ascendv2__Submitted_Date__c = system.today() + 15;
        opp.StageName='Pending';
        opp.CloseDate = system.today() + 25;
        opp.nd_PendingDate__c = system.today().addDays(-15);
        opp.nd_Aging_Status_Code_Value__c = 'Y';
        update opp;
        Account acc = [select id,ucinn_ascendv2__PRM__c from account where id=:opp.AccountId];
        Test.startTest();
        ND_IdentifyProposalRemindersBatch t = new ND_IdentifyProposalRemindersBatch();
        DataBase.executeBatch(t); 
        Test.stopTest();
    }
    
    @istest 
    public static void CORPTestMethod07(){
        TracHier.HierarchyAPI.setTriggerDisabled();
        Opportunity opp=[select id,accountId,ucinn_ascendv2__Submitted_Date__c,nd_ApprovedDate__c,nd_PendingDate__c,StageName,CloseDate,nd_LeadPP__c from opportunity where name='test123'];
    	opp.CloseDate = system.today() + 15;
        opp.StageName='Pending';
        opp.nd_PendingDate__c = system.today().addDays(-15);
        opp.nd_LeadPP__c=true;
        update opp;
        Account acc = [select id,ucinn_ascendv2__PRM__c from account where id=:opp.AccountId];
        Test.startTest();
        ND_IdentifyProposalRemindersBatch t = new ND_IdentifyProposalRemindersBatch();
        DataBase.executeBatch(t); 
        Test.stopTest();
    }
    
    @istest
    public static void CORPTestMethod05(){
        TracHier.HierarchyAPI.setTriggerDisabled();
        Opportunity opp=[select id,accountId,ucinn_ascendv2__Submitted_Date__c,StageName,CloseDate,nd_LeadPP__c from opportunity where name='test123'];
   		opp.ucinn_ascendv2__Submitted_Date__c = system.today();
        opp.StageName='Planning';
        opp.nd_LeadPP__c= true;
        opp.CloseDate = system.today() + 15;
        update opp;
        Account acc = [select id,ucinn_ascendv2__PRM__c,nd_LastCRDate__c from account where id=:opp.AccountId];
        Test.startTest();
        ND_IdentifyProposalRemindersBatch t = new ND_IdentifyProposalRemindersBatch();
        DataBase.executeBatch(t); 
        Test.stopTest();
    }

    @istest
    public static void CORPTestMethod04(){
        TracHier.HierarchyAPI.setTriggerDisabled();
        Opportunity opp=[select id,accountId,ucinn_ascendv2__Submitted_Date__c,CloseDate,StageName,nd_LeadPP__c from opportunity where name='test123'];
       	opp.ucinn_ascendv2__Submitted_Date__c = system.today().adddays(15);
        opp.StageName='Planning';
        opp.nd_LeadPP__c= true;
        opp.CloseDate = system.today() + 185;
        update opp;
        Account acc = [select id,ucinn_ascendv2__PRM__c,nd_LastCRDate__c from account where id=:opp.AccountId];
        acc.nd_LastCRDate__c = system.today().adddays(-195);
        update acc;
        Test.startTest();
        ND_IdentifyProposalRemindersBatch t = new ND_IdentifyProposalRemindersBatch();
        DataBase.executeBatch(t); 
        Test.stopTest();
    }    
    
    @istest
    public static void HHTestMethod04(){
        TracHier.HierarchyAPI.setTriggerDisabled();
        Opportunity opp=[select id,accountId,ucinn_ascendv2__Submitted_Date__c,CloseDate,StageName,nd_LeadPP__c from opportunity where name='testOpp1'];
       	opp.ucinn_ascendv2__Submitted_Date__c = system.today().adddays(15);
        opp.StageName='Planning';
        opp.CloseDate = system.today() + 185;
        update opp;
        Account acc = [select id,ucinn_ascendv2__PRM__c,nd_LastCRDate__c from account where id=:opp.AccountId];
        acc.nd_LastCRDate__c = system.today().adddays(-195);
        update acc;
        Test.startTest();
        ND_IdentifyProposalRemindersBatch t = new ND_IdentifyProposalRemindersBatch();
        DataBase.executeBatch(t); 
        Test.stopTest();
    } 

    @istest
    public static void CORPTestMethod011(){
        TracHier.HierarchyAPI.setTriggerDisabled();
        Opportunity opp=[select id,accountId,ucinn_ascendv2__Submitted_Date__c,nd_Aging_Status_Code_Value__c,CloseDate,StageName,nd_LeadPP__c from opportunity where name='test123'];
       	opp.ucinn_ascendv2__Submitted_Date__c = system.today().adddays(45);
        opp.StageName='Planning';
        opp.nd_LeadPP__c= true;
        opp.CloseDate = system.today()+50;
        update opp;
        opp.nd_Aging_Status_Code_Value__c = 'R';
        update opp;
        Account acc = [select id,ucinn_ascendv2__PRM__c,nd_LastCRDate__c from account where id=:opp.AccountId];
        acc.nd_LastCRDate__c = system.today().adddays(-95);
        update acc;
        Test.startTest();
        ND_IdentifyProposalRemindersBatch t = new ND_IdentifyProposalRemindersBatch();
        DataBase.executeBatch(t); 
        Test.stopTest();
    } 
    
    @istest
    public static void HHTestMethod011(){
        TracHier.HierarchyAPI.setTriggerDisabled();
        Opportunity opp=[select id,accountId,ucinn_ascendv2__Submitted_Date__c,nd_Aging_Status_Code_Value__c,CloseDate,StageName,nd_LeadPP__c from opportunity where name='testOpp1'];
       	opp.ucinn_ascendv2__Submitted_Date__c = system.today().adddays(45);
        opp.StageName='Planning';
        opp.CloseDate = system.today()+50;
        update opp;
        opp.nd_Aging_Status_Code_Value__c = 'R';
        update opp;
        Account acc = [select id,ucinn_ascendv2__PRM__c,nd_LastCRDate__c from account where id=:opp.AccountId];
        acc.nd_LastCRDate__c = system.today().adddays(-95);
        update acc;
        Test.startTest();
        ND_IdentifyProposalRemindersBatch t = new ND_IdentifyProposalRemindersBatch();
        DataBase.executeBatch(t); 
        Test.stopTest();
    } 
    static testMethod void scheduleBatch() {    
        TracHier.HierarchyAPI.setTriggerDisabled();
        test.starttest();
        ND_IdentifyProposalRemindersBatch i = new ND_IdentifyProposalRemindersBatch();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, i);
        test.stopTest();
    }
}