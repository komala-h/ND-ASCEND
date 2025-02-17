@isTest
public class Nd_Involvement_Adv_Council_Test {
  @isTest
    static void method1(){
        
        ucinn_ascendv2__Trigger_Handler__c degHandler = new ucinn_ascendv2__Trigger_Handler__c();
        degHandler.Name = 'Involvement Advisory Council';
        degHandler.ucinn_ascendv2__Class__c = 'Nd_Involvement_Advisory_Council';
        degHandler.ucinn_ascendv2__Is_Active__c = true;
        degHandler.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Involvement__c';
        degHandler.ucinn_ascendv2__Trigger_Action__c = 'AfterInsert;AfterUpdate';
        insert degHandler; 
        
        Id HrecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        
        Id degreeRecordTypeId = [select id,name from recordtype where sobjecttype='ucinn_ascendv2__Degree_Information__c' and name='School Degree Information'].Id;
            //Schema.SObjectType.ucinn_ascendv2__Degree_Information__c.getRecordTypeInfosByName().get('School Degree Information').getRecordTypeId();
            
        Id involvementRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='ucinn_ascendv2__Involvement__c' AND Name='Advisory Council'].Id; 
        system.debug(involvementRecordTypeId);
        
        Id involvementValueRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='ucinn_ascendv2__Involvement_Value__c' AND Name='Advisory Council'].Id; 
        system.debug(involvementValueRecordTypeId);
        
        //Create Account
        Account hsAcc = new account(recordTypeId=HrecordTypeId,name='accTest',ND_Household_Category__c='AS',ND_Household_Types__c='S');
        insert hsAcc;
        
         // Create Contacts
        Contact spouse = new Contact(Constituent_Status__c='A',FirstName='SpouseFirstName',ucinn_ascendv2__Contact_Type__c='AL',LastName='SpouseLastName', email='spouse@test.com',accountId=hsAcc.id, ucinn_ascendv2__Preferred_Spouse__c=null);   
        insert spouse;
        Contact con1 = new Contact(Constituent_Status__c='A',FirstName='TestFirstName', ucinn_ascendv2__Contact_Type__c='AL',LastName='TestLastName',email='test@test.com',accountid=hsAcc.id,nd_Suffix_Constituent_Types__c='AL90', ucinn_ascendv2__Preferred_Spouse__c=spouse.Id);
        insert con1;
        
          //create Degree Information for contact with involvement
        ucinn_ascendv2__Degree_Information__c deg1 = new ucinn_ascendv2__Degree_Information__c
            (ucinn_ascendv2__Conferred_Degree_Year__c='1991',ucinn_ascendv2__Contact__c=spouse.Id,
            Data_Source__c='ADV',RecordTypeId=degreeRecordTypeId );       
        insert deg1;  
        
         // Create Degree information for Spouse
        ucinn_ascendv2__Degree_Information__c deg= 
            new ucinn_ascendv2__Degree_Information__c(ucinn_ascendv2__Conferred_Degree_Year__c='1990',
                                                      ucinn_ascendv2__Contact__c=con1.Id,Data_Source__c='ACN',
                                                     RecordtypeId=degreeRecordTypeId);
        insert deg;        
        
      // Create Involvement Value Records
    	ucinn_ascendv2__Involvement_Value__c involvementValue = new ucinn_ascendv2__Involvement_Value__c(Name='TEST450',ucinn_ascendv2__Involvement_Description__c='TEST',
        RecordTypeId=involvementValueRecordTypeId);    	
    	insert involvementValue;

          // Create Involvement Records for Contact
    	ucinn_ascendv2__Involvement__c involvement = new ucinn_ascendv2__Involvement__c(Name='InvolTest',
        ucinn_ascendv2__Contact__c=con1.Id,ucinn_ascendv2__Status__c='A',ucinn_ascendv2__Involvement_Code__c=involvementValue.Id,Data_Source__c='ACN',RecordTypeId=involvementRecordTypeId);
         insert involvement;
        
        involvement.ucinn_ascendv2__Status__c='H';
        update involvement;
    }

}