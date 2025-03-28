/* Author: Ramyashri
 * Description: This batch class resolves a known issue where the Kindsight tool generates incorrect Household names
 			    by updating them to conform to the specified format.
 * Last modified date:03/12/2025
 */
public class nd_UpdateHouseholdName implements Database.Batchable<Sobject>,Schedulable{
    
      public void execute(SchedulableContext SC){
        nd_UpdateHouseholdName i = new nd_UpdateHouseholdName(); 
      	Database.ExecuteBatch(i,50);
    }
    
	public Database.QueryLocator start(Database.BatchableContext BC){
       //Querying Account records created in last 24 hours
       return Database.getQueryLocator([SELECT Id, Name, ucinn_ascendv2__Primary_Contact__r.FirstName, 
                   					    ucinn_ascendv2__Primary_Contact__r.LastName, ucinn_ascendv2__Primary_Contact__r.ucinn_ascendv2__Donor_ID__c
            							FROM Account WHERE createdDate=Last_N_Days:1]);
    }
    public void execute(Database.BatchableContext BC, list<Account> accountList){
        List<Account> accountsToUpdate = new List<Account>();
        List<ucinn_ascendv2__Account_Name__c> accountNamesToUpdate = new List<ucinn_ascendv2__Account_Name__c>();
        String errorMsg='';
        List<Database.SaveResult> updateResults;
        List<Database.SaveResult> updateResultsAccountNames;
        Map<Id, ucinn_ascendv2__Account_Name__c> accountNameMap = new Map<Id, ucinn_ascendv2__Account_Name__c>();
        for (ucinn_ascendv2__Account_Name__c accName : [SELECT Id, Name, ucinn_ascendv2__Account__c, ucinn_ascendv2__Account_Name__c,ucinn_ascendv2__Type__c 
                                                        FROM ucinn_ascendv2__Account_Name__c 
                                                        WHERE ucinn_ascendv2__Account__c IN :accountList AND ucinn_ascendv2__Type__c='Full Name'])
        {
             accountNameMap.put(accName.ucinn_ascendv2__Account__c, accName);
        }
        
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
                
                if (accountNameMap.containsKey(acc.Id)) {
                    ucinn_ascendv2__Account_Name__c accNameObj = accountNameMap.get(acc.Id);
                    if (accNameObj.ucinn_ascendv2__Account_Name__c != expectedName) {
                        accNameObj.ucinn_ascendv2__Account_Name__c = expectedName;
                        accountNamesToUpdate.add(accNameObj);
                    }
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
        }         
        if (!accountNamesToUpdate.isEmpty()) {
            updateResultsAccountNames = Database.update(accountNamesToUpdate, false);
            for (Database.SaveResult dr : updateResultsAccountNames) {
                if (!dr.isSuccess()) {
                    for (Database.Error err : dr.getErrors()) {
                        errorMsg += '\n' + err.getMessage() + '\n';
                    }
                }
            }
        }
        // Send email only if there are errors
        if (String.isNotBlank(errorMsg) || Test.isRunningTest()) {
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