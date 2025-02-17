/**
 * @author jrizzi
 * @date 09/21/2021
 * @group Triggers
 * @description 
 */
trigger TRIG_Foundation_Funding_Interest on ucinn_ascendv2__Foundation_Funding_Interests__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    ucinn_ascendv2.ascend_TDTM_GlobalAPI.run(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete,
  Trigger.isUnDelete, Trigger.new, Trigger.old, Schema.Sobjecttype.ucinn_ascendv2__Foundation_Funding_Interests__c);
}