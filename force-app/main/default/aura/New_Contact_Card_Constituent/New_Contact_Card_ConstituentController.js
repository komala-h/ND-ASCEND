({
	init : function(component, event, helper) {
		var url = decodeURIComponent(window.location);
		var IsConstituent  = true;
		if (url.includes('/Account/')) {
			var accountId = url.substr(url.search('/Account/') + 9, 18);
			component.set('v.recordId', accountId);
            IsConstituent = false;
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
                name : 'IsConstituent',
            	type : 'Boolean',
                value : IsConstituent
            }
		];
			flow.startFlow('Contact_Card_Screen_Flow', inputVariables);
		
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