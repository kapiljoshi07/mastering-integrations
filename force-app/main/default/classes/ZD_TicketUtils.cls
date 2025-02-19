public with sharing class ZD_TicketUtils {
    
    public class TicketWrapper{
        public String body;
        public String subject;
        public String priority;
        public String name;
        public String email;
    }

    public static String createTicket(TicketWrapper wrapper){
        HttpRequest httpReq = new HttpRequest();
        String ticketId='';
        
        String header = System.label.ZD_username +':'+ System.label.ZD_api_token;
        Blob headerAsBlob = Blob.valueOf(header);

        String requestBody = '{'+
        '    "ticket": {'+
        '        "subject": "' + wrapper.subject +'",'+
        '        "comment": {'+
        '            "body": "' + wrapper.body +'"' +
        '        },'+
        '        "priority": "' + wrapper.priority + '",' +
        '        "requester": {'+
        '            "locale_id": 8,'+
        '            "name": "'+wrapper.name+'",'+
        '            "email": "'+wrapper.email+'"'+
        '        }'+
        '    }'+
        '}';
        
        httpReq.setBody(requestBody);
        httpReq.setEndpoint(System.label.ZD_POSTEndPointURL);
        httpReq.setMethod('POST');
        httpReq.setHeader('content-type', 'application/json');
        httpReq.setHeader('Accept','application/json');
        httpReq.setHeader('Authorization', 'Basic '+EncodingUtil.base64Encode(headerAsBlob));
        
        Http http = new Http();
        try{
            HttpResponse response = http.send(httpReq);
            if(response.getStatusCode() == 201){
                System.debug('SUCCESS\n'+response.getBody());
                Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                Map<String, Object> ticket = (Map<String,Object>)jsonMap.get('ticket');
                ticketId = String.valueOf(ticket.get('id'));
            }else{
                System.debug('ERROR\n'+response.getBody());
                ticketId = 'A failure in ticket creation on Zendesk';
            }
        }catch(System.CalloutException calloutEx){
            ticketId = 'A system callout exception occured';
        }catch(System.Exception ex){
            ticketId = 'A system exception occured Zendesk';
        }
        return ticketId;
    }
}