public  class lockboxGiftProcessing {
    public static ucinn_ascendv2__Review_Transaction_v2__c processGift(Map<String, Object> gift){
        ucinn_ascendv2__Review_Transaction_v2__c rt = new ucinn_ascendv2__Review_Transaction_v2__c(); 

        rt.nd_process_status__c = 'Done';
        Pipeline__mdt pipeline = Pipeline__mdt.getInstance('LX');
        string donor_id = (string) gift.get('ID_NUM'); //donor id
        donor_id = donor_id.substring(donor_id.indexOfAnyBut('0'));
        if (donor_id != '9999999999'){
            list <Contact> person = [SELECT  id  from contact where ucinn_ascendv2__Donor_ID__c = :donor_id limit 1];
            if (person.size() > 0) {
                rt.ucinn_ascendv2__Donor_External_ID__c = donor_id;
                rt.ucinn_ascendv2__Contact__c = person[0].id;
            }else {
            list <Account> business = [SELECT  id  from Account where ucinn_ascendv2__Donor_ID__c = :donor_id limit 1];
                if (business.size() > 0) {
                rt.nd_organization_external_id__c = donor_id;
                rt.ucinn_ascendv2__Account__c = business[0].id;
                }else{
                rt.ucinn_ascendv2__Donor_External_ID__c = donor_id;  
                }
            }
        }else{
            rt.nd_process_message__c = 'No donor id in Lockbox file ' ;
        }

           
       rt.nd_skip_interim__c = true;
        rt.nd_gift_source_id__c = String.valueOf( gift.get('ND_UNIQUID')); 
        string amount = (String)gift.get('ITEM_AMT');
        rt.ucinn_ascendv2__Total_Transaction_Amount__c = decimal.valueOf(amount) / 100;
        rt.ucinn_ascendv2__Payment_Amount_1_1__c =  decimal.valueOf(amount) / 100;
       
        string batch_id = (string) gift.get('BATCH_ID');
        rt.nd_lockbox_batch_id__c = batch_id.substring(batch_id.indexOfAnyBut('0'));
        string trans_id = (string) gift.get('TRANS_ID');
        rt.nd_lockbox_trans_id__c =  trans_id.substring(trans_id.indexOfAnyBut('0'));
        string group_num = (string) gift.get('GROUP_NUM');
        rt.nd_lockbox_group_num__c =  group_num.substring(group_num.indexOfAnyBut('0')).trim();
        rt.nd_lockbox_programme_code__c = (string) gift.get('PROGRAM_CODE');

        String tranDateString = (string) gift.get('FILE_DATE');
        if (tranDateString != null) {
            string year = tranDateString.substring(4,8) + '-';
            string month = tranDateString.substring(0,2) + '-';
            string day= tranDateString.substring(2,4);

            //string date_no_time = tranDateString.substring(0, 10);
            //system.debug('date_no_time' + date_no_time);
            rt.ucinn_ascendv2__Transaction_Date__c = Date.valueOf(year + month+ day);
           // rt.ucinn_ascendv2__Received_Date_1_1__c = Date.valueOf(year + month+ day);
            rt.nd_lockbox_date__c = Date.valueOf(year + month+ day);
        }
        if(pipeline.override_reciept_date__c != null){
           rt.ucinn_ascendv2__Transaction_Date__c = pipeline.override_reciept_date__c;
           rt.credit_date_override__c = pipeline.override_reciept_date__c;
        }
        rt.ND_Pipeline__c = 'LX'; //lockbox
        rt.nd_gift_source__c ='Lockbox';
        rt.nd_data_source__c ='LBX';

        String appealCode =  (string) gift.get('APPEAL_CODE');
        if (appealCode == '00000'){
            appealCode = null;
        }
    
        if (appealCode != null) {
            rt.nd_appeal_code__c = appealCode;
            list <Campaign> appeal = [SELECT ID, ND_Campaign_Code__c, nd_Default_Designation__c   FROM Campaign where ucinn_ascendv2__Motivation_Code__c = :rt.nd_appeal_code__c and nd_campaign_record_type_dev_name__c = 'Appeal' ];
            if(appeal.size()> 0){
                rt.nd_appeal__c = appeal[0].id;
                rt.ucinn_ascendv2__Designation_1__c = appeal[0].nd_Default_Designation__c;
                if (rt.ucinn_ascendv2__Designation_1__c == null ){
                    rt.ucinn_ascendv2__Designation_External_ID_1__c = 'UNRESTRICTED';
                }
            }   
        }
       /* Campaign campaign =[SELECT ID from Campaign where  isactive = true and  nd_campaign_record_type_dev_name__c = 'Comprehensive_Campaign' limit 1];
        rt.ucinn_ascendv2__Campaign__c = campaign.id; */
     
       

        if (rt.nd_lockbox_group_num__c == '7' || rt.nd_lockbox_group_num__c == '8'){
            rt.ucinn_ascendv2__Tender_Type_1__c = 'Lockbox Credit Card';
        }else{
            rt.ucinn_ascendv2__Tender_Type_1__c = 'Lockbox Check';
            string check_num =  (string) gift.get('CHECK_NUM');
            if (check_num != '00000000000000000'){
            rt.ucinn_ascendv2__Check_Number_1__c = check_num.substring(check_num.indexOfAnyBut('0'));
            }
        }

        rt.ucinn_ascendv2__Transaction_Type__c ='Gift';
        rt.ucinn_ascendv2__Opportunity_Type__c = 'Outright';
        rt.ucinn_ascendv2__Send_to_G_L__c = true;
        rt.ucinn_ascendv2__External_System_ID__c ='GNRL';

        return rt;
    }
}