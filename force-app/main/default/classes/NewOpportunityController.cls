/**
 * @author UC Innovation
 * @date 11/7/2021
 * @group LWC Controller
 * @description Controller for LWC Components
 */
public with sharing class NewOpportunityController {
    
    /**
    * Method to get Account record
    * @param accountId Account record Id
    * @return Account record 
    */
    @AuraEnabled
    public static Account getAccount(String accountId) {
        List<Account> accList = [Select Id, Name, ucinn_ascendv2__PRM__c From Account Where Id = :accountId];
        if (!accList.isEmpty()) {
            return accList[0];
        }
        return null;
    }

    /**
    * Method to get Strategy record
    * @param strategyId Strategy record Id
    * @return strategy record 
    */
    @AuraEnabled
    public static ucinn_ascendv2__Strategy__c getStrategy(String strategyId) {
        List<ucinn_ascendv2__Strategy__c> strategyList = [Select Id, Name, ucinn_ascendv2__Account__c, ucinn_ascendv2__Account__r.ucinn_ascendv2__PRM__c From ucinn_ascendv2__Strategy__c Where Id = :strategyId];
        if (!strategyList.isEmpty()) {
            return strategyList[0];
        }
        return null;
    }

    /**
    * Method to get current Comprehensive Campaign record
    * @return campaign record 
    */
    @AuraEnabled
    public static Campaign getCurrentComprehensiveCampaign() {
        List<Campaign> campaignList = [Select Id, Name From Campaign Where RecordType.DeveloperName = 'Comprehensive_Campaign' And StartDate <= :System.Today() And (EndDate = null Or EndDate >= :System.Today()) LiMIT 1];

        if (!campaignList.isEmpty()) {
            return campaignList[0];
        }
        return null;
    }

    /**
    * Method to get field help text
    * @return text
    */
    @AuraEnabled
    public static String getFieldHelpText(String sobjectName, String fieldName) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(sobjectName);
        Schema.SObjectField targetField = targetType.getDescribe().fields.getMap().get(fieldName);
        return targetField.getDescribe().getInlineHelpText();
    }

    /**
    * Method to save the Opportunity and related records
    * @param oppRec Opportunity record
    * @param subproposals Sub Proposal list
    * @param oppteammembers Opportunity Team Member list
    * @param oppcontactroles Opportunity contact role list
    * @return 
    */
    @AuraEnabled
    public static Map<String, String> saveOpportunity(Map<String, Object> opp, List<Map<String, Object>> subproposals, List<Map<String, Object>> oppteammembers, List<Map<String, Object>> oppcontactroles) {
        String KEY_OPPORTUNITYID = 'OpportunityId';
        String KEY_ERRORMESSAGE = 'ErrorMessage';
        List<String> errmsgList = new List<String>();
        List<Id> prmUserIdList = new List<Id>();
        List<String> prmUserRoleList = new List<String>();
        List<String> prmGroupRegionList = new List<String>();
        Map<String, String> ret = new Map<String, String>();
        Boolean hasSubProposalPlannedGift = false;

        ret.put(KEY_OPPORTUNITYID,'');

        Savepoint sp = Database.setSavepoint();
            
        try {
            List<Sub_Proposal__c> insertSubproposalList = new List<Sub_Proposal__c>();
            List<OpportunityTeamMember> inserOppTeamMemberList = new List<OpportunityTeamMember>();
            List<OpportunityContactRole> oppContactRoleList = new List<OpportunityContactRole>();
            Set<Id> fundingPrioritySet = new Set<Id>();

            Opportunity newopp = new Opportunity();
            newopp.Name = generateRandomString(20);
            newopp.Description = (String)opp.get('Description');
            newopp.Type = (String)opp.get('Type');
            newopp.StageName = (String)opp.get('StageName');
            if (opp.get('RecordTypeId') != null) {
                newopp.RecordTypeId =  (Id)opp.get('RecordTypeId');
            }
            if (opp.get('AccountId') != null) {
                newopp.AccountId =  (Id)opp.get('AccountId');
            }
            if (opp.get('CampaignId') != null) {
                newopp.CampaignId =  (Id)opp.get('CampaignId');
            }
            if (opp.get('nd_Likelihood_to_Close__c') != null) {
                newopp.nd_Likelihood_to_Close__c = Decimal.valueOf((String)opp.get('nd_Likelihood_to_Close__c'));
                newopp.Probability = newopp.nd_Likelihood_to_Close__c;
            }
            if (opp.get('nd_Research_Award_Number__c') != null) {
                newopp.nd_Research_Award_Number__c = (String)opp.get('nd_Research_Award_Number__c');
            }
            if (opp.get('ucinn_ascendv2__Expected_Close_Date__c') != null) {
                newopp.ucinn_ascendv2__Expected_Close_Date__c = Date.valueOf((String)opp.get('ucinn_ascendv2__Expected_Close_Date__c'));
                newopp.CloseDate = newopp.ucinn_ascendv2__Expected_Close_Date__c;
            }
            if (opp.get('ucinn_ascendv2__Submitted_Date__c') != null) {
                newopp.ucinn_ascendv2__Submitted_Date__c = Date.valueOf((String)opp.get('ucinn_ascendv2__Submitted_Date__c'));
            }
            if (opp.get('ucinn_ascendv2__Submitted_Amount__c') != null) {
                newopp.ucinn_ascendv2__Submitted_Amount__c = (Decimal)opp.get('ucinn_ascendv2__Submitted_Amount__c');
                newopp.Amount = newopp.ucinn_ascendv2__Submitted_Amount__c;
            }
            if (opp.get('nd_Answer_Amount__c') != null) {
                newopp.nd_Answer_Amount__c = (Decimal)opp.get('nd_Answer_Amount__c');
                newopp.Amount = newopp.nd_Answer_Amount__c;
            }
            if (opp.get('Title__c') != null) {
                newopp.Title__c = (String)opp.get('Title__c');
            }
            
            insert newopp;

            // Add sub-proposals
            for (Map<String, Object> rec : subproposals) {
                Sub_Proposal__c newsp = new Sub_Proposal__c();
                newsp.Opportunity__c = newopp.Id;
                newsp.Type__c = (String)rec.get('Type__c');
                newsp.Comments__c = (String)rec.get('Comments__c');
                newsp.Planned_Gift_Type__c = (String)rec.get('Planned_Gift_Type__c');
                if (rec.get('Amount__c') != null) {
                    newsp.Amount__c = Decimal.valueOf((String)rec.get('Amount__c'));
                }
                if (rec.get('Funding_Priority__c') != null) {
                    newsp.Funding_Priority__c = (Id)rec.get('Funding_Priority__c');
                    fundingPrioritySet.add(newsp.Funding_Priority__c);
                }
                insertSubproposalList.add(newsp);

                if (newsp.Type__c == 'PG') {
                    hasSubProposalPlannedGift = true;
                }
            }

            // Add Opportunity Team Members from the UI
            for (Map<String, Object> rec : oppteammembers) {
                OpportunityTeamMember newotm = new OpportunityTeamMember();
                newotm.OpportunityId = newopp.Id;
                newotm.TeamMemberRole = (String)rec.get('TeamMemberRole');
                if (rec.get('UserId') != null) {
                    newotm.UserId = (Id)rec.get('UserId');

                    //if PRM or Lead Proposal Primary
                    if (newotm.TeamMemberRole == 'RM' || newotm.TeamMemberRole == 'PP') {
                        prmUserIdList.add(newotm.UserId);
                    }
                }
                inserOppTeamMemberList.add(newotm);
            }

            // Add Funding Priority Owners as members
            for (ucinn_ascendv2__Work_Plan_Unit__c wpu : [Select Id, Name, OwnerId From ucinn_ascendv2__Work_Plan_Unit__c Where Id In :fundingPrioritySet]) {
                OpportunityTeamMember newotm = new OpportunityTeamMember();
                newotm.OpportunityId = newopp.Id;
                newotm.TeamMemberRole = 'LI';
                newotm.UserId = wpu.OwnerId;
                inserOppTeamMemberList.add(newotm);
            }

            /*
            // Add members based on Opp Team Member by Type mdt
            String newOppType = newopp.Type;
            String otmByTypeQuery = 'Select Stewardship_Staff_ID__c, Opp_Team_Member_Role__c From Opp_Team_Member_by_Type__mdt Where Proposal_Type__c = :newOppType ';
            if (hasSubProposalPlannedGift) {
                otmByTypeQuery += ' And Sub_Proposal_Type__c = \'PG\' ';
            } else {
                otmByTypeQuery += ' And Sub_Proposal_Type__c <> \'PG\' ';
            }

            for (Opp_Team_Member_by_Type__mdt mdt : Database.query(otmByTypeQuery)) {
                OpportunityTeamMember newotm = new OpportunityTeamMember();
                newotm.OpportunityId = newopp.Id;
                newotm.TeamMemberRole = mdt.Opp_Team_Member_Role__c;
                newotm.UserId = mdt.Stewardship_Staff_ID__c;
                inserOppTeamMemberList.add(newotm);
            }
            */

            // Add PRM's Gift Planning Officer as member. Collect PRM user roles
            if (!prmUserIdList.isEmpty()) {
                for (User u : [Select Id, nd_Gift_Planning_Officer__c, UserRoleId, UserRole.Name, ND_Group_Region__c From User Where Id In :prmUserIdList]) {
                    //for users that has GPO assigned at the user account and has planned gift
                    if (u.nd_Gift_Planning_Officer__c != null && hasSubProposalPlannedGift) {
                        OpportunityTeamMember newotm = new OpportunityTeamMember();
                        newotm.OpportunityId = newopp.Id;
                        newotm.TeamMemberRole = 'GP';
                        newotm.UserId = u.nd_Gift_Planning_Officer__c;
                        inserOppTeamMemberList.add(newotm);
                    }
                    
                    //getting the role from the user account
                    if (u.UserRoleId != null) {
                        prmUserRoleList.add(u.UserRole.Name);
                    }
                    
                    //getting the group region of the user.
                    if (String.isNotBlank(u.ND_Group_Region__c)) {
                        prmGroupRegionList.add(u.ND_Group_Region__c);
                    }
                }
            }
            
            // Add members based on Opp Team Member by Role mdt
            if (!prmUserRoleList.isEmpty()) {
                String otmByRoleQuery = 'Select Stewardship_User_ID__c, Opp_Team_Member_Role__c, PRM_Role__c From Opp_Team_Member_by_Role__mdt Where PRM_Role__c In :prmUserRoleList And Stewardship_User_ID__c <> null';

                for (Opp_Team_Member_by_Role__mdt mdt : Database.query(otmByRoleQuery)) {
                    OpportunityTeamMember newotm = new OpportunityTeamMember();
                    newotm.OpportunityId = newopp.Id;
                    newotm.TeamMemberRole = mdt.Opp_Team_Member_Role__c;
                    newotm.UserId = mdt.Stewardship_User_ID__c;
                    inserOppTeamMemberList.add(newotm);
                }
            }
            
            // Add members based on the Group Region Assignment mdt
            if (!prmGroupRegionList.isEmpty()) {
                String otmByGroupRegionQuery = 'Select Stewardship_User_ID__c From Group_Region_SRD_Assignment__mdt Where Group_Region__c In :prmGroupRegionList And Stewardship_User_ID__c <> null';

                for (Group_Region_SRD_Assignment__mdt mdt : Database.query(otmByGroupRegionQuery)) {
                    OpportunityTeamMember newotm = new OpportunityTeamMember();
                    newotm.OpportunityId = newopp.Id;
                    newotm.TeamMemberRole = 'SW'; //stewardship
                    newotm.UserId = mdt.Stewardship_User_ID__c;
                    inserOppTeamMemberList.add(newotm);
                }
            }
            
            //add contact roles from the UI
            for (Map<String, Object> rec : oppcontactroles) {
                OpportunityContactRole newocr = new OpportunityContactRole();
                newocr.OpportunityId = newopp.Id;
                newocr.Role = (String)rec.get('Role');
                if (rec.get('ContactId') != null) {
                    newocr.ContactId = (Id)rec.get('ContactId');
                }
                oppContactRoleList.add(newocr);
            }

            if (!insertSubproposalList.isEmpty()) {
                insert insertSubproposalList;
            }

            if (!inserOppTeamMemberList.isEmpty()) {
                insert inserOppTeamMemberList;
            }

            if (!oppContactRoleList.isEmpty()) {
                insert oppContactRoleList;
            }

            // Update opportunity name and owner
            List<Opportunity> oppList = [Select Id, ND_Proposal_AutoNumber2__c From Opportunity Where Id = :newopp.Id];
            if (!oppList.isEmpty()) {
                if (!prmUserIdList.isEmpty()) {
                    oppList[0].OwnerId = prmUserIdList[0];
                }

                oppList[0].Name = 'PR' + oppList[0].ND_Proposal_AutoNumber2__c;
                update oppList[0];
            }

            ret.put(KEY_OPPORTUNITYID, newopp.Id);

        } catch(System.Exception ex) {
            Database.rollback(sp);
            errmsgList.add(ex.getMessage());
            
            System.debug('#### ERROR: '+ex.getMessage());
        }

        ret.put(KEY_ERRORMESSAGE, string.join(errmsgList, '; '));

        return ret;
    }

    /*******************************************************************************************************
     * @description Method to generate random string
     * @param len The number of character length
     * @return N/A
     */
    private static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
}