({
    getMembershipLogosForRecord : function(component, recId) {
        var action = component.get("c.getMembershipLogos");

        action.setParams({
            recId : recId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var logos = response.getReturnValue();
                if (logos) {
                    logos.forEach(logo => {
                        logo.url = $A.get('$Resource.' + logo.name);
                    });
                    component.set("v.membershipLogoList", logos);
                }
            }
            else if (state === "ERROR") {
                console.log('Error: ' + JSON.stringify(response.error));
            }
            else {
                console.log('Unknown problem, state: ' + state + ', error: ' + JSON.stringify(response.error));
            }
        });
        $A.enqueueAction(action);
    }
})