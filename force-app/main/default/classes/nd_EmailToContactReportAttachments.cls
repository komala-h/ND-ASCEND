public class nd_EmailToContactReportAttachments implements Queueable{
        
    public string taskId;
    public string contactReportId;
    
    public nd_EmailToContactReportAttachments(string taskId1,string contactReportId1){
        taskId =taskId1;
        contactReportId =contactReportId1;
    }
    @InvocableMethod(label='Re-parent attachments')
    
    public static void migrateAttachments(List<List<String>> objectIds){
        String localtaskId = objectIds[0][0];
        system.debug('@@ taskId '+localtaskId);
        String localcontactReportId;
        //Checks if a contactReportId has been passed to the apex invocable method
        if(objectIds[0].size() > 1){            
        	localcontactReportId = objectIds[0][1];
        system.debug('@@ contactReportId '+ objectIds[0][1]); 
            System.enqueueJob(new nd_EmailToContactReportAttachments(localtaskId,localcontactReportId),5);
        }

    }
    public void execute(QueueableContext context) {
 		migrateAttachmentsfuture(taskId,contactReportId);      
    }
    
    public static void migrateAttachmentsfuture(string taskId1,string contactReportId1){
        
 	String taskId = taskId1;
        
        system.debug('@@ taskId '+taskId);
      
            
        //Checks if a contactReportId has been passed to the apex invocable method
        if(string.isNotBlank(contactReportId1)) {
            
        	String contactReportId = contactReportId1;
        
        	String qryString = getQuery('Attachment', 'parentid = :taskId');
            system.debug(qryString);
        	List<Attachment> aList = (List<Attachment>)Database.query(qryString);
        	List<Attachment> toInsert = new List<Attachment>();
            system.debug(aList);
        	Integer aListSize = aList.size();
        	for(Integer i = 0; i < aListSize; i++){
            	Attachment a = aList[i].clone(false, false, false, false);
            	a.ParentId = contactReportId;
            	toInsert.add(a);
        	}
                        
           	if(toInsert.size() > 0){
                insert toInsert;
                System.debug('##'+aList);
            	//delete aList;
        	}
        }
        
        //Checks if the task exists before attempting to delete it
       /* List<Task> tasksToDelete = [SELECT Id FROM Task WHERE Id =:taskId LIMIT 1];
        system.debug('@@ tasksToDelete '+tasksToDelete);
        if(!tasksToDelete.isEmpty()){
            try{
                delete tasksToDelete;
            }
            Catch(Exception e){
                system.debug('@@ exception: '+e);
            }
        } */       
    }
   public static string getQuery(string objectName, string whereClause) {
    	string query = 'SELECT ';
        
    	for(Schema.SObjectField ft : Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap().values()){
      		Schema.DescribeFieldResult fd = ft.getDescribe();
      		query += fd.getName() + ',';  
    	}
                  
        query = query.removeEnd(',') + ' FROM ' + objectName;
        
        if(string.isNotBlank(whereClause)) {
      		query += ' WHERE ' + whereClause; 
    	}
    	return query;
  	}
}