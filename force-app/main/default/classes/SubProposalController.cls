/**
 * @author UC Innovation
 * @date 11/23/2021
 * @group LWC Controller
 * @description Controller for LWC Components
 */
public with sharing class SubProposalController {
    
    /**
    * Method to get Opportunity record
    * @param opportunityId Opportunity record Id
    * @return Opportunity record 
    */
    @AuraEnabled
    public static Opportunity getOpportunity(String opportunityId) {
        List<Opportunity> oppList = [Select Id, Name, CampaignId From Opportunity Where Id = :opportunityId];
        if (!oppList.isEmpty()) {
            return oppList[0];
        }
        return null;
    }
}