//-------------------------------------------------------------
//  @description    custom trigger handler for Work Plan Unit
//  @author         UCInnovation
//  @date           05/08/2022
//  
global without sharing class asc_TRIG_WorkPlanUnitHandler extends TRIG_BaseHandler {
    protected override void beforeInsert(Trigger_ContextVariables trigContextVars, ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper) {
        verifyLevelLookup(trigContextVars);
    }
    
    protected override void afterInsert(Trigger_ContextVariables trigContextVars, ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper) {
        initiateRecalucationBatch(trigContextVars);
    }
    
    protected override void beforeUpdate(Trigger_ContextVariables trigContextVars, ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper) {
        verifyLevelLookup(trigContextVars);
    }
    
    protected override void afterUpdate(Trigger_ContextVariables trigContextVars, ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper) {
        initiateRecalucationBatch(trigContextVars);
    }
    
    protected override void afterDelete(Trigger_ContextVariables trigContextVars, ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper) {
        initiateRecalucationBatch(trigContextVars);
    }

    protected override void afterUndelete(Trigger_ContextVariables trigContextVars, ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper) {
        initiateRecalucationBatch(trigContextVars);
    }    
    
    //-----------------------------------------------------------------------------
    // @description verifies that the Funding Priorities hierachy tree is properly
    //              maintained during inserts/update (e.g. parent of L4 MUST BE L3)
    //              We strictly follow:
    //              L4 --> L3 --> L2 --> L1 --> NO Funding Priorities
    //              P/S: Record Type cannot be changed
    //              P/S2: Goal can ONLY be changed on L4
    // @param       trigContextVars     trigger Context variables
    // @return      void
    // 
    global void verifyLevelLookup(Trigger_ContextVariables trigContextVars) {
        asc_UTIL_FundingPrioritiesUtils utils = new asc_UTIL_FundingPrioritiesUtils();      
        
        //Step 1: Gather & query the parent Funding Priorities for L4, L3, L2
        Set<Id> parentLookups = new Set<Id>();
        for (ucinn_ascendv2__Work_Plan_Unit__c eachFundingPriority 
                : (List<ucinn_ascendv2__Work_Plan_Unit__c>) trigContextVars.triggerNew) {
            if (eachFundingPriority.RecordTypeId == utils.levelToRecordType.get(4)
                    || eachFundingPriority.RecordTypeId == utils.levelToRecordType.get(3)
                    || eachFundingPriority.RecordTypeId == utils.levelToRecordType.get(2)) {
                parentLookups.add(eachFundingPriority.ucinn_ascendv2__Work_Plan_Unit__c);   
            } 
        }
        parentLookups.remove(null);
        
        Map<Id, ucinn_ascendv2__Work_Plan_Unit__c> parentMap = new Map<Id, ucinn_ascendv2__Work_Plan_Unit__c> 
            ([SELECT Id, RecordTypeId FROM ucinn_ascendv2__Work_Plan_Unit__c WHERE Id IN:parentLookups]);
        
        //Step 2: Make sure that hierachy is maintained for all Funding Priorities (L4 --> L3 --> L2 --> L1 --> NONE)
        for (ucinn_ascendv2__Work_Plan_Unit__c eachFundingPriority 
                : (List<ucinn_ascendv2__Work_Plan_Unit__c>) trigContextVars.triggerNew) {
                    
            //For Updates
            if (trigContextVars.triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.beforeUpdate
                    && trigContextVars.oldMap.get(eachFundingPriority.Id) != null) {
                
                //Get Old record information
                ucinn_ascendv2__Work_Plan_Unit__c oldFundingPriority 
                    = (ucinn_ascendv2__Work_Plan_Unit__c) trigContextVars.oldMap.get(eachFundingPriority.Id);
                
                //Check for Record Type change
                if (eachFundingPriority.RecordTypeId != oldFundingPriority.RecordTypeId
                        && (utils.recordTypeToLevel.containsKey(eachFundingPriority.RecordTypeId)
                            || utils.recordTypeToLevel.containsKey(oldFundingPriority.RecordTypeId))) { 
                    throw new DmlException('Funding Priorities Levels cannot be changed.');
                }
                
                //11-27-23 qluong - commenting out this validation rule because when the code runs, it will update funding priority
                //1, 2 and 3 and this validation rule go into effect.     
                //Check for amount change
                //if (eachFundingPriority.Goal__c != oldFundingPriority.Goal__c
                //        && eachFundingPriority.RecordTypeId != utils.levelToRecordType.get(4)) {
                //    throw new DmlException('Goal amount can only be edited on Level 4 Funding Priorities.');
                //}       
            }                
                    
            //Only consider Funding Priorities Level record types
            if (!utils.recordTypeToLevel.containsKey(eachFundingPriority.RecordTypeId)) {
                continue;
            }
                    
            //L1 should NOT be child of ANY Funding Priorities
            if (utils.recordTypeToLevel.get(eachFundingPriority.RecordTypeId) == 1
                    && eachFundingPriority.ucinn_ascendv2__Work_Plan_Unit__c != null) {
                throw new DmlException('Level 1 Funding Priorities cannot be children of any Funding Priorities');
            }
                    
            //No parent => just skip (even if it's L1, which is correct in this case)
            if (eachFundingPriority.ucinn_ascendv2__Work_Plan_Unit__c == null) {
                continue;
            }
            
            //Make sure hierarchy is maintained
            ucinn_ascendv2__Work_Plan_Unit__c parentPriority = parentMap.get(eachFundingPriority.ucinn_ascendv2__Work_Plan_Unit__c);
            if (parentPriority != null
                    && (utils.recordTypeToLevel.get(eachFundingPriority.RecordTypeId) - 1) //ALWAYS have a value (checked above)
                            != utils.recordTypeToLevel.get(parentPriority.RecordTypeId)) { //this one can be null, which is error
                throw new DmlException('A Funding Priority can only be a child of the immediate parent Level. Please check the Record Types of the parent/child Funding Priority');
            }
        }        
    }
    
    //---------------------------------------------------------------------------------
    // @description initiate the Funding Priorities goal calculation batch to bubble
    //              up the changes and aggregate the lower level Funding Priorities
    //              to the upper level Funding Priorities
    // @param       trigContextVars     trigger context variables
    // @return      void
    // 
    global void initiateRecalucationBatch(Trigger_ContextVariables trigContextVars) {
        //can't fire batch in batch/future, should we email them?
        if (System.isBatch() || System.isFuture()) {
            return;
        }
        
        asc_UTIL_FundingPrioritiesUtils utils = new asc_UTIL_FundingPrioritiesUtils();      
        
        //Batch Variables
        Map<Integer, Set<Id>> fundingPrioritiesToCalculate = new Map<Integer, Set<Id>>();
        Integer batchStartLevel;
        
        if (trigContextVars.triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.afterInsert
                || trigContextVars.triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.afterUndelete) {
            //For afterInsert and afterUndelete, determine by triggerNew
            batchStartLevel = determineStartLevelAndPopulateParentsToRecalculate(
                                fundingPrioritiesToCalculate,
                                (List<ucinn_ascendv2__Work_Plan_Unit__c>) trigContextVars.triggerNew,
                                utils);
                    
        } else if (trigContextVars.triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.afterUpdate) {
            batchStartLevel = determineStartLevelAndPopulateParentsToRecalculateForUpdate(
                                fundingPrioritiesToCalculate,
                                trigContextVars,
                                utils);
            
        } else if (trigContextVars.triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.afterDelete) {
            //For afterDelete, determine by triggerOld
            batchStartLevel = determineStartLevelAndPopulateParentsToRecalculate(
                                fundingPrioritiesToCalculate,
                                (List<ucinn_ascendv2__Work_Plan_Unit__c>) trigContextVars.triggerOld,
                                utils);     
        }
        
        System.debug(batchStartLevel);
        System.debug(fundingPrioritiesToCalculate);
        
        //Everything was skipped, no need to recalculate
        if (batchStartLevel == null
                || (batchStartLevel == 0 
                    && (fundingPrioritiesToCalculate.get(0) == null
                        || fundingPrioritiesToCalculate.get(0).isEmpty()))) {
            return;
        }
        
        //10 is prolly good enough, not sure if they insert like 1000s
        Database.executeBatch(new asc_Batch_RecalculateFundingPriority(batchStartLevel, fundingPrioritiesToCalculate, 10), 10);
    }
    
    //---------------------------------------------------------------------------
    // @description determine the start level for the batch and find the parents
    //              that are affected in this operation based on the triggerScope. 
    //              Used for insert/delete/undelete
    // @param       fundingPrioritiesToCalculate    store affected parent Ids
    // @param       triggerScope                    can be triggerNew or triggerOld
    // @param       utils                           utils class that have the 
    //                                              Record Type Id maps
    // @return      Integer                         start level for batch
    //
    global Integer determineStartLevelAndPopulateParentsToRecalculate(
        Map<Integer, Set<Id>> fundingPrioritiesToCalculate,
        List<ucinn_ascendv2__Work_Plan_Unit__c> triggerScope, 
        asc_UTIL_FundingPrioritiesUtils utils) {
            
        Integer batchStartLevel = 0;
        for (ucinn_ascendv2__Work_Plan_Unit__c eachFundingPriority : triggerScope) {
            
            //We only care about funding priorities (null RecordTypeId will also skip, which is correct)
            if (!utils.recordTypeToLevel.containsKey(eachFundingPriority.RecordTypeId)) {
                continue;
            }
            
            //Now selfLevel MUST be 1, 2, 3, or 4 (can't be 0 because that's Campaign Rec Type Id)
            Integer selfLevel = utils.recordTypeToLevel.get(eachFundingPriority.RecordTypeId);

            Set<Id> parentToRecalculate = fundingPrioritiesToCalculate.get(selfLevel - 1);
            if (parentToRecalculate == null) {
                parentToRecalculate = new Set<Id>();
            }
                    
            if (selfLevel == 1 && eachFundingPriority.Comprehensive_Campaign__c != null) {
                parentToRecalculate.add(eachFundingPriority.Comprehensive_Campaign__c);
            } else if (selfLevel > 1 && eachFundingPriority.ucinn_ascendv2__Work_Plan_Unit__c != null) {
                //MUST be 2, 3, or 4
                parentToRecalculate.add(eachFundingPriority.ucinn_ascendv2__Work_Plan_Unit__c);
            } else {
                //continue here so that it won't overwrite fundingPrioritiesToCalculate and batchStartLevel
                continue;
            }
                    
            fundingPrioritiesToCalculate.put(selfLevel - 1, parentToRecalculate);
            
            //We want to start at the PARENT's level,
            //  no need to start at the child
            if ((selfLevel - 1) > batchStartLevel) {
                batchStartLevel = selfLevel - 1;
            }
        }
        return batchStartLevel;
    }  
    
    //---------------------------------------------------------------------------
    // @description determine the start level for the batch and find the parents
    //              that are affected in this update based on the triggerScope. 
    //              Used for updates
    // @param       fundingPrioritiesToCalculate    store affected parent Ids
    // @param       trigContextVars                 trigger Context variables
    // @param       utils                           utils class that have the 
    //                                              Record Type Id maps
    // @return      Integer                         start level for batch
    //
    global Integer determineStartLevelAndPopulateParentsToRecalculateForUpdate(
        Map<Integer, Set<Id>> fundingPrioritiesToCalculate,
        Trigger_ContextVariables trigContextVars, 
        asc_UTIL_FundingPrioritiesUtils utils) {
            
        Integer batchStartLevel = 0;
        for (ucinn_ascendv2__Work_Plan_Unit__c eachFundingPriority 
                : (List<ucinn_ascendv2__Work_Plan_Unit__c>) trigContextVars.triggerNew) {
                    
            //Again, we only care about funding priorities (null RecordTypeId will also skip, which is correct)
            if (!utils.recordTypeToLevel.containsKey(eachFundingPriority.RecordTypeId)) {
                continue;
            }
                    
            //Now selfLevel MUST be 1, 2, 3, or 4 (can't be 0 because that's Campaign Rec Type Id)
            Integer selfLevel = utils.recordTypeToLevel.get(eachFundingPriority.RecordTypeId);

            Set<Id> parentToRecalculate = fundingPrioritiesToCalculate.get(selfLevel - 1);
            if (parentToRecalculate == null) {
                parentToRecalculate = new Set<Id>();
            }
             
            ucinn_ascendv2__Work_Plan_Unit__c oldFundingPriority 
                = (ucinn_ascendv2__Work_Plan_Unit__c) trigContextVars.oldMap.get(eachFundingPriority.Id);
            
            //Null check, yea I'm paranoid
            if (oldFundingPriority == null) {
                continue;
            }
                    
            if (//For L2, L3, L4 reparenting Work Plan Unit change
                (eachFundingPriority.ucinn_ascendv2__Work_Plan_Unit__c != oldFundingPriority.ucinn_ascendv2__Work_Plan_Unit__c
                        && (eachFundingPriority.RecordTypeId == utils.levelToRecordType.get(4)
                            || eachFundingPriority.RecordTypeId == utils.levelToRecordType.get(3)
                            || eachFundingPriority.RecordTypeId == utils.levelToRecordType.get(2)))
                
                    //For L1 reparenting Comprehensive Campaign change
                    || (eachFundingPriority.Comprehensive_Campaign__c != oldFundingPriority.Comprehensive_Campaign__c
                        && eachFundingPriority.RecordTypeId == utils.levelToRecordType.get(1))
                
                    //For L4 Goal Amount change (we already check for L4 in beforeUpdate)
                    || (eachFundingPriority.Goal__c != oldFundingPriority.Goal__c)) {      
                   
                //We have to recalculate BOTH the new parent and the old parent
                if (selfLevel == 1) {
                    parentToRecalculate.add(eachFundingPriority.Comprehensive_Campaign__c);
                    parentToRecalculate.add(oldFundingPriority.Comprehensive_Campaign__c);
                } else if (selfLevel > 1) { // selfLevel can only be 2, 3, or 4 here
                    parentToRecalculate.add(eachFundingPriority.ucinn_ascendv2__Work_Plan_Unit__c);
                    parentToRecalculate.add(oldFundingPriority.ucinn_ascendv2__Work_Plan_Unit__c);
                }
                parentToRecalculate.remove(null);
            } else {
                //continue here so that it won't overwrite fundingPrioritiesToCalculate and batchStartLevel
                continue;
            }
                    
            fundingPrioritiesToCalculate.put(selfLevel - 1, parentToRecalculate);
                    
            //We want to start at the PARENT's level,
            //  no need to start at the child
            if ((selfLevel - 1) > batchStartLevel) {
                batchStartLevel = selfLevel - 1;
            }
        }
            
        return batchStartLevel;
    }
}