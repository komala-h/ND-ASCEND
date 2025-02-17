/* Description: This batch class is to Update the Household name if it does not conform to the specified format.
 * Author: Ramyashri
 */
public class nd_UpdateHouseholdName implements Database.Batchable<Sobject>,Schedulable{
    
      public void execute(SchedulableContext SC){
        nd_UpdateHouseholdName i = new nd_UpdateHouseholdName(); 
      	Database.ExecuteBatch(i,50);
    }
    
	public Database.QueryLocator start(Database.BatchableContext BC){
       return Database.getQueryLocator([SELECT Id, Name, ucinn_ascendv2__Primary_Contact__r.FirstName, 
                   					    ucinn_ascendv2__Primary_Contact__r.LastName, ucinn_ascendv2__Primary_Contact__r.ucinn_ascendv2__Donor_ID__c
            							FROM Account WHERE createdDate=TODAY]);  
    }
     public void execute(Database.BatchableContext BC, list<Account> accountList){
          List<Account> accountsToUpdate = new List<Account>();
          String errorMsg='';
          List<Database.SaveResult> updateResults;

           for (Account acc : accountList) {
            if (acc.ucinn_ascendv2__Primary_Contact__r != null && acc.ucinn_ascendv2__Primary_Contact__r.LastName != null && acc.ucinn_ascendv2__Primary_Contact__r.FirstName != null &&  acc.ucinn_ascendv2__Primary_Contact__r.ucinn_ascendv2__Donor_ID__c !=null){
                // The Expected Name
                 String expectedName = acc.ucinn_ascendv2__Primary_Contact__r.LastName + ' ' +
                      				   acc.ucinn_ascendv2__Primary_Contact__r.FirstName + ' ' +
                      				   acc.ucinn_ascendv2__Primary_Contact__r.ucinn_ascendv2__Donor_ID__c + ' ' +
                      				   'Household';
                // Check if the current name doesn't match the expected format
                if (acc.Name != expectedName) {
                    acc.Name = expectedName; 
                    accountsToUpdate.add(acc);
                }
            } 
        }
          // Update the records if changes are required
             if (!accountsToUpdate.isEmpty()) {
                 updateResults = Database.update(accountsToUpdate, false);
                 for(Database.SaveResult dr : updateResults){
                     if(!dr.isSuccess()){
                         for(Database.Error err : dr.getErrors()){
                             String failedDML = err.getMessage();
                             errorMsg = errorMsg+'\n'+failedDML+'\n' ; 
                         }
                     }
                 }
                 if(string.isNotBlank(errorMsg)||Test.isRunningTest())
            		sendEmail(errorMsg); 
             }             
     }   
        
    public void finish(Database.BatchableContext BC){
       // system.debug('Finish');
    }
   
     private void sendEmail(String msg){
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
        mail.setSubject('ERROR: Household Name Update Batch Job');
        String body = msg;
        mail.setHtmlBody(body);
        
        // Step 5. Send mail
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
	} 
}