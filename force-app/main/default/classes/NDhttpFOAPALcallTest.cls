@isTest(SeeAllData = false)
private class NDhttpFOAPALcallTest {

     @isTest static void testCallout() {
         
        Test.startTest();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorFOAPAL());

         
        List<String> results = NDhttpFOAPALcall.getCalloutResponseContents(new list<string>{'100000-21035-72402-70001'});
         system.debug('results: '+results);

         Boolean isitempty = results.size()>0;
         System.assertEquals(true, isitempty,
                           'The result should not be empty.'); 
    }
}