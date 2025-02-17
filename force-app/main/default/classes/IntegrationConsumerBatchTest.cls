@isTest(SeeAllData=false)
private class IntegrationConsumerBatchTest {
    @testSetup 
    static void setup() {
		/** The code in this section will create test records only once
		 *  The test data can then be used by multiple test methods in
		 *  this test class
		 */
		Account a = new Account(name='Sirius Satellite');
        Account a2 = new Account(name='EMPLOYER IN NAME ONLY');
        Account a3 = new Account(name='University Of Notre Dame', ucinn_ascendv2__Donor_ID__c='307129',institution_code__c='184100');
        insert new List<Account>{a, a2, a3};
        //Account newOrganization = [select id from Account where name = 'Sirius Satellite' limit 1];
         
        Contact c = new Contact(accountid =   a.Id, ucinn_ascendv2__Donor_ID__c='38', ucinn_ascendv2__External_System_ID__c='902169782', firstname = 'Sarah', lastname = 'Farris', ucinn_ascendv2__Personal_Email__c='sfarris@ttech.edu', Constituent_Status__c='A');
        Contact c2 = new Contact(accountid = a2.Id, ucinn_ascendv2__Donor_ID__c='402', firstname = 'Danuel', lastname = 'House', ucinn_ascendv2__Personal_Email__c = 'house@uci.com', Constituent_Status__c ='A' );
        Contact c3 = new Contact(accountid = a3.Id, ucinn_ascendv2__Donor_ID__c='508', firstname = 'John', lastname = 'Stugotz', Constituent_Status__c='F', ucinn_ascendv2__Personal_Email__c='stuyougotz@meadowlark.com' );
        Contact c4 = new Contact(accountid = a3.Id, firstname = 'Dan', lastname = 'LeBatard', Constituent_Status__c='X', ucinn_ascendv2__Personal_Email__c='lebatard@espn.com');
        Contact c5 = new Contact(accountid = a.Id, ucinn_ascendv2__Donor_ID__c='606196', firstname = 'Chad', lastname = 'Harrington', Constituent_Status__c='A', ucinn_ascendv2__Personal_Email__c='harrington@ortho.com');
        Contact c6= new Contact(accountid = a.Id, ucinn_ascendv2__Donor_ID__c='2098147', firstname = 'Tony', lastname = 'Soprano', Constituent_Status__c='A', ucinn_ascendv2__Personal_Email__c='tsop@bing.com');

        
        
        insert new List<Contact>{c, c2, c3, c4, c5, c6};
        //insert c;  
        
    }
    /*
    static testmethod void testUserChange() {
        Contact newConstituent = [select id, ucinn_ascendv2__Donor_ID__c from contact where name='Danuel House' limit 1];
        List<Integration_In__c> intList= new List<Integration_In__c>();
        
        Integration_In__c i2 = new Integration_In__c(json_message__c='{"object":{"changed":["email","work_email"],"event":{"event_id":1163488,"event_name":"user change","event_sequence_number":"100-341033535",'
                                                     +'"event_time":"2022-06-18 11:04:02.000","event_type":"U","priority":66,"source_database":"hivebrite","source_schema":"none","source_table":"user change"},'
                                                     +'"target":{"address_city":"South Bend","address_nation":"US","address_preferred_type":"postal_personal","address_state":"IN",'
                                                     +'"address_street_line1":"314 Peashway Street","address_street_line2":null,"address_street_line3":null,"address_type":"H","address_zip":"46617-1220",'
                                                     +'"alum_email":null,"birth_date":"1981-01-29 00:00:00.000 -0500","constituent_id":"402","data_source":"HVB",'
                                                     +'"email":"no_email.aamoni_at_guat.nd.edu@hivebrite.com","email_type":"M","ethnicity":["White"],"first":"Andrea","gender":"F","home_phone":"5748552337",'
                                                     +'"last":"Amoni","marital_status":"N","middle":"Susanne","mobile_phone":null,"phone_us_number":"5748552337","prefix":null,"primary_email_choice":"email",'
                                                     +'"seasonal_address_end_date":null,"seasonal_address_line_1":null,"seasonal_address_line_2":null,"seasonal_address_line_3":null,"seasonal_address_start_date":null,'
                                                     +'"seasonal_city":null,"seasonal_country":null,"seasonal_postal_code":null,"seasonal_state_region":null,"spouse_first_name":null,"spouse_id":null,"spouse_last_name":null,'
                                                     +'"spouse_legal_first_name":null,"suffix1":null,"work_addr_line1":"358 Information Technology Center","work_addr_line2":null,"work_addr_line3":null,"work_country":"US",'
                                                     +'"work_email":null,"work_phone":null,"work_state":"IN","work_us_city":"Notre Dame","work_us_phone":null,"work_us_zip":"46556"}}}');
                                                     //{"object":{"changed":["birth_date","address_preferred_type","work_addr_line1","work_phone","work_us_phone","work_country","work_us_city","mobile_phone","work_state","work_us_zip"],"event":{"event_id":2043942,"event_name":"user change","event_sequence_number":"100-306543043","event_time":"2021-10-20 20:56:51.000","event_type":"U","priority":66,"source_database":"hivebrite","source_schema":"none","source_table":"user change"},"target":{"address_city":"Gallatin","address_nation":"US","address_preferred_type":"postal_work","address_state":"TN","address_street_line1":"1711 Lake Grasslands W","address_street_line2":"shoebox","address_street_line3":null,"address_type":"H","address_zip":"37066","birth_date":"2000-12-13 00:00:00.000 -0500","constituent_id":"'+newconstituent.ucinn_ascendv2__Donor_ID__c+'","data_source":"HVB","email":"no_email.rraccoon_animalfarm.com@hivebrite.com","email_type":"M","first":"Rocky","gender":"M","home_phone":"61526242829","last":"Racoon","middle":"R","mobile_phone":"3056542331","phone_us_number":"61526242829","prefix":"Mr.","primary_email_choice":"email","suffix1":"Esquire","work_addr_line1":"1019 collins ave apt 2b","work_addr_line2":null,"work_addr_line3":null,"work_country":"US","work_phone":"3052672829","work_state":"Florida","work_us_city":"maimi beach","work_us_phone":"3052672829","work_us_zip":"33139"}}}');
                                                     //{"object":{"changed":["email"],"event":{"event_id":1762308,"event_name":"person email change","event_sequence_number":"50-220348126","event_time":"2020-08-11 16:07:20.000","event_type":"U","priority":66,"source_database":"hivebrite","source_schema":"none","source_table":"person email change"},"target":{"constituent_id":"'+newconstituent.Constituent_ID__c+'","data_source":"HVB","email":"pattyherrity@hotmail.com","primary_email_choice":"email2","type":"M"}}}');
        intList.add(i2);
        
        //System.Test.startTest();
        insert intList;
        IntegrationConsumerBatch icb =  new IntegrationConsumerBatch();
        database.executeBatch(icb);
        //System.Test.stopTest();
        
        Integration_In__c[] intsUpdatedist = [select id, name, json_message__c, status__c, source_data_set__c, message_id__c , constituent_id__c, process_id__c, message_type__c from Integration_In__c];
        system.debug('ints'+intsUpdatedist);
        system.debug('ints con id'+intsUpdatedist[0].constituent_id__c);
        List<ucinn_ascendv2__Interim__c> interims = [select id, ucinn_ascendv2__First_Name__c, ucinn_ascendv2__Middle_Name__c, ucinn_ascendv2__Last_Name__c
                                                     ,ucinn_ascendv2__Contact__c, ucinn_ascendv2__Suffix__c, ucinn_ascendv2__Prefix__c from ucinn_ascendv2__Interim__c where Integration_In_id__c = :intsUpdatedist[0].id ];
        system.debug('interims: '+interims);
        system.assert(intsUpdatedist[0].source_data_set__c.Contains('user change'));
        system.assert(intsUpdatedist[0].constituent_id__c == interims[0].ucinn_ascendv2__Contact__c);
        //system.assert(intsUpdatedist[0].process_id__c == cases[0].process_id__c);
        //system.assert(interims[0].ucinn_ascendv2__First_Name__c == 'Andrea');
        //system.assert(interims[0].ucinn_ascendv2__Middle_Name__c == 'Susanne');
        //system.assert(interims[0].ucinn_ascendv2__Last_Name__c == 'Amoni');
        //system.assert(interims[0].ucinn_ascendv2__Suffix__c == 'Esquire');
        //system.assert(interims[0].ucinn_ascendv2__Prefix__c == 'Mr.');
        //
        /*
        List<Case> cases = [select id, message_id__c, email__c, Preferred_Email__c, process_id__c, source__c, contactid, original_source_code__c, Email_Type__c, Integration_Type__c from case where message_id__c = :intsUpdatedist[0].message_id__c ];
        system.assert(intsUpdatedist[0].source_data_set__c.Contains('person email change'));
        system.assert(intsUpdatedist[0].constituent_id__c == cases[0].contactid);
        system.assert(intsUpdatedist[0].process_id__c == cases[0].process_id__c);
        system.assert(cases[0].Preferred_Email__c == false);
        system.assert(cases[0].email__c == 'pattyherrity@hotmail.com');
        system.assert(cases[0].source__c == 'HVB');
        system.assert(cases[0].original_source_code__c == 'HVB');
        system.assert(cases[0].Email_Type__c == 'M');
        system.assert(cases[0].Integration_Type__c == intsUpdatedist[0].message_type__c);
         */       
   // }
    static testmethod void testDegreeSync() {
        Contact newConstituent = [select id, ucinn_ascendv2__External_System_ID__c from contact where name='Sarah Farris' limit 1];
        List<Integration_In__c> intList= new List<Integration_In__c>();
        
        Integration_In__c i2 = new Integration_In__c(json_message__c='{"object":{"changed":[],"event":{"event_id":"9020942931","event_last_modified_by":"902094293","event_sequence_number":"902094293120240805150426","event_time":"2024-08-05T15:04:26.000Z","event_type":"I","source_database":"banner","source_schema":"none","source_table":"degree sync"},"target":{"activity_date":"2024-08-05T14:40:25.000Z","college2_code":null,"college2_description":null,"college_code":"SS","college_description":"Social Science","concentration1_code":null,"concentration1_desc":null,"concentration2_code":null,"concentration2_desc":null,"concentration3_code":null,"concentration3_desc":null,"concentration4_code":null,"concentration4_desc":null,"degree_code":"PHD","degree_description":"Doctor of Philosophy","degree_level_code":"DR","degree_level_description":"Doctorate","degree_seq_no":1,"department2_code":null,"department2_description":null,"department3_code":null,"department3_description":null,"department4_code":null,"department4_description":null,"department_code":"ANTH","department_description":"Anthropology","graduation_date":"2024-08-04","level_code":"GR","level_description":"Graduate","major1_code":"ANTH","major1_description":"Anthropology","major2_code":null,"major2_description":null,"major3_code":null,"major3_description":null,"major4_code":null,"major4_description":null,"minor1_code":null,"minor1_description":null,"minor2_code":null,"minor2_description":null,"minor3_code":null,"minor3_description":null,"minor4_code":null,"minor4_description":null,"ndid":"'+newConstituent.ucinn_ascendv2__External_System_ID__c+'","program_code":"PHD-ANTH","program_description":"PhD - Anthropology","start_year":"2019"}}}');
    
        intList.add(i2);
        Test.startTest();
        insert intList;
        IntegrationConsumerBatch icb =  new IntegrationConsumerBatch();
        database.executeBatch(icb);
        Test.stopTest();
        
        Integration_In__c[] intsUpdatedist = [select id, name, json_message__c, status__c, source_data_set__c, message_id__c , constituent_id__c, process_id__c, message_type__c from Integration_In__c];
        system.debug('ints'+intsUpdatedist);
        system.debug('ints con id'+intsUpdatedist[0].constituent_id__c);
        List<ucinn_ascendv2__Interim__c> interims = [select id, ucinn_ascendv2__First_Name__c, ucinn_ascendv2__Middle_Name__c, ucinn_ascendv2__Last_Name__c
                                                     ,ucinn_ascendv2__Contact__c, ucinn_ascendv2__Suffix__c, ucinn_ascendv2__Prefix__c from ucinn_ascendv2__Interim__c where Integration_In_id__c = :intsUpdatedist[0].id ];
        system.debug('interims: '+interims);
        system.assert(intsUpdatedist[0].source_data_set__c.Contains('degree sync'));
        //system.assert(intsUpdatedist[0].constituent_id__c == interims[0].ucinn_ascendv2__Contact__c);
        
    }
    static testmethod void testUserChangeAuto2() {
        Contact newConstituent = [select id, ucinn_ascendv2__Donor_ID__c from contact where name='Danuel House' limit 1];
        List<Integration_In__c> intList= new List<Integration_In__c>();
        
        Integration_In__c i2 = new Integration_In__c(json_message__c='{"object":{"changed":["email","mobile_phone"],"event":{"event_id":715448,"event_name":"user change","event_sequence_number":"100-959738603","event_time":"2024-05-21 19:00:06.000","event_type":"U","priority":66,"source_database":"hivebrite change producer","source_schema":"none","source_table":"user change"},"target":{"address_city":"Bellmore","address_nation":"US","address_preferred_type":"postal_personal","address_state":"NY","address_street_line1":"2825 Royle Street","address_street_line2":null,"address_street_line3":null,"address_type":"H","address_zip":"11710-4125","alum_email":null,"birth_date":"2002-02-17 00:00:00.000 -0500","constituent_id":"2125211","data_source":"HVB","email":"ajcammiso@gmail.com","email_type":"M","ethnicity":["White"],"first":"Ashley","gender":"F","home_phone":null,"last":"Cammiso","legal_first_name":"Ashley","maiden_name":null,"marital_status":"N","middle":null,"mobile_phone":"5165321841","phone_us_number":null,"prefix":null,"primary_email_choice":"email","seasonal_address_end_date":null,"seasonal_address_line_1":null,"seasonal_address_line_2":null,"seasonal_address_line_3":null,"seasonal_address_start_date":null,"seasonal_city":null,"seasonal_country":null,"seasonal_postal_code":null,"seasonal_state_region":null,"spouse_class_year":null,"spouse_first_name":null,"spouse_id":null,"spouse_last_name":null,"spouse_legal_first_name":null,"suffix1":null,"work_addr_line1":null,"work_addr_line2":null,"work_addr_line3":null,"work_country":null,"work_email":null,"work_phone":null,"work_state":null,"work_us_city":null,"work_us_phone":null,"work_us_zip":null}}}');
        intList.add(i2);
        
        Test.startTest();
        insert intList;
        IntegrationConsumerBatch icb =  new IntegrationConsumerBatch();
        database.executeBatch(icb);
        Test.stopTest();
        
        Integration_In__c[] intsUpdatedist = [select id, name, json_message__c, status__c, source_data_set__c, message_id__c , constituent_id__c, process_id__c, message_type__c from Integration_In__c];
        system.debug('ints'+intsUpdatedist);
        system.debug('ints con id'+intsUpdatedist[0].constituent_id__c);
        List<ucinn_ascendv2__Interim__c> interims = [select id, ucinn_ascendv2__First_Name__c, ucinn_ascendv2__Middle_Name__c, ucinn_ascendv2__Last_Name__c
                                                     ,ucinn_ascendv2__Contact__c, ucinn_ascendv2__Suffix__c, ucinn_ascendv2__Prefix__c from ucinn_ascendv2__Interim__c where Integration_In_id__c = :intsUpdatedist[0].id ];
        system.debug('interims: '+interims);
        system.assert(intsUpdatedist[0].source_data_set__c.Contains('user change'));
        system.assert(intsUpdatedist[0].constituent_id__c == interims[0].ucinn_ascendv2__Contact__c);
    }
    static testmethod void testEmployeeSync() {
        Contact newConstituent = [select id, ucinn_ascendv2__External_System_ID__c from contact where name='Sarah Farris' limit 1];
        List<Integration_In__c> intList= new List<Integration_In__c>();
        
        Integration_In__c i2 = new Integration_In__c(json_message__c='{"object":{"changed":["home_city","home_stat_code","home_street_line1","home_street_line2","home_zip"],"event":{"event_id":"902211333","event_last_modified_by":"902211333","event_sequence_number":"90221133320220126080409","event_time":"2022-01-26T08:04:09.000Z","event_type":"U","source_database":"banner","source_schema":"none","source_table":"employee sync"},"target":{"death_date":null,"eclass":"S3","eclass_desc":"FT Non-exempt Hourly","email_address":null,"first_name":"Douglas","gender":"M","home_city":"Niles","home_nation":null,"home_natn_code":null,"home_phone":"269-2672443","home_stat_code":"MI","home_street_line1":"Apartment 34","home_street_line2":"2203 Spansail Drive","home_street_line3":null,"home_zip":"49120-3780","international_phone":null,"last_name":"Schutze","middle_name":"Steven","name_prefix":null,"name_suffix":null,"ndid":"'+newConstituent.ucinn_ascendv2__External_System_ID__c+'","netid":null,"office_city":"Notre Dame","office_nation":null,"office_natn_code":null,"office_phone":"574-6315615","office_stat_code":"IN","office_street_line1":"117 Mason Services Center","office_street_line2":null,"office_street_line3":null,"office_zip":"46556-5691","primary_job_title":null}}}}');
                                                     //{"object":{"changed":["email"],"event":{"event_id":1762308,"event_name":"person email change","event_sequence_number":"50-220348126","event_time":"2020-08-11 16:07:20.000","event_type":"U","priority":66,"source_database":"hivebrite","source_schema":"none","source_table":"person email change"},"target":{"constituent_id":"'+newconstituent.Constituent_ID__c+'","data_source":"HVB","email":"pattyherrity@hotmail.com","primary_email_choice":"email2","type":"M"}}}');
        intList.add(i2);
        
        Test.startTest();
        insert intList;
        IntegrationConsumerBatch icb =  new IntegrationConsumerBatch();
        database.executeBatch(icb);
        Test.stopTest();
        
        Integration_In__c[] intsUpdatedist = [select id, name, json_message__c, status__c, source_data_set__c, message_id__c , constituent_id__c, process_id__c, message_type__c from Integration_In__c];
        system.debug('ints'+intsUpdatedist);
        system.debug('ints con id'+intsUpdatedist[0].constituent_id__c);
        List<ucinn_ascendv2__Interim__c> interims = [select id, ucinn_ascendv2__First_Name__c, ucinn_ascendv2__Middle_Name__c, ucinn_ascendv2__Last_Name__c
                                                     ,ucinn_ascendv2__Contact__c, ucinn_ascendv2__Suffix__c, ucinn_ascendv2__Prefix__c, ND_Eclass__c from ucinn_ascendv2__Interim__c where Integration_In_id__c = :intsUpdatedist[0].id ];
        system.assert(intsUpdatedist[0].source_data_set__c.Contains('employee sync'));
        system.debug('interims[0].ucinn_ascendv2__Contact__c '+interims[0].ucinn_ascendv2__Contact__c);
        //system.assert(intsUpdatedist[0].constituent_id__c == interims[0].ucinn_ascendv2__Contact__c);
        system.assert(interims[0].ND_Eclass__c == 'S3');
        
    }
    
