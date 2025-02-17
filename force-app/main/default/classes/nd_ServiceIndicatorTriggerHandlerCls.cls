global class nd_ServiceIndicatorTriggerHandlerCls extends ucinn_ascendv2.ascend_TDTM_Runnable  {
    private ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper = new ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper();
    
    private static final string Daily_List ='Daily List';
    
    global override ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, ucinn_ascendv2.ascend_TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        List<ucinn_ascendv2__Service_Indicator__c> triggerNew = (List<ucinn_ascendv2__Service_Indicator__c>) newList;
        List<ucinn_ascendv2__Service_Indicator__c> triggerOld = (List<ucinn_ascendv2__Service_Indicator__c>) oldList;

        Map<Id, ucinn_ascendv2__Service_Indicator__c> triggerOldMap = new Map<Id, ucinn_ascendv2__Service_Indicator__c>();
        if (triggerOld != null) {
            for (ucinn_ascendv2__Service_Indicator__c si : triggerOld) {
                triggerOldMap.put(si.Id, si);
            }
        }

        if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterInsert) {
          	SIGcheckbox(triggerNew,null);
        } 
		else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterUpdate) {
            SIGcheckbox(triggerNew,triggerOldMap);
        } 
		else if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.AfterDelete) {
      		SIGcheckbox(triggerOld,null);
        } 

        return dmlWrapper;
    }
    
    /*      
    public static void afterInsert(list<ucinn_ascendv2__Service_Indicator__c> newrecords){
        SIGcheckbox(newrecords);
    }
    public static void afterUpdate(list<ucinn_ascendv2__Service_Indicator__c>newrecords, Map<id,ucinn_ascendv2__Service_Indicator__c> newrecordsMap ){
        SIGcheckbox(newrecords);
    }
    public static void afterdelete(list<ucinn_ascendv2__Service_Indicator__c>newrecords){
         SIGcheckbox(newrecords);
    }
    */
    /* Sig check box: checking if constituent is having Daily List service indicator and making SiG indicator to true*/
    
    public static void SIGcheckbox(list<ucinn_ascendv2__Service_Indicator__c> ndServInd,map<id,ucinn_ascendv2__Service_Indicator__c> oldValues) {
        set<Id> constIds = new set<Id>();
        Map<Id, Contact> constsToUpdate = new map<Id, Contact>();
        Map<Id, Contact> constsToProcess = new map<Id, Contact>();
        for(Integer i = 0; i < ndServInd.size(); i++){
            if((oldValues!=null&& oldValues.get(ndServInd[i].Id).ucinn_ascendv2__Service_Indicator_Value__c!=ndServInd[i].ucinn_ascendv2__Service_Indicator_Value__c))
            	constIds.add(ndServInd[i].ucinn_ascendv2__Contact__c);
            else if(oldValues==null)
                constIds.add(ndServInd[i].ucinn_ascendv2__Contact__c);
         } 
        
        list<Contact> constituents = [SELECT Id,nd_SIG__c,
                                      ( SELECT id,isdeleted, ucinn_ascendv2__Service_Indicator_Value__r.Name,ucinn_ascendv2__Is_Active__c 
                                       FROM ucinn_ascendv2__Service_Indicators_Contact__r 
                                       WHERE  
                                        ucinn_ascendv2__Service_Indicator_Value__r.Name =:Daily_List
                                      )
                                      FROM Contact
                                      WHERE Id in:constIds
                                     ];
        for(Contact c : constituents){
            List<ucinn_ascendv2__Service_Indicator__c> ls = c.ucinn_ascendv2__Service_Indicators_Contact__r;
            system.debug('2'+ls);
            //No Dailylist and SIG true             
            if(ls.isEmpty() && c.nd_SIG__c==true ){
                c.nd_SIG__c =false;
                constsToProcess.put(c.Id,c);
            }else if(!ls.isEmpty() && !c.nd_SIG__c ){
                c.nd_SIG__c =true;
                constsToUpdate.put(c.Id,c);
            }
        }
         
        if(!constsToUpdate.isEmpty())
            update constsToUpdate.values();
        
        // checking for involvement record exist for constituent before unchecking SIG check box
        if(!constsToProcess.isEmpty())
        {
                list<Contact> constituentList = [SELECT Id,nd_SIG__c,ND_VIP__c, ND_VIP_Reason__c,ucinn_ascendv2__Preferred_Spouse__c,
                                        (SELECT Id, isDeleted,ucinn_ascendv2__Involvement_Type_Formula__c,ucinn_ascendv2__Status__c,ucinn_ascendv2__Contact__c 
                                         FROM ucinn_ascendv2__Involvements_Contact__r
                                         WHERE (RecordType.developerName='Advisory_Council' OR RecordType.developerName='Other_Involvements')
                                               AND RecordType.IsActive = true 
                                               AND ucinn_ascendv2__Status__c = 'A'
                                               AND ucinn_ascendv2__Involvement_Type_Formula__c IN ('ADB','ADC','BOT','CC','UNACD')
                                        )    FROM Contact WHERE Id in:constsToProcess.keyset()];   
            for(contact c: constituentList){
                if(c.ucinn_ascendv2__Involvements_Contact__r.size()>0)
                constsToProcess.remove(c.Id);
            }
           
            update constsToProcess.values();
        }
        
        
           
    }
    
}