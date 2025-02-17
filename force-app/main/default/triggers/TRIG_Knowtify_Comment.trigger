/**
 * @author jrizzi
 * @date 09/23/2022
 * @group Triggers
 * @description 
 */
trigger TRIG_Knowtify_Comment on Knowtify_Comment__c(after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    ucinn_ascendv2.ascend_TDTM_GlobalAPI.run(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete,
  Trigger.isUnDelete, Trigger.new, Trigger.old, Schema.Sobjecttype.Knowtify_Comment__c);
}