    static testmethod void testRetireEmployeeSync() {
        Contact newConstituent = [select id, ucinn_ascendv2__External_System_ID__c from contact where name='Sarah Farris' limit 1];
        List<Integration_In__c> intList= new List<Integration_In__c>();
        
        Integration_In__c i2 = new Integration_In__c(json_message__c='{"object":{"changed":["eclass"],"event":{"event_id":"900179544","event_last_modified_by":"900179544","event_sequence_number":"90017954420221110090611","event_time":"2022-11-10T09:06:11.000Z","event_type":"U","source_database":"banner","source_schema":"none","source_table":"employee sync"},"target":{"eclass":"R1","eclass_desc":"Retiree Regular","email_address":"gduke@guat.nd.edu","first_name":"George","gender":"M","home_city":"Venice","home_nation":null,"home_natn_code":null,"home_phone":null,"home_stat_code":"FL","home_street_line1":"442 Lake of The Woods Drive","home_street_line2":null,"home_street_line3":null,"home_zip":"34293-4146","international_phone":null,"last_name":"Duke","middle_name":"Robert","name_prefix":null,"name_suffix":null,"ndid":"sfarris38","netid":"gduke","office_city":"South Bend","office_nation":null,"office_natn_code":null,"office_phone":"574-6318700","office_stat_code":"IN","office_street_line1":"3225 Eddy Street Commons","office_street_line2":null,"office_street_line3":null,"office_zip":"46617","preferred_first_name":null,"primary_job_title":"Development Program Director"}}}');
        intList.add(i2);
        
        Test.startTest();
        insert intList;
        IntegrationConsumerBatch icb =  new IntegrationConsumerBatch();
        database.executeBatch(icb);
        Test.stopTest();
        
        Integration_In__c[] intsUpdatedist = [select id, name, json_message__c, status__c, source_data_set__c, message_id__c , constituent_id__c, process_id__c, message_type__c from Integration_In__c];
        system.debug('ints'+intsUpdatedist);
        system.debug('ints con id'+intsUpdatedist[0].constituent_id__c);
        List<ucinn_ascendv2__Interim__c> interims = [select id, ucinn_ascendv2__First_Name__c, ucinn_ascendv2__Middle_Name__c, ucinn_ascendv2__Last_Name__c
                                                     ,ND_Constituent_Type__c,ucinn_ascendv2__Contact__c, ucinn_ascendv2__Suffix__c, ucinn_ascendv2__Prefix__c, ND_Eclass__c from ucinn_ascendv2__Interim__c where Integration_In_id__c = :intsUpdatedist[0].id ];
        system.assert(intsUpdatedist[0].source_data_set__c.Contains('employee sync'));
        system.debug('interims[0].ucinn_ascendv2__Contact__c '+interims[0].ucinn_ascendv2__Contact__c);
        //system.assert(intsUpdatedist[0].constituent_id__c == interims[0].ucinn_ascendv2__Contact__c);
        system.assert(interims[0].ND_Eclass__c == 'R1');
        system.assert(interims[0].ND_Constituent_Type__c == 'ER');
       
        
    }
static testmethod void testSeparationEmployeeSync() {
        Contact newConstituent = [select id, ucinn_ascendv2__External_System_ID__c from contact where name='Sarah Farris' limit 1];
        List<Integration_In__c> intList= new List<Integration_In__c>();
        
        Integration_In__c i2 = new Integration_In__c(json_message__c='{"object":{"event":{"event_id":"900108275","event_last_modified_by":"900108275","event_sequence_number":"90010827520230705170427","event_time":"2023-07-05T17:04:27.000Z","event_type":"D","source_database":"banner","source_schema":"none","source_table":"employee sync"},"target":{"contact_indicator":null,"death_date":null,"ndid":"sfarris38","separation_reason":null}}}');
        intList.add(i2);
        
        Test.startTest();
        insert intList;
        IntegrationConsumerBatch icb =  new IntegrationConsumerBatch();
        database.executeBatch(icb);
        Test.stopTest();
        
        Integration_In__c[] intsUpdatedist = [select id, name, json_message__c, status__c, source_data_set__c, message_id__c , constituent_id__c, process_id__c, message_type__c from Integration_In__c];
        system.debug('ints'+intsUpdatedist);
        system.debug('ints con id'+intsUpdatedist[0].constituent_id__c);
        List<ucinn_ascendv2__Interim__c> interims = [select id, ucinn_ascendv2__First_Name__c, ucinn_ascendv2__Middle_Name__c, ucinn_ascendv2__Last_Name__c, ND_Constituent_status__c
                                                     ,ND_Constituent_Type__c,nd_Affiliation_Status_1__c,ucinn_ascendv2__Contact__c, ucinn_ascendv2__Suffix__c, ucinn_ascendv2__Prefix__c, ND_Eclass__c from ucinn_ascendv2__Interim__c where Integration_In_id__c = :intsUpdatedist[0].id ];
        system.assert(intsUpdatedist[0].source_data_set__c.Contains('employee sync'));
        system.debug('interims[0].ucinn_ascendv2__Contact__c '+interims[0].ucinn_ascendv2__Contact__c);
        //system.assert(intsUpdatedist[0].constituent_id__c == interims[0].ucinn_ascendv2__Contact__c);
        system.assert(interims[0].nd_Affiliation_Status_1__c == 'Former');
        system.assert(interims[0].ND_Constituent_Type__c == 'EF');
       
        
    }
static testmethod void testDeceasedEmployeeSync() {
        Contact newConstituent = [select id, ucinn_ascendv2__External_System_ID__c from contact where name='Sarah Farris' limit 1];
        List<Integration_In__c> intList= new List<Integration_In__c>();
        
        Integration_In__c i2 = new Integration_In__c(json_message__c='{"object":{"event":{"event_id":"900108275","event_last_modified_by":"900108275","event_sequence_number":"90010827520230705170427","event_time":"2023-07-05T17:04:27.000Z","event_type":"D","source_database":"banner","source_schema":"none","source_table":"employee sync"},"target":{"contact_indicator":null,"death_date":null,"ndid":"sfarris38","separation_reason":"deceased"}}}');
        intList.add(i2);
        
        Test.startTest();
        insert intList;
        IntegrationConsumerBatch icb =  new IntegrationConsumerBatch();
        database.executeBatch(icb);
        Test.stopTest();
        
        Integration_In__c[] intsUpdatedist = [select id, name, json_message__c, status__c, source_data_set__c, message_id__c , constituent_id__c, process_id__c, message_type__c from Integration_In__c];
        system.debug('ints'+intsUpdatedist);
        system.debug('ints con id'+intsUpdatedist[0].constituent_id__c);
        List<ucinn_ascendv2__Interim__c> interims = [select id, ucinn_ascendv2__First_Name__c, ucinn_ascendv2__Middle_Name__c, ucinn_ascendv2__Last_Name__c, ND_Constituent_status__c
                                                     ,ND_Constituent_Type__c,ucinn_ascendv2__Contact__c, ucinn_ascendv2__Suffix__c, ucinn_ascendv2__Prefix__c, ND_Eclass__c from ucinn_ascendv2__Interim__c where Integration_In_id__c = :intsUpdatedist[0].id ];
        system.assert(intsUpdatedist[0].source_data_set__c.Contains('employee sync'));
        system.debug('interims[0].ucinn_ascendv2__Contact__c '+interims[0].ucinn_ascendv2__Contact__c);
        //system.assert(intsUpdatedist[0].constituent_id__c == interims[0].ucinn_ascendv2__Contact__c);
        system.assert(interims[0].ND_Constituent_status__c == 'D');
        system.assert(interims[0].ND_Constituent_Type__c == 'EF');
       
        
    }        
    static testmethod void testStudentSync() {
        Contact newConstituent = [select id, ucinn_ascendv2__External_System_ID__c from contact where name='Sarah Farris' limit 1];
        List<Integration_In__c> intList= new List<Integration_In__c>();
        
        Integration_In__c i2 = new Integration_In__c(json_message__c='{"object":{"changed":["summer_curriculum"],"event":{"event_id":"902141893","event_last_modified_by":"902141893","event_sequence_number":"90214189320230823080654","event_time":"2023-08-23T08:06:54.000Z","event_type":"U","source_database":"banner","source_schema":"none","source_table":"student sync"},"target":{"birth_dt":"2001-06-13","citizen_cntry_code1":"US","citizen_country":"United States of America","common_app_id":"23008412","email_address":"mkorth2@guat.nd.edu","ethnic_code":"CCC","ethnic_description":"White","expected_graduate_date":"2024-05-19","fall_curriculum":[{"campus_code":"M","campus_desc":"Main","classification_code":"04","classification_desc":"Senior","college_code":"BA","college_desc":"Mendoza College of Business","current_term":"Y","degree_code":"BBA","degree_desc":"Bachelor of Business Admin.","department_code":"FIN","department_desc":"Finance","level_code":"UG","level_desc":"Undergraduate","major_code":"FIN","major_desc":"Finance","program_code":"BA-BBA","program_desc":"Bach of Business Admin","study_type":"MAJOR","term_code":"202310","term_desc":"Fall Semester 2023","term_end_date":"2023-12-07T00:00:00","term_start_date":"2023-08-22T00:00:00"},{"campus_code":"M","campus_desc":"Main","classification_code":"04","classification_desc":"Senior","college_code":"BA","college_desc":"Mendoza College of Business","current_term":"Y","degree_code":"BBA","degree_desc":"Bachelor of Business Admin.","department_code":"CDT","department_desc":"Computing & Digtl Technologies","level_code":"UG","level_desc":"Undergraduate","major_code":"MCDT","major_desc":"Computing & Digtl Technologies","program_code":"BA-BBA","program_desc":"Bach of Business Admin","study_type":"MINOR","term_code":"202310","term_desc":"Fall Semester 2023","term_end_date":"2023-12-07T00:00:00","term_start_date":"2023-08-22T00:00:00"}],"first_name":"Matthew","first_year":"2020","gender_code":"M","hall_code":null,"hall_description":null,"home_city":"Westfield","home_nation":null,"home_nation_code":null,"home_phone":"9082325208","home_phone_ext":null,"home_state":"NJ","home_street_line1":"544 Lawrence Avenue","home_street_line2":null,"home_street_line3":null,"home_zip":"07090-3118","last_name":"Korth","law_review":null,"local_city":null,"local_nation":null,"local_nation_code":null,"local_phone":null,"local_phone_extension":null,"local_state":null,"local_street_line1":null,"local_street_line2":null,"local_street_line3":null,"local_zip":null,"maiden_name":null,"middle_name":"Brennan","moot_court":null,"ndid":"sfarris38","netid":"sfarris38","pers_suffix":null,"prefix":null,"religion_code":"CT","religion_description":"Catholic - Roman","salutation":"Matt","slate_id":"340741176","spring_curriculum":[{"campus_code":"M","campus_desc":"Main","classification_code":"04","classification_desc":"Senior","college_code":"BA","college_desc":"Mendoza College of Business","current_term":"N","degree_code":"BBA","degree_desc":"Bachelor of Business Admin.","department_code":"FIN","department_desc":"Finance","level_code":"UG","level_desc":"Undergraduate","major_code":"FIN","major_desc":"Finance","program_code":"BA-BBA","program_desc":"Bach of Business Admin","study_type":"MAJOR","term_code":"202320","term_desc":"Spring Semester 2024","term_end_date":"2024-05-01T00:00:00","term_start_date":"2024-01-16T00:00:00"},{"campus_code":"M","campus_desc":"Main","classification_code":"04","classification_desc":"Senior","college_code":"BA","college_desc":"Mendoza College of Business","current_term":"N","degree_code":"BBA","degree_desc":"Bachelor of Business Admin.","department_code":"CDT","department_desc":"Computing & Digtl Technologies","level_code":"UG","level_desc":"Undergraduate","major_code":"MCDT","major_desc":"Computing & Digtl Technologies","program_code":"BA-BBA","program_desc":"Bach of Business Admin","study_type":"MINOR","term_code":"202320","term_desc":"Spring Semester 2024","term_end_date":"2024-05-01T00:00:00","term_start_date":"2024-01-16T00:00:00"}],"student_type":"Current","summer_curriculum":[{"campus_code":"M","campus_desc":"Main","classification_code":"04","classification_desc":"Senior","college_code":"BA","college_desc":"Mendoza College of Business","current_term":"N","degree_code":"BBA","degree_desc":"Bachelor of Business Admin.","department_code":"FIN","department_desc":"Finance","level_code":"UG","level_desc":"Undergraduate","major_code":"FIN","major_desc":"Finance","program_code":"BA-BBA","program_desc":"Bach of Business Admin","study_type":"MAJOR","term_code":"202400","term_desc":"Summer Session 2024 Unofficial","term_end_date":"2024-07-26T00:00:00","term_start_date":"2024-06-17T00:00:00"},{"campus_code":"M","campus_desc":"Main","classification_code":"04","classification_desc":"Senior","college_code":"BA","college_desc":"Mendoza College of Business","current_term":"N","degree_code":"BBA","degree_desc":"Bachelor of Business Admin.","department_code":"CDT","department_desc":"Computing & Digtl Technologies","level_code":"UG","level_desc":"Undergraduate","major_code":"MCDT","major_desc":"Computing & Digtl Technologies","program_code":"BA-BBA","program_desc":"Bach of Business Admin","study_type":"MINOR","term_code":"202400","term_desc":"Summer Session 2024 Unofficial","term_end_date":"2024-07-26T00:00:00","term_start_date":"2024-06-17T00:00:00"}]}}}');
                                                     //{"object":{"changed":["home_city","home_state","home_street_line1","home_street_line2","home_zip"],"event":{"event_id":"902184550","event_last_modified_by":"902184550","event_sequence_number":"90218455020220124130237","event_time":"2022-01-24T13:02:37.000Z","event_type":"U","source_database":"banner","source_schema":"none","source_table":"student sync"},"target":{"birth_dt":"2003-10-10","citizen_cntry_code1":"US","citizen_country":"United States of America","common_app_id":"25800323","current_curriculum":[{"campus_code":"M","campus_desc":"Main","classification_code":"01","classification_desc":"Freshman","college_code":"FY","college_desc":"First Year of Studies","degree_code":"BSME","degree_desc":"Bach of Sci in Mech Engr","department_code":"AME","department_desc":"Aerospace and Mechanical Engr.","level_code":"UG","level_desc":"Undergraduate","major_code":"ME","major_desc":"Mechanical Engineering","program_code":"FY-EG-ME","program_desc":"FY-Mechanical Engineering","study_type":"MAJOR"}],"email_address":"dalhuay@guat.nd.edu","ethnic_code":"SSS","ethnic_description":"Hispanic or Latino","first_name":"Danielle","first_year":"2021","future_curriculum":[{"campus_code":"M","campus_desc":"Main","classification_code":"01","classification_desc":"Freshman","college_code":"FY","college_desc":"First Year of Studies","degree_code":"BSME","degree_desc":"Bach of Sci in Mech Engr","department_code":"AME","department_desc":"Aerospace and Mechanical Engr.","level_code":"UG","level_desc":"Undergraduate","major_code":"ME","major_desc":"Mechanical Engineering","program_code":"FY-EG-ME","program_desc":"FY-Mechanical Engineering","study_type":"MAJOR"}],"gender_code":"F","hall_code":"HOWA","hall_description":"Howard Hall","home_city":"South Bend","home_nation":null,"home_nation_code":null,"home_phone":"7145199511","home_phone_ext":null,"home_state":"IN","home_street_line1":"Apartment 16D","home_street_line2":"424 North Frances Street","home_street_line3":null,"home_zip":"46617-2316","last_name":"Alhuay","law_review":null,"local_city":null,"local_nation":null,"local_nation_code":null,"local_phone":null,"local_phone_extension":null,"local_state":null,"local_street_line1":null,"local_street_line2":null,"local_street_line3":null,"local_zip":null,"maiden_name":null,"middle_name":"Crystal","moot_court":null,"ndid":"'+newConstituent.ucinn_ascendv2__External_System_ID__c+'","netid":"dalhuay","pers_suffix":null,"prefix":null,"religion_code":"CT","religion_description":"Catholic - Roman","salutation":"Danielle","slate_id":"102566322","student_type":"Current"}}}');
        intList.add(i2);
        
        Test.startTest();
        insert intList;
        IntegrationConsumerBatch icb =  new IntegrationConsumerBatch();
        database.executeBatch(icb);
        Test.stopTest();
        
        Integration_In__c[] intsUpdatedist = [select id, name, json_message__c, status__c, source_data_set__c, message_id__c , constituent_id__c, process_id__c, message_type__c from Integration_In__c];
        system.debug('student ints'+intsUpdatedist);
        system.debug('student ints con id'+intsUpdatedist[0].constituent_id__c);
        List<ucinn_ascendv2__Interim__c> interims = [select id, ucinn_ascendv2__First_Name__c, ucinn_ascendv2__Middle_Name__c, ucinn_ascendv2__Last_Name__c
                                                     ,ucinn_ascendv2__Contact__c, ucinn_ascendv2__Suffix__c,ND_Constituent_status__c
                                                     ,ucinn_ascendv2__Prefix__c, ucinn_ascendv2__Country_of_Birth__c, ucinn_ascendv2__School_ID__c from ucinn_ascendv2__Interim__c where Integration_In_id__c = :intsUpdatedist[0].id ];
        system.assert(intsUpdatedist[0].source_data_set__c.Contains('student sync'));
        //system.debug('student interims[0].ucinn_ascendv2__Contact__c '+interims[0].ucinn_ascendv2__Contact__c);
        //system.assert(interims[0].ucinn_ascendv2__School_ID__c == 'sfarris38');
        //system.assert(interims[0].ucinn_ascendv2__Country_of_Birth__c == 'US');
        
    }
    
