/**
 * @author UC Innovation
 * @date 2/2/2023
 * @group Trigger Handlers
 * @description Handler class for Session Trigger
 */
global class asc_TRIG_SessionHandler extends ucinn_ascendv2.ascend_TDTM_Runnable {
    private ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper = new ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper();

    /*******************************************************************************************************
     * @description Overridden method that handles the trigger actions and calls the relevant logic
     * @return The dmlWrapper with any sObjects to be inserted/updated/deleted
     */
    global override ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, ucinn_ascendv2.ascend_TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        List<ucinn_ascendv2__Session__c> triggerNew = (List<ucinn_ascendv2__Session__c>) newList;
        List<ucinn_ascendv2__Session__c> triggerOld = (List<ucinn_ascendv2__Session__c>) oldList;

        Map<Id, ucinn_ascendv2__Session__c> triggerOldMap = new Map<Id, ucinn_ascendv2__Session__c>();
        if (triggerOld != null) {
            for (ucinn_ascendv2__Session__c eachSession : triggerOld) {
                triggerOldMap.put(eachSession.Id, eachSession);
            }
        }

        if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeInsert) {

        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterInsert) {

        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeUpdate) {

        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterUpdate) {
            // system.debug('!!!inside after update on session');
            getApprovedSessionIdsForActionCenterNotifications(triggerNew, triggerOld, triggerOldMap);

        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeDelete) {
        
        } else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterDelete) {
      
        } 

        return dmlWrapper;
    }

    private void getApprovedSessionIdsForActionCenterNotifications(List<ucinn_ascendv2__Session__c> triggerNew, List<ucinn_ascendv2__Session__c> triggerOld, Map<Id, ucinn_ascendv2__Session__c> triggerOldMap) { 
        Set<Id> approvedSessionIds = new Set<Id>();

        for (ucinn_ascendv2__Session__c session : triggerNew) {
            if (session.ucinn_ascendv2__Session_Totals_Approved__c != null && triggerOldMap.get(session.Id).ucinn_ascendv2__Session_Totals_Approved__c == null) {
                approvedSessionIds.add(session.Id);
            }
        }

        if (approvedSessionIds.size() > 0) {
            // system.debug('!!! approvedSessionIds ' + approvedSessionIds);
            makeActionCenterNotifications(approvedSessionIds);
        }
    }
    
    private void makeActionCenterNotifications(Set<Id> approvedSessionIds) {
        Id pledgeRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Pledge').getRecordTypeId();

        // // Only making action center notifications from Constituents, not Accounts
        // List<ucinn_ascendv2__Session__c> approvedSessionsWithDetails = [SELECT Id, 
        
        //                                                                     //subquery of fulfilled non-adjusted pledge.    
        //                                                                     (SELECT Id, Name, RecordTypeId, AccountId, ucinn_ascendv2__Contact__c, ucinn_ascendv2__Contact__r.nd_Name_and_ID__c, ucinn_ascendv2__Contact__r.AccountId 
        //                                                                     FROM ucinn_ascendv2__Opportunities_Session__r 
        //                                                                     WHERE (ucinn_ascendv2__Contact__c != null AND ucinn_ascendv2__Contact__r.AccountId != null AND ucinn_ascendv2__Contact__r.nd_Name_and_ID__c!= null AND RecordTypeId =: pledgeRecordTypeId 
        //                                                                     AND StageName = 'Paid' AND ucinn_ascendv2__Adjusted_Gift__c = null)) //added by qluong on 2/28/23
                                                                        
        //                                                                 FROM ucinn_ascendv2__Session__c WHERE (Id IN :approvedSessionIds)];
        
        // Only making action center notifications from Constituents, not Accounts
        List<ucinn_ascendv2__Session__c> approvedSessionsWithDetails = [SELECT Id, 
        
                                                                            //subquery of fulfilled non-adjusted pledge.    
                                                                            (SELECT Id, Name, ucinn_ascendv2__Account__c, ucinn_ascendv2__Contact__c, ucinn_ascendv2__Contact__r.nd_Name_and_ID__c, ucinn_ascendv2__Contact__r.AccountId, ucinn_ascendv2__Contact__r.ucinn_ascendv2__Full_Name_Formula__c, ucinn_ascendv2__Opportunity__r.Name, ucinn_ascendv2__Opportunity__r.ucinn_ascendv2__Amount_Paid_to_Date_Roll_Up__c 
                                                                            FROM ucinn_ascendv2__Payments_Session__r 
                                                                            WHERE (ucinn_ascendv2__Contact__c != null AND ucinn_ascendv2__Contact__r.AccountId != null AND ucinn_ascendv2__Contact__r.nd_Name_and_ID__c != null 
                                                                            AND ucinn_ascendv2__Status__c = 'Paid' AND ucinn_ascendv2__Transaction_Type__c = 'Pledge Payment' AND ucinn_ascendv2__Adjusted_Gift__c = null AND ucinn_ascendv2__Adjusted_Payment__c = null))
                                                                        
                                                                        FROM ucinn_ascendv2__Session__c WHERE (Id IN :approvedSessionIds)];

        // system.debug('!!! approvedSessionsWithDetails ' + approvedSessionsWithDetails);

        List<ucinn_ascendv2__Payment__c> fulfilledPayments = new List<ucinn_ascendv2__Payment__c>();
        Set<Id> householdIds = new Set<Id>();
        for (ucinn_ascendv2__Session__c approvedSessionWithDetails : approvedSessionsWithDetails) {
            // system.debug('!!! approvedSessionWithDetails.ucinn_ascendv2__Payments_Session__r ' + approvedSessionWithDetails.ucinn_ascendv2__Payments_Session__r);
            
            //question what happens if there are no paid non-adjusted pledge?
            
            for (ucinn_ascendv2__Payment__c payment  : approvedSessionWithDetails.ucinn_ascendv2__Payments_Session__r) {
                householdIds.add(payment.ucinn_ascendv2__Contact__r.AccountId);
                fulfilledPayments.add(payment);
            }
        }
        // system.debug('!!! householdIds ' + householdIds);

        Map<Id, Account> mapHouseholdIdToHousehold = new Map<Id, Account>([SELECT Id, ucinn_ascendv2__PRM__c, ucinn_ascendv2__PRM__r.Development_Coordinator__c
                                                                    FROM Account
                                                                    WHERE (Id IN: householdIds)]);
        
        // system.debug('!!! mapHouseholdIdToHousehold size ' + mapHouseholdIdToHousehold.size());
        
        List<ucinn_ascendv2__Action_Center_Staging__c> actionCenterNotifications = new List<ucinn_ascendv2__Action_Center_Staging__c>();                                     
        for (ucinn_ascendv2__Payment__c fulfilledPayment : fulfilledPayments) {
            // If AccountId is not populated, try going off of Contact__r.AccountId
            Id householdId = fulfilledPayment.ucinn_ascendv2__Account__c;
            if (householdId == null) {
                householdId = fulfilledPayment.ucinn_ascendv2__Contact__r.AccountId;
            }
            Account household = mapHouseholdIdToHousehold.get(householdId);
            
            // system.debug('!!! household ' + household);
                        
            Id prm = household.ucinn_ascendv2__PRM__c;
            
            if (prm != null) {
                //do step 1 if contains an active PRM
                
                // Format to add commas to separate thousands
                String amountFormattedByCurrency = '$' + fulfilledPayment.ucinn_ascendv2__Opportunity__r.ucinn_ascendv2__Amount_Paid_to_Date_Roll_Up__c.format();
                // Formatting strips the decimal amount if it is zero, manually add it in
                if (!amountFormattedByCurrency.contains('.')) {
                    amountFormattedByCurrency = amountFormattedByCurrency + '.00';
                }
                // Turns single digit decimals like 0.2 into 0.20
                else if (amountFormattedByCurrency.substringAfterLast('.').length() == 1) {
                    amountFormattedByCurrency = amountFormattedByCurrency + '0';
                }

                string name = 'Pledge ' + fulfilledPayment.ucinn_ascendv2__Opportunity__r.Name + ' fulfilled by ' + fulfilledPayment.ucinn_ascendv2__Contact__r.ucinn_ascendv2__Full_Name_Formula__c;
                // string message = fulfilledPayment.ucinn_ascendv2__Contact__r.nd_Name_and_ID__c +' fulfilled pledge ' + fulfilledPayment.ucinn_ascendv2__Opportunity__r.Name + ' in the amount of ' + amountFormattedByCurrency + ' on ' + date.today().format();
                string message = '#DisplayName# fulfilled pledge ' + fulfilledPayment.ucinn_ascendv2__Opportunity__r.Name + ' in the amount of ' + amountFormattedByCurrency + ' on ' + date.today().format();

                ucinn_ascendv2__Action_Center_Staging__c activePRMStaging = new ucinn_ascendv2__Action_Center_Staging__c();
                activePRMStaging.Name = name.left(80);
                activePRMStaging.ucinn_ascendv2__Contact__c = fulfilledPayment.ucinn_ascendv2__Contact__c;
                activePRMStaging.ucinn_ascendv2__Display_Date__c = date.today();
                activePRMStaging.ucinn_ascendv2__Display_Name__c = fulfilledPayment.ucinn_ascendv2__Contact__r.nd_Name_and_ID__c;
                activePRMStaging.ucinn_ascendv2__Display_Now__c = true;
                activePRMStaging.ucinn_ascendv2__Expiration_Date__c = date.today() + 7;
                activePRMStaging.ucinn_ascendv2__Fundraiser__c = household.ucinn_ascendv2__PRM__c;
                activePRMStaging.ucinn_ascendv2__Message__c = message;
                activePRMStaging.ucinn_ascendv2__Panel__c = 'DidYouKnow';

                actionCenterNotifications.add(activePRMStaging);

                Id developmentCoordinator = household.ucinn_ascendv2__PRM__r.Development_Coordinator__c;

                if (developmentCoordinator != null) {
                    //do step 2 if the active PRM contains a development coordinator

                    ucinn_ascendv2__Action_Center_Staging__c devCoordStaging = new ucinn_ascendv2__Action_Center_Staging__c();
                    devCoordStaging.Name = name;
                    devCoordStaging.ucinn_ascendv2__Display_Date__c = date.today();
                    devCoordStaging.ucinn_ascendv2__Display_Name__c = fulfilledPayment.ucinn_ascendv2__Contact__r.nd_Name_and_ID__c;
                    devCoordStaging.ucinn_ascendv2__Display_Now__c = true;
                    devCoordStaging.ucinn_ascendv2__Expiration_Date__c = date.today() + 7;
                    devCoordStaging.ucinn_ascendv2__Fundraiser__c = developmentCoordinator;
                    devCoordStaging.ucinn_ascendv2__Message__c = message;
                    devCoordStaging.ucinn_ascendv2__Panel__c = 'DidYouKnow';

                    actionCenterNotifications.add(devCoordStaging);

                }
            }
        }
        // for (ucinn_ascendv2__Action_Center_Staging__c actionCenterNotification : actionCenterNotifications) {
        //     system.debug('!!! actionCenterNotification ' + actionCenterNotification);
        // }
        insert actionCenterNotifications;


    }

}