public with sharing class ZendeskUsersAPIService {
    
    public static String getZendeskUsers(){
        System.System.debug('INSIDE ZendeskUsersAPIService.getZendeskUsers method');
        System.HttpResponse response = new System.HttpResponse();
        String zendeskUsersPayload = '';
        String endpoint = System.label.ZD_EndpointForGETUsers;
        String header = System.label.ZD_username +':'+ System.label.ZD_api_token;
        Blob headerAsBlob = Blob.valueOf(header);
        System.HttpRequest httpReq = CalloutUtils.prepareHttpRequest(endpoint, 'GET', '', 'application/json', 'application/json', 'BASIC '+EncodingUtil.base64Encode(headerAsBlob));
        try{
            Map<String,System.HttpResponse> statusToResponseMap = CalloutUtils.makeCallout(httpReq);
            if(statusToResponseMap.containsKey('SUCCESS')){
                response = statusToResponseMap.get('SUCCESS');
                if(!String.isBlank(response.getBody())){
                    zendeskUsersPayload = response.getBody();
                }
            }else{
                System.System.debug('ERROR\n'+statusToResponseMap.get('ERROR').getBody());
            }
        }catch(System.CalloutException calloutEx){
            System.System.debug('Callout Exception Occurred\n'+calloutEx.getMessage());
        }catch(System.Exception ex){
            System.System.debug('Some Exception Occurred\n'+ex.getMessage());
        }
        return zendeskUsersPayload;
    }

    public static void createZendeskUsers(List<ZendeskUserResponseWrapper.cls_users> zdUserList){
        
        List<Zendesk_User__c> zdUserstoAdd = new List<Zendesk_User__c>();
        for(ZendeskUserResponseWrapper.cls_users zdUser: zdUserList){
            Zendesk_User__c usr = new Zendesk_User__c();
            usr.Active__c = zdUser.active;
            usr.Email__c = zdUser.email;
            usr.External_id__c = zdUser.id;
            usr.Phone_Number__c = zdUser.phone;
            usr.Role__c = zdUser.role;
            usr.Time_Zone__c = zdUser.time_zone;
            usr.Name = zdUser.name;
            zdUserstoAdd.add(usr);
        }
        if(!zdUserstoAdd.isEmpty()){
            System.System.debug('zdUserstoAdd\n'+zdUserstoAdd);
            try{
                Database.UpsertResult[] saveResList = Database.upsert(zdUserstoAdd, Zendesk_User__c.External_Id__c, false);
                for(Database.UpsertResult res: saveResList){
                    if(res.isSuccess()){
                        System.debug('SUCCESS ✅');
                    }else{
                        for(Database.Error err: res.getErrors()){
                            System.debug('ERROR ❌'+err.getMessage());
                        }
                    }
                }
            }catch(System.Exception ex){
                System.debug('An exception occurred ❌\n'+ex.getMessage()+' at\n'+ex.getStackTraceString());
            }
        }
    }

}