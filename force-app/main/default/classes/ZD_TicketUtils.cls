public with sharing class ZD_TicketUtils {
    
    public class TicketWrapper{
        public String body;
        public String subject;
        public String priority;
        public String name;
        public String email;
        public Long assignee_id;
        public Long id;
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
        '        "assignee_id": "' + wrapper.assignee_id + '",' +
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

    public static void updateTicket(TicketWrapper wrapper){

        String header = System.label.ZD_username +':'+ System.label.ZD_api_token;
        Blob headerAsBlob = Blob.valueOf(header);
        String requestBody = '{'+
        '   "ticket": {'+
        '        "assignee_id": "'+wrapper.assignee_id+'"'+
        '    }'+
        '}';

        HttpRequest httpReq = CalloutUtils.prepareHttpRequest(System.label.ZD_EndpointURLforUpdateTickets+wrapper.id, 'PUT', requestBody, 'application/json', 'application/json', 'Basic '+EncodingUtil.base64Encode(headerAsBlob));

        Map<String, HttpResponse> statusToResMap = CalloutUtils.makeCallout(httpReq);
        if(statusToResMap.containsKey('SUCCESS')){
            system.debug('✅Success \n'+statusToResMap.get('SUCCESS').getStatusCode());
        }
        else{
            System.debug('❌Error: \n'+statusToResMap.get('ERROR').getBody());
        }
    }
}