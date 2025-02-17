({
	doInit : function(component, event, helper) {
        var recId = component.get("v.recordId");

        if (recId) {
            helper.getMembershipLogosForRecord(component, recId);
        }
    }
})