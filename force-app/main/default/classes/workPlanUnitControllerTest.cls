@isTest(SeeAllData=false)
private class workPlanUnitControllerTest {

    
    static testmethod void insertandCheckWorkUnit() {
        Test.startTest();
        ucinn_ascendv2__Work_Plan_Unit__c w1 = new ucinn_ascendv2__Work_Plan_Unit__c( name='test level 1', Sort_Order__c=1);
        insert w1;
        //ucinn_ascendv2__Work_Plan_Unit__c qw1 = [select id from ucinn_ascendv2__Work_Plan_Unit__c where  name='test level 1' ];
        
        ucinn_ascendv2__Work_Plan_Unit__c w2 = new ucinn_ascendv2__Work_Plan_Unit__c( name='test level 2', ucinn_ascendv2__Work_Plan_Unit__c= w1.id, Sort_Order__c=2);
        insert w2;
        
        ucinn_ascendv2__Work_Plan_Unit__c w3 = new ucinn_ascendv2__Work_Plan_Unit__c( name='test level 3', ucinn_ascendv2__Work_Plan_Unit__c= w2.id, Sort_Order__c=3);
        insert w3;
        
        workPlanUnitController.getData(w3.id);
        
        Test.stopTest();
        
       // ucinn_ascendv2__Work_Plan_Unit__c qresult = [select count(id) from ucinn_ascendv2__Work_Plan_Unit__c];
        System.assertEquals(3, [select count() from ucinn_ascendv2__Work_Plan_Unit__c ]);
         //System.assertEquals(qresult, 3);
        
    }

}