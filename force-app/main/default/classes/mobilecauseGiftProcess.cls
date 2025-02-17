public class mobilecauseGiftProcess {
    public static ucinn_ascendv2__Review_Transaction_v2__c processGift(Map<String, Object> gift){
        String appealCode = null;
        String invalidNumbers = '[^0-9]';
        String keyword;
        
        ucinn_ascendv2__Review_Transaction_v2__c rt = new ucinn_ascendv2__Review_Transaction_v2__c(); 
        keyword = (string) gift.get('keyword');
        if (keyword =='NDCLUBGIFT'){
            rt.nd_skip_interim__c = true;
            rt.nd_process_message__c = 'NDCLUBGIFT please set the organization for the gift. ';
        }

        rt.nd_process_status__c = 'New';
        rt.nd_gift_comment__c = (string) gift.get('comments');
        //rt.ucinn_ascendv2__Donor_External_ID__c = (string) gift.get('user_external_id'); //donor id
        rt.ucinn_ascendv2__First_Name__c = (string) gift.get('first_name');
        rt.ucinn_ascendv2__Last_Name__c = (string) gift.get('last_name');
        rt.ucinn_ascendv2__Address_1_Line_1__c =  (string) gift.get('street_address');
        rt.ucinn_ascendv2__Country_1__c =  (string) gift.get('country');
        rt.ucinn_ascendv2__State_1__c =  (string) gift.get('state');
        rt.ucinn_ascendv2__City_1__c =  (string) gift.get('city');
        rt.ucinn_ascendv2__Postal_Code_1__c =  (string) gift.get('zip');
        rt.ucinn_ascendv2__Address_1_Type__c = 'H';
        rt.ucinn_ascendv2__Email_1__c =  (string) gift.get('email');
        rt.ucinn_ascendv2__Email_1_Type__c = 'M';
        string phone =  (string) gift.get('phone');
        if (phone != null){
            rt.ucinn_ascendv2__Phone_1__c = phone.replaceAll( invalidNumbers, '' );
            rt.ucinn_ascendv2__Phone_1_Type__c = 'M';     
        }

        string recurring_payment = (String) gift.get('frequency');
        if (recurring_payment != null && recurring_payment != 'One Time'){
            rt.nd_recurring_transaction_Ind__c = true;
            if(recurring_payment == 'Monthly'){
            rt.nd_Recurring_Periodicity__c = 12;
            }else if(recurring_payment == 'Annually'){
            rt.nd_Recurring_Periodicity__c = 1;
            }
            else if(recurring_payment == 'Quarterly'){
            rt.nd_Recurring_Periodicity__c = 4;
            }
        }
        rt.nd_gift_source_id__c = (string) gift.get('nd_uniquid'); 
        rt.nd_data_source__c = 'MBC';
        rt.nd_gift_source__c = 'Mobilecause';
        rt.ucinn_ascendv2__Authorization_Code_1__c = (string) gift.get('BILLING_TRANSACTION');
        //rt.ucinn_ascendv2__Matching_Source__c = (string) gift.get('HEP_INFORMATION__NAME');
        string amount = (String)gift.get('collected_amount');
        rt.ucinn_ascendv2__Total_Transaction_Amount__c = Decimal.ValueOf(amount.replace('$',''));
        rt.ucinn_ascendv2__Payment_Amount_1_1__c =  Decimal.ValueOf(amount.replace('$',''));
        String tranDateString = (string) gift.get('transaction_date');
        if (tranDateString != null) {
            string date_no_time = tranDateString.substring(0, 10);
            system.debug('date_no_time' + date_no_time);
            rt.ucinn_ascendv2__Transaction_Date__c = Date.parse(date_no_time);
            //rt.ucinn_ascendv2__Received_Date_1_1__c = Date.parse(date_no_time);
        }
        //rt.ucinn_ascendv2__Authorization_Code_1__c = (string) gift.get('billing_transaction_reference');
        rt.ucinn_ascendv2__Transaction_ID__c = (string) gift.get('transaction_id');
        // rt.ucinn_ascendv2__Transaction_Number_2__c = (string) gift.get('PAYMENT_GATEWAY_INFORMATIONS__TRANSACTION__ID');
        rt.ND_Pipeline__c = 'CF'; //crowdfunding
        rt.nd_Acknowledgement_Code__c = 'NER';
        rt.nd_notre_dame_class_year__c = (string) gift.get('class_year');
        //  rt.nd_relationship_with_notre_dame__C = (string) gift.get('YOUR_RELATIONSHIP_WITH_NOTRE_DAME');
        rt.nd_spouse_first_name__c = (string) gift.get('spouse_first_name');
        rt.nd_spouse_last_name__c = (string) gift.get('spouse_last_name');


        appealCode =  (string) gift.get('appeal_code');
    
        if (appealCode != null) {
        rt.nd_appeal_code__c = appealCode;
        }
        
        rt.ucinn_ascendv2__Tender_Type_1__c = 'Credit Card';
        rt.ucinn_ascendv2__Designation_External_ID_1__c = (string) gift.get('fund_allocation'); // might have to change this if set to other
        rt.ucinn_ascendv2__Send_to_G_L__c = true;
        rt.ucinn_ascendv2__External_System_ID__c ='GNRL';
        return rt;
    }
        
}