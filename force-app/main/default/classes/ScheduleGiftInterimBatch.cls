/*Schedular class for GiftInterim batch class*/
global with sharing class ScheduleGiftInterimBatch implements Schedulable {
    global static void execute(SchedulableContext sc) {
        GiftInterimBatch u = new GiftInterimBatch(); 
       database.executebatch(u, 20);
    }
     
 }