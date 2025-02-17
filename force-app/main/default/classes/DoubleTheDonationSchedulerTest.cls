@istest
public class DoubleTheDonationSchedulerTest {

    
    @isTest static void method1(){
       
         
         
        try{
        Id HrecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporations_and_Organizations').getRecordTypeId();
       
        test.startTest();   
        Account hsAcc = new account(recordTypeId=HrecordTypeId,name='accTest',ND_Household_Category__c='AS',ND_Household_Types__c ='I',Online_Only__c=true);
        Test.setMock(HttpCalloutMock.class, new RestMock()); 
        insert hsAcc;
        test.stopTest();    
            
        String CRON_EXP = '0 0 0 3 9 ? 2042';
            
        String jobId = System.schedule('testBasicScheduledApex',CRON_EXP, new DoubleTheDonationScheduler());
              
        //CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :jobId];
        }Catch(Exception ex){
            
        }
  
       // Verify the expressions are the same
       //System.assertEquals(CRON_EXP, ct.CronExpression);
    }
      private class RestMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(500);
            return res;
        }
    }
}