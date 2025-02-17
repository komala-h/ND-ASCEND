@isTest
public class EndowmentCasesReportTest {
    
    @isTest
    Static void method1(){
    
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
        designation.Steward_Reporting_Code__c='FL';
        designation.ucinn_ascendv2__G_L_Effective_Date__c = System.today();
        designation.Sub_Department__c = ao3.Id;
        insert designation;
        test.starttest();
            EndowmentCasesReport delBatchSchedule = new EndowmentCasesReport();  
        
            String chron = '0 0 0 1 5 ?';        
            system.schedule('Test Sched', chron, delBatchSchedule);
        test.stopTest();
        
    }

}