    static testmethod void testHivebriteEducation() {
        List<Integration_In__c> intList= new List<Integration_In__c>();
        
        Integration_In__c i2 = new Integration_In__c(json_message__c='{"object":{"changed":["graduation_date","majors","level","school_name","degree_name"],"event":{"event_id":2391797,"event_name":"person education change","event_sequence_number":"72-714364310","event_time":"2024-01-06 21:39:34.000","event_type":"I","priority":66,"source_database":"hivebrite","source_schema":"none","source_table":"person education change"},"target":{"class_year":null,"college":null,"concentration":null,"constituent_id":"2098147","data_source":"HVB","degree_name":"Masters of Philosophy","graduation_date":"2024-08-31 00:00:00.000 -0400","hivebrite_id":2391797,"integration_record_id":null,"level":"Master","majors":"Nuclear Energy","minors":null,"school_name":"University of Cambridge"}}}}');
        intList.add(i2);
        
        Test.startTest();
        insert intList;
        IntegrationConsumerBatch icb =  new IntegrationConsumerBatch();
        database.executeBatch(icb);
        Test.stopTest();
        
        Integration_In__c[] intsUpdatedist = [select id, name, json_message__c, status__c, source_data_set__c, message_id__c , constituent_id__c, process_id__c, message_type__c from Integration_In__c];
        system.debug('ints'+intsUpdatedist);
        system.debug('ints con id'+intsUpdatedist[0].constituent_id__c);
        List<ucinn_ascendv2__Interim__c> interims = [select id, ucinn_ascendv2__First_Name__c, ucinn_ascendv2__Middle_Name__c, ucinn_ascendv2__Last_Name__c, ND_Constituent_status__c
                                                     ,ucinn_ascendv2__Contact__c,ucinn_ascendv2__Status__c, nd_Major1_Code__c from ucinn_ascendv2__Interim__c where Integration_In_id__c = :intsUpdatedist[0].id ];
        system.assert(intsUpdatedist[0].source_data_set__c.Contains('person education change'));
        system.debug('interims[0].ucinn_ascendv2__Contact__c '+interims[0].ucinn_ascendv2__Contact__c);
        system.assert(intsUpdatedist[0].constituent_id__c == interims[0].ucinn_ascendv2__Contact__c);
        system.assert(interims[0].ucinn_ascendv2__Status__c == 'Manual Review');
        system.assert(interims[0].nd_Major1_Code__c == 'Nuclear Energy');
    }
    static testmethod void testHivebriteEmployment() {
        List<Integration_In__c> intList= new List<Integration_In__c>();
        
        Integration_In__c i2 = new Integration_In__c(json_message__c='{"object":{"changed":["job_title"],"event":{"event_id":60656,"event_name":"person experience change","event_sequence_number":"74-714382287","event_time":"2024-01-07 15:03:23.000","event_type":"U","priority":66,"source_database":"hivebrite","source_schema":"none","source_table":"person experience change"},"target":{"constituent_id":"606196","data_source":"HVB","employer_name":"Ban Oral & Maxiilofacial Surgery","employer_name_description":"26006","employment_type":"EP","from":null,"hivebrite_id":60656,"industry":null,"integration_record_id":"246136","job_function":null,"job_title":"Owner","to":null}}}}');
        intList.add(i2);
        
        Test.startTest();
        insert intList;
        IntegrationConsumerBatch icb =  new IntegrationConsumerBatch();
        database.executeBatch(icb);
        Test.stopTest();
        
        Integration_In__c[] intsUpdatedist = [select id, name, json_message__c, status__c, source_data_set__c, message_id__c , constituent_id__c, process_id__c, message_type__c from Integration_In__c];
        system.debug('ints'+intsUpdatedist);
        system.debug('ints con id'+intsUpdatedist[0].constituent_id__c);
        List<ucinn_ascendv2__Interim__c> interims = [select id, ucinn_ascendv2__First_Name__c, ucinn_ascendv2__Middle_Name__c, ucinn_ascendv2__Last_Name__c, ND_Constituent_status__c
                                                     ,ucinn_ascendv2__Contact__c,ucinn_ascendv2__Status__c, nd_Employer_Name_2__c from ucinn_ascendv2__Interim__c where Integration_In_id__c = :intsUpdatedist[0].id ];
        system.assert(intsUpdatedist[0].source_data_set__c.Contains('person experience change'));
        system.debug('interims[0].ucinn_ascendv2__Contact__c '+interims[0].ucinn_ascendv2__Contact__c);
        system.assert(intsUpdatedist[0].constituent_id__c == interims[0].ucinn_ascendv2__Contact__c);
        system.assert(interims[0].ucinn_ascendv2__Status__c == 'Manual Review');
        system.assert(interims[0].nd_Employer_Name_2__c == 'Ban Oral & Maxiilofacial Surgery');
        
    }
    static testmethod void testGiftSync() {
        List<Integration_In__c> intList= new List<Integration_In__c>();
        
        Integration_In__c i2 = new Integration_In__c(json_message__c='{"object": {"event": {"event_id": "3162455","event_sequence_number": "461164712","event_time": "13:39:22","event_type": "I","source_database": "hivebrite gift","source_schema": "", "source_table": "gift"},"target": {"AMOUNT": 110,"CAMPAIGN_ID": 4,"CURRENCY__CODE": "USD","CURRENCY__CREATED_AT": "2019-03-27 12:26:09.000","CURRENCY__ID": 2,"CURRENCY__NAME": "United States Dollar","CURRENCY__SYMBOL": "$","CURRENCY__UPDATED_AT": "2019-03-27 12:26:09.000","GIFT_DETAIL": { "32110": { "ALLOCATION_CODE": "LAW THOMAS MORE", "AMOUNT": 110,"CAMPAIGN_ID": 4, "FUND_ID": 14,"GIFTS_FULL_KEY": "32110","GIFTS_SKEY": 1835678846,"GIFT_CREATED_AT": "2022-01-22 20:50:06.000","GIFT_ID": 32110,"HIST_EFFECTIVE_START_DTM": "2022-01-22 20:50:06.000", "HIST_RECORD_START_DTM": "2022-01-22 16:19:18.734","ORDER_ID": 31624,"SOURCE_PAYLOAD_MESSAGE_ID": 324656566,"UPDATED_AT": "2022-01-22 20:50:06.000"}},"GIFT_IDS": "[32110]","HIST_ID": 4611647,"ID": 32803,"IN_HONOR_OF": false,"IN_MEMORY_OF": false,"LIFELONG_PAYMENT_ENABLED": true, "MOBILE_PERSO": "9895132675","ON_BEHALF_OF": false,"ORDERS_FULL_KEY": "31624","ORDERS_SKEY": 1835678864,"ORDER_BILLING_ADDRESS__ADDRESS_1": "1345 Fleming street","ORDER_BILLING_ADDRESS__ADDRESS_2": "Apartment 502","ORDER_BILLING_ADDRESS__CITY": "Granger","ORDER_BILLING_ADDRESS__COUNTRY": "US","ORDER_BILLING_ADDRESS__CREATED_AT": "2022-01-22 20:50:06.000","ORDER_BILLING_ADDRESS__ID": 5825356,"ORDER_BILLING_ADDRESS__POSTAL_CODE": "46530","ORDER_BILLING_ADDRESS__STATE": "Indiana","ORDER_BILLING_ADDRESS__UPDATED_AT": "2022-01-22 20:50:06.000","ORDER_CREATED_AT": "2022-01-22 20:50:06.000","ORDER_EMAIL": "zthursto@nd.edu","ORDER_FIRSTNAME": "Zach","ORDER_HIST_EFFECTIVE_START_DTM": "2022-01-22 20:50:06.000","ORDER_HIST_RECORD_START_DTM": "2022-01-22 16:19:33.131","ORDER_ID": "31624","ORDER_LASTNAME": "Thurston","ORDER_SOURCE_PAYLOAD_MESSAGE_ID": 324656534,"PARENT_ID": 31541,"PAYMENT_ACCOUNT_ID": 4,"PAYMENT_GATEWAY_INFORMATIONS__TRANSACTION__ID": "m848eb5r","PAYMENT_GATEWAY_INFORMATIONS__TRANSACTION__ORDER_ID": "client_3_1642884602_14e289","PAYMENT_GATEWAY_INFORMATIONS__TRANSACTION__PROCESSOR_AUTHORIZATION_CODE": "Y3GKZR","PAYMENT_STATUS": "paid","PERIODICITY": "month","RECEIPTS_FULL_KEY": "32803","RECEIPTS_SKEY": 1835678884,"RECEIPT_CREATED_AT": "2022-01-22 20:50:06.000","RECEIPT_EMAIL": "zthursto@nd.edu","RECEIPT_FIRSTNAME": "Zach","RECEIPT_HIST_EFFECTIVE_START_DTM": "2022-01-22 20:50:06.000","RECEIPT_HIST_RECORD_START_DTM": "2022-01-22 16:20:14.090","RECEIPT_ID": 32803,"RECEIPT_ITEMS": [{"fund_id": 14,"id": 33669,"product_id": 32110,"product_type": "Donation","quantity": 1,"total_price": "110.0","unit_price": "110.0"}],"RECEIPT_NUMBER": "0003-000742","RECEIPT_SOURCE_PAYLOAD_MESSAGE_ID": 324656555,"RECIEPT_LASTNAME": "Thurston","RECURRING_PAYMENTS_LEFT": 2,"RECURRING_PAYMENT_ENABLED": true,"SEND_CONFIRMATION_EMAIL": true,"TOTAL_EXCL_TAX": 110,"TOTAL_INCL_TAX": 110,"UPDATED_AT": "2022-01-22 20:50:06.000","VAT_AMOUNT": 0}}}');
        intList.add(i2);
        
        Test.startTest();
        insert intList;
        IntegrationConsumerBatch icb =  new IntegrationConsumerBatch();
        database.executeBatch(icb);
        Test.stopTest();
        
        
    }
    static testmethod void testcrmNDAddress() {
        List<Integration_In__c> intList= new List<Integration_In__c>();
        
        Integration_In__c i1 = new Integration_In__c(json_message__c='{"object" : {"event" : {"event_last_modified_by" : "0050R00000CpBCcQAN","event_sequence_number" : "17923757","event_type" : "I","event_time" : "2024-01-09T13:06:57.000Z","event_id" : "a09DV00000GYyxKYAT","source_schema" : "none","source_table" : "acf_Address__c","source_database" : "Salesforce"},"target" : {"Current_Home__c" : "dasas","Constituent_ID__c" : "2068253","sfl_load_unique_id__c" : "","sfl_load_process_id__c" : "","sfl_load_group_id__c" : "","VerificationFlag__c" : "","ValidationDate__c" : "","Type_of_Returned_Mail_3__c" : "","Type_of_Returned_Mail_2__c" : "","Type_of_Returned_Mail_1__c" : "","Trigger_Reciprocal__c" : true,"Total_Preferred_Addresses__c" : 1,"Title__c" : "","System_Start_Date__c" : "","System_End_Date__c" : "","State__c" : "FM","Start_Date__c" : "","Returned_Date__c" : "","ResponseFlag__c" : "","Position_Level__c" : "","Other_Type_of_Returned_Mail_Comments__c" : "","Original_Source_Code__c" : "AFL","Number_Returned__c" : "","Mail_Returned__c" : false,"Joint_Address__c" : "a09DV00000GYyxLYAT","In_Season__c" : false,"GT5__c" : "","GT2__c" : "","GT24__c" : "","GT23__c" : "","GT22__c" : "","GT21__c" : "","GT20__c" : "","GT1__c" : "","End_Date__c" : "","Employment_Record__c" : "","Employer_Name__c" : "","Emailed_Date__c" : "","Country__c" : "BS","Comments__c" : "test","ChangesFlag__c" : "","Change_Source__c" : "SAF","Care_Of__c" : "","Address_Status__c" : "A","Address_Start_Date__c" : "2024-01-09","Address_End_Date__c" : "","Old_Constituent_Address__c" : "","Seasonal_End_Date__c" : "","Seasonal_Start_Date__c" : "","Update_Description__c" : "","Update_Address__c" : "No","Formula_MailingStreetAddress__c" : "dasas","Formula_Mailing_Address__c" : "dasas<br>city, 123","MailingPostalCode__c" : "123","Salesforce_Preferred_Address_Date__c" : "","SF_Preferred_Address__c" : true,"Preferred_Address_Date__c" : "","Preferred_Address__c" : true,"MailingStreet3__c" : "","MailingStreet2__c" : "","MailingStreet__c" : "dasas","MailingState__c" : "","MailingCountry__c" : "","MailingCity__c" : "city","External_ID__c" : "","County_Name__c" : "","Constituent__c" : "0033600001dWg5dAAC","Address_Type__c" : "H","Old_Address_Status__c" : "","Address_Salesforce_ID__c" : "","SystemModstamp" : "2024-01-09T13:07:02.000Z","LastModifiedById" : "0050R00000CpBCcQAN","LastModifiedDate" : "2024-01-09T13:07:02.000Z","CreatedById" : "0050R00000CpBCcQAN","CreatedDate" : "2024-01-09T13:06:57.000Z","RecordTypeId" : "01236000000vXHoAAM","Name" : "A-4565364","IsDeleted" : false,"Id" : "a09DV00000GYyxKYAT","type" : [ "sf:sObject", "acf_Address__c" ]}}}');
	    intList.add(i1);
        
        Test.startTest();
        insert intList;
        IntegrationConsumerBatch icb =  new IntegrationConsumerBatch();
        database.executeBatch(icb);
        Test.stopTest();
    }
    
