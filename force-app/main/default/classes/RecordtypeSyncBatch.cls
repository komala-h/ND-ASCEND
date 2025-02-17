global  class RecordtypeSyncBatch  implements Database.Batchable<string>, Database.Stateful{
	global list<string> start(Database.BatchableContext bc) {
        set<string> objectList = new set<string>();
        for(RecordType rt : [SELECT ID, name, developername, sObjecttype, isActive, NamespacePrefix from recordtype ORDER BY SObjectType ASC]) {
            objectList.add(rt.sObjectType);
        }
        //system.debug('objectList '+objectList);
        return (Test.isRunningTest() ? new list<string>{new list<string>(objectList)[0]} : new list<string>(objectList));
    }
	global void execute(Database.BatchableContext bc, List<string> scope){ 
        list<nd_picklist__c> nd_picklist = new list<nd_picklist__c>();
        list<nd_picklist__c> nd_picklistDelete = new list<nd_picklist__c>();

		string objectName = scope[0];
        map<Id, recordType> rtMap = new map<Id, recordType>([SELECT ID, name, developername, sObjecttype, isActive, NamespacePrefix from recordtype where sObjecttype = :objectName]);
        
        //system.debug('rtMap '+rtMap);
        list<nd_picklist__c> exsitingRTs = [SELECt Id, code__c, description__c, code_record_id__c, active__c, field_api_name__c FROM  nd_picklist__c WHERE field_api_name__c = 'RecordTypeId' AND object_api_name__c = :objectName];
        map<Id, nd_picklist__c> existingRTMap = new map<Id, nd_picklist__c>();
        for(nd_picklist__c pl : exsitingRTs) {
            existingRTMap.put(pl.code_record_id__c, pl);
        }
        for(recordtype recs : rtMap.values()){
          nd_picklist__c ps = existingRTMap.containsKey(recs.Id) ? existingRTMap.get(recs.Id) : new nd_picklist__c();
            if(ps.code_record_id__c != null) {
                if(ps.code__c  != recs.developername || ps.description__c != recs.name || ps.active__c != recs.isActive) {
                	ps.code__c  = recs.developername;
                    ps.description__c = recs.name;
                    ps.active__c = recs.isActive;
                    nd_picklist.add(ps);
                }
            }
            else {
          ps.code_record_id__c =  recs.id;
          ps.namespace_prefix__c = recs.NamespacePrefix;
          ps.object_api_name__c = recs.sObjectType.toLowerCase();
          ps.field_api_name__c = 'RecordTypeId'.toLowerCase();
          ps.code__c  = recs.developername;
          ps.description__c = recs.name;
          ps.active__c = recs.isActive;
          ps.unique_id__c = recs.id;
          nd_picklist.add(ps);
            }
          /*  
          nd_recordtype_sync__c irs = new  nd_recordtype_sync__c();
          irs.recordtype_developer_name__c = recs.developername;
          irs.recordtype_id__c = recs.id;
          irs.recordtype_name__c = recs.name;
          irs.recordtype_object_api_name__c = recs.sObjectType;
          irs.active__c = recs.isActive;
          irs.namespace_prefix__c = recs.NamespacePrefix;
          rs.add(irs);  
        }
        upsert rs recordtype_id__c;*/
        }
        
        for(nd_picklist__c ndp : exsitingRTs) {
            if(!rtMap.containsKey(ndp.code_record_id__c)) {
                nd_picklistDelete.add(ndp);
            }
        }
        upsert nd_picklist code_record_id__c;
        
        if(nd_picklistDelete.size() > 0) {
            delete nd_picklistDelete;
        }
    }
    global void finish(Database.BatchableContext bc){
       
    }
}