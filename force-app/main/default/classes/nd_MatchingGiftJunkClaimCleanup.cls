/* Description: This batch class is to delete the Matching Gifts which are neither Funder nor Adjusted
 * Author: Komala H
 */


public class nd_MatchingGiftJunkClaimCleanup implements Database.Batchable<Sobject>, Schedulable {
    public static String ADMIN_USERNAME = 'ascendadmin@nd.edu';

    public Database.QueryLocator start(Database.BatchableContext BC) {
        try {
            // Exclude ascend admin username when Opportunity Handler trigger handler record runs
            updateTriggerHandlerRecord(ADMIN_USERNAME);

            // Query all the matching gift origination records modified today which have payment records and Gifts associated to it
            if (Test.isRunningTest()) {
                return Database.getQueryLocator([SELECT Id, ucinn_ascendv2__Payment__c, ucinn_ascendv2__Opportunity__c,
                                                   ucinn_ascendv2__Opportunity__r.StageName, ucinn_ascendv2__Opportunity__r.ucinn_ascendv2__Session__c,
                                                   ucinn_ascendv2__Opportunity__r.ucinn_ascendv2__Disbursement__c
                                                 FROM ucinn_ascendv2__Matching_Gift_Origination__c
                                                 WHERE ucinn_ascendv2__Opportunity__c != null
                                                 LIMIT 2]);
            } 
            else {
                return Database.getQueryLocator([SELECT Id, ucinn_ascendv2__Payment__c, ucinn_ascendv2__Opportunity__c,
                                                   ucinn_ascendv2__Opportunity__r.StageName, ucinn_ascendv2__Opportunity__r.ucinn_ascendv2__Session__c,
                                                   ucinn_ascendv2__Opportunity__r.ucinn_ascendv2__Disbursement__c
                                                 FROM ucinn_ascendv2__Matching_Gift_Origination__c
                                                 WHERE ucinn_ascendv2__Payment__c != null
                                                 AND ucinn_ascendv2__Opportunity__c != null
                                                 AND ND_Payment_Transaction_Type__c = 'Matching Gift Payment'
                                                 AND LastModifiedDate = TODAY]);
            }
        } 
        catch (Exception ex) {
            System.debug('Error in start method: ' + ex.getMessage());
            return null;
        }
    }

    public void execute(Database.BatchableContext BC, List<ucinn_ascendv2__Matching_Gift_Origination__c> matchingGiftOriginationList) {
        Set<Id> OpportunityIds = new Set<Id>();
        List<Opportunity> matchingGiftsToDelete = new List<Opportunity>();
        String errorMsg = '';
        List<Database.DeleteResult> deleteResults;

        try {
            // Loop over the Matching Gift Origination records
            for (ucinn_ascendv2__Matching_Gift_Origination__c mgo : matchingGiftOriginationList) {
                if (mgo.ucinn_ascendv2__Opportunity__r.StageName != 'Funded' 
                    && mgo.ucinn_ascendv2__Opportunity__r.StageName != 'Adjusted'
                    && mgo.ucinn_ascendv2__Opportunity__r.ucinn_ascendv2__Session__c != null
                    && mgo.ucinn_ascendv2__Opportunity__r.ucinn_ascendv2__Disbursement__c == null) {
                    OpportunityIds.add(mgo.ucinn_ascendv2__Opportunity__c);
                }
            }

            if (!OpportunityIds.isEmpty()) {
                // Get the Matching Gift records to delete
                matchingGiftsToDelete = [SELECT Id FROM Opportunity WHERE Id IN :OpportunityIds];

                if (!matchingGiftsToDelete.isEmpty()) {
                    deleteResults = Database.delete(matchingGiftsToDelete, false);

                    for (Database.DeleteResult dr : deleteResults) {
                        if (!dr.isSuccess()) {
                            for (Database.Error err : dr.getErrors()) {
                                String failedDML = err.getMessage();
                                errorMsg = errorMsg + '\n' + failedDML;
                            }
                        }
                    }
                }
            }

            // Send an email if there are errors or if running tests
            if (String.isNotBlank(errorMsg) || Test.isRunningTest()) {
                sendEmail(errorMsg);
            }

        } catch (Exception ex) {
            System.debug('Exception caught in execute method: ' + ex.getMessage());
        }
    }

    public void execute(SchedulableContext SC) {
        nd_MatchingGiftJunkClaimCleanup i = new nd_MatchingGiftJunkClaimCleanup();
        Database.executeBatch(i, 2);
    }

    public void finish(Database.BatchableContext BC) {
        // Clear the exclude username to run
        updateTriggerHandlerRecord(null);
    }

    @TestVisible private void sendEmail(String msg) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>{'entcrm@nd.edu'};
        mail.setToAddresses(sendTo);
        mail.setReplyTo('no_reply@nd.edu');
        mail.setSenderDisplayName('Scheduled Apex');
        mail.setSubject('ERROR: Matching Gift Junk Claim Cleanup Batch job');
        String body = msg;
        mail.setHtmlBody(body);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }

    @TestVisible private void updateTriggerHandlerRecord(String value) {
        List<ucinn_ascendv2__Trigger_Handler__c> recordToUpdate = [ SELECT Id, Name, ucinn_ascendv2__Usernames_to_Exclude__c  
                                                                    FROM ucinn_ascendv2__Trigger_Handler__c
            														WHERE Name = 'Opportunity Handler'];

        if (!recordToUpdate.isEmpty()) {
            for (ucinn_ascendv2__Trigger_Handler__c trigHandler : recordToUpdate) {
                trigHandler.ucinn_ascendv2__Usernames_to_Exclude__c = value;
            }
            update recordToUpdate;
        }
    }
}