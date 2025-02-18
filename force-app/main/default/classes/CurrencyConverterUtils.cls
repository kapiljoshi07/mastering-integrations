public with sharing class CurrencyConverterUtils {
    
    @InvocableMethod(label='convertCurrency')
    public static List<Double> convertCurrency(List<CurrencyConverterWrapper> requestObjectList){

        CurrencyConverterWrapper requestObject = requestObjectList[0];
        String fromCode = requestObject.fromCode;
        String toCode = requestObject.toCode;
        Double amount = requestObject.amount;
        List<Double> amountList = new List<Double>();

        System.debug('From Code: '+ fromCode + '\nTo Code:' + toCode + '\nAmount: ' +amount);

        //GET https://v6.exchangerate-api.com/v6/YOUR-API-KEY/latest/USD
        String currencyAPIEndpointURL = System.label.EXC_endpointURL+System.label.EXC_api_key+'/latest/'+fromCode;

        HttpRequest httpReq = new HttpRequest();
        httpReq.setMethod('GET');
        httpReq.setEndpoint(currencyAPIEndpointURL);
        httpReq.setHeader('Content-Type', 'application/JSON');
        httpReq.setHeader('Accept', 'application/JSON');

        Http http = new Http();

        try{
            HttpResponse httpRes = http.send(httpReq);

            String responseBody = httpRes.getBody();
            Integer statusCode = httpRes.getStatusCode();
            String status = httpRes.getStatus();
            System.debug('Response body - '+responseBody);
            System.debug('Status - '+status);
            System.debug('statusCode - '+statusCode);

            Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
            Map<String, Object> conversionRate = (Map<String, Object>)jsonMap.get('conversion_rates');
            Object toCodeConversionRateObject = conversionRate.get(toCode);
            Double toCodeConversionRate = (Double)toCodeConversionRateObject;
            System.debug(toCodeConversionRate);

            
            amountList.add(Double.valueOf(amount * toCodeConversionRate));
            

        }catch(System.CalloutException calloutEx){
            System.debug('CallException encountered');
            System.debug(calloutEx.getMessage());
        }catch(System.Exception ex){
            System.debug('Exception encountered');
            System.debug(ex.getMessage());
        }
        
        return amountList;
    }

    
}