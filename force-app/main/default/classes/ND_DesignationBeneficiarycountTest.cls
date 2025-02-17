@isTest
public class ND_DesignationBeneficiarycountTest {
    
    @testsetup
    Static void testsetup(){
        ucinn_ascendv2__Trigger_Handler__c conHandler = new ucinn_ascendv2__Trigger_Handler__c();
        conHandler.Name = 'ND Contact Trigger';
        conHandler.ucinn_ascendv2__Class__c = 'ND_DesignationBeneficiaryCount';
        conHandler.ucinn_ascendv2__Is_Active__c = true;
        conHandler.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Designation_Beneficiary__c';
        conHandler.ucinn_ascendv2__Trigger_Action__c = 'AfterInsert;AfterUpdate;AfterDelete';
        insert conHandler; 
        
        List<ucinn_ascendv2__Academic_Organization__c> aoList = new List<ucinn_ascendv2__Academic_Organization__c>();
        
        ucinn_ascendv2__Academic_Organization__c ao1 = new ucinn_ascendv2__Academic_Organization__c();
        ao1.Name = 'Athletics';
        ao1.ucinn_ascendv2__Type__c = 'desig_div';
        ao1.ucinn_ascendv2__Code__c = 'V025';
        aoList.add(ao1);
        
        ucinn_ascendv2__Academic_Organization__c ao3 = new ucinn_ascendv2__Academic_Organization__c();
        ao3.Name = 'Athletics';
        ao3.ND_Parent_Department__c = ao1.Id;
        ao3.ucinn_ascendv2__Type__c = 'desig_sub-dept';
        ao3.ucinn_ascendv2__Code__c = 'S025';
        aoList.add(ao3);
        
        insert aoList;
        
        ucinn_ascendv2__Designation__c designation = new ucinn_ascendv2__Designation__c();
        designation.ucinn_ascendv2__Designation_Name__c = 'Test Designation';
        designation.ucinn_ascendv2__Acknowledgement_Description__c = 'Designation001';
        designation.Steward_Reporting_Code__c='FL';
        designation.ucinn_ascendv2__G_L_Effective_Date__c = System.today();
        designation.Sub_Department__c = ao3.Id;
        designation.nd_Current_Beneficiary_Count__c = 0;
        insert designation;
        
        Id HrecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();

        Account hsAcc = new account(recordTypeId=HrecordTypeId,name='accTest',ND_Household_Category__c='AS',ND_Household_Types__c ='I');
        insert hsAcc;
        list<Contact> conlist = new list<Contact>();
        Contact con1 = new Contact(Constituent_Status__c='A',FirstName='TestFirstName', ucinn_ascendv2__Contact_Type__c='EM',LastName='TestLastName',email='test@test.com',accountid=hsAcc.id);       
        insert con1;    
        
        Contact con2 = new Contact(Constituent_Status__c='A',FirstName='TestFirstName1', ucinn_ascendv2__Contact_Type__c='EM',LastName='TestLastName1',email='test1@test.com',accountid=hsAcc.id);       
        insert con2;                
        Date testDate = Date.newInstance(2021, 08, 08);
        ucinn_ascendv2__Designation_Beneficiary__c db = new ucinn_ascendv2__Designation_Beneficiary__c();
        db.ucinn_ascendv2__Contact__c= con1.Id;
        db.ucinn_ascendv2__Designation__c=designation.id;
        //   db.ucinn_ascendv2__Fiscal_Year__c = dynamicValue;
        db.ucinn_ascendv2__Start_Date__c = testDate;
    //    db.Year_of_Study__c = '2024';
         
        insert db;
    
        ucinn_ascendv2__Designation_Beneficiary__c db1 = new ucinn_ascendv2__Designation_Beneficiary__c();
        db1.ucinn_ascendv2__Contact__c= con2.Id;
        db1.ucinn_ascendv2__Designation__c=designation.id;
        insert db1;
        
        ucinn_ascendv2__Designation_Beneficiary__c db2 = new ucinn_ascendv2__Designation_Beneficiary__c();
        db2.ucinn_ascendv2__Contact__c= con1.Id;
        db2.ucinn_ascendv2__Designation__c=designation.id;
        db2.ucinn_ascendv2__Start_Date__c = testDate;
        insert db2;
    }
    
    @isTest
    static void testMethod1(){
        Date testDate = Date.newInstance(2024, 08, 08);
        list<ucinn_ascendv2__Designation_Beneficiary__c> ben = [select id,ucinn_ascendv2__Designation__c,ucinn_ascendv2__Contact__c,Year_of_Study__c,ucinn_ascendv2__Start_Date__c from ucinn_ascendv2__Designation_Beneficiary__c limit 3 ];
    	test.startTest();
    //    ben[0].ucinn_ascendv2__Fiscal_Year__c = dynamicValue;
    	ben[0].ucinn_ascendv2__Start_Date__c = testDate;
        ben[1].ucinn_ascendv2__Start_Date__c = Date.newInstance(2024, 09, 09);
        update ben;
        test.stopTest();
    }

}