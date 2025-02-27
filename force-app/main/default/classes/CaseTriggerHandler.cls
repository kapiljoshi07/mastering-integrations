public with sharing class CaseTriggerHandler {
    
    public static void onAfterInsert(List<Case> newCasesList){
        //Iterate on each case record
        CaseHelper.createZDTicket(newCasesList);
    }

    public static void onAfterUpdate(List<Case> newCasesList, Map<Id,Case> oldCaseMap){
        CaseHelper.hasAgentChanged(newCasesList,oldCaseMap);
    }

}