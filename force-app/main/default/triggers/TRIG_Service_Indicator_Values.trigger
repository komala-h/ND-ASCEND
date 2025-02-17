/**
 * @author jrizzi
 * @date 10/09/2023
 * @group Triggers
 * @description 
 */
trigger TRIG_Service_Indicator_Values on ucinn_ascendv2__Service_Indicator_Value__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    ucinn_ascendv2.ascend_TDTM_GlobalAPI.run(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete,
  Trigger.isUnDelete, Trigger.new, Trigger.old, Schema.Sobjecttype.ucinn_ascendv2__Service_Indicator_Value__c);
}