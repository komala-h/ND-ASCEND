/*
* Author: UCInnovation
* Description: class to process interim records
*/
public class ND_InterimProcessor {

    //method to populate the contact on RTv2 records from related interim record
    public static void updateContactRTv2(List<ucinn_ascendv2__Interim__c> TriggerNew, Map<Id,ucinn_ascendv2__Interim__c> TriggerOldMap){       
        
        Set<Id> procInterims = new Set<Id>();
        Map<Id, ucinn_ascendv2__Interim__c> newMap = new Map<Id, ucinn_ascendv2__Interim__c>();
        
        for (ucinn_ascendv2__Interim__c interim : TriggerNew) {
            If(interim.ucinn_ascendv2__Contact__c != TriggerOldMap.get(interim.Id).ucinn_ascendv2__Contact__c){
                newMap.put(interim.Id, interim);
                procInterims.add(interim.Id);
            }
        }

        // Querying to get the review transaction related list, which should only be one for each interim.
        List<ucinn_ascendv2__Interim__c> interimList = [SELECT Id, ucinn_ascendv2__Contact__c,nd_RecordType_DeveloperName__c,
                                                               (SELECT Id, ucinn_ascendv2__Contact__c,ucinn_ascendv2__Status__c,
                                                                ucinn_ascendv2__Manual_Review_Reason__c
                                                                FROM ucinn_ascendv2__Review_Transactions_v2_Interim__r
                                                                WHERE ucinn_ascendv2__Status__c <> 'Posted')
                                                        FROM ucinn_ascendv2__Interim__c
                                                        WHERE Id IN :procInterims AND ucinn_ascendv2__Contact__c != null];
       
        List<ucinn_ascendv2__Review_Transaction_v2__c> RTV2ToUpdateList = new List<ucinn_ascendv2__Review_Transaction_v2__c>();
        
        for (ucinn_ascendv2__Interim__c interim : interimList) {
        
            if (interim.ucinn_ascendv2__Review_Transactions_v2_Interim__r != null && !interim.ucinn_ascendv2__Review_Transactions_v2_Interim__r.isEmpty()) {
                ucinn_ascendv2__Review_Transaction_v2__c revTransV2 = interim.ucinn_ascendv2__Review_Transactions_v2_Interim__r.get(0);

                // Need to get it from map instead of from query since ucinn_ascendv2__Contact__c would be old value.
                revTransV2.ucinn_ascendv2__Contact__c = newMap.get(interim.Id).ucinn_ascendv2__Contact__c;
                /*
                if (revTransV2.ucinn_ascendv2__Status__c == 'Manual Review'){ 
                    revTransV2.ucinn_ascendv2__Status__c = 'Reviewed';
                    revTransV2.ucinn_ascendv2__Manual_Review_Reason__c = '';
                }
                */
                RTV2ToUpdateList.add(revTransV2); 
            }
        }
        update RTV2ToUpdateList;
       
    }
    
    //method to call the ascend dedupe batch to match records
    public static void InterimMatch() {
        
        List<ucinn_ascendv2__Interim__c> InterimList = new List<ucinn_ascendv2__Interim__c>([Select id from ucinn_ascendv2__Interim__c where 
                                                                                            ND_Address_Verification_Processed__c= true and
                                                                                            ucinn_ascendv2__Possible_Duplicate_Checked__c = false and
                                                                                            ucinn_ascendv2__Contact__c = null and
                                                                                            ucinn_ascendv2__Status__c != 'Completed']);

        //system.debug('Interim records returned ' + InterimList.size());
        //check if there are records to processed
        If(InterimList.size()>0){
            InterimMatch(InterimList, 200);

        }
    }
    
