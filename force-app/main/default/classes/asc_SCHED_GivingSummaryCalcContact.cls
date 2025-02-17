/*
* Author: UCInnovation, qluong
* Date:02/13/2024
* Description: schedulable asc_SCHED_GivingSummaryCalcContact class
*/
global class asc_SCHED_GivingSummaryCalcContact implements Schedulable {   
       
   
    global void execute(SchedulableContext ct) {
        asc_BATCH_GivingSummaryCalcContact batch = new asc_BATCH_GivingSummaryCalcContact();
        Database.executeBatch(batch, 1);
    }                                
}