@isTest
public class Nd_SocietyMemberShipTest {
    
    @testsetup
     static void setup() {
        ucinn_ascendv2__Trigger_Handler__c socHandler = new ucinn_ascendv2__Trigger_Handler__c();
        socHandler.Name = 'ND Society Membership Handler';
        socHandler.ucinn_ascendv2__Class__c = 'nd_SocietyMembershipTriggerHandler';
        socHandler.ucinn_ascendv2__Is_Active__c = true;
        socHandler.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Society_Membership__c';
        socHandler.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;BeforeDelete;AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
        insert socHandler; 
     }
    
    @isTest
    static void method1(){
        Id HrecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();

        Account hsAcc = new account(recordTypeId=HrecordTypeId,name='accTest',ND_Household_Category__c='AS',ND_Household_Types__c ='I');
        insert hsAcc;
        Contact con1 = new Contact(Constituent_Status__c='A',FirstName='TestFirstName', ucinn_ascendv2__Contact_Type__c='AL',LastName='TestLastName',email='test@test.com',accountid=hsAcc.id);
        insert con1;  
        ucinn_ascendv2__Giving_Society__c gs = new ucinn_ascendv2__Giving_Society__c(nd_Affiliation_Symbol__c='SS',nd_Hierarchy_Order__c=1,Name='Test');
        insert gs;
        ucinn_ascendv2__Society_Membership__c sm = new ucinn_ascendv2__Society_Membership__c(ucinn_ascendv2__Giving_Society__c=gs.Id,
                                                   name='SMTest',nd_Status__c='A',ucinn_ascendv2__Account__c=hsAcc.Id,
                                                   ucinn_ascendv2__Contact__c=con1.Id );
        Insert sm;
        update sm;
        system.assert([select id,nd_Suffix_Giving_Societies__c from contact where id=:con1.id]!=null, 'Suffix constituent type is not set');
        
    }
}