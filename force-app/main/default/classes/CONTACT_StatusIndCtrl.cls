/**
 * This is a server side controller to help with the constituent to show various indicators
 * on contact lightning record page
 *
 * @author:  UCInnovation
 * @version: 1.0
 * @since:   1.0
 */
public without sharing class CONTACT_StatusIndCtrl {
    @AuraEnabled
    public static Map<String, Object> SERVER_QueryRecord(Id recordId, String parentObject, String queryField){
        String query = 'SELECT ID, ' + queryField + ' FROM ' + parentObject + ' WHERE ID = \'' + recordId + '\'';
        
        SObject resultObject = Database.query(query);
        System.debug('recordId: ' + recordId + ', queryFied: ' + queryField + ', result: ' + resultObject.get(queryField));

        Map<String, Object> result = new Map<String, Object>();
        result.put(queryField, resultObject.get(queryField));
        
        if (parentObject == 'Contact' && queryField == 'Is_Lost__c')  {
            List<ucinn_ascendv2__Email__c> emailList = [SELECT Id FROM ucinn_ascendv2__Email__c WHERE ucinn_ascendv2__Status__c = 'Current' AND ucinn_ascendv2__Contact__c = :recordId];
            List<ucinn_ascendv2__Phone__c> phoneList = [SELECT Id FROM ucinn_ascendv2__Phone__c WHERE ucinn_ascendv2__Status__c = 'Current' AND ucinn_ascendv2__Contact__c = :recordId];
            List<ucinn_ascendv2__Address_Relation__c> addressRelationList = [SELECT Id FROM ucinn_ascendv2__Address_Relation__c WHERE ucinn_ascendv2__Status__c = 'Current' AND ucinn_ascendv2__Contact__c = :recordId];
            if (!emailList.isEmpty() || !phoneList.isEmpty() || !addressRelationList.isEmpty()) {
                result.put('Is_Lost__c', false);
            }
        }     
        
        return result;
    }
}