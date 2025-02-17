({
	getWorkUnitTiers : function(component, event, helper) {
                // call webservice class, using parameters to get results
        var action = component.get("c.getData");
        //console.log(component.get("v.recordId"));
        action.setParams({
            workUnitId: component.get("v.recordId")
        });
		// Create a callback that is executed after 
        // the server-side action returns        
        action.setCallback(this, function(response) { 
              var state = response.getState();
            console.log('it ran');
            
           if (state === "SUCCESS") {
               
               var returnValue =response.getReturnValue();
                component.set("v.response", returnValue.records );
               console.log(returnValue);
           }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(action);
	}
})