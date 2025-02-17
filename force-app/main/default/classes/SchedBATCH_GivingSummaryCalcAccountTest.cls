@isTest(SeeAllData=false)

public class SchedBATCH_GivingSummaryCalcAccountTest {
    @isTest static void ftest(){
        Test.startTest();
        SchedulableContext a;
        SchedBATCH_GivingSummaryCalcAccount.execute(a);
        Test.stopTest();
	}
}