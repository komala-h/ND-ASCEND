({
	init : function(component, event, helper) {
		var url = decodeURIComponent(window.location);
		var isAccount = true;
		if (url.includes('/Account/')) {
			var accountId = url.substr(url.search('/Account/') + 9, 18);
			component.set('v.recordId', accountId);
		}
		else if (url.includes('/Contact/')) {
			var contactId = url.substr(url.search('/Contact/') + 9, 18);
			component.set('v.recordId', contactId);
			isAccount = false;
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
			flow.startFlow('Research_Request', inputVariables);
		
	},

    statusChange : function (component, event) {
        if (event.getParam('status') === 'FINISHED' || event.getParam('status') === 'FINISHED_SCREEN') {
			component.set('v.showModal', false);
		}
	},
    
    closeModal : function (component, event) {
    	component.set('v.showModal', false);
	}
})