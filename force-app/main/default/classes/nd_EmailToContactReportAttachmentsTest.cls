@isTest
public class nd_EmailToContactReportAttachmentsTest {

    @testSetup
    public static void createData(){
       TracHier.HierarchyAPI.setTriggerDisabled();
        //Create Contacts
        Contact cList = new contact(lastname='test',firstname='test',Constituent_Status__c='A');
        
        insert cList;
        //Create Task
        Task t = new Task();
        t.WhoId = cList.Id;
        insert t;
        //Create Attachment
        Attachment a = new Attachment();
        a.Name = 'Test attachment';
        a.ParentId = t.Id;
        a.Body = Blob.valueOf('Hello world!');
        insert a;
        //Create ContactReport
        ucinn_ascendv2__Contact_Report__c cr = new ucinn_ascendv2__Contact_Report__c();
        cr.Author__c = UserInfo.getUserId();
        cr.Significant_Visit_Details__c = 'Test Contact Report';
        cr.ucinn_ascendv2__Contact__c= cList.Id;
        cr.Purpose__c = 'C'; 
        cr.RecordTypeId = Schema.SObjectType.ucinn_ascendv2__Contact_Report__c.getRecordTypeInfosByName().get('Contact Report').getRecordTypeId();
        insert cr;
    }
    
    @isTest
    public static void attachmentsGetReparented(){
        TracHier.HierarchyAPI.setTriggerDisabled();
        List<Task> tList = [Select id from Task];
        List<ucinn_ascendv2__Contact_Report__c> crList = [Select id from ucinn_ascendv2__Contact_Report__c];                
        List<String> idList = new List<String>{tList[0].Id, crList[0].Id};
        List<List<String>> idListList = new List<List<String>>();
        idListList.add(idList);
        test.startTest();
        nd_EmailToContactReportAttachments.migrateAttachments(idListList);        
        List<Attachment> aList = [Select id, parentid from attachment];        
        tList = [Select id from Task];
        test.stopTest();
    }
}