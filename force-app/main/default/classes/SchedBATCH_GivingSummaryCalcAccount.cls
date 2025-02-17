global with sharing class SchedBATCH_GivingSummaryCalcAccount implements Schedulable {
   global static void execute(SchedulableContext sc) {
      asc_BATCH_GivingSummaryCalcAccount u = new asc_BATCH_GivingSummaryCalcAccount(); 
      database.executebatch(u, 200);
   }
    
}