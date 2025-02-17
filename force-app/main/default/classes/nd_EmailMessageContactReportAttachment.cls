public class nd_EmailMessageContactReportAttachment implements Queueable {
    
 	public String emailMessageId;
    public String contactReportId;

   public nd_EmailMessageContactReportAttachment(String emailMessageId1, String contactReportId1) {
        emailMessageId = emailMessageId1;
        contactReportId = contactReportId1;
    }
    
	 @InvocableMethod(label='Re-parent attachments')
    
    public static void migrateAttachments(List<List<String>> objectIds){
        String localEmailMessageId  = objectIds[0][0];
        system.debug('@@ EmailMessageId  '+localEmailMessageId );
        String localcontactReportId;
        //Checks if a contactReportId has been passed to the apex invocable method
        if(objectIds[0].size() > 1){            
        	localcontactReportId = objectIds[0][1];
        system.debug('@@ contactReportId '+ objectIds[0][1]); 
           System.enqueueJob(new nd_EmailMessageContactReportAttachment(localEmailMessageId ,localcontactReportId),5);
        }
    }
     public void execute(QueueableContext context) {
        migrateAttachmentsFuture(emailMessageId, contactReportId);
    }
      public static void migrateAttachmentsFuture(String emailMessageId1, String contactReportId1) {
        String emailMessageId = emailMessageId1;
        System.debug('@@ emailMessageIdFuture ' + emailMessageId);

        // Checks if a contactReportId has been passed to the Apex invocable method
        if (String.isNotBlank(contactReportId1)) {
            String contactReportId = contactReportId1;

            // Query ContentDocument IDs linked to the EmailMessage           
            List<ContentDocumentLink> existingLinks = [SELECT ContentDocumentId,ShareType, Visibility FROM ContentDocumentLink WHERE LinkedEntityId = :emailMessageId];
            List<ContentDocumentLink> newLinks = new List<ContentDocumentLink>();

            for (ContentDocumentLink link : existingLinks) {
                // Create new ContentDocumentLink records for the ContactReport
                ContentDocumentLink newLink = new ContentDocumentLink(
                    ContentDocumentId = link.ContentDocumentId,
                    LinkedEntityId = contactReportId,
                    ShareType = link.ShareType,
                    Visibility = link.Visibility
                );
                newLinks.add(newLink);
                //System.debug(' Inserted new ContentDocumentLink records: ' + newLinks);
            }

            if (newLinks.size() > 0) {
             try { 
                insert newLinks;
                System.debug(' Inserted new ContentDocumentLink records: ' + newLinks);
               } catch (DmlException e) {
                 System.debug('Error occurred while inserting ContentDocumentLink records: ' + e.getMessage());
               }
            }
        }
    }
}