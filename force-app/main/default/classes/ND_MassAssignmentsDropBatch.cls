global class ND_MassAssignmentsDropBatch implements Database.Batchable<String>,Database.Stateful{

    public List<string> requestIdList;
    public List<string> accIdsList = new List<string>();
    public string newFundraiserId, NewAssgComments, msg;
    public string cmdt, comments, msg2,userId,hc,ht;
    Public Date reEvalDate;
    public String errorMsg;
    public Boolean enableFundraiser;

    public ND_MassAssignmentsDropBatch(String cmdt,List<string> ids,String comments,String msg2,String userId,String hc,String ht,Date reEvalDate,String newSupervisior,String NewAssgComments,String msg,Boolean enableFundraiser){
        
        this.newFundraiserId = newSupervisior;
        this.NewAssgComments = NewAssgComments;
        this.msg = msg;
        this.enableFundraiser= enableFundraiser;
        
        this.requestIdList = ids;
        this.cmdt =cmdt;
        this.comments = comments;
        this.msg2 = msg2;
        this.userId = userId;
        this.hc = hc;
        this.ht = ht;
        this.reEvalDate = reEvalDate;
            
    }
    public Iterable<String> start(Database.BatchableContext BC){
        
        return this.requestIdList ;
    }
    public void execute(Database.BatchableContext BC, List<string> scope){
        System.debug(newFundraiserId);
        System.debug(NewAssgComments);
        System.debug(msg);
        System.debug(requestIdList.size());
        List<String> stList = new List<String>();
        Map<String,Object> res = new Map<String,Object>();
        res= ND_CustomLookupLwcController.dropRecords(cmdt,scope,comments, msg2,userId,hc,ht,reEvalDate);
        if(res!=null && res.size()>0){
            if(res.get('accIds')!=null)
            accIdsList.addAll((List<String>)res.get('accIds'));
            if(res.get('msg')!=null && String.isNotBlank((String)res.get('msg')))
            errorMsg = errorMsg+(String)res.get('msg');
        }
        

    }
    public void finish(Database.BatchableContext BC){
         Mass_Assignment_Table_Config__mdt configData= [Select Id,Batch_Size__c from Mass_Assignment_Table_Config__mdt where Label='Unassigned Households']; 

        if(accIdsList.size()>0 && enableFundraiser)
            Database.executeBatch(new ND_MassAssignmentsAddBatch(accIdsList,newFundraiserId,NewAssgComments, msg),integer.valueof(configData.Batch_Size__c));
        
        AsyncApexJob a = [SELECT Id,CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId() limit 1];
      
              
            errorMsg = errorMsg;
            sendEmail(errorMsg,a.CreatedBy.Email);  
            
        
    }
    
    public void sendEmail(String msg,String toEmail){
        String csvColumnHeader = 'ObjectName, RecordId,Error Message\n'; 
       
        // Step 1: Create a new Email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        // Step 2: Set list of people who should get the email
        List<String> sendTo = new List<String>();
        sendTo.add(toEmail);  
        mail.setToAddresses(sendTo);
        
        mail.setSenderDisplayName('MassDropJob Results');
        mail.setSubject('MassDropJob Results');
        String body = csvColumnHeader+msg;
        String htmlbody = 'Request has been processed sucessfully';
        if(String.isNotBlank(msg)){
        Messaging.EmailFileAttachment attach1 = new Messaging.EmailFileAttachment();
        blob b;
        if(Test.isRunningTest()) { 
            b = blob.valueOf('Unit.Test');
        } else {
            b = Blob.valueOf(body);
        }                        
        
        attach1.setFileName('MassDrop.csv');
        attach1.setBody(b);
        mail.setFileAttachments(new Messaging.EmailFileAttachment[]{attach1}); 
        htmlbody = 'Please find the attachment for more details';
        }
        
        mail.setHtmlBody(htmlbody);
        
        // Step 5. Send mail
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});

   }   
}