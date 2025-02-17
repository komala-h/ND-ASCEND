/**
 * @author jrizzi
 * @date 7/31/2023
 * @group Triggers
 * @description 
 */
trigger TRIG_ND_Geo_Group_Region on ND_Geo_Group_Region__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    ucinn_ascendv2.ascend_TDTM_GlobalAPI.run(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete,
  Trigger.isUnDelete, Trigger.new, Trigger.old, Schema.Sobjecttype.ND_Geo_Group_Region__c);
}