    static testmethod void testcrmNDCommunicationMethod() {
        List<Integration_In__c> intList= new List<Integration_In__c>();
        
        Integration_In__c i1 = new Integration_In__c(json_message__c='{"object" : {"event" : {"event_last_modified_by" : "0050R00000CpBCcQAN","event_sequence_number" : "17923785","event_type" : "I","event_time" : "2024-01-13T12:25:48.000Z","event_id" : "a1vDV000001UVSiYAO","source_schema" : "none","source_table" : "Communication_Method__c","source_database" : "Salesforce"},"target" : {"Integration_Record_ID__c" : "","crm_nd_create_from_id__c" : "","Constituent_ID__c" : "2068251","Change_Source_NEW__c" : "","sfl_load_unique_id__c" : "","sfl_load_process_id__c" : "","sfl_load_group_id__c" : "","IDEA_Center_Preferred__c" : false,"Type__c" : "","Trigger_Reciprocal__c" : false,"System_Start_Date__c" : "","System_End_Date__c" : "","Stop_Date__c" : "2024-01-13","Status__c" : "A","Start_Date__c" : "2024-01-13","Seasonal_Start_Date__c" : "","Seasonal_End_Date__c" : "","Preferred_Phone__c" : false,"Preferred_Email__c" : true,"Phone_Type__c" : "","Phone_Number__c" : "","Pardot_Email__c" : false,"Original_Source_Code__c" : "P22","Number_of_Bounce_Backs__c" : "","Joint_Phone__c" : "","International_Phone_Number__c" : "","In_Season__c" : false,"External_ID__c" : "","Extension__c" : "","Employment_Record__c" : "","Email_Type__c" : "M","Email_Address__c" : "h@test.com","Do_Not_Phone__c" : false,"Do_Not_Email__c" : false,"Country__c" : "","Contact__c" : "h@test.com","Communication_Method_Phone__c" : "","Communication_Method_Email__c" : "0033600001dWg4VAAS","Comments__c" : "ff","Change_Source__c" : "","Change_Source_Date__c" : "","Constituent__c" : "0033600001dWg4VAAS","LastReferencedDate" : "","LastViewedDate" : "","SystemModstamp" : "2024-01-13T12:25:48.000Z","LastModifiedById" : "0050R00000CpBCcQAN","LastModifiedDate" : "2024-01-13T12:25:48.000Z","CreatedById" : "0050R00000CpBCcQAN","CreatedDate" : "2024-01-13T12:25:48.000Z","RecordTypeId" : "01236000000o5hOAAQ","Name" : "CM2607163","IsDeleted" : false,"Id" : "a1vDV000001UVSiYAO","type" : [ "sf:sObject", "Communication_Method__c" ]}}}');
	    intList.add(i1);
        Integration_In__c i2 = new Integration_In__c(json_message__c='{"object" : {"event" : {"event_last_modified_by" : "0050R00000CpBCcQAN","event_sequence_number" : "17923795","event_type" : "I","event_time" : "2024-01-13T13:06:48.000Z","event_id" : "a1vDV000001UVSoYAO","source_schema" : "none","source_table" : "Communication_Method__c","source_database" : "Salesforce"},"target" : {"Integration_Record_ID__c" : "","crm_nd_create_from_id__c" : "","Constituent_ID__c" : "2068251","Change_Source_NEW__c" : "","sfl_load_unique_id__c" : "","sfl_load_process_id__c" : "","sfl_load_group_id__c" : "","IDEA_Center_Preferred__c" : false,"Type__c" : "","Trigger_Reciprocal__c" : false,"System_Start_Date__c" : "","System_End_Date__c" : "","Stop_Date__c" : "","Status__c" : "A","Start_Date__c" : "2024-01-13","Seasonal_Start_Date__c" : "","Seasonal_End_Date__c" : "","Preferred_Phone__c" : false,"Preferred_Email__c" : false,"Phone_Type__c" : "H","Phone_Number__c" : "1234567893","Pardot_Email__c" : false,"Original_Source_Code__c" : "AA","Number_of_Bounce_Backs__c" : "","Joint_Phone__c" : "a1vDV000001UVSnYAO","International_Phone_Number__c" : "","In_Season__c" : false,"External_ID__c" : "","Extension__c" : "","Employment_Record__c" : "","Email_Type__c" : "","Email_Address__c" : "","Do_Not_Phone__c" : false,"Do_Not_Email__c" : false,"Country__c" : "AZ","Contact__c" : "1234567893","Communication_Method_Phone__c" : "0033600001dWg4VAAS","Communication_Method_Email__c" : "","Comments__c" : "","Change_Source__c" : "","Change_Source_Date__c" : "","Constituent__c" : "0033600001dWg4VAAS","LastReferencedDate" : "","LastViewedDate" : "","SystemModstamp" : "2024-01-13T13:06:48.000Z","LastModifiedById" : "0050R00000CpBCcQAN","LastModifiedDate" : "2024-01-13T13:06:48.000Z","CreatedById" : "0050R00000CpBCcQAN","CreatedDate" : "2024-01-13T13:06:48.000Z","RecordTypeId" : "01236000000o5hPAAQ","Name" : "CM2607165","IsDeleted" : false,"Id" : "a1vDV000001UVSoYAO","type" : [ "sf:sObject", "Communication_Method__c" ]}}}');		
		intList.add(i2);
        Test.startTest();
        insert intList;
        IntegrationConsumerBatch icb =  new IntegrationConsumerBatch();
        database.executeBatch(icb);
        Test.stopTest();
    }
    
