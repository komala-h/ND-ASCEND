@isTest
private class UpdateVIPReasonAsManuallyDesignatedTest {
	@testSetup
    static void setup(){
        Account acc = new Account(Name = 'ND Club Of Test',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId());   
        insert acc;
        
        Contact con = new Contact(Firstname = 'TestFirst', LastName = 'TestLast', Email = 'testemail@test.com',AccountId = acc.Id,Constituent_Status__c='A',ND_VIP_Reason__c='M',ND_VIP__c=false);
        Contact con1 = new Contact(Firstname = 'TestFirst1', LastName = 'TestLast', Email = 'testemail@test.com',AccountId = acc.Id,ucinn_ascendv2__Lifetime_Fundraising__c = 10000000,Constituent_Status__c='A',ND_VIP_Reason__c='D;M', ND_VIP__c=false);
		Contact con2 = new Contact(Firstname = 'TestFirst2', LastName = 'TestLast', Email = 'testemail@test.com',AccountId = acc.Id,ucinn_ascendv2__Lifetime_Fundraising__c = 10000000,Constituent_Status__c='A',ND_VIP_Reason__c='D',ND_VIP__c=false);
        Contact con3 = new Contact(Firstname = 'TestFirst3', LastName = 'TestLast', Email = 'testemail@test.com',AccountId = acc.Id,ucinn_ascendv2__Lifetime_Fundraising__c = 10000000,Constituent_Status__c='A',ND_VIP_Reason__c='I;M',ND_VIP__c=true);
        Contact con4 = new Contact(Firstname = 'TestFirst4', LastName = 'TestLast', Email = 'testemail@test.com',AccountId = acc.Id,ucinn_ascendv2__Lifetime_Fundraising__c = 10000000,Constituent_Status__c='A',ND_VIP__c=false);
        Contact con7 = new Contact(Firstname = 'TestFirst4', LastName = 'TestLast', Email = 'testemail@test.com',AccountId = acc.Id,ucinn_ascendv2__Lifetime_Fundraising__c = 1000,Constituent_Status__c='A',ND_VIP__c=true);
        Contact con5 = new Contact(Firstname = 'TestFirst5', LastName = 'TestLast', Email = 'testemail@test.com',AccountId = acc.Id,ucinn_ascendv2__Lifetime_Fundraising__c = 1000,Constituent_Status__c='A',ND_VIP_Reason__c='M',ND_VIP__c=true);
        Contact con6 = new Contact(Firstname = 'TestFirst6', LastName = 'TestLast', Email = 'testemail@test.com',AccountId = acc.Id,ucinn_ascendv2__Lifetime_Fundraising__c = 10000,Constituent_Status__c='A',ND_VIP_Reason__c='D;M',ND_VIP__c=true);
		insert new list<Contact>{con,con1,con2,con3,con4,con5,con6,con7};
    }
    
    @isTest
    private static void test1(){
        list<Contact> conList = [ Select id,Firstname,LastName,Email,Constituent_Status__c,ND_VIP_Reason__c,ND_VIP__c,ucinn_ascendv2__Lifetime_Fundraising__c,AccountId from Contact ];
		
        List<UpdateVIPReasonAsManuallyDesignated.FlowInputs> flowInputList=new List<UpdateVIPReasonAsManuallyDesignated.FlowInputs>();    
        UpdateVIPReasonAsManuallyDesignated.FlowInputs finput=new UpdateVIPReasonAsManuallyDesignated.FlowInputs();
        finput.constituents = conList;
        finput.ToAdd = true;
        flowInputList.add(finput);
        
        Test.startTest();
        UpdateVIPReasonAsManuallyDesignated.updateConstituents(flowInputList);
        Test.stopTest();
    }
    
    @isTest
    private static void test2(){
        list<Contact> conList = [ Select id,Firstname,LastName,Email,Constituent_Status__c,ND_VIP_Reason__c,ND_VIP__c,ucinn_ascendv2__Lifetime_Fundraising__c,AccountId from Contact];
		
        List<UpdateVIPReasonAsManuallyDesignated.FlowInputs> flowInputList=new List<UpdateVIPReasonAsManuallyDesignated.FlowInputs>();    
        UpdateVIPReasonAsManuallyDesignated.FlowInputs finput=new UpdateVIPReasonAsManuallyDesignated.FlowInputs();
        finput.constituents = conList;
        finput.ToAdd = false;
        flowInputList.add(finput);
        
        Test.startTest();
        UpdateVIPReasonAsManuallyDesignated.updateConstituents(flowInputList);
        Test.stopTest();
    }
    
    
    
    
}