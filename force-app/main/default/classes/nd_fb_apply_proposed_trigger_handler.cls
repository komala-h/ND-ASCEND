global class nd_fb_apply_proposed_trigger_handler extends ucinn_ascendv2.ascend_TDTM_Runnable
{
    private ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper = new ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper();

    global override ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, ucinn_ascendv2.ascend_TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult)
    {
        List<Lottery_Application__c> triggerNew = (List<Lottery_Application__c>) newList;
        List<Lottery_Application__c> triggerOld = (List<Lottery_Application__c>) oldList;
        
        Map<Id, Lottery_Application__c> triggerOldMap = new Map<Id, Lottery_Application__c>();
        if (triggerOld != null)
        {
            for (Lottery_Application__c old : triggerOld)
            {
                triggerOldMap.put(old.Id, old);
            }
        }

    for(Lottery_Application__c app : triggerNew)
    {
        if ( !app.locked_for_automated_updates__c )
        {
            if ( trigger.isUpdate )
            {
                // only apply changes if the proposed app is different from the current app
                if ( app.Apply_Proposed_Lottery_Application__c  && app.Proposed_Lottery_Application_Level__c != triggerOldMap.get(app.Id)?.Lottery_Application_Level__c )
                {
                    app.Replaced_Lottery_Application_Level__c = triggerOldMap.get(app.Id)?.Lottery_Application_Level__c;
                    app.Replaced_Lottery_Application_Level_Audit__c = triggerOldMap.get(app.Id)?.Earned_Application_Audit__c;
                    app.Lottery_Application_Level__c = app.Proposed_Lottery_Application_Level__c;
                    app.Earned_Application_Audit__c = app.Proposed_Earned_Application_Audit__c;
                }
            }
    
            if ( trigger.isInsert )
            {
                // only apply changes if the proposed app is different from the current app
                if ( app.Apply_Proposed_Lottery_Application__c && app.Proposed_Lottery_Application_Level__c != app.Lottery_Application_Level__c )
                {
                    app.Replaced_Lottery_Application_Level__c = app.Lottery_Application_Level__c;
                    app.Replaced_Lottery_Application_Level_Audit__c = app.Earned_Application_Audit__c;
                    app.Lottery_Application_Level__c = app.Proposed_Lottery_Application_Level__c;
                    app.Earned_Application_Audit__c = app.Proposed_Earned_Application_Audit__c;
                }
            }
        }

        // this should always go back to false since it is our trigger to apply the next change
        app.Apply_Proposed_Lottery_Application__c = false;
    }
       
        return dmlWrapper;
    }
    
}