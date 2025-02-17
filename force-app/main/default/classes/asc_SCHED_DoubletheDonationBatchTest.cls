/*
* Author: UCInnovation, qluong
* Date:6/08/2023
* Description: test class for schedulable asc_SCHED_DoubletheDonationBatch class
*/
@isTest
private class asc_SCHED_DoubletheDonationBatchTest {

    static testMethod void scheduletest() {        
         test.starttest();
         //asc_SCHED_DoubletheDonationBatch sched = new asc_SCHED_DoubletheDonationBatch();
         Map<String, Object> params = new Map<String, Object>();
         String whereClause = 'ucinn_ascendv2__Double_the_Donation_ID__c = null AND RecordType.Name = \'Corporations and Organizations Details\' limit 1';
         params.put('whereClause', whereClause);
         params.put('batchSize', 1);
         //sched.params = params;
         String chron = '0 0 23 * * ?';        
         system.schedule('Test Sched', chron, new asc_SCHED_DoubletheDonationBatch(params));
         test.stopTest();
    }
}