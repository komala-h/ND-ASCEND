/**
 * @author UC Innovation
 * @date 11/10/2021
 * @description Controller for Work Plan Unit Tree for Designation New Button
 */
public with sharing class asc_UTIL_FundingPriorityTreeController {
    
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
    public static List<WorkPlanUnit> getWorkPlanUnits(){
        List<WorkPlanUnit> wpus = new List<WorkPlanUnit>();
        Map<Id, List<ucinn_ascendv2__Work_Plan_Unit__c>> parentWpuMap = new Map<Id, List<ucinn_ascendv2__Work_Plan_Unit__c>>();

        for (ucinn_ascendv2__Work_Plan_Unit__c wpu : [Select Id, Name, ucinn_ascendv2__Work_Plan_Unit__c, ucinn_ascendv2__Code__c From ucinn_ascendv2__Work_Plan_Unit__c where nd_Status__c='A' Order By nd_Sort_Order__c Limit :Limits.getLimitQueryRows()]) {
            if (!parentWpuMap.containsKey(wpu.ucinn_ascendv2__Work_Plan_Unit__c)) {
                parentWpuMap.put(wpu.ucinn_ascendv2__Work_Plan_Unit__c, new List<ucinn_ascendv2__Work_Plan_Unit__c>());
            }
            parentWpuMap.get(wpu.ucinn_ascendv2__Work_Plan_Unit__c).add(wpu);
        }

        wpus = getChildren(null, parentWpuMap);
        wpus = addComprehensiveCampaign(wpus);

        return wpus;
    }

    private static List<WorkPlanUnit> getChildren(Id parentId, Map<Id, List<ucinn_ascendv2__Work_Plan_Unit__c>> parentWpuMap){
        List<WorkPlanUnit> children = new List<WorkPlanUnit>();

        if (parentWpuMap.containsKey(parentId)) {
            for (ucinn_ascendv2__Work_Plan_Unit__c wpu : parentWpuMap.get(parentId)) {
                WorkPlanUnit wrapper = new WorkPlanUnit();
                wrapper.label = ((wpu.ucinn_ascendv2__Code__c != null) ? wpu.ucinn_ascendv2__Code__c + ' ' : '') + wpu.Name;
                wrapper.name = wpu.Id;
                wrapper.expanded = false;
                wrapper.items = getChildren(wpu.Id, parentWpuMap);
                children.add(wrapper);
            }
        }

        return children;
    }

    private static List<WorkPlanUnit> addComprehensiveCampaign(List<WorkPlanUnit> currentWpus) {

        Map<Id, WorkPlanUnit> mapFpIdToFp = new Map<Id, WorkPlanUnit>();
        for (WorkPlanUnit wpu : currentWpus) {
            mapFpIdToFp.put(wpu.name, wpu);
        }
        Set<Id> levelOneFpIds = mapFpIdToFp.keySet();

        List<ucinn_ascendv2__Work_Plan_Unit__c> levelOneFps = [SELECT Id, Name, Comprehensive_Campaign__c
                                                                    FROM ucinn_ascendv2__Work_Plan_Unit__c
                                                                    WHERE (Id IN : levelOneFpIds) Order By nd_Sort_Order__c ];

        // Map<Id, Id> mapFpIdToCampaignId = new Map<Id, Id>();

        Map<Id, List<WorkPlanUnit>> mapCampaignIdToFps = new Map<Id, List<WorkPlanUnit>>();

        List<WorkPlanUnit> fpsWithNoCampaign = new List<WorkPlanUnit>();

        for (ucinn_ascendv2__Work_Plan_Unit__c levelOneFp : levelOneFps) {

            Id campaignId = levelOneFp.Comprehensive_Campaign__c;
            if (campaignId != null) {
                if (!mapCampaignIdToFps.keySet().contains(campaignId)) {
                    mapCampaignIdToFps.put(campaignId, new List<WorkPlanUnit>());
                }
                mapCampaignIdToFps.get(campaignId).add(mapFpIdToFp.get(levelOneFp.Id));
                //
                // mapFpIdToCampaignId.put(levelOneFp.Id, levelOneFp.Comprehensive_Campaign__c);
            }
            else {
                fpsWithNoCampaign.add(mapFpIdToFp.get(levelOneFp.Id));
           }
        }

        Set<Id> comprehensiveCampaignIds = mapCampaignIdToFps.keySet();

        List<Campaign> comprehensiveCampaigns = [SELECT Id, Name
                                            FROM Campaign
                                            WHERE (Id IN: comprehensiveCampaignIds)];
        // Map<Id, String> mapCampaignIdToCampaignName = new Map<Id, String>();
        // for (Campaign comprehensiveCampaign : comprehensiveCampaigns) {
        //     mapCampaignIdToCampaignName.put(comprehensiveCampaign.Id, comprehensiveCampaign.Name);
        // }

        // system.debug('comprehensivecampaigns ' + comprehensiveCampaigns);
        // system.debug('mapFpIdToCampaignId ' + mapFpIdToCampaignId);
        // system.debug('mapCampaignIdToCampaignName ' + mapCampaignIdToCampaignName);

        // system.debug('!!!current wpus ' + currentWpus);

        List<asc_UTIL_FundingPriorityTreeController.WorkPlanUnit> currentWpusClone = new List<asc_UTIL_FundingPriorityTreeController.WorkPlanUnit>();

        currentWpusClone.addAll(fpsWithNoCampaign);

        for (Campaign comprehensiveCampaign : comprehensiveCampaigns) {
            //List<WorkPlanUnit> wrapperItems = mapCampaignIdToFps(comprehensiveCampaignIds);
            WorkPlanUnit wrapper = new WorkPlanUnit();
            wrapper.label = comprehensiveCampaign.Name;
            wrapper.name = comprehensiveCampaign.Id;
            wrapper.expanded = false;
            List<WorkPlanUnit> wrapperItems = mapCampaignIdToFps.get(comprehensiveCampaign.Id);
            wrapper.items = wrapperItems;
            currentWpusClone.add(wrapper);
        }

        return currentWpusClone;


        // for (asc_UTIL_FundingPriorityTreeController.WorkPlanUnit currentWpu : currentWpus) {
            
        //     WorkPlanUnit wrapper = new WorkPlanUnit();

        //     Id comprehensiveCampaignId = mapFpIdToCampaignId.get(currentWpu.name);
        //     if (comprehensiveCampaignId != null) {
        //         String comprehensiveCampaignName = mapCampaignIdToCampaignName.get(comprehensiveCampaignId);
        //         wrapper.label = comprehensiveCampaignName;
        //         wrapper.name = comprehensiveCampaignId;
        //         wrapper.expanded = true;
        //         List<WorkPlanUnit> wrapperItems = new List<WorkPlanUnit>();
        //         wrapperItems.add(currentWpu);
        //         wrapper.items = wrapperItems;
        //     }
        //     else {
        //         wrapper = currentWpu;
        //     }
        //     currentWpusClone.add(wrapper);

        // }

        // return currentWpusClone;
        
        // /*
        // for (asc_UTIL_FundingPriorityTreeController.WorkPlanUnit wpu : wpus) {
        //     system.debug(wpu);
        // }
        // */
        // // Campaign comprehensiveCampaigns = [SELECT Id, 
        // //                                     (SELECT Id, Name FROM Funding_Priorities__r WHERE (Id In: levelOneFpIds) LIMIT 1)
        // //                                   FROM Campaign 
        // //                                   LIMIT 1];
        // // system.debug(comprehensiveCampaigns);
        // // List<ucinn_ascendv2__Work_Plan_Unit__c> lst = comprehensiveCampaigns.Funding_Priorities__r;
        // // system.debug(lst.get(0).get('Name'));


        // //query on levelOneFpIds to get their parent campaign

        // List<WorkPlanUnit> wpusClone = currentWpus.clone();
        // Integer index = 0;
        // for (WorkPlanUnit wpu : currentWpus) {

        //     WorkPlanUnit wrapper = new WorkPlanUnit();
        //     system.debug('!!! ' + wpu.name);
        //     system.debug('!!! ' + wpu.label);
        //     //wrapper.name = id from query from above
        //     //wrapper.items = wpu;

        //     //wpuToEdit = wrapper;
        //     //wpusClone.set(index, wrapper);
        //     index += 1;
        // }

        // return wpusClone;

    }

    @AuraEnabled
    public static Map<String,String> getMapCampaignFP(String idOfDeepestFP) {
        // Map<String,String> output = new Map<String, String>();
        // output.put('id of Lowest FP ' + idOfDeepestFP, '1');
        // return output;

        String comprehensiveCampaignId = '';
        ucinn_ascendv2__Work_Plan_Unit__c fp1 = new ucinn_ascendv2__Work_Plan_Unit__c();
        ucinn_ascendv2__Work_Plan_Unit__c fp2 = new ucinn_ascendv2__Work_Plan_Unit__c();
        ucinn_ascendv2__Work_Plan_Unit__c fp3 = new ucinn_ascendv2__Work_Plan_Unit__c();
        ucinn_ascendv2__Work_Plan_Unit__c fp4 = new ucinn_ascendv2__Work_Plan_Unit__c();

        List<ucinn_ascendv2__Work_Plan_Unit__c> currentFps = [SELECT Id, RecordType.Name, ucinn_ascendv2__Work_Plan_Unit__c, Comprehensive_Campaign__c 
                                                       FROM ucinn_ascendv2__Work_Plan_Unit__c
                                                       WHERE Id =: idOfDeepestFP Order By nd_Sort_Order__c];

        if (currentFps.size() == 0) {
            comprehensiveCampaignId = idOfDeepestFP;
        }
        else {
            ucinn_ascendv2__Work_Plan_Unit__c currentFp = currentFps.get(0);

            if (currentFp.RecordType.Name == 'Funding Priority Level 4') {
                fp4 = currentFp;
                currentFp = [SELECT Id, RecordType.Name, ucinn_ascendv2__Work_Plan_Unit__c, Comprehensive_Campaign__c 
                            FROM ucinn_ascendv2__Work_Plan_Unit__c
                            WHERE Id =: currentFp.ucinn_ascendv2__Work_Plan_Unit__c
                            LIMIT 1];
            }

            if (currentFp.RecordType.Name == 'Funding Priority Level 3') {
                fp3 = currentFp;
                currentFp = [SELECT Id, RecordType.Name, ucinn_ascendv2__Work_Plan_Unit__c, Comprehensive_Campaign__c 
                            FROM ucinn_ascendv2__Work_Plan_Unit__c
                            WHERE Id =: currentFp.ucinn_ascendv2__Work_Plan_Unit__c
                            LIMIT 1];
            }

            if (currentFp.RecordType.Name == 'Funding Priority Level 2') {
                fp2 = currentFp;
                currentFp = [SELECT Id, RecordType.Name, ucinn_ascendv2__Work_Plan_Unit__c, Comprehensive_Campaign__c 
                            FROM ucinn_ascendv2__Work_Plan_Unit__c
                            WHERE Id =: currentFp.ucinn_ascendv2__Work_Plan_Unit__c
                            LIMIT 1];
            }

            if (currentFp.RecordType.Name == 'Funding Priority Level 1') {
                fp1 = currentFp;
            }

            comprehensiveCampaignId = currentFp.Comprehensive_Campaign__c;

        }

        Map<String, String> mapFpToId = new Map<String, String>();
        mapFpToId.put('Comprehensive Campaign', comprehensiveCampaignId);
        mapFpToId.put('Funding Priority Level 1', fp1.Id);
        mapFpToId.put('Funding Priority Level 2', fp2.Id);
        mapFpToId.put('Funding Priority Level 3', fp3.Id);
        mapFpToId.put('Funding Priority Level 4', fp4.Id);

        return mapFpToId;

    }

}