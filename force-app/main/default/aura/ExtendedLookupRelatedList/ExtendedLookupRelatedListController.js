({
	onInit : function(component, event, helper) {
        var additionalFieldsToPopulate = component.get("v.additionalFieldsToPopulate");
        
        helper.loadRecord(component, event);
        
        if (additionalFieldsToPopulate != null && additionalFieldsToPopulate != '') {
            component.set("v.additionalFieldsToPopulateMap", JSON.parse(additionalFieldsToPopulate));
        }
	},
    
    rerenderTable : function(component, event, helper) {
    	helper.loadRecord(component, event);
	}
})