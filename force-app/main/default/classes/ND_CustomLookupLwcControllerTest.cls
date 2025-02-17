@isTest
public class ND_CustomLookupLwcControllerTest {

    
    
    public static void setupData(){
        
        Id HouseholdId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Household').getRecordTypeId();
        Id CorOrFounRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporations_and_Organizations').getRecordTypeId();
        List < Account > testAccts = new List < Account > ();
        
        Account hs= new Account(Name = 'TestAcct' ,recordTypeid=HouseholdId ,ND_Household_Category__c = 'R2',ND_Household_Types__c='R2',ucinn_ascendv2__PRM__c=null) ;
        Account cor= new Account(Online_Only__c=true,Name = 'TestAcct' ,recordTypeid=CorOrFounRecordTypeId ,ND_Household_Category__c = 'GP') ;
        testAccts.add(hs);
        testAccts.add(cor);
        Insert testAccts;
        
        
    }
    
    @isTest
    // Use to test fetchLookupData & fetchDefaultRecord method
    public static void fetchLookupDataTest(){
        //setupData();
        User usr = [Select id, name,isActive, email from User where id=: UserInfo.getUserId()];
        system.debug('User Info-'+usr);
        
        test.starttest();
        ND_CustomLookupLwcController.fetchLookupData(usr.name,'user');
        ND_CustomLookupLwcController.fetchDefaultRecord(usr.id,'user');
        test.stoptest();
    }
    
