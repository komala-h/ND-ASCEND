/*
* Author: UCInnovation, qluong
* Date:02/13/2024
* Description: schedulable asc_SCHED_GivingSummaryCalcAccount class
*/
global class asc_SCHED_GivingSummaryCalcAccount implements Schedulable {   
       
   
    global void execute(SchedulableContext ct) {
        asc_BATCH_GivingSummaryCalcAccount batch = new asc_BATCH_GivingSummaryCalcAccount();
        Database.executeBatch(batch, 200);
    }                                
}