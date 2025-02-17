global class GiftInterimBatch implements Database.Batchable<sObject>,  Database.Stateful{

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'select id from ucinn_ascendv2__Review_Transaction_v2__c where nd_RecordType_DeveloperName__c = \'General_Transaction\' and ucinn_ascendv2__Interim__c = null and ucinn_ascendv2__Status__c =\'Manual Review\' and nd_process_status__c in ( \'New\', \'Error\') and ucinn_ascendv2__Transaction_Type__c not in (\'Recurring Gift\') and ND_Pipeline__c != null  '

        );
    }
    global void execute(Database.BatchableContext bc, List<ucinn_ascendv2__Review_Transaction_v2__c> scope){ 

        List<ucinn_ascendv2__Review_Transaction_v2__c> lockedRows = [Select id,  ucinn_ascendv2__External_System_ID__c, nd_Ticket_ID__c,
            ucinn_ascendv2__Donor_External_ID__c, nd_organization_external_id__c, ucinn_ascendv2__First_Name__c, ucinn_ascendv2__Address_1_Type__c, ucinn_ascendv2__Last_Name__c,
            ucinn_ascendv2__Middle_Name__c,  ucinn_ascendv2__Address_1_Line_1__c,ucinn_ascendv2__Address_1_Line_2__c, ucinn_ascendv2__City_1__c, ucinn_ascendv2__Country_1__c,  ucinn_ascendv2__State_1__c,
            ucinn_ascendv2__Postal_Code_1__c, ucinn_ascendv2__Phone_1__c, ucinn_ascendv2__Phone_1_Type__c, ucinn_ascendv2__Email_1__c, nd_spouse_first_name__c,nd_gift_comment__c,
            ucinn_ascendv2__Email_1_Type__c, nd_spouse_last_name__c, nd_notre_dame_class_year__c, nd_process_message__c, nd_gift_source__c, nd_data_source__c,ucinn_ascendv2__Opportunity_Type__c,ND_Notes__c, ucinn_ascendv2__Response__c,
            nd_relationship_with_notre_dame__C, nd_process_status__c, nd_Appeal__c, nd_appeal_code__c, nd_skip_interim__c, NDID__c, ucinn_ascendv2__Tributee_1__c, give_campus_ndac__c, In_Honor_of__c, In_Memory_of__c, ucinn_ascendv2__Transaction_Type__c, ucinn_ascendv2__Opportunity_External_ID__c
            from ucinn_ascendv2__Review_Transaction_v2__c where Id IN :scope FOR UPDATE 
        ];
        String invalidNumbers = '[^0-9]';
        list<ucinn_ascendv2__Interim__c> intToAdd = new List<ucinn_ascendv2__Interim__c>();
		Boolean valid_appeal; 
        for(ucinn_ascendv2__Review_Transaction_v2__c rt : lockedRows) {
            if(rt.ucinn_ascendv2__Donor_External_ID__c != null ){
                list <Contact> person = [SELECT  id  from contact where ucinn_ascendv2__Donor_ID__c = :rt.ucinn_ascendv2__Donor_External_ID__c limit 1];
                if (person.size() > 0) {
                    rt.ucinn_ascendv2__Contact__c = person[0].id;
                }
            }else {
                if(rt.nd_organization_external_id__c != null){
                    list <Account> business = [SELECT  id  from Account where ucinn_ascendv2__Donor_ID__c = :rt.nd_organization_external_id__c limit 1];
                    if (business.size() > 0) {
                        rt.ucinn_ascendv2__Account__c = business[0].id;
                    }
                }
            }
            if(rt.nd_gift_source__c == 'Giving Form'  && rt.ucinn_ascendv2__Response__c != null){
                rt.ucinn_ascendv2__Address_1_Type__c = 'H';
                rt.ucinn_ascendv2__Email_1_Type__c = 'M';
                rt.ucinn_ascendv2__Phone_1_Type__c = 'M';
                rt.ND_Notes__c =  rt.nd_gift_comment__c;
                if (rt.give_campus_ndac__c != null){
                    rt.nd_appeal_code__c = rt.give_campus_ndac__c;
                }
                if (rt.In_Memory_of__c != null && rt.In_Honor_of__c != null ){
                    rt.ucinn_ascendv2__Tributee_1__c =  rt.In_Honor_of__c + ' and in memory of ' + rt.In_Memory_of__c;
                    rt.ucinn_ascendv2__Tribute_Type_1__c ='H';
                }else if (rt.In_Honor_of__c != null ){
                    rt.ucinn_ascendv2__Tributee_1__c = rt.In_Honor_of__c;
                    rt.ucinn_ascendv2__Tribute_Type_1__c ='H';
                }else if(rt.In_Memory_of__c != null){
                    rt.ucinn_ascendv2__Tributee_1__c =  rt.In_Memory_of__c;
                    rt.ucinn_ascendv2__Tribute_Type_1__c ='M';
                }
                if(rt.ucinn_ascendv2__Transaction_Type__c == 'Recurring Gift Payment' && rt.ucinn_ascendv2__Response__c != null ){
                    Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(rt.ucinn_ascendv2__Response__c);
                    Map<String, Object> subscription = (Map<String, Object>) parsedJson.get('subscription');
                    String Periodicity = (String) subscription.get('period');
                    if(Periodicity == 'monthly'){
                        rt.nd_Recurring_Periodicity__c = 12;
                        }else if(Periodicity == 'yearly'){
                        rt.nd_Recurring_Periodicity__c = 1;
                        }
                        else if(Periodicity == 'weekly'){
                        rt.nd_Recurring_Periodicity__c = 52;
                        }
                        else if(Periodicity == 'six_months'){
                        rt.nd_Recurring_Periodicity__c = 2;
                        }
                        else if(Periodicity == 'three_months'){
                        rt.nd_Recurring_Periodicity__c = 4;
                        }
                    rt.nd_parent_initial_transaction_id__c =String.valueOf((integer) subscription.get('id'));
                    Boolean lifelong_payment_enabled = (Boolean) subscription.get('indefinite ');
                    if((String) subscription.get('installment_number') == '1'){
                        rt.nd_initial_recurring_transaction_ind__c = true;
                        }
                    rt.ucinn_ascendv2__Transaction_Type__c = null;
                    rt.nd_Pledge_Gift_Type__c = null;
                    rt.nd_recurring_transaction_Ind__c = true;
                    rt.ucinn_ascendv2__Opportunity_External_ID__c = null;
                    rt.ucinn_ascendv2__Opportunity_Type__c = null;
                }
            }
            valid_appeal = true;


            if((rt.nd_Appeal__c == null && rt.nd_appeal_code__c != null) || rt.give_campus_ndac__c != null){

                list <Campaign> appeals = [SELECT ID, ND_Campaign_Code__c, Parent.nd_Data_Source__c   FROM Campaign where ucinn_ascendv2__Motivation_Code__c = :rt.nd_appeal_code__c and nd_campaign_record_type_dev_name__c = 'Appeal'  ];
                if (appeals.size() <1 ){
                    valid_appeal = false;
                }else{
                    rt.nd_Appeal__c = appeals[0].id;
                    if (rt.nd_gift_source__c =='Giving Form' && appeals[0].Parent.nd_Data_Source__c != null){
                        rt.nd_Data_Source__c = appeals[0].Parent.nd_Data_Source__c;
                    }
                }
            }

            if( valid_appeal && rt.nd_skip_interim__c != true){
                ucinn_ascendv2__Interim__c ic = new ucinn_ascendv2__Interim__c();
                if(rt.ucinn_ascendv2__Phone_1__c != null){
                    string home_phone = rt.ucinn_ascendv2__Phone_1__c.replaceAll( invalidNumbers, '' );
                    ic.ucinn_ascendv2__Phone_1__c =  home_phone ;
                    if (rt.ucinn_ascendv2__Phone_1_Type__c != null){
                        ic.ucinn_ascendv2__Phone_1_Type__c = rt.ucinn_ascendv2__Phone_1_Type__c;
                        ic.ND_Phone_1_Type__c = rt.ucinn_ascendv2__Phone_1_Type__c;
                    }else{
                        ic.ucinn_ascendv2__Phone_1_Type__c = 'M';
                        ic.ND_Phone_1_Type__c = 'M';
                    }
                    ic.ND_Phone_1_Data_Source_Abbrev__c = rt.nd_data_source__c;
                    ic.ND_Phone_1_Status__c       ='Current';
                }
                ic.ucinn_ascendv2__First_Name__c = rt.ucinn_ascendv2__First_Name__c;
                ic.ucinn_ascendv2__Middle_Name__c = rt.ucinn_ascendv2__Middle_Name__c;
                ic.ucinn_ascendv2__Last_Name__c = rt.ucinn_ascendv2__Last_Name__c ;
                ic.ucinn_ascendv2__Address_1_Line_1__c =  rt.ucinn_ascendv2__Address_1_Line_1__c ;
                if (ic.ucinn_ascendv2__Address_1_Line_1__c != null){
                    ic.ucinn_ascendv2__Address_1_Line_2__c =  rt.ucinn_ascendv2__Address_1_Line_2__c ;
                    ic.ucinn_ascendv2__City_1__c  = rt.ucinn_ascendv2__City_1__c;
                    ic.ucinn_ascendv2__Country_1__c =  rt.ucinn_ascendv2__Country_1__c ;
                    /*if (ic.ucinn_ascendv2__Country_1__c == 'United States'){
                        ic.ucinn_ascendv2__Country_1__c = 'US';
                    }*/
                    ic.ucinn_ascendv2__State_1__c  = rt.ucinn_ascendv2__State_1__c ;
                    ic.ucinn_ascendv2__Postal_Code_1__c = rt.ucinn_ascendv2__Postal_Code_1__c ;
                    ic.ND_Address_1_Type__c = rt.ucinn_ascendv2__Address_1_Type__c;
                    if (rt.ucinn_ascendv2__Address_1_Type__c != null){
                        ic.ND_Address_1_Type__c = rt.ucinn_ascendv2__Address_1_Type__c;
                    }else{
                        ic.ND_Address_1_Type__c = 'H';
                    }
                    ic.ND_Address_1_Data_Source_Abbrev__c = rt.nd_data_source__c;
                }
                ic.ucinn_ascendv2__Email_1__c = rt.ucinn_ascendv2__Email_1__c ;
                if(ic.ucinn_ascendv2__Email_1__c != null ){
                    //ic.ucinn_ascendv2__Preferred_Email__c = 'Email 1';
                    ic.ND_Preferred_Email_1__c = true;
                    ic.ND_Email_1_Status__c = 'Current' ;
                    ic.ND_Email_1_Type__c = rt.ucinn_ascendv2__Email_1_Type__c;
                    if (rt.ucinn_ascendv2__Email_1_Type__c != null){
                        ic.ND_Email_1_Type__c = rt.ucinn_ascendv2__Email_1_Type__c;
                    }else{
                        ic.ND_Email_1_Type__c = 'M';
                    }
                    ic.ND_Email_1_Data_Source__c = rt.nd_data_source__c;
                }
                ic.nd_Spouse_First_Name__c = rt.nd_spouse_first_name__c ; // or should it be ic.nd_spouse_first_name 
                ic.nd_Spouse_Last_Name__c = rt.nd_spouse_last_name__c ; // or should it be ic.nd_spouse_last_name
                ic.nd_notre_dame_class_year__c = rt.nd_notre_dame_class_year__c;
                ic.nd_relationship_with_notre_dame__C = rt.nd_relationship_with_notre_dame__C ;
                ic.ucinn_ascendv2__Donor_ID__c = rt.ucinn_ascendv2__Donor_External_ID__c;
                ic.ND_Banner_Id__c = String.valueOf(rt.NDID__c);
                ic.nd_Constituent_Status__c = 'Active';
                ic.ucinn_ascendv2__External_System_ID__c	  = 'PRAX-' + rt.ucinn_ascendv2__external_system_id__c;
                ic.name  = 'INT-' + rt.ucinn_ascendv2__external_system_id__c;
                ic.Tributee__c = rt.ucinn_ascendv2__Tributee_1__c;
                ic.ucinn_ascendv2__Status__c = 'Gift Interim';
                //ic.ucinn_ascendv2__Related_Interim_1__c = ic.name + '-Spouse';
                ic.ND_data_source_code__c = rt.nd_data_source__c;
                //ic.nd_Affiliation_Data_Source_1__c = rt.nd_data_source__c;
                ic.nd_Ticket_ID__c = rt.nd_Ticket_ID__c;
                if (ic.nd_Ticket_ID__c != null){
                    ic.ND_Alternate_ID_Type_2__c ='TIK';
                }

                


                
                if (rt.nd_Spouse_First_Name__c != null){
                    ucinn_ascendv2__Interim__c spouse_ic = new ucinn_ascendv2__Interim__c();    
                    spouse_ic.ucinn_ascendv2__First_Name__c = ic.nd_Spouse_First_Name__c ;
                    spouse_ic.ucinn_ascendv2__Last_Name__c = ic.nd_spouse_last_name__c ;
                    spouse_ic.ucinn_ascendv2__Address_1_Line_1__c =  ic.ucinn_ascendv2__Address_1_Line_1__c ;
                    spouse_ic.ucinn_ascendv2__Address_1_Line_2__c =  ic.ucinn_ascendv2__Address_1_Line_2__c ;
                    spouse_ic.ucinn_ascendv2__City_1__c  = rt.ucinn_ascendv2__City_1__c;
                    spouse_ic.ucinn_ascendv2__Country_1__c =  ic.ucinn_ascendv2__Country_1__c ;
                    spouse_ic.ucinn_ascendv2__State_1__c  = ic.ucinn_ascendv2__State_1__c ;
                    spouse_ic.ucinn_ascendv2__Postal_Code_1__c = ic.ucinn_ascendv2__Postal_Code_1__c ;
                    spouse_ic.ND_Address_1_Type__c = ic.ND_Address_1_Type__c;
                    spouse_ic.nd_Constituent_Status__c = 'Active';
                    spouse_ic.Name = ic.name + '-Spouse';
                    spouse_ic.ucinn_ascendv2__External_System_ID__c	 = ic.ucinn_ascendv2__External_System_ID__c + '-Spouse';
                    spouse_ic.ND_data_source_code__c = ic.ND_data_source_code__c;
                    spouse_ic.ND_Address_1_Data_Source_Abbrev__c = ic.ND_Address_1_Data_Source_Abbrev__c;
                    spouse_ic.ucinn_ascendv2__Phone_1__c = ic.ucinn_ascendv2__Phone_1__c;
                    spouse_ic.ND_Phone_1_Data_Source_Abbrev__c = ic.ND_Phone_1_Data_Source_Abbrev__c;
                    spouse_ic.ND_Phone_1_Type__c = ic.ND_Phone_1_Type__c;
                    spouse_ic.ND_Phone_1_Status__c = ic.ND_Phone_1_Status__c;
                    spouse_ic.ucinn_ascendv2__Status__c = 'Gift Interim';
                    ic.ucinn_ascendv2__Relationship_1_Related_Role__c ='Spouse';
                    ic.ucinn_ascendv2__Related_Interim_1__c = spouse_ic.ucinn_ascendv2__External_System_ID__c;
                    ic.ND_Merge_Option__c = 'Move Constituent';
                    ic.ND_Apply_Soft_Credit_1__c = true;
                    intToAdd.add(spouse_ic);  
                }     
                intToAdd.add(ic);
            } 
        }
         
        try {
           insert intToAdd;   
           for(ucinn_ascendv2__Review_Transaction_v2__c rt : lockedRows) {
                Boolean interim_created = false; 
                for(ucinn_ascendv2__Interim__c ic : intToAdd) {
                    if(ic.ucinn_ascendv2__External_System_ID__c == 'PRAX-' + rt.ucinn_ascendv2__external_system_id__c){
                        rt.ucinn_ascendv2__Interim__c = ic.id;
                        rt.nd_process_status__c = 'Waiting'; 
                        rt.nd_process_message__c = 'Interim created.';
                        interim_created = true;                      
                    }
                }
                if (interim_created == false && rt.nd_skip_interim__c){
                    rt.nd_process_status__c = 'skip interim';
                    rt.nd_process_message__c += ' This record does not require an interim';
                } else if (interim_created == false){
                    rt.nd_process_status__c = 'Error' ;
                    rt.nd_process_message__c = 'This RTV2 record includes an appeal code that is either inactive or does not exist. Matching will not commence until it is updated.';
                }
            }
           update lockedRows;
        }
        catch (Exception error){ 
            system.debug('this is an error message ' + error);
            //create an error message field and save the error.getmessage
            //create a nd_status error field and save the state
        }
    }
      global void finish(Database.BatchableContext bc){ 
      	asc_SCHED_Address_Verification schedule = new asc_SCHED_Address_Verification();
		Map<String, String> addressFieldMap = new Map<String, String>();
		addressFieldMap.put('addressLine1', 'ucinn_ascendv2__Address_1_Line_1__c');
		addressFieldMap.put('addressLine2','ucinn_ascendv2__Address_1_Line_2__c');
		addressFieldMap.put('city', 'ucinn_ascendv2__City_1__c');
		addressFieldMap.put('state', 'ucinn_ascendv2__State_1__c');
		addressFieldMap.put('postalCode', 'ucinn_ascendv2__Postal_Code_1__c');
		addressFieldMap.put('country', 'ucinn_ascendv2__Country_1__c');
		addressFieldMap.put('request', 'ucinn_ascendv2__Address_Verification_API_Request__c');
		addressFieldMap.put('response', 'ucinn_ascendv2__Address_Verification_API_Response__c');
        addressFieldMap.put('isVerified', 'ucinn_ascendv2__Is_Verified__c');
        addressFieldMap.put('verificationSource', 'ucinn_ascendv2__Verification_Source__c');
       	addressFieldMap.put('verificationResponse', 'ucinn_ascendv2__Verification_Response__c');
       	addressFieldMap.put('dataSource', 'ucinn_ascendv2__Data_Source__c');
       	addressFieldMap.put('latitude', 'ucinn_ascendv2__Geolocation_1__Latitude__s');
       	addressFieldMap.put('longitude', 'ucinn_ascendv2__Geolocation_1__Longitude__s');
       	addressFieldMap.put('county','nd_County_Name__c');
		schedule.objParam = 'ucinn_ascendv2__Interim__c';
		schedule.batchSize = 75;
		schedule.whereClause = 'ND_Address_Verification_Processed__c = false and ucinn_ascendv2__Country_1__c != null ';
		schedule.addressFieldMap = addressFieldMap;
        Set<String> matchCodeSet = new Set<String>{'Y','N','S','D',null};
       	Set<String> vacantSet = new Set<String>{'N','Y',null};
       	Set<String> verificationStatusSet = new Set<String>{'Verified'};
       	Set<String> addressPrecisionSet = new Set<String>{'Premise', 'DeliveryPoint'};

        Map<String, Set<String>> uspsParam = new Map<String, Set<String>>();
      	uspsParam.put('ucinn_ascendv2__DPV_Match_Code__c', matchCodeSet);
       	uspsParam.put('ucinn_ascendv2__DPV_Vacant__c', vacantSet);
            
      	Map<String, Set<String>> internationalParam = new Map<String, Set<String>>();
       	internationalParam.put('ucinn_ascendv2__Verification_Status__c', verificationStatusSet);
       	internationalParam.put('ucinn_ascendv2__Address_Precision__c', addressPrecisionSet);
       	if(!Test.isRunningTest()) {
			ucinn_ascendv2.ascend_UTIL_RunBatch.ascend_ADDR_VerifyAddrSmartyStreetsBatch(schedule.whereClause, 
                                                                                     uspsParam,                                                                                  
                                                                                     internationalParam, 
                                                                                     schedule.objParam, 
                                                                                     addressFieldMap, 
                                                                                     schedule.batchSize);
          }
       
    }   
    
}