trigger nd_SocietyMembershipTrigger on ucinn_ascendv2__Society_Membership__c ( after insert,after Update,after delete,after undelete, before insert, before update, before delete) {
    ucinn_ascendv2.ascend_TDTM_GlobalAPI.run(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete,
    Trigger.isUnDelete, Trigger.new, Trigger.old, Schema.Sobjecttype.ucinn_ascendv2__Society_Membership__c);

    /*
    if(trigger.isAfter){
        if(trigger.isInsert){
        nd_SocietyMembershipTriggerHandler.afterInsert(trigger.new);
        }
        if(trigger.isUpdate){
        nd_SocietyMembershipTriggerHandler.afterUpdate(trigger.new,trigger.oldMap);
        }
        if(trigger.isdelete){
        nd_SocietyMembershipTriggerHandler.afterDelete(trigger.old);
        }
    }
    */
}