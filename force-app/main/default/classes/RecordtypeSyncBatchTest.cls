@isTest(SeeAllData=false)
public class RecordtypeSyncBatchTest {
    
     static testmethod void test() {
         
         string objectName = [select SObjectType from recordtype ORDER BY SObjectType ASC LIMIT 1].SObjectType;
         Integer rType = [SELECT Count() FROM recordType WHERE SObjectType = :objectName];
         test.starttest();
               RecordtypeSyncBatch u = new RecordtypeSyncBatch(); 
      			database.executebatch(u, 1);
         test.stoptest();
                 
        integer picks = [select count() from nd_picklist__c where field_api_name__c='RecordTypeId' ];
         /*
        system.debug('message_id__c: ' + intsUpdatedist[0].message_id__c);
        system.debug('constituent ID: ' + intsUpdatedist[0].constituent_id__c);
        system.debug('status : ' + intsUpdatedist[0].status__c);*/
        system.assertEquals(rtype, picks);         
     }
    

}