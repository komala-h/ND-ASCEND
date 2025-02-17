({
	init : function(component, event, helper) {
		var url = decodeURIComponent(window.location);
        var isAccount = false;
		if (url.includes('/Account/')) {
			var accountId = url.substr(url.search('/Account/') + 9, 18);
			component.set('v.recordId', accountId);
            isAccount = true;
		}
		else if (url.includes('/Contact/')) {
			var contactId = url.substr(url.search('/Contact/') + 9, 18);
			component.set('v.recordId', contactId);
		}

		component.set('v.showModal', true);
		var flow = component.find('flowData');
		var inputVariables = [
        	{
            	name : 'recordId',
            	type : 'String',
            	value : component.get('v.recordId')
        	},
            {
            	name : 'isAccount',
            	type : 'Boolean',
            	value : isAccount
        	}
            
		];
			flow.startFlow('Lottery_Application_Request_Form', inputVariables);
		
	},

    statusChange : function (component, event) {
        if (event.getParam('status') === 'FINISHED' || event.getParam('status') === 'FINISHED_SCREEN') {
			component.set('v.showModal', false);
            $A.get('e.force:refreshView').fire();
            /*
            var navEvt = $A.get("e.force:navigateToSObject");
    			navEvt.setParams({
      			"recordId": component.get('v.recordId')
    			});
    			navEvt.fire();
            */    
		}
	},
    
    closeModal : function (component, event) {
    	component.set('v.showModal', false);
	}
})