public with sharing class BeatEventAlertController {
    @AuraEnabled(cacheable=true)
    public static List<BEAT_Alert__c> getBeatAlerts(){
        try {
            return [SELECT id, Event__c, Event__r.Name, Message__c FROM BEAT_Alert__c WHERE Status__c = 'Active' ORDER BY Order__c ASC];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Beat_Alert_Setting__mdt getCMT(){
        try {
            return [SELECT id, Link__c FROM Beat_Alert_Setting__mdt WHERE DeveloperName = 'Beat_Alert_Guidelines' LIMIT 1];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}