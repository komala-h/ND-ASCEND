@isTest
public class ManageMySubscriptionsTest {
	@Testsetup
    static void setup() {
        Contact con = new Contact(Firstname = 'TestFirst', LastName = 'TestLast', Email = 'testemail@test.com',Constituent_Status__c='A');
        insert con;
        
        ucinn_ascendv2__Service_Indicator_Value__c si1 = new ucinn_ascendv2__Service_Indicator_Value__c(Name = 'Test1', Public_Name__c = 'Test1', Public__c = TRUE, nd_MID__c = '524005560');
        ucinn_ascendv2__Service_Indicator_Value__c si2 = new ucinn_ascendv2__Service_Indicator_Value__c(Name = 'Test2', Public_Name__c = 'Test2', Public__c = TRUE, nd_MID__c = '524005560');
        insert new list<ucinn_ascendv2__Service_Indicator_Value__c>{si1, si2};
        
        ucinn_ascendv2__Service_Indicator__c lm = new ucinn_ascendv2__Service_Indicator__c(ucinn_ascendv2__Service_Indicator_Value__c = si2.Id, ucinn_ascendv2__Contact__c = con.Id, Status__c = 'Exclude', nd_Comments__c = '',Data_Source__c='MC');
        insert lm;
    }
    
    static testMethod void validateLoad_NoParameters() {
        test.startTest();
        Contact con = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Email =: 'testemail@test.com'];
        string listId = [SELECt Id FROM ucinn_ascendv2__Service_Indicator_Value__c WHERE Name = 'Test1'].Id;
        
        try{
            ManageMySubscriptions mms = new ManageMySubscriptions();
        }
        catch(Exception e){
            System.assertEquals(false, String.isBlank(e.getMessage()));
        }
        test.stopTest();
    } 
    
    static testMethod void validateLoad_ContactIdParam() {
        test.startTest();
        Contact con = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Email =: 'testemail@test.com'];
        string listId = [SELECT Id FROM ucinn_ascendv2__Service_Indicator_Value__c WHERE Name = 'Test1'].Id;
        
        Test.setCurrentPageReference(new PageReference('Page.ManageMySubscriptions'));
        System.currentPageReference().getParameters().put('cId', con.Id);
        System.currentPageReference().getParameters().put('sId', listId);
        System.currentPageReference().getParameters().put('mId', '524005560');
        
        ManageMySubscriptions mms = new ManageMySubscriptions();
 
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
    
    static testmethod void validate_contactIdParamstoCreateInterim(){
        test.startTest();
        Contact con = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Email =: 'testemail@test.com'];
         
       	Test.setCurrentPageReference(new PageReference('Page.ManageMySubscriptions'));  
        System.currentPageReference().getParameters().put('cId', con.Id);
        System.currentPageReference().getParameters().put('mId', '524005560');
        
        ManageMySubscriptions mms = new ManageMySubscriptions();
        
        List<ucinn_ascendv2__Interim__c> interimList = new List<ucinn_ascendv2__Interim__c>();
        ucinn_ascendv2__Interim__c interim = new ucinn_ascendv2__Interim__c(RecordTypeId=[Select ID from RecordType where DeveloperName = 'Online_Donation_Interface'].id,
                          ucinn_ascendv2__Contact__c = con.id,
                          ucinn_ascendv2__First_Name__c = con.FirstName,
                          ucinn_ascendv2__Last_Name__c = con.LastName, 
                          ucinn_ascendv2__Status__c = 'New'
                          );
        												           
        interimList.add(interim);
        insert interimList;   
        
        mms.oFName = 'Testfirst1';
        mms.Email = 'test@test.com'; 
        mms.updateContactInfo();
        mms.EmailType = 'U'; 
      	mms.updateContactInfo();
       	mms.updateSubscription();
        mms.updateAllSubscriptions();
        test.stopTest();
        mms.updateContactInfo(); 
    }
    
    static testMethod void validateCaseCreationWhenConPrefCommentUpdated() {
        Contact con = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Email =: 'testemail@test.com'];
        string listId = [SELECt Id FROM ucinn_ascendv2__Service_Indicator_Value__c WHERE Name = 'Test1'].Id;
        
        ucinn_ascendv2__Service_Indicator__c lm1 = new ucinn_ascendv2__Service_Indicator__c(ucinn_ascendv2__Service_Indicator_Value__c = listId, ucinn_ascendv2__Contact__c = con.Id, ucinn_ascendv2__Start_Date__c = system.today(), Status__c = 'Exclude', 
                                                               nd_Comments__c = '',Data_Source__c='MC');
        ucinn_ascendv2__Service_Indicator__c lm2 = new ucinn_ascendv2__Service_Indicator__c(ucinn_ascendv2__Service_Indicator_Value__c = listId, ucinn_ascendv2__Contact__c = con.Id, ucinn_ascendv2__Start_Date__c = system.today(), Status__c = 'Exclude', 
                                                               nd_Comments__c = '',Data_Source__c='MC');
        insert new list<ucinn_ascendv2__Service_Indicator__c>{lm1, lm2};
        
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('Page.ManageMySubscriptions'));
        System.currentPageReference().getParameters().put('cId', con.Id);
        System.currentPageReference().getParameters().put('sId', listId);
        System.currentPageReference().getParameters().put('mId', '524005560');
        
        ManageMySubscriptions mms = new ManageMySubscriptions();
        mms.recordCheck();
        mms.unsubscribeReason = 'Other';
        mms.updateSubscription();
        mms.updateAllSubscriptions();
        Test.stopTest();
        
    }
}