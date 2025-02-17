global class IER_Deletion_Batch implements Database.Batchable<SObject>, Database.Stateful,Schedulable {
	public String months;
    
    public IER_Deletion_Batch(){
        IER_BatchSetting__c bs = IER_BatchSetting__c.getValues('Record Deletion');
        if(bs!=null){
            this.months = String.valueOf((Integer)bs.Months__c*30);
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query='';
        if(months!=null){
            query = 'SELECT Id FROM et4ae5__IndividualEmailResult__c WHERE CreatedDate < LAST_N_DAYS:'+months;
		}
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<et4ae5__IndividualEmailResult__c> EmailResults){
        try{
            //et4ae5__IndividualLink__c et4ae5__Individual_Email_Result__c
            if(!EmailResults.isEmpty()){
                List<et4ae5__IndividualLink__c> relatedLinks = new List<et4ae5__IndividualLink__c>();
                for(et4ae5__IndividualLink__c EmailResultLink : [select id from et4ae5__IndividualLink__c where et4ae5__Individual_Email_Result__c=:EmailResults ]){
                    relatedLinks.add(EmailResultLink);
                }
                if(!relatedLinks.isEmpty()){
                    delete relatedLinks;
                }
                delete EmailResults;
            }
        }
        Catch(Exception ex){
            System.debug('Following exception has occurred:'+ ex.getMessage());
        }
    }
    
    global void execute(SchedulableContext SC){
        IER_Deletion_Batch Deletebat = new IER_Deletion_Batch(); 
      	database.executebatch(Deletebat);
    }
    
    global void finish(Database.BatchableContext BC) {
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] {job.CreatedBy.Email};
        message.subject = 'Individual Email Results Deletion Batch';
        message.plainTextBody = 'Your batch job to delete Individual Email Results records has been processed successfully.';
        
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        if(!results[0].success) {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        } 
        
    }
}