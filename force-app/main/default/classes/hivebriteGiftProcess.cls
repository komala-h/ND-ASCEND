public class hivebriteGiftProcess{
    public static ucinn_ascendv2__Review_Transaction_v2__c processGift(Map<String, Object> gift){
        
        list<ucinn_ascendv2__Review_Transaction_v2__c> rtv2ToAdd = new List<ucinn_ascendv2__Review_Transaction_v2__c>();
        List<Object> myMapObjects = (List<Object>) gift.get('GIFT_DETAIL');
        String invalidNumbers = '[^0-9]';
        String custom_fund_list = '';
        
        ucinn_ascendv2__Review_Transaction_v2__c rt = new ucinn_ascendv2__Review_Transaction_v2__c(); 
        
        rt.nd_process_status__c = 'New';
        string gift_comment = (string) gift.get('GIFT_COMMENT');
        string donor_id = (string) gift.get('user_external_id'); //donor id
        if (donor_id != null){
            list <Account> business = [SELECT  id  from Account where ucinn_ascendv2__Donor_ID__c = :donor_id limit 1];
            if (business.size() > 0) {
                rt.nd_organization_external_id__c = donor_id;
            }else{
                rt.ucinn_ascendv2__Donor_External_ID__c = donor_id;  
            }
        }
        //rt.ucinn_ascendv2__External_System_ID__c nd id
        rt.ucinn_ascendv2__First_Name__c = (string) gift.get('ORDER_FIRSTNAME');
        rt.ucinn_ascendv2__Last_Name__c = (string) gift.get('ORDER_LASTNAME');
        rt.ucinn_ascendv2__Address_1_Line_1__c =  (string) gift.get('ORDER_BILLING_ADDRESS__ADDRESS_1');
        rt.ucinn_ascendv2__Address_1_Line_2__c =  (string) gift.get('ORDER_BILLING_ADDRESS__ADDRESS_2');
        rt.ucinn_ascendv2__Country_1__c =  (string) gift.get('ORDER_BILLING_ADDRESS__COUNTRY');
        rt.ucinn_ascendv2__State_1__c =  (string) gift.get('ORDER_BILLING_ADDRESS__STATE');
        rt.ucinn_ascendv2__City_1__c =  (string) gift.get('ORDER_BILLING_ADDRESS__CITY');
        rt.ucinn_ascendv2__Postal_Code_1__c =  (string) gift.get('ORDER_BILLING_ADDRESS__POSTAL_CODE');
        rt.ucinn_ascendv2__Address_1_Type__c = 'H';
        rt.ucinn_ascendv2__Email_1__c =  (string) gift.get('ORDER_EMAIL');
        rt.ucinn_ascendv2__Email_1_Type__c = 'M';
        string phone =  (string) gift.get('MOBILE_PERSO');
        if (phone != null){
            rt.ucinn_ascendv2__Phone_1__c = phone.replaceAll( invalidNumbers, '' );
            rt.ucinn_ascendv2__Phone_1_Type__c = 'M';     
            }
        rt.ucinn_ascendv2__Tributee_1__c = (string) gift.get('DEDICATION_TITLE');
        rt.ucinn_ascendv2__In_Memory_Honor_Comments_1__c = (string) gift.get('DEDICATION_DESCRIPTION');
        

        rt.nd_data_source__c = 'HVG';
        rt.nd_gift_source__c = 'Hivebrite';
        rt.ND_Pipeline__c = 'GF'; //nd giving form
        rt.nd_Acknowledgement_Code__C = 'NER';

        Boolean on_behalf = (Boolean) gift.get('ON_BEHALF_OF');
        Boolean in_memory = (Boolean) gift.get('IN_MEMORY_OF');
        Boolean in_honor = (Boolean) gift.get('IN_HONOR_OF');
        if(on_behalf == true){
            rt.ucinn_ascendv2__Tribute_Type_1__c = 'B'; 
        }else if(in_memory == true){
            rt.ucinn_ascendv2__Tribute_Type_1__c = 'M'; 
        }else if(in_honor == true){
            rt.ucinn_ascendv2__Tribute_Type_1__c = 'H'; 
        }
        Boolean poster =  (Boolean) gift.get('I_WANT_TO_RECEIVE_THE_FREE_POSTER');
        if (poster != null){
            rt.nd_i_want_to_receive_the_free_poster__c = poster;
            if(poster == false ){
                rt.nd_No_Swag__c = true;
            }     
        }
        Boolean magazine =  (Boolean) gift.get('I_WANT_TO_RECEIVE_THE_MAGAZINE');
        if (magazine != null){
            rt.nd_i_want_to_receive_the_magazine__c = magazine;     
        }
    
        Boolean confirmation =  (Boolean) gift.get('SEND_CONFIRMATION_EMAIL');
        if (confirmation != null){
            rt.nd_send_confirmation_email__c = confirmation; 
                /* no longer neededif (rt.nd_send_confirmation_email__c){
                rt.nd_Acknowledgement_Code__c    = null;
            }*/
            
        } 



        Boolean recurring_payment_enabled = (Boolean) gift.get('RECURRING_PAYMENT_ENABLED');
        Boolean lifelong_payment_enabled = (Boolean) gift.get('LIFELONG_PAYMENT_ENABLED ');
        if (recurring_payment_enabled != null){
            rt.nd_recurring_transaction_Ind__c = recurring_payment_enabled;
            String Periodicity = (string)gift.get('PERIODICITY');
            if(Periodicity == 'month'){
            rt.nd_Recurring_Periodicity__c = 12;
            }else if(Periodicity == 'year'){
            rt.nd_Recurring_Periodicity__c = 1;
            }
            else if(Periodicity == 'week'){
            rt.nd_Recurring_Periodicity__c = 52;
            }
            else if(Periodicity == 'six_months'){
            rt.nd_Recurring_Periodicity__c = 2;
            }
            else if(Periodicity == 'three_months'){
            rt.nd_Recurring_Periodicity__c = 4;
            }
            rt.nd_parent_initial_transaction_id__c =String.valueOf((integer) gift.get('MASTER_PARENT'));
            String parent_id = String.valueOf((integer) gift.get('PARENT_ID'));
            if(parent_id == null){
            rt.nd_initial_recurring_transaction_ind__c = true;
            }
            rt.nd_recurring_payments_left__c = (integer)gift.get('RECURRING_PAYMENTS_LEFT');
        }
        rt.nd_gift_source_id__c = (string) gift.get('ORDER_ID'); 
        rt.ucinn_ascendv2__Authorization_Code_1__c = (string) gift.get('PAYMENT_GATEWAY_INFORMATIONS__TRANSACTION__ID');
        rt.ucinn_ascendv2__Matching_Source__c = (string) gift.get('HEP_INFORMATION__NAME');
        rt.ucinn_ascendv2__Total_Transaction_Amount__c = (Decimal) gift.get('AMOUNT');
        string tranDateString = (string) gift.get('RECEIPT_CREATED_AT');
        if (tranDateString != null) {
            rt.ucinn_ascendv2__Transaction_Date__c = Date.valueOf(tranDateString);
            //rt.ucinn_ascendv2__Received_Date_1_1__c = Date.valueOf(tranDateString);
        }
        rt.ucinn_ascendv2__Transaction_ID__c = (string) gift.get('RECEIPT_NUMBER');
        rt.ucinn_ascendv2__Transaction_Number_2__c = (string) gift.get('PAYMENT_GATEWAY_INFORMATIONS__TRANSACTION__ID');
        rt.ucinn_ascendv2__Middle_Name__c = (string)gift.get('PREFIX_NAME');

        rt.nd_notre_dame_class_year__c = (string) gift.get('NOTRE_DAME_CLASS_YEAR');
        rt.nd_relationship_with_notre_dame__C = (string) gift.get('YOUR_RELATIONSHIP_WITH_NOTRE_DAME');
        rt.nd_spouse_first_name__c = (string) gift.get('SPOUSE_FIRST_NAME');
        rt.nd_spouse_last_name__c = (string) gift.get('SPOUSE_LAST_NAME');


        string appealCode =  (string) gift.get('PROMOTION_CODE');
       
        if (appealCode != null) {
            rt.nd_appeal_code__c = appealCode;
            //list<Campaign> appeal = [SELECT ID ,ND_Campaign_Code__c FROM Campaign where nd_appeal_code__c = :appealCode and nd_campaign_record_type_dev_name__c = 'Appeal' and isActive =True  ];
            //rt.ucinn_ascendv2__Campaign__c = appeal.id;
            //rt.ucinn_ascendv2__Campaign_External_ID__c = appeal.ND_Campaign_Code__c;
            //rt.nd_appeal__c = appeal.id;
        }
        
        rt.ucinn_ascendv2__Tender_Type_1__c = 'Credit Card'; /// may need to be a specific tender type.
        rt.ucinn_ascendv2__Send_to_G_L__c = true;
        

        Integer designation_num = 1;
        for (Object obj : myMapObjects) {
   		    Map<String, Object> giftDetail = (Map<String, Object>)obj;
            
            string custom_fund = (string) giftDetail.get('CUSTOM_FUND');
        	if (custom_fund != null && custom_fund != 'null'){
            	custom_fund_list = custom_fund_list + custom_fund + '; ';
        	}
            
            if(designation_num == 1){
                rt.ucinn_ascendv2__Designation_External_ID_1__c = (string) giftDetail.get('ALLOCATION_CODE');
                rt.ucinn_ascendv2__Payment_Amount_1_1__c =  (Decimal) giftDetail.get('AMOUNT');
                rt.nd_designation_description__c = (string) giftDetail.get('FUND_TITLE');
            }else if(designation_num == 2){
                rt.ucinn_ascendv2__Designation_External_ID_2__c = (string) giftDetail.get('ALLOCATION_CODE');
                rt.ucinn_ascendv2__Payment_Amount_2_1__c =  (Decimal) giftDetail.get('AMOUNT');
            }
            else if(designation_num == 3){
                rt.ucinn_ascendv2__Designation_External_ID_3__c = (string) giftDetail.get('ALLOCATION_CODE');
                rt.ucinn_ascendv2__Payment_Amount_3_1__c =  (Decimal) giftDetail.get('AMOUNT');
            }
            else if(designation_num == 4){
                rt.ucinn_ascendv2__Designation_External_ID_4__c = (string) giftDetail.get('ALLOCATION_CODE');
                rt.ucinn_ascendv2__Payment_Amount_4_1__c =  (Decimal) giftDetail.get('AMOUNT');
            }
            else if(designation_num == 5){
                rt.ucinn_ascendv2__Designation_External_ID_5__c = (string) giftDetail.get('ALLOCATION_CODE');
                rt.ucinn_ascendv2__Payment_Amount_5_1__c =  (Decimal) giftDetail.get('AMOUNT');
            }
            else if(designation_num == 6){
                rt.Designation_External_ID_6__c = (string) giftDetail.get('ALLOCATION_CODE');
                rt.Payment_Amount_6_1__c =  (Decimal) giftDetail.get('AMOUNT');
            }
            else if(designation_num == 7){
                rt.Designation_External_ID_7__c = (string) giftDetail.get('ALLOCATION_CODE');
                rt.Payment_Amount_7_1__c =  (Decimal) giftDetail.get('AMOUNT');
            }
            else if(designation_num == 8){
                rt.Designation_External_ID_8__c = (string) giftDetail.get('ALLOCATION_CODE');
                rt.Payment_Amount_8_1__c =  (Decimal) giftDetail.get('AMOUNT');
            }
            else if(designation_num == 9){
                rt.Designation_External_ID_9__c = (string) giftDetail.get('ALLOCATION_CODE');
                rt.Payment_Amount_9_1__c =  (Decimal) giftDetail.get('AMOUNT');
            }
            else if(designation_num == 10){
                rt.Designation_External_ID_10__c = (string) giftDetail.get('ALLOCATION_CODE');
                rt.Payment_Amount_10_1__c =  (Decimal) giftDetail.get('AMOUNT');
            }else if(designation_num > 10 ){
                rt.nd_process_message__c = 'This gift includes more than 10 designations, only the first 10 have been assigned';
                rt.nd_process_status__c = 'Error';
            }

       	    //rt.ucinn_ascendv2__Transaction_Number_1__c = String.valueOf((integer) giftDetail.get('GIFT_ID'));
            
            // system.debug(rt.ucinn_ascendv2__Transaction_Number_1__c);
		    
            designation_num +=1; 
            rt.ucinn_ascendv2__External_System_ID__c ='GNRL';


        }
        if (custom_fund_list != 'null' && custom_fund_list != null){
            //rt.nd_gift_comment__c = custom_fund_list;
        }
        if(gift_comment != 'null' && gift_comment != null){
            //rt.nd_gift_comment__c = rt.nd_gift_comment__c + gift_comment;
        }
        return rt;
   //     rtv2ToAdd.add(rt);
  //      return rtv2ToAdd;
    }
}