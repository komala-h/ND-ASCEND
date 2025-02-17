global class PicklistSyncBatch implements Database.Batchable<string>, Database.AllowsCallouts, Database.Stateful{
    global List<string> objNames {
        get {
            if(objNames == null) {
                objNames = new list<string>();//new list<string>('ascend_Note__c'); //new list<string>{'ucinn_ascendv2__Affiliation__c'};//() ;
                //Integer i = 0;   
                Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
                for(string objN : gd.keyset() ){
					Schema.DescribeSObjectResult dsr = gd.get(objN).getDescribe();
					string objName = dsr.getName();
                    if ( objName.containsignorecase('__c') || !objName.containsignorecase('history') ){
                        //if(i < 20){
                            objNames.add(objName);
                         //   i++;
                            system.debug('objName: '+objName);
                    	/*}
                        else {
                            break;
                        }*/
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
        //return new List<String>(objNames); //Database.getQueryLocator('');
    }
public static MetadataService.MetadataPort createService()
	{ 
		MetadataService.MetadataPort service = new MetadataService.MetadataPort();
		service.SessionHeader = new MetadataService.SessionHeader_element();
		service.SessionHeader.sessionId = UserInfo.getSessionId();
		return service;		
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
    
    for ( nd_picklist__c ndp : [select id, name, object_api_name__c, field_api_name__c, code__c, description__c, unique_id__c from nd_picklist__c where object_api_name__c = :objectNameForQuery]){ // :objectName
        //if ( existing_pick_map.containskey(ndp.field_api_name__c)){
        //using obj + field+ code now
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
        }
 }
    
        system.debug('field name list: '+fieldNameList);
  MetadataService.MetadataPort service = createService();
    if ( fieldNameList.size() > 0 ) {
        list<MetadataService.CustomField> customFields = new list<MetadataService.CustomField>();
        if (fieldNameList.size() <= 10){
        // Read Custom Field (dependent picklist)
        customFields = (list<MetadataService.CustomField>) service.readMetadata(
            'CustomField', fieldNameList //new string [] {'Account.Change_Source__c'}
        ).getRecords();
        } else if (fieldNameList.size() <= 100) {
        
            Integer plSize = fieldNameList.size();
            system.debug('large size fieldNameList.size() +'+fieldNameList.size());
            integer divisor = 10;
            //10 per array
            Integer remainder = Math.mod(plSize, divisor);
            Integer totalCustomFieldArrays = remainder == 0 ? (plSize/divisor) : (plSize/divisor + 1);
                for(Integer i = 0; i < totalCustomFieldArrays; i++) {
                    List<string> customFieldsFoundLoop = new List<string>(); 
                    Integer maxRecords = ((i + 1) * divisor) > plSize ? plSize : ((i + 1) * divisor);
                    for(Integer j = (i * divisor); j < maxRecords; j++) {
                        customFieldsFoundLoop.add(fieldNameList[j]);
                    }
                    list<MetadataService.CustomField> CustomFieldSetsLoop = (list<MetadataService.CustomField>) service.readMetadata('CustomField', customFieldsFoundLoop).getRecords();
                    customFields.addAll(CustomFieldSetsLoop);
                }
    
        }
    system.debug('Metadata Api Result - customFields: '+ customFields);
    
    
        // At the end of this example, this list will contain only those picklist values
        // that satisfy the picklist dependency of the controlling field's value.
        // The controlling field is the 'Active__c' picklist field.
        // use customField.valueset.valueSetDefinition.value 
        List<string> globalValueSetsFound = new List<string>();    
        List<MetadataService.CustomValue > ListValues = new List<MetadataService.CustomValue>();
    for(MetadataService.CustomField customField : customFields) {

        system.debug('customField.label = ' + customField.label);
        system.debug('customField.valueset           = ' + customField.valueset);
        if(customField.valueset!=null)
        	system.debug('customField.valueSetDefinition = ' + customField.valueset.valueSetDefinition);
        
        if ( customField.valueset != null &&  customField.valueset.valueSetDefinition == null ) {
            //means its a global val set
            globalValueSetsFound.add(customField.valueset.valueSetName);
        }
    }
          System.debug( 'ListValues = ' + ListValues );

    system.debug('globalValueSetsFound'+globalValueSetsFound);
    system.debug('globalValueSetsFound.size() = '+globalValueSetsFound.size());
        
    list<MetadataService.GlobalValueSet> globalValueSets = new list<MetadataService.GlobalValueSet>();

    if (globalValueSetsFound.size() <= 10){
    globalValueSets = globalValueSetsFound.isEmpty() ? new list<MetadataService.GlobalValueSet>() 
        : (list<MetadataService.GlobalValueSet>) service.readMetadata(
            'GlobalValueSet', globalValueSetsFound //new string [] {'Account.Change_Source__c'}
        ).getRecords();
    } else if (globalValueSetsFound.size() <= 100) {
        
        Integer plSize = globalValueSetsFound.size();
        system.debug('large size globalValueSetsFound.size() +'+globalValueSetsFound.size());
        integer divisor = 10;
        //10 per array
        Integer remainder = Math.mod(plSize, divisor);
        Integer totalGlobalArrays = remainder == 0 ? (plSize/divisor) : (plSize/divisor + 1);
            for(Integer i = 0; i < totalGlobalArrays; i++) {
                List<string> globalValueSetsFoundLoop = new List<string>(); 
                Integer maxRecords = ((i + 1) * divisor) > plSize ? plSize : ((i + 1) * divisor);
                for(Integer j = (i * divisor); j < maxRecords; j++) {
                    globalValueSetsFoundLoop.add(globalValueSetsFound[j]);
                }
                list<MetadataService.GlobalValueSet> globalValueSetsLoop = (list<MetadataService.GlobalValueSet>) service.readMetadata('GlobalValueSet', globalValueSetsFoundLoop).getRecords();
                globalValueSets.addAll(globalValueSetsLoop);
            }

    }
    //system.debug('globalValueSets: '+ globalValueSets);
    
    Map<string, List<MetadataService.CustomValue> > globalListValues = new Map<string, List<MetadataService.CustomValue> >();
    //HERE
   //Map<string, List<MetadataService.GlobalValueSet> > globalAttributes = new Map<string, List<MetadataService.GlobalValueSet> >();
   Map<string, Map<string, string>> globalTopLevel = new  Map<string, Map<string, string>>();

    for(MetadataService.GlobalValueSet globalvalueset : globalValueSets) {
        system.debug('globalvalueset.valueset '+globalvalueset);

        List<MetadataService.CustomValue> global2ndList = new List<MetadataService.CustomValue>();
        /*
        system.debug('globalvalueset.masterlabel '+globalvalueset.masterlabel);
        system.debug('globalvalueset.description '+globalvalueset.description);
        */

        //globalMasterLabelAndDesc.add(globalvalueset.fullName, globalvalueset.masterLabel);
        for ( MetadataService.CustomValue  globalPicklistValue : globalvalueset.customValue ) {
            global2ndList.add(globalPicklistValue);
        	}
        globalListValues.put(globalvalueset.fullName, global2ndList);
        //AND HERE
        //globalAttributes.put(globalvalueset.fullName, globalvalueset);
        map<string, string> globalLocal = new map<string, string>();
        globalLocal.put('masterlabel', globalvalueset.masterlabel);
        globalLocal.put('description', globalvalueset.description);
        //system.debug('globalLocal:'+globalLocal);

        globalTopLevel.put(globalvalueset.fullName, globalLocal);
    }
    //system.debug('globalTopLevel: '+globalTopLevel);

    for(MetadataService.CustomField customField : customFields) {
        //Map<string, nd_picklist__c> existing_vals = existing_pick_map.containsKey(customfield.fullName) ? existing_pick_map.get(customfield.fullName) : null;

        List<MetadataService.CustomValue> globalDisplay = new List<MetadataService.CustomValue>();
        map<string, string> globalTopLevelDisplay = new  map<string, string>();
        if (customField.valueset != null &&  customField.valueset.valueSetDefinition != null){
        	globalDisplay = customField.valueset.valueSetDefinition.value;
        } else if ( customField.valueset != null &&  customField.valueset.valueSetDefinition == null ) {
            //means its a global val set
            globalDisplay = globalListValues.get(customField.valueset.valueSetName);
            globalTopLevelDisplay = globalTopLevel.get(customField.valueset.valueSetName);
            /*
            system.debug('globalDisplay '+globalDisplay);
            system.debug('globalTopLevelDisplay '+globalTopLevelDisplay);
            */
        }
        if(globalDisplay != null){
        Map<string, nd_picklist__c> existing_vals = null;
        for( MetadataService.CustomValue pickListVal : globalDisplay){
            string objLower = objectName.toLowerCase();
            string fieldlowSub = customField.fullName.toLowerCase().substringAfter('.');

            existing_vals =  existing_pick_map.get(objLower+fieldlowSub+pickListVal.fullName);

            //insert new records if record doesnt exist if null or picklist item doesnt exist
            if( existing_vals == null || !existing_vals.containsKey(pickListVal.fullName) ){
                nd_picklist__c newAdds = new nd_picklist__c();
                newAdds.object_api_name__c = objectName.toLowerCase();
                string fullFieldName = customField.fullName.toLowerCase();
                newAdds.field_api_name__c = fullFieldName.substringAfter('.');
                newAdds.code__c = pickListVal.fullName;
                newAdds.unique_id__c = newAdds.object_api_name__c+newAdds.field_api_name__c+newAdds.code__c;
                newAdds.description__c = pickListVal.label;
                if(newAdds.description__c == null){
                    newAdds.description__c = 'description missing here';
                }
                system.debug('picklistVal.isActive ='+picklistVal.isActive);
                newAdds.active__c = picklistVal.isActive ==null ? true : picklistVal.isActive;
                newAdds.default_value__c = picklistVal.default_x;
                //globalTopLevel.contains(customField.fullName) &&
                //system.debug('globalTopLevelDisplay.get(masterlabel)'+globalTopLevelDisplay.get('masterlabel'));

                newAdds.global_master_label__c = globalTopLevelDisplay.get('masterlabel') != null ? globalTopLevelDisplay.get('masterlabel') : null;
                newAdds.global_value_set_description__c = globalTopLevelDisplay.get('description') != null ? globalTopLevelDisplay.get('description') : null;
                
                nd_picklist.add(newAdds);
            } 
            else {
                //update existing records
                nd_picklist__c existingval = existing_vals.get(pickListVal.fullName);
                If( existingval.description__c != pickListVal.label && existingval.description__c != null){
                    existingval.description__c = pickListVal.label;
                    nd_picklist.add(existingval);
                }
                existing_vals.remove(pickListVal.fullName);
            }
        }
        if( existing_vals != null ) {
            delete_nd_picklist.addall(existing_vals.values());
        }
        }
        if(nd_picklist.size() <= 10000) {
            system.debug('nd_picklist.size() +'+nd_picklist.size());
    		upsert nd_picklist;        
        }
        else {
            Integer plSize = nd_picklist.size();
            system.debug('large size nd_picklist.size() +'+nd_picklist.size());
            Integer remainder = Math.mod(plSize, 10000);
            Integer totalUpserts = remainder == 0 ? (plSize/10000) : (plSize/10000 + 1);
            for(Integer i = 0; i < totalUpserts; i++) {
            	list<nd_picklist__c> upsertList = new list<nd_picklist__c>();
                Integer maxRecords = ((i + 1) * 10000) > plSize ? plSize : ((i + 1) * 10000);
                for(Integer j = (i * 10000); j < maxRecords; j++) {
                    upsertList.add(nd_picklist[j]);
                }
                database.upsert(upsertList, false);
            }
            //database.upsert(nd_picklist, false);
        }
    
    	delete delete_nd_picklist; 
        
        nd_picklist.clear();
    }
  }
}
    
    global void finish(Database.BatchableContext bc){
       
    }       
}