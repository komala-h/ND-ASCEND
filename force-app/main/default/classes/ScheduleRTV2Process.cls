/*Schedular class for ND_RTV2_Processing batch class*/
global with sharing class ScheduleRTV2Process implements Schedulable {
    global static void execute(SchedulableContext sc) {
        ND_RTV2_Processing u = new ND_RTV2_Processing(); 
       database.executebatch(u, 1);
    }
     
 }