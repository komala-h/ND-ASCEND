/*Schedular class for ScheduleStandardPicklistBatchSync batch class*/
global with sharing class ScheduleStandardPicklistBatchSync implements Schedulable {
   global static void execute(SchedulableContext sc) {
      StandardPicklistBatchSync u = new StandardPicklistBatchSync(); 
      database.executebatch(u, 1);
   }
    
}