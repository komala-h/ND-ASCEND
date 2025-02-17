/**
 * @author UC Innovation
 * @date 8/29/2021
 * @group Aura Controller
 * @description Controller for CaseRelatedList controller
 */
public with sharing class asc_BIO_CaseRelatedListController {

    /**
    * Method to return the case record
    * @param caseId The case id
    * @return Case record
    */
    @AuraEnabled
    public static Case getCase(String caseId) {
        List<Case> caseList = [Select Id, AccountId, ContactId From Case Where Id = :caseId];
        if (!caseList.isEmpty()) {
            return caseList[0];
        }
        return null;
    }
}