({
    queryRecord: function(component){
        let action = component.get("c.SERVER_QueryRecord");
        action.setParams({
            recordId : component.get("v.recordId"),
            parentObject : component.get("v.parentObject"),
            queryField : component.get("v.queryField")
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            let returnObject = response.getReturnValue();

            if (state == "SUCCESS") {

                if (returnObject != undefined) {
                    let queryField = component.get("v.queryField");
                    let fieldValue = component.get("v.fieldValue");
                    
                    console.log(returnObject);
                    console.log('queryField: ' + component.get("v.queryField"));
                    console.log('fieldValue: ' + component.get("v.fieldValue"));
					console.log(returnObject[queryField]);
                    console.log(returnObject[queryField]== fieldValue);
                    if (returnObject[queryField] == fieldValue) {
                        component.set("v.showIndicator", true);
                    }else if( (fieldValue =='true'|| fieldValue=='false') && returnObject[queryField]== JSON.parse(fieldValue)){
                        component.set("v.showIndicator", true);
                    }
                } else {
                    console.log('undefined return record');
                }
            } else {
                console.log('ERROR STATE' + state);
                console.log(response);
                console.log(response.getError());
            }
        });
     
        $A.enqueueAction(action);
    }
})