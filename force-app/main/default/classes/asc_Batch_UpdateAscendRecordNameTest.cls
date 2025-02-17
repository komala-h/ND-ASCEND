@isTest
private class asc_Batch_UpdateAscendRecordNameTest {
    @isTest
    static void batchTest() {
        Id oppPledgeRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Pledge').getRecordTypeId();
        List<ucinn_ascendv2__Trigger_Handler__c> thList = new List<ucinn_ascendv2__Trigger_Handler__c>();

        ucinn_ascendv2__Trigger_Handler__c th1 = new ucinn_ascendv2__Trigger_Handler__c();
        th1.Name = 'Session Handler';
        th1.ucinn_ascendv2__Class__c = 'ascend_TRIG_SessionHandler';
        th1.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Session__c';
        th1.ucinn_ascendv2__Load_Order__c = 1.0;
        th1.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert; BeforeUpdate; BeforeDelete; AfterInsert; AfterUpdate; AfterDelete; AfterUndelete';
        th1.ucinn_ascendv2__Is_Active__c = false;
        thList.add(th1);
        ucinn_ascendv2__Trigger_Handler__c th2 = new ucinn_ascendv2__Trigger_Handler__c();
        th2.Name = 'Address Handler';
        th2.ucinn_ascendv2__Class__c = 'ascend_TRIG_AddressHandler';
        th2.ucinn_ascendv2__Object__c = 'ucinn_ascendv2__Address__c';
        th2.ucinn_ascendv2__Load_Order__c = 1.0;
        th2.ucinn_ascendv2__Trigger_Action__c = 'BeforeInsert; BeforeUpdate; BeforeDelete; AfterInsert; AfterUpdate; AfterDelete; AfterUndelete';
        th2.ucinn_ascendv2__Is_Active__c = false;
        thList.add(th2);
        insert thList;

        Contact con1 = new Contact(FirstName='TestFirstName', LastName='TestLastName',Constituent_Status__c = 'A');
        insert con1;

   /*     Opportunity opp = new Opportunity(Name='P', 
                                        StageName='Planned', 
                                        ucinn_ascendv2__Contact__c=con1.Id, 
                                        closeDate=system.today(), 
                                        RecordTypeId=oppPledgeRTId);
        insert opp; */

       
        Opportunity opp = new Opportunity();
        opp.Name = 'P';
        opp.ucinn_ascendv2__Contact__c = con1.Id;
        opp.StageName = 'Planned';
        opp.ucinn_ascendv2__Tender_Type_for_Gifts__c = 'Cash';
        opp.Amount =125000;
        opp.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Pledge').getRecordTypeId();
        opp.ucinn_ascendv2__Adjusted_Gift__c = null;
        opp.ucinn_ascendv2__Credit_Date__c = System.today();
        opp.Type =  'Outright';
        opp.CloseDate =  System.today();
        insert opp;
        
        ucinn_ascendv2__Session__c session = new ucinn_ascendv2__Session__c();
        insert session;

        ucinn_ascendv2__Address__c address = new ucinn_ascendv2__Address__c();
        insert address;

        String qryStr1 = 'SELECT Id, Name, ucinn_ascendv2__Proposal_ID__c FROM Opportunity WHERE RecordType.Name = \'Pledge\' AND Name LIKE \'P%\'';
        asc_Batch_UpdateAscendRecordName batch1 = new asc_Batch_UpdateAscendRecordName(qryStr1);
        Database.executeBatch(batch1, 100);
        asc_Batch_UpdateAscendRecordName batch2 = new asc_Batch_UpdateAscendRecordName(qryStr1, true);
        Database.executeBatch(batch2, 100);

        String qryStr2 = 'SELECT Id, Name, ucinn_ascendv2__Session_Name_Auto_Number__c, CreatedDate FROM ucinn_ascendv2__Session__c WHERE (NOT Name LIKE \'S%\')';
        asc_Batch_UpdateAscendRecordName batch3 = new asc_Batch_UpdateAscendRecordName(qryStr2);
        Database.executeBatch(batch3, 100);

        String qryStr3 = 'SELECT Id, Name, ucinn_ascendv2__Address_Name_Auto_Number__c FROM ucinn_ascendv2__Address__c WHERE (NOT Name LIKE \'ADDR%\')';
        asc_Batch_UpdateAscendRecordName batch4 = new asc_Batch_UpdateAscendRecordName(qryStr3);
        Database.executeBatch(batch4, 100);
    }
}