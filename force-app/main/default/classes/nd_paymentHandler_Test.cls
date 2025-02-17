@isTest
public class nd_paymentHandler_Test {

    @isTest
    static void testMethod1() {
        
        ucinn_ascendv2__Trigger_Handler__c customHandler1 = new ucinn_ascendv2__Trigger_Handler__c();
        customHandler1.Name = 'Review Payment Handler';
        customHandler1.ucinn_ascendv2__Class__c = 'nd_paymentHandler';
        customHandler1.ucinn_ascendv2__Is_Active__c = true;
        customHandler1.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Payment__c';
        customHandler1.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate';
        customHandler1.ucinn_ascendv2__Load_Order__c = 2;
        insert customHandler1;
        
        
        Id giftRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Gift').getRecordTypeId();

         Contact con1 = new Contact();
        con1.FirstName = 'h01';
        con1.LastName = 'TEST';
        con1.ucinn_ascendv2__Gender__c = 'Male';
        con1.ucinn_ascendv2__Contact_Type__c = 'AL';
        con1.ucinn_ascendv2__Personal_Email__c = 'sample@uci.com';
        con1.Constituent_Status__c = 'A';
        insert con1;
        
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
        
        insert ddList;
        
        
         ucinn_ascendv2__Review_Transaction_v2__c review = new ucinn_ascendv2__Review_Transaction_v2__c( 
        name = 'GNRL-0030785',
        ucinn_ascendv2__First_Name__c = 'Dan',
        ucinn_ascendv2__Last_Name__c = 'LeBatard', 
        nd_data_source__c = 'HVG', 
        ucinn_ascendv2__Transaction_Date__c = Date.valueOf('2024-01-11'),
        ucinn_ascendv2__Status__c='Reviewed', 
        ucinn_ascendv2__Tender_Type_1__c = 'Credit Card',
        ucinn_ascendv2__Transaction_Type__c ='Gift',
        nd_Pledge_Gift_Type__c = 'Outright',
        ucinn_ascendv2__Send_to_G_L__c = true,
        nd_Remitting_Bank__c='1233434',     
        ucinn_ascendv2__Payment_Amount_1_1__c =  50.00,
        ucinn_ascendv2__Designation_1__c = desig1.id,
        ucinn_ascendv2__External_System_ID__c = 'GNRL-0030785'
                );
        
        insert review;
            
         List<ucinn_ascendv2__Payment__c> pmtList = new List<ucinn_ascendv2__Payment__c>();

        ucinn_ascendv2__Payment__c pmt1 = new ucinn_ascendv2__Payment__c();
        pmt1.ucinn_ascendv2__Contact__c = con1.Id;
        pmt1.ucinn_ascendv2__Transaction_Type__c = 'Outright Gift';
        pmt1.ucinn_ascendv2__Status__c = 'Paid';
        pmt1.ucinn_ascendv2__Tender_Type_for_Gifts__c = 'Cash';
        pmt1.ucinn_ascendv2__Payment_Amount__c = 2500;
        pmt1.ucinn_ascendv2__Credit_Date__c = System.today();
        pmt1.ucinn_ascendv2__Send_to_G_L__c=true;
        pmt1.ucinn_ascendv2__Session__c = sess1.Id;
        pmt1.ucinn_ascendv2__Opportunity__c = opp1.Id;
        pmt1.ucinn_ascendv2__Designation__c = desig1.Id;
        pmt1.ucinn_ascendv2__Review_Transaction_v2__c=review.id;
        pmt1.ucinn_ascendv2__Designation_Detail__c = dd1.Id;
        pmtList.add(pmt1);
        
        insert pmtList;
    }
}