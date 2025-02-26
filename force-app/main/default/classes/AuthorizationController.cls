public with sharing class AuthorizationController {
    
    @AuraEnabled
    public static void getAccessToken(String authCode){
        try {
            System.debug(authCode);
            SalesforceTokenUtils.calloutForToken(authCode);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}