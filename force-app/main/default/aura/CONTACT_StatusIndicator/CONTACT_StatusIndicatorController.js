({
    doInit: function(component, event, helper){
        component.set("v.showIndicator", false);
        //alert(component.get("v.Textcolor"));
        helper.queryRecord(component);   
        let badgeIconString = component.get("v.badgeIcon");
        
        if (badgeIconString == undefined || badgeIconString == '') {
            console.log('set to false' + badgeIconString);
            component.set("v.badgeIconExists", false);
        } else {
            console.log('set to true');
            component.set("v.badgeIconExists", true);
        }
    },
    doRefresh: function(component, event, helper) {
        window.location.reload();
    }
})