/**
 * @author UC Innovation
 * @date 9/15/2022
 * @description Test class for asc_TRIG_HSCHandler
 */
@isTest
private class asc_TRIG_HSCHandlerTest {

    @TestSetup
    public static void testSetup() {
        ucinn_ascendv2__Trigger_Handler__c customHandler1 = new ucinn_ascendv2__Trigger_Handler__c();
        customHandler1.Name = 'Custom Hard And Soft Credit Handler';
        customHandler1.ucinn_ascendv2__Class__c = 'asc_TRIG_HSCHandler';
        customHandler1.ucinn_ascendv2__Is_Active__c = true;
        customHandler1.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Hard_and_Soft_Credit__c';
        customHandler1.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;BeforeDelete;AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
        customHandler1.ucinn_ascendv2__Load_Order__c = 2;
        insert customHandler1;

        Contact con1 = new Contact();
        con1.FirstName = 'h01';
        con1.LastName = 'TEST';
        con1.ucinn_ascendv2__Gender__c = 'Male';
        con1.ucinn_ascendv2__Contact_Type__c = 'AL';
        con1.ucinn_ascendv2__Personal_Email__c = 'sample@uci.com';
        con1.Constituent_Status__c = 'A';
        insert con1;

        Contact con1Spouse = new Contact();
        con1Spouse.FirstName = 'h01Spouse';
        con1Spouse.LastName = 'TESTSpouse';
        con1Spouse.ucinn_ascendv2__Gender__c = 'Female';
        con1Spouse.ucinn_ascendv2__Contact_Type__c = 'AL';
        con1Spouse.ucinn_ascendv2__Personal_Email__c = 'sample@uci.com';
        con1Spouse.Constituent_Status__c = 'A';
        con1Spouse.ucinn_ascendv2__Preferred_Spouse__c = con1.Id;
        insert con1Spouse;

        con1.ucinn_ascendv2__Preferred_Spouse__c = con1Spouse.Id;
        update con1;

        List<ucinn_ascendv2__Academic_Organization__c> aoList = new List<ucinn_ascendv2__Academic_Organization__c>();

        ucinn_ascendv2__Academic_Organization__c ao1 = new ucinn_ascendv2__Academic_Organization__c();
        ao1.Name = 'Athletics';
        ao1.ucinn_ascendv2__Type__c = 'desig_div';
        ao1.ucinn_ascendv2__Code__c = 'V025';
        aoList.add(ao1);

        ucinn_ascendv2__Academic_Organization__c ao2 = new ucinn_ascendv2__Academic_Organization__c();
        ao2.Name = 'Arts & Letters';
        ao2.ucinn_ascendv2__Type__c = 'desig_div';
        ao2.ucinn_ascendv2__Code__c = 'V010';
        aoList.add(ao2);
        
        ucinn_ascendv2__Academic_Organization__c ao3 = new ucinn_ascendv2__Academic_Organization__c();
        ao3.Name = 'Athletics';
        ao3.ND_Parent_Department__c = ao1.Id;
        ao3.ucinn_ascendv2__Type__c = 'desig_sub-dept';
        ao3.ucinn_ascendv2__Code__c = 'S025';
        aoList.add(ao3);
        
        ucinn_ascendv2__Academic_Organization__c ao4 = new ucinn_ascendv2__Academic_Organization__c();
        ao4.Name = 'Arts & Letters';
        ao4.ND_Parent_Department__c = ao2.Id;
        ao4.ucinn_ascendv2__Type__c = 'desig_sub-dept';
        ao4.ucinn_ascendv2__Code__c = 'S010';
        aoList.add(ao4);

        insert aoList;

        List<ucinn_ascendv2__Designation__c> desigList = new List<ucinn_ascendv2__Designation__c>();

        ucinn_ascendv2__Designation__c desig1 = new ucinn_ascendv2__Designation__c();
        desig1.Name = 'ROCKNE TEST';
        desig1.ucinn_ascendv2__Designation_Name__c = 'Rockne Test';
        desig1.Unrestricted_Type__c = 'UNIVUNR';
        desig1.ucinn_ascendv2__G_L_Effective_Date__c = System.today();
        //desig1.ND_Division__c = ao1.Id;
        desig1.Sub_Department__c = ao3.Id;
        desigList.add(desig1);

        ucinn_ascendv2__Designation__c desig2 = new ucinn_ascendv2__Designation__c();
        desig2.Name = 'EDUC TEST';
        desig2.ucinn_ascendv2__Designation_Name__c = 'Educ Test';
        desig2.Unrestricted_Type__c = null;
        desig2.ucinn_ascendv2__G_L_Effective_Date__c = System.today();
        //desig2.ND_Division__c = ao2.Id;
        desig2.Sub_Department__c = ao4.Id;
        desigList.add(desig2);

        insert desigList;
    }
    
