@istest
public class MockResponseforMetadataApiCalls implements WebServiceMock {
    public static final String[] RECORD_TYPE_FULL_NAMES = new String[] {
        'cve__BenefitClaimed__c.cve__ShortTermDisability'
    };
    public static final String[] CUSTOM_FIELD_FULL_NAMES = new String[] {
        'Contact.Email'
         ,'Account.ND_Household_Types__c'
         ,'cve__BenefitClaimed__c.cve__DateOfDiagnosis__c'
    };

    public void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType
            ) {

        if (request instanceof MetadataService.readMetadata_element) {
            response.put('response_x', readResponse(request));
        } else if (request instanceof MetadataService.updateMetadata_element) {
            response.put('response_x', updateResponse(request));
        } else if (request instanceof MetadataService.upsertMetadata_element) {
            response.put('response_x', upsertResponse(request));
        } else {
            System.assert(false, 'Unexpected request ' + request);
        }
    }    

    // Implements couple of requests
    private MetadataService.IReadResponseElement readResponse(Object request) {

        MetadataService.readMetadata_element r = (MetadataService.readMetadata_element) request;
        system.debug('r.type_x'+r.type_x);
string localPasser = generateRandomString(2);
        if (r.type_x == 'RecordType') {

            MetadataService.PicklistValue picklistValue = new MetadataService.PicklistValue();
            picklistValue.fullName = 'Pending';

            MetadataService.RecordTypePicklistValue recordTypePicklistValue = new MetadataService.RecordTypePicklistValue();
            recordTypePicklistValue.picklist = 'cve__Status__c';
            recordTypePicklistValue.values = new MetadataService.PicklistValue[] {picklistValue};

            MetadataService.RecordType recordType = new MetadataService.RecordType();
            recordType.fullName = RECORD_TYPE_FULL_NAMES[0];
            recordType.picklistValues = new MetadataService.RecordTypePicklistValue[] {
                recordTypePicklistValue
            };

            MetadataService.ReadRecordTypeResult result = new MetadataService.ReadRecordTypeResult();
            result.records = new MetadataService.RecordType[] {
                recordType
            };

            MetadataService.readRecordTypeResponse_element responseElement = new MetadataService.readRecordTypeResponse_element();
            responseElement.result = result;

            return responseElement;

        } else if (r.type_x == 'CustomField') {

            MetadataService.ReadCustomFieldResult result = new MetadataService.ReadCustomFieldResult();
            result.records = new MetadataService.CustomField[] {
                addressType(localPasser), createContactEmailField()
               // , createBenefitClaimedDateOfDiagnosisField()
            };

            MetadataService.readCustomFieldResponse_element responseElement = new MetadataService.readCustomFieldResponse_element();
            responseElement.result = result;

            return responseElement;

        } else if ( r.type_x =='GlobalValueSet') {
            
            MetadataService.ReadGlobalValueSetResult  result = new MetadataService.ReadGlobalValueSetResult ();
            result.records = new MetadataService.GlobalValueSet[]{
                getGlobalData(localPasser)
            };

            MetadataService.readGlobalValueSetResponse_element  responseElement = new MetadataService.readGlobalValueSetResponse_element ();
            responseElement.result = result;

            return responseElement;

        }else {

            System.assert(false, 'Unexpected read type ' + r.type_x);
            return null;
        }
    }

    public static MetadataService.CustomField createContactEmailField() {

        MetadataService.CustomField f = new MetadataService.CustomField();
        f.type_x = String.valueOf(DisplayType.Email);
        f.fullName = CUSTOM_FIELD_FULL_NAMES[0];
        f.label = 'Email';
        f.length = 80;
        f.encrypted = false;

        return f;
    }

    public static MetadataService.CustomField createBenefitClaimedDateOfDiagnosisField() {

        MetadataService.CustomField f = new MetadataService.CustomField();
        f.type_x = String.valueOf(DisplayType.Date);
        f.fullName = CUSTOM_FIELD_FULL_NAMES[1];
        f.label = 'Date';
        f.encrypted = false;

        return f;
    }

    public static MetadataService.CustomField addressType(string localPasser) {

        MetadataService.CustomField f = new MetadataService.CustomField();
        f.type_x = String.valueOf(DisplayType.Date);
        f.fullName ='Lead.Address_Type__c';
        f.label = 'Address Type';
        f.encrypted = false;
        f.valueSet= getData(localPasser);
        return f;
    }

    // Does nothing except return success
    private MetadataService.updateMetadataResponse_element updateResponse(Object request) {

        MetadataService.SaveResult result = new MetadataService.SaveResult();
        result.success = true;

        MetadataService.updateMetadataResponse_element responseElement = new MetadataService.updateMetadataResponse_element();
        responseElement.result = new MetadataService.SaveResult[] {result};

        return responseElement;
    }

    // Does nothing except return success
    private MetadataService.upsertMetadataResponse_element upsertResponse(Object request) {

        MetadataService.UpsertResult result = new MetadataService.UpsertResult();
        result.success = true;

        MetadataService.upsertMetadataResponse_element responseElement = new MetadataService.upsertMetadataResponse_element();
        responseElement.result = new MetadataService.UpsertResult[] {result};

        return responseElement;
    }
    public static String generateRandomString(Integer len) {
    final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
    String randStr = '';
    while (randStr.length() < len) {
       Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
       randStr += chars.substring(idx, idx+1);
    }
    return randStr; 
    }
    
    public static   MetadataService.valueset  getData(string localPasser){
system.debug('getData localPasser= '+localPasser);
        MetadataService.ValueSetValuesDefinition df = new MetadataService.ValueSetValuesDefinition();
        MetadataService.CustomValue cv = new MetadataService.CustomValue();
        cv.isActive=true;
        cv.fullName =localPasser;
        cv.default_x =true;
        df.value = new List<MetadataService.CustomValue>{cv};
        MetadataService.valueset ct = new MetadataService.valueset();
        ct.valueSetDefinition =df;
        ct.valueSetName =localPasser;
        return ct;
    }
    public static   MetadataService.GlobalValueSet   getGlobalData(string localPasser){
        system.debug('global localPasser= '+localPasser);
        MetadataService.GlobalValueSet cv = new MetadataService.GlobalValueSet();
        cv.fullName=localPasser;
        cv.masterLabel ='testv';
        cv.sorted =true;
        MetadataService.CustomValue  c = new MetadataService.CustomValue ();
        c.default_x=true;
        c.isActive=true;
        c.label='Test1';
        c.fullName ='tt';
        cv.customValue= new List<MetadataService.customValue>{c};
        return cv;
    }
}