global with sharing class ScheduleAffiliationRelationBatch implements Schedulable {
	global static void execute(SchedulableContext sc) {
       ND_AddressAffiliationRelationBatch addr = new ND_AddressAffiliationRelationBatch(); 
       database.executebatch(addr);
        
       ND_EmailAffiliationRelationBatch em = new ND_EmailAffiliationRelationBatch(); 
       database.executebatch(em);
        
       ND_PhoneAffiliationRelationBatch ph = new ND_PhoneAffiliationRelationBatch(); 
       database.executebatch(ph);
    }
}