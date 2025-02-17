trigger nd_DegreeInformationTrigger on ucinn_ascendv2__Degree_Information__c (after Insert,after Update,after delete,after undelete, before insert,before update, before delete) {
    
    ucinn_ascendv2.ascend_TDTM_GlobalAPI.run(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete,
    Trigger.isUnDelete, Trigger.new, Trigger.old, Schema.Sobjecttype.ucinn_ascendv2__Degree_Information__c);
    
   /* 
    if(trigger.isAfter){
        if(trigger.isInsert){
            nd_DegreeInformationHandlerCls.afterInsert(trigger.new);
        }
        if(trigger.isUpdate){
              nd_DegreeInformationHandlerCls.afterUpdate(trigger.new,trigger.oldMap);   
        }
       if(trigger.isDelete){
              nd_DegreeInformationHandlerCls.afterdelete(trigger.old);   
        }
    }
    */
}