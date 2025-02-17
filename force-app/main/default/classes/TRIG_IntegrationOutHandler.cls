/**
 * Contact trigger Handler class
 * 
 * @author  jrizzi
 * @version  1.1, 2021-04-14
 * @since  1.0
 */
global class TRIG_IntegrationOutHandler extends ucinn_ascendv2.ascend_TDTM_Runnable {
  private ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper = new ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper();

  /*******************************************************************************************************
   * @description Overridden method that handles the trigger actions and calls the relevant logic
   * @return The dmlWrapper with any sObjects to be inserted/updated/deleted
   */
  global override ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, ucinn_ascendv2.ascend_TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
    List<sObject> triggerNew = (List<sObject>) newList;
    List<sObject> triggerOld = (List<sObject>) oldList;

    Map<Id, sObject> triggerOldMap = new Map<Id, sObject>();
    if (triggerOld != null) {
      for (sObject con : triggerOld) {
        triggerOldMap.put(con.Id, con);
      }
    }

    if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeInsert) {

    } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterInsert) {
     	Integration_Out_Class.InsertNewRecord(Trigger.New);
    } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeUpdate) {
         
    } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterUpdate) {
        Integration_Out_Class.UpdateRecord(Trigger.New);      
    } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeDelete) {
    
    } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterDelete) {
		Integration_Out_Class.DeleteRecord(Trigger.Old);
    } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterUndelete) {
		Integration_Out_Class.InsertNewRecord(Trigger.New);
    }   

    return dmlWrapper;
  }
  /**
   * This method can be called by the above trig if/else
   * @param triggerNew list of new Affiliation records
   */
    /* placeholder
  private void setPrimaryToTrueIfCurrent(List<Contact> triggerNew) {
    
  }*/

  
}