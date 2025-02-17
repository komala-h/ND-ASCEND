/*
 * Test class for : ND_ManageSeasonalAddressBatch
 * 
*/
@isTest
private class ND_ManageSeasonalAddressBatchTest {
	@testSetup
    public static void setup(){
        ucinn_ascendv2__Trigger_Handler__c addRelHandler2 = new ucinn_ascendv2__Trigger_Handler__c();
        addRelHandler2.Name = 'Custom Address Relation Handler';
        addRelHandler2.ucinn_ascendv2__Class__c = 'ND_ManageSeasonalAddressBatch';
        addRelHandler2.ucinn_ascendv2__Is_Active__c = true;
        addRelHandler2.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Address_Relation__c';
        addRelHandler2.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;BeforeDelete;AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
        addRelHandler2.ucinn_ascendv2__Load_Order__c = 3;
        insert addRelHandler2;
            
        Id householdRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();

        Account household01 = new Account();
        household01.Name = 'TEST HOUSEHOLD 01';
        household01.BillingStreet = 'Test St';
        household01.BillingCity = 'City of Test';
        household01.BillingCountry = 'United States';
        household01.RecordTypeId = householdRecTypeId;
        insert household01;
        
        Contact h01 = new Contact();
        h01.AccountId = household01.Id;
        h01.FirstName = 'h01';
        h01.LastName = 'TEST';
        h01.ucinn_ascendv2__Gender__c = 'Male';
        h01.ucinn_ascendv2__Contact_Type__c = 'AL';
        h01.ucinn_ascendv2__Personal_Email__c = 'sample@abc.com';
        h01.Constituent_Status__c = 'A';
        h01.ucinn_ascendv2__Preferred_Class_Year__c = '2014';
        insert h01;
        
        Contact w01 = new Contact();
        w01.AccountId = household01.Id;
        w01.FirstName = 'w01';
        w01.LastName = 'TEST';
        w01.ucinn_ascendv2__Gender__c = 'Female';
        w01.ucinn_ascendv2__Contact_Type__c = 'AL';
        w01.ucinn_ascendv2__Personal_Email__c = 'sample2@abc.com';
        w01.Constituent_Status__c = 'A';
        w01.ucinn_ascendv2__Preferred_Class_Year__c = '2015';
        insert w01;
        
        household01.ucinn_ascendv2__Primary_Contact__c = h01.Id;
        household01.Secondary_Constituent__c = w01.Id;
        update household01;
        
        ucinn_ascendv2__Address__c add01 = new ucinn_ascendv2__Address__c();
        add01.Name = 'TEST Address 01';
        add01.ucinn_ascendv2__Address_Line_1__c = 'Test 01 ave';
        add01.ucinn_ascendv2__City__c = 'City';
        add01.ucinn_ascendv2__State__c = 'CA';
        add01.ucinn_ascendv2__Country__c = 'United States';
        insert add01;
        
        ucinn_ascendv2__Address__c add02 = new ucinn_ascendv2__Address__c();
        add02.Name = 'TEST Address 02';
        add02.ucinn_ascendv2__Address_Line_1__c = 'Tests 02 ave';
        add02.ucinn_ascendv2__City__c = 'Citsy';
        add02.ucinn_ascendv2__State__c = 'CA';
        add02.ucinn_ascendv2__Country__c = 'United States';
        insert add02;
        
        Id conAddRelRecTypeId = Schema.SObjectType.ucinn_ascendv2__Address_Relation__c.getRecordTypeInfosByName().get('Constituent Address Relation').getRecordTypeId();

        ucinn_ascendv2__Address_Relation__c addrel = new ucinn_ascendv2__Address_Relation__c();
        addrel.ucinn_ascendv2__Address__c = add01.Id;
        addrel.ucinn_ascendv2__Account__c = h01.AccountId;
        addrel.ucinn_ascendv2__Contact__c = h01.Id;
        addrel.ucinn_ascendv2__Status__c = 'Current';
        addrel.ucinn_ascendv2__Type__c = 'H';
        addrel.RecordTypeId = conAddRelRecTypeId;
        insert addrel;
        
        Date TODAY = Date.Today();
        String TodayDay = String.valueOf(TODAY.Day());
        if(TODAY.Day()<10){
            TodayDay = '0'+TodayDay;
        }
        String TodayMonth = String.valueOf(TODAY.Month());
        if(TODAY.Month()<10){
            TodayMonth = '0'+TodayMonth;
        }
       
        ucinn_ascendv2__Address_Relation__c addrelseasonal = new ucinn_ascendv2__Address_Relation__c();
        addrelseasonal.ucinn_ascendv2__Address__c = add01.Id;
        addrelseasonal.ucinn_ascendv2__Account__c = h01.AccountId;
        addrelseasonal.ucinn_ascendv2__Contact__c = h01.Id;
        addrelseasonal.ucinn_ascendv2__Status__c = 'Current';
        addrelseasonal.ucinn_ascendv2__Type__c = 'Seasonal';
        addrelseasonal.RecordTypeId = conAddRelRecTypeId;
        addrelseasonal.ucinn_ascendv2__Seasonal_Start_Day__c=String.valueOf(TodayDay);
        addrelseasonal.ucinn_ascendv2__Seasonal_Start_Month__c=String.valueOf(TodayMonth);
   //     addrelseasonal.ucinn_ascendv2__Seasonal_Start_Year__c=String.valueOf(TODAY.year());
        addrelseasonal.ucinn_ascendv2__Seasonal_End_Day__c= String.valueOf(TodayDay);
        addrelseasonal.ucinn_ascendv2__Seasonal_End_Month__c=String.valueOf(TodayMonth);
     //   addrelseasonal.ucinn_ascendv2__Seasonal_End_Year__c=String.valueOf(TODAY.year());
        addrelseasonal.In_Season__c=false;
        insert addrelseasonal;
        
        Date FIVEDAYSBEFORETODAY = system.today().adddays(-5);
        String FiveDayPastDay = String.valueOf(FIVEDAYSBEFORETODAY.Day());
        if(FIVEDAYSBEFORETODAY.Day()<10){
            FiveDayPastDay = '0'+FiveDayPastDay;
        }
        String FivedayPastMonth = String.valueOf(FIVEDAYSBEFORETODAY.Month());
        if(FIVEDAYSBEFORETODAY.Month()<10){
            FivedayPastMonth = '0'+FivedayPastMonth;
        }
        
        Date ONEDAYBEFORETODAY = system.today().adddays(-1);
        String OneDayPastDay = String.valueOf(ONEDAYBEFORETODAY.Day());
        if(ONEDAYBEFORETODAY.Day()<10){
            OneDayPastDay = '0'+OneDayPastDay;
        }
        String OnedayPastMonth = String.valueOf(ONEDAYBEFORETODAY.Month());
        if(ONEDAYBEFORETODAY.Month()<10){
            OnedayPastMonth = '0'+OnedayPastMonth;
        }
        
        ucinn_ascendv2__Address_Relation__c addrelseasonalSpouse = new ucinn_ascendv2__Address_Relation__c();
        addrelseasonalSpouse.ucinn_ascendv2__Address__c = add02.Id;
        addrelseasonalSpouse.ucinn_ascendv2__Account__c = w01.AccountId;
        addrelseasonalSpouse.ucinn_ascendv2__Contact__c = w01.Id;
        addrelseasonalSpouse.ucinn_ascendv2__Status__c = 'Current';
        addrelseasonalSpouse.ucinn_ascendv2__Type__c = 'Seasonal';
        addrelseasonalSpouse.RecordTypeId = conAddRelRecTypeId;
        addrelseasonalSpouse.ucinn_ascendv2__Seasonal_Start_Day__c=String.valueOf(FiveDayPastDay);
    //    addrelseasonalSpouse.ucinn_ascendv2__Seasonal_Start_Month__c=String.valueOf(FiveDayPastMonth);
        addrelseasonalSpouse.ucinn_ascendv2__Seasonal_Start_Month__c=String.valueOf(OnedayPastMonth);
     //   addrelseasonalSpouse.ucinn_ascendv2__Seasonal_Start_Year__c=String.valueOf(TODAY.year());
     
    //    addrelseasonalSpouse.ucinn_ascendv2__Seasonal_End_Day__c= String.valueOf(OneDayPastDay);
        addrelseasonalSpouse.ucinn_ascendv2__Seasonal_End_Day__c= String.valueOf(TodayDay);
     //   addrelseasonalSpouse.ucinn_ascendv2__Seasonal_End_Month__c=String.valueOf(OnedayPastMonth);
        addrelseasonalSpouse.ucinn_ascendv2__Seasonal_End_Month__c=String.valueOf(TodayMonth);
     //   addrelseasonalSpouse.ucinn_ascendv2__Seasonal_End_Year__c=String.valueOf(TODAY.year());
        addrelseasonalSpouse.In_Season__c= false;
        insert addrelseasonalSpouse;
                
    }
    /*
    @istest
    public static void TestwhenrecordIsinSeason(){
        ucinn_ascendv2__Address__c addr = [select id , name from  ucinn_ascendv2__Address__c  limit 1];
        ucinn_ascendv2__Address_Relation__c ar=[select id,ucinn_ascendv2__Address__r.ucinn_ascendv2__Address_Line_1__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__Address_Line_2__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__Address_Line_3__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__Address_Line_4__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__City__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__State__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__Country__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__Postal_Code__c,ucinn_ascendv2__Contact__r.Seasonal_City__c,ucinn_ascendv2__Contact__r.Seasonal_State__c,ucinn_ascendv2__Contact__r.Seasonal_Country__c,ucinn_ascendv2__Contact__r.Seasonal_Address_Line_1__c, ucinn_ascendv2__Contact__r.Seasonal_Address_Line_2__c, ucinn_ascendv2__Contact__r.Seasonal_Address_Line_3__c, ucinn_ascendv2__Contact__r.Seasonal_Address_Line_4__c ,ucinn_ascendv2__Contact__r.Seasonal_Zip_Postal_Code__c,ucinn_ascendv2__Address__c,ucinn_ascendv2__Contact__c, ucinn_ascendv2__Seasonal_Start_Day__c, ucinn_ascendv2__Seasonal_Start_Month__c, ucinn_ascendv2__Seasonal_Start_Year__c, ucinn_ascendv2__Seasonal_End_Day__c, ucinn_ascendv2__Seasonal_End_Month__c, ucinn_ascendv2__Seasonal_End_Year__c,In_Season__c, ucinn_ascendv2__Type__c, ucinn_ascendv2__Status__c FROM ucinn_ascendv2__Address_Relation__c WHERE ucinn_ascendv2__Address__c =: addr.id limit 1];
        ar.In_Season__c = false;
        Test.startTest();
      	ND_ManageSeasonalAddressBatch t = new ND_ManageSeasonalAddressBatch();	DataBase.executeBatch(t,200);
		Test.stopTest();
    }
    
    @istest
    public static void TestWhenrecordIsOutOfSeason(){
        Contact con = [select id,FirstName,LastName from Contact where FirstName='w01' AND LastName = 'TEST' limit 1];
        ucinn_ascendv2__Address_Relation__c ar=[select id,ucinn_ascendv2__Address__r.ucinn_ascendv2__Address_Line_1__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__Address_Line_2__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__Address_Line_3__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__Address_Line_4__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__City__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__State__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__Country__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__Postal_Code__c,ucinn_ascendv2__Contact__r.Seasonal_City__c,ucinn_ascendv2__Contact__r.Seasonal_State__c,ucinn_ascendv2__Contact__r.Seasonal_Country__c,ucinn_ascendv2__Contact__r.Seasonal_Address_Line_1__c, ucinn_ascendv2__Contact__r.Seasonal_Address_Line_2__c, ucinn_ascendv2__Contact__r.Seasonal_Address_Line_3__c, ucinn_ascendv2__Contact__r.Seasonal_Address_Line_4__c ,ucinn_ascendv2__Contact__r.Seasonal_Zip_Postal_Code__c,ucinn_ascendv2__Address__c,ucinn_ascendv2__Contact__c, ucinn_ascendv2__Seasonal_Start_Day__c, ucinn_ascendv2__Seasonal_Start_Month__c, ucinn_ascendv2__Seasonal_Start_Year__c, ucinn_ascendv2__Seasonal_End_Day__c, ucinn_ascendv2__Seasonal_End_Month__c, ucinn_ascendv2__Seasonal_End_Year__c,In_Season__c, ucinn_ascendv2__Type__c, ucinn_ascendv2__Status__c FROM ucinn_ascendv2__Address_Relation__c WHERE ucinn_ascendv2__Contact__c =: con.id limit 1];
    	
        Test.startTest();
      	ND_ManageSeasonalAddressBatch t = new ND_ManageSeasonalAddressBatch();	DataBase.executeBatch(t,200);
		Test.stopTest();
    }
    */
    @istest
    public static void TestwhenrecordIsinSeason1(){
        ucinn_ascendv2__Address__c addr = [select id , name from  ucinn_ascendv2__Address__c where name='TEST Address 01' limit 1];
        ucinn_ascendv2__Address_Relation__c ar=[select id,ucinn_ascendv2__Address__r.ucinn_ascendv2__Address_Line_1__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__Address_Line_2__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__Address_Line_3__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__Address_Line_4__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__City__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__State__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__Country__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__Postal_Code__c,ucinn_ascendv2__Contact__r.Seasonal_City__c,ucinn_ascendv2__Contact__r.Seasonal_State__c,ucinn_ascendv2__Contact__r.Seasonal_Country__c,ucinn_ascendv2__Contact__r.Seasonal_Address_Line_1__c, ucinn_ascendv2__Contact__r.Seasonal_Address_Line_2__c, ucinn_ascendv2__Contact__r.Seasonal_Address_Line_3__c, ucinn_ascendv2__Contact__r.Seasonal_Address_Line_4__c ,ucinn_ascendv2__Contact__r.Seasonal_Zip_Postal_Code__c,ucinn_ascendv2__Address__c,ucinn_ascendv2__Contact__c, ucinn_ascendv2__Seasonal_Start_Day__c, ucinn_ascendv2__Seasonal_Start_Month__c, ucinn_ascendv2__Seasonal_Start_Year__c, ucinn_ascendv2__Seasonal_End_Day__c, ucinn_ascendv2__Seasonal_End_Month__c, ucinn_ascendv2__Seasonal_End_Year__c,In_Season__c, ucinn_ascendv2__Type__c, ucinn_ascendv2__Status__c FROM ucinn_ascendv2__Address_Relation__c WHERE ucinn_ascendv2__Address__c =: addr.id limit 1];
        ar.In_Season__c = false;
        ar.ucinn_ascendv2__Seasonal_End_Year__c=null;
        Update ar;
        Test.startTest();
      	ND_ManageSeasonalAddressBatch t = new ND_ManageSeasonalAddressBatch();	DataBase.executeBatch(t,200);
		Test.stopTest();
    }
    
