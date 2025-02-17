/*Schedular class for RecordtypeSyncBatch batch class*/
global with sharing class ScheduleRecordtypeSyncBatch implements Schedulable {
   global static void execute(SchedulableContext sc) {
      RecordtypeSyncBatch u = new RecordtypeSyncBatch(); 
      database.executebatch(u, 1);
   }
}