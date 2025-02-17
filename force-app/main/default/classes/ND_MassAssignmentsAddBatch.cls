public class ND_MassAssignmentsAddBatch implements Database.Batchable<String>,Database.Stateful{

    public List<string> requestIdList;
    public string newFundraiserId, NewAssgComments, msg;
    public String errorMsg;
    
    public String cmdt,userId,asType;
    
    public ND_MassAssignmentsAddBatch(List<String> ids, String newFundraiserId,String NewAssgComments,String msg){
        this.requestIdList = ids;
        this.newFundraiserId = newFundraiserId;
        this.NewAssgComments = NewAssgComments;
        this.msg = msg;
            
    }
    
    public ND_MassAssignmentsAddBatch(String cmdt,List<string> ids,string userId,string newFundraiserId,String asType,String comments,string msg){
        this.requestIdList = ids;
        this.newFundraiserId = newFundraiserId;
        this.NewAssgComments = comments;
        this.msg = msg;
        this.cmdt = cmdt;
        this.userId = userId;
        this.asType = asType;
            
    }    
    public Iterable<String> start(Database.BatchableContext BC){
        
        return this.requestIdList ;
    }
    public void execute(Database.BatchableContext BC, List<string> scope){
        System.debug(newFundraiserId);
        System.debug(NewAssgComments);
        System.debug(msg);
        System.debug(requestIdList.size());
        System.debug(scope.size());
        if(String.isBlank(cmdt))
            errorMsg = errorMsg+ ND_CustomLookupLwcController.addNewSupervisor(scope,newFundraiserId,NewAssgComments,msg);
        else 
           errorMsg = errorMsg+ ND_CustomLookupLwcController.getSelectedAccRecords(cmdt,scope,userId,newFundraiserId,asType,NewAssgComments,msg); 
        
        
    }
    public void finish(Database.BatchableContext BC){
        AsyncApexJob a = [SELECT Id,CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId() limit 1];
        
         
            
            sendEmail(errorMsg,a.CreatedBy.Email);
        
    }
    
    public void sendEmail(String msg,String toEmail){
        // Step 1: Create a new Email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String csvColumnHeader = 'Household Id,Error Message\n';
        
        // Step 2: Set list of people who should get the email
        List<String> sendTo = new List<String>();
        sendTo.add(toEmail);  
        mail.setToAddresses(sendTo);
        
        mail.setSenderDisplayName('MassAddJob Results');
        mail.setSubject('MassAddJob Results');
        String htmlbody = 'Request has been processed sucessfully';
        
        if(string.isnotBlank(msg)){
        String body = csvColumnHeader+errorMsg;
        Messaging.EmailFileAttachment attach1 = new Messaging.EmailFileAttachment();
        blob b;
        if(Test.isRunningTest()) { 
            b = blob.valueOf('Unit.Test');
        } else {
            b = Blob.valueOf(body);
        } 
        attach1.setFileName('MassAdd.csv');
        attach1.setBody(b);
        mail.setFileAttachments(new Messaging.EmailFileAttachment[]{attach1});   
        htmlbody = 'Please find the attachment for more details';    
        }

        mail.setHtmlBody(htmlbody);
                
        
        
        
        // Step 5. Send mail
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
  }   
}