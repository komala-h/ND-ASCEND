({
	loadCaseRecord : function(component, event) {
		let action = component.get("c.getCase");
        action.setParams({
            caseId : component.get("v.recordId")
        });
		action.setCallback(this, function(a) {
            var state = a.getState();

            if(state ==="SUCCESS") {
                let caseRec = a.getReturnValue();
                let targetLookupField = component.get("v.targetLookupField");
                component.set("v.accountOrContactRecordId", caseRec[targetLookupField]);
            } 
            else if (state === "INCOMPLETE") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "Error",
                    "message": "Incomplete error."
                });
                toastEvent.fire();
            }
            else if (state === "ERROR") {
                let error = a.getError();
                if (error && error[0] && error[0].message) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "Error",
                        "message": error[0].message
                    });
                    toastEvent.fire();
                }
                else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "Error",
                        "message": error[0].message
                    });
                    toastEvent.fire();
                }
            }
		});
		$A.enqueueAction(action);
	}
})