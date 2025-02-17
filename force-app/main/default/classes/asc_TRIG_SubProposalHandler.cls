/**
 * @author UC Innovation
 * @date 12/29/2022
 * @group Trigger Handlers
 * @description Handler class for Sub Proposal Trigger
 */
global class asc_TRIG_SubProposalHandler extends ucinn_ascendv2.ascend_TDTM_Runnable {
  private ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper = new ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper();

  /*******************************************************************************************************
   * @description Overridden method that handles the trigger actions and calls the relevant logic
   * @return The dmlWrapper with any sObjects to be inserted/updated/deleted
   */
    global override ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, ucinn_ascendv2.ascend_TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        List<Sub_Proposal__c> triggerNew = (List<Sub_Proposal__c>) newList;
        List<Sub_Proposal__c> triggerOld = (List<Sub_Proposal__c>) oldList;
        
        Map<Id, Sub_Proposal__c> triggerOldMap = new Map<Id, Sub_Proposal__c>();
        if (triggerOld != null) {
            for (Sub_Proposal__c sp : triggerOld) {
                triggerOldMap.put(sp.Id, sp);
            }
        }
        
        if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeInsert) {
            
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterInsert) {
            updateOpportunitySubmittedAmount(triggerNew, triggerOldMap);
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeUpdate) {
            
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterUpdate) {
            updateOpportunitySubmittedAmount(triggerNew, triggerOldMap);
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeDelete) {
            updateOpportunitySubmittedAmount(triggerNew, triggerOldMap);
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterDelete) {
            
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterUndelete) {
            updateOpportunitySubmittedAmount(triggerNew, triggerOldMap);
        }   
        
        return dmlWrapper;
    }
    
    /*******************************************************************************************************
     * @description: Update opportunity Submitted Amount (Ask Amount)
     * @param triggerNew The list of newly updated Sub Proposals
     * @param triggerOldMap The map of the old versions of the newly updated Sub Proposals
     * @return N/A.
     */
    private void updateOpportunitySubmittedAmount(List<Sub_Proposal__c> triggerNew, Map<Id, Sub_Proposal__c> triggerOldMap) {
        List<Sub_Proposal__c> triggerRecordList = triggerNew;
        List<Opportunity> updateOppList = new List<Opportunity>();
        Set<Id> oppSet = new Set<Id>();
        Set<Id> excludeSet = new Set<Id>();
        
        if (Trigger.isDelete) {
            triggerRecordList = triggerOldMap.values();
            excludeSet.addAll(triggerOldMap.keySet());
        }
        
        for (Sub_Proposal__c sp : triggerRecordList) {
            oppSet.add(sp.Opportunity__c);
        }
        
        for (Opportunity opp : [Select Id, Amount, ucinn_ascendv2__Submitted_Amount__c, (Select Id, Amount__c From Sub_Proposals1__r Where Id Not In :excludeSet And Amount__c <> null) 
        From Opportunity Where Id In :oppSet]) {
            
            Decimal totalamount = 0;
            
            for (Sub_Proposal__c sp : opp.Sub_Proposals1__r) {
                totalamount += sp.Amount__c;
            }
            
            if (opp.ucinn_ascendv2__Submitted_Amount__c != totalamount || opp.Amount != totalamount) {
                opp.ucinn_ascendv2__Submitted_Amount__c = totalamount;
                opp.Amount = totalamount;
                updateOppList.add(opp);
            }
        }
        
        if (!updateOppList.isEmpty()) {
            update updateOppList;
        }
    }
}