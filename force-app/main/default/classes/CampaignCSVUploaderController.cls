public  class CampaignCSVUploaderController {

    
        @AuraEnabled
        public static void saveFile(String base64Data) {
            //Blob binaryData = EncodingUtil.base64Decode(data);
            //String Blobstring = binaryData.tostring();
            try{
            String data   = JSON.deserializeUntyped(base64Data).toString();   
            list<Campaign> lstCCToInsert = new list<Campaign>();   
            list<String> lstCSVLines = data.split('\n');
        	system.debug('@@'+lstCSVLines[0]);
            for(Integer i = 1; i < lstCSVLines.size(); i++){    
                Campaign cmp = new Campaign();    
                String csvLine = lstCSVLines[i];                   
                system.debug('@@'+csvLine); 
               
                List<String> csvRowData = new List<String>();
       
                for(String column : csvLine.split(',')){    
                    //column = column.replaceAll(':quotes:', '').replaceAll(':comma:', ',');   
                    csvRowData.add(column);   
                }
                Id recordTypeId =Schema.SObjectType.campaign.getRecordTypeInfosByDeveloperName().get('Appeal').getRecordTypeId();
                system.debug('csvRowData'+csvRowData);
                if(csvRowData.size()==10&& string.isnotblank(csvRowData[9]))
                cmp.Id= csvRowData[9].trim();
				cmp.nd_Job_Number__c = csvRowData[0];
                cmp.ND_Channel__c = csvRowData[1];
                cmp.Name = csvRowData[2];
                cmp.Type = csvRowData[3];
                cmp.ParentId = string.isNotBlank(csvRowData[4])?csvRowData[4]:null;
                cmp.nd_Default_Designation__c = string.isNotBlank(csvRowData[5])?csvRowData[5]:null;
                cmp.StartDate = string.isNotBlank(csvRowData[6])?Date.valueof(csvRowData[6]):null;
                cmp.EndDate = string.isNotBlank(csvRowData[7])?Date.valueof(csvRowData[7]):null;
                cmp.Status = csvRowData[8];
                cmp.RecordTypeId =recordTypeId;
        
                lstCCToInsert.add(cmp);
            }
            database.ExecuteBatch(new ND_CampaignCSVUploaderBatch(lstCCToInsert)); 
            //insert lstCCToInsert; 
            }Catch(Exception ex){
                system.debug(ex.getStackTraceString());
                throw new AuraHandledException(ex.getMessage());
            }                   
        }     

}