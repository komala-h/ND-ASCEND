global class nd_SocietyMembershipTriggerHandler extends ucinn_ascendv2.ascend_TDTM_Runnable {

    private ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper = new ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper();
    
    global override ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, ucinn_ascendv2.ascend_TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
    	List<ucinn_ascendv2__Society_Membership__c> triggerNew = (List<ucinn_ascendv2__Society_Membership__c>) newList;
        List<ucinn_ascendv2__Society_Membership__c> triggerOld = (List<ucinn_ascendv2__Society_Membership__c>) oldList;
        
        Map<Id, ucinn_ascendv2__Society_Membership__c> triggerOldMap = new Map<Id, ucinn_ascendv2__Society_Membership__c>();
        if (triggerOld != null) {
            for (ucinn_ascendv2__Society_Membership__c soc : triggerOld) {
                triggerOldMap.put(soc.Id, soc);
            }
        }
        
        if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterInsert) {
            organizationsocietySuffix(triggerNew);
        	societiySuffix(triggerNew); 
        }
        else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterUpdate) {
            organizationsocietySuffix(triggerNew);
        	societiySuffix(triggerNew);
        }
        else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterDelete) {
            organizationsocietySuffix(triggerOld);
        	societiySuffix(triggerOld);
        }
        
        return dmlWrapper;
    }
    
    /*
    public static void afterInsert(List<ucinn_ascendv2__Society_Membership__c> newRecords){
        organizationsocietySuffix(newRecords);
        societiySuffix(newRecords); 
    }
    
    public static void afterUpdate(List<ucinn_ascendv2__Society_Membership__c> newRecords, map<id,ucinn_ascendv2__Society_Membership__c> oldMapRecord){
        organizationsocietySuffix(newRecords);
        societiySuffix(newRecords);
    }
    
    public static void afterdelete(List<ucinn_ascendv2__Society_Membership__c> oldRecords){
        organizationsocietySuffix(oldRecords);
        societiySuffix(oldRecords);       
    }   
    */
    // Household society suffix
    public static void organizationsocietySuffix(List<ucinn_ascendv2__Society_Membership__c> newRecords){
        map<id,Account> accToUpdate = new map<id,Account>();
        List<Id> accIds = new List<id>();
        for(ucinn_ascendv2__Society_Membership__c m: newRecords){
            if(m.ucinn_ascendv2__Account__c!=null)
            accIds.add(m.ucinn_ascendv2__Account__c);
        }     
    list<Account> Accounts = [SELECT Id, nd_Suffix_Giving_Societies__c, 
                              (SELECT Id, nd_Affiliation_Symbol__c FROM ucinn_ascendv2__Society_Memberships_Account__r WHERE nd_Affiliation_Symbol__c != null AND nd_Affiliation_Symbol__c != '' AND 
                               nd_Status__c = 'A' ORDER BY nd_Hierarchy_Order__c asc) 
                              FROM Account WHERE Id IN: accIds ];
    Integer conSize = Accounts.size();
    //Iterate over household
    for(Integer i = 0; i < conSize; i++) {
        Account c = Accounts[i];
        //If Affiliation Symbol is not Empty then add it to the Constituent Suffix_Giving_Societies
        string societies = '';
        for(ucinn_ascendv2__Society_Membership__c rsm : c.ucinn_ascendv2__Society_Memberships_Account__r) {
            if(string.isNotEmpty(rsm.nd_Affiliation_Symbol__c) && !societies.contains(rsm.nd_Affiliation_Symbol__c)){
                societies += rsm.nd_Affiliation_Symbol__c + ' ';
            }
        }
        //Remove any trailing spaces
        societies = societies.trim();
        if(!societies.equals(c.nd_Suffix_Giving_Societies__c)){
            accToUpdate.put(c.Id,new account(Id = c.Id, nd_Suffix_Giving_Societies__c = societies));
        }
    }
        if(accToUpdate.size()>0)
            update accToUpdate.values();
    } 
    
    // constituent society suffix
    public static void societiySuffix(List<ucinn_ascendv2__Society_Membership__c> newRecords){
        map<id,contact> constsToUpdate = new map<id,contact>();
        List<Id> constIds = new List<id>();
        for(ucinn_ascendv2__Society_Membership__c m: newRecords){
            if(m.ucinn_ascendv2__Contact__c!=null)
            constIds.add(m.ucinn_ascendv2__Contact__c);
        }     
    list<Contact> contacts = [SELECT Id, nd_Suffix_Giving_Societies__c, 
                              (SELECT Id, nd_Affiliation_Symbol__c FROM ucinn_ascendv2__Society_Memberships_Contact__r WHERE nd_Affiliation_Symbol__c != null AND nd_Affiliation_Symbol__c != '' AND 
                               nd_Status__c = 'A' ORDER BY nd_Hierarchy_Order__c asc) 
                              FROM Contact WHERE Id IN: constIds and ucinn_ascendv2__Is_Deceased__c=false];
    Integer conSize = contacts.size();
    //Iterate over Constituents
    for(Integer i = 0; i < conSize; i++) {
        Contact c = contacts[i];
        //If Affiliation Symbol is not Empty then add it to the Constituent Suffix_Giving_Societies
        string societies = '';
        for(ucinn_ascendv2__Society_Membership__c rsm : c.ucinn_ascendv2__Society_Memberships_Contact__r) {
            if(string.isNotEmpty(rsm.nd_Affiliation_Symbol__c) && !societies.contains(rsm.nd_Affiliation_Symbol__c)){
                societies += rsm.nd_Affiliation_Symbol__c + ' ';
            }
        }
        //Remove any trailing spaces
        societies = societies.trim();
        if(!societies.equals(c.nd_Suffix_Giving_Societies__c)){
            constsToUpdate.put(c.Id,new Contact(Id = c.Id, nd_Suffix_Giving_Societies__c = societies));
        }
    }
        if(constsToUpdate.size()>0)
            update constsToUpdate.values();
    }
}