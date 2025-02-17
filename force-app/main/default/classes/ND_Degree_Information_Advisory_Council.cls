global class ND_Degree_Information_Advisory_Council extends ucinn_ascendv2.ascend_TDTM_Runnable{
    
    private ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper = new ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper();
    
    global override ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, ucinn_ascendv2.ascend_TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        List<ucinn_ascendv2__Degree_Information__c> triggerNew = (List<ucinn_ascendv2__Degree_Information__c>) newList;
        List<ucinn_ascendv2__Degree_Information__c> triggerOld = (List<ucinn_ascendv2__Degree_Information__c>) oldList;
        
        Map<Id, ucinn_ascendv2__Degree_Information__c> triggerOldMap = new Map<Id, ucinn_ascendv2__Degree_Information__c>();
        if (triggerOld != null) {
            for (ucinn_ascendv2__Degree_Information__c Dgi : triggerOld) {
                triggerOldMap.put(Dgi.Id, Dgi);
            }
        }
        
        if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeInsert) {
            
        } 
        else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterInsert) {
            UpdateDegreeInfo(triggerNew);
        } 
        else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterUpdate) {
            UpdateDegreeInfo(triggerNew);
        } 
        
        
        return dmlWrapper;
    }
    
    public static void UpdateDegreeInfo(List<ucinn_ascendv2__Degree_Information__c> newRec){
        
        // Create a Set to store unique Contact IDs
        Set<Id> contactIds = new Set<Id>();
        // Create a Map to store Contact IDs and their related involvement counts
        Map<Id, Integer> contactInvolvementCountMap = new Map<Id, Integer>();
        // Iterate over new records and add Contact IDs to the set
        
        for (ucinn_ascendv2__Degree_Information__c degreeInfo : newRec) {
            contactIds.add(degreeInfo.ucinn_ascendv2__Contact__c);
            system.debug('contactIds'+contactIds);
        }
        
        // Query involvements related to the Contacts and count them
        List<AggregateResult> involvementAggregateResults = [
            SELECT ucinn_ascendv2__Contact__c, COUNT(Id) involvementCount
            FROM ucinn_ascendv2__Involvement__c
            WHERE ucinn_ascendv2__Contact__c IN :contactIds 
            AND nd_Record_Type_Dev_Name__c = 'Advisory_Council' 
            AND ucinn_ascendv2__Involvement_Code__r.nd_Record_Type_Dev_Name__c = 'Advisory_Council' 
            AND (ucinn_ascendv2__Status__c = 'A' OR ucinn_ascendv2__Status__c = 'H') 
            GROUP BY ucinn_ascendv2__Contact__c
        ];
        
        // Populate the map with Contact IDs and their related involvement counts
        for (AggregateResult result : involvementAggregateResults) {
            Id contactId = (Id)result.get('ucinn_ascendv2__Contact__c');
            Integer involvementCount = (Integer)result.get('involvementCount');
            contactInvolvementCountMap.put(contactId, involvementCount);
        }
        // Query Contacts with related Degree Information
        List<Contact> contactList = [
            SELECT Id, 
            (SELECT Id, Req_Degree_Info__c FROM ucinn_ascendv2__Degree_Information_Contact__r),
            DegreeInfo__c 
            FROM Contact 
            WHERE ID IN :contactIds
        ]; 
        system.debug('contactList'+contactList);
        
        //Retreive Preferred Spouse of Contacts
         List<id>spouseIds=new list<id>();
         List<Contact> spouseConList = [
            SELECT Id,ucinn_ascendv2__Preferred_Spouse__c 
            FROM Contact 
            WHERE ID IN :contactInvolvementCountMap.Keyset() and ucinn_ascendv2__Preferred_Spouse__c!=NULL
        ]; 
         for(Contact conSpouse:spouseConList)
         {
             spouseIds.add(conSpouse.ucinn_ascendv2__Preferred_Spouse__c);
         }
          system.debug('spouseIds'+spouseIds);
        
         // Query Spouse Contacts with related Degree Information
          List<Contact> spouseList = [
            SELECT Id, 
            (SELECT Id, Req_Degree_Info__c FROM ucinn_ascendv2__Degree_Information_Contact__r),
            DegreeInfo__c 
            FROM Contact 
            WHERE ID IN :spouseIds
        ]; 
         system.debug('spouseList'+spouseList);
        
        // Update Degree Information for each Contact
        for (Contact con : contactList) {
            List<String> degreeInfoList = new List<String>();
            //String degreeInfo = '';
            if (!con.ucinn_ascendv2__Degree_Information_Contact__r.isEmpty() && contactInvolvementCountMap.get(con.id)>0) {
                for (ucinn_ascendv2__Degree_Information__c degree : con.ucinn_ascendv2__Degree_Information_Contact__r) {
                    if(degree.Req_Degree_Info__c!=null)
                    {
                       degreeInfoList.add(degree.Req_Degree_Info__c);
                    }
                }  
            }
            String degreeInfo = String.join(degreeInfoList, '; ');
            system.debug('degreeInfo'+degreeInfo);
            con.DegreeInfo__c = degreeInfo;
        }
         // Update Degree Information for each Spouse Contact
         for (Contact conSpouse : spouseList) {
            List<String> degreeInfoListSpouse = new List<String>();
            //String degreeInfo1 = '';
            if (!conSpouse.ucinn_ascendv2__Degree_Information_Contact__r.isEmpty()) {
                for (ucinn_ascendv2__Degree_Information__c degree : conSpouse.ucinn_ascendv2__Degree_Information_Contact__r) {
                    if(degree.Req_Degree_Info__c!=null)
                    {
                        degreeInfoListSpouse.add(degree.Req_Degree_Info__c);
                    }
                }  
            }
            String degreeInfo1 = String.join(degreeInfoListSpouse, '; ');
            system.debug('degreeInfo1'+degreeInfo1);
            conSpouse.DegreeInfo__c = degreeInfo1;
        }
        
        // Update Contacts
        update contactList;
        update spouseList;
    }
}