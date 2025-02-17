/*
* Author: UCInnovation, qluong
* Date:6/08/2023
* Description: schedulable asc_SCHED_DoubletheDonationBatch class
*/
global class asc_SCHED_DoubletheDonationBatch implements Schedulable {   
    
    global Map<String, Object> params;
    
    /* 
    *Author: Cube84,Vikas
    *Date:6/16/2023
    *Description: Defined constructor to pass parameters
    */
    global asc_SCHED_DoubletheDonationBatch(Map<String, Object> filter){        
        this.params = filter;
    }
  
    global void execute(SchedulableContext ct) {
        ucinn_ascendv2.ascend_UTIL_RunBatch.ascend_GIFT_DoubletheDonationBatch(params);
    }                                
}