@isTest
private class IER_Deletion_BatchTest {
	@Testsetup
    private static void setup() {
        IER_BatchSetting__c IERrec = new IER_BatchSetting__c(Name='Record Deletion',Months__c=3);
        insert IERrec;
     
        et4ae5__SendDefinition__c sendef = new et4ae5__SendDefinition__c(et4ae5__FromName__c='TestEmail');
        insert sendef;
        
        et4ae5__IndividualEmailResult__c emailres = new et4ae5__IndividualEmailResult__c(Name='testresult',et4ae5__SendDefinition__c=sendef.Id,CreatedDate=Datetime.now().addDays(-300));
        insert emailres;
        
        et4ae5__IndividualLink__c emaillink = new et4ae5__IndividualLink__c(Name='testLink',et4ae5__Individual_Email_Result__c=emailres.Id,et4ae5__Unique_Link_ID__c='test');
        insert emaillink;  
    }
    
    static testMethod void deleteIERrecord() {
        Test.startTest();
        IER_Deletion_Batch deletionBatch = new IER_Deletion_Batch();
        DataBase.executeBatch(deletionBatch); 
        Test.stopTest();
    }
    
    static testMethod void scheduleBatch() {        
        test.starttest();
        IER_Deletion_Batch delBatchSchedule = new IER_Deletion_Batch();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, delBatchSchedule);
        test.stopTest();
    }
}