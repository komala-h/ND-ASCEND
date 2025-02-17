//----------------------------------------------------------
//	@description	Apex Batch Class to aggregate the lower
//					level Funding Priorities' Goal Amount
//					to put on the higher level ones
//	@author			UCInnovation
//	@date			05/08/2022
//	
global class asc_BATCH_RecalculateFundingPriority implements Database.Batchable<sObject>, Database.Stateful {
    //Class Stateful Variables
    global String queryString;
    global Integer currentPriorityLevel;
    global Map<Integer, Set<Id>> fundingPrioritiesToCalculate;
    global String sObjectName_c;
    global String childrenLookup_r;
    global Boolean recalculateAll;
	global Integer batchSize;
	Set<Id> fundingPriorityScope;
    global asc_UTIL_FundingPrioritiesUtils utils;
    
    //---------------------------------------------------------------------
    // @description	determine the Object name and the children lookup name
    // 				based on the current Funding Priority level the batch 
    // 				is running
    // @param		void
    // @return		void
    // 
    global void initiateVariables() {
        utils = new asc_UTIL_FundingPrioritiesUtils();
        if (currentPriorityLevel == 0) {
            sObjectName_c = 'Campaign';
            childrenLookup_r = 'Funding_Priorities__r';
    	} else {
			sObjectName_c = 'ucinn_ascendv2__Work_Plan_Unit__c';
            childrenLookup_r = 'ucinn_ascendv2__Work_Plan_Units_Work_Plan_Unit__r';
        }
    }
    
    //---------------------------------------------------------
    // @description	verify that the level that the batch will run
    // 				is valid range: [0, 3] 
    // 				level 0 means Campaign
    // 				level 1, 2, 3 mean Funding Priority
    // @param		newLevel	level batch will run
    // @return		void
    // 
    global void verifyLevel(Integer newLevel) {
        if (newLevel < 0 || newLevel > 3) {
            throw new DmlException('Funding priority must be between 0 to 3. 0 is the Comprehensive Campaign, and 3 is Level 3 Funding Priorities');
        }
        
        //currentPriorityLevel MUST be 0, 1, 2, or 3 here
		currentPriorityLevel = newLevel;
    }
    
    //----------------------------------------------------------
    // @description Constructor for recalculation of specific
    // 				funding priorities at newLevel
    // 				
    global asc_BATCH_RecalculateFundingPriority(Integer newLevel, 
                                                Map<Integer, Set<Id>> newFundingPrioritiesToCalculate, 
                                                Integer newBatchSize) {
                                                    
        //verify and populate member variables                                            
		verifyLevel(newLevel);
        initiateVariables();
        recalculateAll = false;
        batchSize = newBatchSize;

        //deal with fundingPrioritiesToCalculate
        if (newFundingPrioritiesToCalculate == null) {
            newFundingPrioritiesToCalculate = new Map<Integer, Set<Id>>();
        }
        
        //build queryString
        fundingPrioritiesToCalculate = newFundingPrioritiesToCalculate;
        fundingPriorityScope = fundingPrioritiesToCalculate.get(currentPriorityLevel);
        if (fundingPriorityScope == null) {
			fundingPriorityScope = new Set<Id>();
        }
        queryString = 'SELECT Id FROM ' + sObjectName_c + ' WHERE Id IN :fundingPriorityScope';
    }
    
    //-------------------------------------------------
    // @description	constructor for recalculate ALL 
    // 				Funding Priorities at the newLevel
    // 				
    global asc_BATCH_RecalculateFundingPriority(Integer newLevel, Integer newBatchSize) {
        
        //verify and populate member variables                                            
		verifyLevel(newLevel);
        initiateVariables();
        recalculateAll = true;
        batchSize = newBatchSize;
        
        //deal with fundingPrioritiesToCalculate
        fundingPrioritiesToCalculate = new Map<Integer, Set<Id>>();
        
        //build queryString
        queryString = 'SELECT Id FROM ' + sObjectName_c + ' WHERE RecordTypeId = :currentLevelRecordType';
    }
    
    //-----------------------------------------------------------------
    // @description	constructor for recalculate ALL Funding Priorities 
    // 			
    global asc_BATCH_RecalculateFundingPriority(Integer newBatchSize) {
        
        //verify and populate member variables                                            
		verifyLevel(3);
        initiateVariables();
        recalculateAll = true;
        batchSize = newBatchSize;
        
        //deal with fundingPrioritiesToCalculate
        fundingPrioritiesToCalculate = new Map<Integer, Set<Id>>();
        
        //build queryString
        queryString = 'SELECT Id FROM ' + sObjectName_c + ' WHERE RecordTypeId = :currentLevelRecordType';
    }
    
    //-----------------------------------------------------------------
    // @description	Default constructor => throw error 
    // 		
    global asc_BATCH_RecalculateFundingPriority() {
		throw new DmlException('Please specify Batch Size');
    }
    
    //-------------------------------------------------------------------------------
    // @description	batch start: query for scope depending on the Constructor called
    // 
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //currentPriorityLevel MUST be 0, 1, 2, or 3 because 
        // we checked in the Constructors
        Id currentLevelRecordType = utils.levelToRecordType.get(currentPriorityLevel);
        return Database.getQueryLocator(queryString);
    }

    //---------------------------------------------------------
    // @description	recalculate the Goal Amount of the records
    // 				in scope by aggregating all of its Funding
    // 				Priorities children
    // 
    global void execute(Database.BatchableContext bc, List<SObject> records) {
        //currentPriorityLevel MUST be 0, 1, 2, or 3 because 
        // we checked in the Constructors
        // => currentPriorityLevel + 1 = [1, 4]
        Id childrenRecordTypeId = utils.levelToRecordType.get(currentPriorityLevel + 1);
        
        //Step 1: query for all the info of the records in scope
        String innerQueryString = 'SELECT Id, ';
        if (currentPriorityLevel != 0) {
            //it's 1, 2, or 3 so we need to fetch the parent
            // so that we can also recalculate them
            innerQueryString = innerQueryString + ' Comprehensive_Campaign__c, ucinn_ascendv2__Work_Plan_Unit__c, '; 
        }
            						
        innerQueryString = innerQueryString + '(SELECT Id, Goal__c, Comprehensive_Campaign__c, ucinn_ascendv2__Work_Plan_Unit__c ' 
            								+ ' FROM  ' + childrenLookup_r 
            								+ ' WHERE RecordTypeId = :childrenRecordTypeId) '
            						+ ' FROM ' + sObjectName_c + ' WHERE Id IN :records';

        List<SObject> queriedRecords = Database.query(innerQueryString);
        
		//Step 2: Recalculate the Goal Amount and put the affected parents 
		//	on the list so that we can recalculate them in the next batch        
        Schema.SObjectType objectToken = Schema.getGlobalDescribe().get(sObjectName_c); 
        List<SObject> objWithUpdatedAmount = new List<SObject>(); // update these
        
        //Get the list of the parent level from fundingPrioritiesToCalculate
        //	so that we can add onto it instead of creating a new Set here
        //	because there might be some records at the parent level that were
        //	passed in by the Constructor
        Set<Id> parentToRecalculate = new Set<Id>();
        if (fundingPrioritiesToCalculate.get(currentPriorityLevel - 1) != null
           		&& !fundingPrioritiesToCalculate.get(currentPriorityLevel - 1).isEmpty()) {
            parentToRecalculate.addAll(fundingPrioritiesToCalculate.get(currentPriorityLevel - 1)); 
        }
        
        //Loop through each record in scope, recalculate, and add its parent
        for(SObject eachObj : queriedRecords) {
            
            Decimal aggregatedAmount = 0.0;
            
            //Aggregate the amount of the children
            if (eachObj.getSObjects(childrenLookup_r) != null) {
                for (SObject eachChild : eachObj.getSObjects(childrenLookup_r)) {
                    if (eachChild.get('Goal__c') != null) {
                        aggregatedAmount = aggregatedAmount + (Decimal) eachChild.get('Goal__c');
                    }
                }
            }
            
            sObject updatedObject = objectToken.newSObject();
			updatedObject.Id = eachObj.Id;
            updatedObject.put('Goal__c', aggregatedAmount);
            
            objWithUpdatedAmount.add(updatedObject);
            
            //Add the Parent to the Set so that we can recalculate
            //	 them in the next batch
            if (!recalculateAll) { 
                if (currentPriorityLevel == 1) {
                    parentToRecalculate.add((Id) eachObj.get('Comprehensive_Campaign__c'));
                } else if (currentPriorityLevel > 1) {
                    parentToRecalculate.add((Id) eachObj.get('ucinn_ascendv2__Work_Plan_Unit__c'));
                }
            }
        }
        
        parentToRecalculate.remove(null);
        fundingPrioritiesToCalculate.put(currentPriorityLevel - 1, parentToRecalculate);
        
        //Turn off trigger so that it won't error, it also won't fire duplicate batches
        ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger(sObjectName_c, false);
        update objWithUpdatedAmount;
        ucinn_ascendv2.ascend_UTIL_TDTMTrigger.toggleTDTMTrigger(sObjectName_c, true);
    }
    
    //---------------------------------------------------------------------------
    // @description batch finish: 
    // 					Fire the calculation for the next parent level
    //					since we did the update when the trigger
    //					is off, it doesn't fire duplicate batches
    //					That means this batch is self-sufficient
    //					
    global void finish(Database.BatchableContext bc) {
        
        if (recalculateAll) { 
            //Again, currentPriorityLevel can only be 0, 1, 2, or 3
            //	we only need to fire if it's > 0 because if it's 0 
            //	there's no parent
            //	P/S: currentPriorityLevel - 1 = [0, 2] 
            if (currentPriorityLevel > 0) {
                Database.executeBatch(new asc_BATCH_RecalculateFundingPriority(currentPriorityLevel - 1, batchSize), batchSize);
            }
            
        } else {
            if (currentPriorityLevel > 0) {
                Database.executeBatch(new asc_BATCH_RecalculateFundingPriority(currentPriorityLevel - 1, fundingPrioritiesToCalculate, batchSize), batchSize);
            }
        }
    }
}