/**
 * @author jrizzi
 * @date 05/24/2021
 * @group Triggers
 * @description 
 */
trigger TRIG_Minor_code on ucinn_ascendv2__Minor_Code__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    ucinn_ascendv2.ascend_TDTM_GlobalAPI.run(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete,
  Trigger.isUnDelete, Trigger.new, Trigger.old, Schema.Sobjecttype.ucinn_ascendv2__Post_Code__c);
}