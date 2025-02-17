/**
 * @author jrizzi
 * @date 12/12/2022
 * @group Triggers
 * @description 
 */
trigger TRIG_Clipboard_Saved_List on ucinn_ascendv2__Clipboard_Saved_List__c  (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    ucinn_ascendv2.ascend_TDTM_GlobalAPI.run(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete,
  Trigger.isUnDelete, Trigger.new, Trigger.old, Schema.Sobjecttype.ucinn_ascendv2__Clipboard_Saved_List__c);
}