/*
 * This batch class to populate value for lastContactReportdate on Account(household and organisation).
 * This should be run before the feature goes live to make the existing records have value. 
 * Also this batch class can be run to update the lastcontactreportdate field if discrepancy found in data.
 * Author: Komala H
*/


public class ND_UpdateLastContactReportDateBatch implements Database.Batchable<sobject>,Schedulable {
    public Database.QueryLocator start(Database.BatchableContext Bc){
        String query = 'select Id,Name,ucinn_ascendv2__PRM__c,nd_LastCRDate__c,(select ucinn_ascendv2__Account__r.Id,CreatedDate,ucinn_ascendv2__Date__c,Author__c,nd_activePRM__c from ucinn_ascendv2__Contact_Reports_Account__r Where nd_activePRM__c= true  Order By ucinn_ascendv2__Date__c DESC Limit 1) from Account where recordtype.developerName IN (\'Household\',\'Corporations_and_Organizations\') ';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext Bc,List<Account> scope){
        List<Account> acclist = new List<Account>();
        list<ucinn_ascendv2__Contact_Report__c> crList = new list<ucinn_ascendv2__Contact_Report__c>();
        
        for(Account acc : scope){
            crList = acc.ucinn_ascendv2__Contact_Reports_Account__r;
            if(crList.size()!=0){
            	acc.nd_LastCRDate__c = crList[0].ucinn_ascendv2__Date__c;
                acclist.add(acc); 
            }
        }
        try{
            if(acclist.size()!=0){
                update acclist;
            } 
        }
        Catch(exception e){
            system.debug('Exception Caught:'+e.getmessage());
        }
        
    }
    
    public void execute(SchedulableContext SC){
        ND_UpdateLastContactReportDateBatch i = new ND_UpdateLastContactReportDateBatch(); 
      	database.executebatch(i);
    }
    public void finish(Database.BatchableContext Bc) {
        try
        {
        	AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email
                              FROM AsyncApexJob 
                              WHERE Id =:bc.getJobId()];
        	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        	String[] toAddresses = new String[] {a.CreatedBy.Email};
        	mail.setToAddresses(toAddresses);
        	mail.setSubject('Update lastContactReportCreatedDate Batch job has been completed with status as  ' + a.Status);
        	mail.setPlainTextBody('The batch Apex job processed: ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures.');
        	
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {mail};
        	Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        	if(!results[0].success) {
            	System.debug('The email failed to send: ' + results[0].errors[0].message);
        	} 
        }
        catch(Exception ex){
			system.debug('Exception caught :'+ex);
        }
    }
}