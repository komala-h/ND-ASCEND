/*
 * Description: This batch class is to assign short description and resolution description fields on a proposal opportunity based on criteria 
 * Author: Komala H
 *  
 * 
 */

public class ND_IdentifyProposalRemindersBatch implements Database.Batchable<Sobject>,Schedulable{
    static map<String,Proposal_Reminder__mdt> propReminderMap = new map<String,Proposal_Reminder__mdt>();
    static list<Proposal_Reminder__mdt> propReminderList = [select masterLabel,DeveloperName, Short_Description__c ,Resolution_Description__c from Proposal_Reminder__mdt];
      
    public Database.QueryLocator start(Database.BatchableContext BC){
        try{
           String query = 'SELECT Id,nd_Aging_Status_Code_Value__c,nd_Aging_Status_Code__c,AccountId,nd_Answer_Date__c,CloseDate,Account.recordtype.developerName,Account.nd_LastCRDate__c,StageName, nd_Short_Description__c, ND_Resolution_Description__c,nd_LeadPP__c, nd_activePRM__c, nd_daysInPlanning__c, nd_daysInPending__c, nd_daysInApproved__c, RecordType.developerName,ucinn_ascendv2__Submitted_Date__c FROM Opportunity where recordtype.developerName =\'Proposal\' AND StageName in (\'Planning\',\'Pending\',\'Approved\') AND Account.recordtype.developerName in (\'Household\',\'Corporations_and_Organizations\') ';
	  //   for unit testing	     
      //   String query = 'SELECT Id,nd_Aging_Status_Code_Value__c,nd_Aging_Status_Code__c,AccountId,nd_Answer_Date__c,CloseDate,Account.recordtype.developerName,Account.nd_LastCRDate__c,StageName, nd_Short_Description__c, ND_Resolution_Description__c,nd_LeadPP__c, nd_activePRM__c, nd_daysInPlanning__c, nd_daysInPending__c, nd_daysInApproved__c, RecordType.developerName,ucinn_ascendv2__Submitted_Date__c FROM Opportunity where Id in (\'0067j00000CK6nxAAD\',\'006U80000081ZOvIAM\') ';
           return Database.getQueryLocator(query);
        }
        Catch(Exception e){
            return null;
        }
    }    
    
