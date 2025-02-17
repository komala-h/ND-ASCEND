/**
* @author UC Innovation
* @date 2/12/2023
* @group LWC Controller
* @description Test Class for CampaignDetailController
*/
@IsTest
public class CampaignDetailControllerTest {
    
    @testSetup
    static void setupTestData() {
        // Create a campaign with both start & end date
        Campaign cmpgn = new Campaign();
        cmpgn.Name = 'Test';
        cmpgn.Status = 'Active';
        cmpgn.StartDate = Date.today().addDays(-30);
        cmpgn.EndDate = Date.today().addDays(30);
        insert cmpgn;
        
         // Create child campaign
        Campaign childCampaign = new Campaign();
        childCampaign.Name = 'Child Campaign';
        childCampaign.Status = 'Active';
        childCampaign.StartDate = Date.today().addDays(-15);
        childCampaign.EndDate = Date.today().addDays(15);
        childCampaign.ParentId = cmpgn.Id; 
        insert childCampaign;
        
        // Create a campaign with no EndDate 
        Campaign cmpgnWithoutEndDate = new Campaign();
        cmpgnWithoutEndDate.Name = 'Test Without End Date';
        cmpgnWithoutEndDate.Status = 'Active';
        cmpgnWithoutEndDate.StartDate = Date.today().addDays(-30);
        cmpgnWithoutEndDate.EndDate = null; 
        insert cmpgnWithoutEndDate;
    }
    
    @isTest(seeAllData=false)
    static void testController() {
       // String query = 'Select Id, Name,  nd_Constituent__c, nd_Constituent__r.Name, nd_Comment__c, nd_Constituent__r.ucinn_ascendv2__Donor_ID__c From ascend_Note__c Where OwnerId <> null And ( OwnerId In (#currentuserid#) )';
        String query='SELECT Id, Name, (SELECT Id, Name FROM ChildCampaigns) FROM Campaign '; //WHERE OwnerId <> null AND ( OwnerId IN (#currentuserid#) )';
        String queryVariables = '[{"Name": "#currentuserid#", "Query": "Select Id From User Where Id =\'#userid#\'", "type": "text", "TargetFieldName": "Id"}]';
        
        // Fetch the test campaign with an EndDate 
        List<Campaign> cmpgnList = [SELECT Id FROM Campaign WHERE Name = 'Test' LIMIT 1];
        
        // Fetch the test campaign without an EndDate 
        List<Campaign> cmpgnWithoutEndDateList = [SELECT Id FROM Campaign WHERE Name = 'Test Without End Date' LIMIT 1];
               
        Campaign_Detail_Setting__mdt mdt = CampaignDetailController.getCampaignDetailSetting('PRM');
        List<SObject> recordswithEndDate = CampaignDetailController.getRecords(UserInfo.getUserId(), cmpgnList[0].Id, query, queryVariables, '');
        List<SObject> recordswithoutEndDate = CampaignDetailController.getRecords(UserInfo.getUserId(), cmpgnWithoutEndDateList[0].Id, query, queryVariables, '');
        List<SObject> recordswithsubquery = CampaignDetailController.getRecords(UserInfo.getUserId(), cmpgnList[0].Id, query, queryVariables, 'ChildCampaigns');
    }
    
    @isTest(seeAllData=false)
	static void testController1() {
        
    String query1 ='SELECT Id, Name, (SELECT Id, Name FROM ChildCampaigns) FROM Campaign ';//WHERE OwnerId <> null AND ( OwnerId IN (#currentuserid#) );
    String queryVariables1 = '[{"Name": "#currentuserid#", "Query": "SELECT Id FROM User WHERE Id = \'nonexistentuser\'", "type": "text", "TargetFieldName": "Id"}]';
    
    // Fetch the test campaign
    List<Campaign> cmpgnList = [SELECT Id FROM Campaign WHERE Name = 'Test' LIMIT 1];
    
    //Make CMT to return NULL
    Campaign_Detail_Setting__mdt mdt = CampaignDetailController.getCampaignDetailSetting('');
    List<SObject> records = CampaignDetailController.getRecords(UserInfo.getUserId(), cmpgnList[0].Id, query1, queryVariables1, '');    
}
}