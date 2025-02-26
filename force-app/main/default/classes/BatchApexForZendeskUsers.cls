public with sharing class BatchApexForZendeskUsers implements Database.Batchable<SObject>, Database.AllowsCallouts {
    
    public final String queryString = System.label.BatchApexForZendeskUsersQuery;

    public Database.QueryLocator start(Database.BatchableContext BC){
        Integer count = [SELECT COUNT() FROM Zendesk_User__c];
        System.debug('Zendesk_User__c Record Count: ' + count);

        if (count > 0) {
            System.debug('Using queryString: ' + queryString);
            return Database.getQueryLocator(queryString);
        } else {
            System.debug('Zendesk_User__c is empty, using fallback query.');
            return Database.getQueryLocator('SELECT Id FROM User LIMIT 1');
        }
    }

    public void execute(Database.BatchableContext BC, List<SObject> scope){
        
        Map<String, Zendesk_User__c> zendeskExtIdToUserMap = new Map<String,Zendesk_User__c>();
        for(SObject sobjectRec: scope){
            if(sobjectRec.getSObjectType() == Schema.Zendesk_User__c.getSObjectType()){
                Zendesk_User__c zdUser = (Zendesk_User__c)sobjectRec;
                if(!zendeskExtIdToUserMap.containsKey(zdUser.External_Id__c)){
                    zendeskExtIdToUserMap.put(zdUser.External_Id__c, zdUser);
                }else{
                    zendeskExtIdToUserMap.put(zdUser.External_Id__c, zendeskExtIdToUserMap.get(zdUser.External_Id__c));
                }
            }
        }

        List<ZendeskUserResponseWrapper.cls_users> zdUsersToCreate = new List<ZendeskUserResponseWrapper.cls_users>();

        try{
            String zendeskUsersPayloadString = ZendeskUsersAPIService.getZendeskUsers();
            ZendeskUserResponseWrapper deserializeResults = ZendeskUserResponseWrapper.parse(zendeskUsersPayloadString);
            List<ZendeskUserResponseWrapper.cls_users> zdUserList =  deserializeResults.users;
            for(ZendeskUserResponseWrapper.cls_users zdUser: zdUserList){
                if(zendeskExtIdToUserMap.containsKey(zdUser.external_id)){
                    continue;
                }else{
                    zdUsersToCreate.add(zdUser);
                }
            }
            System.System.debug('INSIDE BatchApexForZendeskUsers \n'+zdUsersToCreate);
            if(!zdUsersToCreate.isEmpty()){
                ZendeskUsersAPIService.createZendeskUsers(zdUsersToCreate);
            }
        }catch(System.Exception ex){
            System.System.debug('ERROR\n '+ex.getMessage()+'Stack Trace\n'+ex.getStackTraceString());
        }
    }

    public void finish(Database.BatchableContext BC){

    }

}