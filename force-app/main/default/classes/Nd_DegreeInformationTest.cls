@isTest
public class Nd_DegreeInformationTest {

    @isTest
    static void method1(){
        ucinn_ascendv2__Trigger_Handler__c degHandler = new ucinn_ascendv2__Trigger_Handler__c();
        degHandler.Name = 'ND Degree Information Handler';
        degHandler.ucinn_ascendv2__Class__c = 'nd_DegreeInformationHandlerCls';
        degHandler.ucinn_ascendv2__Is_Active__c = true;
        degHandler.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Degree_Information__c';
        degHandler.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;BeforeDelete;AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
        insert degHandler; 
        
        Id HrecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        
        Id degreeRecordTypeId = [select id,name from recordtype where sobjecttype='ucinn_ascendv2__Degree_Information__c' and name='School Degree Information'].Id;
            //Schema.SObjectType.ucinn_ascendv2__Degree_Information__c.getRecordTypeInfosByName().get('School Degree Information').getRecordTypeId();
        Account hsAcc = new account(recordTypeId=HrecordTypeId,name='accTest',ND_Household_Category__c='AS',ND_Household_Types__c='S');
        insert hsAcc;
        Contact con1 = new Contact(Constituent_Status__c='A',FirstName='TestFirstName', ucinn_ascendv2__Contact_Type__c='AL',LastName='TestLastName',email='test@test.com',accountid=hsAcc.id,nd_Suffix_Constituent_Types__c='AL90');
        insert con1;
        ucinn_ascendv2__Degree_Information__c deg= 
            new ucinn_ascendv2__Degree_Information__c(ucinn_ascendv2__Conferred_Degree_Year__c='1990',
                                                      ucinn_ascendv2__Contact__c=con1.Id,Data_Source__c='ADV',
                                                     RecordtypeId=degreeRecordTypeId);
        insert deg;
        deg.ucinn_ascendv2__Conferred_Degree_Year__c='1989';
        update deg ;
        list<contact> con = [Select id,Nd_Suffix_Constituent_Types__c from contact where id=:con1.Id];

        system.assert(con[0].Nd_Suffix_Constituent_Types__c =='AL89','Suffix constituent type is not set'); 
    
}
}