    static testmethod void testcrmNDNonNDAssociation() {
        List<Integration_In__c> intList= new List<Integration_In__c>();
        
        Integration_In__c i1 = new Integration_In__c(json_message__c='{"object" : {"event" : {"event_last_modified_by" : "0050R00000CpBCcQAN","event_sequence_number" : "17923805","event_type" : "I","event_time" : "2024-01-13T13:13:47.000Z","event_id" : "a1uDV000001PpaEYAS","source_schema" : "none","source_table" : "Non_ND_Association__c","source_database" : "Salesforce"},"target" : {"Constituent_Name_and_ID__c" : "Scott Page 2068251 - FR","hivebrite_create_from_id__c" : "","integration_record_id__c" : "9701","Mentor__c" : false,"Pitchbook_Verticals__c" : "","Court_Type__c" : "","Judge_s_Name__c" : "","Employer_Name_in_Sync__c" : true,"sfl_load_unique_id__c" : "","sfl_load_process_id__c" : "","sfl_load_group_id__c" : "","npe5_StartDate__c" : "2024-01-01","npe5_EndDate__c" : "","Year__c" : "","User_Group__c" : "","Type_of_Employment__c" : "","Status__c" : "A","Speaker__c" : false,"Self_Employed__c" : false,"Round_4__c" : false,"Round_3__c" : false,"Round_2__c" : false,"Round_1__c" : false,"Process_Builder_Created_Affiliation__c" : false,"Primary_Employer__c" : true,"Position_Level__c" : "ADN","ND_Social_segment__c" : "","ND_Gigot_segment__c" : "","ND_Employee_Type__c" : "F1","Matching_Gift_Employer__c" : false,"Live_Pitch__c" : false,"Job_Title__c" : "","Include_Position_Level_in_Address__c" : false,"Include_Job_Title_in_Address__c" : false,"Field_of_Work__c" : "AR00","Field_of_Speciality_3__c" : "","Field_of_Speciality_2__c" : "","Field_of_Speciality_1__c" : "","External_ID__c" : "","Experiential_Program_Location__c" : "","Experiential_Program_International__c" : false,"Employer_Type__c" : "EP","Employer_Name__c" : "","Data_Source__c" : "P19","Competition_Role__c" : "","Comments__c" : "test","Change_Source__c" : "P19","Affiliation_Name__c" : "","npe5_Organization__c" : "0010R00000Ky6XoQAJ","npe5_Contact__c" : "0033600001dWg4VAAS","LastReferencedDate" : "","LastViewedDate" : "","SystemModstamp" : "2024-01-13T13:13:47.000Z","LastModifiedById" : "0050R00000CpBCcQAN","LastModifiedDate" : "2024-01-13T13:13:47.000Z","CreatedById" : "0050R00000CpBCcQAN","CreatedDate" : "2024-01-13T13:13:47.000Z","RecordTypeId" : "01236000000o5hAAAQ","Name" : "AF-381396","IsDeleted" : false,"Id" : "a1uDV000001PpaEYAS","type" : [ "sf:sObject", "Non_ND_Association__c" ]}}}');
		intList.add(i1);

        Test.startTest();
        insert intList;
        IntegrationConsumerBatch icb =  new IntegrationConsumerBatch();
        database.executeBatch(icb);
        Test.stopTest();
    }
    
