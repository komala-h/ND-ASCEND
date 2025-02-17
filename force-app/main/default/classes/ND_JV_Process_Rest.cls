@RestResource(urlMapping='/nd_jv_entry/*')
global with sharing class  ND_JV_Process_Rest {
    @HttpPost
    global static id execute() {
       
        id batchID = Database.executeBatch(new ND_JV_Process(), 25);
        return batchID;
        
    }
   
}