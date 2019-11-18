public class TwitterFollowerWrapper {
    public cls_users[] users;
    public String next_cursor_str;	
    public String id_str;
    public class cls_users {
        public String id_str;
        public String name;	
        public String screen_name;	
        public String location;
        public String description;
        public Integer followers_count;		
        public String profile_image_url;	
        public String profile_image_url_https;		
    }
}