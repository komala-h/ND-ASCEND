@isTest
public class ND_CleanupIntegrationInBatchTest {
    @testSetup 
    static void setup() {
        List<Integration_In__c> intList= new List<Integration_In__c>();
  		Integration_In__c i1 = new Integration_In__c(status__c='Done',json_message__c='{"object" : {"event" : {"event_last_modified_by" : "0050R00000CpBCcQAN","event_sequence_number" : "17923819","event_type" : "I","event_time" : "2024-01-13T13:41:33.000Z","event_id" : "a08DV00000AAm9wYAD","source_schema" : "none","source_table" : "Education_History__c","source_database" : "Salesforce"},"target" : {"RecordtypeName__c" : "Non_ND_Degree","Institution_Code__c" : "123456789","Constituent_ID__c" : "2068251","hivebrite_create_from_id__c" : "","Integration_Record_ID__c" : "5493","Source_Code_API__c" : "","Source_Code_NEW__c" : "","sfl_load_unique_id__c" : "","sfl_load_process_id__c" : "","sfl_load_group_id__c" : "","Concentration_2_Field_of_Study__c" : "","Unknown_Institution_Name__c" : "","xseq__c" : "","local_ind__c" : false,"Non_Grad__c" : "","Minor_2__c" : "MADS","Minor_1__c" : "MAFN","Major_3__c" : "AME","Major_2__c" : "ACCY","Honorary_Alum_Ind__c" : false,"Education_Major_1__c" : "ACCT","Division__c" : "","Department__c" : "","Degree_Level__c" : "B","Data_Source__c" : "P21","Concentration_1_Field_of_Study__c" : "ACCT","Comments__c" : "test","College__c" : "","Adm_Year__c" : "","Adm_Type__c" : "","Academic_Degree__c" : "AU","Executive__c" : false,"Old_Education_History_ID__c" : "","School_Old__c" : "","Institution__c" : "001DV00001osSLAYA2","Education_Year__c" : "2024","Education_Grad_Date_1__c" : "","External_ID__c" : "","Constituent__c" : "0033600001dWg4VAAS","Old_Concentration_1_Field_of_Study__c" : "","Old_Education_Major_1__c" : "","Old_Academic_Degree__c" : "","LastReferencedDate" : "","LastViewedDate" : "","SystemModstamp" : "2024-01-13T13:41:33.000Z","LastModifiedById" : "0050R00000CpBCcQAN","LastModifiedDate" : "2024-01-13T13:41:33.000Z","CreatedById" : "0050R00000CpBCcQAN","CreatedDate" : "2024-01-13T13:41:33.000Z","RecordTypeId" : "01236000000o5mAAAQ","Name" : "EH-839788","IsDeleted" : false,"Id" : "a08DV00000AAm9wYAD","type" : [ "sf:sObject", "Education_History__c" ]}}}');
        Integration_In__c i2 = new Integration_In__c(status__c='Discard',json_message__c='{"object" : {"event" : {"event_last_modified_by" : "0050R00000CpBCcQAN","event_sequence_number" : "17923819","event_type" : "I","event_time" : "2024-01-13T13:41:33.000Z","event_id" : "a08DV00000AAm9wYAD","source_schema" : "none","source_table" : "Education_History__c","source_database" : "Salesforce"},"target" : {"RecordtypeName__c" : "Non_ND_Degree","Institution_Code__c" : "123456789","Constituent_ID__c" : "2068251","hivebrite_create_from_id__c" : "","Integration_Record_ID__c" : "5493","Source_Code_API__c" : "","Source_Code_NEW__c" : "","sfl_load_unique_id__c" : "","sfl_load_process_id__c" : "","sfl_load_group_id__c" : "","Concentration_2_Field_of_Study__c" : "","Unknown_Institution_Name__c" : "","xseq__c" : "","local_ind__c" : false,"Non_Grad__c" : "","Minor_2__c" : "MADS","Minor_1__c" : "MAFN","Major_3__c" : "AME","Major_2__c" : "ACCY","Honorary_Alum_Ind__c" : false,"Education_Major_1__c" : "ACCT","Division__c" : "","Department__c" : "","Degree_Level__c" : "B","Data_Source__c" : "P21","Concentration_1_Field_of_Study__c" : "ACCT","Comments__c" : "test","College__c" : "","Adm_Year__c" : "","Adm_Type__c" : "","Academic_Degree__c" : "AU","Executive__c" : false,"Old_Education_History_ID__c" : "","School_Old__c" : "","Institution__c" : "001DV00001osSLAYA2","Education_Year__c" : "2024","Education_Grad_Date_1__c" : "","External_ID__c" : "","Constituent__c" : "0033600001dWg4VAAS","Old_Concentration_1_Field_of_Study__c" : "","Old_Education_Major_1__c" : "","Old_Academic_Degree__c" : "","LastReferencedDate" : "","LastViewedDate" : "","SystemModstamp" : "2024-01-13T13:41:33.000Z","LastModifiedById" : "0050R00000CpBCcQAN","LastModifiedDate" : "2024-01-13T13:41:33.000Z","CreatedById" : "0050R00000CpBCcQAN","CreatedDate" : "2024-01-13T13:41:33.000Z","RecordTypeId" : "01236000000o5mAAAQ","Name" : "EH-839788","IsDeleted" : false,"Id" : "a08DV00000AAm9wYAD","type" : [ "sf:sObject", "Education_History__c" ]}}}');
		intList.add(i1);
        intList.add(i2);
        insert intList;
    }
    
    static testmethod void testDeleteDoneIntegrationIn() {
        List<Integration_In__c> intList= [select id,status__c from Integration_In__c limit 2 ];
        
        Test.startTest();
        ND_CleanupIntegrationInBatch icb =  new ND_CleanupIntegrationInBatch();
        database.executeBatch(icb);
        Test.stopTest();
    }
    
    static testMethod void scheduleBatch() {    
        TracHier.HierarchyAPI.setTriggerDisabled();
        test.starttest();
        ND_CleanupIntegrationInBatch i = new ND_CleanupIntegrationInBatch();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, i);
        test.stopTest();
    } 
    
}