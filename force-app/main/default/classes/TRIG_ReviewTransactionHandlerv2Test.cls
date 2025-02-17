@IsTest
public class TRIG_ReviewTransactionHandlerv2Test {

    @TestSetup
    public static void setupTestData() {
        List<ucinn_ascendv2__Trigger_Handler__c> handlers = new List<ucinn_ascendv2__Trigger_Handler__c>();
        
        ucinn_ascendv2__Trigger_Handler__c ascend_TRIG_ReviewTransactionHandlerv2 = new ucinn_ascendv2__Trigger_Handler__c();
        ascend_TRIG_ReviewTransactionHandlerv2.Name = 'Custom Review Handler';
        ascend_TRIG_ReviewTransactionHandlerv2.ucinn_ascendv2__Class__c = 'ascend_TRIG_ReviewTransactionHandlerv2';
        ascend_TRIG_ReviewTransactionHandlerv2.ucinn_ascendv2__Is_Active__c = true;
        ascend_TRIG_ReviewTransactionHandlerv2.ucinn_ascendv2__Is_Asynchronous__c = false;
        ascend_TRIG_ReviewTransactionHandlerv2.ucinn_ascendv2__Is_User_Managed__c = false;
        ascend_TRIG_ReviewTransactionHandlerv2.ucinn_ascendv2__Load_Order__c = 2.0;
        ascend_TRIG_ReviewTransactionHandlerv2.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Review_Transaction_v2__c';
        ascend_TRIG_ReviewTransactionHandlerv2.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;BeforeDelete;AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
        handlers.add(ascend_TRIG_ReviewTransactionHandlerv2);
        
        ucinn_ascendv2__Trigger_Handler__c reviewTransactionv2HandlerCustom = new ucinn_ascendv2__Trigger_Handler__c();
        reviewTransactionv2HandlerCustom.Name = 'Custom Review Handler';
        reviewTransactionv2HandlerCustom.ucinn_ascendv2__Class__c = 'TRIG_ReviewTransactionHandlerv2';
        reviewTransactionv2HandlerCustom.ucinn_ascendv2__Is_Active__c = true;
        reviewTransactionv2HandlerCustom.ucinn_ascendv2__Is_Asynchronous__c = false;
        reviewTransactionv2HandlerCustom.ucinn_ascendv2__Is_User_Managed__c = false;
        reviewTransactionv2HandlerCustom.ucinn_ascendv2__Load_Order__c = 1.0;
        reviewTransactionv2HandlerCustom.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Review_Transaction_v2__c';
        reviewTransactionv2HandlerCustom.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;BeforeDelete;AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
        handlers.add(reviewTransactionv2HandlerCustom);
        insert handlers;
    }
    
    @isTest
    public static void testPopulateExternalID() {
        Contact cont = new Contact();
        cont.Salutation = 'Mr';
        cont.FirstName = 'First';
        cont.LastName = 'Last';
        cont.MobilePhone = '111-111-1111';
        cont.Email = 'test@test.com';
        cont.Constituent_Status__c = 'A';
        cont.ucinn_ascendv2__Contact_Type__c = 'Other';
        cont.ucinn_ascendv2__Payroll_ID__c = '123';
        insert cont;

        Contact rel2Cont = new Contact();
        rel2Cont.Salutation = 'Dr';
        rel2Cont.FirstName = 'Test';
        rel2Cont.LastName = 'QA';
        rel2Cont.Constituent_Status__c = 'A';
        rel2Cont.MobilePhone = '111-111-1112';
        rel2Cont.Email = 'test@test.com';
        rel2Cont.ucinn_ascendv2__Contact_Type__c = 'Other';
        rel2Cont.ucinn_ascendv2__Payroll_ID__c = '789';
        insert rel2Cont;

        Campaign camp = new Campaign();
        camp.Name = '-';
        camp.StartDate = Date.today();
        camp.ucinn_ascendv2__Motivation_Code__c = 'Campaign001';
        insert camp;
        
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
        designation.ucinn_ascendv2__G_L_Effective_Date__c = System.today();
        designation.Sub_Department__c = ao3.Id;
        insert designation;

        ucinn_ascendv2__Review_Transaction_v2__c rtv2 = new ucinn_ascendv2__Review_Transaction_v2__c();
        rtv2.Name = 'test';
        /*rtv2.ucinn_ascendv2__Transaction_Type__c = 'Gift';
        rtv2.ucinn_ascendv2__Opportunity_Type__c = 'Outright';
        rtv2.ucinn_ascendv2__Status__c = null;
        rtv2.ucinn_ascendv2__Contact__c = cont.Id;
        rtv2.ucinn_ascendv2__Designation_1__c = designation.Id;
        rtv2.ucinn_ascendv2__Campaign__c = camp.Id;

        rtv2.ucinn_ascendv2__Tender_Type_1__c = 'Cash';
        rtv2.ucinn_ascendv2__Transaction_Date__c = Date.today();
        rtv2.ucinn_ascendv2__Payment_Amount_1_1__c = 100;
        rtv2.ucinn_ascendv2__Non_Gift_Amount_1_1__c = 100;
        rtv2.ucinn_ascendv2__Face_Value_1_1__c = 100;
        rtv2.ucinn_ascendv2__Payment_Date_1_1__c = Date.today();
        rtv2.ucinn_ascendv2__Description__c  = 'Session description.';

        rtv2.ucinn_ascendv2__Tribute_Type_1__c = 'H';
        rtv2.ucinn_ascendv2__In_Memory_Honor_Contact_1__c = rel2Cont.Id;
        rtv2.ucinn_ascendv2__Notify_Contact_1__c = rel2Cont.Id;

        rtv2.ucinn_ascendv2__Hard_and_Soft_Credit_Type_1_1__c = 'Soft';
        rtv2.ucinn_ascendv2__Hard_and_Soft_Credit_Contact_1_1__c = rel2Cont.Id;
        rtv2.ucinn_ascendv2__Hard_and_Soft_Credit_Amount_1_1__c = 100;*/
        rtv2.recordTypeId = Schema.SObjectType.ucinn_ascendv2__Review_Transaction_v2__c.getRecordTypeInfosByDeveloperName().get('General_Transaction').getRecordTypeId();
        //rtv2.ucinn_ascendv2__External_System_ID__c = 'GNRL-12345'; // clin Added on 10/25/2022 - confirm with Brandon Chung
        insert rtv2;
                
        ucinn_ascendv2__Review_Transaction_v2__c updatedRtv2 = [SELECT id, ucinn_ascendv2__External_System_ID__c , nd_Review_Transaction_Auto_Number__c
                                                                FROM ucinn_ascendv2__Review_Transaction_v2__c 
                                                                WHERE id =: rtv2.id LIMIT 1];
        
        System.assertEquals(updatedRtv2.ucinn_ascendv2__External_System_ID__c, 'GNRL-' + updatedRtv2.nd_Review_Transaction_Auto_Number__c);
    }
}