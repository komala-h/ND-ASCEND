@isTest
public class ManageMySubscriptions_LeadTest {
	@Testsetup
    static void setup() {
        Lead ld = new Lead(Firstname = 'TestFirst', LastName = 'TestLast', Email = 'testemail@test.com', Email_Type__c = 'M', Company = 'Notredame');
        insert ld;
        
        ucinn_ascendv2__Service_Indicator_Value__c si1 = new ucinn_ascendv2__Service_Indicator_Value__c(Name = 'Test1', Public_Name__c = 'Test1', Public__c = TRUE, nd_MID__c = '524005560');
        ucinn_ascendv2__Service_Indicator_Value__c si2 = new ucinn_ascendv2__Service_Indicator_Value__c(Name = 'Test2', Public_Name__c = 'Test2', Public__c = TRUE, nd_MID__c = '524005560');
        insert new list<ucinn_ascendv2__Service_Indicator_Value__c>{si1, si2};
        
        ucinn_ascendv2__Service_Indicator__c lm = new ucinn_ascendv2__Service_Indicator__c(ucinn_ascendv2__Service_Indicator_Value__c = si1.Id, nd_Lead__c = ld.Id, Status__c = 'Exclude', nd_Comments__c = '',Data_Source__c='MC');
        insert lm;
    } 
    
    static testMethod void validateLoad_NoParameters() {
        test.startTest();
        Lead ld = [SELECT Id, FirstName, LastName, Email FROM Lead WHERE Email =: 'testemail@test.com'];
        string listId = [SELECt Id FROM ucinn_ascendv2__Service_Indicator_Value__c WHERE Name = 'Test1'].Id;
        
        try{
            ManageMySubscriptions_Lead mms = new ManageMySubscriptions_Lead();
        }
        catch(Exception e){
            System.assertEquals(false, String.isBlank(e.getMessage()));
        }
        test.stopTest();
    }
    
    static testMethod void validateLoad_ContactIdParam() {
        test.startTest();
        Lead ld = [SELECT Id, FirstName, LastName, Email FROM Lead WHERE Email =: 'testemail@test.com'];
        string listId = [SELECt Id FROM ucinn_ascendv2__Service_Indicator_Value__c WHERE Name = 'Test1'].Id;
        
        Test.setCurrentPageReference(new PageReference('Page.ManageMySubscriptions_Lead'));
        System.currentPageReference().getParameters().put('cId', ld.Id);
        System.currentPageReference().getParameters().put('sId', listId);
        System.currentPageReference().getParameters().put('mId', '524005560');
        
        ManageMySubscriptions_Lead mms = new ManageMySubscriptions_Lead();
                
        for (ucinn_ascendv2__Service_Indicator__c lm : mms.serviceIndicators.values()) {
            if (!string.isEmpty(lm.Id)) { 
                lm.Status__c = 'Include';
            } else {
                lm.Status__c = 'Exclude';
            }
            lm.Data_Source__c='MC';
        }
        mms.unsubscribeReason = 'test reason';
                
        mms.updateAllSubscriptions();
        mms.updateSubscription();
        
        test.stopTest();
    }
    
    static testMethod void validateLoad_ContactAndSubscriptionIdParams() {
        test.startTest();
        Lead ld = [SELECT Id, FirstName, LastName, Email FROM Lead WHERE Email =: 'testemail@test.com'];
        string listId = [SELECt Id FROM ucinn_ascendv2__Service_Indicator_Value__c WHERE Name = 'Test1'].Id;
        
        Test.setCurrentPageReference(new PageReference('Page.ManageMySubscriptions'));
        System.currentPageReference().getParameters().put('cId', ld.Id);
        System.currentPageReference().getParameters().put('sId', listId);
        System.currentPageReference().getParameters().put('mId', '524005560');
        
        ManageMySubscriptions_Lead mms = new ManageMySubscriptions_Lead();
        mms.updateSubscription();
        mms.updateAllSubscriptions();
        test.stopTest();
    }
    
    static testMethod void validateLeadInfoUpdate() {
        Lead ld = [SELECT Id, FirstName, LastName, Email FROM Lead WHERE Email =: 'testemail@test.com'];
        string listId = [SELECt Id FROM ucinn_ascendv2__Service_Indicator_Value__c WHERE Name = 'Test1'].Id;
        
        Test.setCurrentPageReference(new PageReference('Page.ManageMySubscriptions'));
        System.currentPageReference().getParameters().put('cId', ld.Id);
        System.currentPageReference().getParameters().put('sId', listId);
        System.currentPageReference().getParameters().put('mId', '524005560');
        
        test.startTest();
        ManageMySubscriptions_Lead mms = new ManageMySubscriptions_Lead();
        list<SelectOption> eTypes = mms.getEmailTypes;
        mms.fName = ld.firstName + 'test';
        mms.updateLeadInfo();
        test.stopTest();
        system.assertEquals('TestFirsttest', [SELECT FirstName FROM Lead WHERE Id =: ld.Id].FirstName);    
   	}
    /*
    static testMethod void validateCaseCreationWhenConPrefCommentUpdated() {
        Lead ld = [SELECT Id, FirstName, LastName, Email FROM Lead WHERE Email =: 'testemail@test.com'];
        string listId = [SELECt Id FROM ucinn_ascendv2__Service_Indicator_Value__c WHERE Name = 'Test1'].Id;
        
        ucinn_ascendv2__Service_Indicator__c lm1 = new ucinn_ascendv2__Service_Indicator__c(ucinn_ascendv2__Service_Indicator_Value__c = listId, nd_Lead__c = ld.Id, ucinn_ascendv2__Start_Date__c = system.today(), Status__c = 'Exclude', 
                                                               nd_Comments__c = '',Data_Source__c='MC');
        ucinn_ascendv2__Service_Indicator__c lm2 = new ucinn_ascendv2__Service_Indicator__c(ucinn_ascendv2__Service_Indicator_Value__c = listId, nd_Lead__c = ld.Id, ucinn_ascendv2__Start_Date__c = system.today(), Status__c = 'Exclude', 
                                                               nd_Comments__c = '',Data_Source__c='MC');
        insert new list<ucinn_ascendv2__Service_Indicator__c>{lm1, lm2};
        
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.ManageMySubscriptions'));
        System.currentPageReference().getParameters().put('cId', ld.Id);
        System.currentPageReference().getParameters().put('sId', listId);
        System.currentPageReference().getParameters().put('mId', '524005560');
        
        ManageMySubscriptions mms = new ManageMySubscriptions();
        list<SelectOption> ls = new list<SelectOption>();
        ls=mms.getUnsubReasons();
        mms.recordCheck();
        mms.unsubscribeReason = 'Other';
        Test.stopTest();
    }
*/
}