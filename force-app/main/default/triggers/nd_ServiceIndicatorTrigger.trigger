trigger nd_ServiceIndicatorTrigger on ucinn_ascendv2__Service_Indicator__c (after insert,after update,after delete,after undelete, before delete, before insert, before update) {
  
    ucinn_ascendv2.ascend_TDTM_GlobalAPI.run(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete,
    Trigger.isUnDelete, Trigger.new, Trigger.old, Schema.Sobjecttype.ucinn_ascendv2__Service_Indicator__c);
    
    /*
  if(trigger.isAfter){
      if(trigger.isinsert)
          nd_ServiceIndicatorTriggerHandlerCls.afterInsert(trigger.new);
      if(trigger.isUpdate)
          nd_ServiceIndicatorTriggerHandlerCls.afterUpdate(trigger.new, trigger.oldmap);
      if(trigger.isdelete)
          nd_ServiceIndicatorTriggerHandlerCls.afterdelete(trigger.old);
  }
  */
}