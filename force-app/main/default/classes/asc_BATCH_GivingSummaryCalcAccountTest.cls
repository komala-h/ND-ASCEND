@isTest
public class asc_BATCH_GivingSummaryCalcAccountTest {

    static testmethod void ReviewTransaction() {
        string json_message='{"object": {"event": {"event_id": 14,"event_modified_by": "9999999999","event_sequence_number": "14","event_time": "01122024","event_type": "I","source_database": "lockbox gift","source_schema": "none","source_table": "gift"},"target": {"APPEAL_CODE": "00000","BATCH_ID": "676","CHECK_NUM": "00000000000001253","FILE_DATE": "01122024","GROUP_NUM": "05                      ","ID_NUM": "9999999999","ITEM_AMT": "0000005000","MESSAGE_STATUS": "in process","ND_UNIQUID": 14,"PROGRAM_CODE": "0802275","TRANS_ID": "005"}}}';
        Map<String, Object> m =(Map<String, Object>) JSON.deserializeUntyped(json_message);
        Map<String, Object> newmap = (Map<String, Object>) m.get('object');
        Map<String, Object> target = (Map<String, Object>) newmap.get('target');
        map<string, ucinn_ascendv2__Review_Transaction_v2__c> newJustRTV2 = new map<string, ucinn_ascendv2__Review_Transaction_v2__c>();
        
        ucinn_ascendv2__Review_Transaction_v2__c rt2 = lockboxGiftProcessing.processGift(target);
        newJustRTV2.put('rtv2 test', rt2);
        Database.insert(newJustRTV2.values(), false);
        
        Test.startTest();
        asc_BATCH_GivingSummaryCalcAccount batchInstance = new asc_BATCH_GivingSummaryCalcAccount();
        Database.executeBatch(batchInstance);
   
        //String chron = '0 0 23 * * ?';        
        //system.schedule('Test Sched', chron, batchInstance);        
        //Database.executeBatch(batchInstance);
        //Database.QueryLocator ql = batchInstance.start(null);
        //batchInstance.execute(null,newJustRTV2.values());
        Test.stopTest();
        
    }
}