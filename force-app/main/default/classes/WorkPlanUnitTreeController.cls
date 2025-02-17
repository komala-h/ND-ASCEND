/**
 * @author UC Innovation
 * @date 11/10/2021
 * @description Controller for Work Plan Unit Tree
 */
public with sharing class WorkPlanUnitTreeController {
    
    public class WorkPlanUnit {
        @AuraEnabled
        public string name;
        @AuraEnabled
        public string label;
        @AuraEnabled
        public boolean expanded;
        @AuraEnabled
        public List<workPlanUnit> items;
    }  

    @AuraEnabled(cacheable=true)
    public static List<WorkPlanUnit> getWorkPlanUnits(String campaignId){
        List<WorkPlanUnit> wpus = new List<WorkPlanUnit>();
        Map<Id, List<ucinn_ascendv2__Work_Plan_Unit__c>> parentWpuMap = new Map<Id, List<ucinn_ascendv2__Work_Plan_Unit__c>>();

        for (ucinn_ascendv2__Work_Plan_Unit__c wpu : [Select Id, Name, ucinn_ascendv2__Code__c, ucinn_ascendv2__Work_Plan_Unit__c, Comprehensive_Campaign__c, Comprehensive_Campaign__r.Name 
                From ucinn_ascendv2__Work_Plan_Unit__c where nd_Status__c='A' Order By nd_Sort_Order__c Limit :Limits.getLimitQueryRows()]) {

            if (!parentWpuMap.containsKey(wpu.ucinn_ascendv2__Work_Plan_Unit__c)) {
                parentWpuMap.put(wpu.ucinn_ascendv2__Work_Plan_Unit__c, new List<ucinn_ascendv2__Work_Plan_Unit__c>());
            }
            parentWpuMap.get(wpu.ucinn_ascendv2__Work_Plan_Unit__c).add(wpu);
        }

        wpus = getChildren(null, parentWpuMap, campaignId);
        return wpus;
    }

    /**
    * Method to get Work Plan Unit record
    * @param accountId Work Plan Unit record Id
    * @return Work Plan Unit record 
    */
    @AuraEnabled
    public static ucinn_ascendv2__Work_Plan_Unit__c getWorkPlanUnit(String workplanunitId) {
        List<ucinn_ascendv2__Work_Plan_Unit__c> wpuList = [Select Id, Name, RecordTypeId, RecordType.DeveloperName, ucinn_ascendv2__Code__c From ucinn_ascendv2__Work_Plan_Unit__c Where Id = :workplanunitId];
        if (!wpuList.isEmpty()) {
            return wpuList[0];
        }
        return null;
    }

    private static List<WorkPlanUnit> getChildren(Id parentId, Map<Id, List<ucinn_ascendv2__Work_Plan_Unit__c>> parentWpuMap, String campaignId){
        List<WorkPlanUnit> children = new List<WorkPlanUnit>();

        if (parentWpuMap.containsKey(parentId)) {
            for (ucinn_ascendv2__Work_Plan_Unit__c wpu : parentWpuMap.get(parentId)) {
                if (parentId == null && wpu.Comprehensive_Campaign__c == null) {
                    continue;
                }

                if (parentId == null && String.isNotBlank(campaignId)) {
                    if (wpu.Comprehensive_Campaign__c != campaignId) {
                        continue;
                    }
                }
                WorkPlanUnit wrapper = new WorkPlanUnit();
                wrapper.label = ((wpu.ucinn_ascendv2__Code__c != null) ? wpu.ucinn_ascendv2__Code__c + ' ' : '') + wpu.Name;
                wrapper.name = wpu.Id;
                wrapper.expanded = false;
                wrapper.items = getChildren(wpu.Id, parentWpuMap, campaignId);
                children.add(wrapper);

                /*
                if (parentId == null && wpu.Comprehensive_Campaign__c != null) {
                    WorkPlanUnit campaignwrapper = new WorkPlanUnit();
                    campaignwrapper.label = wpu.Comprehensive_Campaign__r.name;
                    campaignwrapper.name = wpu.Comprehensive_Campaign__c;
                    campaignwrapper.expanded = true;
                    campaignwrapper.items = new List<WorkPlanUnit>{wrapper};
                    children.add(campaignwrapper);
                } else {
                    children.add(wrapper);
                }
                */
            }
        }

        return children;
    }

    @AuraEnabled
    public static Map<String,String> getMapCampaignFP(String idOfDeepestFP) {
        // Map<String,String> output = new Map<String, String>();
        // output.put('id of Lowest FP ' + idOfDeepestFP, '1');
        // return output;

        Campaign comprehensiveCampaign;
        ucinn_ascendv2__Work_Plan_Unit__c fp1 = new ucinn_ascendv2__Work_Plan_Unit__c();
        ucinn_ascendv2__Work_Plan_Unit__c fp2 = new ucinn_ascendv2__Work_Plan_Unit__c();
        ucinn_ascendv2__Work_Plan_Unit__c fp3 = new ucinn_ascendv2__Work_Plan_Unit__c();
        ucinn_ascendv2__Work_Plan_Unit__c fp4 = new ucinn_ascendv2__Work_Plan_Unit__c();

        ucinn_ascendv2__Work_Plan_Unit__c currentFp = [SELECT Id, RecordType.Name, ucinn_ascendv2__Work_Plan_Unit__c 
                                                       FROM ucinn_ascendv2__Work_Plan_Unit__c
                                                       WHERE Id =: idOfDeepestFP
                                                       AND  nd_Status__c='A'
                                                       LIMIT 1];

        if (currentFp.RecordType.Name == 'Funding Priority Level 4') {
            fp4 = currentFp;
            currentFp = [SELECT Id, RecordType.Name, ucinn_ascendv2__Work_Plan_Unit__c 
                         FROM ucinn_ascendv2__Work_Plan_Unit__c
                         WHERE Id =: currentFp.ucinn_ascendv2__Work_Plan_Unit__c
                         LIMIT 1];
        }

        if (currentFp.RecordType.Name == 'Funding Priority Level 3') {
            fp3 = currentFp;
            currentFp = [SELECT Id, RecordType.Name, ucinn_ascendv2__Work_Plan_Unit__c 
                         FROM ucinn_ascendv2__Work_Plan_Unit__c
                         WHERE Id =: currentFp.ucinn_ascendv2__Work_Plan_Unit__c
                         LIMIT 1];
        }

        if (currentFp.RecordType.Name == 'Funding Priority Level 2') {
            fp2 = currentFp;
            currentFp = [SELECT Id, RecordType.Name, ucinn_ascendv2__Work_Plan_Unit__c 
                         FROM ucinn_ascendv2__Work_Plan_Unit__c
                         WHERE Id =: currentFp.ucinn_ascendv2__Work_Plan_Unit__c
                         LIMIT 1];
        }

        if (currentFp.RecordType.Name == 'Funding Priority Level 1') {
            fp1 = currentFp;
        }

        Map<String, String> mapFpToId = new Map<String, String>();
        mapFpToId.put('Funding Priority Level 1', fp1.Id);
        mapFpToId.put('Funding Priority Level 2', fp2.Id);
        mapFpToId.put('Funding Priority Level 3', fp3.Id);
        mapFpToId.put('Funding Priority Level 4', fp4.Id);

        return mapFpToId;

    }

}