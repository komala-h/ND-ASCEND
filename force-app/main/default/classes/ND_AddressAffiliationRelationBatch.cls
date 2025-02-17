global class ND_AddressAffiliationRelationBatch implements Database.Batchable<SObject>, Database.Stateful{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //give me all the records where data source is banner and no affiliation tied to it...not sure how to avoid this with student records -_-
        // oh wait a new field that says its affiliation! i can do that, setting to true in the intrim now
        return Database.getQueryLocator(
            'SELECT ID, affiliation__c,  ucinn_ascendv2__Status__c, ucinn_ascendv2__Data_Source__c from ucinn_ascendv2__Address_Relation__c ' +
            'Where ucinn_ascendv2__Type__c in (\'B\', \'O\') and ucinn_ascendv2__Data_Source__c=\'B\' and affiliation__c = null and ND_Created_from_Interim_Auto_Affiliation__c = true and ND_process_id__c = null'
        );
    }
    global void execute(Database.BatchableContext bc, List<ucinn_ascendv2__Address_Relation__c> scope){

        List<ucinn_ascendv2__Address_Relation__c> lockedEms = [SELECT ID, affiliation__c, ucinn_ascendv2__Contact__c, ucinn_ascendv2__Status__c, ucinn_ascendv2__Data_Source__c 
        , ND_process_id__c from ucinn_ascendv2__Address_Relation__c where Id IN :scope and ND_process_id__c = null FOR UPDATE ];
        id NdOrgId = [select id from account where ucinn_ascendv2__Donor_ID__c='307129'].id;
        set<string> constituentIds = new set <string>();


        for(ucinn_ascendv2__Address_Relation__c ems : lockedEms) {

            constituentIds.add(ems.ucinn_ascendv2__Contact__c);

        }
        Map<id, Id> constituent_and_affils = new map<id, id>();
        for (ucinn_ascendv2__Affiliation__c af : [select id, ucinn_ascendv2__Contact__c from  ucinn_ascendv2__Affiliation__c 
        where ucinn_ascendv2__Contact__c in :constituentIds and ucinn_ascendv2__Data_Source__c = 'B' and ucinn_ascendv2__Account__c = :NdOrgId and ucinn_ascendv2__Status__c='Current']){
            constituent_and_affils.put(af.ucinn_ascendv2__Contact__c, af.id);
        }
        List<ucinn_ascendv2__Address_Relation__c> addrUpdate = new List<ucinn_ascendv2__Address_Relation__c>();
        for(ucinn_ascendv2__Address_Relation__c emUps : lockedEms) {

            emUps.affiliation__c = constituent_and_affils.get(emUps.ucinn_ascendv2__Contact__c);
            emUps.ND_process_id__c = processId;
            addrUpdate.add(emUps);
        }

        update addrUpdate;


    }
    global void finish(Database.BatchableContext bc){
       
    }
    global integer processId = Crypto.getRandomInteger();


}