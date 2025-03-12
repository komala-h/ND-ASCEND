/*
 * Description: This class is to batch upload Stewardship Assets
 * This Class is called from LWC Component 'massUploadStewardshipAssets'
 * This class parses the data in csv to create Stewardship Asset records and passes them to batch class ND_massUploadStewardshipAssetsBatch
 * Author: Komala H @Cube84 
 *  
 * 
 */

public class ND_massUploadStewardshipAssets {
	@AuraEnabled
    public static boolean saveFile(String base64Data, String recordtypeChosen){
        String recortypeName = recordtypeChosen;
        Boolean isBatchJobSubmitted=false;
        try{
            // To deserialize the JSON string to String
            String data = JSON.deserializeUntyped(base64Data).toString();
            
            list<Asset> assetsToInsert = new list<Asset>();
            list<String> lstCSVLines = data.split('\n');
                       
            Id AssetRecordtypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(recordtypeChosen).getRecordTypeId();
             
            for(Integer i = 1; i < lstCSVLines.size(); i++){
                Asset asset = new Asset();
                String csvLine = lstCSVLines[i];
                List<String> csvRowData = new List<String>();
                for(String column : csvLine.split(',')){
                 //   column = column.replaceAll(':quotes:', '').replaceAll(':comma:', ',');
                    csvRowData.add(column);
                }
                
                // Create the asset record
                if(recortypeName=='Giving_Society_Acknowledgements'){
                    asset.recordTypeId = AssetRecordtypeId;
                    asset.name = csvRowData[0];
                    asset.ContactId = (csvRowData[1] != '') ? csvRowData[1] : null;
                    asset.Product2Id = (csvRowData[2] != '') ? csvRowData[2] : null;
                    asset.nd_Giving_Society__c = (csvRowData[3] != '') ? csvRowData[3] : null;
                    String pdate = csvRowData[4];
                    if(String.isNotBlank(pdate)){
                        asset.PurchaseDate = Date.valueOf(csvRowData[4]);
                    }
                    else{
                        asset.PurchaseDate = null;
                    }
                    
                }
                else if(recortypeName=='Stewardship_Item'){
                    asset.recordTypeId = AssetRecordtypeId;
                    asset.name = csvRowData[0];
                    asset.Product2Id = csvRowData[1];
                    asset.status = csvRowData[2];
                    asset.ContactId = (csvRowData[3] != '') ? csvRowData[3] : null; 
                    asset.AccountId = (csvRowData[4] != '') ? csvRowData[4] : null;   
                    asset.ucinn_ascendv2__Opportunity__c = (csvRowData[5] != '') ? csvRowData[5] : null;
                    asset.ND_Case__c = (csvRowData[6] != '') ? csvRowData[6] : null;
                    asset.nd_Stewardship_Assignment__c = (csvRowData[7] != '') ? csvRowData[7] : null;
                    String d = csvRowData[8];
                    if(String.isNotBlank(d)){
                        asset.nd_Date__c = Date.valueOf(csvRowData[8]);
                    }
                    else{
                        asset.nd_Date__c = null;
                    }
                    
                }
                else if(recortypeName=='Membership_Benefit'){
                    asset.recordTypeId = AssetRecordtypeId;
                    asset.name = csvRowData[0];
					asset.ContactId = (csvRowData[1] != '') ? csvRowData[1] : null;
                    asset.Product2Id = (csvRowData[2] != '') ? csvRowData[2] : null;
                    asset.nd_Giving_Society__c = (csvRowData[3] != '') ? csvRowData[3] : null;
                     
                    String purchasedate = csvRowData[4];
                    if(String.isNotBlank(purchasedate)){
                        asset.PurchaseDate = Date.valueOf(csvRowData[4]);
                    }
                    else{
                        asset.PurchaseDate = null;
                    }
                    
                    String qty = csvRowData[5];
                    if(String.isNotBlank(qty)){
                        asset.Quantity = Decimal.valueOf(csvRowData[5]);
                    }
                    else{
                        asset.Quantity = null;
                    }
              		
                    String p = csvRowData[6];
                    if(String.isNotBlank(p)){
                        asset.Price = Decimal.valueOf(csvRowData[6]);
                    }
                    else{
                        asset.Price = null;
                    }
                                                       
                    asset.AccountId = (csvRowData[7] != '') ? csvRowData[7] : null;
                    asset.status = (csvRowData[8] != '') ? csvRowData[8] : null;
                }
                    
                assetsToInsert.add(asset);
            }
  
            // Pass the records to be inserted to the batch job
            ND_massUploadStewardshipAssetsBatch b = new ND_massUploadStewardshipAssetsBatch(assetsToInsert);
            Database.executebatch(b,200);
            
            isBatchJobSubmitted = true;
            return isBatchJobSubmitted;
        }
        catch(Exception e) {
 	        system.debug('Exception occurred is' +e.getMessage());
            isBatchJobSubmitted = false;
            return isBatchJobSubmitted;
        }
    }
}