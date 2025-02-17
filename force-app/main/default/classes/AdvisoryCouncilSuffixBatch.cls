global class AdvisoryCouncilSuffixBatch implements Database.Batchable<sObject>,Schedulable{

    List<String> recids = new List<string>();
    global void execute(SchedulableContext SC) {
        
        Integer noOfRecords = (Integer)ManageBatchJobSize__mdt.getInstance('AdvisoryCouncilSuffixBatch').ChunkSize__c;           
        AdvisoryCouncilSuffixBatch M = new AdvisoryCouncilSuffixBatch();
        database.executeBatch(m,noOfRecords);
    }
    
    global Database.querylocator start(Database.BatchableContext BC){
        ManageBatchJobSize__mdt  mb =ManageBatchJobSize__mdt.getInstance('AdvisoryCouncilSuffixBatch');
        if(!mb.IsAllowed__c)
        	return Database.getQueryLocator([Select id,ucinn_ascendv2__Start_Date__c,ucinn_ascendv2__End_Date__c,ND_BackendFieldCalForSuffixes__c, ND_IsValidPeriodforSuffix__c, ucinn_ascendv2__Status__c from ucinn_ascendv2__Involvement__c where ucinn_ascendv2__Status__c ='A' AND recordType.developername ='Advisory_Council' AND ( (ucinn_ascendv2__Start_Date__c <=TODAY AND ucinn_ascendv2__End_Date__c >=TODAY AND ND_IsValidPeriodforSuffix__c=false) OR (ucinn_ascendv2__End_Date__c < TODAY AND ND_IsValidPeriodforSuffix__c=true))AND nd_Affiliation_Symbol__c!=null]);
        else
        	return Database.getQueryLocator([Select id,ucinn_ascendv2__Start_Date__c,ucinn_ascendv2__End_Date__c,ND_BackendFieldCalForSuffixes__c, ND_IsValidPeriodforSuffix__c, ucinn_ascendv2__Status__c from ucinn_ascendv2__Involvement__c where ucinn_ascendv2__Status__c ='A' AND recordType.developername ='Advisory_Council' AND ( (ucinn_ascendv2__Start_Date__c <=TODAY AND ucinn_ascendv2__End_Date__c >=TODAY AND ND_IsValidPeriodforSuffix__c=false) OR (ucinn_ascendv2__End_Date__c < TODAY AND ND_IsValidPeriodforSuffix__c=true) OR (ND_BackendFieldCalForSuffixes__c=False AND ucinn_ascendv2__Contact__r.nd_Suffix_ND_Affiliations__c like '%CN%'))AND nd_Affiliation_Symbol__c!=null]);

    }
    global void execute(Database.BatchableContext BC, List<ucinn_ascendv2__Involvement__c> scope){
        for(ucinn_ascendv2__Involvement__c inv: scope){
          inv.ND_IsValidPeriodforSuffix__c = inv.ND_BackendFieldCalForSuffixes__c;
        }
         String errorMsg='';
        if(scope.size()>0){
            List<Database.SaveResult> updateResults;
            updateResults = Database.update(scope, false);
            for(Integer i=0;i<updateResults.size();i++){
                if (!updateResults.get(i).isSuccess()){
                    Database.Error error = updateResults.get(i).getErrors().get(0);String failedDML = error.getMessage();

                }        
            }             
        } 

        if(string.isNotBlank(errorMsg)||Test.isRunningTest())
            sendEmail(errorMsg);  
    }
    global void finish(Database.BatchableContext BC){

    }
    
    public void sendEmail(String msg){
    // Step 1: Create a new Email
    Messaging.SingleEmailMessage mail = 
    new Messaging.SingleEmailMessage();
    
    // Step 2: Set list of people who should get the email
    List<String> sendTo = new List<String>();
    sendTo.add('entcrm@nd.edu');  
    mail.setToAddresses(sendTo);
    
    // Step 3: Set who the email is sent from
    mail.setReplyTo('no_reply@nd.edu');
    mail.setSenderDisplayName('Scheduled Apex');

    // Step 4. Set email contents - you can use variables!
    mail.setSubject('ERROR: NDAddressUpdate Job');
    String body = msg;
    mail.setHtmlBody(body);
    
    // Step 5. Send mail
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
  }      
}