@isTest(SeeAllData=false)

public class SchedulePicklistSyncBatchTest {
    @isTest static void ftest(){
        Test.startTest();
        SchedulableContext a;
        SchedulePicklistSyncBatch.execute(a);
        Test.stopTest();
	}
}