    @isTest
    public static void getAccountsTest1(){
        setupData();
        Id HouseholdId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Household').getRecordTypeId();
        Id CorOrFounRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporations_and_Organizations').getRecordTypeId();
        List < Account > testAccts = new List < Account > ();
        
        Account hs= new Account(Name = 'TestAcct' ,recordTypeid=HouseholdId ,ND_Household_Category__c = 'R2',ND_Household_Types__c='R2',ucinn_ascendv2__PRM__c=null) ;
        Account cor= new Account(Online_Only__c=true,Name = 'TestAcct' ,recordTypeid=CorOrFounRecordTypeId ,ND_Household_Category__c = 'GP') ;
        testAccts.add(hs);
        testAccts.add(cor);
        Insert testAccts;
        
        Account Acct = [SELECT Id, Name,recordTypeid FROM Account LIMIT 1];
       Mass_Assignment_Table_Config__mdt configData= [Select Id,Limit_Records__c,Object_APIName__c,Field_API_Name__c,Header_Value__c,Query__c,Query_Filters__c,Label from Mass_Assignment_Table_Config__mdt LIMIT 1];   
        User usr = [Select id, name,isActive, email from User where id=: UserInfo.getUserId()];
        String userId = usr.id;
        String assType = 'Primary Relationship Manager';
        String OrgType = 'Household';
        String massAssType = 'Mass Add';
        String recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Household').getRecordTypeId();
        String nextAccRef = '';
        string prevAccRef = '';
        string meta=configData.Label;
        List<String> PrimeList=new List<String>();
        List<String> PrimeId=new List<String>();
        for(Account acc: testAccts)
        {
          PrimeId.add(acc.id);  
        }
        System.debug('IDs: ' + PrimeId);

        test.starttest();
        ND_CustomLookupLwcController.getAccounts(prevAccRef,nextAccRef,assType,OrgType,massAssType,recTypeId,'',PrimeList);
        ND_CustomLookupLwcController.addNewSupervisor(PrimeId,userId,assType,OrgType);
        ND_CustomLookupLwcController.postChatterRecordFlow(userId,assType,OrgType,massAssType,recTypeId,'');
        try
        {
                 ND_CustomLookupLwcController.prepareDataforCSV(meta,nextAccRef,assType,OrgType,massAssType,recTypeId,PrimeList);
   
        }
        catch(Exception e)
        {
            
        }
        test.stoptest();
    }
    @isTest
    public static void getAccountsTest2(){
        setupData();
        Account Acct = [SELECT Id, Name,recordTypeid FROM Account LIMIT 1];
        User usr = [Select id, name,isActive, email from User where id=: UserInfo.getUserId()];
               Mass_Assignment_Table_Config__mdt configData= [Select Id,Limit_Records__c,Object_APIName__c,Field_API_Name__c,Header_Value__c,Query__c,Query_Filters__c,Label from Mass_Assignment_Table_Config__mdt LIMIT 1];   

        String userId = usr.id;
        String assType = 'Secondary Relationship Manager';
        String OrgType = 'Household';
        String massAssType = 'Mass Add';
        String recTypeId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Household').getRecordTypeId();
        String nextAccRef = '';
        string prevAccRef = '';
        List<String> PrimeList=new List<String>();
        List<Id> PrimeId=new List<Id>();
        string meta=configData.Label;
        
        test.starttest();
        ND_CustomLookupLwcController.getAccounts(prevAccRef,nextAccRef,assType,OrgType,massAssType,recTypeId,'',PrimeList);
        ND_CustomLookupLwcController.addNewSupervisor(PrimeId,userId,assType,OrgType);
        ND_CustomLookupLwcController.postChatterRecordFlow(userId,assType,OrgType,massAssType,recTypeId,'');
        try
        {
                ND_CustomLookupLwcController.prepareDataforCSV(meta,nextAccRef,assType,OrgType,massAssType,recTypeId,PrimeList);
        }
        catch(Exception e)
        {
            
        }
        
        test.stoptest();
        
    }
    @isTest
    public static void getAccountsTest3(){
        setupData();
        Account Acct = [SELECT Id, Name,recordTypeid FROM Account LIMIT 1];
        User usr = [Select id, name,isActive, email from User where id=: UserInfo.getUserId()];
                       Mass_Assignment_Table_Config__mdt configData= [Select Id,Limit_Records__c,Object_APIName__c,Field_API_Name__c,Header_Value__c,Query__c,Query_Filters__c,Label from Mass_Assignment_Table_Config__mdt LIMIT 1];   

        String userId = usr.id;
        String OrgType = 'Corporation or Foundation';
        String massAssType = 'Mass Add';
        String recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporations_and_Organizations').getRecordTypeId();
        String nextAccRef = '';
        string prevAccRef = '';
        String assType2 = '';
        string meta=configData.Label;
        List<String> PrimeList=new List<String>();
        List<Id> PrimeId=new List<Id>();
        
        test.starttest();
        ND_CustomLookupLwcController.getAccounts(prevAccRef,nextAccRef,assType2,OrgType,massAssType,recTypeId,'',PrimeList);
        ND_CustomLookupLwcController.addNewSupervisor(PrimeId,userId,assType2,OrgType);
        ND_CustomLookupLwcController.postChatterRecordFlow(userId,assType2,OrgType,massAssType,recTypeId,'');
        try
        {
                ND_CustomLookupLwcController.prepareDataforCSV(meta,nextAccRef,assType2,OrgType,massAssType,recTypeId,PrimeList);
        }
        catch(Exception e)
        {
            
        }
        test.stoptest();
        
        
    }
    
