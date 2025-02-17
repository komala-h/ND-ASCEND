global class EndowmentCasesReport implements Database.Batchable<SObject>, Database.Stateful,Schedulable { 
    
   /* It has been scheduled to run once in a year during May 1st week*/
    global void execute(SchedulableContext SC){
        Integer noOfRecords = (Integer)ManageBatchJobSize__mdt.getInstance('AutoCreateEndowmentCases').ChunkSize__c;           
	    EndowmentCasesReport caseBatch = new EndowmentCasesReport();
        DataBase.executeBatch(caseBatch,noOfRecords);         
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        List<String> reportingcodes = new List<string>{'CE','CR','EC','EE','EH','EP','ER','FB','FE','FL','GA','LL','MS','PB','PF','PG','PL','PR','PS','PU','RO','SC','ST','SU','UL'};
        
        String query='Select id,nd_Cumulative_Impact_Historical_Number__c,nd_Cumulative_Impact_Statement__c,ND_Designation_Department__c,ND_Designation_Division__c from ucinn_ascendv2__Designation__c where ND_Omit_Steward_Reporting_Code__c=null AND Steward_Reporting_Code__c IN :reportingcodes';
        return Database.getQueryLocator(query);
    }
    /* Autocreates a endowment case reports */
     
    global void execute(Database.BatchableContext BC, list<ucinn_ascendv2__Designation__c> designations){
        try{ 
            system.debug('designations'+designations);
            List<Case> caseList = new List<Case>();
            String recordTypeId =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Endowment_Report').getRecordTypeId();
            group stewardshipRecord = [Select id from group where type='Queue' and Developername='Stewardship'];
            for(ucinn_ascendv2__Designation__c des: designations){
                case c= new case(recordTypeId=recordTypeId,ownerId=stewardshipRecord.Id);
                c.nd_Designation__c= des.Id;
                c.Requested_Completion_Date__c= date.newInstance(date.today().Year(), 10, 31);
              //  c.nd_Cumulative_Impact__c=String.valueOf(des.nd_Cumulative_Impact_Historical_Number__c);
                c.nd_Cumulative_Impact__c=des.nd_Cumulative_Impact_Statement__c;
                caseList.add(c);
            }  
            system.debug('caseList'+caseList);
            system.debug('caseList'+caseList.size());
            if(!caseList.isempty())
                Insert caseList;
        }Catch(Exception ex){
            System.debug('Following exception has occurred:'+ ex.getMessage()+ex.getStackTraceString());
        }
    }    
    global void finish(Database.BatchableContext BC) {
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] {job.CreatedBy.Email};
        message.subject = 'Auto Create Endowment Case Report';
        message.plainTextBody = 'Your batch job to Create Endowment Case Report records has been processed successfully.';
        
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
    }
}