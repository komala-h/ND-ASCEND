/**
 * @author Sulung Chandra, UC Innovation
 * @date 4/19/2021
 * @group Trigger Handlers
 * @description Handler class for Constituent Name Trigger
 */
global class asc_TRIG_ConstituentNameHandler extends ucinn_ascendv2.ascend_TDTM_Runnable {

    public static boolean hasSalutationsExecuted = false;
    private ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper = new ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper();
    
    /*******************************************************************************************************
     * @description Overridden method that handles the trigger actions and calls the relevant logic
     * @return The dmlWrapper with any sObjects to be inserted/updated/deleted
     */
    global override ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, ucinn_ascendv2.ascend_TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        List<ucinn_ascendv2__Contact_Name__c> triggerNew = (List<ucinn_ascendv2__Contact_Name__c>) newList;
        List<ucinn_ascendv2__Contact_Name__c> triggerOld = (List<ucinn_ascendv2__Contact_Name__c>) oldList;

        Map<Id, ucinn_ascendv2__Contact_Name__c> triggerOldMap = new Map<Id, ucinn_ascendv2__Contact_Name__c>();
        if (triggerOld != null) {
            for (ucinn_ascendv2__Contact_Name__c cn : triggerOld) {
                triggerOldMap.put(cn.Id, cn);
            }
        }

        if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeInsert) {
            updateFullNameRecord(triggerNew);
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterInsert) {
            updateNameFields(triggerNew);
            setupSalutations(triggerNew, triggerOldMap);
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeUpdate) {
            
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterUpdate) {
            updateNameFields(triggerNew);
            setupSalutations(triggerNew, triggerOldMap);
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeDelete) {
            
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterDelete) {
            
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterUndelete) {
            
        }
        
        return dmlWrapper;
    }

        /*******************************************************************************************************
     * @description Method to update constituent Name on insert
     * @param triggerNew The list of newly updated Constituent Name
     * @return N/A
     */
    private void updateFullNameRecord(List<ucinn_ascendv2__Contact_Name__c> triggerNew) {
        List<ucinn_ascendv2__Contact_Name__c> cnList = new List<ucinn_ascendv2__Contact_Name__c>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        Set<Id> contactSet = new Set<Id>();
        
        for (ucinn_ascendv2__Contact_Name__c cn : triggerNew) {
            if (cn.ucinn_ascendv2__Type__c == 'Full Name') {
                cnList.add(cn);
                contactSet.add(cn.ucinn_ascendv2__Contact__c);
            }
        }
        
        if (!contactSet.isEmpty()) {
            for (Contact con : [Select Id, Nickname__c From Contact Where Id In :contactSet]) {
                contactMap.put(con.Id, con);
            }
            
            for (ucinn_ascendv2__Contact_Name__c cn : cnList) {
                if (contactMap.containsKey(cn.ucinn_ascendv2__Contact__c)) {
                    Contact con = contactMap.get(cn.ucinn_ascendv2__Contact__c);
                    cn.ucinn_ascendv2__Nickname__c = con.Nickname__c;
                }
            }
        }
    }
    
    /*******************************************************************************************************
     * @description Method to setup Salutations
     * @param triggerNew The list of newly updated Constituent Name
     * @param triggerOldMap The map of the old versions of the newly updated Constituent Names
     * @return N/A
     */
    private void setupSalutations(List<ucinn_ascendv2__Contact_Name__c> triggerNew, Map<Id, ucinn_ascendv2__Contact_Name__c> triggerOldMap) {
        List<ucinn_ascendv2__Contact_Name__c> cnList = new List<ucinn_ascendv2__Contact_Name__c>();
        Set<Id> contactSet = new Set<Id>();
        
        // Collect contacts to evaluate
        if (Trigger.isInsert) {
            for (ucinn_ascendv2__Contact_Name__c cn : triggerNew) {
                if (cn.ucinn_ascendv2__Type__c == 'Full Name') {
                    cnList.add(cn);
                    contactSet.add(cn.ucinn_ascendv2__Contact__c);
                }
            }
        } else if (Trigger.isUpdate) {
            for (ucinn_ascendv2__Contact_Name__c cn : triggerNew) {
                if (cn.ucinn_ascendv2__Type__c == 'Full Name' && (
                        cn.ucinn_ascendv2__Prefix__c != triggerOldMap.get(cn.Id).ucinn_ascendv2__Prefix__c ||
                        cn.ucinn_ascendv2__First_Name__c != triggerOldMap.get(cn.Id).ucinn_ascendv2__First_Name__c ||
                        cn.ucinn_ascendv2__Last_Name__c != triggerOldMap.get(cn.Id).ucinn_ascendv2__Last_Name__c ||
                        cn.ucinn_ascendv2__Nickname__c != triggerOldMap.get(cn.Id).ucinn_ascendv2__Nickname__c)) {
                    cnList.add(cn);
                    contactSet.add(cn.ucinn_ascendv2__Contact__c);
                }
            }
        }
        
        if (!contactSet.isEmpty() && !hasSalutationsExecuted) {
            Map<Id, Map<String, Object>> contactData = asc_UTIL_ContactHelper.getContactData(contactSet);
            asc_UTIL_ContactHelper.setupSalutations(contactData);
            hasSalutationsExecuted = true;
        }
    }
    
    /*******************************************************************************************************
     * @description Add this logic to update other name field since we override the name logic on package extension
     * @param triggerNew The list of newly updated Constituent Names
     * @param triggerOldMap The map of the old versions of the newly updated Constituent Names
     * @return N/A
     */
    private void updateNameFields(List<ucinn_ascendv2__Contact_Name__c> trigger_new) {
        List<ucinn_ascendv2__Contact_Name__c> cnList = new List<ucinn_ascendv2__Contact_Name__c>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        Set<Id> contactSet = new Set<Id>();
        List<Contact> updateContactList = new List<Contact>();
        
        for (ucinn_ascendv2__Contact_Name__c cn : trigger_new) {
            cnList.add(cn);
            contactSet.add(cn.ucinn_ascendv2__Contact__c);
        }
        
        if (!contactSet.isEmpty()) {
            for (Contact con : [Select Id, ucinn_ascendv2__Is_Name_Overridden__c, Salutation, FirstName, MiddleName, LastName, Suffix, ucinn_ascendv2__Professional_Designation__c, Nickname__c 
                    From Contact Where Id In :contactSet]) {
                contactMap.put(con.Id, con);
            }
            
            for (ucinn_ascendv2__Contact_Name__c cn : cnList) {
                if (contactMap.containsKey(cn.ucinn_ascendv2__Contact__c)) {
                    Contact con = contactMap.get(cn.ucinn_ascendv2__Contact__c);
                    if (cn.ucinn_ascendv2__Type__c == 'Full Name' && !con.ucinn_ascendv2__Is_Name_Overridden__c) {
                        
                        if (con.Salutation == cn.ucinn_ascendv2__Prefix__c && con.FirstName == cn.ucinn_ascendv2__First_Name__c && con.MiddleName == cn.ucinn_ascendv2__Middle_Name__c && 
                                con.LastName == cn.ucinn_ascendv2__Last_Name__c && con.Suffix == cn.ucinn_ascendv2__Suffix__c && con.Nickname__c == cn.ucinn_ascendv2__Nickname__c && 
                                con.ucinn_ascendv2__Professional_Designation__c == cn.ucinn_ascendv2__Professional_Designation__c) {
                            continue;
                        }
                        
                        con.Salutation = cn.ucinn_ascendv2__Prefix__c;
                        con.FirstName = cn.ucinn_ascendv2__First_Name__c;
                        con.MiddleName = cn.ucinn_ascendv2__Middle_Name__c;
                        con.LastName = cn.ucinn_ascendv2__Last_Name__c;
                        con.Suffix = cn.ucinn_ascendv2__Suffix__c;
                        con.ucinn_ascendv2__Professional_Designation__c = cn.ucinn_ascendv2__Professional_Designation__c;
                        con.Nickname__c = cn.ucinn_ascendv2__Nickname__c;
                        updateContactList.add(con);
                    }
                }
            }
        }
        
        if (updateContactList.size() > 0) {
            Update updateContactList;
        }
    }
}