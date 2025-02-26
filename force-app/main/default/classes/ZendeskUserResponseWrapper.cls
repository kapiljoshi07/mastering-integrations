public class ZendeskUserResponseWrapper{
	public cls_users[] users;
	public cls_next_page next_page;
	public cls_previous_page previous_page;
	public Integer count;	//6
	public class cls_users {
		public String id;	//32711854110225
		public String url;	//https://ramatva.zendesk.com/api/v2/users/32711854110225.json
		public String name;	//Soobin Do
		public String email;	//soobin.do@example.com
		public String time_zone;	//Asia/Kolkata
		public String iana_time_zone;	//Asia/Kolkata
		public String phone;
		public Boolean active;
		public String organization_id;
		public String role;	//end-user
		public String external_id;
	}
	public class cls_next_page {
	}
	public class cls_previous_page {
	}
	public static ZendeskUserResponseWrapper parse(String json){
		return (ZendeskUserResponseWrapper) System.JSON.deserialize(json, ZendeskUserResponseWrapper.class);
	}
}