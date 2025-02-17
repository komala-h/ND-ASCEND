/* Description: This class is to batch upload Stewardship Assets
 * 
 * Author: Komala H @Cube84 
 */
public class ND_massUploadStewardshipAssetsBatch implements Database.Batchable<Sobject>,Database.Stateful{
	list<Asset> assetListToInsert;
    // To store the success and failure count of records that were inserted
    Public Integer successCount = 0;
    public Integer failureCount = 0;
    
    //Records are passed to this batch class from apex class ND_massUploadStewardshipAssets
    public ND_massUploadStewardshipAssetsBatch(list<Asset> asList){
        assetListToInsert = asList;
    }
    
    public list<Asset> start(Database.BatchableContext BC) {
      	return assetListToInsert;
    }
    
    public void execute(Database.BatchableContext BC, list<Asset> assetListToInsert){
        try{
            if(!assetListToInsert.isEmpty()){
                Database.SaveResult[] srList = database.insert(assetListToInsert,false);
                for(Database.SaveResult sr:srList){
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
        	mail.setSubject('Mass Upload Stewardship Assets is ' + a.Status);
        	mail.setPlainTextBody('The batch Apex job processed: ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures.'+ '\n\n' +
                                  'Total Number of records inserted successfully is '+ successCount +'\n'+
                                  'Total Number of records failed to insert are '+ failureCount +'\n'
                                 );
        	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    	}
        catch(Exception e){
			system.debug('Exception occurred is' +e.getMessage());
        }
    }
    
}