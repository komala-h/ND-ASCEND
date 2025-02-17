trigger HardAndSoftcredit on ucinn_ascendv2__Hard_and_Soft_Credit__c (Before Insert, Before Update,before delete, after Insert, after update,after delete, after undelete) {

    ucinn_ascendv2.ascend_TDTM_GlobalAPI.run(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete,
    Trigger.isUnDelete, Trigger.new, Trigger.old, Schema.Sobjecttype.ucinn_ascendv2__Hard_and_Soft_Credit__c);
    
    
  /*  if(trigger.isBefore){
        if(trigger.isInsert){
            Nd_HardandSoftCreditTriggerHandler.beforeInsert(trigger.new);
        }
        if(trigger.isUpdate){
            Nd_HardandSoftCreditTriggerHandler.beforeUpdate(trigger.new,trigger.newMap);
        }
    }
    */
}