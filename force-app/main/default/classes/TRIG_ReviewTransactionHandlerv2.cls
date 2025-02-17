/**
 * @author Brandon Chung, UC Innovation
 * @date 10/24/2022
 * @description Handler class for RTv2 Trigger
 */
global class TRIG_ReviewTransactionHandlerv2 extends TRIG_BaseHandler{
    protected override void beforeInsert(Trigger_ContextVariables trigContextVars, ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper) {
        prepopulateExternalID(trigContextVars);
    }

    protected override void beforeUpdate(Trigger_ContextVariables trigContextVars, ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper) {
    }

    protected override void beforeDelete(Trigger_ContextVariables trigContextVars, ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper) {
    }

    protected override void afterInsert(Trigger_ContextVariables trigContextVars, ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper) {
        populateExternalID(trigContextVars);
    }

    protected override void afterUpdate(Trigger_ContextVariables trigContextVars, ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper) {
    }

    protected override void afterUndelete(Trigger_ContextVariables trigContextVars, ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper) {
    }
    
    /*******************************************************************************************************    
    * @description Prepopulate null external system id to avoid field validation error. 
    * @param trigContextVars Trigger Context Variables.
    * @return N/A.  
    */  
    private static void prepopulateExternalID(Trigger_ContextVariables trigContextVars) { 
        for(ucinn_ascendv2__Review_Transaction_v2__c rtv2 : (List<ucinn_ascendv2__Review_Transaction_v2__c>) trigContextVars.triggerNew){
            if(rtv2.ucinn_ascendv2__External_System_ID__c == null){
                rtv2.ucinn_ascendv2__External_System_ID__c = 'GNRL';
            }
        }
    }
    

    /*******************************************************************************************************    
    * @description For record type general auto populate external system id and name, must be after insert because nd_Review_Transaction_Auto_Number__c populates after. 
    * @param trigContextVars Trigger Context Variables.
    * @return N/A.  
    */  
    private static void populateExternalID(Trigger_ContextVariables trigContextVars) { 
        List<ucinn_ascendv2__Review_Transaction_v2__c> rtv2List;
        List<ucinn_ascendv2__Review_Transaction_v2__c> rtv2ToUpdate = new List<ucinn_ascendv2__Review_Transaction_v2__c>();
        Set<Id> rtv2Ids = new Set<Id>();

        for(ucinn_ascendv2__Review_Transaction_v2__c rtv2 : (List<ucinn_ascendv2__Review_Transaction_v2__c>) trigContextVars.triggerNew){
            rtv2Ids.add(rtv2.id);
        }
        rtv2List = [SELECT id, recordTypeId, nd_Review_Transaction_Auto_Number__c, ucinn_ascendv2__External_System_ID__c
                    FROM ucinn_ascendv2__Review_Transaction_v2__c
                    WHERE id IN: rtv2Ids];

        for(ucinn_ascendv2__Review_Transaction_v2__c rtv2 : rtv2List){
            if(rtv2.recordTypeId == Schema.SObjectType.ucinn_ascendv2__Review_Transaction_v2__c.getRecordTypeInfosByDeveloperName().get('General_Transaction').getRecordTypeId() &&
              	(rtv2.ucinn_ascendv2__External_System_ID__c == null || rtv2.ucinn_ascendv2__External_System_ID__c == 'GNRL')){
                
                rtv2.ucinn_ascendv2__External_System_ID__c = 'GNRL-' + rtv2.nd_Review_Transaction_Auto_Number__c;
                rtv2.Name = 'GNRL-' + rtv2.nd_Review_Transaction_Auto_Number__c;
                rtv2ToUpdate.add(rtv2);
            }
        }

        if(rtv2ToUpdate.size() != 0){
            ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger('ucinn_ascendv2__Review_Transaction_v2__c', false);
            update rtv2ToUpdate;
            ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger('ucinn_ascendv2__Review_Transaction_v2__c', true);
        }
    }
}