global class ND_RTV2_Processing implements Database.Batchable<sObject>,  Database.Stateful{

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            select id from ucinn_ascendv2__Review_Transaction_v2__c where nd_RecordType_DeveloperName__c = 'General_Transaction'
             and (ucinn_ascendv2__Contact__c != null or ucinn_ascendv2__Account__c != null )  and ucinn_ascendv2__Status__c ='Manual Review' 
             and  nd_process_status__c != 'Done' and ucinn_ascendv2__Transaction_Type__c  not in ('Recurring Gift', 'Recurring Gift Payment') and ND_Pipeline__c != null
        ]);
    }

    public decimal ifnull(decimal num ) {
        if (num == null){num = 0;} 
        return num;
    }

    global static string CheckYA(String currDes, double desAmount, Integer yearsGrad, list<ND_Young_Alumni_Designation_Chart__c> yaChart){
        String des = currDes;
        for (ND_Young_Alumni_Designation_Chart__c ya : yaChart){
            if(currDes == ya.Unrestricted_Designation__c && ya.Min_years_since_graduation__c <= yearsGrad && ya.Max_years_since_graduation__c >= yearsGrad && desAmount >= ya.Unrestricted_threshold__c){
                des = ya.Rec_Soc_Designation__c;
            }
        }

        return des;
    }

    global void execute(Database.BatchableContext bc, List<ucinn_ascendv2__Review_Transaction_v2__c> scope){ 
        List<ucinn_ascendv2__Review_Transaction_v2__c> lockedRows = [Select id, nd_spouse_first_name__c, ucinn_ascendv2__Hard_and_Soft_Credit_Contact_1_1__c, ucinn_ascendv2__Hard_and_Soft_Credit_Amount_1_1__c, ucinn_ascendv2__Hard_Soft_Credit_Contact_External_ID_1_1__c, ucinn_ascendv2__Hard_and_Soft_Credit_Type_1_1__c,  nd_Total_Recurring_Amount__c, ucinn_ascendv2__Payment_Date_1_1__c, nd_spouse_last_name__c, ucinn_ascendv2__Tender_Type_1__c, ucinn_ascendv2__Total_Transaction_Amount__c, nd_appeal_code__c, nd_Appeal__c, nd_process_status__c, ucinn_ascendv2__In_Memory_Honor_First_Name_1__c, nd_process_message__c, nd_gift_group__c, ucinn_ascendv2__Transaction_Type__c, ucinn_ascendv2__Designation_1__c, ucinn_ascendv2__Designation_2__c, ucinn_ascendv2__Designation_3__c, ucinn_ascendv2__Designation_4__c, ucinn_ascendv2__Designation_5__c, Designation_6__c, Designation_7__c, Designation_8__c, Designation_9__c, Designation_10__c, ucinn_ascendv2__Status__c, ucinn_ascendv2__Contact__c, ucinn_ascendv2__Comments_v1__c,ucinn_ascendv2__Campaign__c, ucinn_ascendv2__Interim__c, nd_gift_comment__c, ucinn_ascendv2__Designation_External_ID_1__c, ucinn_ascendv2__Designation_External_ID_2__c, ucinn_ascendv2__Designation_External_ID_3__c, ucinn_ascendv2__Designation_External_ID_4__c, ucinn_ascendv2__Designation_External_ID_5__c, ucinn_ascendv2__Transaction_Date__c, ND_Pipeline__c,  Designation_External_ID_6__c, Designation_External_ID_7__c, Designation_External_ID_8__c, Designation_External_ID_9__c, Designation_External_ID_10__c, ucinn_ascendv2__Payment_Amount_1_1__c, ucinn_ascendv2__Payment_Amount_2_1__c, ucinn_ascendv2__Payment_Amount_3_1__c, ucinn_ascendv2__Payment_Amount_4_1__c, ucinn_ascendv2__Payment_Amount_5_1__c, Payment_Amount_6_1__c, Payment_Amount_7_1__c, Payment_Amount_8_1__c, Payment_Amount_9_1__c, Payment_Amount_10_1__c, ucinn_ascendv2__Account__c, ucinn_ascendv2__Tributee_1__c from ucinn_ascendv2__Review_Transaction_v2__c where Id IN :scope FOR UPDATE ];
        //system.debug('lockedRows' + lockedRows);
        list<ucinn_ascendv2__Review_Transaction_v2__c> rtv2ToUpdate = new List<ucinn_ascendv2__Review_Transaction_v2__c>();
        list<ucinn_ascendv2__Review_Transaction_v2__c> rtv2ToPost = new List<ucinn_ascendv2__Review_Transaction_v2__c>();
        list<ND_Young_Alumni_Designation_Chart__c> yaChart = [select Max_years_since_graduation__c, Min_years_since_graduation__c, Rec_Soc_Designation__c, Unrestricted_Designation__c, Unrestricted_threshold__c from ND_Young_Alumni_Designation_Chart__c  ];
        //Set<String> desExIDCol = new Set<String>{'ucinn_ascendv2__Designation_External_ID_1__c', 'ucinn_ascendv2__Designation_External_ID_2__c', 'ucinn_ascendv2__Designation_External_ID_3__c', 'ucinn_ascendv2__Designation_External_ID_4__c', 'ucinn_ascendv2__Designation_External_ID_5__c', 'Designation_External_ID_6__c', 'Designation_External_ID_7__c', 'Designation_External_ID_8__c', 'Designation_External_ID_9__c' , 'Designation_External_ID_10__c'};

        for(ucinn_ascendv2__Review_Transaction_v2__c rt : lockedRows) {
        	Map<Integer, String> desExIDCols = new Map<Integer, String>{1 => 'ucinn_ascendv2__Designation_External_ID_1__c', 2 => 'ucinn_ascendv2__Designation_External_ID_2__c', 3 => 'ucinn_ascendv2__Designation_External_ID_3__c', 4 => 'ucinn_ascendv2__Designation_External_ID_4__c', 5 => 'ucinn_ascendv2__Designation_External_ID_5__c', 6 => 'Designation_External_ID_6__c', 7 => 'Designation_External_ID_7__c', 8 => 'Designation_External_ID_8__c', 9 => 'Designation_External_ID_9__c', 10 => 'Designation_External_ID_10__c'};
        	Map<Integer, String> desIDCols = new Map<Integer, String>{1 => 'ucinn_ascendv2__Designation_1__c', 2 => 'ucinn_ascendv2__Designation_2__c', 3 => 'ucinn_ascendv2__Designation_3__c', 4 =>'ucinn_ascendv2__Designation_4__c', 5 => 'ucinn_ascendv2__Designation_5__c', 6 => 'Designation_6__c', 7 => 'Designation_7__c', 8 => 'Designation_8__c', 9 => 'Designation_9__c' , 10 => 'Designation_10__c'};                   
        	Map<Integer, String> paymentCols = new Map<Integer, String>{1 => 'ucinn_ascendv2__Payment_Amount_1_1__c', 2 => 'ucinn_ascendv2__Payment_Amount_2_1__c', 3 => 'ucinn_ascendv2__Payment_Amount_3_1__c', 4 =>'ucinn_ascendv2__Payment_Amount_4_1__c', 5 => 'ucinn_ascendv2__Payment_Amount_5_1__c', 6 => 'Payment_Amount_6_1__c', 7 => 'Payment_Amount_7_1__c', 8 => 'Payment_Amount_8_1__c', 9 => 'Payment_Amount_9_1__c' , 10 => 'Payment_Amount_10_1__c'};                   
            Campaign campaign;
            Boolean recordValid = true;
            Boolean missingData = false;
            boolean donor_is_alumni = false;
            boolean donor_spouse_is_alumni = false;
            Decimal totalDesignations = 0.00;
            Boolean shouldPost = false;
            Boolean is_business = false; 
            contact donor = new contact();
            string appealNote;
            id donor_id;
            list <ucinn_ascendv2__Society_Membership__c> societies = new List<ucinn_ascendv2__Society_Membership__c>();
            list <Opportunity> pledges= new List<Opportunity>();
            list <Knowtify_Comment__c> alert = new List<Knowtify_Comment__c>();
            rt.nd_process_message__c = '';

            if(rt.nd_Appeal__c == null && rt.nd_appeal_code__c != null){
                list <Campaign> appeal = [SELECT ID, ND_Campaign_Code__c, gift_processing_note__c  FROM Campaign where ucinn_ascendv2__Motivation_Code__c = :rt.nd_appeal_code__c and nd_campaign_record_type_dev_name__c = 'Appeal' ];
                if(appeal.size()> 0){
                    rt.nd_appeal__c = appeal[0].id;
                    appealNote =  appeal[0].gift_processing_note__c;
                    system.debug(' line 58 appeal note is ' + appealNote);
                }
                else {
                    missingData = true;
                    rt.nd_process_message__c +='Appeal does not exist. ';
                }
            }else if(rt.nd_Appeal__c != null){
                list <Campaign> appeal2 = [SELECT ID, ND_Campaign_Code__c, gift_processing_note__c  FROM Campaign where id = :rt.nd_Appeal__c and nd_campaign_record_type_dev_name__c = 'Appeal'  ];
                appealNote =  appeal2[0].gift_processing_note__c;
                system.debug(' line 67 appeal note is ' + appealNote);
            }

            if(appealNote != null){
                if(rt.nd_gift_comment__c != null && !rt.nd_gift_comment__c.contains(appealNote) ){
                	rt.nd_gift_comment__c = appealNote + ' ' + rt.nd_gift_comment__c;
             		system.debug(' line 72 gift comment ' + rt.nd_gift_comment__c);
                }else {
                    rt.nd_gift_comment__c = appealNote;
                }
            }
/*
            if (rt.ucinn_ascendv2__Campaign__c == null) { // put in the default campaign code
                campaign =[SELECT ID, ND_Campaign_Code__c  from Campaign where  isactive = true and  nd_campaign_record_type_dev_name__c = 'Comprehensive_Campaign' and StartDate < :Date.today() and EndDate >= :Date.today()limit 1];
                rt.ucinn_ascendv2__Campaign__c = campaign.id;
            }*/

            if(rt.ucinn_ascendv2__Tender_Type_1__c == null || rt.ucinn_ascendv2__Transaction_Date__c == null){
                missingData = true;
            }
            donor_id = rt.ucinn_ascendv2__Contact__c;
            if (rt.ucinn_ascendv2__Account__c != null){
                is_business = true;
                if(rt.ucinn_ascendv2__Hard_and_Soft_Credit_Contact_1_1__c != null){
                    donor_id = rt.ucinn_ascendv2__Hard_and_Soft_Credit_Contact_1_1__c;
                    if(rt.ucinn_ascendv2__Hard_and_Soft_Credit_Type_1_1__c == null){
                        recordValid = false;
                        rt.nd_process_message__c += 'Hard/Soft credit type required when there is a B donor  ';
                    }
                } else{
                    recordValid = false;
                    rt.nd_process_status__c = 'Error';
                    rt.nd_process_message__c += 'B Donor not valid  ';
                }
            }
            if (donor_id != null){
                donor = [SELECT ucinn_ascendv2__Preferred_Spouse__c, id , Constituent_Status__c, ucinn_ascendv2__Degree_Year_Roll_Up__c, ucinn_ascendv2__Contact_Type__c,  ucinn_ascendv2__Earliest_Degree_Year_Roll_Up__c from contact where id = :donor_id limit 1];
                if(donor.ucinn_ascendv2__Contact_Type__c != null && donor.ucinn_ascendv2__Contact_Type__c.contains('AL')){
                    donor_is_alumni = true;
                }
                if(rt.nd_Spouse_First_Name__c != null && rt.ucinn_ascendv2__Interim__c != null){ 
                    if (donor.ucinn_ascendv2__Preferred_Spouse__c != null){
                    //make sure that the spouse interim constitutent matches the contacts spouse
                        ucinn_ascendv2__Interim__c dInterim = [select ucinn_ascendv2__Related_Interim_1__c  from ucinn_ascendv2__Interim__c where id = :rt.ucinn_ascendv2__Interim__c limit 1];
                        list<ucinn_ascendv2__Interim__c> spouseInterim = [select ucinn_ascendv2__Contact__c from ucinn_ascendv2__Interim__c where  ucinn_ascendv2__External_System_ID__c = :dInterim.ucinn_ascendv2__Related_Interim_1__c limit 1];
                        if(spouseInterim.size() > 0 && (spouseInterim[0].ucinn_ascendv2__Contact__c != donor.ucinn_ascendv2__Preferred_Spouse__c)){
                            recordValid = false;
                            rt.nd_process_status__c = 'Waiting';
                            rt.nd_process_message__c += 'Spouse Interim does not match the spouse on the constituent record. ';
                        }
                    } else {
                        recordValid = false;
                        rt.nd_process_status__c = 'Waiting';
                        rt.nd_process_message__c += 'Gift came in with a spouse but the constituent record has no spouse. ';
                    }         
                }
            }
            for(Integer key : desExIDCols.keySet()){
                totalDesignations = totalDesignations + ifnull((decimal)rt.get(paymentCols.get(key)));
                //system.debug('des '+ rt.get(desIDCols.get(key)) + ' amount ' +rt.get(paymentCols.get(key)) );
                if (rt.get(paymentCols.get(key)) != null && rt.get(desIDCols.get(key)) == null ){
                    rt.nd_process_message__c += 'Payment amount ' + key +' assigned without a valid designation. The user entered designation code is ' + rt.get(desExIDCols.get(key)) + ' ' ;
                    rt.nd_process_status__c = 'Error';
                    recordValid = false;
                }
            }
           // totalDesignations =  ifnull(rt.ucinn_ascendv2__Payment_Amount_1_1__c) +  ifnull(rt.ucinn_ascendv2__Payment_Amount_2_1__c) +  ifnull(rt.ucinn_ascendv2__Payment_Amount_3_1__c) +  ifnull(rt.ucinn_ascendv2__Payment_Amount_4_1__c) +  ifnull(rt.ucinn_ascendv2__Payment_Amount_5_1__c) +  ifnull(rt.Payment_Amount_6_1__c) + ifnull(rt.Payment_Amount_7_1__c) +  ifnull(rt.Payment_Amount_8_1__c) +  ifnull(rt.Payment_Amount_9_1__c) +  ifnull(rt.Payment_Amount_10_1__c);
            if (rt.ucinn_ascendv2__Total_Transaction_Amount__c == null && totalDesignations > 0) {
                rt.ucinn_ascendv2__Total_Transaction_Amount__c = totalDesignations;
            }else if(rt.ucinn_ascendv2__Total_Transaction_Amount__c != totalDesignations){
                recordValid = false;
                rt.nd_process_message__c += 'The total amount of the gift does not equal the sum of all the designations ';
                rt.nd_process_status__c = 'Error';
            }

            if(rt.ucinn_ascendv2__Hard_Soft_Credit_Contact_External_ID_1_1__c != null && rt.ucinn_ascendv2__Hard_and_Soft_Credit_Amount_1_1__c == null){  //If there is a constitunet with a soft credit set the amount to the total
                rt.ucinn_ascendv2__Hard_and_Soft_Credit_Amount_1_1__c = rt.ucinn_ascendv2__Total_Transaction_Amount__c;
            }

            // set the designation for lockboc 

            if(rt.ND_Pipeline__c != null){
                Pipeline__mdt pipeline = Pipeline__mdt.getInstance(rt.ND_Pipeline__c);
                if(recordValid == true && pipeline.checkGiftGroups__c){
                /*remove hard code of nd_active_status and make it a set) */
                //giving society has to be active and exclude certain codes   select * from ucinn_ascendv2__Giving_Society__c  where ucinn_ascendv2__Status__c = 'Active' and nd_Hierarchy_Order__c = '15' and nd_Giving_Society_Code__c not in ( 'BADN', 'JGIA', 'WCRSR', 'WCRSD') 
                    Set<String> desExID = new Set<String>{rt.ucinn_ascendv2__Designation_External_ID_1__c, rt.ucinn_ascendv2__Designation_External_ID_2__c,rt.ucinn_ascendv2__Designation_External_ID_3__c,rt.ucinn_ascendv2__Designation_External_ID_4__c, rt.ucinn_ascendv2__Designation_External_ID_5__c, rt.Designation_External_ID_6__c, rt.Designation_External_ID_7__c, rt.Designation_External_ID_8__c, rt.Designation_External_ID_9__c , rt.Designation_External_ID_10__c};
                    Set<id> desID = new Set<id>{rt.ucinn_ascendv2__Designation_1__c, rt.ucinn_ascendv2__Designation_2__c,rt.ucinn_ascendv2__Designation_3__c,rt.ucinn_ascendv2__Designation_4__c, rt.ucinn_ascendv2__Designation_5__c, rt.Designation_6__c, rt.Designation_7__c, rt.Designation_8__c, rt.Designation_9__c , rt.Designation_10__c};                   
					system.debug('line 155 desEXID ' + desEXID);
                    list<ucinn_ascendv2__Designation__c> recSocDes=[ select name from ucinn_ascendv2__Designation__c where name in :desEXID and Unrestricted_Type__c = 'UNIVUNR'];

                    if (rt.nd_gift_group__c == null && pipeline.checkGiftGroupPP__c){
                        if(donor_id != null){
                            pledges= [ select name, id from opportunity where ucinn_ascendv2__Contact__c= :donor_id and StageName = 'Active' and ND_RecordType_DeveloperName__c='Pledge'];
                        }
                        boolean matchingDes = false;
                        if(pledges.size() > 0){
                           integer matchingPledgeCount = 0;
                           id matchingPledge = null;
                            for (Opportunity p: pledges){
                                list <ucinn_ascendv2__Designation_Detail__c> pledgeDesignations= [ select name, ucinn_ascendv2__Designation__c from ucinn_ascendv2__Designation_Detail__c where ucinn_ascendv2__Opportunity__c = :p.id and ucinn_ascendv2__Designation__c in :desid ];
                                /*for(ucinn_ascendv2__Designation_Detail__c pd: pledgeDesignations){
                                    if (desId.contains(pd.ucinn_ascendv2__Designation__c)){
                                        matchingDes = true;
                                    }
                                } */
                                if(pledgeDesignations.size() > 0 ){
                                    matchingPledgeCount += 1;
                                    matchingPledge = p.id;
                                }
                            }

                            if( matchingPledgeCount == 1){
                                rt.ucinn_ascendv2__Opportunity__c = matchingPledge;
                                rt.nd_process_message__c += 'An open pledge exists with this donor and has been set but requires review '; 
                                rt.nd_gift_group__c = 'PP';
                                rt.ucinn_ascendv2__Transaction_Type__c ='Pledge Payment';
                                //rt.ucinn_ascendv2__Opportunity_Type__c = 'Pledge Payment';
                                //rt.nd_Pledge_Gift_Type__c = 'Pledge Payment';
                            } else if (matchingPledgeCount > 1){
                                rt.nd_process_message__c += 'Multiple open pledges exist with this donor ';
                                rt.nd_gift_group__c = 'PP';
                                rt.ucinn_ascendv2__Transaction_Type__c ='Pledge Payment';
                                //rt.ucinn_ascendv2__Opportunity_Type__c = 'Pledge Payment';
                                //rt.nd_Pledge_Gift_Type__c = 'Pledge Payment';
                            }else {
                                rt.nd_gift_group__c = 'PP';
                                rt.nd_process_message__c += 'An open pledge exists with this donor but designations do not match ';
                                rt.ucinn_ascendv2__Transaction_Type__c ='Gift';
                                rt.ucinn_ascendv2__Opportunity_Type__c = 'Outright';
                                rt.nd_Pledge_Gift_Type__c = 'Outright';
                            }
                            
                        }
                    } 
                    if (rt.nd_gift_group__c == null && rt.ucinn_ascendv2__Tributee_1__c != null   && pipeline.checkGiftGroupHG__c){
                        rt.nd_gift_group__c = 'HG';
                        rt.nd_process_message__c += 'In memory name is filled and requires review.' ;
                    }

                    if (rt.nd_gift_group__c == null && donor.Constituent_Status__c == 'd' && pipeline.checkGiftGroupHG__c){
                        rt.nd_gift_group__c = 'HG';
                        rt.nd_process_message__c += 'Donor is deceased in system and requires review' ;
                    } 

                    if (rt.nd_gift_group__c == null && pipeline.checkGiftGroupWK__c)  {
                        if(is_business){
                            alert = [select Comment__c   from Knowtify_Comment__c where Organization__c = :rt.ucinn_ascendv2__Account__c and knowtify_critical__c = true and category__c = 'Gift Processing' and (knowtify_start_date__c <= :system.today() and (knowtify_end_date__c = null or knowtify_end_date__c >= :system.today())) ];
                        }else{
                            alert = [select Comment__c   from Knowtify_Comment__c where Constituent__c = :rt.ucinn_ascendv2__Contact__c  and knowtify_critical__c = true and category__c = 'Gift Processing' and (knowtify_start_date__c <= :system.today() and (knowtify_end_date__c = null or knowtify_end_date__c >= :system.today()))];
                        }
                        if (alert.size() > 0 ){
                            rt.nd_gift_group__c = 'WK';
                            rt.nd_process_message__c += 'Donor has a alert in the knowtify table ' ;
                        } 
                    }    
                    if(rt.nd_gift_group__c == null && rt.nd_gift_comment__c != null && pipeline.checkGiftGroupWC__c){
                            String lowercaseValue = rt.nd_gift_comment__c.toLowerCase();
                            lowercaseValue = lowercaseValue.replace('!', ''); // Remove exclamation points
                            lowercaseValue = lowercaseValue.trim(); // Remove trailing white spaces
                            if (!lowercaseValue.equals('go irish') && !lowercaseValue.equals('')) {
                                rt.nd_gift_group__c = 'WC';
                                rt.nd_process_message__c += ' Gift included comments that need review' ;
                            }
                    } 
                    
                    if (rt.nd_gift_group__c == null ) {
                        ND_RTV2_Process_Settings__mdt settings = ND_RTV2_Process_Settings__mdt.getInstance('GNRL');
                        List<String> codesList = settings.giving_society_exclude__c.split(',');
                        if(is_business){
                            societies = [select id from ucinn_ascendv2__Society_Membership__c where ucinn_ascendv2__Account__c = :rt.ucinn_ascendv2__Account__c and nd_Status__c in ('A') and ucinn_ascendv2__Giving_Society__r.nd_giving_society_code__c not in :codesList];
                        }else{
                            societies = [select id from ucinn_ascendv2__Society_Membership__c where ucinn_ascendv2__Contact__c = :rt.ucinn_ascendv2__Contact__c and nd_Status__c in ('A') and ucinn_ascendv2__Giving_Society__r.nd_giving_society_code__c not in :codesList];
                        }
                    }
                    if (rt.nd_gift_group__c == null && pipeline.checkGiftGroupAR__c) {
                        if (societies.size() > 1 && recSocDes.size() >0 ){ //check if gift is sent to the active rec societies
                            rt.nd_gift_group__c = 'AR';
                            rt.nd_process_message__c += ' Donor has multiple active recoginition societies' ;
                        } 
                    }    
                    /* no longer necessary 9/12/2023
                    if(rt.nd_gift_group__c == null && donor.ucinn_ascendv2__Preferred_Spouse__c != null && pipeline.checkGiftGroupMM__c){
                            Contact donorSpouse = [SELECT  id , Constituent_Status__c, ucinn_ascendv2__Earliest_Degree_Year_Roll_Up__c, ucinn_ascendv2__Contact_Type__c   from contact where id = :donor.ucinn_ascendv2__Preferred_Spouse__c limit 1];
                            list <ucinn_ascendv2__Society_Membership__c> spouseSocieties = [select id from ucinn_ascendv2__Society_Membership__c where ucinn_ascendv2__Contact__c = :donorSpouse.id and nd_Status__c in ('A') and ucinn_ascendv2__Giving_Society__r.nd_giving_society_code__c != 'BG' ];
                            system.debug('donor ' + donor_id + ' is donor alum '+ donor_spouse_is_alumni);
                            if(donorSpouse.ucinn_ascendv2__Contact_Type__c.contains('AL')){
                                donor_spouse_is_alumni = true;
                            }
                            if(donor_spouse_is_alumni &&  donor_is_alumni != true){
                                rt.nd_gift_group__c = 'MM';
                                rt.nd_process_message__c = rt.nd_process_message__c + ' Primary donor is not Alumni but Spouse is. ' ;
                            }
                            if(spouseSocieties.size() > 0 && societies.size() == 0){//spouse is a society member
                                rt.nd_gift_group__c = 'MM';
                                rt.nd_process_message__c = rt.nd_process_message__c + 'Spouse has a society membership. ' ;
                            }
                    } */
                        
                    if (rt.nd_gift_group__c == null && societies.size() == 1  && recSocDes.size() >= 1 && pipeline.checkGiftGroupAS__c){
                            // check the designations
                            system.debug(' line 266 societies is ' + societies);
                            system.debug(' line 267 recSocDes is ' + recSocDes);
                            rt.nd_gift_group__c= 'AS';
                            rt.nd_process_message__c += 'Donor has a society membership and gift designated to a society ' ;
                            //shouldPost = true;
                    }
                    if (rt.nd_gift_group__c == null && societies.size() < 1   && pipeline.checkGiftGroupRC__c && (rt.ucinn_ascendv2__Total_Transaction_Amount__c >= 1500 || rt.nd_Total_Recurring_Amount__c > 1500)){
                        
                        for(Integer key : desExIDCols.keySet()){
                            system.debug('des id ' + desExIDCols.get(key) + ' ' + rt.get(desExIDCols.get(key)));
                            if(rt.get(desExIDCols.get(key)) == 'UNRESTRICTED'){
                                rt.put(desExIDCols.get(key), 'SORIN SOCIETY');
                                rt.nd_gift_group__c = 'RC';
                                shouldPost = true;  
                                rt.put(desIDCols.get(key), null) ;
                            }
                        }
                            
                        
                    }

                    if ( donor_is_alumni && rt.nd_gift_group__c == null && donor.ucinn_ascendv2__Earliest_Degree_Year_Roll_Up__c != null && pipeline.checkGiftGroupYA__c){
                        Integer YearSinceGrad = System.Today().year() - integer.valueof(donor.ucinn_ascendv2__Earliest_Degree_Year_Roll_Up__c);

                        if( YearSinceGrad <= 10  ){
                            //paymentCols
                            for(Integer key : desExIDCols.keySet()){    // loop through designations and update based on the young alum chart
                                String holdDes = null;

                                if(rt.get(desExIDCols.get(key)) != null && rt.get(paymentCols.get(key)) != null){
                                    holdDes = CheckYA((String)rt.get(desExIDCols.get(key)), (double)rt.get(paymentCols.get(key)), YearSinceGrad, yaChart);
                                    if (holdDes != rt.get(desExIDCols.get(key)) ){
                                        rt.put(desExIDCols.get(key), holdDes);
                                        rt.nd_gift_group__c = 'YA';
                                        shouldPost = true;  
                                        rt.put(desIDCols.get(key), null) ;
                                    }                                
                                }
                            }   
                        }
                    }

                    if(rt.nd_gift_group__c == null && pipeline.checkGiftGroupPR__c){
                        rt.nd_gift_group__c = 'PR';
                    }
                    
                    if(rt.nd_gift_group__c == null ){
                            rt.nd_gift_group__c = 'NR';
                            shouldPost = true;
                    }    
                    if(rt.nd_gift_group__c != 'PP' && rt.ucinn_ascendv2__Transaction_Type__c == null){
                            rt.ucinn_ascendv2__Transaction_Type__c ='Gift';
                            rt.ucinn_ascendv2__Opportunity_Type__c = 'Outright';
                            rt.nd_Pledge_Gift_Type__c = 'Outright';
                    }

                    rt.nd_process_status__c = 'Done';

                    if (missingData == true){
                        rt.nd_process_message__c += 'ND process has been run, but additional data is needed, this record can not be auto completed';
                        shouldPost = false;
                    }
                }else if (recordValid == true){
                    rt.nd_process_status__c = 'Done'; 
                    rt.nd_process_message__c += 'ND process has been run, but pipeline type does not result in a gift group';
                }
            }else{ //there is no pipeline on the record meaning it is not an online gift and does not go through group processing
                if (recordValid == true){
                    rt.nd_process_status__c = 'Done'; 
                    rt.nd_process_message__c += 'ND process has been run';
                }
            }

            System.debug('The following transaction type is ' + rt.ucinn_ascendv2__Transaction_Type__c +' and gift group is '+ rt.nd_gift_group__c + ' and status is ' + missingData + ' and record valid is' + recordValid + ' should post is ' + shouldPost );     
            rtv2ToUpdate.add(rt);
            if(shouldPost){
                ucinn_ascendv2__Review_Transaction_v2__c a = new ucinn_ascendv2__Review_Transaction_v2__c(id=rt.id, ucinn_ascendv2__Status__c = 'Reviewed');
                rtv2ToPost.add(a);
                system.debug('tv2 list ' + rtv2ToPost);
            }
            
        }

        if(rtv2ToUpdate.size() > 0) {
            List <Database.SaveResult> rts = Database.update(rtv2ToUpdate, false);      
        }

        if(rtv2ToPost.size() > 0) {
            List <Database.SaveResult> res = Database.update(rtv2ToPost, false);
        }

    }
    global void finish(Database.BatchableContext bc){
                if(!Test.isRunningTest()) {
            System.scheduleBatch(new ND_RTV2_Processing(), 'ND_RTV2_Processing', 10, 1);
          }
    } 
}