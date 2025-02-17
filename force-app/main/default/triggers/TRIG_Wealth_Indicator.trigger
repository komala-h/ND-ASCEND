/**
 * @author jrizzi
 * @date 1/13/2023
 * @group Triggers
 * @description 
 */
trigger TRIG_Wealth_Indicator on Wealth_Indicator__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    ucinn_ascendv2.ascend_TDTM_GlobalAPI.run(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete,
  Trigger.isUnDelete, Trigger.new, Trigger.old, Schema.Sobjecttype.Wealth_Indicator__c);
}