/**
 * @author jrizzi
 * @date 1/23/2023
 * @group Triggers
 * @description 
 */
trigger TRIG_Seat_Lot_Assignment on Seat_Lot_Assignment__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    ucinn_ascendv2.ascend_TDTM_GlobalAPI.run(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete,
  Trigger.isUnDelete, Trigger.new, Trigger.old, Schema.Sobjecttype.Seat_Lot_Assignment__c);
}