//-------------------------------------------------------------
// @description	utils class for Funding Priorities Calculation
// @author 		UCInnovation
// @date		05/08/2022
global class asc_UTIL_FundingPrioritiesUtils {
	global Map<Id, Integer> recordTypeToLevel;
    global Map<Integer, Id> levelToRecordType;
	
    
    //-------------------------------------------------
    // @description	initiate the class with the record
    // 				type Ids map
    // @param		null
    // @return		null
    //
    global asc_UTIL_FundingPrioritiesUtils() {
        levelToRecordType = new Map<Integer, Id>();
        levelToRecordType.put(4, Schema.SObjectType.ucinn_ascendv2__Work_Plan_Unit__c.getRecordTypeInfosByDeveloperName().get('Funding_Priority_Level_4').getRecordTypeId());
        levelToRecordType.put(3, Schema.SObjectType.ucinn_ascendv2__Work_Plan_Unit__c.getRecordTypeInfosByDeveloperName().get('Funding_Priority_Level_3').getRecordTypeId());
        levelToRecordType.put(2, Schema.SObjectType.ucinn_ascendv2__Work_Plan_Unit__c.getRecordTypeInfosByDeveloperName().get('Funding_Priority_Level_2').getRecordTypeId());
        levelToRecordType.put(1, Schema.SObjectType.ucinn_ascendv2__Work_Plan_Unit__c.getRecordTypeInfosByDeveloperName().get('Funding_Priority_Level_1').getRecordTypeId());
        levelToRecordType.put(0, Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Comprehensive_Campaign').getRecordTypeId());
    
        recordTypeToLevel = new Map<Id, Integer>();
        recordTypeToLevel.put(Schema.SObjectType.ucinn_ascendv2__Work_Plan_Unit__c.getRecordTypeInfosByDeveloperName().get('Funding_Priority_Level_4').getRecordTypeId(), 4);
        recordTypeToLevel.put(Schema.SObjectType.ucinn_ascendv2__Work_Plan_Unit__c.getRecordTypeInfosByDeveloperName().get('Funding_Priority_Level_3').getRecordTypeId(), 3);
        recordTypeToLevel.put(Schema.SObjectType.ucinn_ascendv2__Work_Plan_Unit__c.getRecordTypeInfosByDeveloperName().get('Funding_Priority_Level_2').getRecordTypeId(), 2);
        recordTypeToLevel.put(Schema.SObjectType.ucinn_ascendv2__Work_Plan_Unit__c.getRecordTypeInfosByDeveloperName().get('Funding_Priority_Level_1').getRecordTypeId(), 1);
        recordTypeToLevel.put(Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Comprehensive_Campaign').getRecordTypeId(), 0);

    }
    
    
    //-------------------------------------------------------------------------
    // @description	controller for the Recalculate Funding Priority Goal on 
    // 				Funding Priority and Campaign. Query all of the children
    // 				(grand/grand-grand/...children) of the Funding Priority/Campaign
    // 				and recalculate the whole tree
    // @param		recordId		recordId of the record on the screen
    // @return		status of the initiation			
    //
    @InvocableMethod(label='Initiate Recalculate Funding Priority Goal' category='Funding Priority')
    global static List<String> recalculateFundingPriorityButtonInitiate(List<String> recordId) {
        //Query for the record on screen so that we have the RecordTypeId to determine the level we're at
        List<ucinn_ascendv2__Work_Plan_Unit__c> fundingPriority = [SELECT Id, RecordTypeId FROM ucinn_ascendv2__Work_Plan_Unit__c WHERE Id IN:recordId];
        List<Campaign> comprehensiveCampaign = [SELECT Id, RecordTypeId FROM Campaign WHERE Id IN:recordId];
        
        asc_UTIL_FundingPrioritiesUtils utils = new asc_UTIL_FundingPrioritiesUtils();
        Integer currentLevelOnRecord;
        
        //Find out the current level we're at
		if ((fundingPriority == null
        			|| fundingPriority.isEmpty())
        		&& (comprehensiveCampaign != null)
            		&& !comprehensiveCampaign.isEmpty()) {
        	currentLevelOnRecord = utils.recordTypeToLevel.get(comprehensiveCampaign[0].RecordTypeId); 
                    
        } else if ((fundingPriority != null
        				&& !fundingPriority.isEmpty())
        			&& (comprehensiveCampaign == null)
                   		|| comprehensiveCampaign.isEmpty()) {
        	currentLevelOnRecord = utils.recordTypeToLevel.get(fundingPriority[0].RecordTypeId);
        }
        
        if (currentLevelOnRecord == null) {
            return new List<String> {'ERROR: No records found!'};
        }
        
        //Initiate the fundingPrioritiesToCalculate
        Map<Integer, Set<Id>> fundingPrioritiesToCalculate = new Map<Integer, Set<Id>>();
        if (currentLevelOnRecord == 0) {
            fundingPrioritiesToCalculate.put(0, new Set<Id> {comprehensiveCampaign[0].Id});
        } else {
            fundingPrioritiesToCalculate.put(currentLevelOnRecord, new Set<Id> {fundingPriority[0].Id});
        }
        
        //Populate all the nodes for re-calculation
        for (Integer targetLevel = currentLevelOnRecord + 1; targetLevel <= 3; targetLevel++) {
			populateFundingPrioritiesForLevel(targetLevel, fundingPrioritiesToCalculate, utils);
    	}
        
        System.debug(fundingPrioritiesToCalculate);
        
        Database.executeBatch(new asc_BATCH_RecalculateFundingPriority(3, fundingPrioritiesToCalculate, 20), 20);

        return new List<String> { 'SUCCESS' };
    } 
    
    //-------------------------------------------------------------------------
    // @description	query for the target level of Funding Priority and put them
    // 				into the fundingPrioritiesToCalculate Map for recalculation
    // 				based on the parent level (targetLevel - 1)
    // 	@param		targetLevel						target level we want to query for
    // 	@param		fundingPrioritiesToCalculate	contains the FPs to recalculate
    // 	@param		utils							util class having the record type maps
    // 	@return		void
    // 	
    global static void populateFundingPrioritiesForLevel(Integer targetLevel, 
                                                         Map<Integer, Set<Id>> fundingPrioritiesToCalculate,
                                                         asc_UTIL_FundingPrioritiesUtils utils) {
        //Find the parents of the targetLevel
        Set<Id> parentIdSet = fundingPrioritiesToCalculate.get(targetLevel - 1);
        if (parentIdSet == null) {
			parentIdSet = new Set<Id>();
    	}
                                                             
        //Build query String, if it's L1 we need to look at the Campaign
        Id targetRecordType = utils.levelToRecordType.get(targetLevel);
        String queryString = 'SELECT Id FROM ucinn_ascendv2__Work_Plan_Unit__c WHERE ';
        if (targetLevel == 1) {
            queryString = queryString + ' Comprehensive_Campaign__c ';
        } else {
            queryString = queryString + ' ucinn_ascendv2__Work_Plan_Unit__c ';
        }
        queryString = queryString + ' IN :parentIdSet ';
        queryString = queryString + ' AND RecordTypeId = :targetRecordType ';
     
        System.debug(queryString);
        
        //Query for the FPs at the target Level and put them for recalculation                                                   
        Map<Id, ucinn_ascendv2__Work_Plan_Unit__c> targetFundingPrioritiesMap 
            = new Map<Id, ucinn_ascendv2__Work_Plan_unit__c>(
                (List<ucinn_ascendv2__Work_Plan_Unit__c>)Database.query(queryString));
        
        fundingPrioritiesToCalculate.put(targetLevel, targetFundingPrioritiesMap.keySet());
    }
}