    static testmethod void testcrmNDRelationship() {
        List<Integration_In__c> intList= new List<Integration_In__c>();
        Integration_In__c i1 = new Integration_In__c(json_message__c='{"object" : {"event" : {"event_last_modified_by" : "0050R00000CpBCcQAN","event_sequence_number" : "17923808","event_type" : "I","event_time" : "2024-01-13T13:21:15.000Z","event_id" : "a0BDV0000089bfu2AA","source_schema" : "none","source_table" : "Relationship__c","source_database" : "Salesforce"},"target" : {"Matchstick__c" : false,"Related_Constituent_Institutional_Suffix__c" : "FR","Relationship_Explanation__c" : "Scott Page is Cecilia Pages","Relationship_Explanation_Connector__c" : "","Widow_Class_Year__c" : "","Status_Change_Date__c" : "2024-01-13","Spouse_Status__c" : "","Spouse_Preferred_First_Name__c" : "","Source__c" : "P19","Relationship_Type__c" : "FD","Relationship_Status__c" : "","Related_Constituents_Status__c" : "Active","Related_Constituents_Address__c" : "city FM Bahamas","Reciprocal_created__c" : true,"Organization__c" : "","Marriage_Place__c" : "","Marriage_Date__c" : "","Joint_Seasonal_Address__c" : true,"Joint_Salutation__c" : "","Joint_Name_2__c" : "","Joint_Name_1__c" : "","Joint_Mailing__c" : false,"Joint_Home_Phone__c" : true,"Joint_Home_Address__c" : true,"Joint_Credit__c" : true,"Duplicate__c" : "0033600001dWg5dAAC-0033600001dWg4VAAS-FD","Divorce_Initiated__c" : false,"Constituent_Record_Type__c" : "Individual","Comment__c" : "sff","Allow_Duplicates__c" : false,"Add_Spouse_to_Prospect_Record__c" : true,"Active__c" : true,"Old_Relationship_ID__c" : "","npe4_Type__c" : "","Status__c" : "","npe4_RelatedConstituent__c" : "0033600001dWg4VAAS","npe4_ReciprocalRelationship__c" : "a0BDV0000089bft2AA","External_ID__c" : "","npe4_Description__c" : "","Constituent__c" : "0033600001dWg5dAAC","SystemModstamp" : "2024-01-13T13:21:15.000Z","LastModifiedById" : "0050R00000CpBCcQAN","LastModifiedDate" : "2024-01-13T13:21:15.000Z","CreatedById" : "0050R00000CpBCcQAN","CreatedDate" : "2024-01-13T13:21:15.000Z","RecordTypeId" : "01236000000o5mnAAA","Name" : "R-1498682","IsDeleted" : false,"Id" : "a0BDV0000089bfu2AA","type" : [ "sf:sObject", "Relationship__c" ]}}}');
		intList.add(i1);	
        Test.startTest();
        insert intList;
        IntegrationConsumerBatch icb =  new IntegrationConsumerBatch();
        database.executeBatch(icb);
        Test.stopTest();
    }

