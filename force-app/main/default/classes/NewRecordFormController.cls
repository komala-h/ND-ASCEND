/**
 * @author UC Innovation
 * @date 2/11/2023
 * @group LWC Controller
 * @description Controller for newRecordForm component
 */
public class NewRecordFormController {
    
    public class LayoutSection {
		@AuraEnabled 
        public String key;

		@AuraEnabled 
        public String label;
        
    	@AuraEnabled 
        public List<LayoutField> lstFields;
        
        @AuraEnabled 
        public Integer totalColumns;
        
        public LayoutSection( String key, String label, Integer totalColumns ) {
	    	this.key = key;
	    	this.label = label;
            this.totalColumns = totalColumns;
            this.lstFields = new List<LayoutField>();
        }
    }
    
    private class LayoutColumn {
    	private List<LayoutField> lstFields;   
        
        public LayoutColumn() {
            this.lstFields = new List<LayoutField>();
        }
    }
    
    public class LayoutField { 
		@AuraEnabled 
        public String key;

        @AuraEnabled 
        public String fieldName;
        
        @AuraEnabled 
        public String fieldLabel;
        
        @AuraEnabled 
        public Boolean isRequired;
        
        @AuraEnabled 
        public Boolean isReadOnly;
        
        public LayoutField() {}
        
        public LayoutField( String key, Metadata.LayoutItem li, Map<String, Schema.SObjectField> fields) {
            this.key = key;
            this.fieldName = li.field;
            this.isRequired = false;
            this.isReadOnly = false;
            
            if (fields.containsKey(this.fieldName)) {
                this.fieldLabel = fields.get(this.fieldName).getDescribe().getLabel();
            }
            
            if (li.behavior == Metadata.UiBehavior.Required) {
                this.isRequired = true;
            }
            
            else if (li.behavior == Metadata.UiBehavior.ReadOnly) {
                this.isReadOnly = true;
            }    
        }
    }

    @AuraEnabled
    public static string getLayoutFromRecordType(String recordTypeId) {
        String query = 'select Layout.Name, Layout.FullName, Layout.NamespacePrefix from ProfileLayout where ProfileId = \'' + UserInfo.getProfileId() + '\' And RecordTypeId = \'' + recordTypeId + '\'';
        System.debug('query=' + query);
        String body = toolingAPISOQL(query);
        System.debug(LoggingLevel.ERROR, '@@@ v: ' + body );
        String fullname = body.substringBetween('"FullName":"', '"');
        System.debug(LoggingLevel.ERROR, '@@@ v: ' + fullname );
        return fullname;
    }

    @AuraEnabled
    public static string getLayoutFromObjectName(String objectName) {
        String query = 'select Layout.Name, Layout.FullName, Layout.NamespacePrefix from ProfileLayout where ProfileId = \'' + UserInfo.getProfileId() + '\' And TableEnumOrId = \'' + objectName + '\'';
        System.debug('query=' + query);
        String body = toolingAPISOQL(query);
        System.debug(LoggingLevel.ERROR, '@@@ v: ' + body );
        String fullname = body.substringBetween('"FullName":"', '"');
        System.debug(LoggingLevel.ERROR, '@@@ v: ' + fullname );
        return fullname;
    }

    static String restGet(String endPoint, String method, String sid) {
        if (!Test.isRunningTest()) {
            Http h = new Http();
            HttpRequest hr = new HttpRequest();
            hr.setHeader('Authorization', 'Bearer ' + sid);
            hr.setTimeout(60000);
            hr.setEndpoint(endPoint);
            hr.setMethod(method);
            HttpResponse r = h.send(hr);
            return r.getBody();
        } else {
            return '{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"ProfileLayout","records":[]}';
        }
    }
    static String toolingAPISOQL(String query) {
        // Use named credential (ascend_Salesforce_API) to aoid SessionId restriction from lightning component
        return restGet( 'callout:ascend_Salesforce_API/services/data/v41.0/tooling/query?q='+ (query.replace(' ', '+')),'GET', UserInfo.getSessionId() );
    }

    @AuraEnabled 
    public static List<LayoutSection> getPageLayoutFields(String objectName, String layoutName) {
        Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        List<LayoutSection> lstSections = new List<LayoutSection>();
        
        try {
            // Provide the page layout name here
            // You can give multiple page layout names here as well
            List<String> componentNameList = new List<String>{layoutName};
            // Retrieve page layout details 
            List<Metadata.Metadata> components = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, componentNameList);
            Metadata.Layout myLayout = (Metadata.Layout) components.get(0);
            Integer lscount = 0;
            Integer lsfieldcount = 0;
            
            System.debug('#### myLayout: '+myLayout);
            
            // We are going to find the fields names and will keep them according to columns so 
            // we can show them as per page layout 
            for (Metadata.LayoutSection ls : myLayout.layoutSections) {
                lscount++;
                
                if (ls.label != 'Custom Links') {
                    LayoutSection section = new LayoutSection( 'section'+String.valueOf(lscount), ls.label, ls.layoutColumns.size() );
                        
                    List<LayoutColumn> lstColumns = new List<LayoutColumn>();
                    Integer maxFieldsInColumn = 0;
                    for (Metadata.LayoutColumn lc : ls.layoutColumns) {
                        
                        LayoutColumn column = new LayoutColumn();
                        // check if there are fields available in that column
                        if (lc.layoutItems != null) { 
                            // Get the max number of fields in a column to preserve the alignment 
                            if (maxFieldsInColumn < lc.layoutItems.size()) {
                                maxFieldsInColumn = lc.layoutItems.size();
                            }
                            for (Metadata.LayoutItem li : lc.layoutItems) {
                                lsfieldcount++;

                                // Pass the LayoutItem object in the LayoutField consturctor	    
                                column.lstFields.add( new LayoutField( 'field'+String.valueOf(lsfieldcount), li, fields ) );
                            }
                        }
                        // No need to add a column in the section if there is no field available 
                        if (column.lstFields.size() > 0) {
                            lstColumns.add( column );
                        }
                    }
                    
                    // Now, we need to arrange the fields in section so we can use them in the iteration 
                    // on the component so we will have to arrange them in the order 
                    if (maxFieldsInColumn > 0) {
                        for (Integer i = 0; i < maxFieldsInColumn; i++) {
                            for (Integer j = 0; j < lstColumns.size(); j++){
                                if (lstColumns[j].lstFields.size() > i) {
                                    section.lstFields.add( lstColumns[j].lstFields[i] );    
                                }    
                                else {
                                    section.lstFields.add( new LayoutField() );
                                }
                            }    
                        }    
                    }
                    
                    lstSections.add( section );
                }
            }
        }
        catch( Exception e ){
            System.assert(false, e.getLineNumber() + ' : ' + e.getMessage() );
        }
        return lstSections;
    }
}