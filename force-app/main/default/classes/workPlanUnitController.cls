public with sharing class workPlanUnitController {
    
    @AuraEnabled 
    public static map<string, object> getData(string workUnitId) {
        
        
        map<string, object> data = new map<string, object>();
        List<ucinn_ascendv2__Work_Plan_Unit__c> wpuList = new List<ucinn_ascendv2__Work_Plan_Unit__c>();
        getParents(workUnitId, wpuList);
        system.debug('wpu list'+wpuList);
        List<ucinn_ascendv2__Work_Plan_Unit__c> sortedParents = new List<ucinn_ascendv2__Work_Plan_Unit__c>();
        integer parentListSize = wpuList.size();
        for(integer i = (parentListSize-1); i>=0; i-- ){
            sortedParents.add(wpuList[i]);
        }
        
        
        wpuList = sortedParents;
        //system.debug('sorted wpu list'+wpuList);
        data.put('records',wpuList );
        
        return data;
        
    }
    
    private static void getParents(Id workUnitId, List<ucinn_ascendv2__Work_Plan_Unit__c> parentList){
        //parentList =  new List<ucinn_ascendv2__Work_Plan_Unit__c>();
        ucinn_ascendv2__Work_Plan_Unit__c wpuParent = [select name, ucinn_ascendv2__Work_Plan_Unit__c from ucinn_ascendv2__Work_Plan_Unit__c where id = :workUnitId];
        if (wpuParent.ucinn_ascendv2__Work_Plan_Unit__c != null){
            parentList.add(wpuParent);
            getParents(wpuParent.ucinn_ascendv2__Work_Plan_Unit__c, parentList);            
            
        } else{
            
            parentList.add(wpuParent);
            /*
system.debug('before teja'+parentList);
List<ucinn_ascendv2__Work_Plan_Unit__c> sortedParents = new List<ucinn_ascendv2__Work_Plan_Unit__c>();
integer parentListSize = parentList.size();
for(integer i = (parentListSize-1); i>=0; i-- ){
sortedParents.add(parentList[i]);
}

parentList = sortedParents;
system.debug('after teja'+parentList);
parentList.sort();
system.debug('after sort'+parentList);
*/
        }
        
        
        
    }
    
    public class workPlanUnit{
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
    public static List<workPlanUnit> getWorkPlanUnits(){
        List<workPlanUnit> wpus = new List<workPlanUnit>();
        wpus = getChildren(null);
        return wpus;
    }
    
    private static List<workPlanUnit> getChildren(Id parentId){
        list<WorkPlanUnit> children = new list<WorkPlanUnit>();
        for( ucinn_ascendv2__Work_Plan_Unit__c wpu : [Select id, name from ucinn_ascendv2__Work_Plan_Unit__c where ucinn_ascendv2__Work_Plan_Unit__c = :parentId ]) {
        	WorkPlanUnit wrapper = new WorkPlanUnit();
            wrapper.label = wpu.Name;
            wrapper.name = wpu.Id;
            wrapper.expanded = true;
            wrapper.items = getChildren(wpu.Id);
            children.add(wrapper);
        }
        return children;
    }
    
    
}