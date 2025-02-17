global class nd_UpdateSFMCSync implements Database.Batchable<sObject> , Schedulable {
       
   global void execute(SchedulableContext SC) {
        Integer noOfRecords = (Integer)ManageBatchJobSize__mdt.getInstance('SFMCSync').ChunkSize__c;           
        nd_UpdateSFMCSync M = new nd_UpdateSFMCSync();
        database.executeBatch(m,noOfRecords);
   }
    
  global Database.querylocator start(Database.BatchableContext BC){
    string query = 'select Id, nd_SFMC_Sync__c,RecordType.DeveloperName,Constituent_Status__c,ucinn_ascendv2__Primary_Contact_Type__c,Email  from Contact where (RecordType.DeveloperName = \'Edit_Contact\' and (Constituent_Status__c = \'A\' or Constituent_Status__c = \'L\')';
    query += ' and (ucinn_ascendv2__Primary_Contact_Type__c = \'Alumni\' or ucinn_ascendv2__Primary_Contact_Type__c = \'Employee\' or ucinn_ascendv2__Primary_Contact_Type__c = \'Friend\' or ucinn_ascendv2__Primary_Contact_Type__c = \'Parent\' or ucinn_ascendv2__Primary_Contact_Type__c = \'Alumni Widow\' ' +
    ' or ucinn_ascendv2__Primary_Contact_Type__c = \'Former Employee\' or ucinn_ascendv2__Primary_Contact_Type__c = \'Retired Employee\' )';
    query += ' and Email != null )';
    query += ' or ((RecordType.DeveloperName != \'Edit_Contact\' or (Constituent_Status__c != \'A\' and Constituent_Status__c != \'L\')';
    query += ' or (ucinn_ascendv2__Primary_Contact_Type__c != \'Alumni\' and ucinn_ascendv2__Primary_Contact_Type__c != \'Employee\' and ucinn_ascendv2__Primary_Contact_Type__c != \'Friend\' and ucinn_ascendv2__Primary_Contact_Type__c != \'Parent\' and ucinn_ascendv2__Primary_Contact_Type__c != \'Alumni Widow\' '
    +' and ucinn_ascendv2__Primary_Contact_Type__c = \'Former Employee\' and ucinn_ascendv2__Primary_Contact_Type__c = \'Retired Employee\')';
    query += ' or Email = null) and nd_SFMC_Sync__c = true) ';
    
    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext BC, List<sObject> scope){
  List<contact> conList= ((list<contact>)scope);      
  List<contact> conListUpdate= new List<contact>();        
    /* 
     * Not using the service indicators 
    set<id> CriteriaNotMatchingConstituents = new set<id>();
    list<String> SFMCCustomMetadataValues = new list<String>();
    
    //get the list of service Indicator records that are related to the constituents
    list<ucinn_ascendv2__Service_Indicator__c> serviceIndicatorList = [SELECT id,ucinn_ascendv2__Service_Indicator_Value__r.name,ucinn_ascendv2__Contact__r.id 
                                                                       FROM ucinn_ascendv2__Service_Indicator__c 
                                                                       WHERE ucinn_ascendv2__Contact__c in :contactMap.keySet() and ucinn_ascendv2__Is_Active__c=true];
    
    //loop over the custom metadata and choose only those record for which 'In Use' checkbox is checked. 
    for(Send_To_SFMC_Service_Indicator_Value__mdt s:Send_To_SFMC_Service_Indicator_Value__mdt.getall().values()){
        //if(s.In_Use__c==true)
          SFMCCustomMetadataValues.add(s.label);
    }*/
    Set<String> Subscribers = new Set<String>();
    list<ucinn_ascendv2__Service_Indicator__c> serviceIndicatorList = [SELECT id,ucinn_ascendv2__Is_Active__c,status__c,ucinn_ascendv2__End_Date__c,ucinn_ascendv2__Service_Indicator_Value__r.name,ucinn_ascendv2__Contact__r.id 
                                                                       FROM ucinn_ascendv2__Service_Indicator__c 
                                                                       WHERE ucinn_ascendv2__Contact__c in :conList  
                                                                            AND ucinn_ascendv2__Is_Active__c=true 
                                                                            AND ucinn_ascendv2__Service_Indicator_Value__r.name in ('Held Subscribers','Do Not Contact','Do Not Email','SPAM')];  
                                                                       
    for(ucinn_ascendv2__Service_Indicator__c sil: serviceIndicatorList){
    //    if(sil.ucinn_ascendv2__End_Date__c==null && (sil.ucinn_ascendv2__Is_Active__c || sil.status__c=='Include') )
        if(sil.ucinn_ascendv2__End_Date__c==null && sil.ucinn_ascendv2__Is_Active__c  )
            Subscribers.add(sil.ucinn_ascendv2__Contact__r.Id);
    }  
    
    // loop over service indicator records and check whether value is present in the list of custom metadata values for which 'In use' is used.
    // if any one of the service indicator values of a constituent doesnot match to the values in custom metadata, update 'SFMC Sync' to False
    // Only if all service indicator values of a constituent matches , update 'SFMC Sync' to True
    
    Integer listSize = scope.size();  
    for(Integer i = 0; i < conList.size(); i++) {
        Contact c = (Contact)scope[i] ;
        
        if(c.RecordType.DeveloperName =='Edit_Contact' && (c.Constituent_Status__c=='A'||c.Constituent_Status__c=='L') && 
             (c.ucinn_ascendv2__Primary_Contact_Type__c=='Alumni' || c.ucinn_ascendv2__Primary_Contact_Type__c=='Employee' || c.ucinn_ascendv2__Primary_Contact_Type__c=='Friend' || c.ucinn_ascendv2__Primary_Contact_Type__c=='Parent' || c.ucinn_ascendv2__Primary_Contact_Type__c=='Alumni Widow' || C.ucinn_ascendv2__Primary_Contact_Type__c == 'Former Employee' ||c.ucinn_ascendv2__Primary_Contact_Type__c == 'Retired Employee') &&
             c.Email!=''){
            Boolean SFMCvalue = false;    
            if(Subscribers.contains(c.id))
                SFMCvalue = false;//c.nd_SFMC_Sync__c = false;
            else
                SFMCvalue = true;//c.nd_SFMC_Sync__c = true;
            
            if(c.nd_SFMC_Sync__c!=SFMCvalue){  
                c.nd_SFMC_Sync__c=SFMCvalue;
                conListUpdate.add(c);
            }
        }
        else if((c.RecordType.DeveloperName !='Edit_Contact' || (c.Constituent_Status__c!='A'&& c.Constituent_Status__c!='L') ||
             (c.ucinn_ascendv2__Primary_Contact_Type__c!='Alumni' && c.ucinn_ascendv2__Primary_Contact_Type__c!='Employee' && c.ucinn_ascendv2__Primary_Contact_Type__c!='Friend' && 
              c.ucinn_ascendv2__Primary_Contact_Type__c!='Parent' && c.ucinn_ascendv2__Primary_Contact_Type__c!='Alumni Widow' && c.ucinn_ascendv2__Primary_Contact_Type__c != 'Former Employee' && c.ucinn_ascendv2__Primary_Contact_Type__c != 'Retired Employee') ||
                   c.Email=='') && c.nd_SFMC_Sync__c){
              c.nd_SFMC_Sync__c = !c.nd_SFMC_Sync__c; 
              conListUpdate.add(c);
         }
      }     
    /*for(ucinn_ascendv2__Service_Indicator__c serviceIndicator: serviceIndicatorList )
    {
        String serviceIndicatorValue= serviceIndicator.ucinn_ascendv2__Service_Indicator_Value__r.name;
        contact constituent = contactMap.get(serviceIndicator.ucinn_ascendv2__Contact__r.id);
        

        
        if(!(CriteriaNotMatchingConstituents.contains(constituent.id)))
        {
            if(SFMCCustomMetadataValues.contains(serviceIndicatorValue)){
               CriteriaNotMatchingConstituents.add(constituent.id);
               constituent.nd_SFMC_Sync__c= false;
            }            
        }
    }*/
      String errorMsg='';
      try {  
          //update consts;
          List<Database.SaveResult> updateResults = Database.update(conListUpdate, false);
          for(Integer i=0;i<updateResults.size();i++){
              if (!updateResults.get(i).isSuccess()){
                  Database.Error error = updateResults.get(i).getErrors().get(0);String failedDML = error.getMessage();
                  errorMsg = errorMsg+failedDML+'-'+conListUpdate.get(i).Id+'\n';
              }        
          }  
          if(string.isNotBlank(errorMsg))
              sendEmail(errorMsg); 
          
      }
      catch(Exception e) {
          sendEmail(e.getMessage());  
      }
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
    mail.setSubject('ERROR: SFMCSync Scheduled Job');
    String body = msg;
    mail.setHtmlBody(body);
    
    // Step 5. Send mail
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
  }  
}