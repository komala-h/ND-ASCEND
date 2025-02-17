global class Nd_InterimValTriggerHandler extends ucinn_ascendv2.ascend_TDTM_Runnable {
    
    
    private ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper = new ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper();
    
    global override ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, ucinn_ascendv2.ascend_TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        List<ucinn_ascendv2__Interim__c> triggerNew = (List<ucinn_ascendv2__Interim__c>) newList;
        List<ucinn_ascendv2__Interim__c> triggerOld = (List<ucinn_ascendv2__Interim__c>) oldList;
        
        Map<Id, ucinn_ascendv2__Interim__c> triggerOldMap = new Map<Id, ucinn_ascendv2__Interim__c>();
        if (triggerOld != null) {
            for (ucinn_ascendv2__Interim__c hsc : triggerOld) {
                triggerOldMap.put(hsc.Id, hsc);
            }
        }
        
        if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeInsert) {
            ValidateInterim(triggerNew);
        } 
        else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterUpdate) {
            
        } 
        
        
        return dmlWrapper;
    }
    public static void ValidateInterim(list<ucinn_ascendv2__Interim__c> NewList){
        
        for(ucinn_ascendv2__Interim__c intr: NewList)
        {
            if(intr.ND_Address_1_Data_Source__c!=null)
            {
              intr.ND_data_source_code__c= intr.ND_Address_1_Data_Source__c; 
            }
            if(intr.ND_Email_1_Data_Source__c!=null)
            {
              intr.ND_data_source_code__c= intr.ND_Email_1_Data_Source__c; 
            }
            system.debug('in email'+intr.ND_Email_1_Type__c);
            system.debug('in email'+intr.ucinn_ascendv2__Email_1__c);
            if((intr.ND_Email_1_Type__c!=null && intr.ucinn_ascendv2__Email_1__c==null))
            {
               intr.ND_Email_1_Type__c='';
               intr.ucinn_ascendv2__Email_1__c='';
               intr.ND_Email_1_Data_Source__c=''; 
                system.debug('in email');
            } 
            system.debug('in email'+intr.ND_Address_1_Type__c);
            if((intr.ND_Address_1_Type__c!=null) && (intr.ucinn_ascendv2__Address_1_Line_1__c==null || intr.ucinn_ascendv2__City_1__c==null || intr.ucinn_ascendv2__State_1__c==null || intr.ucinn_ascendv2__Postal_Code_1__c==null))
            {
               intr.ND_Address_1_Type__c='';
               intr.ucinn_ascendv2__Address_1_Line_1__c='';
                intr.ucinn_ascendv2__City_1__c='';
                intr.ucinn_ascendv2__State_1__c='';
                intr.ucinn_ascendv2__Country_1__c='';
                intr.ucinn_ascendv2__Postal_Code_1__c='';
                intr.ND_Address_1_Data_Source__c='';
                intr.ND_Address_1_Data_Source_Abbrev__c='';
                system.debug('in address');
            } 
        }
        
    }
}