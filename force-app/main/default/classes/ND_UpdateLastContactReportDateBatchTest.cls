@isTest
public class ND_UpdateLastContactReportDateBatchTest {
    @testSetup
   public static void testmethod1(){
       User prmUser= [select id FROM User limit 1 ];
       Id householdRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
       Id corpOrgRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporations and Organizations Details').getRecordTypeId();
       Account acc01 = new Account(name='test1',ND_Household_Types__c='C', ND_Household_Category__c='AS',BillingStreet='Test St',BillingCity='City of Test',BillingCountry='United States',RecordTypeId=householdRecTypeId,nd_LastCRDate__c= Date.newInstance(2022, 06, 09),ucinn_ascendv2__PRM__c=prmUser.id);
       insert acc01;
       Account accorp1 = new Account(name='test2',ucinn_ascendv2__Preferred_Address_Type__c='O',BillingStreet='Test St',BillingCity='City of Test',BillingCountry='United States',RecordTypeId=corpOrgRecTypeId,nd_LastCRDate__c= Date.newInstance(2022, 06, 09),ucinn_ascendv2__PRM__c=prmUser.id);
       insert accorp1;
       ucinn_ascendv2__Contact_Report__c conrep1 = new ucinn_ascendv2__Contact_Report__c(Name='testrec1',ucinn_ascendv2__Account__c=acc01.id,Author__c=prmUser.id,ucinn_ascendv2__Contact_Method__c='Email',Purpose__c='A',Objective__c='test',Significant_Visit_Details__c='test',Actions_Next_Steps__c='test',CreatedDate=Date.newInstance (2022,06,09));
       insert conrep1;
       ucinn_ascendv2__Contact_Report__c conrep2 = new ucinn_ascendv2__Contact_Report__c(Name='testrec2',ucinn_ascendv2__Account__c=acc01.id,Author__c=prmUser.id,ucinn_ascendv2__Contact_Method__c='Email',Purpose__c='A',Objective__c='test',Significant_Visit_Details__c='test',Actions_Next_Steps__c='test');
       insert conrep2;

    }
     @istest
    public static void TestMethod02(){
        
        //ucinn_ascendv2__Contact_Report__c cr =[select id, Author__c,CreatedDate from  ucinn_ascendv2__Contact_Report__c where Name='testrec1']; 
        Account ac = [select id,ucinn_ascendv2__PRM__c,nd_LastCRDate__c from Account where Name='test1'];
        ucinn_ascendv2__Contact_Report__c cr = new ucinn_ascendv2__Contact_Report__c();
        cr.Name='test3';
        cr.Actions_Next_Steps__c='test1';
        cr.Author__c=ac.ucinn_ascendv2__PRM__c;
        cr.ucinn_ascendv2__Account__c=ac.id;
        cr.ucinn_ascendv2__Contact_Method__c='Email';
        cr.Purpose__c='A';
        cr.Objective__c='test';
        cr.Significant_Visit_Details__c='test';
        cr.CreatedDate=Date.newInstance(2022, 06, 09);
        insert cr;
        if(ac.ucinn_ascendv2__PRM__c == cr.Author__c){
        ac.nd_LastCRDate__c = cr.CreatedDate.Date();
        }
        else{
           ac.nd_LastCRDate__c = Null; 
        }
        update ac;
        Test.startTest();
        ND_UpdateLastContactReportDateBatch t = new ND_UpdateLastContactReportDateBatch();
        DataBase.executeBatch(t); 
        Test.stopTest();

    }
    
    static testMethod void scheduleBatch() {        
        test.starttest();
        ND_UpdateLastContactReportDateBatch i = new ND_UpdateLastContactReportDateBatch();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, i);
        test.stopTest();
    }
}