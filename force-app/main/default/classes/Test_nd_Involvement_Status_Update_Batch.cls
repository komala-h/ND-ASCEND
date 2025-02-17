@isTest
public class Test_nd_Involvement_Status_Update_Batch {
    
    // Test method to cover the batch class functionality
    static testMethod void testBatchClass() {
        // Create test data
        List<ucinn_ascendv2__Involvement__c> invList = new List<ucinn_ascendv2__Involvement__c>();
        for(Integer i = 0; i < 5; i++) {
            ucinn_ascendv2__Involvement__c inv = new ucinn_ascendv2__Involvement__c(
                Name = 'Involvement ' + i,
                ucinn_ascendv2__Status__c = 'A',
                Data_Source__c='P19',
                ucinn_ascendv2__End_Date__c = Date.today().addDays(-i)
            );
            invList.add(inv);
        }
        insert invList;
        
        // Start the batch job
        Test.startTest();
        nd_Involvement_Status_Update_Batch batchClass = new nd_Involvement_Status_Update_Batch();
        Database.executeBatch(batchClass);
        Test.stopTest();
    }
    
    // Test method to cover the scheduled class
   /* static testMethod void testScheduledClass() {
        // Schedule the batch job
        Test.startTest();
        String jobId = System.schedule('nd_Involvement_Status_batch_Schedule', 
                                        '0 0 1 1 * ?', 
                                        new nd_Involvement_Status_batch_Schedule());
        Test.stopTest();
    } */
    
    @isTest
    private static void updateEndDate(){
      //  list<ucinn_ascendv2__Service_Indicator__c> si = [SELECT Id, ucinn_ascendv2__Start_Date__c, ucinn_ascendv2__End_Date__c,ucinn_ascendv2__Is_Active__c FROM ucinn_ascendv2__Service_Indicator__c limit 1]; 
        Test.startTest();
        nd_Involvement_Status_Update_Batch u = new nd_Involvement_Status_Update_Batch();
        DataBase.executeBatch(u); 
        Test.stopTest();
    }
    
    @istest
    public static void checkSendEmail(){
        test.startTest();
        nd_Involvement_Status_Update_Batch n = new nd_Involvement_Status_Update_Batch();
        n.sendEmail('error message');        
        test.stopTest();
    }
    
    @isTest
    static void scheduleBatch() {        
        test.starttest();
        nd_Involvement_Status_Update_Batch n = new nd_Involvement_Status_Update_Batch();   
        String chron = '0 0 23 * * ?'; 
        String jobName = 'MyBatchJob';
     //   system.schedule(jobName, chron, n);
        test.stopTest();
    }
}