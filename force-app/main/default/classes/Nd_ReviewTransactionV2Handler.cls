global class Nd_ReviewTransactionV2Handler extends ucinn_ascendv2.ascend_TDTM_Runnable  {
    private ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper = new ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper();
    
    global override ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, ucinn_ascendv2.ascend_TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        List<ucinn_ascendv2__Review_Transaction_v2__c> triggerNew = (List<ucinn_ascendv2__Review_Transaction_v2__c>) newList;
        List<ucinn_ascendv2__Review_Transaction_v2__c> triggerOld = (List<ucinn_ascendv2__Review_Transaction_v2__c>) oldList;

        Map<Id, ucinn_ascendv2__Review_Transaction_v2__c> triggerOldMap = new Map<Id, ucinn_ascendv2__Review_Transaction_v2__c>();
        if (triggerOld != null) {
            for (ucinn_ascendv2__Review_Transaction_v2__c si : triggerOld) {
                triggerOldMap.put(si.Id, si);
            }
        }

        if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeInsert) {
          	UpdateNameOnClone(triggerNew);
          //  UpdateSendGL(triggerNew);
        } 

        return dmlWrapper;
    }
    
    /*update the Name and External System ID fields on the cloned record so it has the same base number but adds a '- X' where X is a number that starts with '2' 
     * and increases by one if the record is cloned again
    */
    
    public void UpdateNameOnClone(List<ucinn_ascendv2__Review_Transaction_v2__c> newrecords){
        Map<string,Integer> noofRecords = new Map<string,Integer>();
        Set<string> namesList = new Set<string>();
        for(ucinn_ascendv2__Review_Transaction_v2__c rtv2: newrecords){
            system.debug(rtv2.isClone());
            if(rtv2.isClone()){
                String s= rtv2.Name.split('_')[0];
                namesList.add(s+'%');
                noofRecords.put(s,0);
            }
        }
        for(ucinn_ascendv2__Review_Transaction_v2__c rtv2: [select id,name from ucinn_ascendv2__Review_Transaction_v2__c where name like:namesList]){
            String s= rtv2.Name.split('_')[0];
            if(noofRecords.containsKey(s)){
                Integer count =noofRecords.get(s)+1;noofRecords.put(s,count);                
            }
        }
        
         for(ucinn_ascendv2__Review_Transaction_v2__c rtv2: newrecords){
            if(rtv2.isClone()){
                String s= rtv2.Name.split('_')[0];
                if(noofRecords.containsKey(s)){
                    rtv2.Name=  s+'_'+string.valueof(noofRecords.get(s)+1);
                    if(string.isNotBlank(rtv2.ucinn_ascendv2__External_System_ID__c))
                    rtv2.ucinn_ascendv2__External_System_ID__c =  rtv2.ucinn_ascendv2__External_System_ID__c.split('_')[0]+'_'+string.valueof(noofRecords.get(s)+1);
                }
            }
        }       
    }
    
  /*  public void UpdateSendGL(List<ucinn_ascendv2__Review_Transaction_v2__c> newrecords){
        
         for(ucinn_ascendv2__Review_Transaction_v2__c rtv2: newrecords){
             rtv2.ucinn_ascendv2__Send_to_G_L__c=true;
         }
    } */
}