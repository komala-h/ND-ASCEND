global class IntegrationProducerBatch implements Database.Batchable<SObject>, Database.Stateful{
    boolean long_data;

    global IntegrationProducerBatch(Boolean long_data_param) 
    {
        long_data = long_data_param;
    }    
    global Database.QueryLocator start(Database.BatchableContext bc) {
           /** stuff left to do
            * DONE now fields have lost case, and consumr is case sensitive CHECK field counts arent matching , (see query) doesnt return null or blank vals
            * DONE query sysdate-1 not working
            * maybe do the lock of rows like the consumer
            * DONE move query out of the for loop 
            * DONE event datetime format same format as fields
            * DONE if salesforce row doesnt exist, create a blank array
            * DONE add processed count, and last processed date
            * DONE on success last processed date to sysdatetime
            * */
        datetime yesterday = system.now().addDays(-1);
        return Database.getQueryLocator(
            /* talend job query*/
            'SELECT Id, Date_Modified__c, Event_Type__c, Last_Processed_Date__c, Message__c, Modified_Record_Id__c, Object_Api_Name__c, Outbound_Id__c, Processed_Count__c, Status__c, error_message__c, '
            +' LastModifiedById, Integration_Record_ID__c, long_data_ind__c, json_message__c, json_message_2__c, json_message_3__c, json_message_4__c, json_message_5__c, json_message_6__c, json_message_7__c, json_message_8__c, json_message_9__c, json_message_10__c FROM Integration_Out__c '
            //+'WHERE Id =\'a5Y04000004zW3T\' '
            +'WHERE  (Status__c = \'N\'  or ( Status__c = \'E\' and Last_Processed_Date__c <=  :yesterday)) ' //Outbound_Id__c ASC NULLS FIRST LIMIT 2000'
            //\WHERE   Status__c = \'E\'  ' //Outbound_Id__c ASC NULLS FIRST LIMIT 2000'

            + 'and long_data_ind__c =' + long_data + ' '
            +'   ORDER BY createddate desc'
        );
    }

    global void execute(Database.BatchableContext bc, List<Integration_Out__c> scope){
        //JSONGenerator gen = JSON.createGenerator(true);
       list<Integration_out__c> intOuts = new list<Integration_out__c>();
       map<string, Object> jsonMap = new map<string, Object>();
       Map<Integer, String> jsonCols = new Map<Integer, String>{1 => 'json_message__c', 2 => 'json_message_2__c', 3 => 'json_message_3__c', 4 =>'json_message_4__c', 5 => 'json_message_5__c', 6 => 'json_message_6__c', 7 => 'json_message_7__c', 8 => 'json_message_8__c', 9 => 'json_message_9__c' , 10 => 'json_message_10__c'};                   
       
        map<string, set<Id>> objIdMap = new map<string, set<Id>>();
        for(Integration_Out__c ints : scope) {
            Id modifiedId = (Id)ints.Modified_Record_Id__c;
            string objectName = modifiedID.getSobjectType().getDescribe().getName();
            if(objIdMap.containsKey(objectName)) {
                objIDMap.get(objectName).add(modifiedId);
            }
            else {
                objIDmap.put(objectName, new set<Id>{modifiedId});
            }
        }
        
        map<string, Schema.DescribeSObjectResult> sobjResMap = new map<string, Schema.DescribeSObjectResult>();
        for(Schema.DescribeSObjectResult result : Schema.describeSObjects(new list<string>(objIdMap.keyset()))) {
            sobjResMap.put(result.getName(), result);
        }
        
        
        map<string, map<Id, SObject>> recordsMap = new map<string, map<Id, SObject>>();
        for(string objectName : objIdMap.keyset()) {
            Schema.DescribeSObjectResult res = sobjResMap.get(objectName);
            map<string, Schema.SObjectField> fieldMap = res.fields.getMap();
            List<string> fields = new List<string>();
            for ( string fn : fieldMap.keyset()){
                schema.DescribeFieldResult fldR = fieldMap.get(fn).getDescribe();
                if( fldR.isAccessible() ) {
                    fields.add(fldR.getName());
                }
            }
            
            set<Id> recordIds = objIDMap.get(objectName);
            String objQuery = 'SELECT '+ String.join( fields, ',' ) + ' FROM ' + res.getName() +	' WHERE ' +	' id IN:recordIds';
            system.debug('objQuery: '+objQuery);
            recordsMap.put(objectName, new map<Id, SObject>(Database.query(objQuery)));
        }
        
        
      for(Integration_Out__c ints : scope) {
       try {
           //system.debug('ints.Modified_Record_Id__c: '+ints.Modified_Record_Id__c);
           string idCast = ints.Modified_Record_Id__c;
           id recordId = Id.valueOf(idCast);
           string objectName = recordId.getSobjectType().getDescribe().getName();
           
           SObject record = recordsMap.get(objectName).get(recordId);
           if (record == null){
              ints.Event_Type__c = 'D';
           }
           
           List<SObject> records = new list<Sobject>{record};
	
    system.debug('records:'+records);
  	Map<String, Object> topObj = new Map<String, Object>();
    
    Map<String, Object> obj = new Map<String, Object>(); 
    //Map<String, String> theEventObj = new Map<String, String>();
           if (ints.Event_Type__c == 'D'){
               obj.put('target', new map<string, string>{});
           } else {
           if (records.size() == 0 ){
               ints.status__c = 'E';
               ints.error_message__c = 'no data found for that record id';
               obj.put('target', null);
           } else {
               map<string, Object> recMap = new map<string, Object>{'type' => new list<string>{'sf:sObject', objectName}};
               SObject rec = record;
               
 				Schema.DescribeSObjectResult fieldNames = sobjResMap.get(objectName);
            	map<string, Schema.SObjectField> fieldMap = fieldNames.fields.getMap();
                          
           		 List<string> cleanFieldNames = new List<string>();
           		for ( string fn : fieldMap.keyset()){
              		schema.DescribeFieldResult fldRes = fieldMap.get(fn).getDescribe();
               		if( fldRes.isAccessible() ) {
                   		cleanFieldNames.add(fldRes.getName());
                 
               		}
           		}           
               for(string fn : cleanFieldNames) {
                   recMap.put(fn, rec.get(fn) != null ? rec.get(fn) : '');
                   //intense debugging!
                   //system.debug('column: '+fn+' / sObject rec: '+rec.get(fn)+' / string value of'+string.valueOf(rec.get(fn)) );
               }
               system.debug('recMap: '+recMap);
               obj.put('target', recMap); //records[0]
           }
           }
           
	//theEventObj.put('event', 'myeventObj');
           obj.put ( 'event', new Map<String, String>{
                'source_database'=>'ascend',
                'source_table'=>ints.Object_Api_Name__c,
                'source_schema'=>'none',
                'event_id'=>ints.Modified_Record_Id__c,
                'event_time'=>ints.Date_Modified__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''),
                'event_type'=>ints.Event_Type__c,
                'event_sequence_number'=>ints.Outbound_Id__c,
                'event_last_modified_by'=>ints.LastModifiedById,
                'integration_record_id'=>String.valueOf(ints.Integration_Record_ID__c)
                    }
                      //  , 'target', new Map<String, String>{}   
                );
    topObj.put('object', obj);

 
     String full_json = JSON.serializePretty(topObj, false);      
    
    system.debug('json length ' + full_json.length());
    if (full_json.length() > 130000 )  {  
        if(!ints.long_data_ind__c){
            ints.long_data_ind__c = true;
            ints.json_message__c = null;
        }else{
            integer json_col_num = 1;
            for(Integer i=0; i<full_json.length(); i+=130000) {
                if((i + 130000) < full_json.length()){
                    ints.put(jsonCols.get(json_col_num), full_json.substring(i, i+130000) ) ; 
                    system.debug('here in  first case ' + i + ' ' + (i+130000));
                }else{
                    ints.put(jsonCols.get(json_col_num), full_json.substring(i, full_json.length()) ) ;
                    system.debug('here in  second case ' + i + ' ' +(full_json.length()-1) );
                }
                json_col_num +=1; 
            }
            ints.status__c = 'R';  ///change to R when ready to move them to talend
        }
    }else{
        ints.json_message__c = full_json;
        ints.status__c = 'R';

    }    
    ints.Last_Processed_Date__c = system.now();
          //if (ints.Object_Api_Name__c != objectName) { ints.Object_Api_Name__c = objectName;}
    } catch (exception e) {
        ints.error_message__c = 'Message : ' + e.getMessage() + '\nError string : ' + e.getStackTraceString();
        ints.status__c = 'E';
        ints.Last_Processed_Date__c = system.now();
        ints.Processed_Count__c = ints.Processed_Count__c+1;
        //add processed count, and last processed date
         } 
      }
        List <Database.SaveResult> res = Database.update(scope, false);     
        List <Integration_out__c> errorRecords = new List<Integration_out__c>();
        for (Integer i = 0; i < scope.size(); i++) {
            Database.SaveResult s = res[i];
            if (!s.isSuccess()) {
                Integration_out__c e  = [select id, status__c ,error_message__c, Last_Processed_Date__c, Processed_Count__c from Integration_out__c where id = :scope[i].id];
                e.status__c = 'E';
                try{                e.error_message__c = 'Field ' + + s.getErrors()[0].getFields() + ' Status : ' + s.getErrors()[0].getStatusCode();}
                catch (exception f){e.error_message__c = 'error on record insertion';}
                e.Last_Processed_Date__c = system.now();
                e.Processed_Count__c = e.Processed_Count__c+1;
                errorRecords.add(e);
             } 
        }

        if(errorRecords.size() > 0) {
           update errorRecords;
        } 
        //update scope;
    }
    
    global void finish(Database.BatchableContext bc){
       
    }   
   
}