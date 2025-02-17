global class IntegrationConsumerBatch implements Database.Batchable<SObject>, Database.Stateful{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT ID, status__c, json_message__c, process_id__c from Integration_In__c ' +
            'Where status__c IN (\'new\',\'ready\') and process_id__c = null'
     
        );
    }
/*
    public class ResponseResult {
        public Integer count;
        public String next, previous;
        public current_curriculi[] current_curriculum;
        public class current_curriculi {
            public String campus_code, campus_desc
            , classification_code, classification_desc, college_code
            , college_desc, degree_code, degree_desc
            , department_code, department_desc, level_code, level_desc
            , major_code, major_desc, program_code, program_desc, study_type;
            //public Integer cost;
        }
        public static ResponseResult parse(String jsonString) {
            return (ResponseResult)JSON.deserialize(jsonString, ResponseResult.class);
        }
    }*/

    global void execute(Database.BatchableContext bc, List<Integration_In__c> scope){
        system.debug('begin execute method');
        set<string> nonNdIds = new set<string>();
        map<Id, Contact> constMap = new map<Id, Contact>();
        map<Id, map<string, Object>> jsonMap = processNewRecords(scope, nonNdIds, constMap);
        system.debug('step 5');
        List<Integration_In__c> IntList = [Select ID, status__c, json_message__c, process_id__c, Constituent_Id__c, Spouse_Constituent_Id__c, message_id__c, error_message__c
                                           , done_message__c, message_type__c , source_data_set__c , source_system__c from Integration_In__c where status__c = 'in process' and process_id__c = :processId FOR UPDATE ];
        
     
        //id NdOrgId = [select id from account where ucinn_ascendv2__Donor_ID__c='307129'].id;
        id InterimOwnerID = [select id from user where name='Integration Account'].Id;
        id NdOrgDegreeId = [select id from account where institution_code__c='184100' and ucinn_ascendv2__Donor_ID__c='307129'].id;
        //name = 'Integration User'

        //system.debug('step 5.1 lets get the university affil records');
        /* 100% will not work, 
        there are multiple ND employments per constituent in ascend, 0030400000DER1YAAX has 4 employments, either a bug or a unique identifer is necessary*/
        /*
        set<string> constituentIdsAfterProcess = new set <string>();
        constituentIdsAfterProcess = constMap.keySet();
        Map<String, ID> mapAffiliations = new  Map<String, ID>();
        map<Id, ucinn_ascendv2__Affiliation__c> AffilMap = new map<Id, ucinn_ascendv2__Affiliation__c>();
        for (ucinn_ascendv2__Affiliation__c af : [select Id, Name, ND_Employee_Type__c, ucinn_ascendv2__Status__c, ND_Integration_Record_ID__c 
                                                  from ucinn_ascendv2__Affiliation__c where ucinn_ascendv2__Contact__c in :constituentIdsAfterProcess and ucinn_ascendv2__Status__c = 'A' and ucinn_ascendv2__Account__c = :NdOrgId]){
            mapAffiliations.put(ucinn_ascendv2__Contact__c, af.id);
            AffilMap.put(af.Id, af);
        }*/

        map<string, id> DormMap = new map<string, id>();
        for (ucinn_ascendv2__Involvement_Value__c drm : [select Id, Name, ucinn_ascendv2__Code__c,ucinn_ascendv2__Type__c, ucinn_ascendv2__Involvement_Description__c
                                                  from ucinn_ascendv2__Involvement_Value__c where ucinn_ascendv2__Type__c = 'RSD']){
            
            DormMap.put(drm.Name, drm.id);
            }

        map<string, id> ServiceIndicatorMap = new map<string, id>();
        for (ucinn_ascendv2__Service_Indicator_Value__c svc : [select Id, Name, ucinn_ascendv2__Code__c,ucinn_ascendv2__Service_Indicator_Description__c, nd_X18_Digit_Category_ID__c
                                                  from ucinn_ascendv2__Service_Indicator_Value__c]){
            
            ServiceIndicatorMap.put(svc.ucinn_ascendv2__Code__c, svc.id);
        }
        
        map<string, id> DegreeMap = new map<string, id>();
        map<string, string> DegreeDescription = new map<string, string>();
        for( ucinn_ascendv2__Degree_Code__c deg : [select id, ucinn_ascendv2__Degree_Code__c, ucinn_ascendv2__Degree_Level__c, Degree_Code_Description__c
                                                    from ucinn_ascendv2__Degree_Code__c]){
            DegreeMap.put(deg.ucinn_ascendv2__Degree_Code__c, deg.id); 
            DegreeDescription.put(deg.ucinn_ascendv2__Degree_Code__c,deg.Degree_Code_Description__c); 
        }
        
        map<string, id> MajorMap = new map<string, id>();
        map<string, string> MajorDescription = new map<string, string>();
        for( ucinn_ascendv2__Post_Code__c maj : [select id, Major_API_Code__c, ucinn_ascendv2__Post_Code_Description__c
                                                    from ucinn_ascendv2__Post_Code__c]){
            MajorMap.put(maj.Major_API_Code__c, maj.id); 
            MajorDescription.put(maj.Major_API_Code__c,maj.ucinn_ascendv2__Post_Code_Description__c);                                            
        }
        
        map<string, id> MinorMap = new map<string, id>();
        map<string, string> MinorDescription = new map<string, string>();
        for( ucinn_ascendv2__Minor_Code__c min : [select id,Minor_API_Code__c,ucinn_ascendv2__Minor__c,ucinn_ascendv2__Description__c 
                                                 from ucinn_ascendv2__Minor_Code__c]){
            MinorMap.put(min.Minor_API_Code__c, min.id);
            MinorDescription.put(min.Minor_API_Code__c,min.ucinn_ascendv2__Description__c);                                            
        }
		
        map<string, id> ConcentrationMap = new map<string, id>();
        map<string, string> ConcentrationDescription = new map<string, string>();
        for( ucinn_ascendv2__Specialty__c con : [select id,Concentration_Code__c,ucinn_ascendv2__Description__c 
                                                  from ucinn_ascendv2__Specialty__c]){
            ConcentrationMap.put(con.Concentration_Code__c, con.id);
            ConcentrationDescription.put(con.Concentration_Code__c,con.ucinn_ascendv2__Description__c);                                            
        }

        map<string, string> CollegeCodeMap = new map<string, string>();
        for( ucinn_ascendv2__Academic_Organization__c ccd : [select id,ucinn_ascendv2__Code__c from ucinn_ascendv2__Academic_Organization__c where ucinn_ascendv2__Type__c ='degree_college']){
            CollegeCodeMap.put(ccd.ucinn_ascendv2__Code__c, ccd.id);                                            
        }

        map<string, string> DeptCodeMap = new map<string, string>();
        for( ucinn_ascendv2__Academic_Organization__c dcm : [select id,ucinn_ascendv2__Code__c from ucinn_ascendv2__Academic_Organization__c where ucinn_ascendv2__Type__c ='degree_dept']){
            DeptCodeMap.put(dcm.ucinn_ascendv2__Code__c, dcm.id);                                            
        }
        
        //List<Nd_picklist__c> statesLookupQuery = [select code__c from nd_picklist__c where global_master_label__c = 'State Codes'];
        Set<String> statesSet = new Set<String>();
        /*
        for(Nd_picklist__c a : statesLookupQuery){
            statesSet.add(a.code__c);
        }*/

        list<ucinn_ascendv2__Interim__c> justInterims = new list<ucinn_ascendv2__Interim__c>();
        List<ucinn_ascendv2__Review_Transaction_v2__c> RTV2List = new List<ucinn_ascendv2__Review_Transaction_v2__c>();
        map<string, ucinn_ascendv2__Interim__c> newJustInterims = new map<string, ucinn_ascendv2__Interim__c>();
        map<string, ucinn_ascendv2__Degree_Information__c> newJustDegrees = new map<string, ucinn_ascendv2__Degree_Information__c>();
        map<string, ucinn_ascendv2__Involvement__c> newJustInvolvements = new map<string, ucinn_ascendv2__Involvement__c>();
        map<string, ucinn_ascendv2__Service_Indicator__c> newJustServiceIndicators = new map<string, ucinn_ascendv2__Service_Indicator__c>();
        map<string, Alternate_ID__c> newJustAlternateID = new map<string, Alternate_ID__c>();
        // Savannnah Carr 7/30/21 added line below as a test 
        map<string, ucinn_ascendv2__Review_Transaction_v2__c> newJustRTV2 = new map<string, ucinn_ascendv2__Review_Transaction_v2__c>();

        //Added by wayneharpenau
        map<string, Campaign> newCventEventList = new map<string, Campaign>();
        map<string, Campaign> newCventSessionList = new map<string, Campaign>();

        //Added by cube84
        set<String> constIds = new set<String>();
        set<String> InstitutionIds = new set<String>();
        set<String> OrgIds = new set<String>();
        for(Integration_In__c ig :IntList) {
            if(ig.source_data_set__c =='acf_Address__c' || ig.source_data_set__c =='Communication_Method__c'  || ig.source_data_set__c =='Non_ND_Association__c' || ig.source_data_set__c == 'Relationship__c' || ig.source_data_set__c =='Education_History__c'){
                map<string, Object> newMap = jsonMap.get(ig.Id);
                Map<String, Object> event = (Map<String, Object>) newMap.get('event');
                Map<String, Object> target = (Map<String, Object>) newMap.get('target');
                constIds.add((string) target.get('Constituent_ID__c'));
				
				if( ig.source_data_set__c == 'Non_ND_Association__c'){
                    OrgIds.add((string) target.get('Organisation_ID__c'));
                }
				                
                if( ig.source_data_set__c == 'Relationship__c'){
                    constIds.add((string) target.get('Related_Constituent_Id__c'));
                }
                if( ig.source_data_set__c == 'Education_History__c'){
                    InstitutionIds.add((string) target.get('Institution_Code__c'));
                }
                
            }
        }
        Map<String,ID> constituentDonorMap = new Map<String,ID>();
        Map<String,ID> InstitutionMap = new Map<String,ID>();
        Map<String,ID> orgDonorMap = new Map<String,ID>();
        
        for (Contact con : [select id,ucinn_ascendv2__Donor_ID__c from Contact where ucinn_ascendv2__Donor_ID__c in :constIds]) {
    		constituentDonorMap.put(con.ucinn_ascendv2__Donor_ID__c, con.Id);
		}
        
       for (Account acc : [select id,Institution_Code__c from Account where Institution_Code__c in:InstitutionIds]) {
    		InstitutionMap.put(acc.Institution_Code__c, acc.Id);
		} 
        
        for (Account acc : [select id,ucinn_ascendv2__Donor_ID__c from Account where ucinn_ascendv2__Donor_ID__c in:OrgIds]) {
    		orgDonorMap.put(acc.ucinn_ascendv2__Donor_ID__c, acc.Id);
		} 
        
        //
        
        for(Integration_In__c ints :IntList) {
            try {
               map<string, Object> newMap = jsonMap.get(ints.Id);
                Map<String, Object> event = (Map<String, Object>) newMap.get('event');
                Map<String, Object> target = (Map<String, Object>) newMap.get('target');
                
                string messageId = (string) event.get('event_sequence_number');

                list<Object> changedList = newmap.containsKey('changed') ? (list<Object>)newmap.get('changed') : new list<Object>();
                list<string> changed = new list<string>();
                for(Object o : changedList) {
                	changed.add((string)o);        
                }
                
                string updated_fields_list = null;
                if (changed != null){
                	 updated_fields_list = string.join(changed, ',');
                }
                
                //constants
                string Constituent_Status = null;
                String invalidNumbers = '[^0-9]';

                if (ints.source_data_set__c != 'person bio new'){
                	 Constituent_Status = constMap.get(ints.Constituent_Id__c)?.Constituent_Status__c;
                }

                //system.debug('Constituent_Status - '+Constituent_Status);
                if (Constituent_Status == 'X' || Constituent_Status == 'F' ) {
                    
                    //system.debug('lost or deceased constituent');
                	ints.status__c = 'Done';
                	ints.done_message__c ='change was ignored, constituent is Purged or Defunct';   
                    
                     } else {
                        
                        boolean possible_dupe = false;
                        if (ints.Constituent_Id__c != null){
                            possible_dupe = true;
                        }
                        string ConstituentStatusProgrammatic;
                        if (Constituent_Status == 'D' ) {
                            ConstituentStatusProgrammatic = 'D';
                        } else {
                            ConstituentStatusProgrammatic = 'A';
                        }

                        //
                         //get our picklist lookup obj
                         //List<Nd_picklist__c> pikclistLookup = nd_picklist_desc_to_code();
                         //this may need to be a map so i can set a lookup id then get value like <map<string (concatenate obj+field+description) , string (code)>
                         //DOES NOT WORK TOO MANY ROWS 50001
                         //Map<string, string> ndPicklistLookup = ndPickListforLookup();
                         //usage ndPicklistLookup.get() wait wht aout codes being sent how does this help

                         if (ints.source_data_set__c == 'employee sync' ){
                            string eclass = (string) target.get('eclass');
                            if (eclass == 'R2') {
                                ints.status__c = 'Discard';
                                ints.done_message__c ='message discarded, R2 surviving ';
                                } else {
                     
                             ucinn_ascendv2__Interim__c ic = new ucinn_ascendv2__Interim__c();
                             ic.ucinn_ascendv2__Possible_Duplicate_Checked__c = possible_dupe;
                             ic.message_id__c	= messageId;
                             ic.Message_Event_type__c = ints.message_type__c;
                             ic.ucinn_ascendv2__external_system_id__c = 'WKDY-'+messageId;
                             // ints.source_system__c should equal banner but theres no good way to translate that, so B is for banner 
                             string data_source_constant = 'B';
                             ic.ND_data_source_code__c = data_source_constant;
                             ic.nd_Affiliation_Data_Source_1__c = data_source_constant;
                             ic.ucinn_ascendv2__Contact__c =  ints.Constituent_Id__c;
                             ic.Integration_In_id__c = ints.Id;
                             ic.ND_Constituent_status__c = ConstituentStatusProgrammatic;
                             ic.OwnerId = InterimOwnerID;
                             ic.ucinn_ascendv2__School_ID__c=(string) target.get('netid');
                             ic.ucinn_ascendv2__Employee_ID__c =(string) target.get('ndid');
                             string uniqId = ic.ucinn_ascendv2__School_ID__c+ic.ucinn_ascendv2__Employee_ID__c;
                             ic.ucinn_ascendv2__Employer_Account__c = NdOrgId;

                             
                             /** no need for metadata ,seems like only one retiree eclass */
                             set<string> fieldListRetiree= new set<string>{'eclass'};
                             boolean eclassCheck = false;

                             for(Object str : changed) {
                                string field = (string)str;
                                if(fieldListRetiree.contains(field)) {
                                    eclassCheck = true;
                                    system.debug('check eclass for retiree');
                                    //break;
                                }
                             }
                             
                              if (eclass == 'R1') {    
                                ic.ucinn_ascendv2__Employee_Type__c = 'Retired Employee'; //RE
                                ic.nd_Affiliation_Constituent_Role_1__c='Retired Employee';
                                ic.ucinn_ascendv2__Is_Retiree__c = true;
                                ic.ND_Constituent_Type__c = 'ER';
                             } else {
                                 ic.ucinn_ascendv2__Employee_Type__c = 'Employee'; //EM
                                 ic.nd_Affiliation_Constituent_Role_1__c = 'Employee';
                                 ic.ucinn_ascendv2__Is_Retiree__c = false;
                                 ic.ND_Constituent_Type__c = 'EM';
                             }

                            if ((string) event.get('event_type') == 'D'){
                                // data sources for these items?
                                //delete message , termination of employee , the separation reason = null, seapration reason = Deceased gets death
                                
                                ic.ND_Banner_Id__c = (string) event.get('event_id');
                                ic.ND_Constituent_Type__c = 'EF';

                                if ( (string) target.get('separation_reason') == 'Deceased'){
                                    string deathDateString = (string) target.get('death_date');
                                    date deathdate = stringToDate(deathDateString);
                                    ic.Death_Date__c = deathdate; //stringToDate(deathDateString);
                                    if(deathdate != null) {
                                    ic.nd_deceased_month__c = (deathdate.month() < 10 ?  ('0' + string.valueOf(deathdate.month())) : string.valueOf(deathdate.month()));
                                    ic.nd_deceased_day__c = ( deathdate.day() < 10 ? ('0' + string.valueOf(deathdate.day()) ) : string.valueOf(deathdate.day()) );
                                    ic.nd_deceased_year__c = deathdate.year().format().remove(',');
                                    }
                                    ic.ND_Constituent_status__c = 'D';
                                    ic.ucinn_ascendv2__Status__c = 'Manual Review'; //Pending
                                    //ic.ucinn_ascendv2__Possible_Duplicate_Checked__c = false;
                                    ic.ucinn_ascendv2__Manual_Review_Reason_Multiple_Line__c ='Deceased messages get set to Manual Review';
                                    //dont need this below because this will be automatically be picked up flow or trigger or whatever
                                    //ic.nd_Affiliation_Status_1__c ='Active at time of Death'; //what if this desc changes =/

                                } else if ( (string) target.get('separation_reason') == null ){
                                    //were assuming this is termination
                                    //no longer needed , WKDY takes place of BAUX
                                    //ic.ucinn_ascendv2__external_system_id__c = 'BAUX-'+messageId;

                                    //**** is this still viable? -> if clause here if i have constituent id, pending and true if exists, new and false if not
                                    //ic.ucinn_ascendv2__Possible_Duplicate_Checked__c = false;
                                    ic.ucinn_ascendv2__Status__c = 'New'; //Pending                                    
                                    
                                    ic.nd_Affiliation_Status_1__c='Former'; //Inactive
                                    ic.nd_Affil_End_Date_1__c = system.today(); //unless its supplied

                                }
                                //manually add employer
   
                                newJustInterims.put('employeeAutoSync'+ic.ucinn_ascendv2__School_ID__c+ints.source_data_set__c, ic);
                                
                            } else {
                                if ((string) event.get('event_type') == 'I'){
                                ic.nd_Affil_Start_Date_1__c = system.today();
                                }
                             ic.ND_Employee_Verified_Date__c = system.today();                            
                            //all automatic interim
                             //insert or update message
                             Id EmployeeSyncRecordTypeId = 
                             ucinn_ascendv2__Interim__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Workday_Interface').getRecordTypeId();
                             ic.RecordTypeId = EmployeeSyncRecordTypeId;

                             string home_phone = (string) target.get('home_phone');
                             string office_phone = (string) target.get('office_phone');
                             string international_phone = (string) target.get('international_phone');                            
                             

                             ic.updated_field_list__c = updated_fields_list;
                             //place in a map of ids and affil records
                             ic.Constituent_Type_from_Interim_Auto__c = true;
                             /*
                             if (eclassCheck == true && eclass == 'R1'){
                                //remove this field from the logic and the page layout
                                 ic.ucinn_ascendv2__Employee_Type__c = 'Retired Employee'; //RE
                                 ic.nd_Affiliation_Constituent_Role_1__c='Retired Employee';
                                 ic.ucinn_ascendv2__Is_Retiree__c = true;
                                 // wait so does this auto init? seems problematic
                                 //so i put in the if statement, and created a field but there was 3 fields already, so im not sure if field 1 is ok here
                                 // removed? 4/14/2023
                                 //ic.nd_Affil_End_Date_1__c = updated_fields_list.contains('eclass') ? system.today() : null;
                                 
                                 // removed? 4/14/2023
                                 //ic.nd_Affiliation_Status_1__c='Former';
                                 ic.ND_Constituent_Type__c = 'ER';
                             } else if (eclassCheck == false && eclass == 'R1') {
                                ic.ucinn_ascendv2__Employee_Type__c = 'Retired Employee'; //RE
                                ic.nd_Affiliation_Constituent_Role_1__c='Retired Employee';
                                ic.ucinn_ascendv2__Is_Retiree__c = true;
                                // removed? 4/14/2023
                                //ic.nd_Affiliation_Status_1__c='Former';
                                ic.ND_Constituent_Type__c = 'ER';
                            */
                            

                             ic.nd_Affiliation_Status_1__c='Current';

                            /* string eclassDesc = (string) target.get('eclass_desc');
                             Boolean eclassDescCheckForFT = eclassDesc.contains('FT');
                             ic.ucinn_ascendv2__Is_Employed_By_University__c = eclassDescCheckForFT;*/

                             string eclassDesc = (string) target.get('eclass_desc');
                             string commType;
                             string emailType;
                             boolean eclassDescCheckForFT = false;
                             boolean isPrimary = false;
                                if(eclassDesc.contains('FT') || eclass=='R1') {
                                    eclassDescCheckForFT = true;
                                    system.debug('eclassDescCheckForFT: '+eclassDescCheckForFT);
                                    commType = 'B';
                                    emailType ='U';
                                } else {
                                    commType = 'O';
                                    emailType ='O';
                                }

                            if(eclassDesc.contains('FT')) {
                                isPrimary =true;
                            }
                            ic.nd_Is_Primary_Employment__c = isPrimary;

                            ic.ucinn_ascendv2__Is_Employed_By_University__c = eclassDescCheckForFT;
                            ic.nd_primary_college_school__c = (string) target.get('primary_college_school');

                             /*if ( deathDate != null && updated_fields_list.contains('death_date')){
                                 ic.Death_Date__c = deathDate;
                                 ic.nd_Affiliation_Status_1__c ='Active at time of Death';

                             }*/
                               //default to main notre dame account , weird that 851377 is parent account in ascend?
                             
                               ic.ucinn_ascendv2__Employer_Account__c = NdOrgId;//[select id from account where ucinn_ascendv2__Donor_ID__c='307129'];
                               //other possible ic.ucinn_ascendv2__Employer__c? or ucinn_ascendv2__Account__c which is a lookup
                               ic.ucinn_ascendv2__Address_1_Line_1__c = (string) target.get('home_street_line1');
                               ic.ucinn_ascendv2__Address_1_Line_2__c = (string) target.get('home_street_line2');
                               ic.ucinn_ascendv2__Address_1_Line_3__c = (string) target.get('home_street_line3');
                               ic.ucinn_ascendv2__City_1__c  = (string) target.get('home_city');
                               if( (string) target.get('home_natn_code') == null){
                                if((string) target.get('home_state') != null){
                                    ic.ucinn_ascendv2__Country_1__c = 'US';
                                    /*
                                   if(statesSet.contains((string) target.get('home_state')) == true){
                                        ic.ucinn_ascendv2__Country_1__c = 'US';
                                    }*/
                                }
                               } else {
                                ic.ucinn_ascendv2__Country_1__c = (string) target.get('home_natn_code');
                               }
                               
                               ic.ucinn_ascendv2__State_1__c = (string) target.get('home_stat_code');
                               ic.ucinn_ascendv2__Postal_Code_1__c = (string) target.get('home_zip');
                               ic.ucinn_ascendv2__Address_1_Type__c = (string) target.get('home_street_line1') == null ? null : 'Home';
                               ic.ND_Address_1_Type__c = (string) target.get('home_street_line1') == null ? null : 'H'; //'Home'
                               /*ic.ND_Address_1_Type__c = (string) target.get('address_street_line1') == null
                             || (string) target.get('address_street_line2') == null 
                             || (string) target.get('address_street_line3') == null
                             || (string) target.get('address_city') == null
                             || (string) target.get('address_nation') == null
                             || (string) target.get('address_state') == null
                             || (string) target.get('address_zip') == null 
                             ? null : 'H'; //H is the code for Home NOTICE i like this better i want to use this ??(string) target.get('address_type');*/
                               if (ic.ND_Address_1_Type__c != null){
                                ic.ND_Address_1_Data_Source_Abbrev__c = data_source_constant;
                               }
  
                               
                               /*
                               String invalidNumbers = '[^0-9]';
                               String str = 'abcd123456789xyz';
                               system.debug( 'Only numbers - ' + str.replaceAll( invalidNumbers, '' ) );
                               */
  
                              ic.ucinn_ascendv2__Phone_1__c = home_phone == null ? null : home_phone.replaceAll( invalidNumbers, '' );//home_phone == null ? null : home_phone.replace('+', ' ');
                              ic.ucinn_ascendv2__Phone_1_Type__c =   home_phone == null ? null :'Home'; //translated in metadata field 
                              ic.ND_Phone_1_Type__c =   home_phone == null ? null :'H'; //translated in metadata field
                              ic.ND_Phone_1_Data_Source_Abbrev__c = home_phone == null ? null : data_source_constant;
                              ic.ND_Phone_1_Status__c =  home_phone == null ? null : 'Current'; 
                              if ( ic.updated_field_list__c.contains('home_phone') && home_phone == null){
                                ic.ND_Phone_1_Status__c = 'Former';
                               }

                              ic.ucinn_ascendv2__Address_2_Line_1__c  = (string) target.get('office_street_line1');
                              ic.ucinn_ascendv2__Address_2_Line_2__c  = (string) target.get('office_street_line2');
                              ic.ucinn_ascendv2__Address_2_Line_3__c  = (string) target.get('office_street_line3');
                              ic.ucinn_ascendv2__City_2__c  = (string) target.get('office_city');
                              ic.ucinn_ascendv2__Country_2__c = (string) target.get('office_natn_code');
                              if( (string) target.get('office_natn_code') == null){
                                if((string) target.get('office_stat_code') != null){
                                    ic.ucinn_ascendv2__Country_2__c = 'US';
                                    /*
                                    if(statesSet.contains((string) target.get('office_stat_code')) == true){
                                        ic.ucinn_ascendv2__Country_2__c = 'US';
                                    }*/
                                }
                               } else {
                                ic.ucinn_ascendv2__Country_2__c = (string) target.get('office_natn_code');
                               }
                              ic.ucinn_ascendv2__State_2__c = (string) target.get('office_stat_code');
                              ic.ucinn_ascendv2__Postal_Code_2__c = (string) target.get('office_zip');
                              ic.ucinn_ascendv2__Address_2_Type__c =(string) target.get('office_street_line1') == null ? null : 'Business';
                        
                              ic.ND_Address_2_Type__c =(string) target.get('office_street_line1') == null ? null : commType; //'B'; //Business
                              /*ic.ND_Address_2_Type__c = (string) target.get('office_street_line1') == null
                             || (string) target.get('office_street_line2') == null 
                             || (string) target.get('office_street_line3') == null
                             || (string) target.get('office_city') == null
                             || (string) target.get('office_natn_code') == null
                             || (string) target.get('office_stat_code') == null
                             || (string) target.get('office_zip') == null 
                             ? null : 'B'; //B is the code for Business (string) target.get('address_type');*/
                             if (ic.ND_Address_2_Type__c != null){
                                ic.ND_Address_2_Data_Source__c = data_source_constant;
                                ic.ND_Address_from_Interim_Auto_Affiliation__c = true;
                               }
  

                              ic.ucinn_ascendv2__Phone_2__c =   office_phone == null ? null : office_phone.replaceAll( invalidNumbers, '' );//office_phone == null ? null : office_phone.replace('+', ' ');                             
                              ic.ucinn_ascendv2__Phone_2_Type__c =  office_phone == null ? null : 'Business'; //translated in metadata field
                              
                              ic.ND_Phone_2_Type__c =  office_phone == null ? null : commType; //'B'; //translated in metadata field
                              if (ic.ND_Phone_2_Type__c != null){
                                ic.ND_Phone_2_Data_Source__c = data_source_constant;
                                ic.ND_Phone_from_Interim_Auto_Affiliation__c = true;
                              }
                              ic.ND_Phone_2_Status__c =  office_phone == null ? null : 'Current';                             
                               if ( ic.updated_field_list__c.contains('office_phone') && office_phone == null){
                                ic.ND_Phone_2_Status__c = 'Former';
                               }
                              //ic.ND_Phone_2_Data_Source__c = office_phone == null ? null : ic.ND_data_source_code__c;

                              ic.ucinn_ascendv2__First_Name__c=(string) target.get('first_name');
                              ic.ucinn_ascendv2__Last_Name__c=(string) target.get('last_name');
                              ic.ucinn_ascendv2__Middle_Name__c=(string) target.get('middle_name');
                              ic.ucinn_ascendv2__Gender__c=(string) target.get('gender_code');
                              //ic.ucinn_ascendv2__Salutation__c=(string) target.get('name_prefix');
                              ic.ucinn_ascendv2__Prefix__c=(string) target.get('prefix');
                              ic.ucinn_ascendv2__Suffix__c=(string) target.get('name_suffix');
                              ic.ucinn_ascendv2__Gender__c = (string) target.get('gender');
                              
                              //ic.Death_Date__c = deathDate;
                              ic.ucinn_ascendv2__Email_1__c = (string) target.get('email_address');
                              ic.ucinn_ascendv2__Email_1_Type__c = (string) target.get('email_address')  == null ? null : 'Business Email'; //'Personal'; //definately look up this value
                              ic.ND_Email_1_Type__c = (string) target.get('email_address')  == null ? null : emailType; //'U'; //Personal
                              if (ic.ND_Email_1_Type__c != null){
                                ic.ND_Email_1_Data_Source__c = data_source_constant;
                                ic.ND_Email_from_Interim_Auto_Affiliation__c = true;
                              }
                              
                              //ic.ND_data_source_code__c;

                              ic.ucinn_ascendv2__Phone_3__c = international_phone == null ? null : international_phone.replaceAll( invalidNumbers, '' );//international_phone == null ? null : international_phone.replace('+', ' ');
                              ic.ucinn_ascendv2__Phone_3_Type__c = international_phone == null ? null : 'I'; //no value for international on picklist
                              ic.ND_Phone_3_Data_Source__c = international_phone == null ? null : data_source_constant;

                              ic.College_Code__c = (string) target.get('primary_college_school');
                              ic.ucinn_ascendv2__Home_Department_Code__c = (string) target.get('primary_department');
                              ic.ucinn_ascendv2__Home_Department_Name__c = (string) target.get('primary_department_description');
                              //ic.nd_primary_college_school__c = (string) target.get('primary_college_school');
                              ic.nd_primary_job_title__c = (string) target.get('primary_job_title');
                              ic.ND_Eclass__c = (string) target.get('eclass'); //or the eclass var
                              ic.ND_Eclass_Description__c = (string) target.get('eclass_desc');

                              ic.nd_Affiliation_Status_1__c ='Current';
                              if (ic.ucinn_ascendv2__School_ID__c != null){
                                ic.ND_Alternate_ID_Type_2__c ='NET';
                              }

                              if (ic.ucinn_ascendv2__Employee_ID__c != null){
                                ic.ND_Alternate_ID_Type_1__c ='NID';
                              }
                              /*
                              //ic.nd_Affiliation_Constituent_Role_1__c = 'Employee';

                              //if involvement exists
                             if(ic.ucinn_ascendv2__Employee_ID__c != null){
                                Alternate_ID__c iv = new Alternate_ID__c();
                                iv.Other_ID__c = ic.ucinn_ascendv2__Employee_ID__c;
                                iv.ID_Type__c = 'NID';
                                iv.Constituent__c = ic.ucinn_ascendv2__Contact__c;
                                //field not listed yet iv.ucinn_ascendv2__Type__c = 'RES';                                
                                iv.nd_Interim__r = ic;

                                newJustAlternateID.put('altID_ndid_'+ic.ucinn_ascendv2__School_ID__c+ints.source_data_set__c, iv);
                             }
                             if(ic.ucinn_ascendv2__School_ID__c != null){
                                Alternate_ID__c iv = new Alternate_ID__c();
                                iv.Other_ID__c = ic.ucinn_ascendv2__School_ID__c;
                                iv.ID_Type__c = 'NET';
                                iv.Constituent__c = ic.ucinn_ascendv2__Contact__c;
                                //field not listed yet iv.ucinn_ascendv2__Type__c = 'RES';                                
                                iv.nd_Interim__r = ic;

                                newJustAlternateID.put('altID_netid_'+ic.ucinn_ascendv2__School_ID__c+ints.source_data_set__c, iv);
                             }*/
                              //manually add employer 
 
                              newJustInterims.put('employeeSync_'+ic.ucinn_ascendv2__School_ID__c+ints.source_data_set__c, ic);  
                              
                             }
                            }
                        } else if (ints.source_data_set__c == 'person experience change' ){
                                ucinn_ascendv2__Interim__c ic = new ucinn_ascendv2__Interim__c();
                                ic.ucinn_ascendv2__Possible_Duplicate_Checked__c = possible_dupe;
                                ic.RecordTypeId =  ucinn_ascendv2__Interim__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Hivebrite_Employment_sync').getRecordTypeId();
                                ic.Integration_In_id__c = ints.Id;
                                ic.ND_hivebrite_create_from_id__c = string.valueOf((integer) event.get('event_id'));
                                ic.ucinn_ascendv2__Contact__c =  ints.Constituent_Id__c;
                                ic.ucinn_ascendv2__Status__c = 'Manual Review';
                                ic.updated_field_list__c = updated_fields_list;
                                string eventDate = (string) event.get('event_time');
                                ic.update_datetime__c = stringToDate(eventDate);
                                ic.message_id__c	= messageId;
                                ic.Message_Event_type__c = ints.message_type__c;
                                ic.ucinn_ascendv2__external_system_id__c = 'HEMP-'+messageId;
                                ic.ND_data_source_inbound__c = data_source_constant_hivebrite;
                                ic.OwnerId = InterimOwnerID;

                                ic.nd_Employer_Name_2__c = (string) target.get('employer_name');
                                ic.nd_Employer_Name_3__c = (string) target.get('employer_name_description');
                                //not needed ALWAYS EP ic.ucinn_ascendv2__Employee_Type__c = (string) target.get('employment_type');
                                ic.nd_Affil_Start_Date_1__c = stringToDate((string) target.get('from'));
                                ic.nd_Affil_End_Date_1__c = stringToDate((string) target.get('to'));
                                ic.nd_primary_job_title__c = (string) target.get('job_title');
                                //not needed ic.ucinn_ascendv2__Organization_Industry__c = (string) target.get('industry');
                                //ic = (string) target.get('job_function');


                                
                                newJustInterims.put('hivebrite_exp_'+ic.ucinn_ascendv2__Contact__c+ints.source_data_set__c, ic);

                         }
                         // Added by cube84
                         else if(ints.source_data_set__c == 'acf_Address__c' && ints.message_type__c=='I'){
                             ucinn_ascendv2__Interim__c ic = new ucinn_ascendv2__Interim__c();
                             ic.RecordTypeId =  ucinn_ascendv2__Interim__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('CrmND_Address').getRecordTypeId();
                             ic.Integration_In_id__c = ints.Id;
                             ic.Migration_Source__c=ints.Id;
                             ic.ucinn_ascendv2__Status__c = 'New';
                             ic.message_id__c	= messageId;
                             ic.Message_Event_type__c = ints.message_type__c;
                             ic.OwnerId = InterimOwnerID;
                             
                             String AddressType = (string) target.get('Address_Type__c') == null ? null : (string) target.get('Address_Type__c'); 
                             if(AddressType=='S'){
                                 ic.ND_Address_1_Type__c = 'Seasonal';
                             }else{
                                 ic.ND_Address_1_Type__c =AddressType;
                             }
                                                       
                             ic.nd_Address_1_Status__c = (string) target.get('Address_Status__c') == null ? null : (string) target.get('Address_Status__c');
                             ic.ucinn_ascendv2__Address_1_Line_1__c = (string) target.get('MailingStreet__c');
                             ic.ucinn_ascendv2__Address_1_Line_2__c = (string) target.get('MailingStreet2__c');
                             ic.ucinn_ascendv2__Address_1_Line_3__c = (string) target.get('MailingStreet3__c');
                             ic.ucinn_ascendv2__City_1__c = (string) target.get('MailingCity__c');
                             ic.ucinn_ascendv2__State_1__c = (string) target.get('State__c') == null ? null : (string) target.get('State__c');
                             ic.ucinn_ascendv2__Postal_Code_1__c = (string) target.get('MailingPostalCode__c');
                             ic.ucinn_ascendv2__Country_1__c = (string) target.get('Country__c') == null ? null : (string) target.get('Country__c');
                             ic.nd_Preferred_Address__c = (Boolean) target.get('Preferred_Address__c');
                             ic.ND_Address_1_Data_Source__c = (string) target.get('Original_Source_Code__c') == null ? null : (string) target.get('Original_Source_Code__c');
                             ic.ucinn_ascendv2__Supervisor_Comments__c = (string) target.get('Comments__c');
                             // need to put logic for employment record
                             ic.ucinn_ascendv2__Donor_ID__c = (string) target.get('Constituent_ID__c');
                             String constId = (string) target.get('Constituent_ID__c');
                             if(constId !=''|| constId != null){
                                 ic.ucinn_ascendv2__Contact__c = constituentDonorMap.get(constId);
                             }
                             
                             String startDateString = (string) target.get('Address_Start_Date__c');
                             if(startDateString!=''){
                                 List<String> dateParts = startDateString.split('-');
                                 Integer year = Integer.valueOf(dateParts[0]);
                                 Integer month = Integer.valueOf(dateParts[1]);
                                 Integer day = Integer.valueOf(dateParts[2]);
                                 Date parsedDate = Date.newInstance(year, month, day);
                                 ic.nd_Address_1_Start_Date__c = parsedDate;
                             }
                             else{
                                 ic.nd_Address_1_Start_Date__c = null;
                             }
                             
                             String endDateString = (string) target.get('Address_End_Date__c');
                             if(endDateString!=''){
                                 List<String> dateParts = endDateString.split('-');
                                 Integer year = Integer.valueOf(dateParts[0]);
                                 Integer month = Integer.valueOf(dateParts[1]);
                                 Integer day = Integer.valueOf(dateParts[2]);
                                 
                                          
                                 Date parsedDate = Date.newInstance(year, month, day);
                                 ic.nd_Address_1_End_Date__c = parsedDate;
                             }
                             else{
                                 ic.nd_Address_1_End_Date__c = null;
                             }
                             
                             String SeasonalStartDateString = (string) target.get('System_Start_Date__c');			
                             if(SeasonalStartDateString!=''){
                                 List<String> dateParts = SeasonalStartDateString.split('-');
                                  ic.Seasonal_Start_Year__c = dateParts[0];
                                 ic.ND_Seasonal_Start_Month_1__c = dateParts[1];
                                 ic.ND_Seasonal_Start_Day_1__c = dateParts[2];
                             }
                      		 
                             String SeasonalEndDateString = (string) target.get('System_End_Date__c');			
                             if(SeasonalEndDateString!=''){
                                 List<String> dateParts = SeasonalEndDateString.split('-');
                                 ic.Seasonal_End_Year__c = dateParts[0];
                                 ic.ND_Seasonal_End_Month_1__c = dateParts[1];
                                 ic.ND_Seasonal_End_Day_1__c = dateParts[2];
                             }
                  
                             newJustInterims.put('crmNDAddress'+ic.ucinn_ascendv2__Contact__c+ints.source_data_set__c, ic);
                         }
                         // added by cube84
                         else if(ints.source_data_set__c == 'Communication_Method__c' && ints.message_type__c=='I'){
                             ucinn_ascendv2__Interim__c ic = new ucinn_ascendv2__Interim__c();
                             ic.RecordTypeId =  ucinn_ascendv2__Interim__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('CrmND_Communication_Method').getRecordTypeId();
                             ic.Integration_In_id__c = ints.Id;
                             ic.Migration_Source__c=ints.Id;
                             ic.ucinn_ascendv2__Status__c = 'New';
                             ic.message_id__c	= messageId;
                             ic.Message_Event_type__c = ints.message_type__c;
                             ic.OwnerId = InterimOwnerID;
                             ic.ucinn_ascendv2__Donor_ID__c = (string) target.get('Constituent_ID__c');
                             String constId = (string) target.get('Constituent_ID__c');
                             if(constId !=''|| constId != null){
                                 ic.ucinn_ascendv2__Contact__c = constituentDonorMap.get(constId);
                             }
                             // Email requests
                             if(  ((string) target.get('Email_Address__c')!='') && ((string) target.get('Phone_Type__c')=='') ){
                                 String emailStatus = (string) target.get('Status__c') == null ? null : (string) target.get('Status__c');
                                 if(emailStatus!=null){
                                     if(emailStatus=='A'){
                                         ic.ND_Email_1_Status__c = 'Current';
                                     }
                                     else{
                                         ic.ND_Email_1_Status__c ='Former' ;
                                     }
                                 }else{
                                     ic.ND_Email_1_Status__c = null;
                                 }
                                 
                                 String startDateString = (string) target.get('Start_Date__c');
                             	 if(startDateString!=''){
                                 	List<String> dateParts = startDateString.split('-');
                                 	Integer year = Integer.valueOf(dateParts[0]);
                                 	Integer month = Integer.valueOf(dateParts[1]);
                                 	Integer day = Integer.valueOf(dateParts[2]);
                                 	Date parsedDate = Date.newInstance(year, month, day);
                                 	ic.ND_Email_Start_Date_1__c = parsedDate;
                             	 }
                             	 else{
                                 	ic.ND_Email_Start_Date_1__c = null;
                             	 }
                             	 
                                 String endDateString = (string) target.get('Stop_Date__c');
                                 if(endDateString!=''){
                                 	List<String> dateParts = endDateString.split('-');
                                 	Integer year = Integer.valueOf(dateParts[0]);
                                 	Integer month = Integer.valueOf(dateParts[1]);
                                 	Integer day = Integer.valueOf(dateParts[2]);
                                 	Date parsedDate = Date.newInstance(year, month, day);
                                 	ic.nd_Affil_End_Date_1__c = parsedDate;
                             	}
                             	else{
                                 	ic.nd_Affil_End_Date_1__c = null;
                             	}
                                 
                             	ic.ND_Notes__c = (string) target.get('Comments__c');
                            	ic.ND_Email_1_Type__c = (string) target.get('Email_Type__c') == null ? null : (string) target.get('Email_Type__c');
                             	ic.ucinn_ascendv2__Email_1__c = (string) target.get('Email_Address__c');	
                             	ic.ND_Preferred_Email_1__c = (Boolean) target.get('Preferred_Email__c');
                             	ic.ND_Email_1_Data_Source__c = (string) target.get('Original_Source_Code__c') == null ? null : (string) target.get('Original_Source_Code__c');
                           	 }
                             // Phone requests
                             else if (((string) target.get('Email_Address__c')=='') && ((string) target.get('Phone_Type__c')!='') ){
                                 ic.ND_Phone_2_Type__c = (string) target.get('Phone_Type__c') == null ? null : (string) target.get('Phone_Type__c');
								 String phoneStatus = (string) target.get('Status__c') == null ? null : (string) target.get('Status__c');
                                 if(phoneStatus!=null){
                                     if(phoneStatus=='A'){
                                         ic.ND_Phone_1_Status__c = 'Current';
                                     }
                                     else{
                                         ic.ND_Phone_1_Status__c ='Former' ;
                                     }
                                 }else{
                                     ic.ND_Phone_1_Status__c = null;
                                 }
                                                                                                  
								ic.ucinn_ascendv2__Phone_2__c = (string) target.get('Phone_Number__c');
                                 
								string startDateString = (string) target.get('Start_Date__c');
                                 if(startDateString!=''){
                                 	List<String> dateParts = startDateString.split('-');
                                 	Integer year = Integer.valueOf(dateParts[0]);
                                 	Integer month = Integer.valueOf(dateParts[1]);
                                 	Integer day = Integer.valueOf(dateParts[2]);
                                 	Date parsedDate = Date.newInstance(year, month, day);
                                 	ic.nd_Affil_Start_Date_1__c = parsedDate;
                             	}
                             	else{
                                 	ic.nd_Affil_Start_Date_1__c = null;
                             	}
                                 
								string endDateString = (string)target.get('Stop_Date__c');
                                 if(endDateString!=''){
                                 	List<String> dateParts = endDateString.split('-');
                                 	Integer year = Integer.valueOf(dateParts[0]);
                                 	Integer month = Integer.valueOf(dateParts[1]);
                                 	Integer day = Integer.valueOf(dateParts[2]);
                                 	Date parsedDate = Date.newInstance(year, month, day);
                                 	ic.nd_Affil_End_Date_1__c = parsedDate;
                             	}
                             	else{
                                 	ic.nd_Affil_End_Date_1__c = null;
                             	}
                                                                  
								ic.Seasonal_End_Date__c = (string) target.get('Seasonal_End_Date__c');
								ic.Seasonal_Start_Date__c = (string) target.get('Seasonal_Start_Date__c');
								ic.ND_Preferred_Phone_1__c = (Boolean) target.get('Preferred_Phone__c');
								ic.ND_Notes__c = (string) target.get('Comments__c');                                 
                             }
                             newJustInterims.put('crmNDCommunicationmethod'+ic.ucinn_ascendv2__Contact__c+ints.source_data_set__c, ic);
                         }
                         // Added by Cube84
                         else if(ints.source_data_set__c == 'Non_ND_Association__c'){
                             ucinn_ascendv2__Interim__c ic = new ucinn_ascendv2__Interim__c();
                             ic.RecordTypeId =  ucinn_ascendv2__Interim__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('CrmND_Affiliation').getRecordTypeId();
                             ic.Integration_In_id__c = ints.Id;
                             ic.Migration_Source__c=ints.Id;
                             ic.ucinn_ascendv2__Status__c = 'Manual Review';
                             ic.message_id__c	= messageId;
                             ic.Message_Event_type__c = ints.message_type__c;
                             ic.OwnerId = InterimOwnerID;
                                                          
                             ic.ucinn_ascendv2__Donor_ID__c = (string) target.get('Constituent_ID__c');
                             String constId = (string) target.get('Constituent_ID__c');
                             if(constId !=''|| constId != null){
                                 ic.ucinn_ascendv2__Contact__c = constituentDonorMap.get(constId);
                             }
                             
                             String OrgId = (string)target.get('Organisation_ID__c');
                             if(OrgId !=''|| OrgId != null){
                                 ic.ucinn_ascendv2__Account__c = OrgDonorMap.get(OrgId);
                             }
						                             
                             ic.ucinn_ascendv2__Employer__c = (string)target.get('Employer_Name__c');
                             ic.ucinn_ascendv2__Business_Title__c = (string)target.get('Job_Title__c');
                             ic.ucinn_ascendv2__Employee_Type__c = (string)target.get('ND_Employee_Type__c');
                             ic.nd_Affiliation_Notes_1__c = (string)target.get('Comments__c');
                             
                             string startDateString = (string)target.get('npe5_StartDate__c');
                                 if(startDateString!=''){
                                 	List<String> dateParts = startDateString.split('-');
                                 	Integer year = Integer.valueOf(dateParts[0]);
                                 	Integer month = Integer.valueOf(dateParts[1]);
                                 	Integer day = Integer.valueOf(dateParts[2]);
                                 	Date parsedDate = Date.newInstance(year, month, day);
                                 	ic.nd_Affil_Start_Date_1__c = parsedDate;
                             	}
                             	else{
                                 	ic.nd_Affil_Start_Date_1__c = null;
                             	}
                                 
								string endDateString = (string)target.get('npe5_EndDate__c');
                                 if(endDateString!=''){
                                 	List<String> dateParts = endDateString.split('-');
                                 	Integer year = Integer.valueOf(dateParts[0]);
                                 	Integer month = Integer.valueOf(dateParts[1]);
                                 	Integer day = Integer.valueOf(dateParts[2]);
                                 	Date parsedDate = Date.newInstance(year, month, day);
                                 	ic.nd_Affil_End_Date_1__c = parsedDate;
                             	}
                             	else{
                                 	ic.nd_Affil_End_Date_1__c = null;
                             	}
                                
                                ic.ND_Position_Level__c = (string) target.get('Position_Level__c') == null ? null : (string) target.get('Position_Level__c');
                                ic.nd_Affiliation_Data_Source_1__c =  (string) target.get('Data_Source__c') == null ? null : (string) target.get('Data_Source__c');
                             
                             	String status = (string) target.get('Status__c') == null ? null : (string) target.get('Status__c');
                             	if(status!=null){
                                    if(status=='A'){
                                        ic.nd_Affiliation_Status_1__c = 'Current';
                                    }
                                    else if(status=='P' || status=='U'){
                                        ic.nd_Affiliation_Status_1__c = 'Former';
                                    }
                                    else if(status=='R'){
                                        ic.nd_Affiliation_Status_1__c = 'Retired';
                                    }
                                    else if(status=='D' || status=='X'){
                                        ic.nd_Affiliation_Status_1__c = 'Active at time of Death';
                                    }
                             	}
                                else{
                                	ic.nd_Affiliation_Status_1__c=null;
                             	}
                             	
                             
                             	String EmpType = (string) target.get('Employer_Type__c') == null ? null : (string) target.get('Employer_Type__c');
                                if(EmpType!=null){
                                    if(EmpType=='EP' ||EmpType=='ES' ){
                                       ic.nd_Affiliation_Constituent_Role_1__c = 'Employee';
                                       ic.nd_Is_Primary_Employment__c = true;
                                    }
                                    else if(EmpType=='AF'){
                                        ic.nd_Affiliation_Constituent_Role_1__c = 'Affiliation';
                                    }
                                    else if(EmpType=='FP' || EmpType=='GV' || EmpType=='NP'){
                                        ic.nd_Affiliation_Constituent_Role_1__c='Board Member/Officer';
                                    }
                                    else if(EmpType=='PE'){
                                        if(status=='R'){
                                            ic.nd_Affiliation_Constituent_Role_1__c ='Retired Employee';
                                        }
                                     
                                    }
                                }
                                else{
                                 	ic.nd_Affiliation_Constituent_Role_1__c = null;
                                }
                                newJustInterims.put('crmNDAffiliation'+ic.ucinn_ascendv2__Contact__c+ints.source_data_set__c, ic);    
                         }
                         // Added by Cube84
                         else if(ints.source_data_set__c == 'Relationship__c'){
                             ucinn_ascendv2__Interim__c ic = new ucinn_ascendv2__Interim__c();
                             ic.RecordTypeId =  ucinn_ascendv2__Interim__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('CrmND_Relationship').getRecordTypeId();
                             ic.Integration_In_id__c = ints.Id;
                             ic.Migration_Source__c=ints.Id;
                             ic.ucinn_ascendv2__Status__c = 'Manual Review';
                             ic.message_id__c	= messageId;
                             ic.Message_Event_type__c = ints.message_type__c;
                             ic.OwnerId = InterimOwnerID;
                             
                             ic.ucinn_ascendv2__Donor_ID__c = (string) target.get('Constituent_ID__c');
                             String constId = (string) target.get('Constituent_ID__c');
                             if(constId !=''|| constId != null){
                                 ic.ucinn_ascendv2__Contact__c = constituentDonorMap.get(constId);
                             }
                             
                             string startDateString = (string) target.get('Status_Change_Date__c');
                                 if(startDateString!=''){
                                 	List<String> dateParts = startDateString.split('-');
                                 	Integer year = Integer.valueOf(dateParts[0]);
                                 	Integer month = Integer.valueOf(dateParts[1]);
                                 	Integer day = Integer.valueOf(dateParts[2]);
                                 	Date parsedDate = Date.newInstance(year, month, day);
                                 	ic.nd_Affil_Start_Date_1__c = parsedDate;
                             }
                             else{
                                	ic.nd_Affil_Start_Date_1__c = null;
                             }
                             
                             ic.nd_Relationship_1_Data_Source__c =  (string) target.get('Source__c') == null ? null : (string) target.get('Source__c');
                             String RelType =(string) target.get('Relationship_Type__c');
                             if(RelType=='CH'){
                                 ic.Related_Constituent_Role__c = 'Child';
                             }
                             else if(RelType=='ZZ'){
                                 ic.Related_Constituent_Role__c = 'Deceased Spouse';
                             }
                             else if(RelType=='PR'){
                                 ic.Related_Constituent_Role__c = 'Parent';
                             }
                             else if(RelType=='PP'){
                                 ic.Related_Constituent_Role__c = 'Spouse';
                             }
                             else if(RelType=='WW'){
                                 ic.Related_Constituent_Role__c = 'Widow';
                             }
                             else{
                                 ic.Related_Constituent_Role__c = RelType;
                             }
                             
                             
                             ic.nd_Relationship_1_Notes__c = (string) target.get('Comment__c');
                             
                             String RelStatus = (string) target.get('Relationship_Status__c') == null ? null : (string) target.get('Relationship_Status__c');
                             if(RelStatus!=null){
                                 if(RelStatus=='M'){
                                     ic.ucinn_ascendv2__Marital__c = 'Married';
                                 }
                                 else if(RelStatus=='W'){
                                     ic.ucinn_ascendv2__Marital__c = 'Widowed';
                                 }
                                 else if(RelStatus=='D'){
                                     ic.ucinn_ascendv2__Marital__c = 'Divorced';
                                 }
                                 else{
                                     ic.ucinn_ascendv2__Marital__c = RelStatus;
                                 }
                             }
                             else{
                                 ic.ucinn_ascendv2__Marital__c =  null;
                             }
                             
                             Boolean syncHomeAddress = (Boolean) target.get('Joint_Home_Address__c');
                                                 if(syncHomeAddress==true){
                                 ic.nd_Do_Not_Sync_Home_Address__c = false;
                             }
                             else{
                                 ic.nd_Do_Not_Sync_Home_Address__c = true;
                             }
                             
                             Boolean syncSeasonalAddress = (Boolean) target.get('Joint_Seasonal_Address__c');
                             if(syncSeasonalAddress==true){
                                 ic.nd_Do_Not_Sync_Seasonal_Address__c = false;
                             }
                             else{
                                 ic.nd_Do_Not_Sync_Seasonal_Address__c = true;
                             }
                             
                             String RelconstId = (string) target.get('Related_Constituent_Id__c');
                             
                             if(RelconstId !=''){
                                 ic.ucinn_ascendv2__Relationship_1_Related_Contact__c = constituentDonorMap.get(RelconstId);
                             }
                             newJustInterims.put('crmNDRelation'+ic.ucinn_ascendv2__Contact__c+ints.source_data_set__c, ic);    
                         }
                         
                         // Added by cube84
                         else if (ints.source_data_set__c == 'Education_History__c' && ( (string) target.get('RecordtypeName__c') =='Non_ND_Degree' )   ){
                             ucinn_ascendv2__Interim__c ic = new ucinn_ascendv2__Interim__c();
                             ic.RecordTypeId =  ucinn_ascendv2__Interim__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('CrmND_Education_History').getRecordTypeId();
                             ic.Integration_In_id__c = ints.Id;
                             ic.Migration_Source__c=ints.Id;
                             ic.ucinn_ascendv2__Status__c = 'Manual Review';
                             ic.message_id__c	= messageId;
                             ic.Message_Event_type__c = ints.message_type__c;
                             ic.OwnerId = InterimOwnerID;
                             
                             ic.ucinn_ascendv2__Donor_ID__c = (string) target.get('Constituent_ID__c');
                             String constId = (string) target.get('Constituent_ID__c');
                             if(constId !=''|| constId != null ){
                                 ic.ucinn_ascendv2__Contact__c = constituentDonorMap.get(constId);
                             }
                             
                             String InstitutionCode = (string) target.get('Institution_Code__c');
                             if(InstitutionCode !=''|| InstitutionCode != null ){
                                 ic.Degree_Institution__c = InstitutionMap.get(InstitutionCode);
                             }
                             string ndNonDegRecType = ucinn_ascendv2__Degree_Information__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Non_School_Degree_Information').getRecordTypeId();
                             ic.nd_DegreeInfo_RecTypeId__c = ndNonDegRecType;
                             
                             ic.nd_Degree_Data_Source__c = (string) target.get('Data_Source__c') == null ? null : (string) target.get('Data_Source__c');
                             
                             String degreeCode = DegreeDescription.get((string)target.get('Academic_Degree__c'));
                             if(degreeCode!=null){
                                 ic.nd_Degree_Code__c = degreeCode;
                             }
                             else{
                                 ic.nd_Degree_Code__c = (string)target.get('Academic_Degree__c');
                             }   
                                                     
                             String majorCode1 = MajorDescription.get((string)target.get('Education_Major_1__c'));
                             if(majorCode1!=null){
                                 ic.nd_Major1_Code__c = majorCode1;
                             }
                             else{
                                 ic.nd_Major1_Code__c = (string)target.get('Education_Major_1__c');
                             }   
                             
                             String majorCode2 = MajorDescription.get((string)target.get('Major_2__c'));
                             if(majorCode2!=null){
                                 ic.nd_Major2_Code__c = majorCode2;
                             }
                             else{
                                 ic.nd_Major2_Code__c = (string)target.get('Major_2__c');
                             } 
                             
                             String majorCode3 = MajorDescription.get((string)target.get('Major_3__c'));
                             if(majorCode3!=null){
                                 ic.nd_Major3_Code__c = majorCode3;
                             }
                             else{
                                 ic.nd_Major3_Code__c = (string)target.get('Major_3__c');
                             }
                             
							 String minorCode1 = MinorDescription.get((string)target.get('Minor_1__c'));
                             if(minorCode1!=null){
                                 ic.nd_Minor1_Code__c = minorCode1;
                             }
                             else{
                                 ic.nd_Minor1_Code__c = (string)target.get('Minor_1__c');
                             }
                             
                             String minorCode2 = MinorDescription.get((string)target.get('Minor_2__c'));
                             if(minorCode2!=null){
                                 ic.nd_Minor2_Code__c = minorCode2;
                             }
                             else{
                                 ic.nd_Minor2_Code__c = (string)target.get('Minor_2__c');
                             }
                             
                             String concentration1 = ConcentrationDescription.get((string)target.get('Concentration_1_Field_of_Study__c'));
                             if(concentration1!=null){
                                 ic.nd_Concentration1_Code__c = concentration1;
                             }
                             else{
                                 ic.nd_Concentration1_Code__c = (string)target.get('Concentration_1_Field_of_Study__c');
                             }
                             
                             String concentration2 = ConcentrationDescription.get((string)target.get('Concentration_2_Field_of_Study__c'));
                             if(concentration2!=null){
                                 ic.nd_Concentration2_Code__c = concentration2;
                             }
                             else{
                                 ic.nd_Concentration2_Code__c = (string)target.get('Concentration_2_Field_of_Study__c');
                             }
							 
							 ic.nd_Degree_Comments__c = (string) target.get('Comments__c');
                                                          
                             ic.nd_Conferred_Degree_Year__c = (string) target.get('Education_Year__c');

                             newJustInterims.put('crmND Education History'+ic.ucinn_ascendv2__Contact__c+ints.source_data_set__c, ic); 
                         } 
                         
                         else if (ints.source_data_set__c == 'person education change' ){
                             ucinn_ascendv2__Interim__c ic = new ucinn_ascendv2__Interim__c();
                             ic.ucinn_ascendv2__Possible_Duplicate_Checked__c = possible_dupe;
                             ic.RecordTypeId =  ucinn_ascendv2__Interim__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Hivebrite_Education_sync').getRecordTypeId();
                             ic.Integration_In_id__c = ints.Id;
                             ic.Migration_Source__c=ints.Id;
                             ic.ND_hivebrite_create_from_id__c = string.valueOf((integer) event.get('event_id'));
                             ic.ucinn_ascendv2__Contact__c =  ints.Constituent_Id__c;
                             ic.ucinn_ascendv2__Status__c = 'Manual Review';
                             ic.updated_field_list__c = updated_fields_list;
                             string eventDate = (string) event.get('event_time');
                             ic.update_datetime__c = stringToDate(eventDate);
                             ic.message_id__c	= messageId;
                             ic.Message_Event_type__c = ints.message_type__c;
                             ic.ucinn_ascendv2__external_system_id__c = 'HEDU-'+messageId;
                             ic.ND_data_source_inbound__c = data_source_constant_hivebrite;
                             ic.OwnerId = InterimOwnerID;
                             
                             ic.nd_Major1_Code__c =(string) target.get('majors'); //Major1_Description__c is 255 vs 80
                             ic.nd_Minor1_Code__c = (string) target.get('minors');
                             ic.nd_primary_college_school__c =  (string) target.get('school_name');
                             ic.nd_Degree_Code__c = (string) target.get('degree_name');
                             ic.College_Code__c = (string) target.get('college');
                             ic.nd_Concentration1_Code__c = (string) target.get('concentration');
                             //ic.ucinn_ascendv2__Certification_Date__c = stringToDate((string) target.get('graduation_date'));
                             date graddate = stringToDate((string) target.get('graduation_date'));
                            if(graddate != null) {
                                ic.nd_Conferred_Degree_Year__c = graddate.year().format().remove(',');
                            }
                            ic.ND_Graduation_Date__c = graddate;

                             newJustInterims.put('hivebrite_edu_'+ic.ucinn_ascendv2__Contact__c+ints.source_data_set__c, ic);

                         } else if (ints.source_data_set__c == 'degree sync' ){ 
                            string ndDegRecType = ucinn_ascendv2__Degree_Information__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('School_Degree_Information').getRecordTypeId();
                             ucinn_ascendv2__Interim__c ic = new ucinn_ascendv2__Interim__c();
                             ic.ucinn_ascendv2__Possible_Duplicate_Checked__c = possible_dupe;
                             ic.updated_field_list__c = updated_fields_list;
                             ic.Constituent_Type_from_Interim_Auto__c = true;
                             ic.message_id__c	= messageId;
                             ic.Message_Event_type__c = ints.message_type__c;
                             ic.recordtypeid = ucinn_ascendv2__Interim__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Degree_Sync').getRecordTypeId();
                             ic.ucinn_ascendv2__external_system_id__c = 'DEGS-'+messageId;
                             string data_source_constant_banner = 'B';
                             ic.ND_data_source_code__c = data_source_constant_banner;
                             ic.ucinn_ascendv2__Contact__c =  ints.Constituent_Id__c;
                             ic.Integration_In_id__c = ints.Id;
                             ic.Migration_Source__c=ints.Id;
                             ic.ND_Constituent_status__c = ConstituentStatusProgrammatic;
                             ic.OwnerId = InterimOwnerID;
                             ic.ucinn_ascendv2__School_ID__c=(string) target.get('netid');
                             ic.ucinn_ascendv2__Employee_ID__c =(string) target.get('ndid');
                             ic.ucinn_ascendv2__Student_Information_System_ID__c=(string) target.get('ndid');

                             ic.ucinn_ascendv2__Student_Status__c ='Graduate';
                             ic.ND_Constituent_Type__c = 'AL';
                             ic.Degree_Institution__c = NdOrgDegreeId;
                             date graddate = stringToDate((string) target.get('graduation_date'));
                                if(graddate != null) {
                                    ic.nd_Conferred_Degree_Year__c = graddate.year().format().remove(',');
                                }
                             ic.ND_Graduation_Date__c = graddate;
                             ic.local_ind__c = true;
                             ic.nd_Degree_Data_Source__c = data_source_constant_banner;
                             ic.nd_DegreeInfo_RecTypeId__c = ndDegRecType;

                             ic.Degree_Code_1__c = DegreeMap.get((string) target.get('degree_code'));
                             ic.Major_Code_1__c = MajorMap.get((string) target.get('major1_code'));
                             ic.Major_Code_2__c = MajorMap.get((string) target.get('major2_code'));
                             ic.Major_Code_3__c = MajorMap.get((string) target.get('major3_code'));
                             // major 4 exists on sync but not on ascend degree
                             ic.Minor_Code_1__c = MinorMap.get((string) target.get('minor1_code'));
                             ic.Minor_Code_2__c = MinorMap.get((string) target.get('minor2_code'));
                            // minor 3 & 4 exists on sync but not on ascend degree
                             ic.Concentration_Specialty__c = ConcentrationMap.get((string) target.get('concentration1_code'));
                             ic.Concentration_2__c = ConcentrationMap.get((string) target.get('concentration2_code'));
                             //ic.ucinn_ascendv2__Admit_Term__c = (String)target.get('level_code');
                             string level_code = (String)target.get('level_code');
                             string level_code_xform;
                             /* case 
	when j.student_level_code = 'UG' then 'B'
	when j.student_level_code = 'LW' then 'D'
	when j.student_level_code = 'GR' and j.degree_code = 'PHD' then 'D'
	else 'M'*/

                             if (level_code == 'UG'){
                                level_code_xform = 'B';
                             } else if (level_code == 'LW'){
                                level_code_xform = 'D';
                             } else if (level_code == 'GR' && (String)target.get('degree_level_code') == 'PHD'){
                                level_code_xform = 'D';
                             } else {
                                level_code_xform = 'M';
                             }

                             ic.Degree_Level_Code__c = level_code_xform;
                             //something about removal>???
                             ic.College_Code__c = (string) target.get('college_code');
                             ic.College_Academic_Organization__c = CollegeCodeMap.get((string) target.get('college_code'));
                             ic.Degree_Department__c = DeptCodeMap.get((string) target.get('department_code'));
                             //program code, 

                             newJustInterims.put('DegreeAutoSync_'+ic.ucinn_ascendv2__Student_Information_System_ID__c+ints.source_data_set__c, ic); 

                         } else if (ints.source_data_set__c == 'student sync' ){
                            //cirriculum check goes up here so that i can do multi interims
                            string ndDegRecType = ucinn_ascendv2__Degree_Information__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('School_Degree_Information').getRecordTypeId();
                             ucinn_ascendv2__Interim__c ic = new ucinn_ascendv2__Interim__c();
                             ic.ucinn_ascendv2__Possible_Duplicate_Checked__c = possible_dupe;
                             ic.updated_field_list__c = updated_fields_list;
                             ic.Constituent_Type_from_Interim_Auto__c = true;
                             ic.message_id__c	= messageId;
                             ic.Message_Event_type__c = ints.message_type__c;
                             ic.ucinn_ascendv2__external_system_id__c = 'STRC-'+messageId;
                             string data_source_constant_banner = 'B';
                             ic.ND_data_source_code__c = data_source_constant_banner;
                             ic.ucinn_ascendv2__Contact__c =  ints.Constituent_Id__c;
                             ic.Integration_In_id__c = ints.Id;
                             ic.Migration_Source__c=ints.Id;
                             ic.ND_Constituent_status__c = ConstituentStatusProgrammatic;
                             ic.OwnerId = InterimOwnerID;
                             ic.ucinn_ascendv2__School_ID__c=(string) target.get('netid');
                             ic.ucinn_ascendv2__Employee_ID__c =(string) target.get('ndid');
                             ic.ucinn_ascendv2__Student_Information_System_ID__c=(string) target.get('ndid');
                             
                            //need to metadata build thi asap 2/20/2024
                            if (ic.ucinn_ascendv2__Admit_Term__c =='GN' 
                                || ic.ucinn_ascendv2__Admit_Term__c =='HC'
                                || ic.ucinn_ascendv2__Admit_Term__c =='SM'
                                || ic.ucinn_ascendv2__Admit_Term__c =='EM'
                                || ic.ucinn_ascendv2__Admit_Term__c =='NM'
                                || ic.ucinn_ascendv2__Admit_Term__c =='UD'
                                ){
                            ints.status__c = 'Discard';
                            ints.done_message__c ='message discarded, level code is saint marys, holy cross , Graduate non degree, employee or non matriculating';
                            } else {

                             if ((string) event.get('event_type') == 'D'){
                                //delete message , termination of employee , the separation reason = null, seapration reason = Deceased gets death
                               /*ic.ucinn_ascendv2__external_system_id__c = 'BAUX-'+messageId; 
                               ic.ucinn_ascendv2__Possible_Duplicate_Checked__c = true;
                               ic.ucinn_ascendv2__Status__c = 'New'; //Pending*/
                               ic.ND_Banner_Id__c = (string) event.get('event_id');
                               ic.ND_Constituent_Type__c = 'SW';

                                if ( (string) target.get('withdraw_reason') == 'Deceased'){
                                    string deathDateString = (string) target.get('death_date');
                                    date deathdate = stringToDate(deathDateString);
                                    ic.Death_Date__c = deathdate; //stringToDate(deathDateString);
                                    if(deathdate != null) {
                                    ic.nd_deceased_month__c = (deathdate.month() < 10 ?  ('0' + string.valueOf(deathdate.month())) : string.valueOf(deathdate.month()));
                                    ic.nd_deceased_day__c = ( deathdate.day() < 10 ? ('0' + string.valueOf(deathdate.day()) ) : string.valueOf(deathdate.day()) );
                                    ic.nd_deceased_year__c = deathdate.year().format().remove(',');
                                    }
                                    ic.ND_Constituent_status__c = ' D';
                                    ic.ucinn_ascendv2__Status__c = 'Manual Review'; //Pending
                                    ic.ucinn_ascendv2__Possible_Duplicate_Checked__c = false;
                                    ic.ucinn_ascendv2__Manual_Review_Reason_Multiple_Line__c ='Deceased messages get set to Manual Review';
                                    //ic.ucinn_ascendv2__Student_Status__c ='Active at time of Death';  //placeholder, until i can find where student status vals are

                                } else  if ( (string) target.get('withdraw_reason') == 'Graduated'){
                                    ints.status__c = 'Discard';
                                    ints.done_message__c ='message discarded, degree sync handles graduation info';
                                    ic.ucinn_ascendv2__Student_Status__c ='Graduate';
                                    ic.ND_Constituent_Type__c = 'AL';
                                } else  if ( (string) target.get('withdraw_reason') == 'Voluntary'){
                                    //probably student former??
                                    //ic.ucinn_ascendv2__Student_Status__c ='Graduate';

                                } else  if ( (string) target.get('withdraw_reason') == '-'){
                                    //
                                    //ic.ucinn_ascendv2__Student_Status__c ='Graduate';
                                }
                                   
                                newJustInterims.put('studentAutoSync_'+ic.ucinn_ascendv2__Student_Information_System_ID__c+ints.source_data_set__c, ic); 
                                

                            } else {
                              //Map<String, Object> current_curriculum = (Map<String, Object>) target.get('current_curriculum');
                              List<Map<String, Object>> fallCirriculum = new List<Map<String, Object>>();
                              List<Object> fallCirriculumObjects = (List<Object>) target.get('fall_curriculum');
                              for (Object cobj : fallCirriculumObjects) {
                                  fallCirriculum.add((Map<String, Object>)cobj);
                              }
  
                              system.debug('fallCirriculumObjects size '+ fallCirriculumObjects.size() );
                              
                              List<Map<String, Object>> springCirriculum = new List<Map<String, Object>>();
                              List<Object> springCirriculumObjects = (List<Object>) target.get('spring_curriculum');
                              for (Object fobj : springCirriculumObjects) {
                                  springCirriculum.add((Map<String, Object>)fobj);
                              }
                              system.debug('springCirriculumObjects size '+ springCirriculumObjects.size() );
  
  
                              List<Map<String, Object>> summerCirriculum = new List<Map<String, Object>>();
                              List<Object> summerCirriculumObjects = (List<Object>) target.get('summer_curriculum');
                              for (Object sobj : summerCirriculumObjects) {
                                  summerCirriculum.add((Map<String, Object>)sobj);
                              }
                              system.debug('summerCirriculumObjects size '+ summerCirriculumObjects.size() );
  
                              //determine the 
                              List<Object> current_curriculum = new List<Object>();
                              List<Map<String, Object>> currentCirriculi = new List<Map<String, Object>>();
                              
                              string fcCurrent, spCurrent, suCurrent;
                              //date fcStartDate, fcEndDate, spStartDate, spEndDate, suStartDate, suEndDate;
  
                              if ( fallCirriculumObjects != null && fallCirriculumObjects.size() >= 1) {
                              map<String,Object> fcFind = (map<String,Object>) fallCirriculumObjects[0];
                              /*
                              string fcStartDateString = (String)fcFind.get('term_start_date');
                              string fcEndDateString = (String)fcFind.get('term_end_date');
                              //stringToDate((string) target.get(''));
                              
                              fcStartDate = Date.valueOf(fcStartDateString);
                              fcEndDate = Date.valueOf(fcEndDateString);
                              Integer fcEndYear = fcEndDate.year();
                              system.debug('fcEndYear: '+fcEndYear);
                              */
                              fcCurrent = (String)fcFind.get('current_term');
                              system.debug('fcCurrent value: '+ fcCurrent );
                              }
                              if ( springCirriculumObjects.size() >= 1) {
                                  system.debug('sppring cirriculum greater than 1' );
                              map<String,Object> spFind = (map<String,Object>) springCirriculumObjects[0];
                              /*
                              string spStartDateString = (String)spFind.get('term_start_date');
                              string spEndDateString = (String)spFind.get('term_end_date');
                              spStartDate = Date.valueOf(spStartDateString);
                              spEndDate = Date.valueOf(spEndDateString);*/
                              spCurrent = (String)spFind.get('current_term');
                              system.debug('spCurrent value: '+ spCurrent );
  
                              }
                              if ( summerCirriculumObjects.size() >= 1) {
                              map<String,Object> suFind = (map<String,Object>) summerCirriculumObjects[0];
                              /*string suStartDateString = (String)suFind.get('term_start_date');
                              string suEndDateString = (String)suFind.get('term_end_date');
                              suStartDate = Date.valueOf(suStartDateString);
                              suEndDate = Date.valueOf(suEndDateString);*/
                              suCurrent = (String)suFind.get('current_term');
                              system.debug('suCurrent value: '+ suCurrent );
                              }
                              /*
                              system.debug('today: '+Date.today()+' , fall dates: '+fcStartDate+' to ' +fcEndDate);
                              system.debug('today: '+Date.today()+' , spring dates: '+spStartDate+' to ' +spEndDate);
                              system.debug('today: '+Date.today()+' , summer dates: '+suStartDate+' to ' +suEndDate);*/
                              if (fcCurrent =='Y'){
                                  current_curriculum = fallCirriculumObjects;
                                  system.debug('fall is current cirriculum' );
  
                              } else if (spCurrent=='Y'){
                                  current_curriculum = springCirriculumObjects;
                                  system.debug('spring is current cirriculum' );
  
                              } else if (suCurrent=='Y'){
                                  current_curriculum = summerCirriculumObjects;
                                  system.debug('summer is current cirriculum' );
                              }/*
                              if( Date.today() >= fcStartDate &&  Date.today() <= fcEndDate){
                                  current_curriculum = fallCirriculumObjects;
                                  system.debug('current cirriculi: fall');
                              } else if( Date.today() >= spStartDate &&  Date.today() <= spEndDate){
                                  current_curriculum = springCirriculumObjects;
                                  system.debug('current cirriculi: spring');
                              } else if( Date.today() >= suStartDate &&  Date.today() <= suEndDate){
                                  current_curriculum = summerCirriculumObjects;
                                  system.debug('current cirriculi: summer');
                              }*/
                              /*
                              List<Map<String, Object>> fallCirriculum = new List<Map<String, Object>>();
                              List<Object> fallCirriculumObjects = (List<Object>) target.get('fall_curriculum');
                              for (Object cobj : fallCirriculumObjects) {
                                  fallCirriculum.add((Map<String, Object>)cobj);
                              }*/
                              
  
                              /*if (current_curriculum.size() > 1 ){
                                  system.debug('current cirriculi greater than 1 major');*/
                                  for (Integer i = 0; i < current_curriculum.size(); ++i){
                                      map<String,Object> ccO = (map<String,Object>) current_curriculum[i];
                                      //create two cirriculi here and a method to just put them
                                      //but i need the mappings  of where they go and what theyre doing
                                      //newJustCirriculum
                                      ucinn_ascendv2__Degree_Information__c di = new ucinn_ascendv2__Degree_Information__c();
                                      /* commenting out degree earier work, left for ref
                                      (ucinn_ascendv2__Degree_Information__c)degreeInterimProcess(event, target, ic);
  
                                      ic.ucinn_ascendv2__Student_Information_System_ID__c=(string) target.get('ndid');
                                      ic.Integration_In_id__c = ints.Id;*/
                                      
                                      di.ND_Degree_Institution_FL__c = NdOrgDegreeId;
                                      di.Non_Grad__c = 'T'; //t=student
                                      di.Adm_Type__c = (String)ccO.get('level_code');
                                      //string gradDateString = (string) target.get('graduation_date');
                                      di.nd_Expected_Graduation_Date__c = stringToDate((string) target.get('graduation_date'));  
                                      di.nd_Current_Student_Class_Level__c = (String)ccO.get('classification_code');
  
                                      ucinn_ascendv2__Degree_Code__c dic = new ucinn_ascendv2__Degree_Code__c();
                                      dic.ucinn_ascendv2__Degree_Code__c =(string) ccO.get('degree_code');
                                      di.ucinn_ascendv2__Degree_Code__r = dic;
  
                                      ucinn_ascendv2__Post_Code__c maj = new ucinn_ascendv2__Post_Code__c();
                                      maj.Major_API_Code__c = (string) ccO.get('major_code');
                                      di.ucinn_ascendv2__Post_Code__r = maj; 
                                      
                                      di.ucinn_ascendv2__Contact__c = ic.ucinn_ascendv2__Contact__c;
                                      di.ucinn_ascendv2__Interim__r = ic;
                                      di.Data_Source__c = data_source_constant_banner;
         
                                      newJustDegrees.put('degreeInProgressStudent'+ic.ucinn_ascendv2__Student_Information_System_ID__c+ints.source_data_set__c+i, di);
  
                                  }
  
                                  system.debug(' current_curriculum.size() '+ current_curriculum.size());
                              //for (Integer i = 0; i < current_curriculum.size(); ++i){ }
                                  //why is this looping? the layout, interim fields, merge fields all need to be updated / created
                              if ( current_curriculum.size() > 0) {
                                  map<String,Object> ccO = (map<String,Object>) current_curriculum[0];
                                  system.debug('ccO degree debug '+ccO);
                                  system.debug('degree information iterate level'+(String)ccO.get('level_code'));
                                  //shared
                                  ic.degree_1_non_grad__c = 'T';
                                  ic.Degree_Institution__c = NdOrgDegreeId;
                                  ic.ND_Graduation_Date__c = stringToDate((string) target.get('expected_graduate_date'));
                                  ic.nd_Degree_Data_Source__c = data_source_constant_banner;
                                  ic.nd_DegreeInfo_RecTypeId__c = ndDegRecType;
                                  //individual
                                  ic.ucinn_ascendv2__Current_Class_Level__c = (String)ccO.get('classification_code');                                
                                  ic.Degree_Code_1__c = DegreeMap.get((string) ccO.get('degree_code'));
                                  ic.Major_Code_1__c = MajorMap.get((string) ccO.get('major_code'));

                                  ic.ucinn_ascendv2__Admit_Term__c = (String)ccO.get('level_code');
                                  //removal imminent 5/22/2024
                                  ic.College_Code__c = (string) target.get('college_code');
                                  ic.College_Academic_Organization__c = CollegeCodeMap.get((string) ccO.get('college_code'));
                                  ic.Department_Code__c = (string) target.get('department_code');
                              }
                              if ( current_curriculum.size() > 1) {
                                  map<String,Object> ccO2 = (map<String,Object>) current_curriculum[1];
                                  ic.Degree_Code_2__c = DegreeMap.get((string) ccO2.get('degree_code'));
                                  ic.Major_Code_2__c = MajorMap.get((string) ccO2.get('major_code')); 
                                  //ic.nd_Admit_Term__c = (String)ccO2.get('level_code');  
                              }
                              if ( current_curriculum.size() > 2) {
  
                              }
                              
                            Id StudentSyncInterimRecordTypeId = ucinn_ascendv2__Interim__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('SIS_Interface').getRecordTypeId();
                            ic.RecordTypeId = StudentSyncInterimRecordTypeId;
                            if ( (string) target.get('student_type') == 'Future'){
                                ic.ND_Constituent_Type__c = 'SA';
                                integer myyear = date.today().year();
                                String year = String.valueOf(myyear);
                                ic.ND_Admit_Year__c = year;
                             } else {
                                ic.ND_Constituent_Type__c = 'ST';
                             }

                           

                             //all automatic interim
                             string home_phone = (string) target.get('home_phone');
                             string campus_phone = (string) target.get('local_phone');
							 string birthDateString = (string) target.get('birth_dt');
                             if( birthDateString != null ){
                                date birthDate = stringToDate(birthDateString);
                                ic.ucinn_ascendv2__Birthdate__c = birthDate;
                             }

                             //if involvement exists
                             //system.debug('DormMap call'+ DormMap);
                             string dorm = (string) target.get('hall_code');
                             //system.debug('dorm string value' + dorm);
                             if( dorm != null ){
                                ic.nd_Involvement_1__c = DormMap.get(dorm);
                                //system.debug('dorm map value' + ic.nd_Involvement_1__c);
                                ic.nd_Involvement_Data_Source_1__c = data_source_constant_banner;
                                Id InvolvementRecordTypeId = ucinn_ascendv2__Involvement__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Student_Activity').getRecordTypeId();
                                ic.nd_Involvement_RecordType_1__c =InvolvementRecordTypeId;
                                ic.Involvement_Participation_1__c ='D';
                             }
                             /*
                             we need a custom metadata of student vs empl vs 
                             whatever to get the codes for the service indicators, loop thru and add
                             */
                             /* removing to place in a flow
                             ic.Service_Indicator_Value_1__c = ServiceIndicatorMap.get('DNC');
                             ic.Service_Indicator_Value_2__c = ServiceIndicatorMap.get('DNS');
                             */
                             ic.ucinn_ascendv2__Address_1_Line_1__c = (string) target.get('home_street_line1');
                             ic.ucinn_ascendv2__Address_1_Line_2__c = (string) target.get('home_street_line2');
                             ic.ucinn_ascendv2__Address_1_Line_3__c = (string) target.get('home_street_line3');
                             ic.ucinn_ascendv2__City_1__c  = (string) target.get('home_city');
                             //ic.ucinn_ascendv2__Country_1__c = (string) target.get('home_nation_code');
                             if( (string) target.get('home_nation_code') == null){
                                if((string) target.get('home_state') != null){
                                    ic.ucinn_ascendv2__Country_1__c = 'US';
                                    /*
                                   if(statesSet.contains((string) target.get('home_state')) == true){
                                        ic.ucinn_ascendv2__Country_1__c = 'US';
                                    }*/
                                }
                               } else {
                                ic.ucinn_ascendv2__Country_1__c = (string) target.get('home_nation_code');
                               }
                             ic.ucinn_ascendv2__State_1__c = (string) target.get('home_state');
                             ic.ucinn_ascendv2__Postal_Code_1__c = (string) target.get('home_zip');
                             ic.ucinn_ascendv2__Address_1_Type__c = (string) target.get('home_street_line1') == null ? null : 'Home';    
                             ic.ND_Address_1_Type__c = (string) target.get('home_street_line1') == null ? null : 'H';  //Home
                             if (ic.ND_Address_1_Type__c != null){
                                ic.ND_Address_1_Data_Source_Abbrev__c = data_source_constant_banner;
                                ic.nd_Address_1_Status__c='Current';
                               }
                             if ( ic.updated_field_list__c.contains('home_street_line1') && ic.ND_Address_1_Type__c == null){
                                ic.nd_Address_1_Status__c = 'Former';
                             }
                             ic.ucinn_ascendv2__Phone_1__c = home_phone == null ? null : home_phone.replaceAll( invalidNumbers, '' );//home_phone == null ? null : home_phone.replace('+', ' ');
                             ic.ucinn_ascendv2__Phone_1_Type__c =  home_phone == null ? null : 'Home';
                             ic.ND_Phone_1_Type__c =  home_phone == null ? null : 'H';
                             ic.ND_Phone_1_Data_Source__c = home_phone == null ? null : data_source_constant_banner;
                             ic.ND_Phone_1_Status__c =  home_phone == null ? null : 'Current';
                             if ( ic.updated_field_list__c.contains('home_phone') && home_phone == null){
                                ic.ND_Phone_1_Status__c = 'Former';
                               }

                             ic.ucinn_ascendv2__Phone_2__c =  campus_phone == null ? null : campus_phone.replaceAll( invalidNumbers, '' );//campus_phone == null ? null : campus_phone.replace('+', ' ');
                             ic.ucinn_ascendv2__Phone_2_Type__c =  campus_phone == null ? null : 'Campus';
                             ic.ND_Phone_2_Type__c =  campus_phone == null ? null : 'C';
                             ic.ND_Phone_2_Data_Source__c = campus_phone == null ? null : data_source_constant_banner;
                             ic.ND_Phone_2_Status__c =  campus_phone == null ? null : 'Current';
                             if ( ic.updated_field_list__c.contains('local_phone') && campus_phone == null){
                                ic.ND_Phone_2_Status__c = 'Former';
                               }


                             ic.ucinn_ascendv2__Address_2_Line_1__c  = (string) target.get('local_street_line1');
                             ic.ucinn_ascendv2__Address_2_Line_2__c  = (string) target.get('local_street_line2');
                             ic.ucinn_ascendv2__Address_2_Line_3__c  = (string) target.get('local_street_line3');
                             ic.ucinn_ascendv2__City_2__c  = (string) target.get('local_city');
                             if( (string) target.get('local_nation_code') == null){
                                if((string) target.get('local_state') != null){
                                    ic.ucinn_ascendv2__Country_2__c = 'US';
                                    /*
                                   if(statesSet.contains((string) target.get('local_state')) == true){
                                        ic.ucinn_ascendv2__Country_2__c = 'US';
                                    }*/
                                }
                               } else {
                                ic.ucinn_ascendv2__Country_2__c = (string) target.get('local_nation_code');
                               }
                             //ic.ucinn_ascendv2__Country_2__c = (string) target.get('local_nation_code');
                             ic.ucinn_ascendv2__State_2__c = (string) target.get('local_state');
                             ic.ucinn_ascendv2__Postal_Code_2__c = (string) target.get('local_zip');
                             ic.ucinn_ascendv2__Address_2_Type__c = (string) target.get('local_street_line1') == null ? null : 'Student Local Address';
                             ic.ND_Address_2_Type__c = (string) target.get('local_street_line1') == null ? null : 'C';
                             if (ic.ND_Address_2_Type__c != null){
                                ic.ND_Address_2_Data_Source__c = data_source_constant_banner;
                                ic.nd_Address_2_Status__c='Current';
                             }
                             if ( ic.updated_field_list__c.contains('local_street_line1') && ic.ND_Address_2_Type__c == null){
                                ic.nd_Address_2_Status__c = 'Former';
                             }


                             ic.ucinn_ascendv2__First_Name__c=(string) target.get('first_name');
                             ic.ucinn_ascendv2__Last_Name__c=(string) target.get('last_name');
                             ic.ucinn_ascendv2__Middle_Name__c=(string) target.get('middle_name');
                             ic.ucinn_ascendv2__Gender__c=(string) target.get('gender_code');
                             ic.ucinn_ascendv2__Ethnicity__c=(string) target.get('ethnic_code');
                             // moved to above ic.ucinn_ascendv2__Birthdate__c= stringToDate(birthDate); //bDate;
                             ic.ND_Nickname__c=(string) target.get('salutation');
                             //ic.ucinn_ascendv2__Salutation__c=(string) target.get('prefix');
                             ic.ucinn_ascendv2__Prefix__c=(string) target.get('prefix');
                             ic.ucinn_ascendv2__Suffix__c=(string) target.get('pers_suffix');
                             //this may need to be transformed, code vs text
                             ic.ucinn_ascendv2__Religious_Preference__c=(string) target.get('religion_code');
                             ic.ucinn_ascendv2__Country_of_Birth__c=(string) target.get('citizen_cntry_code1');
                             ic.ucinn_ascendv2__Student_Information_System_ID__c=(string) target.get('ndid');
                             ic.ucinn_ascendv2__School_ID__c=(string) target.get('netid');
                             ic.nd_common_app_id__c = (string) target.get('common_app_id');
                            
                             ic.ucinn_ascendv2__Email_1__c = (string) target.get('email_address');
                             ic.ND_Email_1_Type__c = (string) target.get('email_address')  == null ? null :'S'; //Student Email
                              if (ic.ND_Email_1_Type__c != null){
                                ic.ND_Email_1_Data_Source__c = data_source_constant_banner;
                              }
                             //not sure how to configure slate yet
                             
                             ic.nd_Residence_Hall__c = (string) target.get('hall_code');
                             ic.nd_slate_id__c = (string) target.get('slate_id');
                             if (ic.ucinn_ascendv2__School_ID__c != null){
                                ic.ND_Alternate_ID_Type_2__c ='NET';
                              }

                             if (ic.ucinn_ascendv2__Employee_ID__c != null){
                                ic.ND_Alternate_ID_Type_1__c ='NID';
                              }
                            //ic.Integration_In_id__c = ints.Id;
                             //this ones unique ic.ucinn_ascendv2__External_System_ID__c
                             /*
                             

                             if(ic.ucinn_ascendv2__School_ID__c != null){
                                Alternate_ID__c iv = new Alternate_ID__c();
                                iv.Other_ID__c = ic.ucinn_ascendv2__School_ID__c;
                                iv.ID_Type__c = 'NET';
                                iv.Constituent__c = ic.ucinn_ascendv2__Contact__c;
                                iv.nd_Interim__r = ic;

                                newJustAlternateID.put('altID_netid_'+ic.ucinn_ascendv2__School_ID__c+ints.source_data_set__c, iv);
                             }

                             if(ic.ucinn_ascendv2__Student_Information_System_ID__c != null){
                                Alternate_ID__c iv = new Alternate_ID__c();
                                iv.Other_ID__c = ic.ucinn_ascendv2__Student_Information_System_ID__c;
                                iv.ID_Type__c = 'NID';
                                iv.Constituent__c = ic.ucinn_ascendv2__Contact__c;
                                iv.nd_Interim__r = ic;

                                newJustAlternateID.put('altID_ndid_'+ic.ucinn_ascendv2__Student_Information_System_ID__c+ints.source_data_set__c, iv);
                             }*/

                             newJustInterims.put('studentSync_'+ic.ucinn_ascendv2__Student_Information_System_ID__c+ints.source_data_set__c, ic);
                            }  
                         }                      

                        } else if (ints.source_data_set__c == 'gift'){
                    //mobilecauseProcess.giftprocess(jsonmap);
                            if (ints.source_system__c == 'hivebrite gift'){
                                ucinn_ascendv2__Review_Transaction_v2__c rt2 =  hivebriteGiftProcess.processGift(target);   
                                newJustRTV2.put('rtv2'+rt2.nd_gift_source__c + ints.message_id__c, rt2);  

                            }else if(ints.source_system__c == 'mobilecause gift'){
                                ucinn_ascendv2__Review_Transaction_v2__c rt2 =  mobilecauseGiftProcess.processGift(target);   
                                newJustRTV2.put('rtv2'+rt2.nd_gift_source__c + ints.message_id__c, rt2);
                            }else if(ints.source_system__c == 'lockbox gift'){
                                ucinn_ascendv2__Review_Transaction_v2__c rt2 =  lockboxGiftProcessing.processGift(target);   
                                newJustRTV2.put('rtv2'+rt2.nd_gift_source__c + ints.message_id__c, rt2);
                            } else{
                                // whatever sent in is not in the right format or not set up for online gift processing
                    }
                 /*               
				//   Added 12/16/24   wharpenau for Cvent
                } else if (ints.source_system__c == 'cvent'){
                    system.debug('begin cvent execute method');
                    if (ints.source_data_set__c == 'events'){
                        Campaign camp =  cventProcessingMain.processEvent(target);  
                        newCventEventList.put('newCventEventList => '+ + ints.message_id__c, camp);
                    }else if(ints.source_data_set__c == 'sessions'){
                        Campaign camp =  cventProcessingMain.processSession(target);  
                        newCventSessionList.put('newCventSessionList => '+ + ints.message_id__c, camp);                         
                    }else{
                        // whatever sent in is not in the right format or not set up for Cvent processing
                         system.debug('begin cvent else');
                  }*/
                } else if (ints.source_data_set__c == 'user change' ){
                    set<string> ManualFieldList = new set<string>();
                    set<string> AutoFieldList = new set<string>();
                    set<string> AutoFieldList2 = new set<string>();
                    
                    Map<String, consumer_field__mdt> newWay = consumer_field__mdt.getAll();
                    /*List<consumer_field__mdt> consumerFieldsNew = new List<consumer_field__mdt>();
                    for (Id key : newWay.keySet()) {
                        consumerFieldsNew.add(newWay.get(key));
                    }
                    system.debug('consumerFieldsNew: '+consumerFieldsNew);
                    */
                    Boolean manualInterim = false;
                    Boolean autoInterim = false;
                    Boolean autoInterim2 = false;

                    List<consumer_field__mdt> consumerFields = [select MasterLabel, QualifiedApiName, source_data_set__c, set_name__c from consumer_field__mdt];
                    //system.debug('consumerFields: '+consumerFields);
                    for (consumer_field__mdt fds : consumerFields){ //take off the new if it doesnt work
                        if (fds.set_name__c == 'manualInterim'){
                            ManualFieldList.add(fds.MasterLabel);
                        }
                        if (fds.set_name__c == 'autoInterim'){
                            AutoFieldList.add(fds.MasterLabel);
                        }
                        if (fds.set_name__c == 'autoInterim2'){
                            AutoFieldList2.add(fds.MasterLabel);
                        } else {

                        }
                    }
                    
                    for(Object str : changed) {
                         string field = (string)str;
                         if(ManualFieldList.contains(field)) {
                            manualInterim = true;
                             system.debug('manual engage');
                             //break;
                         }
                        if(AutoFieldList.contains(field)) {
                            autoInterim = true;
                            system.debug('auto engage');
                            //break;
                        }
                        if(AutoFieldList2.contains(field)) {
                            autoInterim2 = true;
                            system.debug('auto2 engage');
                            //break;
                        }
                        
                        
                     }
                     if (autoInterim2){
                    string phoneType = (string) target.get('phone_type')
                        , us_number = (string) target.get('phone_us_number')
                        , home_phone = (string) target.get('home_phone')
                        , bus_phone = (string) target.get('work_phone')
                        , mobile_phone = (string) target.get('mobile_phone')
                        , intl_number = (string) target.get('phone_intl_number')
                        , preferred_type = (string) target.get('address_preferred_type')
                        , pref_picklist;
                    boolean pref1 = false, pref2 = false, pref3 = false;
                     
                     //boolean pref_address_ind = false;
                     if ( preferred_type == 'postal_personal') { 
                         pref_picklist='Address 1';
                         pref1 = true;
                     } else if (preferred_type == 'postal_work') {
                         pref_picklist='Address 2';
                         pref2 = true;
                     } else if (preferred_type == 'postal_other') { //??
                         pref_picklist='Address 3';
                         pref3 = true;
                     }
                     

                     //Id interimRecordTypeId = ucinn_ascendv2__Interim__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Hivebrite_Bio').getRecordTypeId();
                     ucinn_ascendv2__Interim__c ic = new ucinn_ascendv2__Interim__c();
                     ic.ND_hivebrite_create_from_id__c = string.valueOf((integer) event.get('event_id'));
                     ic.ucinn_ascendv2__Possible_Duplicate_Checked__c = possible_dupe;
                     ic.ucinn_ascendv2__Status__c = 'New';
                     //ic.RecordTypeId = interimRecordTypeId;
                     //String auto2updatedPickVals = String.join(new List<String>(AutoFieldList2),',');
                     ic.updated_field_list__c = updated_fields_list; //auto2updatedPickVals;
                     string eventDate = (string) event.get('event_time');
                     ic.update_datetime__c = stringToDate(eventDate);
                     ic.Constituent_Type_from_Interim_Auto__c = true;
                     ic.message_id__c	= messageId;
                     ic.Message_Event_type__c = ints.message_type__c;
                     ic.ucinn_ascendv2__external_system_id__c = 'HBIO-'+messageId;
                     //again not a great translation from source_database =/ ask andrew
                     //need to check bio and see if this is actually working, removing this field should clear up to 400 rows in picklist sync
                     ic.ND_data_source_code__c = data_source_constant_hivebrite;
                     ic.ucinn_ascendv2__Contact__c =  ints.Constituent_Id__c;
                     ic.Integration_In_id__c = ints.Id;
                     ic.ND_Constituent_status__c = 'A';
                     ic.OwnerId = InterimOwnerID;
                     
                       //ic.ucinn_ascendv2__Preferred_Phone__c = null;
                       ic.pref_class_year__c = string.valueOf((integer) target.get('pref_class_year'));
                       ic.ND_Phone_1_Type__c = home_phone == null ? null : 'H';
                       ic.ucinn_ascendv2__Phone_1__c = home_phone == null ? null : home_phone.replaceAll( invalidNumbers, '' );
                       ic.ND_Phone_1_Data_Source_Abbrev__c = home_phone == null ? null : data_source_constant_hivebrite;
                       ic.ND_Phone_1_Status__c =  home_phone == null ? null : 'Current';
                       if ( ic.updated_field_list__c.contains('home_phone') && home_phone == null){
                        ic.ND_Phone_1_Status__c = 'Former';
                       }

                       ic.ND_Phone_2_Type__c = bus_phone == null ? null : 'B';
                       ic.ucinn_ascendv2__Phone_2__c = bus_phone == null ? null : bus_phone.replaceAll( invalidNumbers, '' );
                       ic.ND_Phone_2_Data_Source__c = bus_phone == null ? null : data_source_constant_hivebrite;
                       ic.ND_Phone_2_Status__c =  bus_phone == null ? null : 'Current';
                       if ( ic.updated_field_list__c.contains('work_phone') && bus_phone == null){
                        ic.ND_Phone_2_Status__c = 'Former';
                       }

                       ic.ND_Phone_3_Type__c = mobile_phone == null ? null :'M';
                       ic.ucinn_ascendv2__Phone_3__c = mobile_phone == null ? null : mobile_phone.replaceAll( invalidNumbers, '' );
                       ic.ND_Phone_3_Data_Source__c = mobile_phone == null ? null : data_source_constant_hivebrite;
                       ic.ND_Phone_3_Status__c =  mobile_phone == null ? null : 'Current';
                       if ( ic.updated_field_list__c.contains('mobile_phone') && mobile_phone == null){
                        ic.ND_Phone_3_Status__c = 'Former';
                       }
                       //is there a pref phone indicator?
                     
                     
                     ic.ucinn_ascendv2__Address_1_Line_1__c = (string) target.get('address_street_line1');
                     ic.ucinn_ascendv2__Address_1_Line_2__c = (string) target.get('address_street_line2');
                     ic.ucinn_ascendv2__Address_1_Line_3__c = (string) target.get('address_street_line3');
                     ic.ucinn_ascendv2__City_1__c  = (string) target.get('address_city');
                    //ic.ucinn_ascendv2__Country_1__c = (string) target.get('address_nation');
                     if( (string) target.get('address_nation') == null){
                        if((string) target.get('address_state') != null){
                            ic.ucinn_ascendv2__Country_1__c = 'US';
                            /*
                           if(statesSet.contains((string) target.get('address_state')) == true){
                                ic.ucinn_ascendv2__Country_1__c = 'US';
                            }*/
                        }
                       } else {
                        ic.ucinn_ascendv2__Country_1__c = (string) target.get('address_nation');
                       }
                     ic.ucinn_ascendv2__State_1__c = (string) target.get('address_state');
                     ic.ucinn_ascendv2__Postal_Code_1__c = (string) target.get('address_zip');
                     ic.ucinn_ascendv2__Preferred_Address__c = pref_picklist; //=='Address 1' ? pref_picklist : null; //(string) target.get('address_preferred_type');
                     ic.nd_Preferred_Address__c = pref1;

                     ic.ND_Address_1_Type__c = (string) target.get('address_street_line1') == null ? null : 'H'; //H is the code for Home NOTICE i like this better i want to use this ??(string) target.get('address_type');
                     if (ic.ND_Address_1_Type__c != null){
                        ic.ND_Address_1_Data_Source_Abbrev__c = data_source_constant_hivebrite;
                        ic.nd_Address_1_Status__c='Current';
                       }
                     if ( ic.updated_field_list__c.contains('address_street_line1') && ic.ND_Address_1_Type__c == null){
                        ic.nd_Address_1_Status__c = 'Former';
                     }
                     
                     ic.ucinn_ascendv2__Address_2_Line_1__c = (string) target.get('work_addr_line1');
                     ic.ucinn_ascendv2__Address_2_Line_2__c = (string) target.get('work_addr_line2');
                     ic.ucinn_ascendv2__Address_2_Line_3__c = (string) target.get('work_addr_line3');
                     ic.ucinn_ascendv2__City_2__c  = (string) target.get('work_us_city');
                     //ic.ucinn_ascendv2__Country_2__c = (string) target.get('work_country');
                     if( (string) target.get('work_country') == null){
                        if((string) target.get('work_state') != null){
                            ic.ucinn_ascendv2__Country_2__c = 'US';
                            /*
                           if(statesSet.contains((string) target.get('work_state')) == true){
                                ic.ucinn_ascendv2__Country_2__c = 'US';
                            }*/
                        }
                       } else {
                        ic.ucinn_ascendv2__Country_2__c = (string) target.get('work_country');
                       }
                     ic.ucinn_ascendv2__State_2__c = (string) target.get('work_state');
                     ic.ucinn_ascendv2__Postal_Code_2__c = (string) target.get('work_us_zip');
                     ic.nd_Preferred_Address_2__c = pref2;
                     
                     ic.ND_Address_2_Type__c = (string) target.get('work_addr_line1') == null ? null : 'B'; //B is the code for Business (string) target.get('address_type');
                     if (ic.ND_Address_2_Type__c != null){
                        ic.ND_Address_2_Data_Source__c = data_source_constant_hivebrite;
                        ic.ND_Address_2_Status__c='Current';
                       }
                     if ( ic.updated_field_list__c.contains('work_addr_line1') && ic.ND_Address_2_Type__c == null){
                        ic.ND_Address_2_Status__c = 'Former';
                     }
                     ic.ucinn_ascendv2__Address_3_Line_1__c = (string) target.get('seasonal_address_line_1');
                     ic.ucinn_ascendv2__Address_3_Line_2__c = (string) target.get('seasonal_address_line_2');
                     ic.ucinn_ascendv2__Address_3_Line_3__c = (string) target.get('seasonal_address_line_3');
                     ic.ucinn_ascendv2__City_3__c  = (string) target.get('seasonal_city');
                     //ic.ucinn_ascendv2__Country_3__c = (string) target.get('seasonal_country');
                     if( (string) target.get('seasonal_country') == null){
                        if((string) target.get('seasonal_state_region') != null){
                            ic.ucinn_ascendv2__Country_3__c = 'US';
                            /*
                           if(statesSet.contains((string) target.get('seasonal_state_region')) == true){
                                ic.ucinn_ascendv2__Country_3__c = 'US';
                            }*/
                        }
                       } else {
                        ic.ucinn_ascendv2__Country_3__c = (string) target.get('seasonal_country');
                       }
                     ic.ucinn_ascendv2__State_3__c = (string) target.get('seasonal_state_region');
                     ic.ucinn_ascendv2__Postal_Code_3__c = (string) target.get('seasonal_postal_code');
                     ic.nd_Preferred_Address_3__c = pref3;
                     
                     string seasonalStartDate = (string) target.get('seasonal_address_start_date');
                     ic.nd_Address_3_Start_Date__c = stringToDate(seasonalStartDate);
                     /*
                     if (seasonalStartDate != null) {
                        Date ssDate = Date.valueOf(seasonalStartDate);
                        ic.nd_Address_3_Start_Date__c = ssDate;
                     }*/
                     string seasonalEndDate = (string) target.get('seasonal_address_end_date');
                     ic.nd_Address_3_End_Date__c =stringToDate(seasonalEndDate);
                     /*
                     if (seasonalEndDate != null) {
                        Date seDate = Date.valueOf(seasonalEndDate);
                        ic.nd_Address_3_End_Date__c = seDate;
                     }*/

                     string seasonalType;
                     if ((string) target.get('seasonal_address_line_1') == null
                     //|| (string) target.get('seasonal_address_line_2') == null 
                     //|| (string) target.get('seasonal_address_line_3') == null
                     || (string) target.get('seasonal_city') == null
                     //|| (string) target.get('seasonal_country') == null
                     || (string) target.get('seasonal_state_region') == null
                     || (string) target.get('seasonal_postal_code') == null) 
                     { seasonalType = null; 
                        } else {
                            if (seasonalStartDate != null || seasonalEndDate != null ) { seasonalType='Seasonal'; } else { seasonalType='T'; }
                        }
                     ic.ND_Address_3_Type__c = seasonalType;
                     if (ic.ND_Address_3_Type__c != null){
                        ic.ND_Address_3_Data_Source__c = data_source_constant_hivebrite;
                        ic.ND_Address_3_Status__c='Current';
                       }
                    if ( ic.updated_field_list__c.contains('seasonal_address_line_1') && ic.ND_Address_3_Type__c == null){
                        ic.ND_Address_3_Status__c = 'Former';
                     }
                     //ic.nd_Address_3_Start_Date__c = (string) target.get('seasonal_address_start_date');
                     //ic.nd_Address_3_End_Date__c = (string) target.get('seasonal_address_end_date');
                     ic.ucinn_ascendv2__Birthdate__c = stringToDate((string) target.get('birth_date'));
                     ic.ucinn_ascendv2__Gender__c = (string) target.get('gender');

                     //marked for removal
                     ic.ucinn_ascendv2__Phone_1_Type__c = home_phone == null ? null : 'Home'; //phoneType;//home
                     ic.ucinn_ascendv2__Phone_2_Type__c = bus_phone == null ? null : 'Business'; //phoneType;//home
                     ic.ucinn_ascendv2__Phone_3_Type__c = mobile_phone == null ? null :'Mobile'; //phoneType;//home
                     ic.ucinn_ascendv2__Address_1_Type__c = (string) target.get('address_street_line1') == null ? null : 'Home';//NOTICE i like this better i want to use this ??(string) target.get('address_type');
                     ic.ucinn_ascendv2__Address_2_Type__c = (string) target.get('work_addr_line1') == null ? null : 'Business'; //(string) target.get('address_type');
                     ic.ucinn_ascendv2__Address_3_Type__c = (string) target.get('seasonal_address_line_1') == null ? null : 'Seasonal'; //(string) target.get('address_type');
                     ic.ucinn_ascendv2__Email_1_Type__c = (string) target.get('email') == null ? null : 'Personal'; //NOTICE i like this better i want to use this ?? (string) target.get('email_type');
                     ic.ucinn_ascendv2__Email_2_Type__c = (string) target.get('work_email') == null ? null : 'Business'; //(string) target.get('email_type'); change these to types

                     newJustInterims.put('auto2_'+ic.ucinn_ascendv2__Contact__c+ints.source_data_set__c, ic);
                     
                    }

                     if (manualInterim){
                        system.debug('manual engage part 2');
                        string preferred_email_type = (string) target.get('primary_email_choice')
                        , pref_email_picklist;

                        if ( preferred_email_type != null){
                            if (preferred_email_type == 'email'){
                              pref_email_picklist = 'Email 1';  
                            } else if (preferred_email_type == 'email2'){
                              pref_email_picklist = 'Email 2';  
                            } else if (preferred_email_type == 'email3'){
                                pref_email_picklist = 'Email 3';  
                              }
                        }

                     ucinn_ascendv2__Interim__c iq = new ucinn_ascendv2__Interim__c();
                     iq.ND_hivebrite_create_from_id__c = string.valueOf((integer) event.get('event_id'));
                     iq.ucinn_ascendv2__Possible_Duplicate_Checked__c = possible_dupe;
                     iq.ucinn_ascendv2__Status__c = 'Manual Review';
                     iq.RecordTypeId = ucinn_ascendv2__Interim__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Hivebrite_Bio_Manual').getRecordTypeId();
                     iq.updated_field_list__c = updated_fields_list;
                     string eventDate = (string) event.get('event_time');
                     iq.update_datetime__c = stringToDate(eventDate);
                     iq.message_id__c	= messageId;
                     iq.ucinn_ascendv2__Contact__c =  ints.Constituent_Id__c;
                     
                     iq.Message_Event_type__c = ints.message_type__c;
                     iq.ucinn_ascendv2__external_system_id__c = 'HBIM-'+messageId;

                     iq.ND_Nickname__c = (string) target.get('first');
                     iq.ucinn_ascendv2__First_Name__c = (string) target.get('legal_first_name');
                     iq.ucinn_ascendv2__Middle_Name__c = (string) target.get('middle');
                     iq.ucinn_ascendv2__Last_Name__c = (string) target.get('last');
                     iq.ucinn_ascendv2__Suffix__c = (string) target.get('suffix1');
                     iq.ucinn_ascendv2__Prefix__c = (string) target.get('prefix');
                     iq.maiden_name__c = (string) target.get('maiden_name');
                      /** spouse section */
                      iq.ucinn_ascendv2__Relationship_1_Related_Contact__c =ints.Spouse_Constituent_Id__c;

                      string spsinDb, relatedRole;
                      if (ints.Spouse_Constituent_Id__c != null){
                         spsinDb = 'Yes';
                      }
 
                      iq.ND_Spouse_in_the_database__c = spsinDb;
                      iq.nd_Spouse_First_Name__c = (string) target.get('spouse_legal_first_name');
                      iq.nd_Spouse_Last_Name__c = (string) target.get('spouse_last_name');
                      iq.ND_Spouse_Nickname__c = (string) target.get('spouse_first_name');
                      iq.ND_Spouse_Class_Year__c = String.valueOf(Integer.valueOf(target.get('spouse_class_year')));
                      if ( iq.nd_Spouse_First_Name__c != null){
                         iq.nd_Apply_Soft_Credit_1__c = true;
                         iq.ucinn_ascendv2__Relationship_1_Related_Role__c='Spouse';
                         iq.ND_Merge_Option__c='Merge Household';
                      }
                      /** spouse section end */
                     iq.ucinn_ascendv2__Marital__c = (string) target.get('marital_status');
                     iq.ucinn_ascendv2__Preferred_Email__c =  pref_email_picklist; //=='Email 1' ? pref_picklist : null;//(string) target.get('primary_email_choice');
                     if (preferred_email_type == 'email'){
                        iq.ND_Preferred_Email_1__c = true;
                      } else if (preferred_email_type == 'email2'){
                        iq.ND_Preferred_Email_2__c = true;
                      } else if (preferred_email_type == 'email3'){
                        iq.ND_Preferred_Email_3__c = true;
                      }

                     iq.ucinn_ascendv2__Email_1__c = (string) target.get('email');
                     iq.ucinn_ascendv2__Email_1_Type__c = (string) target.get('email') == null ? null : 'M'; //M is the code for Personal ?? (string) target.get('email_type');
                     iq.ND_Email_1_Type__c = (string) target.get('email') == null ? null : 'M';
                     if (iq.ND_Email_1_Type__c != null){
                        iq.ND_Email_1_Data_Source__c = data_source_constant_hivebrite;
                        iq.ND_Email_1_Status__c = 'Current';
                      }
                     if ( iq.updated_field_list__c.contains('email') && iq.ND_Email_1_Type__c == null){
                        iq.ND_Preferred_Email_1__c = false;
                        iq.ND_Email_1_Status__c = 'Former';
                     }
                     iq.ucinn_ascendv2__Email_2__c = (string) target.get('work_email');
                     iq.ND_Email_2_Type__c = (string) target.get('work_email') == null ? null : 'U'; //U is the code for Business email (string) target.get('email_type'); change these to types
                     if (iq.ND_Email_2_Type__c != null){
                        iq.ND_Email_2_Data_Source__c = data_source_constant_hivebrite;
                        iq.ND_Email_2_Status__c = 'Current';
                      }
                      if ( iq.updated_field_list__c.contains('work_email') && iq.ND_Email_2_Type__c == null){
                        iq.ND_Email_2_Status__c = 'Former';
                        iq.ND_Preferred_Email_2__c = false;
                     }

                     iq.ND_Email_3__c = (string) target.get('alum_email');
                     iq.ND_Email_3_Type__c = (string) target.get('alum_email') == null ? null : 'A'; //U is the code for Alumni email (string) target.get('email_type'); change these to types
                     if (iq.ND_Email_3_Type__c != null){
                        iq.ND_Email_3_Data_Source__c = data_source_constant_hivebrite;
                        iq.ND_Email_3_Status__c = 'Current';
                      }
                      if ( iq.updated_field_list__c.contains('alum_email') && iq.ND_Email_3_Type__c == null){
                        iq.ND_Email_3_Status__c = 'Former';
                        iq.ND_Preferred_Email_3__c = false;
                     }

                     iq.Integration_In_id__c = ints.Id;
                     newJustInterims.put('manual_'+iq.ucinn_ascendv2__Contact__c+ints.source_data_set__c, iq);
                     }
                             
                         }
                         if ( ints.status__c != 'Discard'){
                         ints.status__c = 'Done';
                			if (ints.done_message__c != 'employment delete , do nothing, this is an immediate discard'){
                				ints.done_message__c ='json has been consumed';	
                			}
                        } else {
                            if (ints.done_message__c == null) {
                            ints.done_message__c ='message discarded';
                            }
                        }
                     }
            } catch (exception e) {
                ints.error_message__c = 'Message : ' + e.getMessage() + '\nError string : ' + e.getStackTraceString();
                ints.status__c ='error';
                
            }
        }
        if(newJustInterims.size() > 0) {
            List <Database.SaveResult> jc = Database.insert(newJustInterims.values(), false);
        	system.debug('saveresult'+jc);
            //list<ucinn_ascendv2__Interim__c> intsList  = newJustInterims.values();
        	for ( Database.SaveResult sr : jc) {
                //ucinn_ascendv2__Interim__c origRecord = intsList[sr];
            	if ( sr.isSuccess() != true ){
                    
                    //system.debug('sr.getId() = '+sr.getId()); // I get null here
                    //system.debug(origRecord.Id); //This should be the Id you're looking for
                    /*
                	List<Error_Event__e> errEventList = new List<Error_Event__e>();
                		for ( Database.Error err : sr.getErrors() ){
                    		Error_Event__e errEvent=new Error_Event__e(Error_Message__c=err.getMessage(),Severity__c=2);
                            errEventList.add(errEvent);
                            //System.debug('Error inserting/updating record with id: ' + sr.getId() + ' - ' + sr.getErrors());
                		}
              		//ints.error_message__c = 'Message : ' + sr.getErrors() + '\nError string : ' + e.getStackTraceString();  
              		List<Database.SaveResult> results = EventBus.publish(errEventList);*/
            	}
         }
        }
        if(newJustRTV2.size() > 0) {
            List <Database.SaveResult> rt = Database.insert(newJustRTV2.values(), false);
        	for ( Database.SaveResult srt : rt) {
            	if ( srt.isSuccess() != true ){
                    //error handling
            	}
         }
        }
        system.debug('involvements count :'+newJustInvolvements.size());
        if(newJustInvolvements.size() > 0) {
            system.debug('involvements save');
            List <Database.SaveResult> rt = Database.insert(newJustInvolvements.values(), false);
        	system.debug('saveresult'+rt);
        	for ( Database.SaveResult srti : rt) {
            	if ( srti.isSuccess() != true ){
                    system.debug('involvements save was not successful');
                    //error handling
            	}
         }
        }
        if(newJustServiceIndicators.size() > 0) {
            List <Database.SaveResult> rt = Database.insert(newJustServiceIndicators.values(), false);
        	for ( Database.SaveResult srts : rt) {
            	if ( srts.isSuccess() != true ){
                    //error handling
            	}
         }
        }
        if(newJustAlternateID.size() > 0) {
            List <Database.SaveResult> rt = Database.insert(newJustAlternateID.values(), false);
        	for ( Database.SaveResult srta : rt) {
            	if ( srta.isSuccess() != true ){
                    //error handling
            	}
         }
        }

        if(newJustDegrees.size() > 0) {
            List <Database.SaveResult> rt = Database.insert(newJustDegrees.values(), false);
        	for ( Database.SaveResult srtd : rt) {
            	if ( srtd.isSuccess() != true ){
                    //error handling
            	}
         }
        }
        
        List <Database.SaveResult> SR =
  		Database.update(IntList, false);
    }
    global void finish(Database.BatchableContext bc){
        if(!Test.isRunningTest()) {
            System.scheduleBatch(new IntegrationConsumerBatch(), 'IntegrationConsumerBatch', 5, 1);
          }
       
    }   

    global integer processId = Crypto.getRandomInteger();
    global boolean justDorm = false;
        
    global id NdOrgId = [select id from account where ucinn_ascendv2__Donor_ID__c='307129'].id;
    global string data_source_constant_hivebrite = 'HVB';
    global date stringToDate(string inputString){

        Date dateFromString = null;
        if (inputString != null) {
            dateFromString = Date.valueOf(inputString);                                   
         }
         return dateFromString;

    }
    //
    global sObject states_lookup(){
        list<nd_picklist__c> states = [select code__c, description__c, field_api_name__c, object_api_name__c  from nd_picklist__c where global_master_label__c = 'State Codes'];
        return states[0];
    }

    global map<string, string> ndPickListforLookup(){
        map<string, string> returnal = new map<string, string>();
        list<nd_picklist__c> nd_picklist_sObj = [select description__c, field_api_name__c, object_api_name__c, code__c from nd_picklist__c where field_api_name__c != 'recordtypeid'];
        for (nd_picklist__c ndp : nd_picklist_sObj){
            returnal.put(ndp.object_api_name__c+'.'+ndp.field_api_name__c+'.'+ndp.description__c, ndp.code__c);
        }
        return returnal;
    }
    global sObject nd_picklist_desc_to_code (){
        map<id, nd_picklist__c> returnMap = new map<id, nd_picklist__c>();
        list<nd_picklist__c> nd_picklist_sObj = [select description__c, field_api_name__c, object_api_name__c from nd_picklist__c where field_api_name__c != 'recordtypeid'];
        return nd_picklist_sObj[0];
    }
    /*
    global map<Id, ucinn_ascendv2__Affiliation__c> getAffiliations( set<string> constituentIds, boolean banner, id NdOrgId){
        Map<String, ID> mapAffiliations = new  Map<String, ID>();
        map<Id, ucinn_ascendv2__Affiliation__c> AffilMap = new map<Id, ucinn_ascendv2__Affiliation__c>();
        string bannercriteria ='';
        if (banner){
            bannercriteria = ' and ucinn_ascendv2__Account__c = \''+NdOrgId+'\'';
            ucinn_ascendv2__Affiliation__c afQuery = [select Id, Name, ND_Employee_Type__c, ucinn_ascendv2__Status__c, ND_Integration_Record_ID__c from ucinn_ascendv2__Affiliation__c where ucinn_ascendv2__Contact__c in :constituentIds and ucinn_ascendv2__Status__c = 'A' and ucinn_ascendv2__Account__c = :NdOrgId];
        } else {
            //integration rec id?
            ucinn_ascendv2__Affiliation__c afQuery = [select Id, Name, ND_Employee_Type__c, ucinn_ascendv2__Status__c, ND_Integration_Record_ID__c from ucinn_ascendv2__Affiliation__c where ucinn_ascendv2__Contact__c in :constituentIds and ucinn_ascendv2__Status__c = 'A'];
        }

        //for (ucinn_ascendv2__Affiliation__c af : ['select Id, Name, ND_Employee_Type__c, ucinn_ascendv2__Status__c from ucinn_ascendv2__Affiliation__c where ucinn_ascendv2__Contact__c in :constituentIds'+bannercriteria ]){
        for (ucinn_ascendv2__Affiliation__c af : afQuery){
            mapAffiliations.put(ucinn_ascendv2__Contact__c, af.id);
            AffilMap.put(af.Id, af);
        }

        return AffilMap;
    }*/



    private map<Id, map<string, Object>> processManualMerge(List<Integration_In__c> scope, set<string> nonNdIds, map<Id, Contact> constMap){
        map<Id, map<string, Object>> jsonMap = new map<Id, map<string, Object>>();
        return jsonMap;
    }
    
    private map<Id, map<string, Object>> processNewRecords(List<Integration_In__c> scope, set<string> nonNdIds, map<Id, Contact> constMap){
        /*** new ***/
        List<Integration_In__c> lockedIntIn = [Select ID, status__c, json_message__c, process_id__c, Constituent_Id__c, message_id__c,  error_message__c
                                           , done_message__c, message_type__c , source_data_set__c , source_system__c from Integration_In__c where Id IN :scope and process_id__c = null FOR UPDATE ];
        /*** new ***/
        
        map<Id, map<string, Object>> jsonMap = new map<Id, map<string, Object>>();
        set<string> constituentIds = new set <string>();
        set<string> Ndids = new set <string>();
        for(Integration_In__c ints : lockedIntIn) {
            try {
                if(ints.Status__c == 'new') {
                    /* get the identifier to look up the constituent record */              
                    string json_message = ints.json_message__c;
                    
                    Map<String, Object> m =(Map<String, Object>) JSON.deserializeUntyped(json_message);
                    Map<String, Object> newmap = (Map<String, Object>) m.get('object');
                    Map<String, Object> newtarget = (Map<String, Object>) newmap.get('target');
                    string constituentId =  newtarget.containsKey('constituent_id') ?  (string) newtarget.get('constituent_id') : null; 
                    string constituentIdClean = constituentId == null? null : String.valueOf(Integer.valueOf(constituentId));

                    string ndid =  newtarget.containsKey('dsn_or_ndid') ?  (string) newtarget.get('dsn_or_ndid') : (newtarget.containsKey('ndid') ?  (string) newtarget.get('ndid') : null); 
                    system.debug('clean id'+ constituentIdClean);
                    
                    constituentIds.add(constituentId);
                    String spouseId = String.valueOf(newtarget.get('spouse_id'));
                    string spouseConstituentId =  newtarget.containsKey('spouse_id') ?  spouseId : null;

                    constituentIds.add(spouseConstituentId);
                    if(ndid != null){Ndids.add(ndid);}
        		}
            }catch (exception e) {
                ints.error_message__c = e.getMessage();
                ints.status__c ='error';
            }
        }
        //system.debug(constituentIds);
        /* use identifier to collect constituent records*/
        system.debug('step 1');
        Map<String, ID> mapConstituents = new  Map<String, ID>();
        //need an addtional select here or an or statement to figure out if they have supplied ndids or constituent ids ofr even entid later down the road
        for (Contact c : [Select id , ucinn_ascendv2__Donor_ID__c, Constituent_Status__c, ucinn_ascendv2__External_System_ID__c
                          from Contact where ucinn_ascendv2__Donor_ID__c in :constituentIds
                          //or ucinn_ascendv2__External_System_ID__c in :Ndids 
                          ]){
             if (c.ucinn_ascendv2__Donor_ID__c != null){
                mapConstituents.put(c.ucinn_ascendv2__Donor_ID__c, c.id);
             }
            constMap.put(c.Id, c);
                              
        }

        Map<String, ID> mapConstituentsViaNdid = new  Map<String, ID>();
        for (Contact c : [Select id , ucinn_ascendv2__Donor_ID__c, Constituent_Status__c, ucinn_ascendv2__External_System_ID__c
                          from Contact where ucinn_ascendv2__External_System_ID__c in :Ndids
                         ]){
            mapConstituentsViaNdid.put(c.ucinn_ascendv2__External_System_ID__c, c.id);
            constMap.put(c.Id, c);
                              
        }
        /* assign salesforce id to the integration in 
        not sure what above means ? revisit */
        //this needs to be made global for 1 query
        //id NdOrgId = [select id from account where ucinn_ascendv2__Donor_ID__c='307129'].id;
        system.debug('step 1.5 lets get the university affil records');
        Map<String, ID> mapAffiliations = new  Map<String, ID>();
        map<Id, ucinn_ascendv2__Affiliation__c> AffilMap = new map<Id, ucinn_ascendv2__Affiliation__c>();
        for (ucinn_ascendv2__Affiliation__c af : [select Id, Name, ND_Employee_Type__c, ucinn_ascendv2__Status__c, Integration_Record_ID__c , ucinn_ascendv2__Contact__c
                                                  from ucinn_ascendv2__Affiliation__c where ucinn_ascendv2__Contact__c in :constituentIds and ucinn_ascendv2__Status__c = 'A' and ucinn_ascendv2__Account__c = :NdOrgId]){
            mapAffiliations.put(af.ucinn_ascendv2__Contact__c, af.id); // going to make the field back the way it ND_Integration_Record_ID__c
            AffilMap.put(af.Id, af);
        }

        system.debug('map constituent'+mapConstituents);
        for(Integration_In__c ints : lockedIntIn){
            string json_message = ints.json_message__c;
            try{
                system.debug('step 2');
            Map<String, Object> m =(Map<String, Object>) JSON.deserializeUntyped(json_message);
            Map<String, Object> newMap = (Map<String, Object>) m.get('object');
            Map<String, Object> newEvent = (Map<String, Object>) newmap.get('event');
            Map<String, Object> newtarget = (Map<String, Object>) newmap.get('target');
            jsonMap.put(ints.Id, newMap);
                system.debug('step 2.5');
            string constituentId = newtarget.containsKey('constituent_id') ?  (string) newtarget.get('constituent_id') : null; 
            string constituentIdClean = constituentId == null ? null : String.valueOf(Integer.valueOf(constituentId));
            string ndid =  newtarget.containsKey('dsn_or_ndid') ?  (string) newtarget.get('dsn_or_ndid') : (newtarget.containsKey('ndid') ?  (string) newtarget.get('ndid') : null);
            String spouseId = String.valueOf(newtarget.get('spouse_id'));
            string spouseConstituentId =  newtarget.containsKey('spouse_id') ?  spouseId : null;


                system.debug('step 3');
            //string phone = (string) newtarget.get('us_number');
            string messageId = (string) newEvent.get('event_sequence_number');
            string messageType = (string) newEvent.get('source_table'); //event_name
            string integrationRecId = (string)newTarget.get('integration_record_id');
            nonNDIds.add(integrationRecId);
                
             //add a condition to see if key is there
            //ints.phone__c = phone;

            	ints.Constituent_Id__c =  mapConstituents.get(constituentId);
                if (ints.Constituent_Id__c == null  ){
                    ints.Constituent_Id__c =  mapConstituentsViaNdid.get(ndid);
                    
                }
                ints.Spouse_Constituent_Id__c =  mapConstituents.get(spouseConstituentId);

            /*    
            string Constituent_Status = (string) newtarget.get('Constituent_Status__c');
                if (Constituent_Status != 'X' || Constituent_Status != 'L' ) {
                    ints.active_constituent = true; } else { ints.active_constituent = false; }
			*/
            ints.message_id__c	= messageId;
            ints.source_system__c = (string) newEvent.get('source_database');
            ints.source_data_set__c = messageType; 
			ints.message_type__c = (string) newEvent.get('event_type');                
            ints.error_message__c = null;
                system.debug('step 4');
                ints.status__c ='in process'; 
                /*
                if (ints.Constituent_Id__c != null)  {  
                    ints.status__c ='in process'; }
                else {
                    ints.status__c ='error';
                    ints.error_message__c = 'Message : No constituent ID found for '+constituentId;
                }*/
            
            
            ints.process_id__c = processId;
            
                
            ints.done_message__c ='json object ok, ready to be consumed';  
                
            } catch (exception e) {
                ints.error_message__c = e.getMessage();
                ints.status__c ='error';
            }
        }
        
        update lockedIntIn;
        return jsonMap;
    }    
}