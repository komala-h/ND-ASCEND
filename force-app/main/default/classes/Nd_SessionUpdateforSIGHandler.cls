global class Nd_SessionUpdateforSIGHandler extends ucinn_ascendv2.ascend_TDTM_Runnable {
    
    
    private ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper = new ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper();
    
    global override ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, ucinn_ascendv2.ascend_TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        List<ucinn_ascendv2__Hard_and_Soft_Credit__c> triggerNew = (List<ucinn_ascendv2__Hard_and_Soft_Credit__c>) newList;
        List<ucinn_ascendv2__Hard_and_Soft_Credit__c> triggerOld = (List<ucinn_ascendv2__Hard_and_Soft_Credit__c>) oldList;
        
        Map<Id, ucinn_ascendv2__Hard_and_Soft_Credit__c> triggerOldMap = new Map<Id, ucinn_ascendv2__Hard_and_Soft_Credit__c>();
        if (triggerOld != null) {
            for (ucinn_ascendv2__Hard_and_Soft_Credit__c ses : triggerOld) {
                triggerOldMap.put(ses.Id, ses);
            }
        }
        
        if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeInsert) {
            updateUniversityDate(triggerNew);
        } 
        if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.Beforeupdate) {
             updateUniversityDate(triggerNew);
        } 
        if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterInsert) {
                  SessionProcess(triggerNew);  
        } 
        return dmlWrapper;
    }
    
    public static void updateUniversityDate(List<ucinn_ascendv2__Hard_and_Soft_Credit__c> newRecList){
        Set<Id> reviewId= new Set<Id>();
        map<id,Date> unDate= new map<id,Date>();
        
        for(ucinn_ascendv2__Hard_and_Soft_Credit__c hs: newRecList)
        {
            reviewId.add(hs.ucinn_ascendv2__Review_Transaction_v2__c);  
        }
        
        for(ucinn_ascendv2__Review_Transaction_v2__c hards :[select id,nd_Membership_Credit_Date__c 
                                                             from ucinn_ascendv2__Review_Transaction_v2__c 
                                                             where id IN:reviewId]){
            unDate.put(hards.id,hards.nd_Membership_Credit_Date__c);
        }
        
        for(ucinn_ascendv2__Hard_and_Soft_Credit__c hrdsft: newRecList)
        {
            hrdsft.nd_Membership_Credit_Date__c=unDate.get(hrdsft.ucinn_ascendv2__Review_Transaction_v2__c);
        }
    }
    
    
    public static void SessionProcess(List<ucinn_ascendv2__Hard_and_Soft_Credit__c> newRec){
        
        List<ucinn_ascendv2__Hard_and_Soft_Credit__c> record = newRec;
        
        // Create a map to hold the input values
        Map<String, Object> flowInputs = new Map<String, Object>();
        flowInputs.put('recordId', record[0].id);
        // Create a new instance of the flow interview and start the flow
        Flow.Interview flowInterview = new Flow.Interview.Hard_and_Soft(flowInputs);
        flowInterview.start();
    }
    
}