    static testmethod void testcrmNDHistoricName() {
        List<Integration_In__c> intList= new List<Integration_In__c>();
        Integration_In__c i1 = new Integration_In__c(json_message__c='{"object" : {"event" : {"event_last_modified_by" : "0050R00000CpBCcQAN","event_sequence_number" : "17923816","event_type" : "I","event_time" : "2024-01-13T13:32:36.000Z","event_id" : "a1fDV000001iNWxYAM","source_schema" : "none","source_table" : "Historic_Name__c","source_database" : "Salesforce"},"target" : {"Type__c" : "","Suffix__c" : "eee","Status__c" : "","Sort_Name__c" : "ff, fsfsafs","Primary__c" : true,"Prefix__c" : "mr","Organization__c" : "","Name__c" : "","Name_Type__c" : "00","Name_1__c" : "mr fsfsafs fasfa ff, eee","Mig_External_ID__c" : "","Middle_Name__c" : "fasfa","Mail_Name__c" : "mr fsfsafs f. ff, eee","Last_Name__c" : "ff","First_Name__c" : "fsfsafs","Data_Source_1__c" : "P19","Constituent__c" : "0033600001dWg4VAAS","Comment__c" : "xaxax","Change_Source_1__c" : "P20","LastReferencedDate" : "","LastViewedDate" : "","SystemModstamp" : "2024-01-13T13:32:36.000Z","LastModifiedById" : "0050R00000CpBCcQAN","LastModifiedDate" : "2024-01-13T13:32:36.000Z","CreatedById" : "0050R00000CpBCcQAN","CreatedDate" : "2024-01-13T13:32:36.000Z","RecordTypeId" : "01236000000o5KEAAY","Name" : "HN-1103143","IsDeleted" : false,"OwnerId" : "0050R00000CpBCcQAN","Id" : "a1fDV000001iNWxYAM","type" : [ "sf:sObject", "Historic_Name__c" ]}}}');
		intList.add(i1);	
        Test.startTest();
        insert intList;
        IntegrationConsumerBatch icb =  new IntegrationConsumerBatch();
        database.executeBatch(icb);
        Test.stopTest();
    }
    