    @istest
    public static void TestwhenrecordIsinSeason2(){
        ucinn_ascendv2__Address__c addr = [select id , name from  ucinn_ascendv2__Address__c where name='TEST Address 02' limit 1];
        ucinn_ascendv2__Address_Relation__c ar=[select id,ucinn_ascendv2__Address__r.ucinn_ascendv2__Address_Line_1__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__Address_Line_2__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__Address_Line_3__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__Address_Line_4__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__City__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__State__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__Country__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__Postal_Code__c,ucinn_ascendv2__Contact__r.Seasonal_City__c,ucinn_ascendv2__Contact__r.Seasonal_State__c,ucinn_ascendv2__Contact__r.Seasonal_Country__c,ucinn_ascendv2__Contact__r.Seasonal_Address_Line_1__c, ucinn_ascendv2__Contact__r.Seasonal_Address_Line_2__c, ucinn_ascendv2__Contact__r.Seasonal_Address_Line_3__c, ucinn_ascendv2__Contact__r.Seasonal_Address_Line_4__c ,ucinn_ascendv2__Contact__r.Seasonal_Zip_Postal_Code__c,ucinn_ascendv2__Address__c,ucinn_ascendv2__Contact__c, ucinn_ascendv2__Seasonal_Start_Day__c, ucinn_ascendv2__Seasonal_Start_Month__c, ucinn_ascendv2__Seasonal_Start_Year__c, ucinn_ascendv2__Seasonal_End_Day__c, ucinn_ascendv2__Seasonal_End_Month__c, ucinn_ascendv2__Seasonal_End_Year__c,In_Season__c, ucinn_ascendv2__Type__c, ucinn_ascendv2__Status__c FROM ucinn_ascendv2__Address_Relation__c WHERE ucinn_ascendv2__Address__c =: addr.id limit 1];
        ar.In_Season__c = false;
        ar.ucinn_ascendv2__Seasonal_End_Year__c=null;
        Update ar;
        Test.startTest();
      	ND_ManageSeasonalAddressBatch t = new ND_ManageSeasonalAddressBatch();	DataBase.executeBatch(t,200);
		Test.stopTest();
    }
    
