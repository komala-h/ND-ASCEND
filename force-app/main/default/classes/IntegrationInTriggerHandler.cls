public class IntegrationInTriggerHandler {
    public static set<string> statusSet {
        get {
            if(statusSet == null) {
            	statusSet = new set<string>();
            }
            return statusSet;
        }    
        set;
    }
    
    public static void afterInsert(list<Integration_In__c> newList) {
        system.debug('outside if');
        if(!statusSet.contains('afterInsert')) {
        	statusSet.add('afterInsert');
            system.debug('inside if');
            Id batchId = Database.executeBatch(new IntegrationConsumerBatch(), 50);
        }
    }
}