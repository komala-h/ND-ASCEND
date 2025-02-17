public class ND_CampaignCSVUploaderBatch implements Database.Batchable<Sobject>,Database.Stateful{

    list<Campaign> camListToInsert;
    // To store the success and failure count of records that were inserted
    Public Integer successCount = 0;
    public Integer failureCount = 0;
    
    //Records are passed to this batch class from apex class ND_CampaignCSVUploaderController
    public ND_CampaignCSVUploaderBatch(list<Campaign> cmList){
        camListToInsert = cmList;
    }
    
    public list<Campaign> start(Database.BatchableContext BC) {
        return camListToInsert;
    }
    
    public void execute(Database.BatchableContext BC, list<Campaign> camListToInsert){
        system.debug(camListToInsert);
        try{
            if(!camListToInsert.isEmpty()){
                Database.UpsertResult[] srList = database.upsert(camListToInsert,false);
                for(Database.UpsertResult sr:srList){
                        if(sr.isSuccess()){
                            successCount++;
                        }
                        else{
                            failureCount++;
                        }
                   }
            }
        }
        catch(Exception e){
             system.debug('Exception occurred is' +e.getMessage());
        }
       
    }
    
    public void finish(Database.BatchableContext BC) {
        try
        {
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email
                              FROM AsyncApexJob WHERE Id =:BC.getJobId()];
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {UserInfo.getUserId(),a.CreatedBy.Email};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Mass Upload campaign Appeals is ' + a.Status);
            mail.setPlainTextBody('The batch Apex job processed: ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures.'+ '\n\n' +
                                  'Total Number of records inserted/updated successfully is '+ successCount +'\n'+
                                  'Total Number of records failed to insert/updated are '+ failureCount +'\n'
                                 );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        catch(Exception e){
            system.debug('Exception occurred is' +e.getMessage());
        }
    }
    
}