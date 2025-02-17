global class NdOpportunityHandler extends ucinn_ascendv2.ascend_TDTM_Runnable{

   /* 
     * Household who has a planned gift on their giving record, as defined by: pledge or gift ( transaction type that starts with a T\ *or Q* )
     * In some cases this calculation includes those people with a Gift in Kind transaction with an appeal of "Planned Giving" 
     * Created a trigger to update the PlannedGiftDonor based on the overall existing donations on update and delete using queueable apex   
   */
    private ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper = new ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper();
   
    
     global override ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, ucinn_ascendv2.ascend_TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        List<Opportunity> triggerNew = (List<Opportunity>) newList;
        List<Opportunity> triggerOld = (List<Opportunity>) oldList;

        Map<Id, Opportunity> triggerOldMap = new Map<Id, Opportunity>();
        if (triggerOld != null) {
            for (Opportunity hsc : triggerOld) {
                triggerOldMap.put(hsc.Id, hsc);
            }
        }

        if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterUpdate) {
            UpdatePlannedGiftIndicator(triggerNew,triggerOldMap);
        } 
        else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeDelete) {
           //validation rule - Do not allow proposals to delete when stage is Booked
           ValidationForProposals(triggerOldMap);
            PreventProposalDeletion(triggerOld);
        }          
        else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterDelete) {
            UpdatePlannedGiftIndicator(null,triggerOldMap);
        } 
         
        return dmlWrapper;
    }
    
    public static void ValidationForProposals(Map<Id, Opportunity> oldmap){
    system.debug('$$'+'validation');
        for(Opportunity opp: oldmap.values()){
            if(opp.ND_RecordType_DeveloperName__c=='Proposal' && opp.stageName=='Booked')
                opp.Name.adderror('Cannot delete a proposal record when stageName is "Booked".');
        
        }
    }
    
    // To prevent users of all profiles aside from System Admin and Gift and Data Mgmt from deleting any Opportunity records that are not Proposals
    public static void PreventProposalDeletion(List<Opportunity> triggerOld){
        Set<Id> NonProposalOppIds = new Set<Id>();
    	for(Opportunity opp : triggerOld) {
        	if(opp.ND_RecordType_DeveloperName__c != 'Proposal') {
            	NonProposalOppIds.add(opp.Id);
        	}
    	}
    	system.debug('@@ NonProposalOppIds '+NonProposalOppIds);
        
    	String profileName=[ Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
    	
    	if (NonProposalOppIds.size() > 0  && profileName != 'System Administrator' && profileName != 'Gift and Data Mgmt' ) {
        	for (Opportunity op :triggerOld ) {
            	if(NonProposalOppIds.contains(op.id)){
                	op.addError('You do not have permission to delete this Opportunity');
            	}
        	}
    	}
    
    }
    
    public static void UpdatePlannedGiftIndicator(list<Opportunity> newRecords,Map<Id, Opportunity> oldmap){
   		Set<id> accIds = new Set<Id>();
        Boolean queryCampaign = false;
        Map<Id,campaign> cmpRecord =new Map<Id,Campaign>(); 
        for(Opportunity opp: (newRecords!=null?newRecords:oldmap.values()) ){
            if(newRecords==null && opp.Type=='GK' && opp.CampaignId!=null)
                queryCampaign=true;
        }
        if(queryCampaign)
            cmpRecord = new Map<Id,Campaign>([Select id from campaign where name='Planned Gift' AND Type='Solicitation' limit 1]);
        map<id,Id> accId= new Map<Id,Id>();
        Set<id> conids = new Set<id>();
        for(Opportunity opp: (newRecords!=null?newRecords:oldmap.values()) ){
            conids.add(opp.ucinn_ascendv2__Contact__c);
        } 
        for(contact con:[Select id,accountId from contact where id=:conids]){
            accId.put(con.Id,con.AccountId);
        }
        for(Opportunity opp: (newRecords!=null?newRecords:oldmap.values()) ){
 
            if(accId.containsKey(Opp.ucinn_ascendv2__Contact__c)  && (Opp.ND_RecordType_DeveloperName__c=='Pledge' ||Opp.ND_RecordType_DeveloperName__c=='Gift' )&& newRecords!=null && opp.StageName!=oldmap.get(opp.id).StageName &&
               (  (opp.Type.startsWithIgnoreCase('Q') || opp.Type.startsWithIgnoreCase('T') || opp.Type=='PD' ) && opp.Type!='TO' && opp.Type!='TJ' && opp.Type!='GK' && opp.Type!='T2' && opp.Type!='T3' )  
               && 
               (opp.StageName=='Withdrawn'  ||opp.StageName== 'Declined' ||
                opp.StageName=='Not Funded'||opp.StageName=='Written Off'
                ||opp.StageName=='Void'||opp.StageName=='Terminated'||opp.StageName=='Terminated Early'||
                opp.StageName=='Inactive' ||opp.StageName== 'Cancelled' ||opp.StageName== 'Adjusted'
               )){
                    accIds.add(accId.get(Opp.ucinn_ascendv2__Contact__c));
                }
                
            
            else if(newRecords==null && accId.containsKey(Opp.ucinn_ascendv2__Contact__c)  && (Opp.ND_RecordType_DeveloperName__c=='Pledge'||Opp.ND_RecordType_DeveloperName__c=='Gift') &&
                 (  (opp.Type.startsWithIgnoreCase('Q') || opp.Type.startsWithIgnoreCase('T') || opp.Type=='PD' ) && opp.Type!='TO' && opp.Type!='TJ' && opp.Type!='GK' && opp.Type!='T2' && opp.Type!='T3' ) 
                   )
            	   {
                       accIds.add(accId.get(Opp.ucinn_ascendv2__Contact__c));
                   }
                  
                    
            else if(newRecords==null && accId.containsKey(Opp.ucinn_ascendv2__Contact__c)  && Opp.campaignId!=null&& Opp.Type=='GK' && cmpRecord.containsKey(Opp.CampaignId))
                accIds.add(accId.get(Opp.ucinn_ascendv2__Contact__c) ); 
            
            
       }
  
        if(accIds.size()>0 && !system.isBatch() && !system.isQueueable() && !system.isFuture()) {
            AsyncOptions options = new AsyncOptions();
			options.DuplicateSignature = new System.QueueableDuplicateSignature.Builder().addId(UserInfo.getUserId()).addString('GiftIndicator').build();
            System.enqueueJob(new ND_PlannedGiftIndicatorQueueable(accIds),options);
        //    System.enqueueJob(new ND_PlannedGiftIndicatorQueueable(accIds));
        }
    }
}