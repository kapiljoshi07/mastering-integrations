public with sharing class SalesforceTokenUtils {
    
    public static void calloutForToken(String code){
        Auhtorization_Config__mdt SFDCAuthConfig = Auhtorization_Config__mdt.getInstance(System.label.Salesforce_prod_authorization_config);
        if(SFDCAuthConfig!=null){
            Map<String, Object> fieldWithValuesMap = new Map<String,Object>();
            HttpRequest httpReq = new HttpRequest();
            String orgURL = SFDCAuthConfig.environment__c == 'Production' ? 'https://login.salesforce.com' : 'https://test.salesforce.com';
            String tokenURL = orgURL+'/'+SFDCAuthConfig.token_url__c;
            String redirect_uri = System.URL.getOrgDomainUrl().toExternalForm() + '/apex/' + SFDCAuthConfig.page_name__c;
            String requestBody ='';
            String auth = '';
            String refreshToken = '';
            try{
                Boolean isTokenValid = SalesforceTokenUtils.isValid(SFDCAuthConfig);
                if(!isTokenValid){
                    System.debug('TOKEN NO LONGER VALID');
                    requestBody = 'grant_type=refresh_token&client_id='+SFDCAuthConfig.client_id__c+'&client_secret='+SFDCAuthConfig.client_secret__c+'&refresh_token='+SFDCAuthConfig.refresh_token__c;
                    refreshToken = SFDCAuthConfig.refresh_token__c;
                }else{
                    System.debug('TOKEN STILL VALID');
                    requestBody = 'code='+code+'&grant_type=authorization_code&client_id='+SFDCAuthConfig.client_id__c+'&client_secret='+SFDCAuthConfig.client_secret__c+'&redirect_uri='+redirect_uri;
                    System.debug(requestBody);
                    auth = 'Bearer '+SFDCAuthConfig.access_token__c;
                }
                httpReq = CalloutUtils.prepareHttpRequest(tokenURL, 'POST', requestBody, 'application/x-www-form-urlencoded', 'application/json', auth);
                fieldWithValuesMap = SalesforceTokenUtils.refreshOrGetNewToken(httpReq, SFDCAuthConfig);
                if(String.isBlank((String)fieldWithValuesMap.get('refresh_token__c'))){
                    fieldWithValuesMap.put('refresh_token__c', refreshToken);
                }
                if(fieldWithValuesMap.size()>0){
                    String fullName ='Auhtorization_Config.'+System.Label.Salesforce_prod_authorization_config;
                    String label = System.Label.Salesforce_prod_authorization_config;
                    CreateUpdateMetadataUtils.createUpdateMetadata(fullName, label, fieldWithValuesMap);
                }
            }catch(System.CalloutException calloutEx){
                System.debug(calloutEx.getMessage());
            }catch(System.Exception ex){
                System.debug(ex.getMessage());
            }
        }
    }

    private static boolean isValid(Auhtorization_Config__mdt config){
        if(config.expires_in_date_time__c < System.now()) return false;
        return true;
    }

    public static Map<String, Object> refreshOrGetNewToken(HttpRequest httpReq, Auhtorization_Config__mdt SFDCAuthConfig){
        Map<String, Object> fieldsWithValuesMap = new Map<String, Object>();
        Map<String, System.HttpResponse> resultMap = CalloutUtils.makeCallout(httpReq);
        if(resultMap.containsKey('SUCCESS')){
            SalesforceTokenWrapper wrapper = (SalesforceTokenWrapper)JSON.deserialize(resultMap.get('SUCCESS').getBody(), SalesforceTokenWrapper.class);
            if(wrapper!=null){
                fieldsWithValuesMap =  getMetadataFieldWithValuesMap(wrapper, SFDCAuthConfig);
            }
        }else{
            System.debug('ERROR \n '+ resultMap.get('ERROR').getBody());
        }
        return fieldsWithValuesMap;
    }

    private static Map<String, Object> getMetadataFieldWithValuesMap(SalesforceTokenWrapper wrapper, Auhtorization_Config__mdt SFDCAuthConfig){
        System.debug(wrapper);
        Map<String, Object> fieldWithValuesMap = new Map<String, Object>();
        fieldWithValuesMap.put('access_token__c', wrapper.access_token);
        fieldWithValuesMap.put('refresh_token__c', wrapper.refresh_token);
        fieldWithValuesMap.put('instance_url__c', wrapper.instance_url);
        fieldWithValuesMap.put('scope__c', wrapper.scope);
        fieldWithValuesMap.put('expires_in_date_time__c', System.now().addHours(2));
        fieldWithValuesMap.put('client_id__c', SFDCAuthConfig.client_id__c);
        fieldWithValuesMap.put('client_secret__c', SFDCAuthConfig.client_secret__c);
        return fieldWithValuesMap;
    }

}