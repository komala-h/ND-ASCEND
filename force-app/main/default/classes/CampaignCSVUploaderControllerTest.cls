@isTest
public class CampaignCSVUploaderControllerTest {

    
    @isTest
    public static void method1(){
        String str = 'nd_Job_Number__c,ND_Channel__c,Name,Type,ParentId,nd_Default_Designation__c,StartDate,EndDate,Status,Id\n1,E,Test1,Acknowledgement,,,2023-10-01,2023-10-10,In Progress,';
        Test.startTest();       
        Blob csvFileBody = Blob.valueOf(str);
        String s = EncodingUtil.base64Encode(csvFileBody);
        CampaignCSVUploaderController.saveFile(JSON.serialize(str) );
        Test.stopTest();
    }
        @isTest
    public static void method2(){
        campaign cm = new campaign(name='test');
        insert cm;
        
        String str = 'nd_Job_Number__c,ND_Channel__c,Name,Type,ParentId,nd_Default_Designation__c,StartDate,EndDate,Status,Id\n1,E,Test1,Acknowledgement,,,2023-10-01,2023-10-10,In Progress,'+string.valueof(cm.id);
        Test.startTest();       
        Blob csvFileBody = Blob.valueOf(str);
        String s = EncodingUtil.base64Encode(csvFileBody);
        CampaignCSVUploaderController.saveFile(JSON.serialize(str) );
        Test.stopTest();
    }
}