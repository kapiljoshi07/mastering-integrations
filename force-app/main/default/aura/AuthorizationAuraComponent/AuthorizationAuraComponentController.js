({
    doInit : function(component, event, helper) {
        var action = component.get("c.getAccessToken");
        action.setParams({ authCode : component.get("v.authCode") });
        $A.enqueueAction(action);
    }
})