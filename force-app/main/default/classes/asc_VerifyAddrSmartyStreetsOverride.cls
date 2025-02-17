/**
 * @author Chaldrin Cruz, UC Innovation
 * @description Override finish to chain interim process batches after addresses are verified
 */
global class asc_VerifyAddrSmartyStreetsOverride extends ucinn_ascendv2.ascend_ADDR_VerifyAddrSmartyStreetsBase {
    global override void batchFinish(Database.BatchableContext BC) {
        System.debug('asc_VerifyAddrSmartyStreetsOverride.batchFinish()');
        //processVerifiedNCOAInterims();
          /*cube84-commented it out because lines not available in PROD
        List<ucinn_ascendv2__Interim__c> ListNCOA = [SELECT ID FROM ucinn_ascendv2__Interim__c WHERE RecordType.DeveloperName = 'NCOA'
            AND ucinn_ascendv2__Status__c = 'New'
            AND ucinn_ascendv2__Contact__c != null AND ucinn_ascendv2__Verification_Source__c != null LIMIT 10];
        
        if(ListNCOA.size()>0){*/
            Database.executeBatch(new asc_BATCH_ProcessNcoaInterims(true));
       // }
    }

    /* Cube84-commented the below method because in Line 8 the method call as been already commented out.
    private void processVerifiedNCOAInterims() {
        Set<Id> interimIdSet = new Set<Id>();
        Map<Id, ucinn_ascendv2__Interim__c> interimMap = new Map<Id, ucinn_ascendv2__Interim__c>([
            SELECT Id
            FROM ucinn_ascendv2__Interim__c
            WHERE RecordType.DeveloperName = 'NCOA'
            AND ucinn_ascendv2__Status__c != 'Completed'
            AND ucinn_ascendv2__Contact__c != null
            AND ((ucinn_ascendv2__Is_Verified__c = TRUE
            AND ucinn_ascendv2__DPV_Match_Code__c = 'Y'
            AND ucinn_ascendv2__Verification_Source__c = 'SmartyStreets API'))
            //OR cVerification_Override__c = TRUE)
            LIMIT 50000
        ]);

        if (interimMap.keySet().isEmpty()) {
            return;
        }
        else {
            interimIdSet.addAll(interimMap.keySet());
        }

        Map<String, Object> interimBatchParams = new Map<String, Object>();
        interimBatchParams.put('customizedLogic_interimRecordTypeDeveloperName', 'NCOA');
        interimBatchParams.put('ascend_DEDUPE_ProcessInterimNewBatchSize', 100);
        interimBatchParams.put('ascend_DEDUPE_ProcessPendingBatchSize', 20);
        interimBatchParams.put('ascend_DEDUPE_ProcessInProgressBatchSize', 1);
        interimBatchParams.put('selectiveProcessing', true);
        interimBatchParams.put('selectedInterimIds', interimIdSet);
        try {
            ucinn_ascendv2.ascend_UTIL_RunBatch.processInterimsByRecordType(interimBatchParams);        
        } catch(Exception e) {
            System.debug('Error starting Interim Batch! ' + e.getMessage());
        }
    }*/
}