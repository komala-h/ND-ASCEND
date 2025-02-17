global class ND_ContactStatusIndicator  implements Database.Batchable<SObject>, Database.Stateful,Schedulable{

    /* 
     * Household who has a planned gift on their giving record, as defined by: pledge or gift ( transaction type that starts with a T\ *or Q* )
	 * In some cases this calculation includes those people with a Gift in Kind transaction with an appeal of "Planned Giving" 
	 * Created a batch apex to update the PlannedGiftDonor based on the overall existing donations  
   */
    global void execute(SchedulableContext SC){
        Integer noOfRecords = (Integer)ManageBatchJobSize__mdt.getInstance('PlannedGiftDonor').ChunkSize__c;           
	    ND_ContactStatusIndicator caseBatch = new ND_ContactStatusIndicator();
        DataBase.executeBatch(caseBatch,noOfRecords);         
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query='Select id from Account where Recordtype.Developername=\''+'Household'+'\' AND nd_Planned_Gift_Donor__c=false';
  //      String query='Select id from Account where id=\'0010400000TQX04AAH\'';
        return Database.getQueryLocator(query);
    }
    
    /* Autocreates a endowment case reports */     
    global void execute(Database.BatchableContext BC, list<Account> Accounts){
        Set<id> accids= new set<Id>();
        List<account> UpdateAcc= new List<account>();
        for(Account acc: Accounts){
            accids.add(acc.id);
        }
    	Map<id,Boolean> MapofAccounts = getGiftsOrPledges(accids);
      //  system.debug('@3'+MapofAccounts);
        for(id idkey : MapofAccounts.keySet() ){
            account acc = new account(id=idKey,nd_Planned_Gift_Donor__c=true);
            UpdateAcc.add(acc);
        }
        if(UpdateAcc.size()>0)
            update UpdateAcc;
    }    
    global void finish(Database.BatchableContext BC) {
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] {job.CreatedBy.Email};
        message.subject = 'Contact Status Indicator';
        message.plainTextBody = 'Your batch job to update planned gift donor has been processed successfully.';
        
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
    }
    public static Map<Id,Boolean> getGiftsOrPledges(Set<id> accountIds){
         Integer recordCount = [select count() 
                                from opportunity 
                                where ( (recordtype.developerName IN ('Gift') OR recordtype.developerName IN ('Pledge') )
             		AND ( StageName NOT IN ('Withdrawn','Cancelled','Declined','Not Funded','Written Off','Void','Terminated','Terminated Early','Inactive','Adjusted')) ) 
             //       AND StageName NOT IN ('Declined','Not Funded','Terminated','Terminated Early','Inactive')) )             
                    AND ( ( Type like 'T%' OR Type Like 'Q%' OR Type ='PD') AND type!='TO' AND Type !='TJ' AND Type !='GK' AND Type !='T2' AND Type !='T3' ) 
                    AND ucinn_ascendv2__Contact__r.AccountId in :accountIds
                               ];
            Integer sizeBlock = recordCount/2000 + (math.mod(recordCount,2000)!=0?1:0) ;
            
            Map<Id,Boolean> mapaccIds = new Map<Id,Boolean>(); 
            Set<Id> Ids = new Set<Id>(); 

            //Iterate aggregate result with blocks of 2000 to avoid exception
            for(Integer i=0;i<sizeBlock;i++){            
                for(AggregateResult ar : [Select count(Id),ucinn_ascendv2__Contact__r.AccountId 
                                          from opportunity 
                                          where ( ( recordtype.developerName IN ('Gift')  OR recordtype.developerName IN ('Pledge') )
                      AND ( StageName NOT IN ('Withdrawn','Cancelled','Declined','Not Funded','Written Off','Void','Terminated','Terminated Early','Inactive','Adjusted')) ) 
               //       AND StageName NOT IN ('Declined','Not Funded','Terminated','Terminated Early','Inactive')) )                     
                      AND ( ( Type like 'T%' OR Type Like 'Q%' OR Type ='PD') AND type!='TO' AND Type !='TJ' AND Type !='GK' AND Type !='T2' AND Type !='T3')
                      AND ucinn_ascendv2__Contact__r.AccountId in:accountIds AND ucinn_ascendv2__Contact__r.AccountId NOT IN :mapaccIds.keySet()
                      group by ucinn_ascendv2__Contact__r.AccountId  limit 2000]) {

                    mapaccIds.put(Id.valueOf(String.valueOf(ar.get('AccountId'))),true);
                }
            }
   
        for(id recordId : accountIds){
            if(!mapaccIds.containsKey(recordId))
                Ids.add(recordId);
        }
        if(Ids.size()>0){
            Map<Id,Boolean>  giftInKind = getGiftInKind(Ids);
            mapaccIds.putAll(giftInKind);
        }
   //     system.debug('@@ mapaccIds '+mapaccIds);
        return mapaccIds;     
    }
    public static  Map<Id,Boolean>  getGiftInKind(Set<id> accountIds){
        Integer recordCount2 = [select count() from opportunity where Type='GK'  AND  ucinn_ascendv2__Contact__r.AccountId in :accountIds AND campaign.Name='Planned Gift' AND campaign.Type='Solicitation'];
                    Integer sizeBlock2 = recordCount2/2000 + (math.mod(recordCount2,2000)!=0?1:0) ;
        //Set<Id> setIds = new Set<Id>(); 
        Map<Id,Boolean>   mapOfRecords   = new Map<Id,Boolean>();
        
        //Iterate aggregate result with blocks of 2000 to avoid exception
        for(Integer i=0;i<sizeBlock2;i++){            
            for(AggregateResult ar : [Select count(Id),ucinn_ascendv2__Contact__r.AccountId,recordtype.developerName from opportunity where Type='GK' AND 
                                      ucinn_ascendv2__Contact__r.AccountId in:accountIds AND ucinn_ascendv2__Contact__r.AccountId NOT IN :mapOfRecords.keySet() AND campaign.Name='Planned Gift' AND campaign.Type='Solicitation'
                                      group by ucinn_ascendv2__Contact__r.AccountId,recordtype.developerName  limit 2000]) {

                                          mapOfRecords.put(Id.valueOf(String.valueOf(ar.get('AccountId'))),true);
                                      }
        }
        
        return mapOfRecords;
        
   }
}