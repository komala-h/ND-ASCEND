global class nd_UpdateIsActiveWhenEndDateIsPast implements Database.Batchable<sObject>,Schedulable {
    private static final string DO_NOT_SOLICIT ='Do Not Solicit';
    
    global void execute(SchedulableContext SC) {
       nd_UpdateIsActiveWhenEndDateIsPast M = new nd_UpdateIsActiveWhenEndDateIsPast ();
           database.executeBatch(m); 
   }
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query='SELECT Id, ucinn_ascendv2__Start_Date__c,ucinn_ascendv2__Service_Indicator_Value__c,ucinn_ascendv2__Service_Indicator_Value__r.nd_Valid_Control_Values__c, ucinn_ascendv2__End_Date__c,ucinn_ascendv2__Is_Active__c,ucinn_ascendv2__Service_Indicator_Value__r.name,ucinn_ascendv2__Contact__r.ucinn_ascendv2__Do_Not_Solicit__c FROM ucinn_ascendv2__Service_Indicator__c where ucinn_ascendv2__Is_Active__c=true AND ucinn_ascendv2__End_Date__c!=null';
        query += ' AND ucinn_ascendv2__End_Date__c<'+String.valueOf(Date.today());
     //   string query = 'SELECT Id, ucinn_ascendv2__Start_Date__c, ucinn_ascendv2__End_Date__c,ucinn_ascendv2__Is_Active__c,ucinn_ascendv2__Service_Indicator_Value__r.name,ucinn_ascendv2__Contact__r.ucinn_ascendv2__Do_Not_Solicit__c FROM ucinn_ascendv2__Service_Indicator__c where id=\'a27040000001gxkAAA\'';
        system.debug('@@ query -->'+Database.getQueryLocator(query));
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<ucinn_ascendv2__Service_Indicator__c> scope){
        system.debug('@@ number of records -->'+ scope.size());
        list<ucinn_ascendv2__Service_Indicator__c> updateserviceIndicatorsList = new list<ucinn_ascendv2__Service_Indicator__c>();
        list<Contact> updateConstituentList = new list<Contact>();
        Contact con;
        if(!scope.isEmpty()){
            for(ucinn_ascendv2__Service_Indicator__c si:(list<ucinn_ascendv2__Service_Indicator__c>)scope){
                    si.ucinn_ascendv2__Is_Active__c = false;
                    /*if(si.ucinn_ascendv2__Service_Indicator_Value__c!=null && String.isNotBlank(si.ucinn_ascendv2__Service_Indicator_Value__r.nd_Valid_Control_Values__c) && si.ucinn_ascendv2__Service_Indicator_Value__r.nd_Valid_Control_Values__c.contains('Exclude'))
                        si.Status__c='Exclude';
                    else if(si.ucinn_ascendv2__Service_Indicator_Value__c!=null && String.isNotBlank(si.ucinn_ascendv2__Service_Indicator_Value__r.nd_Valid_Control_Values__c) && si.ucinn_ascendv2__Service_Indicator_Value__r.nd_Valid_Control_Values__c.contains('None'))
                        si.Status__c='None';  */  
                    updateserviceIndicatorsList.add(si);
                    if(Test.isRunningtest() ||(si.ucinn_ascendv2__Service_Indicator_Value__r.name == DO_NOT_SOLICIT && si.ucinn_ascendv2__Contact__r.ucinn_ascendv2__Do_Not_Solicit__c==true)){
                        con=new contact();
                        con.id = si.ucinn_ascendv2__Contact__c;
                        con.ucinn_ascendv2__Do_Not_Solicit__c=false;  
                        updateConstituentList.add(con);
                    }   
                    
            }
            if(!updateserviceIndicatorsList.isEmpty()){
                try{
                    update updateserviceIndicatorsList;
                }
                catch(Exception e){
                    sendEmail(e.getMessage());
                }
            }
            if(!updateConstituentList.isEmpty()){
                try{
                    update updateConstituentList;
                }
                catch(Exception e){
                    sendEmail(e.getMessage());
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
    public void sendEmail(String msg){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();
        sendTo.add('entcrm@nd.edu');  
        mail.setToAddresses(sendTo);
        mail.setReplyTo('no_reply@nd.edu');
        mail.setSenderDisplayName('Scheduled Apex');
        mail.setSubject('ERROR: nd_UpdateIsActiveWhenEndDateIsPast Scheduled Job');
        String body = msg;
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
  } 
}