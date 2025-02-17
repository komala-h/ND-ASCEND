global class ND_JV_Process implements Database.Batchable<sObject>, Database.Stateful {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([ select id from Opportunity where Needs_G_L_Processing__c = true and
        ((((ND_RecordType_DeveloperName__c in('Gift', 'Matching_Gift') and Campaign.StartDate >= 2013-07-01 )
        or ND_RecordType_DeveloperName__c = 'Pledge')
         and stageName != 'Adjusted')   
         or (ND_RecordType_DeveloperName__c in ('Gift', 'Matching_Gift') and Campaign.StartDate >= 2013-07-01  and stageName = 'Adjusted'
          and ucinn_ascendv2__Adjustment_Reason_v1__c includes ('Gift to Pledge Payment')))
          ]);
    }
    
    global static string CreateJVEntry( string jvType, string donorId, string GiftName, Decimal amount, string foapal, string creditDebit, string DocRefNo ){
        String JVEntry;
        String actv;
        String locn;
        //create the jv entry based on 
        JVEntry = '';
        String SystemId = 'ALUMNI'.rightPad(8,' ');
        String DocCode = ''.rightPad(8,' ');
        String RecType = '2'.rightPad(1,' ');
        String RuleClass = jvType.rightPad(4,' ');
        if (DocRefNo.length() >8){
            DocRefNo = DocRefNo.substring(0,8);
        }
        String DocRefNum = DocRefNo.rightPad(8,' ');
        Decimal roundedAmount = amount.setScale(2, RoundingMode.HALF_UP);
    	//Long TransAmtLong = roundedAmount.longValue() * 100;
    	Long TransAmtLong = math.abs((roundedAmount * 100).longValue());
 system.debug('line 28 TransAmtlong  '+ TransAmtLong );
        String TransAmt = String.valueOf(TransAmtLong).leftPad(12, '0');
 system.debug('line 30 TransAmt  '+ TransAmt );
        String TransDesc = ('GID = ' + GiftName + ' EID = ' +  donorId).rightPad(35,' ');
        String DrCrInd = creditDebit.rightPad(1,' ');
        String BankCode = 'XA'.rightPad(2,' ');
        String CoasCode = '1'.rightPad(1,' ');
        String AcciCode = ''.rightPad(6,' ');
        system.debug('line 32 gift  '+ GiftName + ' foapal ' + foapal);
        String fund = foapal.substring(0,6).rightPad(6,' ');
        String org = foapal.substring(7,12).rightPad(6,' ');
        String acct = foapal.substring(13,18).rightPad(6,' ');
        String prog;
        if(foapal.length() > 21){
            prog = foapal.substring(19,24).rightPad(6,' ');
        }
        else{
            prog = foapal.substring(19,21).rightPad(6,' ');
        }
        if(foapal.length() > 24){
            actv = foapal.substring(24,29).rightPad(6,' ');
        } else {
            actv = '      ';
        }

        if(foapal.length() > 29){
            locn = foapal.substring(29,35).rightPad(6,' ');
        }else {
            locn = '      ';
        }
        system.debug('fund  '+ fund + ' org ' + org + ' acct ' + acct + ' prog ' + prog + ' actv ' + actv + ' locn ' + locn);

        String filler = ''.rightPad(26,' ');
        //needs to end with a newline

        JVEntry = SystemId + DocCode + RecType + RuleClass + DocRefNum + TransAmt  + TransDesc + DrCrInd + BankCode + CoasCode + AcciCode + fund + org + acct + prog + actv + locn + filler;
        return JVEntry;
    }

    global void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        id origGift;
        String c_d_ind;
		//Set<id> opset = new Set<id>();
        List<ucinn_ascendv2__Payment__c> payToUpdate = new list<ucinn_ascendv2__Payment__c>();
        List<Opportunity> oppToUpdate = new list<Opportunity>();
        List<nd_jv_entry__c> JVToInsert = new list<nd_jv_entry__c>();
        Map<String, G_L_Processing__mdt> tenderTypeMetadata = new Map<String, G_L_Processing__mdt>();

        List<G_L_Processing__mdt> metadataRecords = [SELECT MasterLabel, clearing_account__c, file_type__c
                                                  FROM G_L_Processing__mdt
                                                 ];
        for (G_L_Processing__mdt metadataRecord : metadataRecords) {
            tenderTypeMetadata.put(metadataRecord.MasterLabel, metadataRecord);
        }
        
        
        List<Opportunity> GiftList = [Select id, name, StageName, ucinn_ascendv2__Adjusted_Gift__c, ucinn_ascendv2__Donor_ID_Formula__c, gl_processed__c, Needs_G_L_Processing__c, ND_RecordType_DeveloperName__c, type from Opportunity  where Id IN :scope ];
        for (Opportunity curGift : GiftList ){
            string OppName = curGift.name;
            if (curGift.StageName == 'Adjusted'){
                //remove the A from the name
                OppName = curGift.name.replace('A','');
            }
            string DocRefNum = OppName.substring(2,OppName.length());
            List<nd_jv_entry__c> sentJVs = [select designation_amount__c,  clearing_amount__c, clearing_account__c, designation_account__c
                                            from nd_jv_entry__c 
                                            where opportunity_name__c = :OppName];
            list<ucinn_ascendv2__Payment__c> CurrPays = [select id, ucinn_ascendv2__Payment_Amount__c, ucinn_ascendv2__G_L_Account__c, ND_GL_Account_Number_Formula__c,  ucinn_ascendv2__Donor_ID_Formula__c, ucinn_ascendv2__Tender_Type_Formula__c, nd_Lockbox_Batch_Id__c, CreatedDate
                                            from ucinn_ascendv2__Payment__c 
                                            where ucinn_ascendv2__Opportunity__r.name = :OppName  and ucinn_ascendv2__Send_to_G_L__c = true and 
                                            ucinn_ascendv2__Session_Approved_Date_Formula__c != null and ND_GL_Account_Number_Formula__c != null
                                            and ucinn_ascendv2__Tender_Type_Formula__c in 
                                            ('ACH Recurring','Campus Credit Card', 'Cash','Check','Credit Card', 'Credit Card Recurring','Lockbox Check', 'Lockbox Credit Card', 'Payroll Deduction', 'Stock Gift','Wire'   ) ] ;

            if(sentJVs.size() < 1 && curGift.StageName != 'Adjusted' && curGift.ND_RecordType_DeveloperName__c != 'Pledge'){
                system.debug('must be a brand new gift');
               for (ucinn_ascendv2__Payment__c cp : CurrPays){
                    //add to the jv table
                    if (cp.nd_Lockbox_Batch_Id__c != null ){DocRefNum = 'L' + cp.nd_Lockbox_Batch_Id__c; }
                    nd_jv_entry__c JVentryRow = new nd_jv_entry__c();
                    G_L_Processing__mdt metadata = tenderTypeMetadata.get((String)cp.ucinn_ascendv2__Tender_Type_Formula__c);
                    if(metadata != null){
                        JVentryRow.jv_status__c = 'new';
                        JVentryRow.clearing_amount__c = cp.ucinn_ascendv2__Payment_Amount__c;
                        JVentryRow.clearing_account__c = metadata.Clearing_Account__c;
                        JVentryRow.designation_amount__c = cp.ucinn_ascendv2__Payment_Amount__c;
                        JVentryRow.opportunity_name__c = curGift.name;
                        //JVentryRow.designation_account__c = cp.ucinn_ascendv2__Designation__r.ucinn_ascendv2__G_L_Account__c;
                        JVentryRow.designation_account__c = cp.ND_GL_Account_Number_Formula__c;
                        JVentryRow.jv_type__c = metadata.file_type__c;
                        JVentryRow.jv_entry__c = CreateJVEntry( JVentryRow.jv_type__c, cp.ucinn_ascendv2__Donor_ID_Formula__c, JVentryRow.opportunity_name__c, JVentryRow.designation_amount__c, JVentryRow.designation_account__c, 'C', DocRefNum );
                        system.debug('line 129 jv value '+ JVentryRow);
                        JVentryRow.opportunity_id__c = curGift.id;
                        JVToInsert.add(JVentryRow);

                        cp.ucinn_ascendv2__Sent_to_G_L_Date__c = Date.today();
                        payToUpdate.add(cp);
                    }
                }

            } else if ( curGift.type != 'TH' &&  curGift.type !=  'T1' && curGift.type !=  'T6') {
                String dvType = 'DV3';
                if (curGift.ND_RecordType_DeveloperName__c == 'Pledge') {
                    dvType = 'DV4';
                }
                // get the totals of the jv table for the original gift
                // Calculate totals for JV table's clearing_amount__c and store in jvClearingAmountTotals map by clearing foapal
                Map<String, Decimal> jvClearingAmountTotals = new Map<String, Decimal>();
                Map<String, Decimal> jvDesignationAmountTotals = new Map<String, Decimal>();

                for (nd_jv_entry__c jvEntry : sentJVs) {
                    String clearingAccount = jvEntry.clearing_account__c;
                    Decimal clearingAmount = jvEntry.clearing_amount__c;

                    if (clearingAccount != null && clearingAmount != null) {
                        if (!jvClearingAmountTotals.containsKey(clearingAccount)) {
                            jvClearingAmountTotals.put(clearingAccount, 0);
                        }

                        jvClearingAmountTotals.put(clearingAccount, jvClearingAmountTotals.get(clearingAccount) + clearingAmount);
                    }
                }

                // Calculate totals for JV table's designation_amount__c and store in jvDesignationAmountTotals map by des foapal
                for (nd_jv_entry__c jvEntry : sentJVs) {
                    String designationAccount = jvEntry.designation_account__c;
                    Decimal designationAmount = jvEntry.designation_amount__c;
                
                    if (designationAccount != null && designationAmount != null) {
                        if (!jvDesignationAmountTotals.containsKey(designationAccount)) {
                            jvDesignationAmountTotals.put(designationAccount, 0);
                        }
                
                        jvDesignationAmountTotals.put(designationAccount, jvDesignationAmountTotals.get(designationAccount) + designationAmount);
                    }
                }
                // get the totals of the current gift's payments
                Map<String, Decimal> payClearingAmountTotals = new Map<String, Decimal>();
                Map<String, Decimal> payDesignationAmountTotals = new Map<String, Decimal>();
                string recentLockbox;
                DateTime lockboxDate;
                
                // Calculate totals for payment table's clearing_amount__c and store in payClearingAmountTotals map by des foapal
                for (ucinn_ascendv2__Payment__c payEntry : CurrPays) {
                    G_L_Processing__mdt metadata = tenderTypeMetadata.get((String)payEntry.ucinn_ascendv2__Tender_Type_Formula__c);
                    String clearingAccount = metadata.clearing_account__c;
                    Decimal clearingAmount = payEntry.ucinn_ascendv2__Payment_Amount__c;
                    String designationAccount =  payEntry.ND_GL_Account_Number_Formula__c;
                    Decimal designationAmount = payEntry.ucinn_ascendv2__Payment_Amount__c;
                    if(payEntry.ucinn_ascendv2__Tender_Type_Formula__c.contains('Lockbox') && payEntry.nd_Lockbox_Batch_Id__c!= null ){
                        if(payEntry.CreatedDate == null || payEntry.CreatedDate < lockboxDate){
                            recentLockbox = payEntry.nd_Lockbox_Batch_Id__c;
                        }
                        
                    }

                    if (clearingAccount != null && clearingAmount != null) {
                        if (!payClearingAmountTotals.containsKey(clearingAccount)) {
                            payClearingAmountTotals.put(clearingAccount, 0);
                        }
                        payClearingAmountTotals.put(clearingAccount, payClearingAmountTotals.get(clearingAccount) + clearingAmount);
                    }
                    if (designationAccount != null && designationAmount != null) {
                        if (!payDesignationAmountTotals.containsKey(designationAccount)) {
                            payDesignationAmountTotals.put(designationAccount, 0);
                        }
                        payDesignationAmountTotals.put(designationAccount, payDesignationAmountTotals.get(designationAccount) + designationAmount);
                    }
                }

                //compare the totals between the clearing amounts and enter the diffs into the jv table 
                Set<String> allClearingAccounts = new Set<String>();
                allClearingAccounts.addAll(payClearingAmountTotals.keySet());
                allClearingAccounts.addAll(jvClearingAmountTotals.keySet());
                
                // Loop through all unique clearingAccounts
                for (String clearingAccount : allClearingAccounts) {
                    nd_jv_entry__c JVentryRow = new nd_jv_entry__c();
                    Decimal payClearingAmount = payClearingAmountTotals.get(clearingAccount);
                    Decimal jvClearingAmount = jvClearingAmountTotals.get(clearingAccount);
                    boolean createJV = true;
                    Decimal entryAmount = null;
                    String clearingDebitCreditInd = 'D';
                                    
                    // Compare clearingAmounts
                    if (payClearingAmount != null && jvClearingAmount != null && payClearingAmount != jvClearingAmount) {
                        System.debug('Mismatch for clearingAccount: ' + clearingAccount + ' payClearingAmount: ' + payClearingAmount + ' jvClearingAmount: ' + jvClearingAmount);
                        entryAmount = payClearingAmount - jvClearingAmount ;
                        if (entryAmount < 0) {
                            clearingDebitCreditInd = 'C';
                        }
                    } else if (payClearingAmount == null && jvClearingAmount != null && jvClearingAmount != 0) {
                        System.debug('Missing clearingAccount in payClearingAmountTotals: ' + clearingAccount + ' for jvClearingAmount: ' + jvClearingAmount);
                        //Reverse the amount in the JV table JV  -jvClearingAmount
                        entryAmount = jvClearingAmount * -1;
                        clearingDebitCreditInd = 'C';
                    } else if (payClearingAmount != null && jvClearingAmount == null && payClearingAmount != 0 ) {
                        System.debug('Missing clearingAccount in jvClearingAmountTotals: ' + clearingAccount + ' for payClearingAmount: ' + payClearingAmount);
                        // add to the jv table payClearingAmount
                        entryAmount = payClearingAmount;
                    } else{
                        createJV = false;
                    }
                    if(entryAmount == 0){createJV = false;}

                    if (createJV == true){
                        JVentryRow.jv_status__c = 'new';         
                        JVentryRow.clearing_account__c = clearingAccount;
                        if(recentLockbox != null && clearingAccount == '999999-58050-11194-99000'){
                            DocRefNum = recentLockbox;
                        }
                        //JVentryRow.designation_amount__c = null;
                        JVentryRow.clearing_amount__c = entryAmount;
                        JVentryRow.opportunity_name__c = OppName;
                        //JVentryRow.designation_account__c = null;
                        JVentryRow.jv_type__c = dvType;
                        JVentryRow.jv_entry__c = CreateJVEntry( dvType, curGift.ucinn_ascendv2__Donor_ID_Formula__c, JVentryRow.opportunity_name__c, entryAmount, clearingAccount, clearingDebitCreditInd, DocRefNum);
                        JVentryRow.opportunity_id__c = curGift.id;
                        JVToInsert.add(JVentryRow);
                    }
                }
                //compare the totals between the designation amounts and enter the diffs into the jv table 
                Set<String> allDesignationAccounts = new Set<String>();
                allDesignationAccounts.addAll(payDesignationAmountTotals.keySet());
                allDesignationAccounts.addAll(jvDesignationAmountTotals.keySet());
                
                // Loop through all unique designationAccounts
                for (String designationAccount : allDesignationAccounts) {
                    nd_jv_entry__c JVentryRow = new nd_jv_entry__c();
                    Decimal payDesignationAmount = payDesignationAmountTotals.get(designationAccount);
                    Decimal jvDesignationAmount = jvDesignationAmountTotals.get(designationAccount);
                    boolean createJV = true;
                    Decimal entryAmount = null;
                    String designationDebitCreditInd = 'C';
                
                    // Compare designationAmounts
                    if (payDesignationAmount != null && jvDesignationAmount != null && payDesignationAmount != jvDesignationAmount) {
                        System.debug('Mismatch for designationAccount: ' + designationAccount + ' payDesignationAmount: ' + payDesignationAmount + ' jvDesignationAmount: ' + jvDesignationAmount);
                        entryAmount = payDesignationAmount - jvDesignationAmount; 
                        if (entryAmount < 0) {
                            designationDebitCreditInd = 'D';
                        }
                    } else if (payDesignationAmount == null && jvDesignationAmount != null && jvDesignationAmount != 0 ) {
                        System.debug('Missing designationAccount in payDesignationAmountTotals: ' + designationAccount + ' for jvDesignationAmount: ' + jvDesignationAmount);
                        // reverse out of the jv table by -jvDesignationAmount
                        entryAmount = jvDesignationAmount * -1;
                        designationDebitCreditInd = 'D';
                    } else if (payDesignationAmount != null && jvDesignationAmount == null && payDesignationAmount != 0) {
                        System.debug('Missing designationAccount in jvDesignationAmountTotals: ' + designationAccount + ' for payDesignationAmount: ' + payDesignationAmount);
                        // add t0 the jv table by -jvDesignationAmount
                        entryAmount = payDesignationAmount;
                    } else {
                        createJV = false;
                    }

                    if (createJV == true){
                        JVentryRow.jv_status__c = 'new';         
                        //JVentryRow.clearing_account__c = clearingAccount;
                        JVentryRow.designation_amount__c = entryAmount;
                        //JVentryRow.clearing_amount__c = null;
                        JVentryRow.opportunity_name__c = OppName;
                        JVentryRow.designation_account__c = designationAccount;
                        JVentryRow.jv_type__c = dvType;
                        JVentryRow.jv_entry__c = CreateJVEntry( dvType, curGift.ucinn_ascendv2__Donor_ID_Formula__c, JVentryRow.opportunity_name__c, entryAmount, designationAccount, designationDebitCreditInd, DocRefNum);
                        JVentryRow.opportunity_id__c = curGift.id;
                        JVToInsert.add(JVentryRow);
                    }
                }

            }
            else{
               system.debug('opp ' + curGift.name +' was a crt adjustment which does not hit the GL ledger.'); 
            }
            curGift.Needs_G_L_Processing__c = false;
            curGift.gl_processed__c = true;
            oppToUpdate.add(curGift);
            //system.debug('opp id ' + curGift.name);
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
        /*
        if(payToUpdate.size() > 0) {
            List <Database.SaveResult> rt2 = Database.update(payToUpdate, true);
            for ( Database.SaveResult sr2 : rt2) {
                if ( sr2.isSuccess() != true ){
                    for(Database.Error err2 : sr2.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err2.getStatusCode() + ': ' + err2.getMessage());
                        System.debug('Account fields that affected this error: ' + err2.getFields());
                    }
                }
            }
        } */

        if(oppToUpdate.size() > 0) {
            List <Database.SaveResult> rt3 = Database.update(oppToUpdate, true);
            for ( Database.SaveResult sr3 : rt3) {
                if ( sr3.isSuccess() != true ){
                    for(Database.Error err3 : sr3.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err3.getStatusCode() + ': ' + err3.getMessage());
                        System.debug('Account fields that affected this error: ' + err3.getFields());
                    }
                }
            }
        }

        //Database.update(scope, false);
    }

    global void finish(Database.BatchableContext bc) {
        // 
    }
}