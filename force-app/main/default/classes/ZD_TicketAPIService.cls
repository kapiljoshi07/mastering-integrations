public with sharing class ZD_TicketAPIService {
    
    public static void createOrUpdateZendeskTicket(Case cas, Boolean isInsert){
        ZD_TicketUtils.TicketWrapper wrapper = new ZD_TicketUtils.TicketWrapper();
        wrapper.body = cas.Description;
        wrapper.subject = cas.Subject;
        wrapper.name = cas.Contact.Name;
        wrapper.email = cas.Contact.Email;
        wrapper.priority = cas.Priority.toLowerCase();
        if(!String.isBlank(cas.Zendesk_Ticket__c)){
            wrapper.id = Long.valueOf(cas.Zendesk_Ticket__c);
        }
        if(cas.Zendesk_Agent__r.External_Id__c!=null){
            wrapper.assignee_id = Long.valueOf(cas.Zendesk_Agent__r.External_Id__c);
        }
        makeCallout(JSON.serialize(wrapper), cas.Id, isInsert);
    }

    @future(callout = true)
    private static void makeCallout(String arg, String caseId, Boolean isInsert){
        ZD_TicketUtils.TicketWrapper wrapper = (ZD_TicketUtils.TicketWrapper)JSON.deserialize(arg, ZD_TicketUtils.TicketWrapper.class);
        System.System.debug(wrapper);
        if(isInsert){
            String zd_TicketId = ZD_TicketUtils.createTicket(wrapper);
            List<Case> caseList = new List<Case>();
            for(Case c: [SELECT Id, Zendesk_Ticket__c FROM Case where Id =:caseId LIMIT 1]){
                c.Zendesk_Ticket__c = zd_TicketId;
                caseList.add(c);
            }
            try{
                List<Database.SaveResult> resList = Database.update(caseList, true);
                for(Database.SaveResult res : resList){
                    if(res.isSuccess()){
                        System.debug('Successfully updated zendesk ticket id on case');
                    }else{
                        System.debug('An error occured while updating case with zendesk ticket id\n');
                        System.debug(res.getErrors());
                    }
                }
            }catch(System.exception ex){
                System.debug('An exception occured'+ex.getMessage());
            }
        }else{
            ZD_TicketUtils.updateTicket(wrapper);
        }
        
    }

}