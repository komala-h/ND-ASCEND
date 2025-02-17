/**
 * @author Charlie Park, UC Innovation
 * @date 2020-9-1
 * @description Schedule class to class to run Interim Process
 */
global class ascend_Scheduler_Dedupe implements Schedulable {
    global Map<String, Object> params;
    global String batchType = '';

    /*******************************************************************************************************
     * @description Check to see if there are any in progress interim jobs. Idea is to stop the execute unless the job queue is empty of interim jobs.
     * @return True if there are in progress jobs, False if the queue is clear.
     */
    private Boolean checkForInProgressJobs() {
        List<String> interimBatchNames = new List<String>{'Batch_DedupeInterims','ascend_DEDUPE_ProcessInterimNewBatch','ascend_DEDUPE_ProcessPendingBatch','ascend_DEDUPE_ProcessInProgressBatch'};
        List<String> jobStatusList = new List<String>{'Holding', 'Preparing', 'Processing', 'Queued'};
        List<AsyncApexJob> myRunningJobs = [Select Id, Status, ApexClass.Name From AsyncApexJob where ApexClass.Name IN: interimBatchNames AND Status IN: jobStatusList];

        if (!myRunningJobs.isEmpty()) {
            return true;
        }

        return false;
    }

    /*******************************************************************************************************
     * @description Execute schedule context.
     * @param sc Parameter type of a schedulable context.
     * @return N/A.
     */
    global void execute(SchedulableContext sc) {
        if(batchType == 'MatchingKVBatch'){
            /*
             * Params for executeCreateMatchingKVBatch are as follows:
             *    {'matchingRuleId' : Id of the matching rule
             *     'recordIdList' : List of Ids to create matching key values for
             *     'batchSize' : size of the batch. Max is 200}
             *
             *    OR
             *
             *    {'matchingRuleId' : Id of the matching rule
             *     'whereClause' : Where clause to filter constituents
             *     'batchSize' : size of the batch. Max is 200}
             *
             *    OR
             *
             *    {'keyRuleIdList' : List of key rule Ids
             *     'recordIdList' : List of Ids to create matching key values for
             *     'batchSize' : size of the batch. Max is 200}
             */
            
            ucinn_ascendv2.ascend_DEDUPE_GlobalWrapper.executeCreateMatchingKVBatch(params);
        } else if (batchType == 'FindDuplicateBatch') {
            
            /*
             * Params for executeFindDuplicateBatch are as follows:
             *    {'matchingRuleId' : Id of the matching rule
             *     'lastModifiedDate' : Find duplicates that were modified after this date
             *     'duplicateCheckedFieldAPIName' : Field that denotes that duplicates were already checked
             *     'additionalCriteria' : specifications for the duplicates in the form of an addon to a where clause Example: 'LastName = \'Bob\''
             *     'batchSize' : size of the batch. Max is 200}
             */
            
            ucinn_ascendv2.ascend_DEDUPE_GlobalWrapper.executeFindDuplicateBatch(params);
        } else if (batchType == 'ProcessInterimsUtilClass') {

            /*
             * Params for processInterimsByRecordType are as follows:
             *    {'matchingRuleId' : Id of the matching rule
             *     'lastModifiedDate' : Find duplicates that were modified after this date
             *     'duplicateCheckedFieldAPIName' : Field that denotes that duplicates were already checked
             *     'additionalCriteria' : specifications for the duplicates in the form of an addon to a where clause Example: 'LastName = \'Bob\''
             *     'batchSize' : size of the batch. Max is 200
             *     'ascend_DEDUPE_FindDuplicateBatchSize' : size of find duplicate batch
             *     'ascend_DEDUPE_ProcessInterimNewBatchSize' : size of process interim new batch
             *     'executeInterimToContactDedupe' : boolean to specify interim as source and contact as target
             *     'executeInterimToInterimDedupe' : boolean to specify interim as source and interim as target
             *     'executeInterimProcessing' : false ends processing after dedpe, true continues to process new interims}
             */
            // Exit if there are in progress jobs.
            if (checkForInProgressJobs()) {
                return;
            }

            ucinn_ascendv2.ascend_UTIL_RunBatch.processInterimsByRecordType(params);
        } else if (batchType == 'ProcessInterimsParallel') {
            // Exit if there are in progress jobs.
            if (checkForInProgressJobs()) {
                return;
            }

            List<String> startWithGroup = new List<String>{'ab','cd', 'ef', 'ghi', 'jkl', 'mn', 'op','qr', 'st', 'uv','wx', 'yz'};
            String originalCriteria = (String)params.get('additionalCriteria');

            for (String letter : startWithGroup) {
                String additionalCriteria = '(';
                additionalCriteria += letter.length() > 0 ? 'ucinn_ascendv2__First_Name__c LIKE \'' + letter.substring(0, 1) + '%\'' : '';
                additionalCriteria += letter.length() > 1 ? ' OR ucinn_ascendv2__First_Name__c LIKE \'' + letter.substring(1, 2) + '%\'' : '';
                additionalCriteria += letter.length() > 2 ? ' OR ucinn_ascendv2__First_Name__c LIKE \'' + letter.substring(2, 3) + '%\'' : '';
                additionalCriteria += ')';

                Map<String, Object> interimBatchParams = new Map<String, Object>();
                interimBatchParams.putAll(params);
                interimBatchParams.put('additionalCriteria', originalCriteria + additionalCriteria);
                ucinn_ascendv2.ascend_DEDUPE_GlobalWrapper.startProcessInterims(interimBatchParams);
            }

            // Run one more for those with first name = null or first name starts with special characters
            List<String> alphabetList = new List<String>{'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'};
            List<String> whereClauseList = new List<String>();
            String additionalCriteria = '(';

            for (String letter: alphabetList) {
                String thisCriteria = '(NOT (ucinn_ascendv2__First_Name__c LIKE \'' + letter + '%\'))';
                whereClauseList.add(thisCriteria);
            }

            additionalCriteria += String.Join(whereClauseList, ' AND ');
            additionalCriteria += ')';

            Map<String, Object> interimBatchParams = new Map<String, Object>();
            interimBatchParams.putAll(params);
            interimBatchParams.put('additionalCriteria', originalCriteria + additionalCriteria);
            ucinn_ascendv2.ascend_DEDUPE_GlobalWrapper.startProcessInterims(interimBatchParams);
        } else {
            // Exit if there are in progress jobs.
            if (checkForInProgressJobs()) {
                return;
            }

            /*
            * Params for startProcessInterims are as follows:
            * 'interimNewBatchSize' : size of the batch for interims with status New. Max is 200
            * 'interimPendingBatchSize' : size of the batch for interims with status Pending. Max is 200
            * 'interimInProgressBatchSize' : size of the batch for interims with status In Progress. Max is 200
            * 'recordTypeDeveloperName' : Record type name for the interims to dedupe
            * 'recordTypeNamespacePrefix' : Namespace prefix for the interim recordtype if applicable
            */
            
            ucinn_ascendv2.ascend_DEDUPE_GlobalWrapper.startProcessInterims(params);
        }
    }
    
}