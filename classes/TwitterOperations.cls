/*
 * @Author : Amit Singh
 * @Date : 7th Oct 2019
 * @Description : A Playground class for Twitter
 * @Name : TwitterOperations
*/
public with sharing class TwitterOperations {
    
    public static String getTwitterFollowers(String cursor){
        List<User> userIn = [Select Id, Name, Twitter_User_Name__c From User Where Id =: UserInfo.getUserId() ];
        if(userIn != null && userIn.size() > 0){
            List<Twitter_Infos__mdt> tokenSecretInfo = TwitterController.twitterSecretTokenInfo(userIn[0].Twitter_User_Name__c);
            List<Twitter_Endpoints__mdt> endpoints = oAuth1OUtility.getEndpoints();
            String screen_name = userIn.get(0).Twitter_User_Name__c;
            if ( endpoints == null) {
                return null;
            }
            String endPoint = '';
            if( cursor == null) {
                endPoint = '/1.1/followers/list.json?cursor=-1&count=200&screen_name='+screen_name+'&skip_status=true&include_user_entities=false';
            } else {
                endPoint = '/1.1/followers/list.json?cursor='+cursor+'&count=200&screen_name='+screen_name+'&skip_status=true&include_user_entities=false';
            }
            if(tokenSecretInfo != null && tokenSecretInfo.size() > 0){
                HttpRequest httpReq = oAuth1OUtility.prepareRequest(tokenSecretInfo[0].api_endpoint__c,
                                                                    tokenSecretInfo[0].oauth_consumer_key__c,
                                                                    tokenSecretInfo[0].oauth_consumer_Secret__c,
                                                                    tokenSecretInfo[0].oauth_token__c,
                                                                    tokenSecretInfo[0].oauth_token_secret__c,
                                                                    endPoint, 
                                                                    'GET');
                
                HttpResponse httpRes = new HttpResponse();
                try{
                    httpRes = (new Http()).send(httpReq);
                    if(httpRes.getStatusCode() == 200){
                        String response = httpRes.getBody();
                        TwitterFollowerWrapper wrapper = (TwitterFollowerWrapper)JSON.deserialize(response, TwitterFollowerWrapper.class);
                        List<TwitterFollowerWrapper.cls_users> userList = wrapper.users;
                        String next_cursor = wrapper.next_cursor_str;
                        List< Twitter_Follower__c > followers = new List< Twitter_Follower__c >();
                        for( TwitterFollowerWrapper.cls_users user : userList ) {
                            Twitter_Follower__c f = new Twitter_Follower__c ();
                            f.Name = user.name;
                            f.Twitter_Handle__c  = user.screen_name;
                            f.Location__c  = user.location;
                            f.Description__c  = user.description;
                            f.followers_count__c = user.followers_count;
                            f.Profile__c  = user.profile_image_url_https;
                            f.Following__c = true;
                            f.Twitter_Id__c = user.id_str;
                            followers.add(f); 
                        }
                        upsert followers Twitter_Handle__c;
                        
                        return next_cursor;
                    }else{
                        String response = httpRes.getBody();
                        System.debug(' Error Response ' + response);
                        return null;
                    }
                }catch(Exception ex){
                    System.debug(' #### Exception Executed '+ex.getStackTraceString());
                    System.debug(' #### Exception Executed '+ex.getCause());
                    System.debug(' #### Exception Executed '+ex.getLineNumber());
                    System.debug(' #### Exception Executed '+ex.getMessage());
                    return null;
                }
            }
        }
        return null;
    }
    
    @AuraEnabled(cacheable=true)
    public static String  getTwitterTimeline(){
        List<User> userInfo = [Select Id, Name, Twitter_User_Name__c From User Where Id =: UserInfo.getUserId() ];
        List<Twitter_Endpoints__mdt> endpoints = oAuth1OUtility.getEndpoints();
        String timeLine = '';
        if ( endpoints == null) {
            return null;
        } else {
            timeLine = endpoints.get(0).Timeline__c;
        }
        if(userInfo != null && userInfo.size() > 0){
            List<Twitter_Infos__mdt> tokenSecretInfo = TwitterController.twitterSecretTokenInfo(userInfo[0].Twitter_User_Name__c);
            if(tokenSecretInfo != null && tokenSecretInfo.size() > 0){
                HttpRequest httpReq = oAuth1OUtility.prepareRequest(tokenSecretInfo[0].api_endpoint__c,
                                                                    tokenSecretInfo[0].oauth_consumer_key__c,
                                                                    tokenSecretInfo[0].oauth_consumer_Secret__c,
                                                                    tokenSecretInfo[0].oauth_token__c,
                                                                    tokenSecretInfo[0].oauth_token_secret__c,
                                                                    timeLine, 'GET');
                HttpResponse httpRes = new HttpResponse();
                try{
                    httpRes = (new Http()).send(httpReq);
                    if(httpRes.getStatusCode() == 200){
                        String response = httpRes.getBody();
                        
                        return response;
                    }else{
                        String response = httpRes.getBody();
                        return response;
                    }
                }catch(Exception ex){
                    System.debug(' #### Exception Executed '+ex.getStackTraceString());
                    return ex.getStackTraceString();
                }
            }
        }
        return null;
    }
    
    @AuraEnabled
    public static void postTwitterContent(String message){
        List<User> userIn = [Select Id, Name, Twitter_User_Name__c From User Where Id =: UserInfo.getUserId() ];
        if(userIn != null && userIn.size() > 0){
            List<Twitter_Infos__mdt> tokenSecretInfo = TwitterController.twitterSecretTokenInfo(userIn[0].Twitter_User_Name__c);
            if(tokenSecretInfo != null && tokenSecretInfo.size() > 0){
                if ( message == null ) {
                    message = 'Hello There! Good Morning/Eve!! If you are able to see me I am from past - 23rd July 2019.'+
                        	  '#Integration #TwitterAPI @amit_sfdc';
                }
                String encodedMessage = EncodingUtil.URLENCODE(message,'UTF-8').replace('+', '%20');
                HttpRequest httpReq = oAuth1OUtility.prepareRequest(tokenSecretInfo[0].api_endpoint__c,
                                                                    tokenSecretInfo[0].oauth_consumer_key__c,
                                                                    tokenSecretInfo[0].oauth_consumer_Secret__c,
                                                                    tokenSecretInfo[0].oauth_token__c,
                                                                    tokenSecretInfo[0].oauth_token_secret__c,
                                                                    '/1.1/statuses/update.json?status='+encodedMessage, 'POST');
                HttpResponse httpRes = new HttpResponse();
                try{
                    httpRes = (new Http()).send(httpReq);
                    if(httpRes.getStatusCode() == 200){
                        String response = httpRes.getBody();
                    }else{
                        String response = httpRes.getBody();
                        System.debug(' Error Response ' + response);
                    }
                }catch(Exception ex){
                    System.debug(' #### Exception Executed '+ex.getStackTraceString());
                }
            }
        }
    }
}