@isTest
private class nd_UpdateIsActiveWhenEndDateIsPastTest {
	@testSetup
    private static void setup(){
		Contact con = new Contact(Firstname = 'TestFirst', LastName = 'TestLast', Email = 'testemail@test.com',Constituent_Status__c='A');
        insert con;
        
        Date startDate = date.newinstance(2019, 2, 17);
        Date endDate = date.newinstance(2021, 2, 17);

        ucinn_ascendv2__Service_Indicator_Value__c si1 = new ucinn_ascendv2__Service_Indicator_Value__c(Name = 'Test1', Public_Name__c = 'Test1', Public__c = TRUE, nd_MID__c = '524005560');
        ucinn_ascendv2__Service_Indicator_Value__c si2 = new ucinn_ascendv2__Service_Indicator_Value__c(Name = 'Test2', Public_Name__c = 'Test2', Public__c = TRUE, nd_MID__c = '524005560');
        insert new list<ucinn_ascendv2__Service_Indicator_Value__c>{si1, si2};
        
        ucinn_ascendv2__Service_Indicator__c lm = new ucinn_ascendv2__Service_Indicator__c(ucinn_ascendv2__Service_Indicator_Value__c = si2.Id, ucinn_ascendv2__Contact__c = con.Id, Status__c = 'Exclude', nd_Comments__c = '',Data_Source__c='MC',ucinn_ascendv2__Is_Active__c=true,ucinn_ascendv2__Start_Date__c= startDate,ucinn_ascendv2__End_Date__c=endDate);
    	insert lm;
    }
    
    @isTest
    private static void updateEndDate(){
      //  list<ucinn_ascendv2__Service_Indicator__c> si = [SELECT Id, ucinn_ascendv2__Start_Date__c, ucinn_ascendv2__End_Date__c,ucinn_ascendv2__Is_Active__c FROM ucinn_ascendv2__Service_Indicator__c limit 1]; 
        Test.startTest();
        nd_UpdateIsActiveWhenEndDateIsPast u = new nd_UpdateIsActiveWhenEndDateIsPast();
        DataBase.executeBatch(u); 
        Test.stopTest();
    }
    
    @istest
    public static void checkSendEmail(){
        test.startTest();
        nd_UpdateIsActiveWhenEndDateIsPast n = new nd_UpdateIsActiveWhenEndDateIsPast();
        n.sendEmail('error message');        
        test.stopTest();
    }
    
    @isTest
    static void scheduleBatch() {        
        test.starttest();
        nd_UpdateIsActiveWhenEndDateIsPast n = new nd_UpdateIsActiveWhenEndDateIsPast();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, n);
        test.stopTest();
    }
}