({
    doInit : function(component, event, helper) {
        // component.set('v.parentTreeValues', 'Test');
        // console.log('doinit');
        // component.set("v.userList", '');
    },

	myAction : function(component, event, helper) {
		
	},

    "echo" : function(cmp) {
		console.log('hello from button');
	},

	createNewRecord : function(component, event, helper) {
        
        var createRecordNewEvent = $A.get("e.force:createRecord");
        var defaults = component.get("v.parentTreeValues");
        //print out treeValue here to see if it works
        
        var action = component.get("c.getMapCampaignFP");
        action.setParams({"idOfDeepestFP": defaults});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                // console.log("Success");
                component.set("v.mapCampaignFP", response.getReturnValue());
                // console.log("setting mapCampaignFP to " + response.getReturnValue());
                // console.log("mapCampaignFP after getting " + component.get("v.mapCampaignFP"));
                var fc1 = component.get("v.mapCampaignFP")["Funding Priority Level 1"];
                // console.log("fc1 is " + fc1);


                var params = {
                    "entityApiName": "ucinn_ascendv2__Designation__c"
                };
                var defaultFieldValues = {
                    "Funding_Priority_Level_1__c" : component.get("v.mapCampaignFP")["Funding Priority Level 1"],
                    "Funding_Priority_Level_2__c" : component.get("v.mapCampaignFP")["Funding Priority Level 2"],
                    "Funding_Priority_Level_3__c" : component.get("v.mapCampaignFP")["Funding Priority Level 3"],
                    "Funding_Priority_Level_4__c" : component.get("v.mapCampaignFP")["Funding Priority Level 4"]

                };
                //Comprehensive_Campaign__c : component.get
                params["defaultFieldValues"] = defaultFieldValues;
                
                createRecordNewEvent.setParams(params);
                createRecordNewEvent.fire();
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);

    },


    handleLWCEvent : function(component, event, helper) {

        // console.log('LWC event handled');

        const treeValue = event.getParam('data').treeValue;

        component.set("v.parentTreeValues", treeValue);


        var createRecordNewEvent = $A.get("e.force:createRecord");
        var defaults = component.get("v.parentTreeValues");
        //print out treeValue here to see if it works
        
        var action = component.get("c.getMapCampaignFP");
        action.setParams({"idOfDeepestFP": defaults});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                // console.log("Success");
                component.set("v.mapCampaignFP", response.getReturnValue());
                // console.log("setting mapCampaignFP to " + response.getReturnValue());
                // console.log("mapCampaignFP after getting " + component.get("v.mapCampaignFP"));
                // var fc1 = component.get("v.mapCampaignFP")["Funding Priority Level 1"];
                // console.log("fc1 is " + fc1);


                var params = {
                    "entityApiName": "ucinn_ascendv2__Designation__c"
                };
                var defaultFieldValues = {
                    "Funding_Priority_Level_1__c" : component.get("v.mapCampaignFP")["Funding Priority Level 1"],
                    "Funding_Priority_Level_2__c" : component.get("v.mapCampaignFP")["Funding Priority Level 2"],
                    "Funding_Priority_Level_3__c" : component.get("v.mapCampaignFP")["Funding Priority Level 3"],
                    "Funding_Priority_Level_4__c" : component.get("v.mapCampaignFP")["Funding Priority Level 4"],
                    "Comprehensive_Campaign__c" : component.get("v.mapCampaignFP")["Comprehensive Campaign"]

                };
                
                params["defaultFieldValues"] = defaultFieldValues;
                
                createRecordNewEvent.setParams(params);
                createRecordNewEvent.fire();
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);

    }

    
})