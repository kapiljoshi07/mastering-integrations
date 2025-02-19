public with sharing class ZD_TicketAPIService {
    
    public static void createZendeskTicket(Case newCase){
        ZD_TicketUtils.TicketWrapper wrapper = new ZD_TicketUtils.TicketWrapper();
        wrapper.body = newCase.Description;
        wrapper.subject = newCase.Subject;
        wrapper.name = newCase.Contact.Name;
        wrapper.email = newCase.Contact.Email;
        wrapper.priority = newCase.Priority.toLowerCase();

        makeCallout(JSON.serialize(wrapper), newCase.Id);
    }

    @future(callout = true)
    private static void makeCallout(String arg, String caseId){
        ZD_TicketUtils.TicketWrapper wrapper = (ZD_TicketUtils.TicketWrapper)JSON.deserialize(arg, ZD_TicketUtils.TicketWrapper.class);
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
    }

}