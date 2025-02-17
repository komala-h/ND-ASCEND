/*
 * Description: This batch class is to set the InSeason field on Address relation and to set the seasonal address on constituent and household
 * Author: Komala H @Cube84
 *  
 * 
 */


public class ND_ManageSeasonalAddressBatch implements Database.Batchable<Sobject>,Schedulable {

    public Database.QueryLocator start(Database.BatchableContext BC){
        try{
            String query = 'SELECT id,ucinn_ascendv2__Address__r.ucinn_ascendv2__Address_Line_1__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__Address_Line_2__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__Address_Line_3__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__Address_Line_4__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__City__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__State__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__Country__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__Postal_Code__c,ucinn_ascendv2__Contact__r.Seasonal_City__c,ucinn_ascendv2__Contact__r.Seasonal_State__c,ucinn_ascendv2__Contact__r.Seasonal_Country__c,ucinn_ascendv2__Contact__r.Seasonal_Address_Line_1__c, ucinn_ascendv2__Contact__r.Seasonal_Address_Line_2__c, ucinn_ascendv2__Contact__r.Seasonal_Address_Line_3__c, ucinn_ascendv2__Contact__r.Seasonal_Address_Line_4__c ,ucinn_ascendv2__Contact__r.Seasonal_Zip_Postal_Code__c,ucinn_ascendv2__Address__c,ucinn_ascendv2__Contact__c, ucinn_ascendv2__Seasonal_Start_Day__c, ucinn_ascendv2__Seasonal_Start_Month__c, ucinn_ascendv2__Seasonal_Start_Year__c, ucinn_ascendv2__Seasonal_End_Day__c, ucinn_ascendv2__Seasonal_End_Month__c, ucinn_ascendv2__Seasonal_End_Year__c,In_Season__c, ucinn_ascendv2__Type__c, ucinn_ascendv2__Status__c FROM ucinn_ascendv2__Address_Relation__c WHERE ucinn_ascendv2__Type__c=\'Seasonal\' and ucinn_ascendv2__Status__c=\'Current\'';
         
          // 	String query = 'SELECT id,ucinn_ascendv2__Address__r.ucinn_ascendv2__Address_Line_1__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__Address_Line_2__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__Address_Line_3__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__Address_Line_4__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__City__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__State__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__Country__c,ucinn_ascendv2__Address__r.ucinn_ascendv2__Postal_Code__c,ucinn_ascendv2__Contact__r.Seasonal_City__c,ucinn_ascendv2__Contact__r.Seasonal_State__c,ucinn_ascendv2__Contact__r.Seasonal_Country__c,ucinn_ascendv2__Contact__r.Seasonal_Address_Line_1__c, ucinn_ascendv2__Contact__r.Seasonal_Address_Line_2__c, ucinn_ascendv2__Contact__r.Seasonal_Address_Line_3__c, ucinn_ascendv2__Contact__r.Seasonal_Address_Line_4__c ,ucinn_ascendv2__Contact__r.Seasonal_Zip_Postal_Code__c,ucinn_ascendv2__Address__c,ucinn_ascendv2__Contact__c, ucinn_ascendv2__Seasonal_Start_Day__c, ucinn_ascendv2__Seasonal_Start_Month__c, ucinn_ascendv2__Seasonal_Start_Year__c, ucinn_ascendv2__Seasonal_End_Day__c, ucinn_ascendv2__Seasonal_End_Month__c, ucinn_ascendv2__Seasonal_End_Year__c,In_Season__c, ucinn_ascendv2__Type__c, ucinn_ascendv2__Status__c FROM ucinn_ascendv2__Address_Relation__c WHERE ucinn_ascendv2__Type__c=\'Seasonal\' and ucinn_ascendv2__Status__c=\'Current\' and id=\'a0LEm000001F86LMAS\'';
		    return Database.getQueryLocator(query);  
        }
        Catch(Exception e){
            return null;
        }
    }
    public void execute(Database.BatchableContext BC, list<ucinn_ascendv2__Address_Relation__c> AddrReltnList){
        Date seasonalStartDate;
        Date seasonalEndDate;
        Integer seasonalStartDay;
        Integer seasonalStartMonth;
        Integer seasonalStartYear;
        Integer seasonalEndDay;
        Integer seasonalEndMonth;
        Integer seasonalEndYear;
        Contact con;
		Date TODAY = Date.today() ;
        
        ucinn_ascendv2__Address__c addr = new ucinn_ascendv2__Address__c();
        
        list<ucinn_ascendv2__Address_Relation__c> arListToUpdate = new list<ucinn_ascendv2__Address_Relation__c>();
        list<Contact> constToUpdate = new list<Contact>();
        map<Id,ucinn_ascendv2__Address_Relation__c> arMap = new map<Id,ucinn_ascendv2__Address_Relation__c>();
        map<id,Contact> constMap = new map<Id,Contact>();
             
        for(ucinn_ascendv2__Address_Relation__c ar: AddrReltnList){
            
            //To find the seasonal startday and startmonth
            seasonalStartDay = Integer.ValueOf(ar.ucinn_ascendv2__Seasonal_Start_Day__c);
        	seasonalStartMonth = Integer.ValueOf(ar.ucinn_ascendv2__Seasonal_Start_Month__c);
			
            //To find the seasonal endday and end month 
        	seasonalEndDay = Integer.ValueOf(ar.ucinn_ascendv2__Seasonal_End_Day__c);
        	seasonalEndMonth = Integer.ValueOf(ar.ucinn_ascendv2__Seasonal_End_Month__c);
            
            // If Seasonal start year is blank, then choose current year
            if(ar.ucinn_ascendv2__Seasonal_Start_Year__c!=null && (ar.ucinn_ascendv2__Seasonal_Start_Year__c.equals('0000')) ==false){
                seasonalStartYear = Integer.ValueOf(ar.ucinn_ascendv2__Seasonal_Start_Year__c);
            }
            else{
                seasonalStartYear = TODAY.year();
            }
            
            // If Seasonal End year is blank, then compare seasonal end month with seasonal start month
            // If seasonal end month is less than seasonal start month then set seasonal end year as next year else set it to current year
            
            if(ar.ucinn_ascendv2__Seasonal_End_Year__c!=null  && (ar.ucinn_ascendv2__Seasonal_End_Year__c.equals('0000'))==false ){
                seasonalEndYear = Integer.ValueOf(ar.ucinn_ascendv2__Seasonal_End_Year__c);
            }
            else{
                if(seasonalEndMonth < seasonalStartMonth){
                    Date nextYear = TODAY.addYears(1);
                    seasonalEndYear = nextYear.year();
                }
                else{
                    seasonalEndYear = TODAY.year();
                }
            }
            
            seasonalStartDate = Date.newInstance(seasonalStartYear,seasonalStartMonth,seasonalStartDay);
            seasonalEndDate = Date.newInstance(seasonalEndYear, seasonalEndMonth, seasonalEndDay);
            
            system.debug('@@ seasonal startdate '+seasonalStartDate);
            system.debug('@@ seasonal enddate '+seasonalEndDate);
            
            // check seasonal start date and end date to determine if Inseason can be set to True or not
            if(seasonalStartDate <= TODAY && seasonalEndDate >= TODAY && ar.In_Season__c ==false){
                system.debug('@@ Inside If');
                ar.In_Season__c = true;
                arListToUpdate.add(ar);
                arMap.putAll(arListToUpdate);
                con= new Contact();
                con.id = ar.ucinn_ascendv2__Contact__c;
   				con.Seasonal_Address_Line_1__c = ar.ucinn_ascendv2__Address__r.ucinn_ascendv2__Address_Line_1__c;
                con.Seasonal_Address_Line_2__c = ar.ucinn_ascendv2__Address__r.ucinn_ascendv2__Address_Line_2__c;
                con.Seasonal_Address_Line_3__c = ar.ucinn_ascendv2__Address__r.ucinn_ascendv2__Address_Line_3__c;
                con.Seasonal_Address_Line_4__c = ar.ucinn_ascendv2__Address__r.ucinn_ascendv2__Address_Line_4__c;
                con.Seasonal_City__c = ar.ucinn_ascendv2__Address__r.ucinn_ascendv2__City__c;
                con.Seasonal_State__c = ar.ucinn_ascendv2__Address__r.ucinn_ascendv2__State__c;
                con.Seasonal_Country__c = ar.ucinn_ascendv2__Address__r.ucinn_ascendv2__Country__c;
                con.Seasonal_Zip_Postal_Code__c = ar.ucinn_ascendv2__Address__r.ucinn_ascendv2__Postal_Code__c;
                constToUpdate.add(con);  
                constMap.putAll(constToUpdate);
                continue;
                
            }
            else if(seasonalEndDate < TODAY && ar.In_Season__c == true){
                ar.In_Season__c = false;
                arListToUpdate.add(ar);
                arMap.putAll(arListToUpdate);
                con = new contact();
                con.id = ar.ucinn_ascendv2__Contact__c;
    			con.Seasonal_Address_Line_1__c = '';
                con.Seasonal_Address_Line_2__c = '';
                con.Seasonal_Address_Line_3__c = '';
                con.Seasonal_Address_Line_4__c = '';
                con.Seasonal_City__c = '';
                con.Seasonal_State__c = '';
                con.Seasonal_Country__c = '';
                con.Seasonal_Zip_Postal_Code__c = '';
                constToUpdate.add(con); 
                constMap.putAll(constToUpdate);
                continue;
            }
        }
        
        // Update the addresses
        if(arMap.size()>0){
       		List <Database.SaveResult> arUpdateList = Database.update(arMap.Values(), false);
            	for ( Database.SaveResult ar : arUpdateList) {
                	if ( ar.isSuccess() != true ){
                    	for(Database.Error err : ar.getErrors()) {
                        	System.debug('The following error has occurred.');                    
                        		System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        }
                	}
            	}
        }
        
        //Update the contacts
      	if(constMap.size()>0){
        	List <Database.SaveResult> conUpdateList = Database.update(constMap.Values(), false);
            	for ( Database.SaveResult c : conUpdateList) {
                	if ( c.isSuccess() != true ){
                    	for(Database.Error err : c.getErrors()) {
                        	System.debug('The following error has occurred.');                    
                        		System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        }
                	}
            	}
        }
    }
    
    public void execute(SchedulableContext SC){
        ND_ManageSeasonalAddressBatch i = new ND_ManageSeasonalAddressBatch(); 
      	database.executebatch(i);
    } 
    
    public void finish(Database.BatchableContext BC)    {
        try{
            AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email
                              FROM AsyncApexJob 
                              WHERE Id =:bc.getJobId()];
        	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        	String[] toAddresses = new String[] {a.CreatedBy.Email};
        	mail.setToAddresses(toAddresses);
            mail.setSubject('Manage Seasonal Address Batch job has been completed with status as  ' + a.Status);
        	mail.setPlainTextBody('The batch Apex job processed: ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures.');
        	
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {mail};
        	Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        	if(!results[0].success) {
            	System.debug('The email failed to send: ' + results[0].errors[0].message);
        	} 
        }
        catch(Exception ex){
			system.debug('Exception caught:'+ex);
        }
    }
    
}