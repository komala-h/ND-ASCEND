/**
 * @author UC Innovation
 * @date 9/9/2021
 * @group Aura Controller
 * @description Controller for ExtendedRelatedList controller
 */
public with sharing class asc_BIO_ExtendedRelatedListController {

    /**
    * Method to return the sobject record
    * @param objectName The sobject name
    * @param objectName The field name
    * @param recordId The record id
    * @return Record
    */
    @AuraEnabled
    public static Sobject getRecord(String objectName, String fieldName, String recordId) {
        List<String> fieldnames = new List<String>();
        fieldnames.add('Id');
        
        if (!fieldnames.contains(fieldName)) {
            fieldnames.add(fieldName);
        }
        
        List<Sobject> objList = Database.query('Select ' + String.join(fieldnames, ', ') + ' From ' + objectName + ' Where Id = :recordId');
        if (!objList.isEmpty()) {
            return objList[0];
        }
        return null;
    }
    
    /**
    * Method to return the list of Ids
    * @param query The query string
    * @return List of Ids
    */
    @AuraEnabled
    public static List<Id> getJunctionInnerQueryIds(String query) {
        List<Id> idList = new List<Id>();
        for (Sobject obj :  Database.query(query)) {
            idList.add((Id)obj.get('Id'));
        }
        return idList;
    }
}