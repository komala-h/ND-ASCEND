public class UpdateVipAndVipReasonForConstituent {
    private static final string DONORLEVEL  = 'D';
    public static boolean run = true;
    
    @InvocableMethod(label='Assign VIP and VIP reason')
    public static list<FlowOutputs> updateConstituents(list<FlowInputs> finputs){
        list<FlowOutputs> outputFlowList = new list<FlowOutputs>();
        FlowOutputs output = new FlowOutputs();
        
        if(run){
            run=true;
            UpdateVIPReasonAsManuallyDesignated.run=true;
            list<Contact> inputContacts = new list<Contact>();
            Boolean ToAddDonorLevel;
            FlowInputs input = new FlowInputs();
            Set<String> vipReasons = new Set<String>();
            Map<Id,Contact> consToUpdate = new Map<Id,Contact>();
            /*system.debug('@@ number of contacts: '+finputs.size()); 
            for(FlowInputs conList : finputs)  {
            system.debug('$'+conList.constituents.size());
            system.debug('$'+conList.ToAdd);
            for(Contact c: conList.constituents){
             system.debug('$'+c.Id);
            }
           
            }   */
            try{
                for(FlowInputs fi : finputs)  {
                    
                if(!finputs.isEmpty()){
                    input = fi;
                    inputContacts = input.constituents;
                    output.constituents = inputContacts;
                    output.recordsUpdated = true;
                    outputFlowList.add(output);
                    system.debug('@@ number of contacts: '+inputContacts); 
                    ToAddDonorLevel = input.ToAdd;
                    system.debug('@@ number of contacts: '+inputContacts.size()); 
                    system.debug('@@ ToAddDonorLevel :'+ToAddDonorLevel);
                    if(ToAddDonorLevel==true){
                        for(Contact con:InputContacts){
                            if(con==null)
                                continue;
                            system.debug('@@ contact vip reason is:'+con.ND_VIP_Reason__c+'for contact ');
                           if(con.ND_VIP_Reason__c!=null){
                               system.debug('@@Inside if');
                                vipReasons = new set<String>(con.ND_VIP_Reason__c.split(';'));
                                system.debug('vip reasons '+vipReasons);
                                if(!vipReasons.contains(DONORLEVEL)){
                                    con.ND_VIP_Reason__c = con.ND_VIP_Reason__c+';'+DONORLEVEL;
                                    con.ND_VIP__c = true;
                                    consToUpdate.put(con.Id,con);
                                }
                                else if((vipReasons.contains(DONORLEVEL)) && (con.ND_VIP__c ==false)){
                                    con.ND_VIP__c = true;
                                    consToUpdate.put(con.Id,con);
                                }
                            }
                            else{
                                system.debug('@@ Inside else');
                                con.ND_VIP__c = true;
                                con.ND_VIP_Reason__c=DONORLEVEL;
                                consToUpdate.put(con.Id,con);
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
                                if(vipReasons.contains(DONORLEVEL) && vipReasons.size()==1){
                                    con.ND_VIP_Reason__c = '';
                                    con.ND_VIP__c = false;
                                    consToUpdate.put(con.Id,con);
                                }
                                else if(vipReasons.contains(DONORLEVEL) && vipReasons.size()>1 ){
                                    vipReasons.remove(DONORLEVEL);
                                    con.ND_VIP_Reason__c = String.join(new list<String>(vipReasons),';');
                                    con.ND_VIP__c=true;
                                    consToUpdate.put(con.Id,con);
                                }
                            }
                            else{
                                con.ND_VIP__c = false;
                                consToUpdate.put(con.Id,con);
                            }
                        }
                    }
                    if(!consToUpdate.isEmpty()){
                        for(contact c:consToUpdate.values()){
                            system.debug('@@ contacts to update : '+ c.id);
                            system.debug('@@ con vip checkbox :'+c.ND_VIP__c);
                            system.debug('@@ con vip reason :'+c.ND_VIP_Reason__c);
                        }
                        
                        update consToUpdate.values();

                        system.debug('@@ outputs : '+outputFlowList);
                    }
                    
                    
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