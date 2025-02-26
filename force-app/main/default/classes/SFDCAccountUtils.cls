public with sharing class SFDCAccountUtils {
    
    public static void createAccount(String name, String rating){
        Auhtorization_Config__mdt SFDCAuthConfig = Auhtorization_Config__mdt.getInstance(System.label.Salesforce_prod_authorization_config);
        String body = '{"name":"'+name+'","rating":"'+rating+'"}';
        String endpoint = SFDCAuthConfig.instance_url__c+'/services/data/v60.0/sobjects/Account';
        String authorization = 'Bearer '+SFDCAuthConfig.access_token__c;
        HttpRequest request = CalloutUtils.prepareHttpRequest(endpoint, 'POST', body, 'application/json','application/json', authorization);
        Map<String,System.HttpResponse> resultBodyMap = CalloutUtils.makeCallout(request);
        System.debug(resultBodyMap);
    }

}