    //method to manually call the ascend dedupe batch to match records
    public static void InterimMatch(List<ucinn_ascendv2__Interim__c> recordList,integer size) {

        string IdInstart = 'Id in (';
        string IdInEnd = ')';
        string IdInBody = '';
        
        //loop through list to build the string body
        for (ucinn_ascendv2__Interim__c intrm : recordList) {
            IdInBody += '\'' + intrm.id + '\',';                               
        }
        
        //remove comma from the last...
        IdInBody = IdInBody.removeEnd(',');
        //system.debug('Id Set ' + IdInstart + IdInBody + IdInEnd);
        //system.debug('IdInBody =' + IdInBody);
        //get matchruleId        
        ucinn_ascendv2__matching_rule__c MatchRuleId = [select id from ucinn_ascendv2__matching_rule__c where name = 'interim to contact' limit 1];
        
        //check if MatchRuleId is null
        if(MatchRuleId != null){
            Map<String, Object> dedupe = new Map<String, Object>();
            dedupe.put('matchingRuleId', MatchRuleId.id);
            dedupe.put('duplicateCheckedFieldAPIName', 'ucinn_ascendv2__Possible_Duplicate_Checked__c');
            dedupe.put('additionalCriteria', IdInstart + IdInbody + IdInEnd);
            dedupe.put('batchSize', size);
            ucinn_ascendV2.ascend_DEDUPE_GlobalWrapper.executeFindDuplicateBatch(dedupe);
        }
    }
    
    public static void InterimAddressVerifier(){
    
        Set<String> matchCodeSet = new Set<String>{'Y'};
        Set<String> vacantSet = new Set<String>{'N'};
        Set<String> verificationStatusSet = new Set<String>{'Verified'};
        Set<String> addressPrecisionSet = new Set<String>{'Premise', 'DeliveryPoint'};
        Map<String, Set<String>> usParam = new Map<String, Set<String>>();
        usParam.put('ucinn_ascendv2__DPV_Match_Code__c', matchCodeSet);
        usParam.put('ucinn_ascendv2__DPV_Vacant__c', vacantSet);
        Map<String, Set<String>> internationalParam = new Map<String, Set<String>>();
        internationalParam.put('ucinn_ascendv2__Verification_Status__c', verificationStatusSet);
        internationalParam.put('ucinn_ascendv2__Address_Precision__c', addressPrecisionSet);
        String whereClause = 'ND_Address_Verification_Processed__c = false';
        Map<String, String> addressFieldMap = new Map<String, String>();
        addressFieldMap.put('addressLine1', 'ucinn_ascendv2__Address_1_Line_1__c');
        addressFieldMap.put('city', 'ucinn_ascendv2__City_1__c');
        addressFieldMap.put('state', 'ucinn_ascendv2__State_1__c');
        addressFieldMap.put('postalCode', 'ucinn_ascendv2__Postal_Code_1__c');
        addressFieldMap.put('country', 'ucinn_ascendv2__Country_1__c');
        addressFieldMap.put('request', 'ucinn_ascendv2__Address_Verification_API_Request__c');
        addressFieldMap.put('response', 'ucinn_ascendv2__Address_Verification_API_Response__c');
        addressFieldMap.put('isVerified', 'ucinn_ascendv2__Is_Verified__c');
        addressFieldMap.put('verificationSource', 'ucinn_ascendv2__Verification_Source__c');
        addressFieldMap.put('verificationResponse', 'ucinn_ascendv2__Verification_Response__c');
        addressFieldMap.put('dataSource', 'ucinn_ascendv2__Data_Source__c');
        addressFieldMap.put('latitude', 'ucinn_ascendv2__Geolocation_1_Latitude__c');
        addressFieldMap.put('longitude', 'ucinn_ascendv2__Geolocation_1_Longitude__c');
        addressFieldMap.put('verificationDateTime', 'ucinn_ascendv2__Verification_Date_Time__c');
        ucinn_ascendv2.ascend_UTIL_RunBatch.ascend_ADDR_VerifyAddrSmartyStreetsBatch(whereClause, usParam,internationalParam, 'ucinn_ascendv2__Interim__c', addressFieldMap, 200);
    
    }
    

}