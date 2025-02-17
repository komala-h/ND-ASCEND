public class AnnouncementController {

    @AuraEnabled(cacheable=true)
    public static List<nd_Announcements__c> getAnnouncements(){
        try {
            return [SELECT id,nd_Subject__c, Name, nd_Message__c FROM nd_Announcements__c WHERE nd_Status__c = 'Active' ORDER BY nd_Order__c ASC];
        } catch (Exception e) {throw new AuraHandledException(e.getMessage());}
    }

    @AuraEnabled(cacheable=true)
    public static Beat_Alert_Setting__mdt getCMT(){

            return [SELECT id, Link__c FROM Beat_Alert_Setting__mdt WHERE DeveloperName = 'Announcement_Files_and_Guidelines' LIMIT 1];
        
    }

}