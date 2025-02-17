trigger InvolvementTrigger on ucinn_ascendv2__Involvement__c (after insert, after update, after delete,after undelete,before delete, before insert, before update) {
    
  ucinn_ascendv2.ascend_TDTM_GlobalAPI.run(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete,
  Trigger.isUnDelete, Trigger.new, Trigger.old, Schema.Sobjecttype.ucinn_ascendv2__Involvement__c);
/*
   if(trigger.isAfter) {
        if(trigger.isInsert) {  
            nd_InvolvementTriggerHandlerCls.afterInsert(trigger.new);
        }
        if(trigger.isUpdate) {  
            nd_InvolvementTriggerHandlerCls.afterUpdate(trigger.new, trigger.oldMap);
        }
        if(trigger.isDelete) {
            nd_InvolvementTriggerHandlerCls.afterDelete(trigger.old);
        }

    }
*/
}