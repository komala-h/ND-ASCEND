/**
 * @author UC Innovation
 * @date 4/26/2021
 * @group Button Extension
 * @description Extension for BTN_CloseCase
 */
public with sharing class BTN_CloseCaseExtension {
    public Case c {get;set;}
    public String errormsg {get;set;}
    
    public BTN_CloseCaseExtension(ApexPages.standardController controller){
        loadCase( ((Case)controller.getRecord()).Id );
    }
    
    /*******************************************************************************************************
     * @description Method to load case
     * @param caseId The case Id
     * @return N/A
     */
    private void loadCase(String caseId) {
        List<Case> caseList = [Select Id, ContactId, Notification_Type__c, Confirmed_Death_Date__c, Death_Date__c From Case Where Id = :caseId];
        if (!caseList.isEmpty()) {
            c = caseList[0];
        }
    }
    
    /*******************************************************************************************************
     * @description Method to close case
     * @return N/A
     */
    public PageReference closeCase(){
        List<Contact> updateContactList = new List<Contact>();
        List<String> errormsgList = new List<String>();
        
        // Validate
        if (c.Notification_Type__c == null) {
            errormsgList.add('Please enter Notification Type');
        }
        if (c.Death_Date__c != null && c.Death_Date__c > Date.today()) {
            errormsgList.add('Death Date cannot be in the future');
        } 
        if (c.Notification_Type__c == 'Obituary' && c.Confirmed_Death_Date__c == null) {
            errormsgList.add('Please enter Confirmed Death Date');
        } 
        if (c.Notification_Type__c != 'Obituary' && c.Confirmed_Death_Date__c != null) {
            errormsgList.add('Confirmed Death Date must be blank');
        } 
        if ((c.Notification_Type__c != null || c.Confirmed_Death_Date__c != null) && c.Death_Date__c == null) {
            errormsgList.add('Please enter Death Date');
        }
        
        if (!errormsgList.isEmpty()) {
            errormsg = String.join(errormsgList, '<br/>');
        } else {
            if (c.Notification_Type__c == 'Obituary' && c.ContactId != null) {
                
                c.Status = 'Closed';
                update c;
                
                for (Contact con : [Select Id, ucinn_ascendv2__Date_Marked_Deceased__c, ucinn_ascendv2__Deceased_Date__c, ucinn_ascendv2__Deceased_Source__c From Contact Where Id = :c.ContactId]) {
                    con.ucinn_ascendv2__Date_Marked_Deceased__c = c.Confirmed_Death_Date__c;
                    con.ucinn_ascendv2__Deceased_Source__c = c.Notification_Type__c;
                    
                    if (c.Death_Date__c != null) {
                        con.ucinn_ascendv2__Deceased_Date__c = c.Death_Date__c;
                        con.ucinn_ascendv2__Deceased_Day__c = ((String.valueOf(c.Death_Date__c.day()).length() == 1) ? '0' : '') + String.valueOf(c.Death_Date__c.day());
                        con.ucinn_ascendv2__Deceased_Month__c = ((String.valueOf(c.Death_Date__c.month()).length() == 1) ? '0' : '') + String.valueOf(c.Death_Date__c.month());
                        con.ucinn_ascendv2__Deceased_Year__c = String.valueOf(c.Death_Date__c.year());
                    }
                    
                    updateContactList.add(con);
                }
                
                if (!updateContactList.isEmpty()) {
                    update updateContactList;
                }
                
                System.debug('#### updateContactList: '+updateContactList);
                
            }
            
            PageReference newpage = new PageReference('/'+c.Id);
            return newpage.setRedirect(true);
        }
        return null;
    }
}