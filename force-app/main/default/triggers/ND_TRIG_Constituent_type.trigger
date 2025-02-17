trigger ND_TRIG_Constituent_type on Contact (before update, before insert,before delete, after insert, after update, after delete, after undelete) {
    
    ucinn_ascendv2.ascend_TDTM_GlobalAPI.run(Trigger.isBefore, Trigger.isAfter, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete,
    Trigger.isUnDelete, Trigger.new, Trigger.old, Schema.Sobjecttype.Contact);
    
    /*
    if( Trigger.isBefore ){
        if(trigger.isInsert) {  
            ND_Constituent_Type_Trigger_Handler.beforeInsert(trigger.newMap);
        }

        if(trigger.isUpdate) {  
            ND_Constituent_Type_Trigger_Handler.beforeUpdate(trigger.newMap, trigger.oldMap);
        }
    }

    if(trigger.isAfter) {
        if(trigger.isInsert) {  
            ND_Constituent_Type_Trigger_Handler.afterInsert(trigger.newMap);
        }
        if(trigger.isUpdate) {  
            ND_Constituent_Type_Trigger_Handler.afterUpdate(trigger.newMap, trigger.oldMap);
        }
        if(trigger.isDelete) {
            ND_Constituent_Type_Trigger_Handler.afterDelete(trigger.oldMap);
        }
        if(trigger.isUndelete) {  
            ND_Constituent_Type_Trigger_Handler.afterUndelete(trigger.newMap);
        }
    }
    */
}