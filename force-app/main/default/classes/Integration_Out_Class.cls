/*-----------------------------------------------------------------------
Created By: Wieslaw Kosidlak
Created Date: Match 9, 2017
Description: Integration out with Advance, Used by triggers
-----------------------------------------------------------------------*/
public class Integration_Out_Class implements Queueable {
    //private static Void InsertIntegrationOut(List<sObject> obj, String event){}
    public String objectTypeStr; 
    public String objectId; 
    public DateTime modifiedDate;
    public String eventType;
    public Integer integrationRecordID;
    public Integration_Out_Class(String objectTypeStr, String objectId, DateTime modifiedDate, String eventType, Integer integrationRecordID) {
        this.objectTypeStr = objectTypeStr; 
        this.objectId = objectId;  
        this.modifiedDate = modifiedDate; 
        this.eventType = eventType;
        this.integrationRecordID = integrationRecordID;
    }
    public void execute(QueueableContext context) {
        futureIntegrationOutRec();
    }
    
    public static void InsertNewRecord(List<sObject> obj){
        List<Integration_Out__c> obj2 =new List<Integration_Out__c>();
       
        String uniqueString;
        for(sObject a : obj)
        {
            // To generate unique duplicate signature which is passed as parameter while enqueueing the job
            uniqueString = EncodingUtil.convertToHex(Crypto.generateDigest('SHA-256', Crypto.generateAesKey(128))).substring(0, 6);
            
            Integer integrationRecordID;
            try{
                integrationRecordID =    Integer.valueOf(a.get('Integration_Record_ID__c'));
            }
            catch(exception e){
                integrationRecordID = null;
            }
            String objectTypeStr = String.valueOf(a.getSObjectType());
            if(objectTypeStr == 'User'){
                //futureIntegrationOutRec(objectTypeStr, a.Id, DateTime.valueOf(a.get('LastModifiedDate')), 'I');
                Integration_Out_Class job = new Integration_Out_Class(objectTypeStr, a.Id, DateTime.valueOf(a.get('LastModifiedDate')), 'I',  integrationRecordID);
                //ID jobID = System.enqueueJob(job);
                //To detect duplicate queueable jobs
                AsyncOptions options = new AsyncOptions();
				options.DuplicateSignature = new System.QueueableDuplicateSignature.Builder().addString(uniqueString).build();
                ID jobID = System.enqueueJob(job,options);
            }
            else{
                Integration_Out__c n = createIntegrationOutRec(objectTypeStr, a.Id, DateTime.valueOf(a.get('LastModifiedDate')), 'I', integrationRecordID);
              obj2.add(n);
            }
        }
        //if(!obj2.isEmpty()){insert obj2;}  
        if(!obj2.isEmpty()){
            if(obj2.size() <= 10000) {
            system.debug('insert record obj2.size() = '+obj2.size());
        insert  obj2;        
            } else{
                
            Integer plSize = obj2.size();
            Integer remainder = Math.mod(plSize, 10000);
            Integer totalUpserts = remainder == 0 ? (plSize/10000) : (plSize/10000 + 1);
            for(Integer i = 0; i < totalUpserts; i++) {
              list<Integration_Out__c> insertList = new list<Integration_Out__c>();
                Integer maxRecords = ((i + 1) * 10000) > plSize ? plSize : ((i + 1) * 10000);
                for(Integer j = (i * 10000); j < maxRecords; j++) {
                    insertList.add(obj2[j]);
                }
                insert insertList;
              }
            }
        }
        /*if(nd_picklist.size() <= 10000) {
        upsert nd_picklist;        
        }
        else {
            Integer plSize = nd_picklist.size();
            Integer remainder = Math.mod(plSize, 10000);
            Integer totalUpserts = remainder == 0 ? (plSize/10000) : (plSize/10000 + 1);
            for(Integer i = 0; i < totalUpserts; i++) {
              list<nd_picklist__c> upsertList = new list<nd_picklist__c>();
                Integer maxRecords = ((i + 1) * 10000) > plSize ? plSize : ((i + 1) * 10000);
                for(Integer j = (i * 10000); j < maxRecords; j++) {
                    upsertList.add(nd_picklist[j]);
                }
                upsert upsertList;
            }
        }*/
    }
    
