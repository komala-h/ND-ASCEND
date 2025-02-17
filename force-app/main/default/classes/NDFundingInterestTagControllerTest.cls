@isTest(SeeAllData=false)
public class NDFundingInterestTagControllerTest {
        
        static testmethod void insertandCheckTags() {
            Test.startTest();
            ucinn_ascendv2__Funding_Interest__c w1 = new ucinn_ascendv2__Funding_Interest__c( name='test level 1');
            insert w1;
            
            ucinn_ascendv2__Funding_Interest__c w2 = new ucinn_ascendv2__Funding_Interest__c( name='test level 2');
            insert w2;
            
            ucinn_ascendv2__Funding_Interest__c w3 = new ucinn_ascendv2__Funding_Interest__c( name='test level 3');
            insert w3;
            
            NDFundingInterestTagController.getData(w3.id);
            
            Test.stopTest();
            
            System.assertEquals(3, [select count() from ucinn_ascendv2__Funding_Interest__c ]);
            
        }
    
    }