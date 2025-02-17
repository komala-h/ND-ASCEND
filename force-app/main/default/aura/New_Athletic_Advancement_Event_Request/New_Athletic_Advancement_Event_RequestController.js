({
	init : function(component, event, helper) {
		var url = decodeURIComponent(window.location);
		var isContact = true;
		if (url.includes('/Contact/')) {
			var ContactId = url.substr(url.search('/Contact/') + 9, 18);
			component.set('v.recordId', ContactId);
		}
		else if (url.includes('/Contact/')) {
			var contactId = url.substr(url.search('/Contact/') + 9, 18);
			component.set('v.recordId', contactId);
			isContact = false;
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
                name : 'isContact',
            	type : 'Boolean',
                value : isContact
            }
		];
			flow.startFlow('Athletic_Advancement_Event_Request', inputVariables);
		
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