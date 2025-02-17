({
	loadRecord : function(component, event) {
		let action = component.get("c.getRecord");
        action.setParams({
            objectName : component.get("v.targetObjectName"),
            fieldName : component.get("v.targetAccountOrContactFieldName"),
            recordId : component.get("v.recordId")
        });
		action.setCallback(this, function(a) {
            var state = a.getState();

            if(state ==="SUCCESS") {
                let theRec = a.getReturnValue();
                let targetAccountOrContactFieldName = component.get("v.targetAccountOrContactFieldName");
                
                if (theRec != null) {
                    component.set("v.accountOrContactRecordId", theRec[targetAccountOrContactFieldName]);
                } else {
                    component.set("v.accountOrContactRecordId", null);
                }
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