global class ND_DesignationBeneficiaryCount extends ucinn_ascendv2.ascend_TDTM_Runnable{
        
    private ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper = new ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper();
    
    global override ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, ucinn_ascendv2.ascend_TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        List<ucinn_ascendv2__Designation_Beneficiary__c> triggerNew = (List<ucinn_ascendv2__Designation_Beneficiary__c>) newList;
        List<ucinn_ascendv2__Designation_Beneficiary__c> triggerOld = (List<ucinn_ascendv2__Designation_Beneficiary__c>) oldList;
        
        Map<Id, ucinn_ascendv2__Designation_Beneficiary__c> triggerOldMap = new Map<Id, ucinn_ascendv2__Designation_Beneficiary__c>();
        if (triggerOld != null) {
            for (ucinn_ascendv2__Designation_Beneficiary__c hsc : triggerOld) {
                triggerOldMap.put(hsc.Id, hsc);
            }
        }
        if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterInsert) {
            getCount(triggerNew);
        } 
        if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterUpdate) {
            getCount(triggerNew);
        } 
        if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterDelete) {
            getCount(triggerOld);
        }  
        return dmlWrapper;
    }
    
    /* Calucates the unique Designation Beneficiaries for a Designation after year 2022 */
    
    global static void getCount(List<ucinn_ascendv2__Designation_Beneficiary__c> ids) {
        List<ucinn_ascendv2__Designation__c> desRecord = new List<ucinn_ascendv2__Designation__c>();
        List<ucinn_ascendv2__Designation__c> desRecord1 = new List<ucinn_ascendv2__Designation__c>();
        
        Set<id> recordids = new Set<id>(); // stores the designation ids
		Map<id,Decimal> designationAggregateCount=new Map<id,Decimal>(); // holds map of designation Id and corresponding aggregate count before checking duplicates/existing before 2022
        try{
            // get the designation record Ids
            for(ucinn_ascendv2__Designation_Beneficiary__c db : ids) {
                recordids.add(db.ucinn_ascendv2__Designation__c);
            }
            
            // Set to store DesignationIDs that have Designation beneficiary records
            Set<Id> designationsWithDesignationBeneficiaries = new Set<Id>();
            
            //store the aggregate count respective to each designation before checking for duplicates/existing designation beneficiary contacts
            for(AggregateResult agg: [Select ucinn_ascendv2__Designation__c,COUNT_DISTINCT(ucinn_ascendv2__Contact__c) cnt 
                                        from ucinn_ascendv2__Designation_Beneficiary__c 
                                        where ucinn_ascendv2__Designation__c =:recordids 
                                            AND nd_Fiscal_Year_Formula__c > '2022'
                                            AND ucinn_ascendv2__Contact__c!=null
                                            AND ucinn_ascendv2__Type__c NOT IN ('Scholarship - Pooled Need Based','Scholarship - Pooled Merit','Scholarship - Pooled GIA','Fellowship - Pooled Business','Fellowship - Pooled Law','Fellowship - Pooled Graduate','Endowed - Rector','Endowed - Coach','Endowed - Professor','Endowed - Director','Endowed - Dean','Scholarship - Other')  
                                            group by ucinn_ascendv2__Designation__c ])
            {
                designationsWithDesignationBeneficiaries.add((Id)agg.get('ucinn_ascendv2__Designation__c'));
                ucinn_ascendv2__Designation__c d = new ucinn_ascendv2__Designation__c(id= (ID)agg.get('ucinn_ascendv2__Designation__c'));
                d.nd_Current_Beneficiary_Count__c = Integer.valueof((Decimal)agg.get('cnt'));  
                designationAggregateCount.put(d.id,d.nd_Current_Beneficiary_Count__c);
           //   system.debug('@@ initial aggregate count is '+ d.nd_Current_Beneficiary_Count__c);
            }  
            
            // Determine which Designation IDs have zero Designation Beneficiaries
            Set<Id> designationsWithZeroDegnBen = new Set<Id>();
            for (Id designationId : recordids) {
                if (!designationsWithDesignationBeneficiaries.contains(designationId)) {
                    designationsWithZeroDegnBen.add(designationId);
                }
            }
            
           // system.debug('@@ designationsWithZeroDegnBen '+designationsWithZeroDegnBen);
            if(!designationsWithZeroDegnBen.isEmpty()){
                for(ucinn_ascendv2__Designation__c desg : [select id,nd_Current_Beneficiary_Count__c 
                                                           from ucinn_ascendv2__Designation__c 
                                                           where ID =:designationsWithZeroDegnBen]){
                    desg.nd_Current_Beneficiary_Count__c = 0;
                    desRecord1.add(desg);
                }
                
                if(!desRecord1.isEmpty())
                    update desRecord1;
            }
                    
            // Get existing beneficiaries before and equal to 2022
            List<ucinn_ascendv2__Designation_Beneficiary__c> beneficiaryRecordsBefore2022 = [SELECT ucinn_ascendv2__Designation__c, ucinn_ascendv2__Contact__c ,nd_Fiscal_Year_Formula__c,ucinn_ascendv2__Fiscal_Year__c,ucinn_ascendv2__Start_Date__c
                                                                                            FROM ucinn_ascendv2__Designation_Beneficiary__c 
                                                                                            WHERE ucinn_ascendv2__Designation__c IN :recordids 
                                                                                            AND nd_Fiscal_Year_Formula__c <= '2022'
                                                                                            AND ucinn_ascendv2__Contact__c != null
                                                                                            AND ucinn_ascendv2__Type__c NOT IN ('Scholarship - Pooled Need Based','Scholarship - Pooled Merit','Scholarship - Pooled GIA','Fellowship - Pooled Business','Fellowship - Pooled Law','Fellowship - Pooled Graduate','Endowed - Rector','Endowed - Coach','Endowed - Professor','Endowed - Director','Endowed - Dean','Scholarship - Other')];
            
            // Get existing beneficiaries after 2022
            List<ucinn_ascendv2__Designation_Beneficiary__c> beneficiaryRecordsAfter2022 = [SELECT id,ucinn_ascendv2__Designation__c, ucinn_ascendv2__Contact__c
                                                                                    FROM ucinn_ascendv2__Designation_Beneficiary__c 
                                                                                    WHERE ucinn_ascendv2__Designation__c IN :recordids 
                                                                                    AND nd_Fiscal_Year_Formula__c > '2022'
                                                                                    AND ucinn_ascendv2__Contact__c != null
                                                                                    AND ucinn_ascendv2__Type__c NOT IN ('Scholarship - Pooled Need Based','Scholarship - Pooled Merit','Scholarship - Pooled GIA','Fellowship - Pooled Business','Fellowship - Pooled Law','Fellowship - Pooled Graduate','Endowed - Rector','Endowed - Coach','Endowed - Professor','Endowed - Director','Endowed - Dean','Scholarship - Other')];
               
            map<Id, set<Id>> idMapOld = new map<Id, set<Id>>(); // map of designation and its unique beneficiary contact ids before and equal to 2022
            if(!beneficiaryRecordsBefore2022.isEmpty()){
                for(ucinn_ascendv2__Designation_Beneficiary__c b: beneficiaryRecordsBefore2022){
                    if(idMapOld.containsKey(b.ucinn_ascendv2__Designation__c)){
                        idMapOld.get(b.ucinn_ascendv2__Designation__c).add(b.ucinn_ascendv2__Contact__c);
                    }
                    else{
                        idMapOld.put(b.ucinn_ascendv2__Designation__c, new set<Id>{b.ucinn_ascendv2__Contact__c});
                    }
                }
                // 	system.debug('@@ idMapOld:'+idMapOld);
            }
            
            map<Id, set<Id>> idMapNew = new map<Id, set<Id>>();  // map of designation and its unique beneficiary contact id after to 2022
            Map<Id, List<ucinn_ascendv2__Designation_Beneficiary__c>> designationToBeneficiariesMap = new Map<Id, List<ucinn_ascendv2__Designation_Beneficiary__c>>();
            List<ucinn_ascendv2__Designation_Beneficiary__c> existingBeneficiaries = new List<ucinn_ascendv2__Designation_Beneficiary__c>(); // holds only beneficiary records which has unique contact ids
            set<id> contactIds = new set<id>();
            
            if(!beneficiaryRecordsAfter2022.isEmpty()){
                for(ucinn_ascendv2__Designation_Beneficiary__c b: beneficiaryRecordsAfter2022){
                    Id designationId = b.ucinn_ascendv2__Designation__c;
                    Id contactId = b.ucinn_ascendv2__Contact__c;
                    
                    if(idMapNew.containsKey(b.ucinn_ascendv2__Designation__c)){
                       //check whether the contact in designation beneficiary record is already present before 2023.
                       // if its not present, then only consider this contact id
                        if(idMapOld.containsKey(b.ucinn_ascendv2__Designation__c)){
                            contactIds = idMapOld.get(b.ucinn_ascendv2__Designation__c);
                            if(!contactIds.contains(b.ucinn_ascendv2__Contact__c)){
                                idMapNew.get(b.ucinn_ascendv2__Designation__c).add(b.ucinn_ascendv2__Contact__c);
                            }
                        }
                        else{
                            idMapNew.get(b.ucinn_ascendv2__Designation__c).add(b.ucinn_ascendv2__Contact__c);
                        }
                    }
                    else{
                        //check whether the contact in designation beneficiary record is already present before 2023.
                       // if its not present, then only consider this contact id
                        if(idMapOld.containsKey(b.ucinn_ascendv2__Designation__c)){
                            contactIds = idMapOld.get(b.ucinn_ascendv2__Designation__c);
                            if(!contactIds.contains(b.ucinn_ascendv2__Contact__c)){
                                idMapNew.put(b.ucinn_ascendv2__Designation__c, new set<Id>{b.ucinn_ascendv2__Contact__c});
                            }
                        }
                        else{
                            idMapNew.put(b.ucinn_ascendv2__Designation__c, new set<Id>{b.ucinn_ascendv2__Contact__c});
                        }
                        
                    }
                    
                    if (!designationToBeneficiariesMap.containsKey(designationId)) {
                        designationToBeneficiariesMap.put(designationId, new List<ucinn_ascendv2__Designation_Beneficiary__c>{b});
                        existingBeneficiaries = designationToBeneficiariesMap.get(designationId);
                    } 
                    else{
                        existingBeneficiaries = designationToBeneficiariesMap.get(designationId);
                        Boolean isUniqueContact = true;
                        // to check whether we already included beneficiary record with same constituent into count or not
                        // we need to consider only beneficiary records created after 2022 which has unique contacts and also they should not be in records created before 2023 as well
                        for (ucinn_ascendv2__Designation_Beneficiary__c existingBeneficiary : existingBeneficiaries) {
                            if (existingBeneficiary.ucinn_ascendv2__Contact__c == contactId) {
                                isUniqueContact = false;
                                break;
                            }	
                        }
                    
                        if (isUniqueContact) {
                            existingBeneficiaries.add(b);
                        }
                    }
                 
                }
            }
            
         //   system.debug('@@ existing beneficiaries '+existingBeneficiaries); 
         //   system.debug('@@ idMapNew '+idMapNew);
            set<id> existingConstituents;
            Decimal updatedCount =0;
            map<id, ucinn_ascendv2__Designation__c> updateMap = new map<id, ucinn_ascendv2__Designation__c>();
            
            if(existingBeneficiaries!=null || !existingBeneficiaries.isEmpty() ){
                for(ucinn_ascendv2__Designation_Beneficiary__c b :existingBeneficiaries ){
                    if(idMapOld!=null || !idMapOld.isEmpty() ){
                        existingConstituents = new set<id>();
                        existingConstituents = idMapOld.get(b.ucinn_ascendv2__Designation__c); 
                      //   system.debug('@@ existing constituents '+ existingConstituents);
                         if(existingConstituents!=null ){
                             if(existingConstituents.contains(b.ucinn_ascendv2__Contact__c)){
                               // system.debug('@@ its already present ');
                                updatedCount = designationAggregateCount.get(b.ucinn_ascendv2__Designation__c) - 1;
                                designationAggregateCount.put(b.ucinn_ascendv2__Designation__c,updatedCount);
                            }
                         }
                    }
                }
                
                for(ucinn_ascendv2__Designation__c desg : [select id,nd_Current_Beneficiary_Count__c from ucinn_ascendv2__Designation__c where ID =:recordids]){
                    desg.nd_Current_Beneficiary_Count__c = designationAggregateCount.get(desg.id);
                 //   system.debug('@@ final designation count is --> '+ desg.nd_Current_Beneficiary_Count__c);
                    desRecord.add(desg);
                }
                
                if(!desRecord.isEmpty() || desRecord!=null)
                {
                    updateMap.putall(desRecord);
                    if(updateMap.size()>0){
                        update updateMap.values();
                    }
                    
                }
            }
   		}
        catch(Exception e){
             system.debug('Exception occurred is' +e.getMessage());
        }
   } 
    
}