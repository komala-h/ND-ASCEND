/**
 * @author jrizzi
 * @date 3/4/2023
 * @group Triggers
 * @description 
 */
trigger TRIG_Lottery_Application on Lottery_Application__c   (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    ucinn_ascendv2.ascend_TDTM_GlobalAPI.run(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete,
  Trigger.isUnDelete, Trigger.new, Trigger.old, Schema.Sobjecttype.Lottery_Application__c);
}