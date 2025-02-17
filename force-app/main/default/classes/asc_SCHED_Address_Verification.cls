global class asc_SCHED_Address_Verification implements Schedulable {   

   global String whereClause;
   global Integer batchSize;
   global Map<String, String> addressFieldMap;
   global String objParam;
        
    global void execute(SchedulableContext ct) {
        
        if(objParam == null) { 
            objParam = 'ucinn_ascendv2__interim__c';
        }
        
        Set<String> matchCodeSet = new Set<String>{'Y','N','S','D',null};
        Set<String> vacantSet = new Set<String>{'N','Y',null};
        Set<String> verificationStatusSet = new Set<String>{'Verified'};
        Set<String> addressPrecisionSet = new Set<String>{'Premise', 'DeliveryPoint'};

        Map<String, Set<String>> uspsParam = new Map<String, Set<String>>();
        uspsParam.put('ucinn_ascendv2__DPV_Match_Code__c', matchCodeSet);
        uspsParam.put('ucinn_ascendv2__DPV_Vacant__c', vacantSet);
        
        Map<String, Set<String>> internationalParam = new Map<String, Set<String>>();
        internationalParam.put('ucinn_ascendv2__Verification_Status__c', verificationStatusSet);
        internationalParam.put('ucinn_ascendv2__Address_Precision__c', addressPrecisionSet);
        
        ucinn_ascendv2.ascend_UTIL_RunBatch.ascend_ADDR_VerifyAddrSmartyStreetsBatch(whereClause, 
                                                                                     uspsParam,                                                                                  
                                                                                     internationalParam, 
                                                                                     objParam, 
                                                                                     addressFieldMap, 
                                                                                     batchSize);
    }
}