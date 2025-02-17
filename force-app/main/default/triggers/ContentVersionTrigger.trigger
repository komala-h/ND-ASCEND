/*
---------------------------------------------------------------------------------------------------------
11/3/2020 (James Seto)
Trigger for handling profile picture data load, use batch size of 1 on data loader.
---------------------------------------------------------------------------------------------------------
*/
trigger ContentVersionTrigger on ContentVersion (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    //need to put in after insert trigger state
    if(trigger.isAfter){
        if(trigger.isInsert){
            //list for contentdocumentLink
            List<ContentDocumentLink> listCDLInsert = new List<ContentDocumentLink>();
            Map<Id, Contact> contactUpdateMap = new Map<Id, Contact>();
            Map<Id, Account> accountUpdateMap = new Map<Id, Account>();
            
            //loop trigger to build mapDocIdbyContId
            for(ContentVersion conver : trigger.new){
                if(conver.isProfilePhoto__c == true){
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.ContentDocumentId = conver.ContentDocumentId;
                    cdl.ShareType = 'V';
                    cdl.Visibility = 'AllUsers'; // 'InternalUsers'; //Changed to 'AllUsers' because Community Users are currently not enabled for ISUF
                    
                    if(conver.Constituent__c != NULL){
                        cdl.LinkedEntityId = conver.Constituent__c;
                        if(contactUpdateMap.containsKey(conver.Constituent__c) == false) {
                            Contact c = new Contact();
                            c.Id = conver.Constituent__c;
                            c.ucinn_ascendv2__Picture_Record_ID__c = conver.Id;
                            contactUpdateMap.put(c.Id, c);
                        }
                    }
                    
                    else if(conver.Organization__c != NULL){
                        cdl.LinkedEntityId = conver.Organization__c;
                        if(accountUpdateMap.containsKey(conver.Organization__c) == false){
                            Account a = new Account();
                            a.Id = conver.Organization__c;
                            a.ucinn_ascendv2__Picture_Record_ID__c = conver.Id;
                            accountUpdateMap.put(a.Id, a);
                        }
                    }

                    listCDLInsert.add(cdl);
                }
            }

            insert listCDLInsert;
            update contactUpdateMap.values();
            update accountUpdateMap.values();
        }
        //Salesforce limitation: Cannot delete Content Version records(?)
        //Must use data loader extract "ContentDocument" records and then delete
    }
}