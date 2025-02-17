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
                let junctionInnerQuery = component.get("v.junctionInnerQuery");
                let junctionInnerQueryIdFieldName = component.get("v.junctionInnerQueryIdFieldName");
                let customFilterCriteria = component.get("v.customFilterCriteria");
                
                if (theRec != null) {
                    let accountOrContactRecordId = theRec[targetAccountOrContactFieldName];
                    component.set("v.accountOrContactRecordId", accountOrContactRecordId);
                    
                    if (junctionInnerQuery != '' && junctionInnerQueryIdFieldName != '' && accountOrContactRecordId != null) {
                        junctionInnerQuery = junctionInnerQuery.replace(/#accountOrContactRecordId#/gi, accountOrContactRecordId);
                        
                        let actionInner = component.get("c.getJunctionInnerQueryIds");
                        actionInner.setParams({
                            query : junctionInnerQuery
                        });
                        actionInner.setCallback(this, function(ainner) {
                            if(ainner.getState() ==="SUCCESS") {
                                component.set("v.junctionInnerIdList", ainner.getReturnValue());
                                
                                let junctionInnerIdList = component.get("v.junctionInnerIdList");
                                let Ids = '\'\'';
                                
                                if (junctionInnerIdList.length > 0) {
                                    for (let i = 0; i < junctionInnerIdList.length; i++) {
                                        Ids = Ids + ",\'" + junctionInnerIdList[i] + "\'"; 
                                    }
                                }
                                
                                let q = "Id In (Select " + component.get("v.junctionLookupFieldName") + 
                                    " From " + component.get("v.junctionObjectName") + 
                                    " Where " + junctionInnerQueryIdFieldName + " In (" + Ids + ") " +
                                    " And " + junctionInnerQueryIdFieldName + " <> '' " +
                                	" And " + component.get("v.junctionLookupFieldName") + " <> null)";
                                
                                console.log('#### q1: '+q);
                                
                                component.set("v.totalQueryOverride", q);
                            } 
                            ainner.getReturnValue();
                            component.find("extendedLookupRelatedList").rerenderTable();
                        });
                        $A.enqueueAction(actionInner);
                    } else {
                        let q = "Id In (Select " + component.get("v.junctionLookupFieldName") + 
                                    " From " + component.get("v.junctionObjectName") + 
                                    " Where " + component.get("v.junctionAccountOrContactFieldName") + " = \'" + theRec[targetAccountOrContactFieldName] + "\' " +
                                	" And " + component.get("v.junctionLookupFieldName") + " <> null)";
                        
                        console.log('#### q2: '+q);
                        
                        component.set("v.totalQueryOverride", q);
                    }
                } else {
                    component.set("v.accountOrContactRecordId", null);
                    component.set("v.totalQueryOverride", '');
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