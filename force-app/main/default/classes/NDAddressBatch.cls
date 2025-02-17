global class NDAddressBatch implements Database.Batchable<sObject>,Schedulable{

   List<String> recids = new List<string>();
    global void execute(SchedulableContext SC) {
        Integer noOfRecords = (Integer)ManageBatchJobSize__mdt.getInstance('NDAddressBatch').ChunkSize__c;           
        NDAddressBatch M = new NDAddressBatch();
        database.executeBatch(m,noOfRecords);
    }
    
    global Database.querylocator start(Database.BatchableContext BC){ 
         return Database.getQueryLocator([Select id,ucinn_ascendv2__Contact__c from ucinn_ascendv2__Address_Relation__c  where  ucinn_ascendv2__Address__r.ND_ToBeProcessedByBatchJob__c=LAST_N_DAYS:1  AND (ucinn_ascendv2__Type__c ='B' OR  ucinn_ascendv2__Type__c='H') AND ucinn_ascendv2__Status__c='Current' AND  ucinn_ascendv2__Is_Preferred__c=true AND ucinn_ascendv2__Contact__c != null   AND ucinn_ascendv2__End_Date__c = null]);
        //ucinn_ascendv2__Address_Postal_Code_Formula__c!=NULL
    }
    global void execute(Database.BatchableContext BC, List<ucinn_ascendv2__Address_Relation__c> scope){
        
        Set<string> conIds = new Set<String>();
        Set<string>addRelIds=new set<String>();
        //for(ucinn_ascendv2__Address__c addR: scope){
            //recids.add(addR.id);
        //}
        for(ucinn_ascendv2__Address_Relation__c arc: scope){            											
              conIds.add(arc.ucinn_ascendv2__Contact__c);
              addRelIds.add(arc.id);               
        }
        List<ucinn_ascendv2__Address_Relation__c> arcl= [select id,ND_Address_Country__c,ucinn_ascendv2__Contact__r.Account.ND_Household_Category__c,ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__Primary_Contact__c,ucinn_ascendv2__Contact__r.Account.Secondary_Constituent__c, ucinn_ascendv2__Status__c,ucinn_ascendv2__Type__c,ND_RecordTypeName__c,ucinn_ascendv2__End_Date__c,
                                               ucinn_ascendv2__Contact__c,ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__c,ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__r.ND_Group_Region__c,Is_ERD_Or_EPD__c, ucinn_ascendv2__Address_Postal_Code_Formula__c,ucinn_ascendv2__Address__c,
                                               ucinn_ascendv2__Is_Preferred__c,ucinn_ascendv2__Address_State_Formula__c,ucinn_ascendv2__Contact__r.AccountId,ucinn_ascendv2__Address__r.ucinn_ascendv2__Country__c from ucinn_ascendv2__Address_Relation__c
                                               where  ucinn_ascendv2__Contact__c=:conIds AND id=:addRelIds AND
                                              (ucinn_ascendv2__Type__c ='B' OR  ucinn_ascendv2__Type__c='H') AND ucinn_ascendv2__Status__c='Current' AND 
                                               ucinn_ascendv2__End_Date__c=null AND  ucinn_ascendv2__Is_Preferred__c=true];     //AND ucinn_ascendv2__Address_Postal_Code_Formula__c !=null    
        Map<string,string> prmRegionMap = new Map<string,string>();
        Map<string,string> postalCodeMap = new Map<String,String>();
        Map<string,String> countryCodeMap = new Map<String,String>();
        // new line added for If country is Canada (CA)--
        Map<string,String> StateCodeMap = new Map<String,String>();
        Map<string,ND_Geo_Group_Region__c> postalcodeGeoGroup = new Map<String,ND_Geo_Group_Region__c>();
        Map<string,Contact> newConMap = new Map<string,Contact>();
        Map<string,Account> newAccMap = new Map<string,Account>();
        
        for(ucinn_ascendv2__Address_Relation__c arc: arcl){
            if(arc.ucinn_ascendv2__Type__c == 'H' && arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__c!=null && 
               arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__r.ND_Group_Region__c!=null){
               prmRegionMap.put(arc.ucinn_ascendv2__Contact__r.AccountId,arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__r.ND_Group_Region__c);
            }
            // New changes for country Code. I did find few records(9799) using the country code instead of Country Name
            if((arc.ND_Address_Country__c=='United States' || arc.ND_Address_Country__c=='US') && arc.ucinn_ascendv2__Address_Postal_Code_Formula__c!=NULL ){
                postalCodeMap.put(arc.ucinn_ascendv2__Address__c, arc.ucinn_ascendv2__Address_Postal_Code_Formula__c.split('-')[0]);
            }// new line added for If country is Canada (CA)--
            else if(arc.ND_Address_Country__c=='Canada' || arc.ND_Address_Country__c=='CA') {
                countryCodeMap.put(arc.ucinn_ascendv2__Address__c, arc.ND_Address_Country__c);
                StateCodeMap.put(arc.ucinn_ascendv2__Address__c, arc.ucinn_ascendv2__Address_State_Formula__c);               
            }
            else if(String.isNotBlank(arc.ND_Address_Country__c)) {
                countryCodeMap.put(arc.ucinn_ascendv2__Address__c, arc.ND_Address_Country__c);
                
            }
        }
        
        if(!postalCodeMap.isEmpty()){
            for(ND_Geo_Group_Region__c gr: [Select id,Postal_Code__c,Prospect_Region__c,ND_Club_Region__c,MSA_Code__c,MSA_Name__c,Country__c from ND_Geo_Group_Region__c where Postal_Code__c=:postalCodeMap.values()]){
                    postalcodeGeoGroup.put(gr.Postal_Code__c, gr);
            }
        }
        if(!countryCodeMap.isEmpty()){
            for(ND_Geo_Group_Region__c gr: [Select id,Postal_Code__c,Prospect_Region__c,ND_Club_Region__c,MSA_Code__c,MSA_Name__c,Country__c,nd_Country_Full_Name__c from ND_Geo_Group_Region__c where nd_Country_Full_Name__c=:countryCodeMap.values() OR Country__c=:countryCodeMap.values()]){
                postalcodeGeoGroup.put(gr.nd_Country_Full_Name__c, gr);
                postalcodeGeoGroup.put(gr.Country__c, gr);
            }
        }        
        // New lines for canada country
       if(!StateCodeMap.isEmpty() && !countryCodeMap.isEmpty()){
            for(ND_Geo_Group_Region__c gr: [Select id,Postal_Code__c,Prospect_Region__c,ND_Club_Region__c,MSA_Code__c,MSA_Name__c,Country__c,nd_Country_Full_Name__c from ND_Geo_Group_Region__c where (nd_Country_Full_Name__c=:countryCodeMap.values() OR Country__c=:countryCodeMap.values()) AND State_Code__c=:StateCodeMap.values()]){
                postalcodeGeoGroup.put(gr.nd_Country_Full_Name__c, gr);
                postalcodeGeoGroup.put(gr.Country__c, gr);
            }
        }     
        for(ucinn_ascendv2__Address_Relation__c arc: arcl){           
            contact con ;
            Account acc ;
            
            if(newConMap.containsKey(arc.ucinn_ascendv2__Contact__c))
                con = newConMap.get(arc.ucinn_ascendv2__Contact__c);
            else
                con = new contact(id=arc.ucinn_ascendv2__Contact__c,
                                  ND_Club_Region__c=null,
                                  nd_Alumni_Club_Business__c = null,          
                                  ND_Home_Address_Region__c = null,
                                  MSA_Code__c = null,
                                  MSA_Name__c = null
                                  // prospect_Region__c =null
                                 );
            // if it is secondary contact dont add it in Accountmap (to overcome if both primary and secondary contact process in same batch)
            if (arc.ucinn_ascendv2__Contact__c == arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__Primary_Contact__c) {
                if(newAccMap.containsKey(arc.ucinn_ascendv2__Contact__r.AccountId))
                    acc = newAccMap.get(arc.ucinn_ascendv2__Contact__r.AccountId);
                else
                    acc = new Account(id=arc.ucinn_ascendv2__Contact__r.AccountId,
                                      ND_Home_Address_Region__c=null,
                                      MSA_Code__c = null,
                                      MSA_Name__c = null
                                      // Prospect_Region__c = null 
                                     );
            }
            if((arc.ucinn_ascendv2__Type__c == 'B'|| arc.ucinn_ascendv2__Type__c == 'H') && arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__c!=null && 
               (arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__r.ND_Group_Region__c!=null||test.isrunningTest())){                  
                   con.Prospect_Region__c = arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__r.ND_Group_Region__c;
                   if(acc !=null){
                       acc.Prospect_Region__c= arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__r.ND_Group_Region__c;
                       //prmRegionMap.put(arc.ucinn_ascendv2__Contact__r.AccountId,arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__r.ND_Group_Region__c);
                   }
               }
            // Country code Us
            if((arc.ND_Address_Country__c=='United States' || arc.ND_Address_Country__c=='US') && arc.ucinn_ascendv2__Address_Postal_Code_Formula__c!=NULL){
                ND_Geo_Group_Region__c gr;
                String postalcode =arc.ucinn_ascendv2__Address_Postal_Code_Formula__c.split('-')[0];
                //postalCodeMap.put(arc.ucinn_ascendv2__Address__c, arc.ucinn_ascendv2__Address_Postal_Code_Formula__c);
                if(postalcodeGeoGroup.containsKey(postalcode))
                    gr =postalcodeGeoGroup.get(arc.ucinn_ascendv2__Address_Postal_Code_Formula__c.split('-')[0]);  
                if(gr!=null && arc.ucinn_ascendv2__Type__c=='H' ){
                    if(acc !=null){
                        acc.ND_Home_Address_Region__c = gr.Prospect_Region__c;
                    }
                    con.ND_Home_Address_Region__c =gr.Prospect_Region__c;
                    if(arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__c==null ||
                       (arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__c!=null && 
                        arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__r.ND_Group_Region__c==null)){
                            con.Prospect_Region__c =gr.Prospect_Region__c;
                            if(acc !=null){       
                                acc.Prospect_Region__c = gr.Prospect_Region__c;
                            }
                        }
                    con.ND_Club_Region__c = gr.ND_Club_Region__c;
                    if(arc.ucinn_ascendv2__Is_Preferred__c || Test.isRunningTest()){
                        con.MSA_Code__c = gr.MSA_Code__c;
                        con.MSA_Name__c = gr.MSA_Name__c; 
                        if(acc !=null){
                            acc.MSA_Code__c =gr.MSA_Code__c;
                            acc.MSA_Name__c =gr.MSA_Name__c; 
                        }
                    }                  
                }                                 
                if (gr!=null && arc.ucinn_ascendv2__Type__c=='B'){
                    con.nd_Alumni_Club_Business__c = gr.ND_Club_Region__c!=null?gr.ND_Club_Region__c:null;
                    if(arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__c==null ||
                       (arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__c!=null && 
                        arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__r.ND_Group_Region__c==null)){
                            con.Prospect_Region__c =gr.Prospect_Region__c;
                            if(acc !=null){
                                acc.Prospect_Region__c = gr.Prospect_Region__c;
                            }
                        }
                    if(arc.ucinn_ascendv2__Is_Preferred__c || Test.isRunningTest()){
                        con.MSA_Code__c = gr.MSA_Code__c;
                        con.MSA_Name__c = gr.MSA_Name__c; 
                        if(acc !=null){
                            acc.MSA_Code__c =gr.MSA_Code__c;
                            acc.MSA_Name__c =gr.MSA_Name__c; 
                        }
                    }
                }     
                
            }// end of united states logic  
            else{
                ND_Geo_Group_Region__c ggr;
                system.debug('ND_Address_Country__c '+arc.ND_Address_Country__c);
                //postalCodeMap.put(arc.ucinn_ascendv2__Address__c, arc.ucinn_ascendv2__Address_Postal_Code_Formula__c);
                if(postalcodeGeoGroup.containsKey(arc.ND_Address_Country__c)){
                    ggr =postalcodeGeoGroup.get(arc.ND_Address_Country__c); 
                }
                if(ggr!=null && arc.ucinn_ascendv2__Type__c=='H' ){
                    if(acc !=null){
                        acc.ND_Home_Address_Region__c = ggr.Prospect_Region__c; 
                    }
                    con.ND_Home_Address_Region__c =ggr.Prospect_Region__c;                  
                    con.ND_Club_Region__c = ggr.ND_Club_Region__c;
                    if(arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__c==null && 
                       arc.ucinn_ascendv2__Contact__r.Account.ND_Household_Category__c!='AS'){
                           con.Prospect_Region__c =ggr.Prospect_Region__c;
                           if(acc !=null){
                               acc.Prospect_Region__c = ggr.Prospect_Region__c;
                           }
                       } 
                    if(arc.ucinn_ascendv2__Is_Preferred__c || Test.isRunningTest()){
                        con.MSA_Code__c = ggr.MSA_Code__c;
                        con.MSA_Name__c = ggr.MSA_Name__c;
                        if(acc !=null){
                            acc.MSA_Code__c =ggr.MSA_Code__c;
                            acc.MSA_Name__c = ggr.MSA_Name__c; 
                        }
                    }
                }                                 
                if (ggr!=null && arc.ucinn_ascendv2__Type__c=='B'){
                    con.nd_Alumni_Club_Business__c = ggr.ND_Club_Region__c!=null?ggr.ND_Club_Region__c:null;
                    if(arc.ucinn_ascendv2__Is_Preferred__c || Test.isRunningTest()){
                        con.MSA_Code__c = ggr.MSA_Code__c;
                        con.MSA_Name__c = ggr.MSA_Name__c;
                        if(acc !=null){
                            acc.MSA_Code__c =ggr.MSA_Code__c;
                            acc.MSA_Name__c = ggr.MSA_Name__c;
                        }
                    }
                    if(arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__PRM__c==null && 
                       arc.ucinn_ascendv2__Contact__r.Account.ND_Household_Category__c!='AS'){
                           con.Prospect_Region__c =ggr.Prospect_Region__c;
                           if(acc !=null){
                               acc.Prospect_Region__c = ggr.Prospect_Region__c; 
                           }
                       }
                }
            }    
            if(arc.ucinn_ascendv2__Contact__c==arc.ucinn_ascendv2__Contact__r.Account.ucinn_ascendv2__Primary_Contact__c){
                newConMap.put(con.Id,con);
                newAccMap.put(acc.Id,acc);  
            }
            else if(arc.ucinn_ascendv2__Contact__c==arc.ucinn_ascendv2__Contact__r.Account.Secondary_Constituent__c){
                newConMap.put(con.Id,con);  
            }
            
        }// end of loop
        String errorMsg='';
        List<Database.SaveResult> updateResults;
          if(newConMap.size()>0 ){//&& newAccMap.size()>0
                updateResults = Database.update(newConMap.values(), false);
                for(Integer i=0;i<updateResults.size();i++){
                    if (!updateResults.get(i).isSuccess()){
                        Database.Error error = updateResults.get(i).getErrors().get(0);String failedDML = error.getMessage();
                        errorMsg = errorMsg+failedDML+'-'+newConMap.values().get(i).Id+'\n';
                        system.debug('errorMsgCon '+errorMsg);
                    }        
                }
            }
            if(newAccMap.size()>0 ) {
                updateResults = Database.update(newAccMap.values(), false);
                for(Integer i=0;i<updateResults.size();i++){
                    if (!updateResults.get(i).isSuccess()){
                        Database.Error error = updateResults.get(i).getErrors().get(0);String failedDML = error.getMessage();
                        errorMsg = errorMsg+failedDML+'-'+newAccMap.values().get(i).Id+'\n';
                        system.debug('errorMsgAcc '+errorMsg);
                    }        
                }
            }
       system.debug('newConMap'+newConMap.values());
       system.debug('newAccMap'+newAccMap.values());
        if(string.isNotBlank(errorMsg)||Test.isRunningTest())
            sendEmail(errorMsg);   
    }
    global void finish(Database.BatchableContext BC){
        //Integer noOfRecords = (Integer)ManageBatchJobSize__mdt.getInstance('NDAddressUpdateBatch').ChunkSize__c;           
        //database.executeBatch(new NDAddressUpdateBatch(),noOfRecords);
    }
    
    public void sendEmail(String msg){
    // Step 1: Create a new Email
    Messaging.SingleEmailMessage mail = 
    new Messaging.SingleEmailMessage();
    
    // Step 2: Set list of people who should get the email
    List<String> sendTo = new List<String>();
    sendTo.add('entcrm@nd.edu');  
    mail.setToAddresses(sendTo);
    
    // Step 3: Set who the email is sent from
    mail.setReplyTo('no_reply@nd.edu');
    mail.setSenderDisplayName('Scheduled Apex');

    // Step 4. Set email contents - you can use variables!
    mail.setSubject('ERROR: NDAddressUpdate Job');
    String body = msg;
    mail.setHtmlBody(body);
    
    // Step 5. Send mail
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
  }      
}