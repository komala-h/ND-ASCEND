@isTest
public class nd_EmailMessageContactReportTest {
 @testSetup
    public static void createData(){
       TracHier.HierarchyAPI.setTriggerDisabled();
        //Create Contacts
        Contact cList = new contact(lastname='test',firstname='test',Constituent_Status__c='A');        
        insert cList;
        
        // Create EmailMessage
        EmailMessage e = new EmailMessage(
            Subject = 'Test Email',
            ToAddress = 'test123@example.com',
            FromAddress = 'sender@example.com',
            TextBody = 'This is a test email.',
            Status = '3' //The status of the email '3' sent
        );
        insert e;

        // Create Attachment
        ContentVersion cv = new ContentVersion(
            Title = 'Test Attachment',
            PathOnClient = 'TestAttachment.txt',
            VersionData = Blob.valueOf('Hello world!')
        );
        insert cv;
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = e.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        insert cdl;
        
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
    public static void testMigrateAttachments() {
         TracHier.HierarchyAPI.setTriggerDisabled();
        // Retrieve setup data
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        EmailMessage e = [SELECT Id FROM EmailMessage LIMIT 1];
        ucinn_ascendv2__Contact_Report__c cr = [SELECT Id FROM ucinn_ascendv2__Contact_Report__c LIMIT 1];
        List<String> idList = new List<String>{e.Id, cr.Id};
        List<List<String>> idListList = new List<List<String>>();
        idListList.add(idList);
        Test.startTest();
        nd_EmailMessageContactReportAttachment.migrateAttachments(idListList);
        Test.stopTest();

        // Verify that the ContentDocumentLink was created for the ContactReport
        List<ContentDocumentLink> newLinks = [SELECT Id, ContentDocumentId, LinkedEntityId, ShareType, Visibility FROM ContentDocumentLink WHERE LinkedEntityId = :cr.Id];
        System.assertEquals(1, newLinks.size(), 'There should be one ContentDocumentLink for the ContactReport.');
        ContentDocumentLink newLink = newLinks[0];
        System.assertEquals(cr.Id, newLink.LinkedEntityId, 'The LinkedEntityId should match the ContactReport Id.');
    }

}