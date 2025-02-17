public class ND_PlannedGiftIndicatorQueueable implements Queueable {
   /* 
     * Household who has a planned gift on their giving record, as defined by: pledge or gift ( transaction type that starts with a T\ *or Q* )
	 * In some cases this calculation includes those people with a Gift in Kind transaction with an appeal of "Planned Giving" 
	 * Created apex to update the PlannedGiftDonor based on the overall existing donations on update and delete using queueable apex   
   */ 
    Set<id> recIds =new Set<id>();
    public  ND_PlannedGiftIndicatorQueueable(Set<id> accids){
        recIds = accids;
    }
    public void execute(QueueableContext context) {
     
      Map<id,Boolean> accRecords= ND_ContactStatusIndicator.getGiftsOrPledges(recIds);
      List<account> accUpdates= new List<account>();
        for(Id recid: recIds){
             account acc = new account(nd_Planned_Gift_Donor__c=accRecords.containsKey(recid),id=recid);
             accUpdates.add(acc);
        }
        if(accUpdates.size()>0)
            update accUpdates;
    }
}