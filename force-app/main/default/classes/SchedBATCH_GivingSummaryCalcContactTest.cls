@isTest(SeeAllData=false)

public class SchedBATCH_GivingSummaryCalcContactTest {
    @isTest static void ftest(){
        Test.startTest();
        SchedulableContext a;
        SchedBATCH_GivingSummaryCalcContact.execute(a);
        Test.stopTest();
	}
}