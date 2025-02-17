@isTest
public class UpdateEMployeeTypeTest {
    

    @isTest
    static void CreateAffiliation(){
       ucinn_ascendv2__Trigger_Handler__c conHandler = new ucinn_ascendv2__Trigger_Handler__c();
        conHandler.Name = 'ND Contact Trigger';
        conHandler.ucinn_ascendv2__Class__c = 'Nd_ContactTriggerHandler';
        conHandler.ucinn_ascendv2__Is_Active__c = true;
        conHandler.ucinn_ascendv2__Object__c = 'Contact';
        conHandler.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;BeforeDelete;AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
        insert conHandler; 
        
        Id HrecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        
        Id degreeRecordTypeId = [select id,name from recordtype where sobjecttype='ucinn_ascendv2__Degree_Information__c' and name='School Degree Information'].Id;
            //Schema.SObjectType.ucinn_ascendv2__Degree_Information__c.getRecordTypeInfosByName().get('School Degree Information').getRecordTypeId();
        Account hsAcc = new account(recordTypeId=HrecordTypeId,name='accTest',ND_Household_Category__c='AS',ND_Household_Types__c ='I');
        insert hsAcc;
        list<Contact> conlist = new list<Contact>();
        Contact con1 = new Contact(Constituent_Status__c='A',FirstName='TestFirstName', ucinn_ascendv2__Contact_Type__c='EM',LastName='TestLastName',email='test@test.com',accountid=hsAcc.id);       
        insert con1;
        ucinn_ascendv2__Affiliation__c affrec = new ucinn_ascendv2__Affiliation__c(ucinn_ascendv2__Contact__c=con1.Id,ucinn_ascendv2__Status__c='Current',Is_Primary_Employment__c=true,
                                                                                  ucinn_ascendv2__Constituent_Role__c='Employee',ucinn_ascendv2__Account__c=hsAcc.id);
        
        insert affrec;
        
       affrec.ucinn_ascendv2__Status__c='Active at time of Death';	
       affrec.Is_Primary_Employment__c= false;
       update  affrec;
              UpdateEmployeeType.inputParams ip = new UpdateEmployeeType.inputParams();
              ip.action='D';
              ip.affiliations = new list<ucinn_ascendv2__Affiliation__c>{affrec};
              UpdateEmployeeType.updateConstituent(new list<UpdateEmployeeType.inputParams> {ip});
    }
    @isTest
    static void CreateAffiliation2(){
       ucinn_ascendv2__Trigger_Handler__c conHandler = new ucinn_ascendv2__Trigger_Handler__c();
        conHandler.Name = 'ND Contact Trigger';
        conHandler.ucinn_ascendv2__Class__c = 'Nd_ContactTriggerHandler';
        conHandler.ucinn_ascendv2__Is_Active__c = true;
        conHandler.ucinn_ascendv2__Object__c = 'Contact';
        conHandler.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;BeforeDelete;AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
        insert conHandler; 
        
        Id HrecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        
        Id degreeRecordTypeId = [select id,name from recordtype where sobjecttype='ucinn_ascendv2__Degree_Information__c' and name='School Degree Information'].Id;
            //Schema.SObjectType.ucinn_ascendv2__Degree_Information__c.getRecordTypeInfosByName().get('School Degree Information').getRecordTypeId();
        Account hsAcc = new account(recordTypeId=HrecordTypeId,name='accTest',ND_Household_Category__c='AS',ND_Household_Types__c ='I');
        insert hsAcc;
        list<Contact> conlist = new list<Contact>();
        Contact con1 = new Contact(Constituent_Status__c='A',FirstName='TestFirstName', ucinn_ascendv2__Contact_Type__c='EM',LastName='TestLastName',email='test@test.com',accountid=hsAcc.id);       
        insert con1;
        ucinn_ascendv2__Affiliation__c affrec = new ucinn_ascendv2__Affiliation__c(ucinn_ascendv2__Contact__c=con1.Id,ucinn_ascendv2__Status__c='Current',Is_Primary_Employment__c=true,
                                                                                  ucinn_ascendv2__Constituent_Role__c='Employee',ucinn_ascendv2__Account__c=hsAcc.id);
        
        insert affrec;
        
       affrec.ucinn_ascendv2__Constituent_Role__c='Retired Employee';	
       affrec.Is_Primary_Employment__c= false;
       update  affrec;
              UpdateEmployeeType.inputParams ip = new UpdateEmployeeType.inputParams();
              ip.action='R';
              ip.affiliations = new list<ucinn_ascendv2__Affiliation__c>{affrec};
              UpdateEmployeeType.updateConstituent(new list<UpdateEmployeeType.inputParams> {ip});
    }    
}