@isTest(SeeAllData=false)
public class ND_TRIG_Constituent_TypeTest {
        @TestSetup
    public static void testSetup() {
        
        ucinn_ascendv2__Trigger_Handler__c customHandler1 = new ucinn_ascendv2__Trigger_Handler__c();
            customHandler1.Name = 'ND Constituent Type Handler';
            customHandler1.ucinn_ascendv2__Class__c = 'ND_Constituent_Type_Trigger_Handler';
            customHandler1.ucinn_ascendv2__Is_Active__c = true;
            customHandler1.ucinn_ascendv2__Object__c = 'Contact';
            customHandler1.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert;BeforeUpdate;BeforeDelete;AfterInsert;AfterUpdate;AfterDelete;AfterUndelete';
            //customHandler1.ucinn_ascendv2__Load_Order__c = 1;
        insert customHandler1;
            
        Contact h01 = new Contact();
        h01.FirstName = 'h01';
        h01.LastName = 'TEST';
        h01.ucinn_ascendv2__Gender__c = 'Female';
        h01.ucinn_ascendv2__Contact_Type__c = 'AL';
        h01.ucinn_ascendv2__Data_Source__c = 'WBB';
        h01.ucinn_ascendv2__Personal_Email__c = 'sample@uci.com';
        h01.Constituent_Status__c ='A';
        h01.ucinn_ascendv2__External_System_ID__c='sfarris38';
        insert h01;
        
        Contact h02 = new Contact();
        h02.FirstName = 'h01';
        h02.LastName = 'TEST';
        h02.ucinn_ascendv2__Gender__c = 'Male';
        h02.ucinn_ascendv2__Contact_Type__c = 'RE';
        h02.ucinn_ascendv2__Data_Source__c = 'WBB';
        h02.ucinn_ascendv2__Personal_Email__c = 'franco@uci.com';
        h02.Constituent_Status__c ='A';
        h02.ucinn_ascendv2__External_System_ID__c='franco226';
        insert h02;
        
        Id HrecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        
        Id degreeRecordTypeId = [select id,name from recordtype where sobjecttype='ucinn_ascendv2__Degree_Information__c' and name='School Degree Information'].Id;
            //Schema.SObjectType.ucinn_ascendv2__Degree_Information__c.getRecordTypeInfosByName().get('School Degree Information').getRecordTypeId();
        Account hsAcc = new account(recordTypeId=HrecordTypeId,name='accTest',ND_Household_Category__c='AS',ND_Household_Types__c ='I');
        insert hsAcc;
        list<Contact> conlist = new list<Contact>();
        Contact con1 = new Contact(Constituent_Status__c='A',FirstName='TestFirstName', ucinn_ascendv2__Contact_Type__c='AL',LastName='TestLastName',email='test@test.com',accountid=hsAcc.id);
        conlist.add(con1);
        Contact con2 = new Contact(Constituent_Status__c='A',FirstName='TestName', ucinn_ascendv2__Contact_Type__c='AL',LastName='TestLastName',email='test@test.com',accountid=hsAcc.id);
        conlist.add(con2);
        insert conlist;
        ucinn_ascendv2__Degree_Information__c deg= 
            new ucinn_ascendv2__Degree_Information__c(ucinn_ascendv2__Conferred_Degree_Year__c='1990',
                                                      ucinn_ascendv2__Contact__c=con1.Id,Data_Source__c='ADV',
                                                     RecordtypeId=degreeRecordTypeId);
        insert deg;
    }
     
    static void updateAR() {
        //test of higher end hierarchies, anything lower end ( > 1 ) gets kicked, in this case , Related child (RC) 

                                        
        Test.startTest();
        Contact newConstituent = [select id, ucinn_ascendv2__Contact_Type__c from contact where ucinn_ascendv2__External_System_ID__c = 'sfarris38' limit 1];
        newConstituent.ucinn_ascendv2__Contact_Type__c = 'EM;RC';
        newConstituent.ND_created_from_interim__c   = true;
        update newConstituent;
        Test.stopTest();
        
        Contact afterUpdate =[select id, ucinn_ascendv2__Contact_Type__c, ND_created_from_interim__c from contact where id = :newConstituent.id];
        
      //  System.assertEquals('AL;EM', afterUpdate.ucinn_ascendv2__Contact_Type__c);
        System.assertEquals(false, afterUpdate.ND_created_from_interim__c);


    }
    
    static void hierUpdateAR() {
        //test of all lower end hierarchies, means all items will be present
                                        
        Test.startTest();
        Contact newConstituent = [select id, ucinn_ascendv2__Contact_Type__c from contact where ucinn_ascendv2__External_System_ID__c = 'franco226' limit 1];
        newConstituent.ucinn_ascendv2__Contact_Type__c = 'FR;RC';
        newConstituent.ND_created_from_interim__c   = true;
        update newConstituent;
        Test.stopTest();
        
        Contact afterUpdate =[select id, ucinn_ascendv2__Contact_Type__c, ND_created_from_interim__c from contact where id = :newConstituent.id];
        
      //  System.assertEquals('RE;FR;RC', afterUpdate.ucinn_ascendv2__Contact_Type__c);
        System.assertEquals(false, afterUpdate.ND_created_from_interim__c);


    }  
    
    @isTest
    static void method1(){
        list<contact> conList = [select id,ucinn_ascendv2__Contact_Type__c from contact where firstName = 'TestFirstName' limit 1];     
        
        conList[0].ucinn_ascendv2__Contact_Type__c =+'ST';
        update conList[0];
      //  Nd_ContactTriggerHandler.updateconstituentAttributes(conlist);
        system.assert([select id,Nd_Suffix_Constituent_Types__c from contact where id=:conList[0].Id].Nd_Suffix_Constituent_Types__c!=null,'Suffix constituent type is not set');

    }
     /* qluong - this method is no longer used in the ND_Constituent_Type class
    @isTest
    static void clearProspectCategoryTest(){        
        Id HrecordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        Account hsAcc = new account(recordTypeId=HrecordTypeId,name='accTest',ND_Household_Category__c='R2',ND_Household_Types__c ='R2');
        insert hsAcc;
        
        Contact h01 = new Contact();
        h01.FirstName = 'h01';
        h01.LastName = 'TEST';
        h01.accountId= hsAcc.Id;
        h01.ucinn_ascendv2__Gender__c = 'Female';
        h01.ucinn_ascendv2__Contact_Type__c = 'AL';
        h01.ucinn_ascendv2__Data_Source__c = 'WBB';
        h01.ucinn_ascendv2__Personal_Email__c = 'sample@test.com';
        h01.Constituent_Status__c ='A';
        h01.ucinn_ascendv2__External_System_ID__c='hello460';
        insert h01; 
        
        test.startTest();
            h01.ucinn_ascendv2__Is_Deceased__c = true;
            h01.ucinn_ascendv2__Date_Marked_Deceased__c = system.today();
            update h01;
        test.stopTest();

    }
    */    
    static void deleteAR() {
        //test of higher end hierarchies, anything lower end ( > 1 ) gets kicked, in this case , Related child (RC) 

                                        
        Test.startTest();
        Contact newConstituent = [select id, ucinn_ascendv2__Contact_Type__c from contact where ucinn_ascendv2__External_System_ID__c = 'sfarris38' limit 1];

        delete newConstituent;
        Test.stopTest();
        
        Contact afterDelete =[select id, ucinn_ascendv2__Contact_Type__c, ND_created_from_interim__c from contact where ucinn_ascendv2__External_System_ID__c = 'sfarris38' limit 1];
        
      system.assertEquals(null, afterDelete);

    }    
}