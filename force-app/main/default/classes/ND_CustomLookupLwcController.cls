public class ND_CustomLookupLwcController {
    
    // Method to fetch lookup search result  for user object
    // @ param1 = userName @param2 = User (objectName)  
     @AuraEnabled(cacheable=true)
     public static list<sObject> fetchLookupData(string searchKey , string sObjectApiName) {    
         List < sObject > returnList = new List < sObject > ();
 
         string sWildCardText = '%' + searchKey + '%';
         string sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where IsActive=true AND Name Like : sWildCardText order by createdDate DESC LIMIT 10';
         for (sObject obj: database.query(sQuery)) {
             returnList.add(obj);
         }
         return returnList;
     }
     
     // Method to fetch lookup default value for user record.
     // @param1 = userId, @param2= User (object Api Name)
     @AuraEnabled
     public static sObject fetchDefaultRecord(string recordId , string sObjectApiName) {
         string sRecId = recordId;    
         string sQuery = 'Select Id,Name From ' + sObjectApiName + ' Where Id = : sRecId LIMIT 1';
         for (sObject obj: database.query(sQuery)) {
             return obj;
         }
         return null;
     }
    
    /* 
     * @getAccounts : Using a custom metadata  record to get SOQL query , object name and filters here Account and Assignments records returned
     * @prevAccRef = Previous record Id (using to fetch records using pagination concept)
     * @nextAccRef = Next record Id (using to fetch records using pagination concept)
     * @assType = picklist values (possible values are Primary Relationship Manager, Secondary Relationship Manager.)
     * @OrgType = Account/Organization types (possible values are Household and Corporation or Foundation)
     * @massAssType = picklist possible values are Mass Drop ,Mass Add
     * @recTypeId = Account/Organization recordtype (Household and Corporation or Foundation Details )
     * @userId = current userId. 
     * */
     @AuraEnabled
     public static  DataTableResponse getAccounts(string prevAccRef,String nextAccRef,String assType,String OrgType,String massAssType,String recTypeId,String userId,List<String> PrimeIdList){
        DataTableResponse dtr1= new DataTableResponse();
        system.debug('Harshadebug'+PrimeIdList);
        //new 
        // Remove double quotes from each string
       List<String> cleanedList = new List<String>();
       for (String originalString : PrimeIdList) {
            cleanedList.add(originalString.replaceAll('"', ''));
             }


//hree   
         try {
            List<Account> accList;
             
            if(massAssType =='Mass Drop') {
                 dtr1 =prepareData('Drop',prevAccRef,nextAccRef,'','','','',userId,cleanedList);
            }
            else if(string.isNotBlank(assType) && string.isNotBlank(OrgType) && 
                string.isNotBlank(massAssType) && massAssType =='Mass Add' && OrgType=='Household' && 
                assType =='Primary Relationship Manager' 
            ){
                dtr1 =prepareData('Unassigned Households',prevAccRef,nextAccRef,assType,OrgType,massAssType,recTypeId,userId,cleanedList);
             }
            else if( string.isNotBlank(assType) && string.isNotBlank(OrgType) && 
                string.isNotBlank(massAssType) && massAssType =='Mass Add' && OrgType=='Household' && 
                assType =='Secondary Relationship Manager' 
            ){
                dtr1 =prepareData('Unassigned Households Secondary',prevAccRef,nextAccRef,assType,OrgType,massAssType,recTypeId,userId,cleanedList);
             } 
            else if( string.isBlank(assType) && string.isNotBlank(OrgType) && 
                string.isNotBlank(massAssType) && massAssType =='Mass Add' && OrgType=='Corporation or Foundation'                 
            ){
                dtr1 =prepareData('Unassigned CoorOrCorp',prevAccRef,nextAccRef,assType,OrgType,massAssType,recTypeId,userId,cleanedList);
             }               
             return dtr1;

        } catch (Exception e) {
            
            system.debug('Error'+e.getMessage()+e.getStackTraceString());
            //return new DataTableResponse();
            throw new AuraHandledException(e.getMessage() + e.getStackTraceString());
        }
     }
    /*
     * saveResult : getAccounts retrun record to Table on UI and selected record will be passed to SaveResult method
     * @massAssType : same as above
     * @otherParams : JSON string   {'comments': input values, 'NewAssgComments': input values, 'newSupervisior': UserId other than current user, 'selOrgType': Account/Organization types (possible values are Household and Corporation or Foundation), 'selAssType': same as above AssType,'enableFundraiser': ture/false,'hc': Prospect category on Account/Organization,'ht':'hc': Household types on Account/Organization ,'reEvalDate': today date  }
     * @data : JSON string (List of accountIds , List of Assignments)
     * */
     @AuraEnabled
     public static String saveResult( string massAssType,String otherParams,string data){
         
        try{
        System.debug(data);
        List<String> ids= (List<String>)JSON.deserialize(data,List<String>.class);
        Map<string,object> otherMap = (Map<string,object>) JSON.deserializeUntyped(otherParams) ;
        String OrgType = (string)otherMap.get('selOrgType');
        String assType = (string)otherMap.get('selAssType');
        String recTypeId =OrgType=='Household'?(string)otherMap.get('orgHouseholdRecordType'):(string)otherMap.get('orgCorporationRecordType');
        Boolean enableFundraiser = (boolean)otherMap.get('enableFundraiser');
        String newSupervisior = (string)otherMap.get('newSupervisior');
        String userId = (string)otherMap.get('userId');
        String comments = (string)otherMap.get('comments'); 
        String NewAssgComments =  (string)otherMap.get('NewAssgComments'); 
        Date reEvalDate =null;
        if(otherMap.get('reEvalDate')!=null)
         reEvalDate = Date.valueof((string)otherMap.get('reEvalDate'));
        String hc = (String)otherMap.get('hc');
        String ht = (String)otherMap.get('ht');  
            
        String reslutMsg=''; 
         system.debug(otherMap);
         system.debug(ids);
         Mass_Assignment_Table_Config__mdt configData= [Select Id,Batch_Size__c from Mass_Assignment_Table_Config__mdt where Label='Unassigned Households']; 

         if(massAssType =='Mass Drop') {
            string msg = '\\n The following Households and/or Organizations have been dropped from your portfolio: \\n {0} \\n Please review the individual Assignment records for additional information. \\n CC';
            String msg2 ='\\n The following Households and/or Organizations have been added to your portfolio: \\n {0}\\n General Assignment Comments: {1} \\n Please review the individual Assignment records for additional information. \\n CC';
            configData= [Select Id,Batch_Size__c from Mass_Assignment_Table_Config__mdt where Label='Drop']; 
             //List<string> recids =dropRecords('Drop',ids,comments,msg,userId,hc,ht,reEvalDate);
            Database.executeBatch(new ND_MassAssignmentsDropBatch('Drop',ids,comments,msg,userId,hc,ht,reEvalDate,newSupervisior,NewAssgComments, msg2,enableFundraiser),Integer.valueof(configData.Batch_Size__c));
      
             reslutMsg = 'Households and/or Organizations have been dropped from your portfolio';
             if(enableFundraiser){
                 System.debug('$$'+ 'Inside');
                 msg='\\n The following Households and/or Organizations have been added to your portfolio: \\n {0}\\n General Assignment Comments: {1} \\n Please review the individual Assignment records for additional information. \\n CC';
                 //addNewSupervisor(recids,newSupervisior,NewAssgComments, msg);
                 reslutMsg = 'Households and/or Organizations have been added to your portfolio';
             }
             
         }
         else if(massAssType =='Mass Add' && OrgType=='Household' && assType =='Primary Relationship Manager'){
             string msg = '\\n You have been assigned as the Primary Relationship Manager for the following Households: \\n {0} \\n General Assignment Comments: {1} \\n Please review the individual Assignment records for additional information. \\n CC ';
            //getSelectedAccRecords('Unassigned Households',ids,userId,'',assType,comments,msg);
            Database.executeBatch(new ND_MassAssignmentsAddBatch('Unassigned Households',ids,userId,'',assType,comments,msg),Integer.valueof(configData.Batch_Size__c));

             reslutMsg = 'You have been assigned as the Primary Relationship Manager';
         }
         else if(massAssType =='Mass Add' && OrgType=='Household' && assType =='Secondary Relationship Manager'){
             string msg = '\\n You have been assigned as the Primary Relationship Manager for the following Households: \\n {0} \\n General Assignment Comments: {1} \\n Please review the individual Assignment records for additional information. \\n CC ';
         
             //getSelectedAccRecords('Unassigned Households Secondary',ids,userId,'',assType,comments,msg);
              Database.executeBatch(new ND_MassAssignmentsAddBatch('Unassigned Households Secondary',ids,userId,'',assType,comments,msg),Integer.valueof(configData.Batch_Size__c));

             reslutMsg = 'You have been assigned as the Secondary Relationship Manager';
         }
         else if(massAssType =='Mass Add' && OrgType=='Corporation or Foundation'){
             string msg = '\\n The following Organizations have been added to your portfolio: \\n {0} \\n General Assignment Comments: {1} \\n Please review the individual Assignment records for additional information. \\n CC ';
         
             //getSelectedAccRecords('Unassigned CoorOrCorp',ids,userId,'','',comments,msg);
             Database.executeBatch(new ND_MassAssignmentsAddBatch('Unassigned CoorOrCorp',ids,userId,'','',comments,msg),Integer.valueof(configData.Batch_Size__c));
             reslutMsg = 'Organizations have been added to your portfolio';
         }
         return 'Ok';
        }Catch(Exception e){
            system.debug('Error'+e.getMessage()+e.getStackTraceString());
            //return  'Error:'+ e.getMessage();
            throw new AuraHandledException(e.getMessage()+e.getStackTraceString());
        }
         
     }
    public static Map<string,Object> dropRecords(String cmdt,List<string> ids,String comments,String msg,String userId,String hc,String ht,Date reEvalDate){
        Mass_Assignment_Table_Config__mdt configData= [Select Id,Limit_Records__c,Object_APIName__c,Field_API_Name__c,Header_Value__c,Query__c,Query_Filters__c,Label from Mass_Assignment_Table_Config__mdt where Label=:cmdt];                       
        String st ='';
        //List<ucinn_ascendv2__Assignment__c> assList = new List<ucinn_ascendv2__Assignment__c>(); 
        List<account> accList = new List<account>(); 
        st= st+ configData.Query__c.replace('from ucinn_ascendv2__Assignment__c', ' ,Comments__c from ucinn_ascendv2__Assignment__c')+ ' where id=:ids';
        List<ucinn_ascendv2__Assignment__c> assList = database.query(st);
        List<string> accIds = new List<String>();
        string accName='';
        List<string> accNames = new List<String>();
        for(ucinn_ascendv2__Assignment__c rec:assList ){
            rec.ucinn_ascendv2__Assignment_End_Date__c = system.today().addDays(-1);
            rec.Comments__c = String.isNotBlank(rec.Comments__c)?rec.Comments__c+'   '+comments.stripHtmlTags():comments.stripHtmlTags();
            rec.nd_Manual_Assignment_Drop__c = false; 
            if(rec.ucinn_ascendv2__Account__c !=null){
                //accName = rec.ucinn_ascendv2__Account__r.Name;
                accNames.add(rec.ucinn_ascendv2__Account__r.Name);
                accIds.add(rec.ucinn_ascendv2__Account__c);
                if(String.isNotBlank(hc))
                    accList.add(new account(id=rec.ucinn_ascendv2__Account__c,ND_Household_Category__c=hc,ND_Household_Types__c=ht,ND_Re_Evaluation_Date__c=reEvalDate));
            }
        }
        
         String errorMsg='';
         
         List<String> records = new List<String>();        
        
        //if(accList.size()>0)
           // update accList;
        
         if(accList.size()>0){
            List<Database.SaveResult> Results = Database.Update(accList, false);
            for(Integer i=0;i<Results.size();i++){
                if (!Results.get(i).isSuccess()){                    
                    Database.Error error = Results.get(i).getErrors().get(0);String failedDML = error.getMessage();
                    String record = 'Organization,'+String.valueof(accList[i].Id)+','+failedDML;records.add(record);
                }        
            }            
        }         
        
        //if(assList.size()>0)
            //update assList;

         if(assList.size()>0){
            List<Database.SaveResult> Results = Database.Update(assList, false);
            for(Integer i=0;i<Results.size();i++){
                if (!Results.get(i).isSuccess()){                    
                    Database.Error error = Results.get(i).getErrors().get(0);String failedDML = error.getMessage();
                    String record = 'Assignment,'+String.valueof(assList[i].Id)+','+failedDML;records.add(record);
                }        
            }            
        } 
        
        if(records.size()>0)
            errorMsg =  String.join(records,'\n');
        
        accName = string.join(accNames, ', ');
        msg= String.format(msg, new List<string>{accName,comments.stripHtmlTags()});
        
        //post to chatter
        system.debug('@#'+ comments);
        postChatterRecordFlow(userId,comments.stripHtmlTags(),accName,'Drop','','');
        //system.debug('@#'+ comments);
        //postChatterRecord(userId,msg);  
        Map<string,Object> result = new Map<string,object>();
        result.put('accIds',accIds);
        result.put('msg',errorMsg);
        //return accIds;
        return result;   
    }
    
    public static String  addNewSupervisor(List<string> ids,string newFundraiserId,String NewAssgComments,string msg){
        String accName ='';
        List<string> accNames = new List<String>();
        List<ucinn_ascendv2__Assignment__c> assList = new List<ucinn_ascendv2__Assignment__c>();
        for(account ac: [Select id,Name from Account where id=:ids]){
            ucinn_ascendv2__Assignment__c asRecord= new ucinn_ascendv2__Assignment__c();
            asRecord.ucinn_ascendv2__Assigned_Relationship_Manager_User__c = newFundraiserId;
            asRecord.ucinn_ascendv2__Account__c= ac.Id;
            asRecord.ucinn_ascendv2__Assignment_Start_Date__c = System.today();
            asRecord.ucinn_ascendv2__Assignment_Type__c ='Primary Relationship Manager';
            asRecord.Comments__c = NewAssgComments.stripHtmlTags();
            assList.add(asRecord);
            accNames.add(ac.Name);
            
        }
        accName = string.join(accNames, ', ');
        //if(assList.size()>0)
            //Insert assList;
        
        String errorMsg='';
        if(assList.size()>0){
            List<Database.SaveResult> Results;
            String csvColumnHeader = 'Household Id,Error Message\n';
            List<String> records = new List<String>();
            Results = Database.Insert(assList, false);
            for(Integer i=0;i<Results.size();i++){
                if (!Results.get(i).isSuccess()){                    
                    Database.Error error = Results.get(i).getErrors().get(0);String failedDML = error.getMessage();
                    String record = String.valueof(assList[i].ucinn_ascendv2__Account__c)+','+failedDML;records.add(record);
                }        
            }
            if(records.size()>0)
             errorMsg = String.join(records,'\n');
            
        }        
        msg= String.format(msg, new List<string>{accName,NewAssgComments.stripHtmlTags()});
        
        //post to chatter
        //postChatterRecord(newFundraiserId,msg);  
        system.debug('@#'+ NewAssgComments);
        postChatterRecordFlow(newFundraiserId,NewAssgComments.stripHtmlTags(),accName,'Drop','','New');  
        return errorMsg;
    }
    public static string getSelectedAccRecords(String cmdt,List<string> ids,string userId,string newFundraiserId,String asType,String comments,string msg){
        
        Mass_Assignment_Table_Config__mdt configData= [Select Id,Limit_Records__c,Object_APIName__c,Field_API_Name__c,Header_Value__c,Query__c,Query_Filters__c,Label from Mass_Assignment_Table_Config__mdt where Label=:cmdt];                       
        String st ='';
        st= st+ configData.Query__c+ ' where id=:ids ';
        List<Account> acc = database.query(st);
        List<ucinn_ascendv2__Assignment__c> assList = new List<ucinn_ascendv2__Assignment__c>();
        String accName ='';
        List<string> accNames= new List<string>();
        for(account ac: acc){
            ucinn_ascendv2__Assignment__c asRecord= new ucinn_ascendv2__Assignment__c();
            asRecord.ucinn_ascendv2__Assigned_Relationship_Manager_User__c = userId;
            asRecord.ucinn_ascendv2__Account__c= ac.Id;
            asRecord.ucinn_ascendv2__Assignment_Start_Date__c = System.today();
            asRecord.ucinn_ascendv2__Assignment_Type__c =string.isBlank(asType)?'Primary Relationship Manager':asType;
            asRecord.Comments__c = comments.stripHtmlTags();
            assList.add(asRecord);
            accNames.add(ac.Name);
          
        }
        accName = String.join( accNames, ', ' ); 
        //if(assList.size()>0)
            //Insert assList;
         
        String errorMsg='';
        List<String> records = new List<String>();
        if(assList.size()>0){
            List<Database.SaveResult> Results;                        
            Results = Database.Insert(assList, false);
            for(Integer i=0;i<Results.size();i++){
                if (!Results.get(i).isSuccess()){                    
                    Database.Error error = Results.get(i).getErrors().get(0);String failedDML = error.getMessage();
                    String record = String.valueof(assList[i].ucinn_ascendv2__Account__c)+','+failedDML;records.add(record);
                }        
            }
        }
        if(records.size()>0)
            errorMsg = String.join(records,'\n');    
            
        msg= String.format(msg, new List<string>{accName,comments.stripHtmlTags()});
        
        //post to chatter
        //postChatterRecord(userId,msg);
        string strType='';
        if(String.isNotBlank(asType))
            strType=(asType=='Primary Relationship Manager'?'PRM':'SRM');
        
        if(cmdt=='Unassigned CoorOrCorp'){
            cmdt='Corporations_and_Organizations';
        }else if(cmdt=='Unassigned Households'){
            cmdt='Household';
        }else if(cmdt=='Unassigned Households Secondary'){
            cmdt='Household';
        }
        system.debug('@#'+ comments);
        postChatterRecordFlow(userId,comments.stripHtmlTags(),accName,'Add',cmdt,strType);
        
        return errorMsg;
    }
    public static void postChatterRecordFlow(string userId, String varBody,String varHouseholdCollection,String varActionType,
                                            String varType,String varAssignmentType){
        
        
        Map<String, Object> Params = new Map<String, Object>();
        String FundraiserDC1='';
        String FundraiserManagerID1='';                                      
        User uRecord = [Select Development_Coordinator__c,ManagerId from user where id=:userId];
        if(uRecord.Development_Coordinator__c!=null)
            FundraiserDC1=uRecord.Development_Coordinator__c;
        if(uRecord.ManagerId!=null)
            FundraiserManagerID1=uRecord.ManagerId;                                                
        Params.put('varUserId',userId);
        Params.put('varActionType',varActionType);
        params.put('varAssignmentType',varAssignmentType);                                       
        Params.put('varBody',varBody);
       Params.put('varType',varType);
        Params.put('varHouseholdCollection',varHouseholdCollection);
        Params.put('FundraiserDC',FundraiserDC1);
        Params.put('FundraiserManagerID',FundraiserManagerID1);
        system.debug('@flow'+Params);
        //create instance of Interview
        Flow.Interview.Mass_Assignments_Add_Drop_to_Chatter stage = new Flow.Interview.Mass_Assignments_Add_Drop_to_Chatter(Params);
        stage.start();        
    }   
    
    /*public static void postChatterRecord(string userId, String messagetext){
        String communityId = null;
        String userToMention = userId;
        User uRecord = [Select Development_Coordinator__c,ManagerId from user where id=:userId];
        
        String subjectId = userInfo.getUserId();
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();        
        mentionSegmentInput.id = userToMention;
        messageBodyInput.messageSegments.add(mentionSegmentInput);
        
        textSegmentInput.text = messagetext;
        messageBodyInput.messageSegments.add(textSegmentInput);
        
        ConnectApi.MentionSegmentInput mentionSegmentInput2 =new ConnectApi.MentionSegmentInput();
        mentionSegmentInput2.id=uRecord.Development_Coordinator__c;
        ConnectApi.MentionSegmentInput mentionSegmentInput3 =new ConnectApi.MentionSegmentInput();
        mentionSegmentInput3.id=uRecord.ManagerId;
        if(uRecord.Development_Coordinator__c!=null)
            messageBodyInput.messageSegments.add(mentionSegmentInput2);
        if(uRecord.ManagerId!=null)
            messageBodyInput.messageSegments.add(mentionSegmentInput3);
        
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = subjectId;
        
        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(null, feedItemInput);
             
    }*/
    
    public static DataTableResponse prepareData(String cmdt,string prevAccRef,String nextAccRef,String assType,String OrgType,String massAssType,string selIds,string userId,List<String> NDPrimeIDList){
        system.debug('#4'+assType);
        system.debug('#%%%%%%'+NDPrimeIDList);

        DataTableResponse result = new DataTableResponse();

        if(NDPrimeIDList.size()>0)
        {
            result = prepareDataforCSV(cmdt,assType,OrgType,massAssType,selIds,userId,NDPrimeIDList);
        }
        else if(NDPrimeIDList.size()==0){
            
        try{
        DataTableResponse dtr= new DataTableResponse();
        String recTypeId,st='';
        Mass_Assignment_Table_Config__mdt configData= [Select Id,Limit_Records__c,Object_APIName__c,Field_API_Name__c,Header_Value__c,Query__c,Query_Filters__c,Label from Mass_Assignment_Table_Config__mdt where Label=:cmdt];                
        
        String sobjectName= configData.Object_APIName__c;
        recTypeId=selIds;
        system.debug(recTypeId);
        List<user> userRecord = [Select id,ND_Group_Region__c from user where id=:userId];
        //String queryStrRec= 'Select Id from recordtype where isActive=true AND sobjectType=:sobjectName AND Name=:OrgType';
        //recTypeId= Database.query(queryStrRec).Id;
        String filterStr ='';
        if(userRecord!=null && !userRecord.isEmpty()){
            string re= userRecord[0].ND_Group_Region__c;
            if(cmdt!='Drop')
                filterStr = filterStr+ ' Prospect_Region__c=:re AND '; 
        }
        if(string.isNotBlank(recTypeId))
            filterStr = filterStr+' recordTypeId=:recTypeId '+ configData.Query_Filters__c;
        else
            filterStr =  filterStr+' '+configData.Query_Filters__c;
        system.debug('@filterStr'+filterStr);
        string countQuery='Select count() from '+configData.Object_APIName__c+' where '+ filterStr;
        system.debug('@countQuery'+countQuery);
        Integer recCount= Database.countQuery(countQuery );
        
        if(configData!=null){
            List<string> tableHeaders =configData.Header_Value__c.split(',');
            
            List<string> tableColumns= new List<String>();
            Map<string,Map<string,string>> tableMetaDataCrossObjInfo=  new Map<string,Map<string,string>>();
            for(String lst: configData.Field_API_Name__c.split(',')){
                if(lst.contains(':') ){
                    map<string,string> pro =new map<string,string>{
                        'label'=> lst.split(':')[1].replace('.',''),
                            'data'=> lst.split(':')[1]
                            }; 
                    tableMetaDataCrossObjInfo.put(lst.split(':')[0],pro);
                    tableColumns.add(lst.split(':')[0]);
                }else{
                    tableColumns.add(lst);
                }
            }
            Map<string,string> tableMetadata= new Map<string,string>();
            Map<string,string> localData = new Map<string,string>();
            String queyStr =configData.Query__c;
            
            Integer limitstr = Integer.valueof(configData.Limit_Records__c);
            List<DataTableColumns> tch = new List<DataTableColumns>();
                                   
            for(Integer i=0;i<tableHeaders.size();i++){
                tableMetadata.put(tableColumns[i],tableHeaders[i]);
            }
            system.debug('@prevAccRef'+prevAccRef);
            system.debug('@nextAccRef'+nextAccRef);
            if(string.isBlank(prevAccRef)  && string.isBlank(nextAccRef))
                st= st+ queyStr+ ' where '+ filterStr +' order by Id ASC '+ ' limit :limitstr';
            else if(string.isBlank(prevAccRef) && string.isNotBlank(nextAccRef))
                st= st+ queyStr + ' where Id >:nextAccRef AND'+ filterStr+ ' order by Id ASC '+ ' limit :limitstr'; 
            else
                st= st+ queyStr+ ' where Id >=: prevAccRef AND Id <=: nextAccRef AND '+ filterStr +' order by Id ASC '+ ' limit :limitstr'; 
            
            system.debug('#'+st);
            List<sobject> accSObjRecords = Database.query(st);            
            system.debug(tableHeaders);
            system.debug(accSObjRecords.size());
            Map<string,FieldDefinition> fdMap = new Map<string,FieldDefinition>();
            for(FieldDefinition  fdl : [SELECT QualifiedApiName,DataType FROM FieldDefinition WHERE EntityDefinitionId=:sobjectName AND QualifiedApiName IN :tableColumns]){
                fdMap.put(fdl.QualifiedApiName,fdl);
            }
            for(string  tb: tableMetadata.keyset() ){
                if(!fdMap.containsKey(tb))
                    continue;
                FieldDefinition fd =fdMap.get(tb);
                DataTableColumns dc= new DataTableColumns();
                dc.label= tableMetadata.get(fd.QualifiedApiName);
                dc.fieldName=fd.QualifiedApiName;
                dc.sortable = true;
                dc.wrapText = true;
                
                if(fd.DataType=='Name' || fd.QualifiedApiName=='Name'){
                    localData.put('Id',fd.QualifiedApiName+'rid');
                    dc.fieldName=fd.QualifiedApiName+'rid';
                    dc.type='url';                    
                    dc.typeAttributes=new  DataTableTypeAttributes(new DataTableTypeAttributesfield('Name'),'_blank');
                }else if(fd.DataType.contains('Lookup') && fd.QualifiedApiName!='Id'){
                    localData.put(fd.QualifiedApiName,fd.QualifiedApiName+'rid');
                    dc.fieldName=fd.QualifiedApiName+'rid';
                    dc.type='url'; 
                    Map<string,string> localProp = new map<string,string>(tableMetaDataCrossObjInfo.get(fd.QualifiedApiName));
                    dc.typeAttributes=dc.typeAttributes=new DataTableTypeAttributes(new DataTableTypeAttributesfield(localProp.get('label')),'_blank');
                }else if(fd.DataType=='Date/Time' && fd.DataType=='Date'){
                    dc.type='date';
                    dc.typeAttributes=null;
                }else if(fd.DataType.contains('Currency')){
                    dc.type='currency';
                    dc.cellAttributes = new cellAttributescls('left');
                    dc.typeAttributes=null;
                }else if(fd.DataType.contains('Email')){
                    dc.type='email';
                    dc.typeAttributes=null;
                }else if(fd.DataType.contains('Phone')){
                    dc.type='phone';
                    dc.typeAttributes=null;
                }else if(fd.DataType.contains('Number')){
                    dc.type='number';
                    dc.cellAttributes = new cellAttributescls('left');
                    dc.typeAttributes=null;
                    dc.typeAttributes=null;
                }else if(fd.DataType.contains('Picklist')){
                    dc.type='text';
                    dc.typeAttributes=null;}                
                else{
                    dc.type='text';
                    dc.typeAttributes=null;
                }
                system.debug(tch);
                tch.add(dc);
                
            }                
            
            dtr.lstDataTableColumns= tch;
            dtr.lstDataTableData=accSObjRecords;
            dtr.modifiedHeaders = localData;
            dtr.tableMetaDataCrossObjInfo = tableMetaDataCrossObjInfo;
            dtr.recCount = recCount;
            dtr.recordsPerPage = Integer.valueof(configData.Limit_Records__c);

                    
            }
            result=dtr;
        }Catch(Exception e){
            System.debug('@'+e.getStackTraceString()); 
            throw new AuraHandledException(e.getMessage()+e.getStackTraceString());
        }
    }
    system.debug('result'+result);
    return result;
    
    }
    public class DataTableColumns {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled       
        public String fieldName {get;set;}
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled 
        public Boolean sortable {set;get;}
        @AuraEnabled 
        public Boolean wrapText {set;get;}        
        @AuraEnabled 
        public cellAttributescls cellAttributes {set;get;}          
        @AuraEnabled  
        public  DataTableTypeAttributes typeAttributes {get;set;}

    }  
    public class cellAttributescls{
        @AuraEnabled 
        public String alignment {set;get;} 
        public cellAttributescls(string s){
            this.alignment =s;
        }
    }

    public class DataTableTypeAttributes{
        @AuraEnabled
        public DataTableTypeAttributesfield label {get;set;}
        @AuraEnabled 
        public string target {get;set;}

        public   DataTableTypeAttributes(DataTableTypeAttributesfield tf,string target){
            this.target = target;
            this.label=tf;
        }

    }
    public class DataTableTypeAttributesfield{
        @AuraEnabled
        public string fieldName {get;set;}
        public   DataTableTypeAttributesfield(string name){
            this.fieldName = name;
        }
    }    
     public class DataTableResponse {
        @AuraEnabled
        public List<DataTableColumns> lstDataTableColumns {get;set;}
        @AuraEnabled
        public List<sObject> lstDataTableData {get;set;}  
        @AuraEnabled
        public Integer recCount  {get;set;}  
        @AuraEnabled
        public Map<string,string> modifiedHeaders {get;set;}  
        @AuraEnabled
        public Map<string,Object> tableMetaDataCrossObjInfo {get;set;} 
        @AuraEnabled
        public Integer recordsPerPage {set;get;} 
        
            
    }
    
    
    public static DataTableResponse prepareDataforCSV(String cmdt,String assType,String OrgType,String massAssType,string selIds,string userId,List<String> NDPrimeIDList){
       
        system.debug(cmdt);
        system.debug(assType);
        system.debug(OrgType);
        system.debug(massAssType);
        system.debug(selIds);
        system.debug(userId);
        system.debug(NDPrimeIDList);
        try{
            DataTableResponse dtr= new DataTableResponse();
            String recTypeId,st='';
            Mass_Assignment_Table_Config__mdt configData= [Select Id,Limit_Records__c,Object_APIName__c,Field_API_Name__c,Header_Value__c,Query__c,Query_Filters__c,Label from Mass_Assignment_Table_Config__mdt where Label=:cmdt];                
            
            String sobjectName= configData.Object_APIName__c;
            recTypeId=selIds;
            system.debug(recTypeId);
            List<user> userRecord = [Select id,ND_Group_Region__c from user where id=:userId];
            
            if(configData!=null){
                List<string> tableHeaders =configData.Header_Value__c.split(',');
                
                List<string> tableColumns= new List<String>();
                Map<string,Map<string,string>> tableMetaDataCrossObjInfo=  new Map<string,Map<string,string>>();
                for(String lst: configData.Field_API_Name__c.split(',')){
                    if(lst.contains(':') ){
                        map<string,string> pro =new map<string,string>{
                            'label'=> lst.split(':')[1].replace('.',''),
                                'data'=> lst.split(':')[1]
                                }; 
                        tableMetaDataCrossObjInfo.put(lst.split(':')[0],pro);
                        tableColumns.add(lst.split(':')[0]);
                    }else{
                        tableColumns.add(lst);
                    }
                }
                Map<string,string> tableMetadata= new Map<string,string>();
                Map<string,string> localData = new Map<string,string>();
                String queyStr =configData.Query__c;
                
                Integer limitstr = Integer.valueof(configData.Limit_Records__c);
                List<DataTableColumns> tch = new List<DataTableColumns>();
                                       
                for(Integer i=0;i<tableHeaders.size();i++){
                    tableMetadata.put(tableColumns[i],tableHeaders[i]);
                }
              
                if(cmdt!='Drop')
                    st = queyStr + ' WHERE nd_Primary_Const_Donor_ID__c IN :NDPrimeIDList AND ';
                else
                    st = queyStr + ' WHERE ucinn_ascendv2__Account__r.nd_Primary_Const_Donor_ID__c  IN :NDPrimeIDList AND ';
                system.debug('#st0'+st);
                String filterStr ='';
                if(userRecord!=null && !userRecord.isEmpty()){
                    string re= userRecord[0].ND_Group_Region__c;
                    if(cmdt!='Drop')
                        filterStr = filterStr+ ' Prospect_Region__c=:re AND '; 
                }
                if(string.isNotBlank(recTypeId))
                    filterStr = filterStr+' recordTypeId=:recTypeId '+ configData.Query_Filters__c;
                else
                    filterStr =  filterStr+' '+configData.Query_Filters__c;
                system.debug('@filterStr'+filterStr);
                st = st+filterStr;
                system.debug('#st1'+st);
                List<sobject> accSObjRecords = Database.query(st);  
                system.debug('accSObjRecords'+accSObjRecords);
                Integer recCount=accSObjRecords.size();
                system.debug(tableHeaders);
                Map<string,FieldDefinition> fdMap = new Map<string,FieldDefinition>();
                for(FieldDefinition  fdl : [SELECT QualifiedApiName,DataType FROM FieldDefinition WHERE EntityDefinitionId=:sobjectName AND QualifiedApiName IN :tableColumns]){
                    fdMap.put(fdl.QualifiedApiName,fdl);
                }
                for(string  tb: tableMetadata.keyset() ){
                    if(!fdMap.containsKey(tb))
                        continue;
                    FieldDefinition fd =fdMap.get(tb);
                    DataTableColumns dc= new DataTableColumns();
                    dc.label= tableMetadata.get(fd.QualifiedApiName);
                    dc.fieldName=fd.QualifiedApiName;
                    dc.sortable = true;
                    dc.wrapText = true;
                    
                    if(fd.DataType=='Name' || fd.QualifiedApiName=='Name'){
                        localData.put('Id',fd.QualifiedApiName+'rid');
                        dc.fieldName=fd.QualifiedApiName+'rid';
                        dc.type='url';                    
                        dc.typeAttributes=new  DataTableTypeAttributes(new DataTableTypeAttributesfield('Name'),'_blank');
                    }else if(fd.DataType.contains('Lookup') && fd.QualifiedApiName!='Id'){
                        localData.put(fd.QualifiedApiName,fd.QualifiedApiName+'rid');
                        dc.fieldName=fd.QualifiedApiName+'rid';
                        dc.type='url'; 
                        Map<string,string> localProp = new map<string,string>(tableMetaDataCrossObjInfo.get(fd.QualifiedApiName));
                        dc.typeAttributes=dc.typeAttributes=new DataTableTypeAttributes(new DataTableTypeAttributesfield(localProp.get('label')),'_blank');
                    }else if(fd.DataType=='Date/Time' && fd.DataType=='Date'){
                        dc.type='date';
                        dc.typeAttributes=null;
                    }else if(fd.DataType.contains('Currency')){
                        dc.type='currency';
                        dc.cellAttributes = new cellAttributescls('left');
                        dc.typeAttributes=null;
                    }else if(fd.DataType.contains('Email')){
                        dc.type='email';
                        dc.typeAttributes=null;
                    }else if(fd.DataType.contains('Phone')){
                        dc.type='phone';
                        dc.typeAttributes=null;
                    }else if(fd.DataType.contains('Number')){
                        dc.type='number';
                        dc.cellAttributes = new cellAttributescls('left');
                        dc.typeAttributes=null;
                        dc.typeAttributes=null;
                    }else if(fd.DataType.contains('Picklist')){
                        dc.type='text';
                        dc.typeAttributes=null;}                
                    else{
                        dc.type='text';
                        dc.typeAttributes=null;
                    }
                    system.debug(tch);
                    tch.add(dc);
                    
                }                
                system.debug(tch);
                dtr.lstDataTableColumns= tch;
                dtr.lstDataTableData=accSObjRecords;
                dtr.modifiedHeaders = localData;
                dtr.tableMetaDataCrossObjInfo = tableMetaDataCrossObjInfo;
                dtr.recCount = recCount;
                dtr.recordsPerPage = Integer.valueof(configData.Limit_Records__c);
    
                        
                }
           system.debug(dtr);
            return dtr;
            }Catch(Exception e){
                System.debug('@'+e.getStackTraceString()+e.getMessage()); 
                throw new AuraHandledException(e.getMessage()+e.getStackTraceString());
            }
    }   
    
 }