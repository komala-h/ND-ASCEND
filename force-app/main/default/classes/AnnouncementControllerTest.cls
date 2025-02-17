@isTest
public class AnnouncementControllerTest {
    
    
    @isTest
    
    static void method1(){
        nd_Announcements__c a = new nd_Announcements__c(nd_Message__c='test',nd_Subject__c='Test');
        Insert a;
  		//AnnouncementController ac;
        AnnouncementController.getAnnouncements();
        AnnouncementController.getCMT();
    }
}