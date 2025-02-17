@isTest
public class nd_UpdateSFMCSyncTest {
    
    @TestSetUp
    public static void setup(){

        Account a1 = new Account(name='Test Account 1');
        Account a2 = new Account(name='Test Account 2');
        insert new List<Account>{a1, a2};
        
        Id contactRecordtypeId= [select id from recordtype where sobjecttype='Contact' and developerName='Edit_Contact'].id;
        
        
        Contact c1 = new Contact(ucinn_ascendv2__Deceased_Source__c='OB',ND_Decease_Confirmed_Date__c=system.today(),ucinn_ascendv2__Date_Marked_Deceased__c=System.today(),accountid = a1.Id, firstname = 'John', lastname = 'Wood', Email='john@abc.com', Constituent_Status__c='D',nd_SFMC_Sync__c=true,recordtypeid=contactRecordtypeId );
        Contact c2 = new Contact(ucinn_ascendv2__Primary_Contact_Type__c='Alumni',accountid = a2.Id, firstname = 'David', lastname = 'Garry', Email='david@def.com', Constituent_Status__c='A',nd_SFMC_Sync__c=false,recordtypeid=contactRecordtypeId);
        insert new List<Contact>{c1, c2};
         
       /* ucinn_ascendv2__Service_Indicator_Value__c siv1 = new ucinn_ascendv2__Service_Indicator_Value__c(name='Do Not Phone');    
        ucinn_ascendv2__Service_Indicator_Value__c siv2 = new ucinn_ascendv2__Service_Indicator_Value__c(name='Do Not Call Business'); 
        ucinn_ascendv2__Service_Indicator_Value__c siv3 = new ucinn_ascendv2__Service_Indicator_Value__c(name='Never Mail'); 
        ucinn_ascendv2__Service_Indicator_Value__c siv4 = new ucinn_ascendv2__Service_Indicator_Value__c(name='Do Not Solicit');
        insert new List<ucinn_ascendv2__Service_Indicator_Value__c>{siv1, siv2, siv3, siv4};
            
        ucinn_ascendv2__Service_Indicator__c si1 = new ucinn_ascendv2__Service_Indicator__c(ucinn_ascendv2__Contact__c=c1.id, ucinn_ascendv2__Service_Indicator_Value__c=siv1.id,Data_Source__c='AC');
		ucinn_ascendv2__Service_Indicator__c si2 = new ucinn_ascendv2__Service_Indicator__c(ucinn_ascendv2__Contact__c=c1.id, ucinn_ascendv2__Service_Indicator_Value__c=siv2.id,Data_Source__c='AC');
    	ucinn_ascendv2__Service_Indicator__c si3 = new ucinn_ascendv2__Service_Indicator__c(ucinn_ascendv2__Contact__c=c2.id, ucinn_ascendv2__Service_Indicator_Value__c=siv3.id,Data_Source__c='Add');
		ucinn_ascendv2__Service_Indicator__c si4 = new ucinn_ascendv2__Service_Indicator__c(ucinn_ascendv2__Contact__c=c2.id, ucinn_ascendv2__Service_Indicator_Value__c=siv4.id,Data_Source__c='Add');
        insert new List<ucinn_ascendv2__Service_Indicator__c>{si1, si2, si3, si4};*/
    }
    
    @istest
    public static void testmethod1(){
        test.startTest();
        nd_UpdateSFMCSync n = new nd_UpdateSFMCSync();
        Id batchId = Database.executeBatch(n);    
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, n);        
        test.stopTest();
    }
    
    @istest
    public static void testmethod2(){
        test.startTest();
        nd_UpdateSFMCSync n = new nd_UpdateSFMCSync();
        n.sendEmail('error message');        
        test.stopTest();
    }
}