    public static void UpdateRecord(List<sObject> obj){
        List<Integration_Out__c> obj2 =new List<Integration_Out__c>();
        String uniqueString;
        
        for(sObject a : obj)
        {
            // To generate unique duplicate signature which is passed as parameter while enqueueing the job
    		uniqueString = EncodingUtil.convertToHex(Crypto.generateDigest('SHA-256', Crypto.generateAesKey(128))).substring(0, 6);
            
            Integer integrationRecordID;
            try{
                // vikas - modifed the line 134
                //Set<String> allObjFlds = a.getSObjectType().getDescribe().fields.getMap().keySet();
                //if(allObjFlds.contains('Integration_Record_ID__c'))
                integrationRecordID =    Integer.valueOf(a.get('Integration_Record_ID__c'));
            }
            catch(exception e){
                integrationRecordID = null;
            }
            
            String objectTypeStr = String.valueOf(a.getSObjectType());
            if(objectTypeStr == 'User'){
                //futureIntegrationOutRec(objectTypeStr, a.Id, DateTime.valueOf(a.get('LastModifiedDate')), 'U');
                Integration_Out_Class job = new Integration_Out_Class(objectTypeStr, a.Id, DateTime.valueOf(a.get('LastModifiedDate')), 'U', integrationRecordID);
                //ID jobID = System.enqueueJob(job);
                //To detect duplicate queueable jobs
                AsyncOptions options = new AsyncOptions();
				options.DuplicateSignature = new System.QueueableDuplicateSignature.Builder().addString(uniqueString).build();
                ID jobID = System.enqueueJob(job,options);
            }
            else{
                Integration_Out__c n = createIntegrationOutRec(objectTypeStr, a.Id, DateTime.valueOf(a.get('LastModifiedDate')), 'U', integrationRecordID);
                obj2.add(n);
            }
        }
        //if(!obj2.isEmpty()){insert obj2;}  
        if(!obj2.isEmpty()){
            system.debug('update record obj2.size() = '+obj2.size());
            if(obj2.size() <= 10000) {
        insert  obj2;        
            } else{
                
            Integer plSize = obj2.size();
            Integer remainder = Math.mod(plSize, 10000);
            Integer totalUpserts = remainder == 0 ? (plSize/10000) : (plSize/10000 + 1);
            for(Integer i = 0; i < totalUpserts; i++) {
              list<Integration_Out__c> insertList = new list<Integration_Out__c>();
                Integer maxRecords = ((i + 1) * 10000) > plSize ? plSize : ((i + 1) * 10000);
                for(Integer j = (i * 10000); j < maxRecords; j++) {
                    insertList.add(obj2[j]);
                }
                insert insertList;
              }
            }
        }
    }
    public static void DeleteRecord(List<sObject> obj){
        List<Integration_Out__c> obj2 =new List<Integration_Out__c>();
        String uniqueString;
        
        for(sObject a : obj)
        {
            // To generate unique duplicate signature which is passed as parameter while enqueueing the job
    		uniqueString = EncodingUtil.convertToHex(Crypto.generateDigest('SHA-256', Crypto.generateAesKey(128))).substring(0, 6);
            
            Integer integrationRecordID;
            try{
                // vikas - modifed the line 134
                //Set<String> allObjFlds = a.getSObjectType().getDescribe().fields.getMap().keySet();
                //if(allObjFlds.contains('Integration_Record_ID__c'))
                integrationRecordID =    Integer.valueOf(a.get('Integration_Record_ID__c'));
            }
            catch(exception e){
                integrationRecordID = null;
            }
            String objectTypeStr = String.valueOf(a.getSObjectType());
            if(objectTypeStr == 'User'){
                //futureIntegrationOutRec(objectTypeStr, a.Id, system.now(), 'D');
                Integration_Out_Class job = new Integration_Out_Class(objectTypeStr, a.Id, system.now(), 'D', integrationRecordID);
                //ID jobID = System.enqueueJob(job);
                //To detect duplicate queueable jobs
                AsyncOptions options = new AsyncOptions();
				options.DuplicateSignature = new System.QueueableDuplicateSignature.Builder().addString(uniqueString).build();
                ID jobID = System.enqueueJob(job,options);
            }
            else{
                Integration_Out__c n = createIntegrationOutRec(objectTypeStr, a.Id, system.now(), 'D', integrationRecordID);
                obj2.add(n);
            }
        }
        //if(!obj2.isEmpty()){insert obj2;}  
        if(!obj2.isEmpty()){
            if(obj2.size() <= 10000) {
        insert  obj2;        
            } else{
                
            Integer plSize = obj2.size();
            Integer remainder = Math.mod(plSize, 10000);
            Integer totalUpserts = remainder == 0 ? (plSize/10000) : (plSize/10000 + 1);
            for(Integer i = 0; i < totalUpserts; i++) {
              list<Integration_Out__c> insertList = new list<Integration_Out__c>();
                Integer maxRecords = ((i + 1) * 10000) > plSize ? plSize : ((i + 1) * 10000);
                for(Integer j = (i * 10000); j < maxRecords; j++) {
                    insertList.add(obj2[j]);
                }
                insert insertList;
              }
            }
        }
    }
    
    private void futureIntegrationOutRec(){
        Integration_Out__c n = new Integration_Out__c();
        n.Object_Api_Name__c = objectTypeStr;
        n.Modified_Record_Id__c = objectId;
        n.Date_Modified__c = modifiedDate;
        n.Event_Type__c = eventType;
        n.Integration_Record_ID__c = integrationRecordID;
        
        insert(n);
    }
    
    private static Integration_Out__c createIntegrationOutRec(String objectTypeStr, String objectId, DateTime modifiedDate, String eventType, Integer integrationRecordID){
        Integration_Out__c n = new Integration_Out__c();
        n.Object_Api_Name__c = objectTypeStr;
        n.Modified_Record_Id__c = objectId;
        n.Date_Modified__c = modifiedDate;
        n.Event_Type__c = eventType;
        n.Integration_Record_ID__c = integrationRecordID;
        return n;
    }
    
    
}