    @isTest
    static void testMethod1() {
        Id giftRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Gift').getRecordTypeId();

        Contact con1 = [SELECT Id FROM Contact WHERE FirstName = 'h01' LIMIT 1];
        Contact con1Spouse = [SELECT Id FROM Contact WHERE FirstName = 'h01Spouse' LIMIT 1];
        ucinn_ascendv2__Designation__c desig1 = [SELECT Id FROM ucinn_ascendv2__Designation__c WHERE ucinn_ascendv2__Designation_Name__c = 'ROCKNE TEST' LIMIT 1];
        ucinn_ascendv2__Designation__c desig2 = [SELECT Id FROM ucinn_ascendv2__Designation__c WHERE ucinn_ascendv2__Designation_Name__c = 'EDUC TEST' LIMIT 1];

        ucinn_ascendv2__Session__c sess1 = new ucinn_ascendv2__Session__c();
        sess1.ucinn_ascendv2__Session_Date__c = System.today();
        sess1.ucinn_ascendv2__Gift_Pledge_Payment_Amount__c = 5000;
        insert sess1;
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = '[Default Name]';
        opp1.RecordTypeId = giftRTId;
        opp1.ucinn_ascendv2__Session__c = sess1.Id;
        opp1.ucinn_ascendv2__Contact__c = con1.Id;
        opp1.StageName = 'Funded';
        opp1.ucinn_ascendv2__Tender_Type_for_Gifts__c = 'Cash';
        opp1.Amount = 5000;
        opp1.ucinn_ascendv2__Credit_Date__c = System.today();
        opp1.Type =  'Outright';
        opp1.CloseDate =  System.today();
        insert opp1;

        List<ucinn_ascendv2__Designation_Detail__c> ddList = new List<ucinn_ascendv2__Designation_Detail__c>();

        ucinn_ascendv2__Designation_Detail__c dd1 = new ucinn_ascendv2__Designation_Detail__c();
        dd1.ucinn_ascendv2__Session__c = sess1.Id;
        dd1.ucinn_ascendv2__Opportunity__c = opp1.Id;
        dd1.ucinn_ascendv2__Contact__c = con1.Id;
        dd1.ucinn_ascendv2__Amount__c = 2500;
        dd1.ucinn_ascendv2__Designation__c = desig1.Id;
        ddList.add(dd1);

        ucinn_ascendv2__Designation_Detail__c dd2 = new ucinn_ascendv2__Designation_Detail__c();
        dd2.ucinn_ascendv2__Session__c = sess1.Id;
        dd2.ucinn_ascendv2__Opportunity__c = opp1.Id;
        dd2.ucinn_ascendv2__Contact__c = con1.Id;
        dd2.ucinn_ascendv2__Amount__c = 2500;
        dd2.ucinn_ascendv2__Designation__c = desig2.Id;
        ddList.add(dd2);

        insert ddList;

        List<ucinn_ascendv2__Payment__c> pmtList = new List<ucinn_ascendv2__Payment__c>();

        ucinn_ascendv2__Payment__c pmt1 = new ucinn_ascendv2__Payment__c();
        pmt1.ucinn_ascendv2__Contact__c = con1.Id;
        pmt1.ucinn_ascendv2__Transaction_Type__c = 'Outright Gift';
        pmt1.ucinn_ascendv2__Status__c = 'Paid';
        pmt1.ucinn_ascendv2__Tender_Type_for_Gifts__c = 'Cash';
        pmt1.ucinn_ascendv2__Payment_Amount__c = 2500;
        pmt1.ucinn_ascendv2__Credit_Date__c = System.today();
        pmt1.ucinn_ascendv2__Session__c = sess1.Id;
        pmt1.ucinn_ascendv2__Opportunity__c = opp1.Id;
        pmt1.ucinn_ascendv2__Designation__c = desig1.Id;
        pmt1.ucinn_ascendv2__Designation_Detail__c = dd1.Id;
        pmtList.add(pmt1);

        ucinn_ascendv2__Payment__c pmt2 = new ucinn_ascendv2__Payment__c();
        pmt2.ucinn_ascendv2__Contact__c = con1.Id;
        pmt2.ucinn_ascendv2__Transaction_Type__c = 'Outright Gift';
        pmt2.ucinn_ascendv2__Status__c = 'Paid';
        pmt2.ucinn_ascendv2__Tender_Type_for_Gifts__c = 'Cash';
        pmt2.ucinn_ascendv2__Payment_Amount__c = 2500;
        pmt2.ucinn_ascendv2__Credit_Date__c = System.today();
        pmt2.ucinn_ascendv2__Session__c = sess1.Id;
        pmt2.ucinn_ascendv2__Opportunity__c = opp1.Id;
        pmt2.ucinn_ascendv2__Designation__c = desig2.Id;
        pmt2.ucinn_ascendv2__Designation_Detail__c = dd2.Id;
        pmtList.add(pmt2);

        insert pmtList;

        Test.startTest();

        List<ucinn_ascendv2__Hard_and_Soft_Credit__c> hscList = new List<ucinn_ascendv2__Hard_and_Soft_Credit__c>();

        ucinn_ascendv2__Hard_and_Soft_Credit__c hsc1 = new ucinn_ascendv2__Hard_and_Soft_Credit__c();
        hsc1.ucinn_ascendv2__Contact__c = con1.Id;
        hsc1.ucinn_ascendv2__Opportunity__c = opp1.Id;
        hsc1.ucinn_ascendv2__Designation_Detail__c = dd1.Id;
        hsc1.ucinn_ascendv2__Designation__c = desig1.Id;
        hsc1.ucinn_ascendv2__Credit_Amount__c = 2500;
        hsc1.ucinn_ascendv2__Credit_Type__c = 'Hard';
        hsc1.ucinn_ascendv2__Payment__c = pmt1.Id;
        hsc1.ucinn_ascendv2__Source__c = 'Payment';
        hscList.add(hsc1);

        ucinn_ascendv2__Hard_and_Soft_Credit__c hsc2 = new ucinn_ascendv2__Hard_and_Soft_Credit__c();
        hsc2.ucinn_ascendv2__Contact__c = con1Spouse.Id;
        hsc2.ucinn_ascendv2__Opportunity__c = opp1.Id;
        hsc2.ucinn_ascendv2__Designation_Detail__c = dd1.Id;
        hsc2.ucinn_ascendv2__Designation__c = desig1.Id;
        hsc2.ucinn_ascendv2__Credit_Amount__c = 2500;
        hsc2.ucinn_ascendv2__Credit_Type__c = 'Soft';
        hsc2.ucinn_ascendv2__Payment__c = pmt1.Id;
        hsc2.ucinn_ascendv2__Source__c = 'Payment';
        hscList.add(hsc2);

        ucinn_ascendv2__Hard_and_Soft_Credit__c hsc3 = new ucinn_ascendv2__Hard_and_Soft_Credit__c();
        hsc3.ucinn_ascendv2__Contact__c = con1.Id;
        hsc3.ucinn_ascendv2__Opportunity__c = opp1.Id;
        hsc3.ucinn_ascendv2__Designation_Detail__c = dd2.Id;
        hsc3.ucinn_ascendv2__Designation__c = desig2.Id;
        hsc3.ucinn_ascendv2__Credit_Amount__c = 2500;
        hsc3.ucinn_ascendv2__Credit_Type__c = 'Hard';
        hsc3.ucinn_ascendv2__Payment__c = pmt2.Id;
        hsc3.ucinn_ascendv2__Source__c = 'Payment';
        hscList.add(hsc3);

        ucinn_ascendv2__Hard_and_Soft_Credit__c hsc4 = new ucinn_ascendv2__Hard_and_Soft_Credit__c();
        hsc4.ucinn_ascendv2__Contact__c = con1Spouse.Id;
        hsc4.ucinn_ascendv2__Opportunity__c = opp1.Id;
        hsc4.ucinn_ascendv2__Designation_Detail__c = dd2.Id;
        hsc4.ucinn_ascendv2__Designation__c = desig2.Id;
        hsc4.ucinn_ascendv2__Credit_Amount__c = 2500;
        hsc4.ucinn_ascendv2__Credit_Type__c = 'Soft';
        hsc4.ucinn_ascendv2__Payment__c = pmt2.Id;
        hsc4.ucinn_ascendv2__Source__c = 'Payment';
        hscList.add(hsc4);

        insert hscList;

        Test.stopTest();
    }

