global class nd_Involvement_Status_Update_Batch implements Database.Batchable<sObject>,Schedulable {
    
    
     global void execute(SchedulableContext SC) {
       nd_Involvement_Status_Update_Batch M = new nd_Involvement_Status_Update_Batch();
           database.executeBatch(m); 
   }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Collect the batches of records or objects to be passed to execute
        String query = 'SELECT Id, Name, ucinn_ascendv2__Status__c, ucinn_ascendv2__End_Date__c FROM ucinn_ascendv2__Involvement__c';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<ucinn_ascendv2__Involvement__c> invList) {
        List<ucinn_ascendv2__Involvement__c> invToUpdate = new List<ucinn_ascendv2__Involvement__c>();
        
        // Iterate over the records and update the status if the end date has passed
        for(ucinn_ascendv2__Involvement__c inv : invList) {   
            if(inv.ucinn_ascendv2__End_Date__c <= Date.today() && inv.ucinn_ascendv2__Status__c=='A') {
                inv.ucinn_ascendv2__Status__c = Label.InvPastStatus;
                invToUpdate.add(inv);
            }
        }
        
        // Update the records
        if(!invToUpdate.isEmpty()) {
            try {
                update invToUpdate;
            } catch(Exception e) {
                // Handle any update errors
                sendEmail(e.getMessage());
            }
        }
    }   
    
    global void finish(Database.BatchableContext BC)
    {
       // Handle finish activities. 
    }
    public void sendEmail(String msg){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();
        sendTo.add('entcrm@nd.edu');  
        mail.setToAddresses(sendTo);
        mail.setReplyTo('no_reply@nd.edu');
        mail.setSenderDisplayName('Scheduled Apex');
        mail.setSubject('ERROR: nd_Involvement_Status_Update_Batch Scheduled Job');
        String body = msg;
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
  } 
}