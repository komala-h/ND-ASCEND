@isTest
public class ND_massUploadStewardshipAssetsTest {
	@testSetup
    public static void setup(){
        Id householdRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        TracHier.HierarchyAPI.setTriggerDisabled();
        Account household01 = new Account();
        household01.Name = 'TEST HOUSEHOLD 01';
        household01.BillingStreet = 'Test St';
        household01.BillingCity = 'City of Test';
        household01.BillingCountry = 'United States';
        household01.RecordTypeId = householdRecTypeId;
        insert household01;
        
        Contact h01 = new Contact();
        h01.AccountId = household01.Id;
        h01.FirstName = 'h01';
        h01.LastName = 'TEST';
        h01.ucinn_ascendv2__Gender__c = 'Male';
        h01.ucinn_ascendv2__Contact_Type__c = 'AL';
        h01.ucinn_ascendv2__Personal_Email__c = 'sample@abc.com';
        h01.Constituent_Status__c = 'A';
        h01.ucinn_ascendv2__Preferred_Class_Year__c = '2014';
        insert h01;
        
        Contact w01 = new Contact();
        w01.AccountId = household01.Id;
        w01.FirstName = 'w01';
        w01.LastName = 'TEST';
        w01.ucinn_ascendv2__Gender__c = 'Female';
        w01.ucinn_ascendv2__Contact_Type__c = 'AL';
        w01.ucinn_ascendv2__Personal_Email__c = 'sample2@abc.com';
        w01.Constituent_Status__c = 'A';
        w01.ucinn_ascendv2__Preferred_Class_Year__c = '2015';
        insert w01;
        
        household01.ucinn_ascendv2__Primary_Contact__c=h01.id;
        household01.Secondary_Constituent__c = w01.Id;
        Update household01;
        
        Product2 prod = new Product2();
        prod.Name = 'Mase';
        prod.RecordTypeId = Product2.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Item').getRecordTypeId();
        prod.ProductCode ='BB01';
        insert prod;
        
        ucinn_ascendv2__Giving_Society__c givingSociety = new ucinn_ascendv2__Giving_Society__c();
        givingSociety.Name = 'Sorin Society';
        givingSociety.ucinn_ascendv2__Status__c = 'Active';
        insert givingSociety;
        
        Opportunity opp = new Opportunity(ND_Pipeline__c='OL', 
                                          RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Gift').getRecordTypeId(),
                                          ucinn_ascendv2__Contact__c =h01.id ,
                                          type='V',
                                          name='testOpp',
                                          Title__c='testOpp',
                                          stageName='Pending',
                                          nd_Likelihood_to_Close__c=2.0,
                                          CloseDate=system.today(),
                                          ucinn_ascendv2__Credit_Date__c = System.today()
                                         );
        insert opp;
        
        Case case01 = new Case();
        case01.ContactId = h01.Id;
        case01.Status = 'New';
        case01.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Research Requests').getRecordTypeId();
        case01.Requested_By__c = UserInfo.getUserId();
        case01.Request_Purpose__c = 'Other';
        case01.Initiate_Request__c = 'test';
        case01.Strategy_Change__c = 'test';
        case01.Research_Reason__c = 'Test';
        case01.Is_this_a_referral__c = 'No';
        case01.Is_this_request_for_an_upcoming_Ask__c = 'No';
        insert case01;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'sfarris', Email='sfarris@tntech.edu', 
            EmailEncodingKey='UTF-8', LastName='Farris', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='sfarris@tntech.edu');
     	insert u;
    }
    
    static testMethod void method1() {
        TracHier.HierarchyAPI.setTriggerDisabled();
        list<contact> con = [select id from Contact where FirstName='h01'];
		list<Product2> prod = [select id from Product2 limit 1];
        list<ucinn_ascendv2__Giving_Society__c> gs = [select id from ucinn_ascendv2__Giving_Society__c limit 1];
        
        Id contactId = con[0].id;
        Id productId = prod[0].id;
        Id givingSocId = gs[0].id;
        
        String str = JSON.serialize('Name,ConstituentID,ProductId,GivingSocietyId,FullfilledDate\ntest,'+contactId+','+productId+','+givingSocId+',2023-05-09');        
        ND_massUploadStewardshipAssets.saveFile(str,'Giving_Society_Acknowledgements');
    }
    
    static testMethod void method2() {
        TracHier.HierarchyAPI.setTriggerDisabled();
        list<contact> con = [select id from Contact where FirstName='h01' limit 1];
		list<Product2> prod = [select id from Product2 limit 1];
        list<Account> acc = [select id from Account limit 1];
        list<ucinn_ascendv2__Giving_Society__c> gs = [select id from ucinn_ascendv2__Giving_Society__c limit 1];
        list<Opportunity> opp = [select id from Opportunity limit 1];
        list<Case> c = [select id from Case limit 1];
        list<user> u = [select id from user limit 1];
        Id contactId = con[0].id;
        Id productId = prod[0].id;
        Id givingSocId = gs[0].id;
        Id accountId = acc[0].id;
        Id oppId = opp[0].id;
        Id caseId = c[0].id;
        Id userId = u[0].id;
        
        String str = JSON.serialize('Name,ProductId,status,ConstituentID,AccountId,OpportunityId,CaseID,StewardshipAssId,Date\ntest,'+productId+',Approved,'+contactId+','+AccountId+','+oppId+','+caseId+','+userId+',2023-05-09');         
        ND_massUploadStewardshipAssets.saveFile(str,'Stewardship_Item');
    }
    
    static testMethod void method3() {
        TracHier.HierarchyAPI.setTriggerDisabled();
        list<contact> con = [select id from Contact where FirstName='h01' limit 1];
		list<Product2> prod = [select id from Product2 limit 1];
        list<Account> acc = [select id from Account limit 1];
        list<ucinn_ascendv2__Giving_Society__c> gs = [select id from ucinn_ascendv2__Giving_Society__c limit 1];
        list<Opportunity> opp = [select id from Opportunity limit 1];
        list<Case> c = [select id from Case limit 1];
        list<user> u = [select id from user limit 1];
        Id contactId = con[0].id;
        Id productId = prod[0].id;
        Id givingSocId = gs[0].id;
        Id accountId = acc[0].id;
        Id oppId = opp[0].id;
        Id caseId = c[0].id;
        Id userId = u[0].id;
        
        String str = JSON.serialize('Name,ConstituentID,ProductId,GivingSocietyId,FullfilledDate,Quantity,Price,AccountId,Status\ntest,'+contactId+','+productId+','+givingSocId+',2023-05-09,30,80,'+AccountId+',Qualified');        
        ND_massUploadStewardshipAssets.saveFile(str,'Membership_Benefit');
    }
}