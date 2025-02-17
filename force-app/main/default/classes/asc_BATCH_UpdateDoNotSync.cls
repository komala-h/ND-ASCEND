/**
 * @author UC Innovation
 * @date 11/2/2021
 * @group asc_BATCH
 * @description Batch class for updating the relationship Do Not Sync settings
 */
global without sharing class asc_BATCH_UpdateDoNotSync implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        String query = 'Select Id, ucinn_ascendv2__Contact__c, ucinn_ascendv2__Related_Contact__c, ucinn_ascendv2__Related_Contact_Role__c, ';
        query += ' nd_Do_Not_Sync_Home_Address__c, nd_Do_Not_Sync_Seasonal_Address__c From ucinn_ascendv2__Relationship__c ';
        query += ' Where ucinn_ascendv2__Related_Contact_Role__c Not In (\'Spouse\',\'Partner/Significant Other\') And (nd_Do_Not_Sync_Home_Address__c = false Or nd_Do_Not_Sync_Seasonal_Address__c = false) ';
        
        if (Test.isRunningTest()) {
            query += ' Limit 200 ';
        }
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<ucinn_ascendv2__Relationship__c> scope) {
        List<ucinn_ascendv2__Relationship__c> updateRelationshipList = new List<ucinn_ascendv2__Relationship__c>();
        List<String> validChildConstituentTypeList = new List<String>{'SA','ST','RC'};
        List<String> validRelationshipRoleList = new List<String>{'Spouse','Partner/Significant Other','Child','Parent'};
        Set<Id> contactSet = new Set<Id>();
        Map<Id, String> conTypeMap = new Map<Id, String>();
        
        for (ucinn_ascendv2__Relationship__c rel : scope) {
            contactSet.add(rel.ucinn_ascendv2__Contact__c);
            contactSet.add(rel.ucinn_ascendv2__Related_Contact__c);
        }
        
        for (Contact con : [Select Id, ucinn_ascendv2__Contact_Type__c From Contact Where Id In :contactSet]) {
            conTypeMap.put(con.Id, con.ucinn_ascendv2__Contact_Type__c+'');
        }
        
        for (ucinn_ascendv2__Relationship__c rel : scope) {
            Id childContactId = null;
            Boolean donotsync = false;
            
            if (rel.ucinn_ascendv2__Related_Contact_Role__c == 'Parent') {
                childContactId = rel.ucinn_ascendv2__Contact__c;
            } else if (rel.ucinn_ascendv2__Related_Contact_Role__c == 'Child') {
                childContactId = rel.ucinn_ascendv2__Related_Contact__c;
            }
            
            if (!validRelationshipRoleList.contains(rel.ucinn_ascendv2__Related_Contact_Role__c)) {
                donotsync = true;
            }
            
            if (childContactId != null) {
                if (conTypeMap.containsKey(childContactId)) {
                    List<String> typeList = conTypeMap.get(childContactId).split(';');
                    Boolean childHasValidTypes = false;
                    
                    for (String t : typeList) {
                        if (validChildConstituentTypeList.contains(t)) {
                            childHasValidTypes = true;
                        }
                    }
                    
                    if (!childHasValidTypes) {
                        donotsync = true;
                    }
                }
            }
            
            if (donotsync) {
                rel.nd_Do_Not_Sync_Home_Address__c = true;
                rel.nd_Do_Not_Sync_Seasonal_Address__c = true;
                updateRelationshipList.add(rel);
            }
        }
        
        if (!updateRelationshipList.isEmpty()) {
            ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger('ucinn_ascendv2__Relationship__c', false);
            update updateRelationshipList;
            ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger('ucinn_ascendv2__Relationship__c', true);
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems,CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()]; 
		System.debug('##### AsyncApexJob ID: ' + a.Id); 
    }
}