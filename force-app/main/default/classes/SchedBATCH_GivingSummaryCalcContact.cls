global with sharing class SchedBATCH_GivingSummaryCalcContact implements Schedulable {
   global static void execute(SchedulableContext sc) {
      asc_BATCH_GivingSummaryCalcContact u = new asc_BATCH_GivingSummaryCalcContact(); 
      database.executebatch(u, 200);
   }
    
}