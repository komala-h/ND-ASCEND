/*
* Author: UCInnovation
* Description: class to process affiliation records
* Date: 6/22/2022
*/
public class ND_AffilationProcessor {

    
    //method to update the constituent type if the affiliation record is an employee of the Univ of Notre Dame.
    public static void UpdateConstituentType(List<ucinn_ascendv2__Affiliation__c> affList){
    
        Set<Id> conSetIds = new Set<Id>();
        //get University of ND external ID
        Id UNDSFId = ND_Utilities.queryforUNDId();
        system.debug('UNDSFId: ' + UNDSFId );   
        //filter affiliations for only UND employees
        if (UNDSFId != null){
            List<Contact> contListToUpdate = new List<Contact>();
            For (ucinn_ascendv2__Affiliation__c aff: affList){
                if(aff.ucinn_ascendv2__Status__c == 'Current' && aff.ucinn_ascendv2__Account__c == UNDSFId){
                    conSetIds.add(aff.ucinn_ascendv2__Contact__c);
                }
            }
            system.debug('conSetIds: ' +conSetIds);
            
            if(conSetIds.size()>0){
                
                for(Contact cont:[SELECT Id, ucinn_ascendv2__Contact_Type__c FROM Contact WHERE Id in: conSetIds]){
                    
                    if(cont.ucinn_ascendv2__Contact_Type__c == null ){
                        cont.ucinn_ascendv2__Contact_Type__c = 'EM';
                         
                    }
                    //need to remove Related Entity 'RE' if present
                    if(cont.ucinn_ascendv2__Contact_Type__c.contains('RE')) {
                        cont.ucinn_ascendv2__Contact_Type__c = cont.ucinn_ascendv2__Contact_Type__c.Remove('RE');
                    } 
                    //need to remove 'ER' if present
                    if(cont.ucinn_ascendv2__Contact_Type__c.contains('ER')){
                        cont.ucinn_ascendv2__Contact_Type__c = cont.ucinn_ascendv2__Contact_Type__c.Remove('ER');
                    }
                    //remove Former Employee 'EF' per Carleen's email confirming the removal of contact types on 12/6.
                    if(cont.ucinn_ascendv2__Contact_Type__c.contains('EF')) {
                        cont.ucinn_ascendv2__Contact_Type__c = cont.ucinn_ascendv2__Contact_Type__c.Remove('EF');
                    }
                    //remove Friend 'FR' per meeting on 2-7-2024 with Jay/Jess/Carleen when discussing student type and employee logic was mentioned 
                    if(cont.ucinn_ascendv2__Contact_Type__c.contains('FR')){
                        cont.ucinn_ascendv2__Contact_Type__c = cont.ucinn_ascendv2__Contact_Type__c.Remove('FR');
                    }
                    // remove Related Child 'RC' per meeting on 2-7-2024 with Jay/Jess/Carleen when discussing student type and employee logic was mentioned 
                    if (cont.ucinn_ascendv2__Contact_Type__c.contains('RC')){
                        cont.ucinn_ascendv2__Contact_Type__c = cont.ucinn_ascendv2__Contact_Type__c.Remove('RC');
                    }
                    if (!cont.ucinn_ascendv2__Contact_Type__c.contains('EM')){
                        cont.ucinn_ascendv2__Contact_Type__c = cont.ucinn_ascendv2__Contact_Type__c + ';EM';
                    }
                     
                                   
                    contListToUpdate.add(cont);
                }
                
                system.debug('contListToUpdate ' + contListToUpdate);
                
                update contListToUpdate;
            }
        }
    }
    
    /*
    * Author: UCInnovation, Ryan Hu 
    * Date: 2/28/2023
    * Description: Method to prevent more than one primary employment.If a new primary employer is created or another record is updated to primary employment, then make the existing primary record to non primary.
    *              Moved logic from process builder to here.
    */
    public static void processSinglePrimaryEmployer(List<ucinn_ascendv2__Affiliation__c> affiliations, Boolean throwError) {
        // Prevent more than one primary - throw an error is an option and parameterized
        Set<Id> contactIdSet = new Set<Id>();
        Set<Id> currentAffiliationIdSet = new Set<Id>();
        Map<Id, ucinn_ascendv2__Affiliation__c> contactIdToAffiliation = new Map<Id, ucinn_ascendv2__Affiliation__c>();
        Set<Id> errorAffiliationIdSet = new Set<Id>();
        for (ucinn_ascendv2__Affiliation__c affiliation : affiliations) {
            if (affiliation.Is_Primary_Employment__c == true) {
                currentAffiliationIdSet.add(affiliation.Id);
                contactIdSet.add(affiliation.ucinn_ascendv2__Contact__c);
                contactIdToAffiliation.put(affiliation.ucinn_ascendv2__Contact__c, affiliation);
            }
        }

        if (contactIdSet.isEmpty() == false) {
            List<ucinn_ascendv2__Affiliation__c> otherAffiliationList = [SELECT Id, Is_Primary_Employment__c, ucinn_ascendv2__Contact__c FROM ucinn_ascendv2__Affiliation__c WHERE Id NOT IN: currentAffiliationIdSet 
                                                                         AND ucinn_ascendv2__Contact__c IN: contactIdSet AND Is_Primary_Employment__c = true ];
            if (otherAffiliationList != null && otherAffiliationList.size() > 0) {
                for (ucinn_ascendv2__Affiliation__c otherAffiliation : otherAffiliationList) {
                    if (throwError == true) {
                        ucinn_ascendv2__Affiliation__c affToThrowError = contactIdToAffiliation.get(otherAffiliation.ucinn_ascendv2__Contact__c);
                        if (errorAffiliationIdSet.contains(affToThrowError.Id) == false) {
                            errorAffiliationIdSet.add(affToThrowError.Id);
                            affToThrowError.addError('A consituent can only have one primary employment.');
                        }
                    }
                    else {
                        if(otherAffiliation.Is_Primary_Employment__c == true){
                            otherAffiliation.ucinn_ascendv2__Status__c = 'Former';
                            otherAffiliation.ucinn_ascendv2__End_Date__c = date.today();
                        }
                        otherAffiliation.Is_Primary_Employment__c = false;

                    }
                }

                if (throwError == false) {
                    update otherAffiliationList;
                }
            }
        }
    }
    
