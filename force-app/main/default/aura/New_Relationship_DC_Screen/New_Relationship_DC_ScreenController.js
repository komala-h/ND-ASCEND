({
	init : function(component, event, helper) {
		var url = decodeURIComponent(window.location);
        
        //var isContact = false;
		if (url.includes('/Contact/')) {
			var contactId = url.substr(url.search('/Contact/') + 9, 18);
			component.set('v.recordId', contactId);
            //isContact = true;
        } 

		component.set('v.showModal', true);
		var flow = component.find('flowData');
		var inputVariables = [
        	{
            	name : 'recordId',
            	type : 'String',
            	value : component.get('v.recordId')
        	}
            
		];
			flow.startFlow('New_Relationship_DC_Form_Flow', inputVariables);
		
	},

    statusChange : function (component, event) {
        
        if (event.getParam('status') === 'FINISHED' || event.getParam('status') === 'FINISHED_SCREEN') {
			component.set('v.showModal', false);
            
            var urlEvent = $A.get('e.force:navigateToSObject');            
    		urlEvent.setParams({
      			'recordId': component.get('v.recordId')
    		});
    		urlEvent.fire();
		}
	},
    
    closeModal : function (component, event) {
    	component.set('v.showModal', false);
	}
})