    static testmethod void testcrmNDEducationHistory() {
        List<Integration_In__c> intList= new List<Integration_In__c>();
  		Integration_In__c i1 = new Integration_In__c(json_message__c='{"object" : {"event" : {"event_last_modified_by" : "0050R00000CpBCcQAN","event_sequence_number" : "17923819","event_type" : "I","event_time" : "2024-01-13T13:41:33.000Z","event_id" : "a08DV00000AAm9wYAD","source_schema" : "none","source_table" : "Education_History__c","source_database" : "Salesforce"},"target" : {"RecordtypeName__c" : "Non_ND_Degree","Institution_Code__c" : "123456789","Constituent_ID__c" : "2068251","hivebrite_create_from_id__c" : "","Integration_Record_ID__c" : "5493","Source_Code_API__c" : "","Source_Code_NEW__c" : "","sfl_load_unique_id__c" : "","sfl_load_process_id__c" : "","sfl_load_group_id__c" : "","Concentration_2_Field_of_Study__c" : "","Unknown_Institution_Name__c" : "","xseq__c" : "","local_ind__c" : false,"Non_Grad__c" : "","Minor_2__c" : "MADS","Minor_1__c" : "MAFN","Major_3__c" : "AME","Major_2__c" : "ACCY","Honorary_Alum_Ind__c" : false,"Education_Major_1__c" : "ACCT","Division__c" : "","Department__c" : "","Degree_Level__c" : "B","Data_Source__c" : "P21","Concentration_1_Field_of_Study__c" : "ACCT","Comments__c" : "test","College__c" : "","Adm_Year__c" : "","Adm_Type__c" : "","Academic_Degree__c" : "AU","Executive__c" : false,"Old_Education_History_ID__c" : "","School_Old__c" : "","Institution__c" : "001DV00001osSLAYA2","Education_Year__c" : "2024","Education_Grad_Date_1__c" : "","External_ID__c" : "","Constituent__c" : "0033600001dWg4VAAS","Old_Concentration_1_Field_of_Study__c" : "","Old_Education_Major_1__c" : "","Old_Academic_Degree__c" : "","LastReferencedDate" : "","LastViewedDate" : "","SystemModstamp" : "2024-01-13T13:41:33.000Z","LastModifiedById" : "0050R00000CpBCcQAN","LastModifiedDate" : "2024-01-13T13:41:33.000Z","CreatedById" : "0050R00000CpBCcQAN","CreatedDate" : "2024-01-13T13:41:33.000Z","RecordTypeId" : "01236000000o5mAAAQ","Name" : "EH-839788","IsDeleted" : false,"Id" : "a08DV00000AAm9wYAD","type" : [ "sf:sObject", "Education_History__c" ]}}}');
		intList.add(i1);
        
        Test.startTest();
        insert intList;
        IntegrationConsumerBatch icb =  new IntegrationConsumerBatch();
        database.executeBatch(icb);
        Test.stopTest();
    }
}