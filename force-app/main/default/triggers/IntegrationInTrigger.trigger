trigger IntegrationInTrigger on Integration_In__c (after insert) {
    IntegrationInTriggerHandler.afterInsert(trigger.new);
}