    @isTest
    public static void getAccountsTest4(){
        setupData();
        Account Acct = [SELECT Id, Name,recordTypeid FROM Account where recordtype.Developername='Corporations_and_Organizations' LIMIT 1];
        
        ucinn_ascendv2__Assignment__c assignt = new ucinn_ascendv2__Assignment__c();
        assignt.Name='AssignTest';
        assignt.ucinn_ascendv2__Assignment_Type__c = 'Primary Relationship Manager';
        assignt.Comments__c = 'abc';
        assignt.ucinn_ascendv2__Account__c= Acct.id;
        assignt.ucinn_ascendv2__Assignment_Start_Date__c = system.today().addDays(-10);
        assignt.ucinn_ascendv2__Assigned_Relationship_Manager_User__c= userinfo.getUserId(); 
        insert assignt;
        
        User usr = [Select id, name,isActive, email from User where id=: UserInfo.getUserId()];
                               Mass_Assignment_Table_Config__mdt configData= [Select Id,Limit_Records__c,Object_APIName__c,Field_API_Name__c,Header_Value__c,Query__c,Query_Filters__c,Label from Mass_Assignment_Table_Config__mdt LIMIT 1];   

        String userId = usr.id;
        String OrgType = '';
        String massAssType = 'Mass Drop';
        String recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporations_and_Organizations').getRecordTypeId();
        String nextAccRef = '';
        string prevAccRef = '';
        String assType2 = '';
        string meta=configData.Label;
        List<String> PrimeList=new List<String>();
        List<Id> PrimeId=new List<Id>();
        
        test.starttest();
        ND_CustomLookupLwcController.getAccounts(prevAccRef,nextAccRef,assType2,OrgType,massAssType,recTypeId,'',PrimeList);
        ND_CustomLookupLwcController.addNewSupervisor(PrimeId,userId,assType2,OrgType);
        ND_CustomLookupLwcController.postChatterRecordFlow(userId,assType2,OrgType,massAssType,recTypeId,'');
        try{
                       ND_CustomLookupLwcController.prepareDataforCSV(meta,nextAccRef,assType2,OrgType,massAssType,recTypeId,PrimeList);
        }
        catch(Exception e)
        {
            
        }
 
        test.stoptest();     
    }    
    
