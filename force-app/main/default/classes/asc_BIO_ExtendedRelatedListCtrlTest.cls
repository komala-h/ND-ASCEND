/**
 * @author UC Innovation
 * @date 9/11/2021
 * @group Aura Controller
 * @description Test Class for asc_BIO_ExtendedRelatedListController
 */
@IsTest
public class asc_BIO_ExtendedRelatedListCtrlTest {
    
    @testSetup
    static void setupTestData() {
        
    }
    
    @isTest(seeAllData=false)
    static void testController() {
        Case newcase = new Case();
        newcase.Description = 'Test';
        insert newcase;
        
        Sobject caseRec = asc_BIO_ExtendedRelatedListController.getRecord('Case', 'ContactId', newcase.Id);
        List<Id> idList = asc_BIO_ExtendedRelatedListController.getJunctionInnerQueryIds('Select Id From Contact Limit 100');
    }
}