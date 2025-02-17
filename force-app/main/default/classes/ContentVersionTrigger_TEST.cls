@IsTest
public class ContentVersionTrigger_TEST {
    /*
    @IsTest
    public static void constituentTest()
    {
        // Constituent Profile Pic Test
        test.startTest();
        //create Constituent(contact) (needed by Content Version Object)
        Contact contact = new Contact();
        contact.LastName = 'LastName';
        contact.FirstName = 'FirstName';
        contact.Constituent_Status__c = 'A';
        insert contact;
        
        //create a Content Version object and insert it
        ContentVersion contVer = new ContentVersion();
        contVer.Constituent__c = contact.Id;
        contVer.isProfilePhoto__c = TRUE;
        contVer.Description = 'Test Profile Picture';
        contVer.Title = 'Test Title';
        Blob blobConverted = Blob.valueOf('Test Version Data');
        contVer.VersionData = blobConverted; //normally file directory
        contVer.PathOnClient = 'Test Path On Client'; ////normally file directory
        insert contVer;
        
        test.stopTest();
    }
    */
    @IsTest
    public static void OrgTest()
    {
        test.startTest();
       //Organization Test Profile Pic Test
        Account account = new Account();
        Account.Name = 'Stark Industries Test 1';
        insert account;
        
        //create a Content Version object and insert it
        ContentVersion contVer2 = new ContentVersion();
        contVer2.Organization__c = account.Id;
        contVer2.isProfilePhoto__c = TRUE;
        contVer2.Description = 'Test Profile Picture Org';
        contVer2.Title = 'Test Title Org';
        Blob blobConverted2 = Blob.valueOf('Test Version Data Org');
        contVer2.VersionData = blobConverted2; //normally file directory
        contVer2.PathOnClient = 'Test Path On Client Org'; ////normally file directory 
        insert contVer2;
        test.stopTest();
    }
    
}