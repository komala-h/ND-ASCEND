@isTest(SeeAllData=false)
private class TRIG_Designation_StewardshipTest {

    @isTest(SeeAllData=false) 
    static void insertAR() {
        
        Test.startTest();
        TracHier.HierarchyAPI.setTriggerDisabled();
        Account hh01 = new Account();
        hh01.Name = 'TEST Household';
        hh01.ucinn_ascendv2__PRM__c = UserInfo.getUserId();
        hh01.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Household').getRecordTypeId();
        insert hh01;
        
        Contact con1 = new Contact();
        con1.FirstName = 'h01';
        con1.LastName = 'TEST';
        con1.ucinn_ascendv2__Gender__c = 'Male';
        con1.ucinn_ascendv2__Contact_Type__c = 'AL';
        con1.ucinn_ascendv2__Personal_Email__c = 'sample@uci.com';
        con1.Constituent_Status__c = 'A';
        con1.AccountId = hh01.Id;
        insert con1;

        
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
        
        ucinn_ascendv2__Designation__c new_parent = new ucinn_ascendv2__Designation__c();
        new_parent.name = 'jrizzi';
        new_parent.ucinn_ascendv2__Designation_Name__c = 'jrizzi';
        new_parent.Unrestricted_Type__c = 'UNIVUNR';
        new_parent.ucinn_ascendv2__G_L_Effective_Date__c = System.today();
        new_parent.Sub_Department__c = ao3.Id;
        insert new_parent;
        
        ucinn_ascendv2__Designation_Stewardship__c new_ar = new ucinn_ascendv2__Designation_Stewardship__c();
        new_ar.ucinn_ascendv2__Contact_Stewardee__c = con1.Id;
        new_ar.ucinn_ascendv2__Role__c   = 'IR';
        new_ar.ucinn_ascendv2__Designation__c = new_parent.id;
        //new_ar.Original_Data_Source__c = 'Constituent';
        //new_ar.Sort_Order__c = 1;
        insert new_ar;
        Test.stopTest();

        ucinn_ascendv2__Designation_Stewardship__c s01 = [SELECT Id, ucinn_ascendv2__Designation__c FROM ucinn_ascendv2__Designation_Stewardship__c WHERE ucinn_ascendv2__Role__c = 'IR'  LIMIT 1];
        System.assertEquals(new_parent.id, s01.ucinn_ascendv2__Designation__c);
        //System.assertEquals(1, s01.Sort_Order__c);
        

    }
}