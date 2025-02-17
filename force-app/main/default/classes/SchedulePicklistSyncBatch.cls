/*Schedular class for PicklistSyncBatch batch class*/
global with sharing class SchedulePicklistSyncBatch implements Schedulable {
   global static void execute(SchedulableContext sc) {
      PicklistSyncBatch u = new PicklistSyncBatch(); 
      database.executebatch(u, 1);
   }
    
}