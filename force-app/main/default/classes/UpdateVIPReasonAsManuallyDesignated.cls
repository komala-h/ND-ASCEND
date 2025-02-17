public class UpdateVIPReasonAsManuallyDesignated {
    private static final string MANUALLY_DESIGNATED  = 'M';
    private static final string DONORLEVEL  = 'D';
    private static final string INVOLVEMENT  = 'I';
    public static boolean run = true;
    
    @InvocableMethod(label='Assign VIP and VIP reason as manually designated')
    public static list<FlowOutputs> updateConstituents(list<FlowInputs> finputs){
        list<FlowOutputs> outputFlowList = new list<FlowOutputs>();
        FlowOutputs output = new FlowOutputs();
               
        if(run ){
            run=true;
            UpdateVipAndVipReasonForConstituent.run=true;
            list<Contact> inputContacts = new list<Contact>();
            Boolean ToAddManuallyDesignated;
            FlowInputs input = new FlowInputs();
            Set<String> vipReasons = new Set<String>();
            list<Contact> consToUpdate = new list<Contact>();

            try{
                if(!finputs.isEmpty()){
                    input = finputs[0];
                    inputContacts = input.constituents;
                    ToAddManuallyDesignated = input.ToAdd;
                    if(ToAddManuallyDesignated==true){
                        for(Contact con:InputContacts){
                            if(con==null)
                                continue;
                            system.debug('@@ vip reason is: '+con.ND_VIP_Reason__c+' for contact ');
                            if(con.ND_VIP_Reason__c!=null){
                                vipReasons = new set<String>(con.ND_VIP_Reason__c.split(';'));
                                system.debug('vip reasons '+vipReasons);
                                if(!vipReasons.contains(MANUALLY_DESIGNATED)){
                                    con.ND_VIP_Reason__c = con.ND_VIP_Reason__c+';'+MANUALLY_DESIGNATED;
                                    con.ND_VIP__c = true;
                                    consToUpdate.add(con);
                                }
                                else if((vipReasons.contains(MANUALLY_DESIGNATED)) && (con.ND_VIP__c ==false)){
                                    con.ND_VIP__c = true;
                                    consToUpdate.add(con);
                                }
                            }
                            else{
                                con.ND_VIP__c = true;
                                con.ND_VIP_Reason__c=MANUALLY_DESIGNATED;
                                consToUpdate.add(con);
                           }
                            
                        }
                    }
                    else{
                        for(Contact con:inputContacts){
                            if(con==null)
                                continue;
                    		system.debug(' value in vip reason is '+con.ND_VIP_Reason__c);
                            
                            if(con.ND_VIP_Reason__c!=null){
                                vipReasons = new set<String>(con.ND_VIP_Reason__c.split(';'));
                                system.debug('vip reasons are: '+vipreasons);
                                if(vipReasons.contains(MANUALLY_DESIGNATED) && vipReasons.size()==1){
                                    con.ND_VIP_Reason__c = '';
                                    con.ND_VIP__c = false;
                                    consToUpdate.add(con);
                                }
                                else if(vipReasons.contains(MANUALLY_DESIGNATED) && vipReasons.size()>1 ){
                                    vipReasons.remove(MANUALLY_DESIGNATED);
                                    con.ND_VIP_Reason__c = String.join(new list<String>(vipReasons),';');
                                    con.ND_VIP__c=true;
                                    consToUpdate.add(con);
                                }
                                
                            }
                            else{
                                con.ND_VIP__c = false;
                                consToUpdate.add(con);
                            }
                            
                        }
                    }
                    if(!consToUpdate.isEmpty()){
                        for(contact c:consToUpdate){
                            system.debug('@@ vip checkbox :'+c.ND_VIP__c);
                            system.debug('@@ vip reason :'+c.ND_VIP_Reason__c);
                        }
                        update consToUpdate;
                        output.constituents = consToUpdate;
                    	output.recordsUpdated = true;
                    	outputFlowList.add(output);
                    	system.debug('@@ outputs : '+outputFlowList);
                    }
                }
            }
            catch(Exception ex)
            {
                system.debug('exception: '+ex.getMessage()+ ex.getStackTraceString());
            }
        }
        return outputFlowList; 
    }
    
    public class FlowInputs{
        @InvocableVariable public list<Contact> constituents;
        @InvocableVariable public Boolean ToAdd;
    }
    public class FlowOutputs{
        @InvocableVariable public list<Contact> constituents;
        @InvocableVariable public Boolean recordsUpdated;
    }

}