public with sharing class ND_Utilities {
    /*Method returns queryString with all the fields on the specified Object*/
    public static string getQuery(string objectName, string whereClause) {
        string query = 'SELECT ';
        
        for(Schema.SObjectField ft : Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap().values()){
            Schema.DescribeFieldResult fd = ft.getDescribe();
            query += fd.getName() + ',';  
        }
                  
        query = query.removeEnd(',') + ' FROM ' + objectName;
        
        if(string.isNotBlank(whereClause)) {
            query += ' WHERE ' + whereClause; 
        }
        return query;
    } 
    
    //Get the salesforce account Id for Univ of Notre Dame
    public static Id queryforUNDId(){
       List<Account> acct = [SELECT Id FROM Account WHERE ucinn_ascendv2__Donor_ID__c = '307129' LIMIT 1];
       if(acct.size()>0){
           return acct[0].Id;
       } else {
           return null;
       }
    }   

}