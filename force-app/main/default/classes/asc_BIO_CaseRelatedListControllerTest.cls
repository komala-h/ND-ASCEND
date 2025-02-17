/**
 * @author UC Innovation
 * @date 8/29/2021
 * @group Aura Controller
 * @description Test Class for asc_BIO_CaseRelatedListController
 */
@IsTest
public class asc_BIO_CaseRelatedListControllerTest {
    
    @testSetup
    static void setupTestData() {
        
    }
    
    @isTest(seeAllData=false)
    static void testController() {
        Case newcase = new Case();
        newcase.Description = 'Test';
        insert newcase;
        
        Case caseRec = asc_BIO_CaseRelatedListController.getCase(newcase.Id);
    }
}