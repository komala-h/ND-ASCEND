/*
* @Author: UCInnovation / qluong
* @Date:2/14/2024
* @Description: test class for schedulable asc_SCHED_GivingSummaryCalcAccount class
*/

@isTest
private class asc_SCHED_GivingSummaryCalcAccountTest {

    static testMethod void scheduletest() {        
         test.starttest();
         
         String chron = '0 0 23 * * ?';        
         system.schedule('Test Sched', chron, new asc_SCHED_GivingSummaryCalcAccount());
         test.stopTest();
    }
}