global class ND_Constituent_Type_Trigger_Handler extends ucinn_ascendv2.ascend_TDTM_Runnable  {
    
    private ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper = new ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper();
    
    static List<Constituent_Type_Hierarchy__mdt> ConTypeMetaData= [Select id,type_code__c from Constituent_Type_Hierarchy__mdt  order by Institutional_Suffix_Hierarchy_Order__c ASC];
    
     global override ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, ucinn_ascendv2.ascend_TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        List<Contact> triggerNew = (List<Contact>) newList;
        List<Contact> triggerOld = (List<Contact>) oldList;
        
        Map<Id, Contact> triggerOldMap = new Map<Id, Contact>();
        if (triggerOld != null) {
            for (Contact con : triggerOld) {
                triggerOldMap.put(con.Id, con);
            }
        }
         
        Map<Id, Contact> triggerNewMap = new Map<Id, Contact>();
        if (triggerNew != null) {
            for (Contact con : triggerNew) {
                triggerNewMap.put(con.Id, con);
            }
        }
        
        if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.beforeInsert) {
            //dont think this is needed 9it would be before insert anyways
            //reason is because interim wont be inserting more than 1 constituent type
            //handleTypeHierarchySet(newMap, null );
            setSuffixConstituentType(triggerNew,null);
        }
        else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterInsert) {
            
        }
        else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeUpdate) {
            setSuffixConstituentType(triggerNew,triggerOldMap); 
            List<Contact> contactList = triggerNewMap.values();
            
            /* 2/7/2024 qluong no longer need this section of code.  Also not sure if the custom field 
             * ND_created_from_interim__c is needed.  Need to consult with Jay.
               Delete this section if it is no longer needed.
            For(Contact conRecord : contactList)
            
            { system.debug('conRecord.ND_created_from_interim__c: '+conRecord.ND_created_from_interim__c);
                If(conRecord.ND_created_from_interim__c == true )
                { 
                    preHandleTypeHierarchySet(triggerNewMap.values(), triggerOldMap);
                } 
            }
            */
            
            // Clear out the Prospect Category, the Prospect Stage and Re-Evaluation date when the HH constituent is deceased
            //This method causes recursion with the ascend account trigger handler.
            //2/14/2023 qluong - this method is no longer needed. Function moved to the deceasing flow
            //clearProspectCategory(triggerNewMap.values(),triggerOldMap);
        }
        else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterUpdate) {
            
        }
        else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterDelete) {
            
        }
        else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterUnDelete) {
            
        }
        
        return dmlWrapper;
    }
    
    /*
    public static void beforeInsert(map<Id, Contact> newMap) {  
        //dont think this is needed 9it would be before insert anyways
        //reason is because interim wont be inserting more than 1 constituent type
        //handleTypeHierarchySet(newMap, null );
    }
    public static void afterInsert(map<Id, Contact> newMap) {}
    public static void beforeUpdate(map<Id, Contact> newMap, map<Id, Contact> oldMap) { 
        List<Contact> contactList = newMap.values();
       

        For(Contact conRecord : contactList)
        { system.debug('conRecord.ND_created_from_interim__c: '+conRecord.ND_created_from_interim__c);
            If(conRecord.ND_created_from_interim__c == true )
            { 
                preHandleTypeHierarchySet(newMap.values(), oldmap);
            } 
        }
        //handleTypeHierarchySet(newMap, oldmap); 
        //update 
    }

    public static void afterUpdate(map<Id, Contact> newMap, map<Id, Contact> oldMap) { 
        
    }
    
    public static void afterDelete(map<Id, Contact> newMap) {  
    }
    
    public static void afterUndelete(map<Id, Contact> newMap) {  
    }
    */
    /* jrizzi1 - removing this as no longer needed and i need the coverage
    public static void preHandleTypeHierarchySet(list<Contact> typesNew , map<Id, Contact> typesOld){
        for(Contact myContact : typesNew){
            String newConTypes = myContact.ucinn_ascendv2__Contact_Type__c;
            string oldConTypes = typesOld.get(myContact.id).ucinn_ascendv2__Contact_Type__c;
            if (string.isnotblank(newConTypes) && newConTypes != null){
                Set<String> setPickVals = new Set<String>();
                setPickVals.addAll(newConTypes.split(';'));
                setPickVals.addAll(oldConTypes.split(';'));
                system.debug('setPickVals before: '+String.join((Iterable<String>)setPickVals, ';'));
                boolean hierarchyOverwrite = false;
                string combinedTypes;
    
                For(string setPickVal : setPickVals){
                
                
                list<Constituent_Type_Hierarchy__mdt> metaCheckNews = [select type_code__c , hierarchy__c from Constituent_Type_Hierarchy__mdt where type_code__c = :setPickVal];
                for (Constituent_Type_Hierarchy__mdt metaCheckNew : metaCheckNews){
                    if (metaCheckNew.hierarchy__c <= 1){
                        hierarchyOverwrite = true;
                        break;  
                        }
                
                    }
                }
    
                system.debug('hierarchyOverwrite: '+hierarchyOverwrite);
                if (hierarchyOverwrite == true){
                    Set<String> updatedPickVals = new Set<String>();
                    For(string setPickVal : setPickVals){
                        list<Constituent_Type_Hierarchy__mdt> metaCheckHiers = [select type_code__c , hierarchy__c from Constituent_Type_Hierarchy__mdt where type_code__c = :setPickVal];
                        for (Constituent_Type_Hierarchy__mdt metaCheckHier : metaCheckHiers){
                            if (metaCheckHier.hierarchy__c <= 1){
                                updatedPickVals.add(setPickVal);
                            }
                        }
                    }
                 combinedTypes = String.join((Iterable<String>)updatedPickVals, ';');
                } else {
                 combinedTypes = String.join((Iterable<String>)setPickVals, ';');
                }
                system.debug('combinedTypes: '+combinedTypes);

            myContact.ucinn_ascendv2__Contact_Type__c = combinedTypes;
            myContact.ND_created_from_interim__c = false;

        }
            
        }
*/

    
    // added the method from Nd_ContactTriggerHandler to keep only one trigger and one handler
    public static List<contact> setSuffixConstituentType(List<Contact> newRecords, Map<id,contact> oldRecords){
        Integer lsSize= newRecords.size();
        system.debug('lsSize'+lsSize);
        Map<id,contact> conList = new Map<id,contact>();
		
        Set<id> conIds = new Set<Id>();
        if(oldRecords!=null && !oldRecords.isEmpty())
        {           
            for(Contact c: newRecords){    
				if(c.ucinn_ascendv2__Contact_Type__c!=oldRecords.get(c.Id).ucinn_ascendv2__Contact_Type__c )
				{   
					conIds.add(c.Id);
				}
            }
        }
        else{
         // Handle the case where there are no old records, e.g., new inserts
           for (Contact c : newRecords) {
            conIds.add(c.Id);
           }            
        }  
        
		if(conIds.size()>0){
           conList = new Map<Id,Contact>([ select id,ucinn_ascendv2__Contact_Type__c,
                                            (  	Select id,ucinn_ascendv2__Degree_Year_Number_Formula__c 
												from ucinn_ascendv2__Degree_Information_Contact__r
												where ucinn_ascendv2__Degree_Year_Number_Formula__c != null AND 
														recordtype.Name='School Degree Information' 
														Order by ucinn_ascendv2__Degree_Year_Number_Formula__c Asc  
														limit 1
											) 
                                        from contact 
										where id=:conIds ]);
	//    system.debug('@@ conList '+conList.values());
                
        List<string> priorityOrder = new List<string>();
        Set<string> priorityOrderSet = new set<String>();

        for(Constituent_Type_Hierarchy__mdt st: ConTypeMetaData){  
            if(!priorityOrderSet.contains(st.type_code__c)){
                priorityOrder.add(st.type_code__c);
                priorityOrderSet.add(st.type_code__c);
            }
        }
        system.debug('@@ priority order '+priorityOrder);
        for(Integer i=0; i<lsSize; i++){
            contact con = newRecords[i];
            string suffix='';
                string suff='';
            if(string.isNotBlank(con.ucinn_ascendv2__Contact_Type__c) /*&& (oldRecords==null || conList.containsKey(con.Id))*/){
                Set<String> contype= new set<String>(con.ucinn_ascendv2__Contact_Type__c.split(';')); 
                
                for(string val: priorityOrder){
				// commenting this line. To calculate the Institutional suffix we need to use now Preferred Class year instead of Conferred degree year                    
                //    string alsuffix = (val =='AL' && conList.containsKey(con.Id) && !conList.get(con.Id).ucinn_ascendv2__Degree_Information_Contact__r.isEmpty()?'AL'+getDegreeYear(conList.get(con.Id).ucinn_ascendv2__Degree_Information_Contact__r[0].ucinn_ascendv2__Degree_Year_Number_Formula__c):val);
                    
				             
                	string alsuffix = ( (val =='AL' &&  conList.containsKey(con.Id) && !conList.get(con.Id).ucinn_ascendv2__Degree_Information_Contact__r.isEmpty() )     
                                         ? (((!String.isBlank(con.ND_Preferred_Degree_Year__c) || con.ND_Preferred_Degree_Year__c!=null )) ? 'AL'+getDegreeYear(con.ND_Preferred_Degree_Year__c) :'AL'+getDegreeYearDecimal(conList.get(con.Id).ucinn_ascendv2__Degree_Information_Contact__r[0].ucinn_ascendv2__Degree_Year_Number_Formula__c))
                                         : val
                                       );
                    system.debug('@@ alsuffix is '+alsuffix);
                    suffix= contype.contains(val)  ?( val =='AL'? alsuffix+' '+suffix:suffix+val+' '):suffix+'';
                    system.debug('@@ suffix is'+suffix);                   
                }
               
            }
                if(string.isNotBlank(suffix))
                    con.nd_Suffix_Constituent_Types__c =suffix.trim();
                 /*    if(con.nd_Suffix_Constituent_Types__c== NULL || con.nd_Suffix_Constituent_Types__c=='')
                {
                    String str=con.ucinn_ascendv2__Contact_Type__c.replace(';', ' ');
                    system.debug('nd_Suffix_Constituent_Types__c'+str);  
                   con.nd_Suffix_Constituent_Types__c = str;
                } */

        }               
        }
            
     //   system.debug('@@ new records are '+newRecords);
        return newRecords;
    }
    
    
    public static string getDegreeYearDecimal(Decimal val){
        return string.valueOf(val).substring(2);
    }
    
    public static string getDegreeYear(String val){
        return val.substring(2);
    }
    
    /* qluong 2/14/2024 No longer needed. Function has been moved to the flow. This method causes recursion with the ascend account trigger handler.
    public static void clearProspectCategory(List<contact> newRecords,Map<id,contact> oldMapRecords){   
        
        List<String> conIds = new List<String>();
        for(Contact con: newRecords){
            if(con.ucinn_ascendv2__Is_Deceased__c &&  
               oldMapRecords.get(con.Id).ucinn_ascendv2__Is_Deceased__c!=con.ucinn_ascendv2__Is_Deceased__c
              ){
                conIds.add(con.Id);
                                      
            }
        }
        List<account> acclist = new List<account>();
        if(conIds.size()>0){
            for(Contact conRecord: [Select id,accountId,account.recordType.DeveloperName,account.ND_Household_Types__c,account.ND_Household_Category__c,account.ND_Re_Evaluation_Date__c 
                                    ,(Select id from ucinn_ascendv2__Relationships_Contact__r where ucinn_ascendv2__Contact__c=:conIds
                                    AND nd_Status__c='Active' AND (ucinn_ascendv2__Related_Contact_Role__c ='Partner/Significant Other' OR 
                                     ucinn_ascendv2__Related_Contact_Role__c ='Spouse') limit 1)
                                    from contact where id=:conIds AND account.ucinn_ascendv2__Number_of_Household_Members__c=1
                                    AND Account.recordType.DeveloperName='Household' AND (Account.ND_Household_Category__c='R2'
                                    OR Account.ND_Household_Category__c='LE') 
                                   ])
            {       
                List<ucinn_ascendv2__Relationship__c> relRecords = conRecord.ucinn_ascendv2__Relationships_Contact__r;
                if(relRecords.isEmpty()){
                    acclist.add(new Account(id=conRecord.AccountId,ND_Household_Category__c='',ND_Household_Types__c='',ND_Re_Evaluation_Date__c=null));
                }
                if(acclist.size()>0) {
                    ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger('Account', false);
                    Update acclist;
                    ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger('Account', true);
                }
            }
        }
        
    }
    */

}