    /*
    * Author: Notre Dame, Jay Rizzi - method was moved over from the class ND_Affiliation_Trigger_Handler
    * Date: 2/28/2023
    * Description: Method to inactivate email, phone, address
    *              Moved method from the class ND_Affiliation_Trigger_Handler
    */
    public static void inactivateRelatedBusinessComms(list<ucinn_ascendv2__Affiliation__c> affilsNew, list<ucinn_ascendv2__Affiliation__c> affilsOld) {

        set<Id> constIds = new set<Id>();
        set<id> AffilIds = new set<Id>();

        Integer affilsNewSize = affilsNew.size();
        for(Integer i = 0; i < affilsNewSize; i++) {
            if(affilsNew[i].ucinn_ascendv2__Status__c == 'Former' && affilsOld[i].ucinn_ascendv2__Status__c != 'Former'){
            /*if(affilsNew[i].Constituent__c != null) {
                constIds.add(affilsNew[i].Constituent__c);
            }*/      
            AffilIds.add(affilsNew[i].id);
            }
        }

        //can you make all these queries together
        
        list<ucinn_ascendv2__Email__c> EmailsUpdate = new list<ucinn_ascendv2__Email__c>();
        list<ucinn_ascendv2__Email__c> Emails = [select id, affiliation__c,  ucinn_ascendv2__Status__c from ucinn_ascendv2__Email__c where affiliation__c in :AffilIds];
        list<ucinn_ascendv2__Phone__c> PhonesUpdate = new list<ucinn_ascendv2__Phone__c>();
        list<ucinn_ascendv2__Phone__c> Phones = [select id, affiliation__c,  ucinn_ascendv2__Status__c from ucinn_ascendv2__Phone__c where affiliation__c in :AffilIds];
        list<ucinn_ascendv2__Address_Relation__c> AddressesUpdate = new list<ucinn_ascendv2__Address_Relation__c>();
        list<ucinn_ascendv2__Address_Relation__c> Addresses = [select id, affiliation__c,  ucinn_ascendv2__Status__c from ucinn_ascendv2__Address_Relation__c where affiliation__c in :AffilIds];
        
        for (ucinn_ascendv2__Email__c em : Emails){
            em.ucinn_ascendv2__Status__c = 'Former';
            em.ucinn_ascendv2__Is_Preferred__c = false;
            em.ucinn_ascendv2__End_Date__c= system.today();
            EmailsUpdate.add(em);
        }
        update EmailsUpdate;

        for (ucinn_ascendv2__Phone__c ph : Phones){
            ph.ucinn_ascendv2__Status__c = 'Former';
            ph.ucinn_ascendv2__Is_Preferred__c = false;
            ph.ucinn_ascendv2__End_Date__c= system.today();
            PhonesUpdate.add(ph);
        }
        update PhonesUpdate;

        for (ucinn_ascendv2__Address_Relation__c ad : Addresses){
            ad.ucinn_ascendv2__Status__c = 'Former';
            ad.ucinn_ascendv2__Is_Preferred__c = false;
            ad.ucinn_ascendv2__End_Date__c= system.today();
            AddressesUpdate.add(ad);
        }
        update AddressesUpdate;



        //hold my beer
        /*
        list<ucinn_ascendv2__Affiliation__c> affilRelations = [select id, (select Id, ucinn_ascendv2__Status__c from Address_Relations__r)
        , (select Id, ucinn_ascendv2__Status__c from Emails__r), (select id, ucinn_ascendv2__Status__c from Phones__r)
        from ucinn_ascendv2__Affiliation__c
        where id in :AffilIds];
        */



    }

}