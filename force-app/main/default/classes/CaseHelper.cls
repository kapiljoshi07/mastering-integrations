public with sharing class CaseHelper {
    
    public static void createZDTicket(List<case> newCasesList){
        for(Case cas: [SELECT ID, Subject, Description,Priority, Contact.email, Contact.name,Zendesk_Ticket__c, Zendesk_Agent__c, Zendesk_Agent__r.External_Id__c FROM Case WHERE ID in: newCasesList]){
            //Create a ticket for each case
            ZD_TicketAPIService.createOrUpdateZendeskTicket(cas, true);
        }
    }
    
    public static void hasAgentChanged(List<case> newCasesList, Map<Id,Case> oldCaseMap){
        for(Case cas: [SELECT ID, Subject, Description,Priority, Contact.email, Contact.name,Zendesk_Ticket__c, Zendesk_Agent__c, Zendesk_Agent__r.External_Id__c, Zendesk_Agent__r.Name FROM Case WHERE ID in: newCasesList]){
            System.System.debug('Old Agent '+oldCaseMap.get(cas.Id).Zendesk_Agent__r.Name);
            System.System.debug('New Agent '+cas.Zendesk_Agent__r.Name);
            if(cas.Zendesk_Agent__c != oldCaseMap.get(cas.Id).Zendesk_Agent__c){
                System.System.debug('Agent changed');
                ZD_TicketAPIService.createOrUpdateZendeskTicket(cas, false);
            }
        }
    }

}