    @isTest
    static void testMethod2() {
        Id pledgeRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Pledge').getRecordTypeId();

        Contact con1 = [SELECT Id FROM Contact WHERE FirstName = 'h01' LIMIT 1];
        Contact con1Spouse = [SELECT Id FROM Contact WHERE FirstName = 'h01Spouse' LIMIT 1];
        ucinn_ascendv2__Designation__c desig1 = [SELECT Id FROM ucinn_ascendv2__Designation__c WHERE ucinn_ascendv2__Designation_Name__c = 'ROCKNE TEST' LIMIT 1];
        ucinn_ascendv2__Designation__c desig2 = [SELECT Id FROM ucinn_ascendv2__Designation__c WHERE ucinn_ascendv2__Designation_Name__c = 'EDUC TEST' LIMIT 1];

        ucinn_ascendv2__Session__c sess1 = new ucinn_ascendv2__Session__c();
        sess1.ucinn_ascendv2__Session_Date__c = System.today();
        sess1.ucinn_ascendv2__Pledge_Amount__c = 5000;
        insert sess1;
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = '[Default Name]';
        opp1.RecordTypeId = pledgeRTId;
        opp1.ucinn_ascendv2__Session__c = sess1.Id;
        opp1.ucinn_ascendv2__Contact__c = con1.Id;
        opp1.StageName = 'Active';
        opp1.ucinn_ascendv2__Tender_Type_for_Gifts__c = 'Cash';
        opp1.Amount = 5000;
        opp1.ucinn_ascendv2__Credit_Date__c = System.today();
        opp1.Type =  'PD';
        opp1.CloseDate =  System.today();
        insert opp1;

        List<ucinn_ascendv2__Designation_Detail__c> ddList = new List<ucinn_ascendv2__Designation_Detail__c>();

        ucinn_ascendv2__Designation_Detail__c dd1 = new ucinn_ascendv2__Designation_Detail__c();
        dd1.ucinn_ascendv2__Session__c = sess1.Id;
        dd1.ucinn_ascendv2__Opportunity__c = opp1.Id;
        dd1.ucinn_ascendv2__Contact__c = con1.Id;
        dd1.ucinn_ascendv2__Amount__c = 2500;
        dd1.ucinn_ascendv2__Designation__c = desig1.Id;
        ddList.add(dd1);

        ucinn_ascendv2__Designation_Detail__c dd2 = new ucinn_ascendv2__Designation_Detail__c();
        dd2.ucinn_ascendv2__Session__c = sess1.Id;
        dd2.ucinn_ascendv2__Opportunity__c = opp1.Id;
        dd2.ucinn_ascendv2__Contact__c = con1.Id;
        dd2.ucinn_ascendv2__Amount__c = 2500;
        dd2.ucinn_ascendv2__Designation__c = desig2.Id;
        ddList.add(dd2);

        insert ddList;

        /* List<ucinn_ascendv2__Payment__c> pmtList = new List<ucinn_ascendv2__Payment__c>();

        ucinn_ascendv2__Payment__c pmt1 = new ucinn_ascendv2__Payment__c();
        pmt1.ucinn_ascendv2__Contact__c = con1.Id;
        pmt1.ucinn_ascendv2__Transaction_Type__c = 'Outright Gift';
        pmt1.ucinn_ascendv2__Status__c = 'Paid';
        pmt1.ucinn_ascendv2__Tender_Type_for_Gifts__c = 'Cash';
        pmt1.ucinn_ascendv2__Payment_Amount__c = 2500;
        pmt1.ucinn_ascendv2__Credit_Date__c = System.today();
        pmt1.ucinn_ascendv2__Session__c = sess1.Id;
        pmt1.ucinn_ascendv2__Opportunity__c = opp1.Id;
        pmt1.ucinn_ascendv2__Designation__c = desig1.Id;
        pmt1.ucinn_ascendv2__Designation_Detail__c = dd1.Id;
        pmtList.add(pmt1);

        ucinn_ascendv2__Payment__c pmt2 = new ucinn_ascendv2__Payment__c();
        pmt2.ucinn_ascendv2__Contact__c = con1.Id;
        pmt2.ucinn_ascendv2__Transaction_Type__c = 'Outright Gift';
        pmt2.ucinn_ascendv2__Status__c = 'Paid';
        pmt2.ucinn_ascendv2__Tender_Type_for_Gifts__c = 'Cash';
        pmt2.ucinn_ascendv2__Payment_Amount__c = 2500;
        pmt2.ucinn_ascendv2__Credit_Date__c = System.today();
        pmt2.ucinn_ascendv2__Session__c = sess1.Id;
        pmt2.ucinn_ascendv2__Opportunity__c = opp1.Id;
        pmt2.ucinn_ascendv2__Designation__c = desig2.Id;
        pmt2.ucinn_ascendv2__Designation_Detail__c = dd2.Id;
        pmtList.add(pmt2);

        insert pmtList; */

        Test.startTest();

        List<ucinn_ascendv2__Hard_and_Soft_Credit__c> hscList = new List<ucinn_ascendv2__Hard_and_Soft_Credit__c>();

        ucinn_ascendv2__Hard_and_Soft_Credit__c hsc1 = new ucinn_ascendv2__Hard_and_Soft_Credit__c();
        hsc1.ucinn_ascendv2__Contact__c = con1.Id;
        hsc1.ucinn_ascendv2__Opportunity__c = opp1.Id;
        hsc1.ucinn_ascendv2__Designation_Detail__c = dd1.Id;
        hsc1.ucinn_ascendv2__Designation__c = desig1.Id;
        hsc1.ucinn_ascendv2__Credit_Amount__c = 2500;
        hsc1.ucinn_ascendv2__Credit_Type__c = 'Hard';
        // hsc1.ucinn_ascendv2__Payment__c = pmt1.Id;
        hsc1.ucinn_ascendv2__Source__c = 'Pledge';
        hscList.add(hsc1);

        /* ucinn_ascendv2__Hard_and_Soft_Credit__c hsc2 = new ucinn_ascendv2__Hard_and_Soft_Credit__c();
        hsc2.ucinn_ascendv2__Contact__c = con1Spouse.Id;
        hsc2.ucinn_ascendv2__Opportunity__c = opp1.Id;
        hsc2.ucinn_ascendv2__Designation_Detail__c = dd1.Id;
        hsc2.ucinn_ascendv2__Designation__c = desig1.Id;
        hsc2.ucinn_ascendv2__Credit_Amount__c = 2500;
        hsc2.ucinn_ascendv2__Credit_Type__c = 'Soft';
        // hsc2.ucinn_ascendv2__Payment__c = pmt1.Id;
        hsc2.ucinn_ascendv2__Source__c = 'Pledge';
        hscList.add(hsc2); */

        ucinn_ascendv2__Hard_and_Soft_Credit__c hsc3 = new ucinn_ascendv2__Hard_and_Soft_Credit__c();
        hsc3.ucinn_ascendv2__Contact__c = con1.Id;
        hsc3.ucinn_ascendv2__Opportunity__c = opp1.Id;
        hsc3.ucinn_ascendv2__Designation_Detail__c = dd2.Id;
        hsc3.ucinn_ascendv2__Designation__c = desig2.Id;
        hsc3.ucinn_ascendv2__Credit_Amount__c = 2500;
        hsc3.ucinn_ascendv2__Credit_Type__c = 'Hard';
        // hsc3.ucinn_ascendv2__Payment__c = pmt2.Id;
        hsc3.ucinn_ascendv2__Source__c = 'Pledge';
        hscList.add(hsc3);

        /* ucinn_ascendv2__Hard_and_Soft_Credit__c hsc4 = new ucinn_ascendv2__Hard_and_Soft_Credit__c();
        hsc4.ucinn_ascendv2__Contact__c = con1Spouse.Id;
        hsc4.ucinn_ascendv2__Opportunity__c = opp1.Id;
        hsc4.ucinn_ascendv2__Designation_Detail__c = dd2.Id;
        hsc4.ucinn_ascendv2__Designation__c = desig2.Id;
        hsc4.ucinn_ascendv2__Credit_Amount__c = 2500;
        hsc4.ucinn_ascendv2__Credit_Type__c = 'Soft';
        // hsc4.ucinn_ascendv2__Payment__c = pmt2.Id;
        hsc4.ucinn_ascendv2__Source__c = 'Pledge';
        hscList.add(hsc4); */

        insert hscList;

        Test.stopTest();
    }

}