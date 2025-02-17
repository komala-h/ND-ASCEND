public without sharing class ManageMySubscriptions {
    public Contact con {get;set;}
    public Id categoryId {get;set;}
    public string mId {get;set;} 
    public string subComments {get;set;}
    public string oFName{get;set;}
    public string oLName{get;set;}
    public string Email{get;set;}
    public string oEmail{get;set;}
    public string EmailType{get;set;}
    public string oEmailType{get;set;}
    public Business_unit__mdt busUnit{get;set;}
    public boolean nameEnabled {get;set;}
    public boolean emailEnabled {get;set;}
    public boolean requestSubmitted {get;set;}
	
    public Map<Id, ucinn_ascendv2__Service_Indicator_Value__c> categories {get;set;}  
    @TestVisible
    private map<Id, ucinn_ascendv2__Service_Indicator__c> serviceIndicators; // map of {serviceIndicatorValue Id : serviceIndicator record}
    public map<Id, Boolean> serviceIndicatorUpdateMap {get; set;}
    public map<Id, ucinn_ascendv2__Service_Indicator__c> serviceIndicator {get;set;} // map of {serviceIndicatorValue Id : serviceIndicator record}
    public set<string> unsubs {get;set;}
    public list<string> serviceIndicatorList {get; private set;}
    
    public boolean okToSolicit{get; set;}
    public boolean okToEngage{get; set;}
    public string openPanel {get;set;} 
	public string resultStatus {public get; private set;}
	public string resultMessage {public get; private set;}
    
    public string unsubscribeReason {get;set;} 
    
    public list<SelectOption> getUnsubReasons() {
        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('The content is no longer relevant to me', 'The content is no longer relevant to me'));
        options.add(new SelectOption('I get too many emails from you', 'I get too many emails from you'));
        options.add(new SelectOption('I never signed up for your emails', 'I never signed up for your emails'));
        options.add(new SelectOption('Other', 'Other'));
        return options;
    }
    
    public List<SelectOption> getEmailTypes{
        get{return getSelectOptions(ucinn_ascendv2__Email__c.ucinn_ascendv2__Type__c.getDescribe().getPicklistValues());}
        set;
    }
    
    private List<SelectOption> getSelectOptions(List<Schema.PicklistEntry> picklistValues){
        List<SelectOption> options = new List<SelectOption>();
        options.add( new SelectOption('', 'None') );
        for(Schema.PicklistEntry pe : picklistValues){            
            options.add( new SelectOption( pe.getValue(), pe.getLabel()) );
        }        
        return options;
    }
    
    public PageReference recordCheck() {
        PageReference pg = null;
        if(string.isNotBlank(ApexPages.currentPage().getParameters().get('cId'))) {
        	string recordId = ApexPages.currentPage().getParameters().get('cId');
            if(recordId.startsWith('00Q')) {
                string url = Url.getSalesforceBaseUrl().toExternalForm() + '/lsubscriptions?';
                map<string, string> params = ApexPages.currentPage().getParameters();
                for(string key : params.keyset()) {
                    url += key + '=' + params.get(key) + '&';
                }
                url = url.removeEndIgnoreCase('&');
                pg = new PageReference(url);
                pg.setRedirect(true);
            }
        }
        return pg;
    }
    
    public ManageMySubscriptions() {
    	try{
	    	categoryId = ApexPages.currentPage().getParameters().get('sId');
	        mId = ApexPages.currentPage().getParameters().get('mId');
			String buQueryString = getQuery('Business_unit__mdt', 'MID__c = :mId limit 1');
			Business_unit__mdt bu = (Business_unit__mdt)Database.query(buQueryString);
			Business_unit__mdt[] busUnits = new List<Business_unit__mdt>();
			busUnits.add(bu);        
	        
	        if(busUnits.size() > 0)
	        	busUnit = busUnits[0];
	        
	        requestSubmitted = false;
            
	        if (!string.isBlank(categoryId)) 
                openPanel = 'item1';
	        else 
                openPanel = 'item2';
	        
            list<Contact> cons = new list<Contact>();
            if (string.isNotBlank(ApexPages.currentPage().getParameters().get('cId'))) {
                if(ApexPages.currentPage().getParameters().get('cId').startsWith('003')) {
                	cons = [SELECT Id, FirstName, LastName, Email, ucinn_ascendv2__Donor_ID__c 
					        FROM Contact 
                            WHERE Id =:ApexPages.currentPage().getParameters().get('cId')];
                }
            } 
			else if (string.isNotBlank(ApexPages.currentPage().getParameters().get('e'))) {
                cons = [SELECT Id, FirstName, LastName, Email,ucinn_ascendv2__Donor_ID__c
				        FROM Contact 
						WHERE Email =:(EncodingUtil.urlDecode(ApexPages.currentPage().getParameters().get('e'), 'UTF-8'))];
            }
            if (cons.size() > 0) {
                con = cons[0];
                try{
                    ucinn_ascendv2__Email__c e = [Select ucinn_ascendv2__Email_Address__c, ucinn_ascendv2__Type__c 
					                              from ucinn_ascendv2__Email__c  
                                                  where ucinn_ascendv2__Contact__c = :con.id and ucinn_ascendv2__Is_Preferred__c = true limit 1]; 
                    EmailType = e.ucinn_ascendv2__Type__c;
                    Email = e.ucinn_ascendv2__Email_Address__c;
                }
				catch(Exception e){}
				
                oFName = con.FirstName;
                oLName = con.LastName;
                oEmail = Email;
                oEmailType = EmailType;
                		
          		if([SELECT Id FROM ucinn_ascendv2__Interim__c where 
                    RecordTypeId in (Select Id from RecordType where DeveloperName = 'Online_Donation_Interface') and 
                    ucinn_ascendv2__Status__c = 'New' and ucinn_ascendv2__Contact__c = :con.Id	and createdById=:userinfo.getUserId() AND
                    (ucinn_ascendv2__First_Name__c!='' OR ucinn_ascendv2__Last_Name__c !='')].size() > 0)                
					nameEnabled = false;
				else
        			nameEnabled = true;
				
				if([SELECT Id FROM ucinn_ascendv2__Interim__c where 
                    RecordTypeId in (Select Id from RecordType where DeveloperName = 'Online_Donation_Interface') and createdById=:userinfo.getUserId() AND
                    ucinn_ascendv2__Status__c = 'New' and ucinn_ascendv2__Contact__c = :con.Id	
                    and (ND_Email_1_Type__c!='' OR ucinn_ascendv2__Email_1__c !='')].size() > 0) 
					emailEnabled = false;
				else
        			emailEnabled = true;    
                
            	getCategoriesAndPreferences();
            } 
            else if(string.isBlank(ApexPages.currentPage().getParameters().get('cId')) || ApexPages.currentPage().getParameters().get('cId').startsWith('003')){
            	 throw new MyCustomException('Could not query user record.');
            }	        
    	}
    	catch(Exception e){
    		throw e;
    	}
        
    }
    
    private static string getQuery(string objectName, string whereClause) {
    	string query = 'SELECT ';
        for(Schema.SObjectField ft : Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap().values()){
      		Schema.DescribeFieldResult fd = ft.getDescribe();
      		query += fd.getName() + ',';  
    	}
        query = query.removeEnd(',') + ' FROM ' + objectName;
        
        if(string.isNotBlank(whereClause)) {
      		query += ' WHERE ' + whereClause; 
    	}
    	return query;
  	}
    
    public class MyCustomException extends Exception {}
    
    public void getCategoriesAndPreferences() {
        
        serviceIndicators = new map<Id, ucinn_ascendv2__Service_Indicator__c>();  
        serviceIndicatorUpdateMap = new map<Id, Boolean>();             
        serviceIndicator = new map<Id, ucinn_ascendv2__Service_Indicator__c>();   
        serviceIndicatorList = new list<string>();
        
        map<string, Id> SIMap = new map<string, Id>();      
		Boolean statusValue;
		for (ucinn_ascendv2__Service_Indicator__c cp : [SELECT Id, ucinn_ascendv2__Service_Indicator_Value__c, ucinn_ascendv2__Service_Indicator_Value__r.ucinn_ascendv2__Code__c,
                                                               ucinn_ascendv2__Service_Indicator_Value__r.Public_Description__c,
                                                               Status__c, nd_Comments__c, ucinn_ascendv2__Start_Date__c, ucinn_ascendv2__Contact__c, 
                                                               ucinn_ascendv2__Service_Indicator_Value__r.Public_Name__c 
										  				FROM ucinn_ascendv2__Service_Indicator__c 
										  				WHERE ucinn_ascendv2__Contact__c =: con.Id 
                                                                AND ucinn_ascendv2__Service_Indicator_Value__r.Public__c = TRUE 
                                                                AND ucinn_ascendv2__Is_Active__c = True
                                                				AND (ucinn_ascendv2__Service_Indicator_Value__r.nd_MID__c = :mId OR ucinn_ascendv2__Service_Indicator_Value__c =: categoryId) 
														ORDER BY ucinn_ascendv2__Service_Indicator_Value__r.Public_Name__c ASC]) {
                    if(cp.ucinn_ascendv2__Service_Indicator_Value__c == categoryId){
                        serviceIndicator.put(cp.ucinn_ascendv2__Service_Indicator_Value__c, cp);
                        if(cp.Status__c!='Include') {                       	
                            serviceIndicators.put(cp.ucinn_ascendv2__Service_Indicator_Value__c, cp);
                            serviceIndicatorUpdateMap.put(cp.ucinn_ascendv2__Service_Indicator_Value__c, false);
                        	if(!SIMap.containsKey(cp.ucinn_ascendv2__Service_Indicator_Value__r.Public_Name__c)) {
                                SIMap.put(cp.ucinn_ascendv2__Service_Indicator_Value__r.Public_Name__c, cp.ucinn_ascendv2__Service_Indicator_Value__c);
                            }
                        }
                    }else{
            			serviceIndicators.put(cp.ucinn_ascendv2__Service_Indicator_Value__c, cp);
                        
                        if(cp.Status__c=='Include')
                            statusValue=true;
                        else
                            statusValue=false;
                        
                        serviceIndicatorUpdateMap.put(cp.ucinn_ascendv2__Service_Indicator_Value__c, statusValue);
                        if(!SIMap.containsKey(cp.ucinn_ascendv2__Service_Indicator_Value__r.Public_Name__c)) {
                            SIMap.put(cp.ucinn_ascendv2__Service_Indicator_Value__r.Public_Name__c, cp.ucinn_ascendv2__Service_Indicator_Value__c);
                        }
                    }
        }

        categories = new map<Id, ucinn_ascendv2__Service_Indicator_Value__c>(); 
        Id serviceIndicatorRecordTypeId = [SELECT Id FROM RecordType where sobjecttype='ucinn_ascendv2__Service_Indicator__c' and developerName='Contact_Service_Indicator' AND IsActive=true].id;
        for (ucinn_ascendv2__Service_Indicator_Value__c c : [SELECT Id, Public_Name__c, Public_Description__c, ucinn_ascendv2__Code__c 
		                      FROM ucinn_ascendv2__Service_Indicator_Value__c 
                              WHERE Public__c = TRUE 
							        AND (nd_MID__c =: mId OR Id =: categoryId) 
                                    AND recordtype.developerName='Marketing_Cloud_Service_Indicator'
                                    ORDER BY Public_Name__c ASC]) {            
                
            categories.put(c.Id, c);
            if (!serviceIndicators.containsKey(c.Id)  && !serviceIndicator.containsKey(c.Id)) {
                if(c.id == categoryId)
                    serviceIndicator.put(c.Id, new ucinn_ascendv2__Service_Indicator__c(ucinn_ascendv2__Service_Indicator_Value__c= c.Id, ucinn_ascendv2__Contact__c = con.Id, Status__c = 'Include', nd_Comments__c = '',recordtypeId=serviceIndicatorRecordTypeId));
                else {
                	serviceIndicators.put(c.Id, new ucinn_ascendv2__Service_Indicator__c(ucinn_ascendv2__Service_Indicator_Value__c= c.Id, ucinn_ascendv2__Contact__c = con.Id, Status__c = 'Include', nd_Comments__c = '',recordtypeId=serviceIndicatorRecordTypeId));
                    serviceIndicatorUpdateMap.put(c.Id, true);
                    if(!SIMap.containsKey(c.Public_Name__c)) {
                        SIMap.put(c.Public_Name__c, c.Id);
                    }
                }
            }
        }
        
        list<string> SINames = new list<string>(SIMap.keySet());
        SINames.sort();
        for(string publicName : SINames) {
            serviceIndicatorList.add(SIMap.get(publicName));
        }
        
        if (!serviceIndicator.containsKey(categoryId) && !serviceIndicators.containsKey(categoryId)) {
            categoryId = null;
            openPanel = 'item2';
        } 
        else openPanel = 'item1';
    }
    
    public pageReference updateSubscription() {
        
        if (!string.isBlank(categoryId)) {
            String comm = serviceIndicator.get(categoryId).nd_Comments__c;
            if(comm == null)
                comm = '';
			
            serviceIndicator.get(categoryId).Status__c = 'Exclude';
            serviceIndicator.get(categoryId).Data_Source__c='MC';
            if(unsubscribeReason != '')
            	serviceIndicator.get(categoryId).nd_Comments__c = system.now()+': '+unsubscribeReason+'\n'+comm;
             
            upsert serviceIndicator.get(categoryId);
        }
        
        getCategoriesAndPreferences();
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Your subscription has been updated.'));
		resultStatus = 'SUCCESS';
		resultMessage = 'Your subscription has been updated.';
        return null;
    }
   
    public pageReference updateAllSubscriptions() {
        system.debug('@@ inside update All subscriptions');
        List<ucinn_ascendv2__Service_Indicator__c> sIndicators = new List<ucinn_ascendv2__Service_Indicator__c>();
        Boolean checkboxValue;
            map<Id, ucinn_ascendv2__Service_Indicator__c> SiMap = new map<Id, ucinn_ascendv2__Service_Indicator__c>([SELECT Id, Status__c, nd_Comments__c 
																						FROM ucinn_ascendv2__Service_Indicator__c 
                                                                                        WHERE ucinn_ascendv2__Contact__c =: con.Id AND ucinn_ascendv2__Service_Indicator_Value__r.Public__c = TRUE 
                                          											    AND (ucinn_ascendv2__Service_Indicator_Value__r.nd_MID__c = :mId OR ucinn_ascendv2__Service_Indicator_Value__c =: categoryId)]);
        
        
        for (ucinn_ascendv2__Service_Indicator__c li: serviceIndicators.values()) {
            checkboxValue = serviceIndicatorUpdateMap.get(li.ucinn_ascendv2__Service_Indicator_Value__c);
            if(checkboxValue==true){
                li.Status__c='Include';
                li.ucinn_ascendv2__End_Date__c = null;
                li.ND_Change_Date__c = Date.today();
            }
            else{
                li.Status__c='Exclude';
             //   li.ucinn_ascendv2__End_Date__c = Date.today();
                li.ucinn_ascendv2__End_Date__c = null;
                li.ND_Change_Date__c = Date.today();
            }
            li.Data_Source__c='MC';
            
                
            if(li.nd_Comments__c == null)
                li.nd_Comments__c = '';
			
            if(!string.isBlank(subComments) && (!SiMap.containsKey(li.Id) || SiMap.get(li.Id).Status__c != li.Status__c))
            	li.nd_Comments__c = system.now()+': '+subComments+'\n'+li.nd_Comments__c;
           
            if(li.id == null){
                if(li.Status__c !='Include')
                    sIndicators.add(li);
			}
			else if(li.Id != null){
                sIndicators.add(li);
            }
        }
        subComments = '';
        upsert sIndicators;
        
        getCategoriesAndPreferences();
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Your subscriptions have been updated.'));
        resultStatus = 'SUCCESS';
		resultMessage = 'Your subscriptions have been updated.';
        return null;
    }
    
    public pageReference updateContactInfo(){
        ucinn_ascendv2__Interim__c interim = new ucinn_ascendv2__Interim__c();
        List<ucinn_ascendv2__Interim__c> interimList = new List<ucinn_ascendv2__Interim__c>();
        Id IntegrationOwnerId = [select id from user where username like '%isa@nd.edu.ascend%' LIMIT 1].Id;
        
        if(requestSubmitted){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Your request has already been submitted.'));
            resultStatus = 'ERROR';
            resultMessage = 'Your request has already been submitted.';
            return null;
        }
        
        if(oFName != con.FirstName || oLName != con.LastName){            
            interimList.add(new ucinn_ascendv2__Interim__c(RecordTypeId = [select id from recordtype where sobjecttype='ucinn_ascendv2__Interim__c' and developername='Online_Donation_Interface'].id, 
                             							   ucinn_ascendv2__Donor_ID__c = con.ucinn_ascendv2__Donor_ID__c ,
                                                           ucinn_ascendv2__Contact__c = con.Id ,
                                                           ucinn_ascendv2__First_Name__c = oFName ,
                                                           ucinn_ascendv2__Last_Name__c = oLName,
                                                           ucinn_ascendv2__Status__c = 'Manual Review',
                                                           ND_data_source_code__c = 'MC',
                                                           ownerId = IntegrationOwnerId
                                                           ));
		}
        
        if(oEmail != Email || oEmailType != EmailType){
            if(Email == '' || EmailType == null){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please choose both an Email as well as Email Type'));
                resultStatus = 'ERROR';
                resultMessage = 'Please choose both an Email as well as Email Type';
            	return null;	
            }
			else{             
				interim = new ucinn_ascendv2__Interim__c(RecordTypeId = [select id from recordtype where sobjecttype='ucinn_ascendv2__Interim__c' and developername='Online_Donation_Interface'].id, 
                                 						 ucinn_ascendv2__Donor_ID__c = con.ucinn_ascendv2__Donor_ID__c ,
                                                         ucinn_ascendv2__Contact__c = con.Id ,
                                 						 ucinn_ascendv2__Email_1__c = Email,
                                 						 ND_Email_1_Type__c = EmailType,
                                 						 ucinn_ascendv2__Status__c = 'Manual Review',
                                                         ND_data_source_code__c = 'MC',
                                                         ND_Email_1_Status__c = 'Current',
                                                         ownerId = IntegrationOwnerId
                                 						 );
 				interimList.add(interim);                
            }
        }
        
        if(interimList.size() > 0){                                
            try{
                insert interimList;
                requestSubmitted = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Your request has been submitted.') );
                resultStatus = 'CONFIRM';
                resultMessage = 'Your request has been submitted.';
                system.debug('Interim record has been created.');
            }catch(Exception e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There was a problem submitting the request: '+e.getMessage()));
                resultStatus = 'ERROR';
                resultMessage = 'There was a problem submitting the request: '+ e.getMessage();
                system.debug('Error : ' + e.getMessage());
            }
        }
        return null;  
    }
}