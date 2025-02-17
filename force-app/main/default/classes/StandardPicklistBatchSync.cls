global class StandardPicklistBatchSync implements Database.Batchable<string>, Database.AllowsCallouts, Database.Stateful{
    global List<string> objNames {
        get {
            if(objNames == null) {
                objNames = new list<string>();

                Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
                for(string objN : gd.keyset() ){
					Schema.DescribeSObjectResult dsr = gd.get(objN).getDescribe();
					string objName = dsr.getName();
                    if ( !objName.containsignorecase('__c')){
                        //!sobjName.contains('__c') 
                            objNames.add(objName);
                            system.debug('objName: '+objName);

                    }
                }
            }
            return objNames;
        } 
        set;
    }

    global List<String> start(Database.BatchableContext bc) {
        system.debug('objNames: '+objNames);
        return (Test.isRunningTest() ? new list<string>{new list<string>(objNames)[0]} : new list<string>(objNames));
    }

    global void execute(Database.BatchableContext bc, List<string> scope){ 
        //global describe, object by object or field by field
        
        String objectName = scope[0];
        String objectNameForQuery = objectName.toLowerCase();
    
       //create a map with keys values
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Map<String, map<string, nd_picklist__c>> existing_pick_map = new Map<String,map<string, nd_picklist__c>>();
        
        list<nd_picklist__c> nd_picklist = new list<nd_picklist__c>();
        list<nd_picklist__c> delete_nd_picklist = new list<nd_picklist__c>();
        
        for ( nd_picklist__c ndp : [select id, name, object_api_name__c, field_api_name__c, code__c, description__c, unique_id__c from nd_picklist__c where object_api_name__c = :objectNameForQuery]){ 

            if ( existing_pick_map.containskey(ndp.unique_id__c)){    
               existing_pick_map.get(ndp.unique_id__c).put(ndp.code__c, ndp);
            } else {
                existing_pick_map.put(ndp.unique_id__c, new map<string, nd_picklist__c>{ndp.code__c => ndp});
            }
            
        }
       List<string> fieldNameList = new List<string>(); 
    
        for (string field : fields.keyset() ){
            Schema.DescribeFieldResult fieldResult = fields.get(field).getDescribe();
            Schema.DisplayType fieldType = fieldResult.gettype();
        
            if (fieldType.name() == 'MultiPicklist' || fieldType.name() == 'Picklist'){
                string fieldName = fieldResult.getName();
                fieldNameList.add(objectName+'.'+fieldName);
                //system.debug(objectName+'.'+fieldName);
            }
        }
    
           //system.debug('field name list: '+fieldNameList);
        for(string fieldNameL : fieldNameList) {
            Map<string, nd_picklist__c> existing_vals = null;
            string objLower = objectName.toLowerCase();
            string fieldlowSub = fieldNameL.toLowerCase().substringAfter('.');

            Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objectName) ;
            Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe() ;
            Map<String,Schema.SObjectField> fields2 = objDescribeSobject.fields.getMap() ;
            Schema.DescribeFieldResult fieldResult = fields2.get(fieldlowSub).getDescribe();            

            //List<PicklistEntry> entries = objDescribeSobject.getPicklistValues();
            List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
           // List<String> values = new List<String>();
            for (Schema.PicklistEntry entry : entries){

                //values.add(entry.getValue());
                existing_vals =  existing_pick_map.get(objLower+fieldlowSub+entry.getValue());
                if( existing_vals == null || !existing_vals.containsKey(entry.getValue()) ){
                    nd_picklist__c newAdds = new nd_picklist__c();
                    newAdds.object_api_name__c = objLower;
                    newAdds.field_api_name__c = fieldlowSub;
                    newAdds.code__c = entry.getValue(); //getLabel()
                    newAdds.unique_id__c = newAdds.object_api_name__c+newAdds.field_api_name__c+newAdds.code__c;
                    newAdds.description__c = entry.getLabel();
                    //system.debug('picklistVal.isActive ='+picklistVal.isActive);
                    newAdds.active__c = true; //all of these are active or use picklistVal.isActive ==null ? true : picklistVal.isActive;
                    newAdds.default_value__c = entry.IsDefaultValue();

                
                    nd_picklist.add(newAdds);
                } else {
                    //update existing records
                    nd_picklist__c existingval = existing_vals.get(entry.getValue());
                    If( existingval.description__c != entry.getLabel() ){
                        existingval.description__c = entry.getLabel();
                        nd_picklist.add(existingval);
                    }
                    existing_vals.remove(entry.getValue());
                }

                if( existing_vals != null ) {
                    delete_nd_picklist.addall(existing_vals.values());
                }
            }
            	upsert nd_picklist;
                delete delete_nd_picklist; 
                nd_picklist.clear();
        }
    }

    global void finish(Database.BatchableContext bc){
       
    }


}