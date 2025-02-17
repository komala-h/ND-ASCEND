({
	handleCancel : function(component, event, helper) {
		component.set("v.EditMode", false); 
	},
    inlineEdit : function(component,event,helper){   
        component.set("v.EditMode", true); 
    },
    handleSuccess: function(component, event) {
        component.set("v.EditMode", false);
        var updatedRecord = JSON.parse(JSON.stringify(event.getParams()));
        console.log('onsuccess: ', updatedRecord.id);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "type" : 'success',
            "message": "The record has been updated successfully."
        });
        toastEvent.fire();        
    },
    handleError: function (component, event, helper) {
        //Get the error
        var error = event.getParams();
        console.log("Error : " + JSON.stringify(error));
        //Get the error message
        var errorMessage = event.getParam("message");
        console.log("Error Message : " + errorMessage);
                var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error',
            message:errorMessage,
            duration:' 5000',
            type: 'error',
            mode: 'pester'
        });
        toastEvent.fire();
    } ,  
    handleRedirect: function (component, event, helper) {
     var record = component.get("v.accountRecord");    
     component.find("navigation").navigate({
        "type" : "standard__recordPage",
        "attributes": {
            "recordId"      :record.ucinn_ascendv2__Contact__c ,
            "actionName"    : "view"
        }
    }, true);
    }
})