@isTest
global class MockHttpResponseGeneratorFOAPAL implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/xml');
        res.setBody('<?xml version=\'1.0\' encoding=\'UTF-8\'?><FOAPAL_validation><status_information><code>0</code><status_message>Valid FOAPAL.</status_message></status_information><FOAPAL><fund>100000_G</fund><org>21035_G</org><acct>72402_G</acct><pgm>70001_G</pgm><actv>null_W</actv><loc>null_W</loc></FOAPAL></FOAPAL_validation>');
        res.setStatusCode(200);
        return res;
    }
}