    public void execute(Database.BatchableContext BC, list<Opportunity> oppList){
        Proposal_Reminder__mdt propReminder;
        Boolean isAskDateGreaterThanToday;
        Integer NoOfDays_AskDate_Today;
        Integer NoOfDays_Today_Askdate;
        Integer NoOfDays_Today_LastContactReportCreatedDate;
        Integer NoOfDays_ExpectedCloseDate_Today;
        Integer NoOfDays_Today_ExpectedCloseDate;
        Boolean isExpectedCloseDateGreaterThanToday;
        Boolean HasContactReportCreatedByPRM;
        String agingStatusCodeFormulaValue;
        String agingStatusCodeValue;
        
        list<Proposal_Reminder__mdt> proposalReminderList ;
        for(Proposal_Reminder__mdt p:propReminderList){
    		propReminderMap.put(p.DeveloperName,p);
		}
        
        try{
            for(Opportunity opp:oppList ){
                agingStatusCodeFormulaValue = '';
                agingStatusCodeValue = '';
                if(opp.nd_Aging_Status_Code__c !='' || opp.nd_Aging_Status_Code__c !=null){
                    agingStatusCodeFormulaValue = opp.nd_Aging_Status_Code__c;
                	agingStatusCodeValue = agingStatusCodeFormulaValue.substring(32, 32 + 1);
                	opp.nd_Aging_Status_Code_Value__c = agingStatusCodeValue;
                }
                
            }
            
       		for(Opportunity opp:oppList ){
                proposalReminderList = new list<Proposal_Reminder__mdt>();
                // to check whether Askdate is greater than today or not
				if(opp.ucinn_ascendv2__Submitted_Date__c !=null){
					if(opp.ucinn_ascendv2__Submitted_Date__c > Date.Today()){
						isAskDateGreaterThanToday = True;
					}
					else{
						isAskDateGreaterThanToday = false;
					}
				}
                          
                if(opp.ucinn_ascendv2__Submitted_Date__c!=null){
                    // to find numbers of days between Askdate and Today
                    NoOfDays_AskDate_Today = Date.Today().daysBetween(opp.ucinn_ascendv2__Submitted_Date__c);
                    // to find numbers of days between Today and AskDate
                    NoOfDays_Today_Askdate = opp.ucinn_ascendv2__Submitted_Date__c.daysBetween(Date.Today());
                }
                
                if(opp.Account.nd_LastCRDate__c !=null){
                    // to find number of days between Today and lastContactReportCreatedDate
                    NoOfDays_Today_LastContactReportCreatedDate = opp.Account.nd_LastCRDate__c.daysBetween(Date.Today());
                    HasContactReportCreatedByPRM = true;
                }
                else{
                    HasContactReportCreatedByPRM = false;
                }
      			
                if(opp.CloseDate != null){
                    // to find number of days between CloseDate and Today
                    NoOfDays_ExpectedCloseDate_Today = Date.Today().daysBetween(opp.CloseDate);
                    // to find number of days between Today and CloseDate
                    NoOfDays_Today_ExpectedCloseDate = opp.CloseDate.daysBetween(Date.Today());
                }
                
                if(opp.CloseDate !=null){
                    if(opp.CloseDate> Date.Today()){
                    	isExpectedCloseDateGreaterThanToday = True;
                	}
                	else{
                    	isExpectedCloseDateGreaterThanToday = false;
                	}
                }
     
                if(opp.Account.recordtype.developerName =='Household'){
                    if(opp.StageName=='Planning'){
                        if(opp.nd_Aging_Status_Code_Value__c=='R'){
                            // Planning stage with ask date within 90 days, and no contact in last 90 days.
                            if(isAskDateGreaterThanToday && (NoOfDays_AskDate_Today<90) && ( HasContactReportCreatedByPRM==false || ((NoOfDays_Today_LastContactReportCreatedDate>90) && (NoOfDays_Today_LastContactReportCreatedDate<=180)))     ){
                                propReminder = propReminderMap.get('Planning_Askdate_in_90D_NoCR_in_90D');
                                proposalReminderList.add(propReminder);
                            }
                            // Planning stage with ask date over 7 days past due, or no ask date.
                            if(opp.ucinn_ascendv2__Submitted_Date__c == null){
                                propReminder = propReminderMap.get('Planning_AskDate_7D_pastDue_Or_NoAskDate');
                                proposalReminderList.add(propReminder);
                            }
                            // Planning stage with ask date over 7 days past due, or no ask date.
                            if((!isAskDateGreaterThanToday) && (NoOfDays_Today_Askdate>7)){
                                propReminder = propReminderMap.get('Planning_AskDate_7D_pastDue_Or_NoAskDate');
                                proposalReminderList.add(propReminder);
                            }
                            // Planning stage with no active proposal primary.                 
                            if(!opp.nd_activePRM__c){
                                propReminder = propReminderMap.get('Planning_with_no_active_PRM');
                                proposalReminderList.add(propReminder);
                            }
                            
                        }
                        else if(opp.nd_Aging_Status_Code_Value__c=='Y'){                      
                            // Planning stage with ask date within 30 days.
                            if(isAskDateGreaterThanToday && (NoOfDays_AskDate_Today < 30)){
                                propReminder = propReminderMap.get('Planning_With_AskDate_Within_30_Days');
                                proposalReminderList.add(propReminder);
                            }
                            // Planning stage with ask date within 180 days, and no contact in last 180 days.
                            if(isAskDateGreaterThanToday && (NoOfDays_AskDate_Today<180) && (  HasContactReportCreatedByPRM==false || (NoOfDays_Today_LastContactReportCreatedDate>180) )       ){
                                propReminder = propReminderMap.get('Planning_Askdate_in_180D_NoCR_180D');
                                proposalReminderList.add(propReminder);
                            }
                        }
                        else{
                            // Planning Stage
							propReminder = propReminderMap.get('Planning_stage');
                        	proposalReminderList.add(propReminder);
                        }
                        opp = updateFields(opp,proposalReminderList);
                        continue;
                    }
                    
                    if(opp.StageName=='Pending'){
                        if(opp.nd_Aging_Status_Code_Value__c=='R'){
                            // Pending stage with no active proposal primary
                            if(!opp.nd_activePRM__c){
                               	propReminder = propReminderMap.get('Pending_with_NoActivePRM');
                            	proposalReminderList.add(propReminder);
                        	}
                            //Pending stage for over 90 days, no contact in last 90 days
							if((opp.nd_daysInPending__c>90) &&  ( HasContactReportCreatedByPRM==false ||(NoOfDays_Today_LastContactReportCreatedDate >90))){
								propReminder = propReminderMap.get('Pending_for_over_90D_No_CR_in_90D');
                            	proposalReminderList.add(propReminder);
							}
                            // Pending stage with expected close date over 7 days past due, or no expected close date
							if(opp.CloseDate == null){
								propReminder = propReminderMap.get('Pending_with_ECDate_7Ddue_or_no_ECDate');
                            	proposalReminderList.add(propReminder);
							}
                            // Pending stage with expected close date over 7 days past due, or no expected close date
							if( (!isExpectedCloseDateGreaterThanToday) && (NoOfDays_Today_ExpectedCloseDate > 7)){
								propReminder = propReminderMap.get('Pending_with_ECDate_7Ddue_or_no_ECDate');
                            	proposalReminderList.add(propReminder);
							}
                        }
                        else if(opp.nd_Aging_Status_Code_Value__c=='Y'){ 
                            //Pending stage for over 60 days, no contact in last 60 days
							if((opp.nd_daysInPending__c>60) && (opp.nd_daysInPending__c<=90) && ( HasContactReportCreatedByPRM==false || ((NoOfDays_Today_LastContactReportCreatedDate > 60) && (NoOfDays_Today_LastContactReportCreatedDate<=90)))   ){
								propReminder = propReminderMap.get('Pending_for_over_60D_No_CR_in_60D');
                            	proposalReminderList.add(propReminder);
							}
                            // Pending stage with expected close date within 30 days
							if( (isExpectedCloseDateGreaterThanToday) && (NoOfDays_ExpectedCloseDate_Today < 30) ){
								propReminder = propReminderMap.get('Pending_with_ECloseDate_within_30D');
                            	proposalReminderList.add(propReminder);
							} 
                        }
                        else{
                            //Pending stage
                        	propReminder = propReminderMap.get('Pending_Stage');
                        	proposalReminderList.add(propReminder);
                        }
                        opp = updateFields(opp,proposalReminderList);
                        continue;
                   }
                    
                    if(opp.StageName=='Approved'){
                        if(opp.nd_activePRM__c){
                            if(opp.nd_Aging_Status_Code_Value__c=='R'){
                                // Approved stage for over 30 days
                            	if((opp.nd_daysInApproved__c >30)){
                                	propReminder = propReminderMap.get('Approved_for_over_30_days');
                    				proposalReminderList.add(propReminder);
                            	}
                            }
                            else if(opp.nd_Aging_Status_Code_Value__c=='Y'){
                                //Approved stage for over 20 days
                                if((opp.nd_daysInApproved__c >20) && (opp.nd_daysInApproved__c<=30)){
                                    propReminder = propReminderMap.get('Approved_for_over_20_days');
                                    proposalReminderList.add(propReminder);
                                }
                            }
                            else{
                                // Approved Stage
                            	propReminder = propReminderMap.get('Approved_Stage');
                       			proposalReminderList.add(propReminder);
                            }
                            
                            opp = updateFields(opp,proposalReminderList);
                        	continue;
                        }
                    }
                }
                
                if(opp.Account.recordtype.developerName =='Corporations_and_Organizations'){
                    
                    if(opp.StageName=='Planning'){
                        if(opp.nd_Aging_Status_Code_Value__c=='R'){
							// Planning stage with ask date within 90 days, and no contact in last 90 days
							if(isAskDateGreaterThanToday && (NoOfDays_AskDate_Today<90) && (HasContactReportCreatedByPRM==false || ((NoOfDays_Today_LastContactReportCreatedDate>90) && (NoOfDays_Today_LastContactReportCreatedDate<=180)) )  ){
								propReminder = propReminderMap.get('ORG_Planning_Askdate_in_90D_NoCR_in_90D');
								proposalReminderList.add(propReminder);
							}
							// Planning stage with ask date over 7 days past due, or no ask date
							if(opp.ucinn_ascendv2__Submitted_Date__c == null){
								propReminder = propReminderMap.get('ORG_Planning_AskDate_7DpastDue_noAskDate');
								proposalReminderList.add(propReminder);
							}
							// Planning stage with ask date over 7 days past due, or no ask date
							if((!isAskDateGreaterThanToday) && (NoOfDays_Today_Askdate>7)){
								propReminder = propReminderMap.get('ORG_Planning_AskDate_7DpastDue_noAskDate');
								proposalReminderList.add(propReminder);
							}
							// Planning stage with no active proposal primary
                            if(!opp.nd_LeadPP__c ){
								propReminder = propReminderMap.get('ORG_Planning_with_no_active_PRM');
								proposalReminderList.add(propReminder);
							}
						}
						else if(opp.nd_Aging_Status_Code_Value__c=='Y'){
							// Planning stage with ask date within 30 days
							if(isAskDateGreaterThanToday && (NoOfDays_AskDate_Today < 30)){
								propReminder = propReminderMap.get('ORG_Planning_With_AskDate_Within_30_Days');
								proposalReminderList.add(propReminder);
							}
							
							// Planning stage with ask date within 180 days, and no contact in last 180 days
							if(isAskDateGreaterThanToday && (NoOfDays_AskDate_Today<180) && ( HasContactReportCreatedByPRM==false || (NoOfDays_Today_LastContactReportCreatedDate>180)) ){
								propReminder = propReminderMap.get('ORG_Planning_Askdate_in_180D_NoCR_180D');
								proposalReminderList.add(propReminder);
							}
						}
						else{
							// Planning stage
							propReminder = propReminderMap.get('Planning_stage');
							proposalReminderList.add(propReminder);
						}
						opp = updateFields(opp,proposalReminderList);
                        continue;
                    }
                    if(opp.StageName=='Pending'){
						if(opp.nd_Aging_Status_Code_Value__c=='R'){
							// Pending stage with no active proposal primary
							if(!opp.nd_LeadPP__c ){
								propReminder = propReminderMap.get('ORG_Pending_with_NoActivePRM');
								proposalReminderList.add(propReminder);
							}
							// Pending stage for over 180 days, no contact in last 180 days
							if((opp.nd_daysInPending__c>180) && ( HasContactReportCreatedByPRM==false || (NoOfDays_Today_LastContactReportCreatedDate >180) ) ){
								propReminder = propReminderMap.get('ORG_Pending_for_over_180D_No_CR_in_180D');
								proposalReminderList.add(propReminder);
							}
							// Pending stage with expected Close date over 60 days past due, or no expected Close date
							if(opp.CloseDate == null){
								propReminder = propReminderMap.get('ORG_Pending_with_CDate_60D_due_or_noECD');
								proposalReminderList.add(propReminder);
							}
							// Pending stage with expected close date over 60 days past due, or no expected close date
							if((opp.nd_daysInPending__c <120) && (!isExpectedCloseDateGreaterThanToday) && (NoOfDays_Today_ExpectedCloseDate > 60)){
								propReminder = propReminderMap.get('ORG_Pending_with_CDate_60D_due_or_noECD');
								proposalReminderList.add(propReminder);
							}
						}
						else if(opp.nd_Aging_Status_Code_Value__c=='Y'){
							// Pending stage with expected close date within 30 days
							if((opp.nd_daysInPending__c <60) && (isExpectedCloseDateGreaterThanToday) && (NoOfDays_ExpectedCloseDate_Today < 30) ){
								propReminder = propReminderMap.get('ORG_Pending_with_ECloseDate_within_30D');
								proposalReminderList.add(propReminder);
							}
							// Pending stage for over 120 days, no contact in last 120 days
							if((opp.nd_daysInPending__c>120) && (opp.nd_daysInPending__c<=180) && ( HasContactReportCreatedByPRM==false || ((NoOfDays_Today_LastContactReportCreatedDate > 120) && (NoOfDays_Today_LastContactReportCreatedDate<=180))) ){
								propReminder = propReminderMap.get('ORG_Pending_for_over_120D_No_CR_in_120D');
								proposalReminderList.add(propReminder);
							}
						}
						else{
							//Pending stage
							propReminder = propReminderMap.get('Pending_Stage');
							proposalReminderList.add(propReminder);
						}
                        opp = updateFields(opp,proposalReminderList);
                        continue;
					}
                    
                    if(opp.StageName=='Approved'){
						if(opp.nd_LeadPP__c){
							if(opp.nd_Aging_Status_Code_Value__c=='R'){
								// Approved stage for over 1 year
								if((opp.nd_daysInApproved__c >365)){
									propReminder = propReminderMap.get('ORG_Approved_for_over_1_year');
									proposalReminderList.add(propReminder);
								}
							}
							else if(opp.nd_Aging_Status_Code_Value__c=='Y'){
								// Approved stage for over 270 days
								if((opp.nd_daysInApproved__c >270) && (opp.nd_daysInApproved__c<=365)){
									propReminder = propReminderMap.get('ORG_Approved_for_over_270_days');
									proposalReminderList.add(propReminder);
								}
							}
							else{
								// Approved stage
								propReminder = propReminderMap.get('Approved_Stage');
								proposalReminderList.add(propReminder);
							}
							opp = updateFields(opp,proposalReminderList);
							continue;
                        }
                    }
                }
            }
            
          // update oppList;
           Database.SaveResult[] SR =  Database.update(oppList,false);
        }
        catch(Exception ex){
            system.debug('Exception caught :'+ex);
        }
    }
    
