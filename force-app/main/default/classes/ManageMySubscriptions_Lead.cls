public without sharing class ManageMySubscriptions_Lead {
	public Lead ld {get;set;}
    public Id categoryId {get;set;}
    public string mId {get;set;} // business unit id
    
    public string fName {get; set;}
    public string lName {get; set;}
    public string email {get; set;}
    public string EType {get; set;}
    
    public string subComments {get;set;}
    public Business_unit__mdt busUnit{get;set;}
    
    public Map<Id, ucinn_ascendv2__Service_Indicator_Value__c> categories {get;set;}
    
    @TestVisible
    private map<Id, ucinn_ascendv2__Service_Indicator__c> serviceIndicators; // map of {category Id : contact preferences record}
    public map<Id, Boolean> serviceIndicatorUpdateMap {get; set;}
    public map<Id, ucinn_ascendv2__Service_Indicator__c> serviceIndicator {get;set;} // map of {category Id : contact preferences record}
    public list<string> serviceIndicatorList {get; private set;}
    
    public string openPanel {get;set;} // controls which panel is open by default
	public string resultStatus {public get; private set;}
	public string resultMessage {public get; private set;}
    
    public string unsubscribeReason {get;set;} // selected picklist choice
    
    public list<SelectOption> getUnsubReasons() {
        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('The content is no longer relevant to me', 'The content is no longer relevant to me'));
        options.add(new SelectOption('I get too many emails from you', 'I get too many emails from you'));
        options.add(new SelectOption('I never signed up for your emails', 'I never signed up for your emails'));
        options.add(new SelectOption('Other', 'Other'));
        return options;
    }
    
    public List<SelectOption> getEmailTypes{
        get{
        	list<SelectOption> options = new list<SelectOption>();
            options.add(new SelectOption('U', 'Business Email'));
            options.add(new SelectOption('M', 'Personal Email'));
            return options;
        }
        set;
    }
    
    public ManageMySubscriptions_Lead() {
    	try{
	    	// retrieve subscription Id
	    	categoryId = ApexPages.currentPage().getParameters().get('sId');
	        mId = ApexPages.currentPage().getParameters().get('mId');
			String buQueryString = getQuery('Business_unit__mdt', 'MID__c = :mId limit 1');
			Business_unit__mdt bu = (Business_unit__mdt)Database.query(buQueryString);
			Business_unit__mdt[] busUnits = new List<Business_unit__mdt>();
			busUnits.add(bu);        
	        
	        if(busUnits.size() > 0)
	        	busUnit = busUnits[0];
	        
            if(!string.isBlank(categoryId)) {
                openPanel = 'item1';
            }
            else {
                openPanel = 'item2';
            }
            //list<Contact> cons = new list<Contact>();
            list<Lead> leads = new list<Lead>();
            if (string.isNotBlank(ApexPages.currentPage().getParameters().get('cId'))) {
                //cons = [SELECT Id, FirstName, LastName, UR_Email__c, Constituent_Id__c, Okay_to_Engage__c, Okay_to_Solicit__c FROM Contact WHERE Id =:ApexPages.currentPage().getParameters().get('cId')];
            	leads = [SELECT Id, FirstName, LastName, Email, Email_Type__c FROM Lead WHERE Id =:ApexPages.currentPage().getParameters().get('cId')];
            } 
            
            if(leads.size() > 0) {
                ld = leads[0];
                fName = ld.FirstName;
                lName = ld.LastName;
                email = ld.Email;
                EType = ld.Email_Type__c;
                getCategoriesAndPreferences();
            }
            else {
            	 throw new MyCustomException('Could not query user record.');
            }	        
    	}
    	catch(Exception e){
    		//Boolean success = new PublishErrorsHandler().postError(e, 1);
    		throw e;
    	}
     }
    
    public class MyCustomException extends Exception {}
    
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
                                          WHERE nd_Lead__c =: ld.Id 
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

        // retrieve all categories; if a contact preference does not already exist, then create it.
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
                    serviceIndicator.put(c.Id, new ucinn_ascendv2__Service_Indicator__c(ucinn_ascendv2__Service_Indicator_Value__c= c.Id, nd_Lead__c = ld.Id, Status__c = 'Include', nd_Comments__c = '',recordtypeId=serviceIndicatorRecordTypeId));
                else {
                	serviceIndicators.put(c.Id, new ucinn_ascendv2__Service_Indicator__c(ucinn_ascendv2__Service_Indicator_Value__c= c.Id, nd_Lead__c = ld.Id, Status__c = 'Include', nd_Comments__c = '',recordtypeId=serviceIndicatorRecordTypeId));
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
                                                                                        WHERE nd_Lead__c =: ld.Id AND ucinn_ascendv2__Service_Indicator_Value__r.Public__c = TRUE 
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
    
    public pageReference updateLeadInfo() { 
        try {
            Lead l = new Lead(Id = ld.Id);
            l.FirstName = fName;
            l.LastName = lName;
            l.Email = email;
            l.Email_Type__c = EType;
            update l;
            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Your information has been updated.') );
            resultStatus = 'CONFIRM';
            resultMessage = 'Your information has been updated.';
        }
        catch(Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There was a problem: '+e.getMessage()));
            resultStatus = 'ERROR';
            resultMessage = 'There was a problem: '+ e.getMessage();
        }
        return null;        
    }  
}