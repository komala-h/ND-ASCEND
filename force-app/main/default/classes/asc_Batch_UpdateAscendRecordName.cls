public class asc_Batch_UpdateAscendRecordName implements Database.Batchable<sObject>, Database.Stateful {
    String query;
    Boolean isGift = false;

    public asc_Batch_UpdateAscendRecordName(String qry, Boolean isGift) {
        this.isGift = isGift;
        this.query = qry;
    }

    public asc_Batch_UpdateAscendRecordName(String qry) {
        this.query = qry;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(this.query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> records) {
        Map<String, String> sObjectToAutoNumFieldMap = new Map<String, String>{
                                'ucinn_ascendv2__Address__c' => 'ucinn_ascendv2__Address_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Address_Relation__c' => 'ucinn_ascendv2__Address_Relation_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Affiliation__c' => 'ucinn_ascendv2__Affiliation_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Assignment__c' => 'ucinn_ascendv2__Assignment_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Briefing__c' => 'ucinn_ascendv2__Briefing_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Contact_Name__c' => 'ucinn_ascendv2__Contact_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Contact_Report__c' => 'ucinn_ascendv2__Contact_Report_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Contact_Report_Relation__c' => 'ucinn_ascendv2__Contact_Report_Relation_Auto_Number__c', 
                                'ucinn_ascendv2__Deductions__c' => 'ucinn_ascendv2__Deduction_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Degree_Information__c' => 'ucinn_ascendv2__Degree_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Designation_Beneficiary__c' => 'ucinn_ascendv2__Designation_Beneficiary_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Designation_Detail__c' => 'ucinn_ascendv2__Designation_Detail_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Email__c' => 'ucinn_ascendv2__Email_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Endowment_Financials__c' => 'ucinn_ascendv2__Endowment_Financial_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Funding_Interest__c' => 'ucinn_ascendv2__Funding_Interest_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Hard_and_Soft_Credit__c' => 'ucinn_ascendv2__Hard_and_Soft_Credit_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Installment__c' => 'ucinn_ascendv2__Installment_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Installment_Payment__c' => 'ucinn_ascendv2__Installment_Payment_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Interim__c' => 'ucinn_ascendv2__Interim_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Involvement__c' => 'ucinn_ascendv2__Involvement_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Level_Benefit__c' => 'ucinn_ascendv2__Level_Benefit_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Matching_Gift_Origination__c' => 'ucinn_ascendv2__Matching_Gift_Origin_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Membership_Benefit__c' => 'ucinn_ascendv2__Membership_Benefit_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Account_Name__c' => 'ucinn_ascendv2__Account_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Payment__c' => 'ucinn_ascendv2__Payment_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Phone__c' => 'ucinn_ascendv2__Phone_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Relationship__c' => 'ucinn_ascendv2__Relationship_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Research__c' => 'ucinn_ascendv2__Research_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Salutation__c' => 'ucinn_ascendv2__Salutation_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Service_Indicator__c' => 'ucinn_ascendv2__Service_Indicator_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Session__c' => 'ucinn_ascendv2__Session_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Social_Media__c' => 'ucinn_ascendv2__Social_Media_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Society_Membership__c' => 'ucinn_ascendv2__Society_Membership_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Stock__c' => 'ucinn_ascendv2__Stock_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Stock_Payment__c' => 'ucinn_ascendv2__Stock_Payment_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Strategy__c' => 'ucinn_ascendv2__Strategy_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Team_Lead__c' => 'ucinn_ascendv2__Team_Lead_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Tribute__c' => 'ucinn_ascendv2__Tribute_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Wealth_Rating__c' => 'ucinn_ascendv2__Wealth_Rating_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Work_Plan__c' => 'ucinn_ascendv2__Work_Plan_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Work_Plan_Percentage__c' => 'ucinn_ascendv2__Work_Plan_Percentage_Name_Auto_Number__c', 
                                'ucinn_ascendv2__Work_Plan_Unit_Officer_Assignment__c' => 'ucinn_ascendv2__Work_Pln_Unt_Off_Assig_Name_Auto_Number__c'
                            };

        if (records != null && records.size() > 0) {
            sObject record = records[0];
            Schema.SObjectType sobjType = record.getSObjectType();
            Schema.DescribeSObjectResult sObjDescribe = sobjType.getDescribe();
            String sobjName = sObjDescribe.getName();
            Set<String> sObjFields = sObjDescribe.fields.getMap().keySet();

            if (sobjType == Schema.Opportunity.getSObjectType()) {
                List<Opportunity> oppRecList = (List<Opportunity>) records;
                List<ucinn_ascendv2__Proposal_ID_Generator__c> proposalIdGeneratorList = new List<ucinn_ascendv2__Proposal_ID_Generator__c>();

                for (Opportunity oppRec : oppRecList) {
                    ucinn_ascendv2__Proposal_ID_Generator__c proposalIdRec = new ucinn_ascendv2__Proposal_ID_Generator__c();
                    proposalIdGeneratorList.add(proposalIdRec);
                }

                insert proposalIdGeneratorList;

                proposalIdGeneratorList = [SELECT Id, Name, ucinn_ascendv2__Proposal_ID_Generator_Auto_Number__c FROM ucinn_ascendv2__Proposal_ID_Generator__c WHERE Id IN :proposalIdGeneratorList];

                for (Integer i = 0; i < oppRecList.size(); i++) {
                    Opportunity oppRec = oppRecList[i];
                    oppRec.ucinn_ascendv2__Proposal_ID__c = proposalIdGeneratorList[i].ucinn_ascendv2__Proposal_ID_Generator_Auto_Number__c;
                    oppRec.ucinn_ascendv2__Original_Proposal_ID__c = oppRec.ucinn_ascendv2__Proposal_ID__c;
                    if (isGift) {
                        oppRec.name = 'G' + oppRec.ucinn_ascendv2__Proposal_ID__c;
                    } else {
                        oppRec.name = 'P' + oppRec.ucinn_ascendv2__Proposal_ID__c;
                    }
                }

                update oppRecList;
                delete proposalIdGeneratorList;
            }
            else if (sobjType == Schema.ucinn_ascendv2__Session__c.getSObjectType()) {
                List<ucinn_ascendv2__Session__c> sessionRecList = (List<ucinn_ascendv2__Session__c>) records;

                for (ucinn_ascendv2__Session__c sessionRec : sessionRecList) {
                    sessionRec.name = this.sessionPrefixName(sessionRec) + sessionRec.ucinn_ascendv2__Session_Name_Auto_Number__c;
                }

                update sessionRecList;
            }
            else {
                if (sObjectToAutoNumFieldMap.containsKey(sobjName)) {
                    String autoNumField = sObjectToAutoNumFieldMap.get(sobjName).toLowercase();
                    
                    if (sObjFields.contains(autoNumField)) {
                        for (sObject sObjectRec : records) {
                            String autoNumValue = string.valueOf(sObjectRec.get(autoNumField));
                            sObjectRec.put('Name', autoNumValue);
                        }

                        update records;
                    } else {
                        // Throw Exception Error that the auto number field cannot be found for this sObject
                        TypeException typeEx = new TypeException();
                        typeEx.setMessage('Error: The auto number field cannot be found for your SOQL.');
                        throw typeEx;
                    }
                } else {
                    // Throw Exception Error that the sObject of input query is not supported by this batch
                    TypeException typeEx = new TypeException();
                    typeEx.setMessage('Error: The sObject in your SOQL query is currently not supported by this batch.');
                    throw typeEx;
                }
            }
        }
    }

    public void finish(Database.BatchableContext BC) {

    }

    private String sessionPrefixName(ucinn_ascendv2__Session__c sessionRec) {
        String sessionCreatedYearStr = (String.valueOf(sessionRec.CreatedDate.year()).substring(2,4));
        String sessionCreatedMonthStr = (string.ValueOf(sessionRec.CreatedDate.month()).leftPad(2,'0'));
        String sessionCreatedDayStr = (string.ValueOf(sessionRec.CreatedDate.day()).leftPad(2,'0'));

        return 'S' + sessionCreatedYearStr + sessionCreatedMonthStr + sessionCreatedDayStr;
    }
}