    @istest
    public static void TestwhenrecordIsNotinSeason2(){
        Date ONEDAYBEFORETODAY = system.today().adddays(-1);
        String OneDayPastDay = String.valueOf(ONEDAYBEFORETODAY.Day());
        if(ONEDAYBEFORETODAY.Day()<10){
            OneDayPastDay = '0'+OneDayPastDay;
        }
        String OnedayPastMonth = String.valueOf(ONEDAYBEFORETODAY.Month());
        if(ONEDAYBEFORETODAY.Month()<10){
            OnedayPastMonth = '0'+OnedayPastMonth;
        }
        
        ucinn_ascendv2__Address__c addr = [select id , name from  ucinn_ascendv2__Address__c where name='TEST Address 02' limit 1];
        ucinn_ascendv2__Address_Relation__c ar=[select id,ucinn_ascendv2__Address__r.ucinn_ascendv2__Address_Line_1__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__Address_Line_2__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__Address_Line_3__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__Address_Line_4__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__City__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__State__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__Country__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__Postal_Code__c,ucinn_ascendv2__Contact__r.Seasonal_City__c,ucinn_ascendv2__Contact__r.Seasonal_State__c,ucinn_ascendv2__Contact__r.Seasonal_Country__c,ucinn_ascendv2__Contact__r.Seasonal_Address_Line_1__c, ucinn_ascendv2__Contact__r.Seasonal_Address_Line_2__c, ucinn_ascendv2__Contact__r.Seasonal_Address_Line_3__c, ucinn_ascendv2__Contact__r.Seasonal_Address_Line_4__c ,ucinn_ascendv2__Contact__r.Seasonal_Zip_Postal_Code__c,ucinn_ascendv2__Address__c,ucinn_ascendv2__Contact__c, ucinn_ascendv2__Seasonal_Start_Day__c, ucinn_ascendv2__Seasonal_Start_Month__c, ucinn_ascendv2__Seasonal_Start_Year__c, ucinn_ascendv2__Seasonal_End_Day__c, ucinn_ascendv2__Seasonal_End_Month__c, ucinn_ascendv2__Seasonal_End_Year__c,In_Season__c, ucinn_ascendv2__Type__c, ucinn_ascendv2__Status__c FROM ucinn_ascendv2__Address_Relation__c WHERE ucinn_ascendv2__Address__c =: addr.id limit 1];
       
         //    addrelseasonalSpouse.ucinn_ascendv2__Seasonal_End_Day__c= String.valueOf(OneDayPastDay);
        ar.ucinn_ascendv2__Seasonal_End_Day__c= String.valueOf(OneDayPastDay);
     //   addrelseasonalSpouse.ucinn_ascendv2__Seasonal_End_Month__c=String.valueOf(OnedayPastMonth);
        ar.ucinn_ascendv2__Seasonal_End_Month__c=String.valueOf(OnedayPastMonth);
        ar.ucinn_ascendv2__Seasonal_End_Year__c=String.valueOf(system.today().year());
        ar.In_Season__c= true;
        Update ar;
        Test.startTest();
      	ND_ManageSeasonalAddressBatch t = new ND_ManageSeasonalAddressBatch();	DataBase.executeBatch(t,200);
		Test.stopTest();
    }
    
    static testMethod void scheduleBatch() {        
        test.starttest();
        ND_ManageSeasonalAddressBatch i = new ND_ManageSeasonalAddressBatch();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, i);
        test.stopTest();
    }

}