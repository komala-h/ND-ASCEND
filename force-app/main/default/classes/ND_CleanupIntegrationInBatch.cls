/*
 * Description: This batch class is to delete the IntegrationIn records which are in status either 'Done' or 'Discard'
 * Author: Komala H
 *  
 * 
 */

public class ND_CleanupIntegrationInBatch implements Database.Batchable<Sobject>,Schedulable{
	public Database.QueryLocator start(Database.BatchableContext BC){
        try{
         // query the Done IntegrationIn records
       		return Database.getQueryLocator([SELECT  Id FROM Integration_In__c WHERE Status__c  in ('Done','Discard')]);
       //     return Database.getQueryLocator([SELECT  Id FROM Integration_In__c WHERE Status__c  in ('Done','Discard') and createddate = last_n_days:30 ]);
        }
        catch(Exception ex){
            return null;
        }
    }
    
    public void execute(Database.BatchableContext BC, list<Integration_In__c> integrationInList){
        list<Integration_In__c> integrationInRecordsToDelete = new list<Integration_In__c>();
		integrationInRecordsToDelete.addAll(integrationInList)  ;   
        List<Database.DeleteResult> deleteResults;
        String errorMsg='';
        try{               
            if(!integrationInRecordsToDelete.isempty()){
                deleteResults = Database.delete(integrationInRecordsToDelete, false);
                for(Integer i=0;i<deleteResults.size();i++){
                    if (!deleteResults.get(i).isSuccess()){
                        Database.Error error = deleteResults.get(i).getErrors().get(0);
                        String failedDML = error.getMessage();
                        errorMsg = errorMsg+'\n'+failedDML+'-'+integrationInRecordsToDelete.get(i).Id+'\n';
                        system.debug('error Message '+errorMsg);
                    }        
                }
            }
            
            if(string.isNotBlank(errorMsg)||Test.isRunningTest())
            	sendEmail(errorMsg);
		}
        catch(Exception ex){
            system.debug('Exception caught :'+ex);
        }
    }
    
    public void execute(SchedulableContext SC){
        ND_CleanupIntegrationInBatch i = new ND_CleanupIntegrationInBatch(); 
      	Database.ExecuteBatch(i,200);
    }
        
    public void finish(Database.BatchableContext BC){
        
    }
    public void sendEmail(String msg){
        // Step 1: Create a new Email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        // Step 2: Set list of people who should get the email
        List<String> sendTo = new List<String>();
        sendTo.add('entcrm@nd.edu');  
        mail.setToAddresses(sendTo);
        
        // Step 3: Set who the email is sent from
        mail.setReplyTo('no_reply@nd.edu');
        mail.setSenderDisplayName('Scheduled Apex');
    
        // Step 4. Set email contents - you can use variables!
        mail.setSubject('ERROR: Delete the Done Integration In Batch job');
        String body = msg;
        mail.setHtmlBody(body);
        
        // Step 5. Send mail
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
  	}     
}