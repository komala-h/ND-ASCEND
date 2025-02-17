@isTest(SeeAllData=false)
public class TRIG_nd_picklistTest {
    @TestSetup
    public static void testSetup() {
        ucinn_ascendv2__Trigger_Handler__c customHandler1 = new ucinn_ascendv2__Trigger_Handler__c();
            customHandler1.Name = 'nd picklist Int out Handler';
            customHandler1.ucinn_ascendv2__Class__c = 'TRIG_IntegrationOutHandler';
            customHandler1.ucinn_ascendv2__Is_Active__c = true;
            customHandler1.ucinn_ascendv2__Object__c = 'nd_picklist__c';
            customHandler1.ucinn_ascendv2__Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
            customHandler1.ucinn_ascendv2__Load_Order__c = 1;
        insert customHandler1;
        
        nd_picklist__c n = new nd_picklist__c();
        n.code__c='H';
        n.description__c='High';
        n.unique_id__c='1234';
        n.field_api_name__c='Priority';
        n.object_api_name__c='Account';
        insert new List<nd_picklist__c>{n};

	}
     @isTest(SeeAllData=false) 
    static void insertAR() {

        nd_picklist__c n02 = [select id from nd_picklist__c where object_api_name__c='Account'];                                     
        
        Test.startTest();
        nd_picklist__c na = new nd_picklist__c();
        na.code__c='L';
        na.description__c='Low';
        na.unique_id__c='123';
        na.field_api_name__c='Priority';
        na.object_api_name__c='Account';
        
        insert na;
        Test.stopTest();
        
		nd_picklist__c n01 =[select id, code__c from nd_picklist__c where id = :na.id];
        
        System.assertEquals('L', n01.code__c);


    }   
}