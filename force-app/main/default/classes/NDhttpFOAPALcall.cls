public class NDhttpFOAPALcall {
    // Pass in the endpoint to be used using the string url
    //@AuraEnabled

    @invocableMethod(label='FOAPAL Callout' description = 'FOAPAL format will be similar to this 100000-21035-72402-70001.')
    public static List<String> getCalloutResponseContents(List<string> FOAPAL) {
        String url = 'https://foapalinquiry.nd.edu/fin/foapal/InterfaceFoapalValidationServlet';
        String apiKey = '';
        //FOAPAL format will be similar to this '100000-21035-72402-70001';


        //List<String> groupedResult = FOAPAL.splitByCharacterType();
        List<String> groupedResult = new List<String>();
        for(String foapalstring: FOAPAL){ 
            foapalstring.splitByCharacterType();
            groupedResult.addall(foapalstring.splitByCharacterType());
        }    
        
        List<String> filterLogicSplitbyDash= new List<String>();
        for(String sequence :groupedResult){
            if(sequence.isAlphanumeric()){
                filterLogicSplitbyDash.add(sequence);
            } else if(String.isNotBlank(sequence)){
                List<String> brakets = sequence.split('-');
                for(String bracket :brakets){
                    filterLogicSplitbyDash.add(bracket);
                }
            }
        }
        System.debug(filterLogicSplitbyDash);
        
        System.debug('FUND='+filterLogicSplitbyDash[0]);
        string fundVar = filterLogicSplitbyDash[0];
        System.debug('ORG='+filterLogicSplitbyDash[1]);
        string orgVar = filterLogicSplitbyDash[1];
        System.debug('ACCT='+filterLogicSplitbyDash[2]);
        string acctVar = filterLogicSplitbyDash[2];
        System.debug('PGM='+filterLogicSplitbyDash[3]);
        string pgmVar = filterLogicSplitbyDash[3];
        /**need the other 2 */
       // if (filterLogicSplitbyDash.size() > 4 && String.isNotBlank(filterLogicSplitbyDash.get(4))){
        string actvVar = (filterLogicSplitbyDash.size() > 4 && String.isNotBlank(filterLogicSplitbyDash.get(4))) ? filterLogicSplitbyDash[4] : '';
        //}
        System.debug('ACTV='+actvVar);
        /*
        if (filterLogicSplitbyDash.size() > 5 && String.isNotBlank(filterLogicSplitbyDash.get(5))){
        string locVar = filterLogicSplitbyDash[5];
        }*/
        string locVar = (filterLogicSplitbyDash.size() > 5 && String.isNotBlank(filterLogicSplitbyDash.get(5))) ? filterLogicSplitbyDash[5] : '';
        System.debug('LOC='+locVar);
        
        Date dToday = Date.today();
        String dateStr = Date.today().format();
        DateTime dt = DateTime.newInstance(dToday.year(), dToday.month(),dToday.day());
        String transDate = dt.format('dd-MMM-YYYY');

        String payLoad = 'FUND='+fundVar+'&ORG='+orgVar+'&ACCT='+acctVar+'&PGM='+pgmVar+'&ACTV='+actvVar+'&LOC='+locVar+'&TRANSDATE='+transDate;
        system.debug ('payload: '+payLoad);

        // Instantiate a new http object
        Http h = new Http();
 
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        req.setBody(payLoad);
        req.setEndpoint(url);
        req.setMethod('POST');
 
        // Send the request, and return a response
        HttpResponse res = h.send(req);
        System.debug('response:--> ' + res.getBody());
        
        //return res.getBody();
        
        //UC Innovation qluong  11/23/2022 parse xml 
        String code;
        List<String> responseList = new List<String>();
        Dom.Document doc = new Dom.Document();
        doc.load(res.getBody());
        Dom.XMLNode root = doc.getRootElement();
        system.debug('root: ' + root);
        for(Dom.XmlNode rootNode: root.getChildElements()) {
            for(Dom.XmlNode childNode: rootNode.getChildElements()) {                
                if(childNode.getName() == 'code') {
                  code = childNode.getText();
                  system.debug('code: ' + code);
                  responseList.add(code);
                }
          }
        }
        
        return responseList;

    }
    
}