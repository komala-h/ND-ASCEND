public with sharing class NDFundingInterestTagController {

        @AuraEnabled(cacheable=true)

        public static List<ucinn_ascendv2__Funding_Interest__c> getData(string FundInterestPriorityId) {
        
        
        List<ucinn_ascendv2__Foundation_Funding_Interests__c> FITags = new List<ucinn_ascendv2__Foundation_Funding_Interests__c>();
        List<ucinn_ascendv2__Funding_Interest__c> FITagsDisplayList = new List<ucinn_ascendv2__Funding_Interest__c>();

        Set<id> FundPriority = new set<id>();

       system.debug('FundInterestPriorityId  '+FundInterestPriorityId);

        for ( ucinn_ascendv2__Funding_Interest__c fi1 : [select name, ucinn_ascendv2__Foundation_Funding_Interest__c  
        from ucinn_ascendv2__Funding_Interest__c where Work_Plan_Unit__c = :FundInterestPriorityId]){
            FundPriority.add(fi1.ucinn_ascendv2__Foundation_Funding_Interest__c);


        }
        system.debug('FundPriority '+FundPriority);


        for (ucinn_ascendv2__Funding_Interest__c fi2 : [select id, name, ucinn_ascendv2__Foundation_Funding_Interest__c,
        ucinn_ascendv2__Foundation_Funding_Interest__r.Name , ucinn_ascendv2__Account__c, ucinn_ascendv2__Account__r.Name
        from ucinn_ascendv2__Funding_Interest__c where  ucinn_ascendv2__Account__c!=null AND ucinn_ascendv2__Foundation_Funding_Interest__c in :FundPriority] ){

            FITagsDisplayList.add(fi2);

        }


        system.debug('FITagsDisplayList'+FITagsDisplayList);

        
        return FITagsDisplayList;
        
    }
  
}