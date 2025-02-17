/**
 * @author  UC Innovation
 * @date 9/2/2020
 * @description Base Class for all trigger handlers to extend.
 */
global abstract class TRIG_BaseHandler extends ucinn_ascendv2.ascend_TDTM_Runnable {
  /*******************************************************************************************************
     * @description Base Trigger Handler. Find the right trigger context and call appropriate virtual class.
     * @param newList the list of Objects from trigger new.
     * @param oldList the list of Objects from trigger old.
     * @param triggerAction which trigger event (BeforeInsert, AfterInsert, etc.).
     * @param objResult the describe for Objects.
     * @return dmlWrapper: A wrapper containing all the records to perform DML on.
     */
    global override ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, ucinn_ascendv2.ascend_TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper = new ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper();
        
        Trigger_ContextVariables trigContextVars = new Trigger_ContextVariables(newList, oldList, triggerAction, objResult);

        setupMethods();
        
        //Provide context specific code using the following format.
        switch on triggerAction {
            when BeforeInsert {
                beforeInsert(trigContextVars, dmlWrapper);
            } when AfterInsert {
                afterInsert(trigContextVars, dmlWrapper);
            } when BeforeUpdate {
                beforeUpdate(trigContextVars, dmlWrapper);
            } when AfterUpdate {
                afterUpdate(trigContextVars, dmlWrapper);
            } when BeforeDelete {
                beforeDelete(trigContextVars, dmlWrapper);
            } when AfterDelete {
                afterDelete(trigContextVars, dmlWrapper);
            } when AfterUndelete {
                afterDelete(trigContextVars, dmlWrapper);
            }
        }
        
        return dmlWrapper;
    }

    /*******************************************************************************************************
     * @description Call these to setup data prior to everything else
     * @param trigContextVars Trigger Context Variables.
     * @param dmlWrapper any dmls required will be in here.
     * @return N/A.
     */
    protected virtual void setupMethods() {}

    /*******************************************************************************************************
     * @description Before Insert Calls.
     * @param trigContextVars Trigger Context Variables.
     * @param dmlWrapper any dmls required will be in here.
     * @return N/A.
     */
    protected virtual void beforeInsert(Trigger_ContextVariables trigContextVars, ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper) {}

    /*******************************************************************************************************
     * @description After Insert Calls.
     * @param trigContextVars Trigger Context Variables.
     * @param dmlWrapper any dmls required will be in here.
     * @return N/A.
     */
    protected virtual void afterInsert(Trigger_ContextVariables trigContextVars, ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper) {}

    /*******************************************************************************************************
     * @description Before Update Calls.
     * @param trigContextVars Trigger Context Variables.
     * @param dmlWrapper any dmls required will be in here.
     * @return N/A.
     */
    protected virtual void beforeUpdate(Trigger_ContextVariables trigContextVars, ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper) {}

    /*******************************************************************************************************
     * @description After Update Calls.
     * @param trigContextVars Trigger Context Variables.
     * @param dmlWrapper any dmls required will be in here.
     * @return N/A.
     */
    protected virtual void afterUpdate(Trigger_ContextVariables trigContextVars, ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper) {}

    /*******************************************************************************************************
     * @description Before Delete Calls.
     * @param trigContextVars Trigger Context Variables.
     * @param dmlWrapper any dmls required will be in here.
     * @return N/A.
     */
    protected virtual void beforeDelete(Trigger_ContextVariables trigContextVars, ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper) {}

    /*******************************************************************************************************
     * @description After Delete Calls.
     * @param trigContextVars Trigger Context Variables.
     * @param dmlWrapper any dmls required will be in here.
     * @return N/A.
     */
    protected virtual void afterDelete(Trigger_ContextVariables trigContextVars, ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper) {}

    /*******************************************************************************************************
     * @description After Undelete Calls.
     * @param trigContextVars Trigger Context Variables.
     * @param dmlWrapper any dmls required will be in here.
     * @return N/A.
     */
    protected virtual void afterUndelete(Trigger_ContextVariables trigContextVars, ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper) {}

    /*******************************************************************************************************
    * @description Class that wraps all trigger context variables.
    */
    global class Trigger_ContextVariables {
        global List<sObject> triggerNew = new List<sObject>();
        global List<sObject> triggerOld = new List<sObject>();
        global Map<ID, sObject> oldMap = new Map<ID, sObject>();
        global Map<ID, sObject> newMap = new Map<ID, sObject>();
        global ucinn_ascendv2.ascend_TDTM_Runnable.Action triggerAction;
        global Schema.DescribeSObjectResult contextObjResult;

      /*******************************************************************************************************
       * @description Constructor accepting trigger.new and trigger.old.
       * @param newList trigger.new.
       * @param oldList trigger.old.
       * @return N/A.
       */
        Trigger_ContextVariables(List<sObject> newList, List<sObject> oldList, ucinn_ascendv2.ascend_TDTM_Runnable.Action action, Schema.DescribeSObjectResult objResult) {
            triggerNew = newList;
            triggerOld = oldList;
            oldMap = createMap(triggerOld);
            newMap = createMap(triggerNew);
            triggerAction = action; 
            contextObjResult = objResult;

        }
    }

    /*******************************************************************************************************
    * @description Create new/old map from new/old trigger list.
    * @param triggerList The trigger list to convert into map.
    * @return Map of ID to Object.
    */
    private static Map<Id, sObject> createMap(List<sObject> triggerList) {
        //We try to replicate standard salesforce trigger functionality here. Maps return null, when the context is not right. For example,
        //If we try to access the oldMap for an object that is being inserted, it will be null.
        if (triggerList != null && !triggerList.isEmpty() && triggerList[0].Id != null) {
            return new Map<Id, sObject>(triggerList);
        } else {
            return null;
        }
    }
}