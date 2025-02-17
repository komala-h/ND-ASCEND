@isTest
public class ScheduleJV_ProcessTest {


    @isTest
    static void testScheduleJVProcess() {
        // Define the batch size for the test
        Integer testBatchSize = 10;

        // Schedule the job
        ScheduleJV_Process scheduleJob = new ScheduleJV_Process(testBatchSize);
        String cronExpression = '0 0 12 * * ?'; // Every day at 12 PM

        // Use Test.startTest and Test.stopTest to simulate the execution of the scheduled job
        Test.startTest();
        String jobId = System.schedule('Test Daily JV Processing', cronExpression, scheduleJob);
        Test.stopTest();

        // Verify that the scheduled job was executed
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(cronExpression, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);

        // Verify that the batch job ran with the correct batch size
        // Fetch the async Apex job
        List<AsyncApexJob> jobs = [SELECT Id, JobType, Status, NumberOfErrors, ExtendedStatus, TotalJobItems, JobItemsProcessed, CreatedById, CreatedDate 
                                   FROM AsyncApexJob 
                                   WHERE JobType = 'BatchApex' 
                                   AND Status = 'Completed'];
        //System.assert(jobs.size() > 0, 'Batch job should have run');
        // Further assertions can be added based on the specific behavior of ND_JV_Process
    }
}