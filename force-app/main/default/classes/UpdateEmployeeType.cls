public class UpdateEmployeeType {

    @InvocableMethod( label='Update Constituent Type')    
    public static List<outputParam> updateConstituent(List<inputParams> records) {
        system.debug('#'+records[0]); 
       // Map<Id,Id> conRecordsmap = new Map<Id,Id>();
        Set<Id> contactIds = new Set<Id>();
        Map<Id, String> contactRoleMap = new Map<Id, String>(); 
        List<contact> updateCon = new List<contact>();
        string ls = records[0].action;
        system.debug('#'+ls);
        for(ucinn_ascendv2__Affiliation__c aff : records[0].affiliations){
            //conRecordsmap.put(aff.Id,aff.ucinn_ascendv2__Contact__c);
            contactIds.add(aff.ucinn_ascendv2__Contact__c);
            contactRoleMap.put(aff.ucinn_ascendv2__Contact__c, aff.ucinn_ascendv2__Constituent_Role__c);
        }
        //for(contact c: [Select id,ucinn_ascendv2__Contact_Type__c from contact where id=:conRecordsmap.values() ]){
            
            /*if(ls=='D' ||  ls=='NLW'){
            	c.ucinn_ascendv2__Contact_Type__c=c.ucinn_ascendv2__Contact_Type__c.replaceALL('EM','EF');
                updateCon.add(c);
            }*/
       
        for (Contact c : [SELECT Id, ucinn_ascendv2__Contact_Type__c FROM Contact WHERE Id IN :contactIds]) {
            String role = contactRoleMap.get(c.Id);
             // If constituent is deceased,check for whether they are ND Active Employee/Retired Employee 
            if ( ls == 'D' && role == 'Employee') {
                    c.ucinn_ascendv2__Contact_Type__c = c.ucinn_ascendv2__Contact_Type__c.replaceALL('EM', 'EF');
                } else if (ls == 'D' && role == 'Retired Employee' && c.ucinn_ascendv2__Contact_Type__c.contains('EM')) {
                    c.ucinn_ascendv2__Contact_Type__c = c.ucinn_ascendv2__Contact_Type__c.replaceALL('EM', 'ER');
                } else if (ls == 'NLW') {
                    c.ucinn_ascendv2__Contact_Type__c = c.ucinn_ascendv2__Contact_Type__c.replaceALL('EM', 'EF');
                } else if (ls == 'R') {
                    c.ucinn_ascendv2__Contact_Type__c = c.ucinn_ascendv2__Contact_Type__c.replaceALL('EM', 'ER');
                }

                updateCon.add(c);
        }
        List<outputParam> opList = new List<outputParam>();
        outputParam obj = new outputParam();
        obj.contacts =updateCon;
        opList.add(obj);
        
        return opList;
    } 
    
    public class inputParams{
        @InvocableVariable 
         public List<ucinn_ascendv2__Affiliation__c> affiliations;
        @InvocableVariable  
         public string action;
    }
    
    public class outputParam{
        @InvocableVariable 
         public List<contact> contacts;  
        
    }
}