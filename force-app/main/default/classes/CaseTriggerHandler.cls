public with sharing class CaseTriggerHandler {
    
    public static void onAfterInsert(List<Case> newCasesList){
        //Iterate on each case record
        for(Case cas: [SELECT ID, Subject, Description,Priority, Contact.email, Contact.name,Zendesk_Ticket__c FROM Case WHERE ID in: newCasesList]){
            //Create a ticket for each case
            ZD_TicketAPIService.createZendeskTicket(cas);
        }
    }

}