    @isTest static void saveResult1(){
        Id HouseholdId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Household').getRecordTypeId();
        Id CorOrFounRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporations_and_Organizations').getRecordTypeId();
        List < Account > testAccts = new List < Account > ();
        
        Account hs= new Account(Name = 'TestAcct' ,recordTypeid=HouseholdId ,ND_Household_Category__c = 'R2',ND_Household_Types__c='R2') ;
        Account cor= new Account(Online_Only__c=true,Name = 'TestAcct' ,recordTypeid=CorOrFounRecordTypeId ,ND_Household_Category__c = 'GP') ;
        testAccts.add(hs);
        testAccts.add(cor);
        Insert testAccts;       
        
        List<String> accList = new List<String>();
        for(Account ac:testAccts){
            accList.add(ac.Id);
        }
        string massAssType, otherParams, data;
        massAssType ='Mass Add';
        otherParams='{"comments": "","NewAssgComments":"" ,"newSupervisior": "", "selOrgType": "Household", "selAssType":"Primary Relationship Manager", "enableFundraiser":false ,"ht":"","hc":"" ,"reEvalDate":"'+ System.Now().format('yyyy-MM-dd') + '","userId":"'+ userInfo.getUserId() +'"}';
        data= JSON.serialize(accList);
        test.startTest();
        ND_CustomLookupLwcController.saveResult(massAssType,otherParams,data);
        test.stopTest();
    }
    @istest static void saveResult2(){
        Id HouseholdId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Household').getRecordTypeId();
        Id CorOrFounRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporations_and_Organizations').getRecordTypeId();
        List < Account > testAccts = new List < Account > ();
        
        Account hs= new Account(Name = 'TestAcct' ,recordTypeid=HouseholdId ,ND_Household_Category__c = 'R2',ND_Household_Types__c='R2') ;
        Account cor= new Account(Online_Only__c=true,Name = 'TestAcct' ,recordTypeid=CorOrFounRecordTypeId ,ND_Household_Category__c = 'GP') ;
        testAccts.add(hs);
        //testAccts.add(cor);
        Insert testAccts;       
        
        List<String> accList = new List<String>();
        for(Account ac:testAccts){
            accList.add(ac.Id);
        }
        string massAssType, otherParams, data;
        massAssType ='Mass Add';
        otherParams='{"comments": "","NewAssgComments":"" ,"newSupervisior": "", "selOrgType": "Household", "selAssType":"Secondary Relationship Manager", "enableFundraiser":false ,"ht":"","hc":"" ,"reEvalDate":"'+ System.Now().format('yyyy-MM-dd') + '","userId":"'+ userInfo.getUserId() +'"}';
        data= JSON.serialize(accList);
        test.starttest();
        try{
            ND_CustomLookupLwcController.saveResult(massAssType,otherParams,data);
        }Catch(Exception ex){
            system.debug('Error tetsclass:'+ex.getStackTraceString() );
        }
        test.stoptest();
    } 
    //@isTest(seeAllData=true)  
    @istest static void saveResult3(){
        Id HouseholdId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Household').getRecordTypeId();
        Id CorOrFounRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporations_and_Organizations').getRecordTypeId();
        List < Account > testAccts = new List < Account > ();
        
        Account hs= new Account(Name = 'TestAcct' ,recordTypeid=HouseholdId ,ND_Household_Category__c = 'R2',ND_Household_Types__c='R2') ;
        Account cor= new Account(Online_Only__c=true,Name = 'TestAcct' ,recordTypeid=CorOrFounRecordTypeId ,ND_Household_Category__c = 'GP') ;
        //testAccts.add(hs);
        testAccts.add(cor);
        Insert testAccts;       
        
        List<String> accList = new List<String>();
        for(Account ac:testAccts){
            accList.add(ac.Id);
        }
        string massAssType, otherParams, data;
        massAssType ='Mass Add';
        otherParams='{"comments": "","NewAssgComments":"" ,"newSupervisior": "", "selOrgType": "Corporation or Foundation", "selAssType":"Secondary Relationship Manager", "enableFundraiser":false ,"ht":"","hc":"" ,"reEvalDate":"'+ System.Now().format('yyyy-MM-dd') + '","userId":"'+ userInfo.getUserId() +'"}';
        data= JSON.serialize(accList);
        test.startTest();
        try{
            ND_CustomLookupLwcController.saveResult(massAssType,otherParams,data);
        }Catch(Exception ex){
            system.debug('testclass'+ ex.getStackTraceString());
        }
        test.stopTest();
        
    }  
    @istest static void saveResult4(){
        Id HouseholdId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Household').getRecordTypeId();
        Id CorOrFounRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporations_and_Organizations').getRecordTypeId();
        List < Account > testAccts = new List < Account > ();
        
        Account hs= new Account(Name = 'TestAcct' ,recordTypeid=HouseholdId ,ND_Household_Category__c = 'R2',ND_Household_Types__c='R2') ;
        Account cor= new Account(Online_Only__c=true,Name = 'TestAcct' ,recordTypeid=CorOrFounRecordTypeId ,ND_Household_Category__c = 'GP') ;
        //testAccts.add(hs);
        testAccts.add(cor);
        Insert testAccts; 
        
        ucinn_ascendv2__Assignment__c assignt = new ucinn_ascendv2__Assignment__c();
        assignt.Name='AssignTest';
        assignt.ucinn_ascendv2__Assignment_Type__c = 'Primary Relationship Manager';
        assignt.Comments__c = 'abc';
        assignt.ucinn_ascendv2__Account__c= testAccts[0].id;
        assignt.ucinn_ascendv2__Assignment_Start_Date__c = system.today().addDays(-10);
        assignt.ucinn_ascendv2__Assigned_Relationship_Manager_User__c= userinfo.getUserId(); 
        insert assignt;        
        List<String> accList = new List<String>();
        
        accList.add(assignt.Id);
        
        string massAssType, otherParams, data;
        massAssType ='Mass Drop';
        otherParams='{"comments": "","NewAssgComments":"" ,"newSupervisior": "", "selOrgType": "Corporation or Foundation", "selAssType":"Secondary Relationship Manager", "enableFundraiser":false ,"ht":"","hc":"" ,"reEvalDate":"'+ System.Now().format('yyyy-MM-dd') + '","userId":"'+ userInfo.getUserId() +'"}';
        data= JSON.serialize(accList);
        test.startTest();
        try{
            ND_CustomLookupLwcController.saveResult(massAssType,otherParams,data);
        }Catch(Exception ex){
            system.debug('Test class:'+ex.getStackTraceString());
        }
        test.stopTest();
        
    }
     @isTest
    public static void testDropRecords() {
        setupData();  // Call the setupData method to create test data
        Account Acct = [SELECT Id, Name,recordTypeid FROM Account where recordtype.Developername='Corporations_and_Organizations' LIMIT 1];
                
        ucinn_ascendv2__Assignment__c assignt = new ucinn_ascendv2__Assignment__c();
        assignt.Name='AssignTest';
        assignt.ucinn_ascendv2__Assignment_Type__c = 'Primary Relationship Manager';
        assignt.Comments__c = 'abc';
        assignt.ucinn_ascendv2__Account__c= Acct.id;
        assignt.ucinn_ascendv2__Assignment_Start_Date__c = system.today().addDays(-10);
        assignt.ucinn_ascendv2__Assigned_Relationship_Manager_User__c= userinfo.getUserId(); 
        insert assignt;
       
        // Create test parameters
        String cmdt = 'Drop'; 
        List<String> ids = new List<String>{assignt.Id};
        String comments = 'Test comments';
        String msg = 'Test message';
        String userId = UserInfo.getUserId();
        String hc = 'NewCategory';
        String ht = 'NewType';
        Date reEvalDate = System.today().addDays(30);

        Test.startTest();        
        // Call the dropRecords method
       ND_CustomLookupLwcController.dropRecords(cmdt, ids, comments, msg, userId, hc, ht, reEvalDate);     
        Test.stopTest();    
    }
    
   
}    
    
  


       /* @isTest(seeAllData=true)  static void saveResult5(){
            Id HouseholdId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Household').getRecordTypeId();
            Id CorOrFounRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporations_and_Organizations').getRecordTypeId();
            List < Account > testAccts = new List < Account > ();
            
            Account hs= new Account(Name = 'TestAcct' ,recordTypeid=HouseholdId ,ND_Household_Category__c = 'R2',ND_Household_Types__c='R2') ;
            Account cor= new Account(Online_Only__c=true,Name = 'TestAcct' ,recordTypeid=CorOrFounRecordTypeId ,ND_Household_Category__c = 'GP') ;
            //testAccts.add(hs);
            testAccts.add(cor);
            Insert testAccts;       
            ucinn_ascendv2__Assignment__c assignt = new ucinn_ascendv2__Assignment__c();
            assignt.Name='AssignTest';
            assignt.ucinn_ascendv2__Assignment_Type__c = 'Primary Relationship Manager';
            assignt.Comments__c = 'abc';
            assignt.ucinn_ascendv2__Account__c= testAccts[0].id;
            assignt.ucinn_ascendv2__Assignment_Start_Date__c = system.today().addDays(-10);
            assignt.ucinn_ascendv2__Assigned_Relationship_Manager_User__c= userinfo.getUserId(); 
            insert assignt;
            List<String> accList = new List<String>();
            
            accList.add(assignt.Id);
            
            string massAssType, otherParams, data;
            massAssType ='Mass Drop';
        otherParams='{"comments": "","NewAssgComments":"" ,"newSupervisior":"'+userInfo.getUserId() + '", "selOrgType": "Corporation or Foundation", "selAssType":"Secondary Relationship Manager", "enableFundraiser":true ,"ht":"","hc":"" ,"reEvalDate":"'+ System.today().format() + '","userId":"'+ userInfo.getUserId() +'"}';
        data= JSON.serialize(accList);
        ND_CustomLookupLwcController.saveResult(massAssType,otherParams,data);
         
    }    */