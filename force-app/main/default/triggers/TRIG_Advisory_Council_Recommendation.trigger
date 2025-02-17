/**
 * @author jrizzi
 * @date 9/25/2023
 * @group Triggers
 * @description 
 */
trigger TRIG_Advisory_Council_Recommendation on ND_Advisory_Council_Recommendation__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    ucinn_ascendv2.ascend_TDTM_GlobalAPI.run(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete,
  Trigger.isUnDelete, Trigger.new, Trigger.old, Schema.Sobjecttype.ND_Advisory_Council_Recommendation__c);
}