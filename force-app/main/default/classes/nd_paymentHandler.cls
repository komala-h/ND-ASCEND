global class nd_paymentHandler extends ucinn_ascendv2.ascend_TDTM_Runnable {
    
    private ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper dmlWrapper = new ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper();
    
    global override ucinn_ascendv2.ascend_TDTM_Runnable.DmlWrapper run(List<SObject> newList, List<SObject> oldList, ucinn_ascendv2.ascend_TDTM_Runnable.Action triggerAction, Schema.DescribeSObjectResult objResult) {
        List<ucinn_ascendv2__Payment__c> triggerNew = (List<ucinn_ascendv2__Payment__c>) newList;
        List<ucinn_ascendv2__Payment__c> triggerOld = (List<ucinn_ascendv2__Payment__c>) oldList;
        
        if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeInsert) {
            handpayment(triggerNew);
        } 
        
        if (triggerAction == ucinn_ascendv2.ascend_TDTM_Runnable.Action.BeforeUpdate) {
          //  handpayment(triggerNew);
        } 
        
        return dmlWrapper;
    }
    
    public static void handpayment(list<ucinn_ascendv2__Payment__c> payList){
        
        Set<Id> reviewId= new Set<Id>();
        map<id,string> remBank= new map<id,string>();
        map<id,boolean> sendCheck= new map<id,boolean>();
        List<ucinn_ascendv2__Review_Transaction_v2__c> rvList=new List<ucinn_ascendv2__Review_Transaction_v2__c>();
        // map<id,Date> uDate= new map<id,Date>();
        for(ucinn_ascendv2__Payment__c pay: payList)
        {
            reviewId.add(pay.ucinn_ascendv2__Review_Transaction_v2__c);  
        }
        
        rvList=[select id,nd_Remitting_Bank__c,ucinn_ascendv2__Send_to_G_L__c,nd_Membership_Credit_Date__c from ucinn_ascendv2__Review_Transaction_v2__c where id IN:reviewId];
        for(ucinn_ascendv2__Review_Transaction_v2__c rev :rvList){
            remBank.put(rev.id,rev.nd_Remitting_Bank__c);
            sendCheck.put(rev.id,rev.ucinn_ascendv2__Send_to_G_L__c);
            //  uDate.put(rev.id,rev.nd_Membership_Credit_Date__c);
        }
        
        if(rvList.size()>0)
        {
            for(ucinn_ascendv2__Payment__c ndpay: payList)
            {
                ndpay.ND_Remitting_Bank__c=remBank.get(ndpay.ucinn_ascendv2__Review_Transaction_v2__c);
                ndpay.ucinn_ascendv2__Send_to_G_L__c=sendCheck.get(ndpay.ucinn_ascendv2__Review_Transaction_v2__c);
                //  ndpay.ND_Membership_Credit_Date__c=uDate.get(ndpay.ucinn_ascendv2__Review_Transaction_v2__c);
            }
            
        }
        
    }
    
}