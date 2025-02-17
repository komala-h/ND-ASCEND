global class nd_DegreeInformationHandlerCls extends ucinn_ascendv2.ascend_TDTM_Runnable {

    private ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper = new ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper();
    
    global override ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, ucinn_ascendv2.ascend_TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        List<ucinn_ascendv2__Degree_Information__c> triggerNew = (List<ucinn_ascendv2__Degree_Information__c>) newList;
        List<ucinn_ascendv2__Degree_Information__c> triggerOld = (List<ucinn_ascendv2__Degree_Information__c>) oldList;

        Map<Id, ucinn_ascendv2__Degree_Information__c> triggerOldMap = new Map<Id, ucinn_ascendv2__Degree_Information__c>();
        if (triggerOld != null) {
            for (ucinn_ascendv2__Degree_Information__c eachCon : triggerOld) {
                triggerOldMap.put(eachCon.Id, eachCon);
            }
        }

        if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterInsert) {
           verifyConstituentDegree(triggerNew,null);
        } 
		else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterUpdate) {
            verifyConstituentDegree(triggerNew,triggerOldMap);
        } 
		else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterDelete) {
      		verifyConstituentDegree(triggerOld,null);
        } 

        return dmlWrapper;
    }
    
	/*    
    public static void afterInsert(List<ucinn_ascendv2__Degree_Information__c> newrecords){
        verifyConstituentDegree(newrecords,null);
    }
    
    public static void afterUpdate(List<ucinn_ascendv2__Degree_Information__c> newrecords, map<id,ucinn_ascendv2__Degree_Information__c> oldMaprecords){
       verifyConstituentDegree(newrecords,oldMaprecords);
    }
    public static void afterDelete(List<ucinn_ascendv2__Degree_Information__c> oldrecords){
        verifyConstituentDegree(oldrecords,null);
    }
	*/
    
    public static void verifyConstituentDegree(List<ucinn_ascendv2__Degree_Information__c> newrecords,map<id,ucinn_ascendv2__Degree_Information__c> oldMaprecords  ){
        
        set<id> conRec = new set<id>();
        List<string> priorityOrder = new List<string>();
        Set<string> priorityOrderSet = new set<String>();
        List<Constituent_Type_Hierarchy__mdt> ConTypeMetaData= [Select id,type_code__c from Constituent_Type_Hierarchy__mdt  order by Institutional_Suffix_Hierarchy_Order__c ASC];
        for(Constituent_Type_Hierarchy__mdt st: ConTypeMetaData){  
            if(!priorityOrderSet.contains(st.type_code__c)){
                priorityOrder.add(st.type_code__c);
                priorityOrderSet.add(st.type_code__c);
            }
        }
        
        if(oldMaprecords!=null){
        for(Integer i=0;i<newrecords.size();i++){
 			ucinn_ascendv2__Degree_Information__c degreeRecord = newrecords[i]; 
         
         if(degreeRecord.ucinn_ascendv2__Contact__c!=null &&
            oldMaprecords.get(degreeRecord.Id).ucinn_ascendv2__Conferred_Degree_Year__c!=degreeRecord.ucinn_ascendv2__Conferred_Degree_Year__c  ){
          	conRec.add(degreeRecord.ucinn_ascendv2__Contact__c);
          }
        }           
        }else{
            for(ucinn_ascendv2__Degree_Information__c deg:newrecords ){
                
                if(deg.ucinn_ascendv2__Contact__c!=null && deg.ucinn_ascendv2__Conferred_Degree_Year__c!=null)
                   conRec.add(deg.ucinn_ascendv2__Contact__c); 
            }
        }
        Map<id,contact> updatecontact= new Map<id,contact>();
        Map<id,Contact> conMap = new map<id,Contact>([Select id,ucinn_ascendv2__Contact_Type__c,nd_Suffix_Constituent_Types__c, (Select id,ucinn_ascendv2__Degree_Year_Number_Formula__c,ucinn_ascendv2__Conferred_Degree_Year__c from ucinn_ascendv2__Degree_Information_Contact__r
                                         where  ucinn_ascendv2__Degree_Year_Number_Formula__c!=null 
                                          AND recordtype.Name='School Degree Information' Order by ucinn_ascendv2__Degree_Year_Number_Formula__c Asc  limit 1)
                                         from contact where id=: conRec and ucinn_ascendv2__Contact_Type__c includes ('AL') and ucinn_ascendv2__Is_Deceased__c=false]);
     
        for(Integer i=0;i<newrecords.size();i++){
            ucinn_ascendv2__Degree_Information__c degreeRecord = newrecords[i];
            if(conMap.containsKey(degreeRecord.ucinn_ascendv2__Contact__c))
            {
                contact con = conMap.get(degreeRecord.ucinn_ascendv2__Contact__c);
                List<ucinn_ascendv2__Degree_Information__c> lsrecord = con.ucinn_ascendv2__Degree_Information_Contact__r;
                if(lsrecord.size()>0){
                for(ucinn_ascendv2__Degree_Information__c child: lsrecord){
                    String lowYear = 'AL'+string.valueOf(child.ucinn_ascendv2__Degree_Year_Number_Formula__c).substring(2);
                    system.debug(lowYear);
                    if(!con.nd_Suffix_Constituent_Types__c.contains(lowYear)){                        
						string suffix= addSuffix(con,priorityOrder,lowYear);
                        suffix= suffix.trim();
                        system.debug(suffix);
                        If(con.nd_Suffix_Constituent_Types__c!=suffix)
                        {
                        	con.nd_Suffix_Constituent_Types__c =suffix;
                            updatecontact.put(degreeRecord.ucinn_ascendv2__Contact__c,con);
                        }
                    }
                }
                }/*else{
                    string suffix= addSuffix(con,priorityOrder,'');
                     If(con.nd_Suffix_Constituent_Types__c!=suffix){
                         con.nd_Suffix_Constituent_Types__c =suffix;
                         updatecontact.put(degreeRecord.ucinn_ascendv2__Contact__c,con);
                     }
                }*/
            
            }
        }
        system.debug(updatecontact);
        if(updatecontact.size()>0)
            Update updatecontact.values();

    }
    
    public static string addSuffix(Contact con,List<string> priorityOrder, string deg){
        string result='';
        if(string.isNotBlank(con.ucinn_ascendv2__Contact_Type__c)){
                Set<String> contype= new set<String>(con.ucinn_ascendv2__Contact_Type__c.split(';')); 
                string suffix='';
                for(string val: priorityOrder){
                    string alsuffix = string.isNotBlank(deg) ?deg:val;
                    suffix= contype.contains(val)  ?( val =='AL'? alsuffix+' '+suffix:suffix+' '+val):suffix+'';                   
                }
                if(string.isNotBlank(suffix))
                	result =suffix.trim();
            }
        return result;
    }
  
    public static void setConstituentAttributes(list<ucinn_ascendv2__Degree_Information__c> records){
        Map<id,id> relationRecords = new map<id,id>() ;
        List<id> relatedconsrecords = new List<id>();
        for(integer i=0;i<records.size();i++){
            ucinn_ascendv2__Degree_Information__c record= records[i];
            if(record.nd_Current_Student_Class_Level__c== '1'|| record.nd_Current_Student_Class_Level__c == '2' ||
              record.nd_Current_Student_Class_Level__c== '3' || record.nd_Current_Student_Class_Level__c == '4')
            relatedconsrecords.add(record.ucinn_ascendv2__Contact__c);
        }
        
        for(ucinn_ascendv2__Relationship__c relationShip :[select id,ucinn_ascendv2__Related_Constituent_Type_Formula__c,ucinn_ascendv2__Contact__c,ucinn_ascendv2__Related_Contact__c from ucinn_ascendv2__Relationship__c 
                                                                  where ucinn_ascendv2__Related_Contact__c=:relatedconsrecords and  
                                                           ucinn_ascendv2__Related_Constituent_Type_Formula__c='Student' ])
        {                
        	relationRecords.put(relationShip.ucinn_ascendv2__Related_Contact__c,relationShip.ucinn_ascendv2__Contact__c);
        }
        
        
   }
}