/**
 * @author: UC Innovation /qluong
 * @date: 02/13/2024
 * @description: Batch class for calculating giving summary for gifts created through RTv2.  Gifts created through RTv2 that uses the automatic approval process
 * doesn't trigger the giving summary calculation when the batch is approved.  So this batch class needs to run daily to calculate the giving summary for gifts
 * created through RTv2
 * 
 * fixed by jrizzi 5/9/2024
 */
global without sharing class asc_BATCH_GivingSummaryCalcAccount implements Database.Batchable<sObject>, Database.Stateful {
    
    Set<Id> acctIds = new Set<Id>();
    Set<Id> SessionIds = new Set<Id>();
    
    DateTime DT = date.today();
      
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        String query = 'Select Id, ucinn_ascendv2__Session__c';
        query += ' From ucinn_ascendv2__Review_Transaction_v2__c ';
        query += ' Where ucinn_ascendv2__Session__r.ucinn_ascendv2__Session_Totals_Approved__c != null and ';
        query += ' ucinn_ascendv2__Session__r.ucinn_ascendv2__Is_Ready_for_G_L__c = true and ucinn_ascendv2__Session__r.ucinn_ascendv2__Session_Totals_Approved__c >=: DT';
        
        if (Test.isRunningTest()) {
            query += ' Limit 200 ';
        }
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<ucinn_ascendv2__Review_Transaction_v2__c> scope) { if(scope.size()>0){ for(ucinn_ascendv2__Review_Transaction_v2__c RTv2Rec: scope){ SessionIds.add(RTv2Rec.ucinn_ascendv2__Session__c);
            }
        }
        
        system.debug('SessionIds size' + SessionIds.size());
        
    }
    
    global void finish(Database.BatchableContext BC) {
    
        List<ucinn_ascendv2__Hard_and_Soft_Credit__c> hsclist = new List<ucinn_ascendv2__Hard_and_Soft_Credit__c>([SELECT ucinn_ascendv2__Account__c 
                                                                    FROM ucinn_ascendv2__Hard_and_Soft_Credit__c 
                                                                    WHERE ucinn_ascendv2__Account__c != null and ucinn_ascendv2__Credit_Amount__c !=null and ucinn_ascendv2__Session__c in :SessionIds]);
        for(ucinn_ascendv2__Hard_and_Soft_Credit__c hsc: hsclist ){ acctIds.add(hsc.ucinn_ascendv2__Account__c);}
        
        system.debug('acctIds size ' + acctIds.size());
        
        //qluong 5/14/2024 added
        if(acctIds.size()>0){
        
            Map<String, Object> params = new Map<String, Object>(); params.put('objectApiName', 'Account'); params.put('recordIdSet', acctIds);params.put('batchSize', 10000);
            ucinn_ascendv2.ascend_UTIL_RunBatch.ascend_GIFT_UpdateGivingSummaryAcctContBatch(params);
    
            AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems,CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()]; 
            System.debug('##### AsyncApexJob ID: ' + a.Id); 
        }
    }
}