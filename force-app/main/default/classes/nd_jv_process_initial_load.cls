global class nd_jv_process_initial_load implements Database.Batchable<sObject>, Database.Stateful {
    global Database.QueryLocator start(Database.BatchableContext bc) {
       return Database.getQueryLocator([ select id from Opportunity where (ucinn_ascendv2__Adjusted_Gift__c = null and
            name like 'MN9%' and Campaign.StartDate >= 2013-07-01
           and stageName != 'Adjusted') or nd_Donor_Gift_Comments__c ='Test class record'
         ]);
   }
   
   global void execute(Database.BatchableContext bc, List<Opportunity> scope) {
       id origGift;
       String c_d_ind;
       //Set<id> opset = new Set<id>();
       List<nd_jv_entry__c> JVToInsert = new list<nd_jv_entry__c>();
       Map<String, G_L_Processing__mdt> tenderTypeMetadata = new Map<String, G_L_Processing__mdt>();

       List<G_L_Processing__mdt> metadataRecords = [SELECT MasterLabel, clearing_account__c, file_type__c
                                                 FROM G_L_Processing__mdt
                                                ];
       for (G_L_Processing__mdt metadataRecord : metadataRecords) {
           tenderTypeMetadata.put(metadataRecord.MasterLabel, metadataRecord);
       }
       
       
       List<Opportunity> GiftList = [Select id, name, StageName, ucinn_ascendv2__Adjusted_Gift__c, ucinn_ascendv2__Donor_ID_Formula__c, gl_processed__c, Needs_G_L_Processing__c from Opportunity  where Id IN :scope ];
       for (Opportunity curGift : GiftList ){
           List<nd_jv_entry__c> sentJVs = [select designation_amount__c,  clearing_amount__c, clearing_account__c, designation_account__c
                                           from nd_jv_entry__c 
                                           where opportunity_name__c = :curGift.name];
           list<ucinn_ascendv2__Payment__c> CurrPays = [select id, ucinn_ascendv2__Payment_Amount__c, ucinn_ascendv2__G_L_Account__c, ND_GL_Account_Number_Formula__c,  ucinn_ascendv2__Donor_ID_Formula__c, ucinn_ascendv2__Tender_Type_Formula__c
           from ucinn_ascendv2__Payment__c 
           where ucinn_ascendv2__Opportunity__r.name = :curGift.name  and ucinn_ascendv2__Send_to_G_L__c = true and 
           ucinn_ascendv2__Session_Approved_Date_Formula__c != null and ND_GL_Account_Number_Formula__c != null
             and ucinn_ascendv2__Sent_to_G_L_Date__c != null and ucinn_ascendv2__Tender_Type_Formula__c in 
             ('ACH Recurring','Campus Credit Card', 'Cash','Check','Credit Card', 'Credit Card Recurring','Lockbox Check', 'Lockbox Credit Card', 'Payroll Deduction', 'Stock Gift','Wire'   )
               ] ;

           if(sentJVs.size() < 1 ){
               system.debug('must be a brand new gift');
              for (ucinn_ascendv2__Payment__c cp : CurrPays){
                   //add to the jv table
                   nd_jv_entry__c JVentryRow = new nd_jv_entry__c();
                   G_L_Processing__mdt metadata = tenderTypeMetadata.get((String)cp.ucinn_ascendv2__Tender_Type_Formula__c);
                   if(metadata != null){
                       JVentryRow.jv_status__c = 'processed in advance';
                       JVentryRow.clearing_amount__c = cp.ucinn_ascendv2__Payment_Amount__c;
                       JVentryRow.clearing_account__c = metadata.Clearing_Account__c;
                       JVentryRow.designation_amount__c = cp.ucinn_ascendv2__Payment_Amount__c;
                       JVentryRow.opportunity_name__c = curGift.name;
                       JVentryRow.designation_account__c = cp.ND_GL_Account_Number_Formula__c;
                       JVentryRow.jv_type__c = metadata.file_type__c;
                       JVToInsert.add(JVentryRow);
                   }
               }
           } 
           
       }

       system.debug('number of jvs to insert '+ JVToInsert.size() );
       if(JVToInsert.size() > 0) {
           List <Database.SaveResult> rt = Database.insert(JVToInsert, true);
           for ( Database.SaveResult sr : rt) {
               if ( sr.isSuccess() != true ){
                   for(Database.Error err : sr.getErrors()) {
                       System.debug('The following error has occurred.');                    
                       System.debug(err.getStatusCode() + ': ' + err.getMessage());
                       System.debug('Account fields that affected this error: ' + err.getFields());
                   }
               }
           }
       }


   }

   global void finish(Database.BatchableContext bc) {
       // 
   }
}