    Opportunity updateFields(Opportunity o,list<Proposal_Reminder__mdt> plist){
        String shortDesc = '';
        String resolutionDesc='';
        for(Proposal_Reminder__mdt p: plist ){
            shortDesc = shortDesc +'\n'+ p.Short_Description__c+'\n';
            if(p.Resolution_Description__c!=null){
                resolutionDesc = resolutionDesc +'\n'+ p.Resolution_Description__c+'\n';
            }
        }
        o.nd_Short_Description__c = shortDesc;
        o.ND_Resolution_Description__c = resolutionDesc;
        return o;
    }

    
   public void execute(SchedulableContext SC){
        ND_IdentifyProposalRemindersBatch i = new ND_IdentifyProposalRemindersBatch(); 
      	database.executebatch(i,50);
    }
    public void finish(Database.BatchableContext BC)
    {
        try
        {
        	AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email
                              FROM AsyncApexJob 
                              WHERE Id =:bc.getJobId()];
        	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        	String[] toAddresses = new String[] {a.CreatedBy.Email};
        	mail.setToAddresses(toAddresses);
        	mail.setSubject('Proposal Identify reminders Batch job has been completed with status as  ' + a.Status);
        	mail.setPlainTextBody('The batch Apex job processed: ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures.');
        	
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {mail};
        	Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        	if(!results[0].success) {
            	System.debug('The email failed to send: ' + results[0].errors[0].message);
        	} 
        }
        catch(Exception ex){
			system.debug('Exception caught:'+ex);
        }
    }
}