/**
 * @author UC Innovation
 * @date 2/2/2023
 * @group LWC Controller
 * @description Controller for LWC Components
 */
public without sharing class CampaignDetailController {

    public class QueryVariable {
        public String Name {get;set;}
        public String Query {get;set;}
        public String Type {get;set;}
        public String TargetFieldName {get;set;}
    }
    
    /**
    * Method to get list of user records
    * @param query query string
    * @return list of user records
    */
    @AuraEnabled
    public static List<User> getUsers(String query) {
        return Database.query(query);
    }
    
    /**
    * Method to get list of campaign records
    * @param query query string
    * @return list of campaign records
    */
    @AuraEnabled
    public static List<Campaign> getCampaigns(String query) {
        return Database.query(query);
    }
    
    /**
    * Method to get list of sobject records
    * @param userId user Id
    * @param campaignId campaign Id
    * @param query query string
    * @param queryVariables query variables string
    * @return list of SObject records
    */
    @AuraEnabled
    public static List<SObject> getRecords(String userId, String campaignId, String query, String queryVariables, String dataSourceSubqueryRelationshipName) {
        List<QueryVariable> variableList = (List<QueryVariable>)JSON.deserialize(queryVariables, List<QueryVariable>.class);
        //List<Campaign> campaignList = [Select Id, StartDate, EndDate From Campaign Where Id=:campaignId];
        List<Campaign> campaignList =[Select Id,Name, StartDate, EndDate,nd_Time__c, (SELECT Id,Name, StartDate, EndDate,nd_Time__c FROM ChildCampaigns) From Campaign Where Id=:campaignId OR ParentId = :campaignId];
        Map<String, String> replaceMap = new Map<String, String>();
		 Datetime campaignEndDate;
        replaceMap.put('#userid#', userId);

        System.debug('#### campaignId: '+campaignId);
        System.debug('#### campaignList: '+campaignList);
       /* for (Campaign c : campaignList) {
    		System.debug('Campaign: ' + c.Id + ' Name: ' + c.Name + ' StartDate: ' + c.StartDate + ' EndDate: ' + c.EndDate);
		}*/
        if (!campaignList.isEmpty()) {
            Campaign cmpgn = campaignList[0];
            Datetime campaignStartDate = DateTime.newInstance(cmpgn.StartDate.year(), cmpgn.StartDate.month(), cmpgn.StartDate.day(), 0, 0, 0);
           //new lines added to overcome null pointer exception 
            if (cmpgn.EndDate == null) {
              cmpgn.EndDate = Date.today();
            }
             campaignEndDate = DateTime.newInstance(cmpgn.EndDate.year(), cmpgn.EndDate.month(), cmpgn.EndDate.day(), 0, 0, 0);

            replaceMap.put('#campaignid#', campaignId);
            replaceMap.put('#campaign__startdate#', campaignStartDate.format('yyyy-MM-dd'));
            replaceMap.put('#campaign__startdate__day#', String.valueOf(campaignStartDate.day()));
            replaceMap.put('#campaign__startdate__month#', String.valueOf(campaignStartDate.month()));
            replaceMap.put('#campaign__startdate__year#', String.valueOf(campaignStartDate.year()));
            replaceMap.put('#campaign__enddate#', campaignEndDate.format('yyyy-MM-dd'));
            replaceMap.put('#campaign__enddate__day#', String.valueOf(campaignEndDate.day()));
            replaceMap.put('#campaign__enddate__month#', String.valueOf(campaignEndDate.month()));
            replaceMap.put('#campaign__enddate__year#', String.valueOf(campaignEndDate.year()));
		      
            for (Integer i = 1; i <= 30; i++) {
                replaceMap.put('#campaign__startdate__addday:' + String.valueOf(-i) + '#', campaignStartDate.addDays(-i).format('yyyy-MM-dd'));
                replaceMap.put('#campaign__startdate__addday:' + String.valueOf(i) + '#', campaignStartDate.addDays(i).format('yyyy-MM-dd'));
                replaceMap.put('#campaign__startdate__addmonth:' + String.valueOf(-i) + '#', campaignStartDate.addMonths(-i).format('yyyy-MM-dd'));
                replaceMap.put('#campaign__startdate__addmonth:' + String.valueOf(i) + '#', campaignStartDate.addMonths(i).format('yyyy-MM-dd'));
                replaceMap.put('#campaign__enddate__addday:' + String.valueOf(-i) + '#', campaignEndDate.addDays(-i).format('yyyy-MM-dd'));
                replaceMap.put('#campaign__enddate__addday:' + String.valueOf(i) + '#', campaignEndDate.addDays(i).format('yyyy-MM-dd'));
                replaceMap.put('#campaign__enddate__addmonth:' + String.valueOf(-i) + '#', campaignEndDate.addMonths(-i).format('yyyy-MM-dd'));
                replaceMap.put('#campaign__enddate__addmonth:' + String.valueOf(i) + '#', campaignEndDate.addMonths(i).format('yyyy-MM-dd'));
            }
        }

        for (String k : replaceMap.keySet()) {
            system.debug('#### k=' + k + '; value=' + replaceMap.get(k));
        }

        if (!variableList.isEmpty()) {
            for (QueryVariable qv : variableList) {
                List<String> mylist = new List<String>();
                String[] fields = qv.TargetFieldName.split('\\.');
                
                for (String k : replaceMap.keySet()) {
                    qv.Query = qv.Query.replace(k, replaceMap.get(k));
                }

                System.debug('#### qv.query:' + qv.Query);

                for (Sobject sobj : Database.query(qv.Query)) {
                    Sobject obj = sobj;
                    Object fieldvalue = null;
                    
                    for (Integer i = 1; i < fields.size(); i++) {
                        if (obj != null) {
                            obj = obj.getSobject(fields[i-1]);
                        }
                    }
                    
                    if (obj != null) {
                        fieldvalue = obj.get(fields[fields.size()-1]);
                    }

                    if (fieldvalue != null) {
                        if (qv.Type.toLowerCase() == 'text') {
                            if (!mylist.contains('\'' + String.valueOf(fieldvalue) + '\'')) {
                                mylist.add('\'' + String.valueOf(fieldvalue) + '\'');
                            }
                        } else {
                            if (!mylist.contains(String.valueOf(fieldvalue))) {
                                mylist.add(String.valueOf(fieldvalue));
                            }
                        }
                    }
                }

                if (mylist.isEmpty()) {
                    if (qv.Type.toLowerCase() == 'text') {
                        mylist.add('\'\'');
                    } else {
                        mylist.add('0');
                    }
                }

                query = query.replace(qv.Name, String.join(mylist, ','));
            }
        }
        
        for (String k : replaceMap.keySet()) {
            Query = Query.replace(k, replaceMap.get(k));
        }

        System.debug('#### query:' + query);

        if (dataSourceSubqueryRelationshipName != '') {
            List<SObject> sublist = new List<SObject>();

            for (SObject main : Database.query(query)) {
                for (Sobject sub : main.getSObjects(dataSourceSubqueryRelationshipName)) {
             /*if (sub.get('nd_Time__c') != null) {
                Time childCampaignTime = (Time) sub.get('nd_Time__c');
                String formattedMinute = (childCampaignTime.minute() < 10) ? '0' + String.valueOf(childCampaignTime.minute()) : String.valueOf(childCampaignTime.minute());
                String formattedTime = String.valueOf(childCampaignTime.hour()) + '-' + formattedMinute;
               // sub.put('nd_Time__c', formattedTime);  
                System.debug('#### Child campaign__time: ' + formattedTime);
            } else {
                  System.debug('#### Child campaign__time:else ' +  '00-00');
                //sub.put('nd_Time__c', '00:00:00'); 
            }*/
                    sublist.add(sub);
                }
            }
		  System.debug('#### sublist:' + sublist);
            return sublist;
        } else {
            return Database.query(query);
        }
    }

    /**
    * Method to get Campaign Detail Setting
    * @param name Setting Name
    * @return Campaign_Detail_Setting__mdt record
    */
    @AuraEnabled
    public static Campaign_Detail_Setting__mdt getCampaignDetailSetting(String name) {
        List<Campaign_Detail_Setting__mdt> mdtList = [Select User_Selector_Query__c, Campaign_Selector_Query__c, Related_List_Config__c From Campaign_Detail_Setting__mdt Where DeveloperName=:name];
        if (!mdtList.isEmpty()) {
            return mdtList[0];
        }
        return null;
    }
}