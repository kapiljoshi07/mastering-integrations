public with sharing class CalloutUtils {
    
    public static HttpRequest prepareHttpRequest(String endpoint, String method, String body, String contentType, String accept, String auth){
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint(endpoint);
        httpReq.setMethod(method);
        if(!String.isBlank(body)){
            httpReq.setBody(body);
        }
        if(!String.isBlank(contentType)){
            httpReq.setHeader('content-type', contentType);
        }
        if(!String.isBlank(auth)){
            httpReq.setHeader('authorization', auth);
        }
        httpReq.setHeader('accept', accept);
        return httpReq;
    }

    public static Map<String,System.HttpResponse> makeCallout(System.HttpRequest req){
        Map<String, System.HttpResponse> resultBodyMap = new Map<String, System.HttpResponse>();
        Http http = new Http();
        System.HttpResponse res = http.send(req);
        if(res.getStatusCode()==201 || res.getStatusCode()==200){
            resultBodyMap.put('SUCCESS', res);
        }else{
            resultBodyMap.put('ERROR', res);
        }
        return resultBodyMap;
    }

}