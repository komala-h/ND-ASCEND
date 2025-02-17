/**
 * @author jrizzi
 * @date 06/28/2021
 * @group Triggers
 * @description 
 */
trigger TRIG_Work_Plan_Unit on ucinn_ascendv2__Work_Plan_Unit__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    ucinn_ascendv2.ascend_TDTM_GlobalAPI.run(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete,
  Trigger.isUnDelete, Trigger.new, Trigger.old, Schema.Sobjecttype.ucinn_ascendv2__Work_Plan_Unit__c);
}