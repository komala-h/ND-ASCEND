global class nd_InvolvementTriggerHandlerCls extends ucinn_ascendv2.ascend_TDTM_Runnable {
    
    private ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper = new ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper();
        
    private static final string ADVISORY_COUNCIL_BOARD='Advisory_Council';
    private static final string Other_Involvements = 'Other_Involvements';
    private static final String ACCOUNT_INVOLVEMENT = 'Account_Involvement';
    private static final String STUDENT_ATHLETE = 'Student_Athlete';
    private static final String STUDENT_ACTIVITY = 'Student_Activity';
    private static final string ADVISORY_BOARD='ADB';  
    private static final string ADVISORY_COUNCIL='ADC';
    private static final string BOARD_OF_TRUSTEE='BOT';
    private static final string CAMPAIGN_CABINET='CC';
    private static final string UNIVERSITY_OFFICER_OFFICIAL='UNACD';
    private static final string Daily_List ='Daily List';
    private static final string ACTIVE = 'A';
    private static final string HONORARY = 'H';
    private static final string INVOLVEMENT  = 'I';
    private static final string Donor_Level  = 'D';
    private static final string MANUALLY_DESIGNATED  = 'M';
    private static Boolean ToAddVIPReason=false;
    private static Boolean ToDeleteVIPReason=false;
        
    global override ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, ucinn_ascendv2.ascend_TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        List<ucinn_ascendv2__Involvement__c> triggerNew = (List<ucinn_ascendv2__Involvement__c>) newList;
        List<ucinn_ascendv2__Involvement__c> triggerOld = (List<ucinn_ascendv2__Involvement__c>) oldList;
        
        Map<Id, ucinn_ascendv2__Involvement__c> triggerOldMap = new Map<Id, ucinn_ascendv2__Involvement__c>();
        if (triggerOld != null) {
            for (ucinn_ascendv2__Involvement__c inv : triggerOld) {
                triggerOldMap.put(inv.Id, inv);
            }
        }
        
        if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterInsert) {
            map<Id, Contact> constsToUpdate = constituentVIPCheck(triggerNew);
            suffixNDAffiliationsUpdate(triggerNew,constsToUpdate);
        }
        else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterUpdate) {
            map<Id, Contact> constsToUpdate = constituentVIPCheck(triggerNew);
            suffixNDAffiliationsUpdate(triggerNew,constsToUpdate);
        }
          else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeDelete) {
            PreventInvolvementDeletion(triggerOld);
        }   
        else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterDelete) {
            map<Id, Contact> constsToUpdate = constituentVIPCheck(triggerOld);
            suffixNDAffiliationsUpdate(triggerOld,constsToUpdate);

        }
        
        return dmlWrapper;
    }
    
    /*
    public static void afterInsert(List<ucinn_ascendv2__Involvement__c> newrecords){
        map<Id, Contact> constsToUpdate = constituentVIPCheck(newrecords);
        suffixNDAffiliationsUpdate(newrecords,constsToUpdate);
    }
    
    public static void afterUpdate(List<ucinn_ascendv2__Involvement__c> newrecords, map<id,ucinn_ascendv2__Involvement__c> oldmapRecords){
        map<Id, Contact> constsToUpdate = constituentVIPCheck(newrecords);
        suffixNDAffiliationsUpdate(newrecords,constsToUpdate);
    }

    public static void afterDelete(List<ucinn_ascendv2__Involvement__c> oldrecords){
        map<Id, Contact> constsToUpdate = constituentVIPCheck(oldrecords);
        suffixNDAffiliationsUpdate(oldrecords,constsToUpdate);
    }   
    
    */
    
    // To prevent users of certain profiles from deleting any Involvement  records
    public static void PreventInvolvementDeletion(list<ucinn_ascendv2__Involvement__c> triggerOld){
        String profileName = [SELECT Id,Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
        
        // Different profiles and their allowed record types
        Set<String> giftAndDataMgmtAllowedTypes = new Set<String>{STUDENT_ACTIVITY, ADVISORY_COUNCIL_BOARD, ACCOUNT_INVOLVEMENT, STUDENT_ATHLETE, OTHER_INVOLVEMENTS };        
            Set<String> advisoryCouncilAllowedTypes = new Set<String>{ADVISORY_COUNCIL_BOARD, OTHER_INVOLVEMENTS};
                Set<String> campaignAllowedTypes = new Set<String>{OTHER_INVOLVEMENTS};
                    
                    for (ucinn_ascendv2__Involvement__c involvement : triggerOld) {
                        String recordTypeDevName = involvement.nd_Record_Type_Dev_Name__c;
                        
                        // based on profile restrict deletion 
                        if (profileName == 'Gift and Data Mgmt') {
                            if (!giftAndDataMgmtAllowedTypes.contains(recordTypeDevName)) {
                                involvement.addError('You do not have permission to delete this Involvement.');
                            }
                        } else if (profileName == 'Advisory Council') {
                            if (!advisoryCouncilAllowedTypes.contains(recordTypeDevName)) {
                                involvement.addError('You do not have permission to delete this Involvement.');
                            }
                        } else if (profileName == 'Campaign') {
                            if (!campaignAllowedTypes.contains(recordTypeDevName)) {
                                involvement.addError('You do not have permission to delete this Involvement.');
                            }
                        }                         
                    }
    }

    //Method to update the Suffix_NDAffiliations on the Constituents
    public static void suffixNDAffiliationsUpdate(list<ucinn_ascendv2__Involvement__c> ndAffs,map<Id, Contact> constsToUpdate) {
        set<Id> constIds = new set<Id>();
     // map<Id, Contact> constsToUpdate = new map<Id, Contact>();
        if(constsToUpdate == null) {
            constsToUpdate = new map<Id, Contact>();
        }
        //Get the Constituent IDs
        Integer ndAffSize = ndAffs.size();
        for(Integer i = 0; i < ndAffSize; i++)
            constIds.add(ndAffs[i].ucinn_ascendv2__Contact__c);
        //Query for Constituents along with ND Affiliations
        list<Contact> contacts = [SELECT Id, nd_Suffix_ND_Affiliations__c, 
                                  (SELECT ND_BackendFieldCalForSuffixes__c,nd_Affiliation_Symbol__c,recordType.developername,ND_IsValidPeriodforSuffix__c FROM ucinn_ascendv2__Involvements_Contact__r WHERE recordType.developername In (:ADVISORY_COUNCIL_BOARD, :Other_Involvements) 
                                   AND ( ucinn_ascendv2__Status__c='A') AND nd_Affiliation_Symbol__c != null   
                                   AND nd_Affiliation_Symbol__c != '' ORDER BY nd_Hierarchy_Order__c ASC) 
                                  FROM Contact WHERE Id in: constIds and ucinn_ascendv2__Is_Deceased__c=false];
        system.debug('contacts '+contacts);
        Integer constSize = contacts.size();
        //Iterate over the Contacts
        for(Integer i = 0; i < constSize; i++) {
            Contact c = contacts[i];
            //If ND Affiliation Symbol is not Empty then add it to the Constituent Suffix_ND_Affiliations
            string affs = '';
            for(ucinn_ascendv2__Involvement__c ndAff : c.ucinn_ascendv2__Involvements_Contact__r) {
                if(((ndAff.recordType.developername ==ADVISORY_COUNCIL_BOARD && ndAff.ND_BackendFieldCalForSuffixes__c)||(ndAff.recordType.developername != ADVISORY_COUNCIL_BOARD)) && string.isNotEmpty(ndAff.nd_Affiliation_Symbol__c) && !affs.contains(ndAff.nd_Affiliation_Symbol__c))
                    affs += ndAff.nd_Affiliation_Symbol__c + ' ';
            } 
             system.debug('affs '+affs);
            //Remove any trailing spaces
            affs = affs.trim();
            if(!affs.equals(c.nd_Suffix_ND_Affiliations__c)) {
                if(constsToUpdate.containsKey(c.Id)) {
                    constsToUpdate.get(c.Id).nd_Suffix_ND_Affiliations__c = affs;
                }
                else {
                    constsToUpdate.put(c.Id, new Contact(Id = c.Id, nd_Suffix_ND_Affiliations__c = affs));
                }
            }
        }
        system.debug('constsToUpdate'+constsToUpdate);
  
        if(!constsToUpdate.isEmpty()) {
            update constsToUpdate.values();
        }
    } 
    
    //To update VIP and VIP reason on constituent
    public static map<id,contact> constituentVIPCheck(List<ucinn_ascendv2__Involvement__c> InvRecords){
        Integer InvRecordsSize = InvRecords.size();
        Set<Id> constIds = new Set<Id>();
        Set<Id> contactSpouseIDs = new Set<Id>();
        Set<Id> SpouseIDs = new Set<Id>();
        Map<Id, Contact> constsToUpdate = new map<Id, Contact>();
        Map<Id, Contact> constsToAddVIP = new map<Id, Contact>();
        Map<Id, Contact> constsToDeleteVIP = new map<Id, Contact>();
        Set<String> vipReasons = new Set<String>();
        
        // get the constituent Ids from Involvement records and store it in a set
        for(Integer i=0; i<InvRecordsSize;i++){
            constIds.add(InvRecords[i].ucinn_ascendv2__Contact__c);
        }
        
        //Query for the constituents which matches the criteria
        list<Contact> constituents = [SELECT Id,nd_SIG__c,ND_VIP__c, ND_VIP_Reason__c,ucinn_ascendv2__Preferred_Spouse__c,
                                        (SELECT Id, isDeleted,ucinn_ascendv2__Involvement_Type_Formula__c,ucinn_ascendv2__Status__c,ucinn_ascendv2__Contact__c 
                                         FROM ucinn_ascendv2__Involvements_Contact__r
                                         WHERE RecordType.developername IN (:ADVISORY_COUNCIL_BOARD, :Other_Involvements)
                                               AND RecordType.IsActive = true 
                                               AND (ucinn_ascendv2__Status__c = :ACTIVE OR ucinn_ascendv2__Status__c = :HONORARY)
                                               AND ucinn_ascendv2__Involvement_Type_Formula__c IN (:ADVISORY_BOARD, :ADVISORY_COUNCIL, :BOARD_OF_TRUSTEE, :CAMPAIGN_CABINET, :UNIVERSITY_OFFICER_OFFICIAL)
                                        ),
                                        ( SELECT id,ucinn_ascendv2__Service_Indicator_Value__r.Name 
                                          FROM ucinn_ascendv2__Service_Indicators_Contact__r 
                                          WHERE ucinn_ascendv2__Is_Active__c=true 
                                                AND ucinn_ascendv2__Service_Indicator_Value__r.Name =:Daily_List
                                        )
                                      FROM Contact
                                      WHERE Id in:constIds and ucinn_ascendv2__Is_Deceased__c=false
                                     ];
         system.debug('constituents'+constituents);
        //loop over the list of constituents and check whether VIP and VIP reasons needs to be updated or not
        for(Contact c:constituents){
            Boolean hasChanges = checkVIPStatus(c);
            if(hasChanges){
                constsToUpdate.put(c.id,c);
                if(ToAddVIPReason==true) 
                {
                    constsToAddVIP.put(c.id,c);
                    system.debug('constsToAddVIP'+constsToAddVIP);
                }
                if(ToDeleteVIPReason==true){
                    constsToDeleteVIP.put(c.id,c);
                    system.debug('constsToDeleteVIP'+constsToDeleteVIP);
                }
           }
        }
        
        // loop over the constituents to update SIG checkbox
        for(Contact c: constituents){
            c = checkSIGCheckbox(c);
            constsToUpdate.put(c.id,c);
        }
        
        // Get the household members records and update the VIP and add the VIP reason Involvement for them as well
        if(!constsToAddVIP.isEmpty()){
            contactSpouseIDs = getConstituents(constsToAddVIP.keyset());
            for(Contact Spousecon:[SELECT Id, ND_VIP__c, ND_VIP_Reason__c FROM Contact WHERE id in:contactSpouseIDs]){
                Spousecon.ND_VIP__c = true;
                if(Spousecon.ND_VIP_Reason__c!=Null){
                    Spousecon.ND_VIP_Reason__c = Spousecon.ND_VIP_Reason__c+';'+INVOLVEMENT;
                }
                else if(Spousecon.ND_VIP_Reason__c==Null) {
                    Spousecon.ND_VIP_Reason__c=INVOLVEMENT;
                }
                constsToUpdate.put(Spousecon.id,Spousecon);
            }
        }
        
        // to remove VIP reason Involvement from constituent and its spouse when the involvemnt status is neither Active or honorary
        if(!constsToDeleteVIP.isEmpty()){
            SpouseIDs = getConstituents(constsToDeleteVIP.keyset());
            for(Contact spouse:[SELECT Id, ND_VIP__c, ND_VIP_Reason__c FROM Contact WHERE id in:SpouseIDs]){
                if(spouse.ND_VIP_Reason__c != Null){
                    vipReasons = new set<String>(spouse.ND_VIP_Reason__c.split(';'));
                    if(vipReasons.contains(INVOLVEMENT) && spouse.ND_VIP__c==true && vipReasons.size()==1){
                        spouse.ND_VIP__c = false;
                        vipReasons.remove(INVOLVEMENT);
                        spouse.ND_VIP_Reason__c = String.join(new list<String>(vipReasons),';');
                    }
                    if(spouse.ND_VIP__c==true && (vipReasons.contains(Donor_Level) || vipReasons.contains(INVOLVEMENT) || vipReasons.contains(MANUALLY_DESIGNATED))) {
                        vipReasons.remove(INVOLVEMENT);
                        spouse.ND_VIP_Reason__c = String.join(new list<String>(vipReasons),';');
                    } 
                }
                constsToUpdate.put(spouse.id,spouse);
            }
        }
        return constsToUpdate;
    } 
    
    private static set<Id> getConstituents(Set<Id> conIds){
        Set<Id> SpouseIDs = new set<id>();
        list<Contact> conList = [SELECT Id, ND_VIP__c, ND_VIP_Reason__c,ucinn_ascendv2__Preferred_Spouse__c
                                 FROM Contact
                                 WHERE ID in:conIds AND account.recordtype.name='Household'];
        for(Contact con:conList){
            if(con.ucinn_ascendv2__Preferred_Spouse__c != NULL)
                    SpouseIDs.add(con.ucinn_ascendv2__Preferred_Spouse__c);
        }
        return SpouseIDs;
    }
    
    private static Boolean checkVIPStatus(Contact con){
        Boolean hasChanges = False;
        Set<String> vipReasons = new Set<String>();
        Set<String> InvContactsStatuses = new Set<String>();
        
        //store the VIP reasons values of the constituent in a set
        if(con.ND_VIP_Reason__c !=Null){
            vipReasons = new set<String>(con.ND_VIP_Reason__c.split(';'));
        }
        else{
            con.ND_VIP_Reason__c='';
        }
        
        // Get the Involvement records associated with the contact
        list<ucinn_ascendv2__Involvement__c> invContacts = con.ucinn_ascendv2__Involvements_Contact__r;
        
        //Store the Involvment status of all Involvement records of that contact into a set
        for(ucinn_ascendv2__Involvement__c inv:invContacts){
            if(  inv.ucinn_ascendv2__Involvement_Type_Formula__c == ADVISORY_COUNCIL || 
                 inv.ucinn_ascendv2__Involvement_Type_Formula__c == BOARD_OF_TRUSTEE ||
                 inv.ucinn_ascendv2__Involvement_Type_Formula__c == ADVISORY_BOARD )
            InvContactsStatuses.add(inv.ucinn_ascendv2__Status__c);
        }
        
        //Update the VIP and VIP Reason of constituent only if any of the involvement records of it has 'Active' or 'Honorary' as status
        if(InvContactsStatuses.contains(ACTIVE) ||InvContactsStatuses.contains(HONORARY) ){
            if((!con.ND_VIP__c)  || (!vipReasons.contains(INVOLVEMENT))){
                con.ND_VIP__c = true;
                con.ND_VIP_Reason__c = con.ND_VIP_Reason__c+';'+INVOLVEMENT;
                hasChanges = true;
                ToAddVIPReason = true; 
            }
        }
        else{
            if(con.ND_VIP__c==true && vipReasons.contains(INVOLVEMENT) && vipReasons.size()==1 ){
                con.ND_VIP__c = false;
                vipReasons.remove(INVOLVEMENT);
                con.ND_VIP_Reason__c = String.join(new list<String>(vipReasons),';');
                hasChanges = true;
                ToDeleteVIPReason = true;
            }
            if(con.ND_VIP__c==true && (vipReasons.contains(Donor_Level) || vipReasons.contains(INVOLVEMENT) || vipReasons.contains(MANUALLY_DESIGNATED)) ) {
                vipReasons.remove(INVOLVEMENT);
                con.ND_VIP_Reason__c = String.join(new list<String>(vipReasons),';');
                hasChanges = true;
                ToDeleteVIPReason = true;
            }            
        }
        return hasChanges;
    }
    
    private static contact checkSIGCheckbox(contact c){
        List<ucinn_ascendv2__Involvement__c> involvementRecords = c.ucinn_ascendv2__Involvements_Contact__r;
        List<ucinn_ascendv2__Service_Indicator__c> serviceRecords = c.ucinn_ascendv2__Service_Indicators_Contact__r;
        c.nd_SIG__c = false;
        
        for(Integer i=0;i<involvementRecords.size();i++){
            ucinn_ascendv2__Involvement__c record = involvementRecords[i];
            if( (!record.isDeleted ) && record.ucinn_ascendv2__Status__c== ACTIVE && ( record.ucinn_ascendv2__Involvement_Type_Formula__c == ADVISORY_COUNCIL || 
                  record.ucinn_ascendv2__Involvement_Type_Formula__c == BOARD_OF_TRUSTEE || record.ucinn_ascendv2__Involvement_Type_Formula__c == CAMPAIGN_CABINET   ||
                  record.ucinn_ascendv2__Involvement_Type_Formula__c == UNIVERSITY_OFFICER_OFFICIAL ))
            {
                c.nd_SIG__c = true;
            } 
        }
        return c;
    }
        
}