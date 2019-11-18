/*
 * @Author : Amit Singh
 * @Date : 25th Feb 2018
 * @Description : A Playground class for Twitter
 * @Name : TwitterController
*/
public with sharing class TwitterController{

    /* Properties */
    public static Boolean isAuthenticated { get; set; }
    public static String tweetContent { get; set; }

    /*
     * @Author : Amit Singh
     * @Date : 25th Feb 2018
     * @Description : To get the temporary oauth_token and oauth_token_secret and then redirect to authorize page 
     * @Param : none
     * @Returntype : PageReference
     * @Name : doAuth
    */
    
   
    
    public static void checkIfAlreadyAuthenticated() {
        List<User> userInfo = [Select Id, Name, Twitter_User_Name__c From User Where Id =: UserInfo.getUserId() ];
        if(userInfo != null && userInfo.size() > 0){
            List<Twitter_Infos__mdt> tokenSecretInfo = twitterSecretTokenInfo(userInfo[0].Twitter_User_Name__c);
            if ( tokenSecretInfo != null && tokenSecretInfo.size() > 0) {
                isAuthenticated = true;
            }
        }
    }
    
    
    public static PageReference doAuth(){
        List<Twitter_Infos__mdt> twitterTokenInfo = twitterTokenInfo();
        System.debug(twitterTokenInfo);
        if(twitterTokenInfo!=null && twitterTokenInfo.size()>0){
            Twitter_Infos__mdt twitterMTD = twitterTokenInfo[0];
            PageReference pareReference = oAuth1OUtility.doFetchOuthNonce(twitterMTD.oauth_callback__c, twitterMTD.oauth_consumer_Secret__c,
                                            twitterMTD.request_token_url__c,'Twitter','https://api.twitter.com/',
                                            twitterMTD.authorize_url__c,twitterMTD.oauth_consumer_key__c);
            pareReference.setRedirect(true);
            System.debug(pareReference);                                
            return pareReference;
        }
        return null;
    }
    
    public static List<Twitter_Infos__mdt> twitterTokenInfo(){
        List<Twitter_Infos__mdt> twitterTokenInfo = [Select Id, MasterLabel, access_token_url__c, 
                                                        DeveloperName,
                                                        authorize_url__c, oauth_callback__c, 
                                                        oauth_consumer_key__c,
                                                        oauth_token__c, oauth_token_secret__c, 
                                                        oauth_consumer_Secret__c,
                                                        request_token_url__c,
                                                        api_endpoint__c
                                                        From Twitter_Infos__mdt Where DeveloperName='Token_Info'];
        return twitterTokenInfo;
    }

    
    /*
     * @Author : Amit Singh
     * @Date : 25th Feb 2018
     * @Description : To Refresh the oauth_token if the Final oauth_token has been expired 
     * @Param : none
     * @Returntype : Map<String,String>
     * @Name : doRefreshAccessToken
    */
    public static PageReference dofetchAccessToken(){
        List<Twitter_Infos__mdt> twitterTokenInfo = twitterTokenInfo();
        if(twitterTokenInfo!=null && twitterTokenInfo.size()>0){
            
            /* Prepare the PageRefernce to Get Redirect to the Right URL */
            PageReference pageRef = new PageReference('/apex/TwitterOperations');
            pageRef.setRedirect(true);
            
            
            Twitter_Infos__mdt twitterMTD = twitterTokenInfo[0];
            Map<String,String> responseMap = oAuth1OUtility.doFetchAccessToken(twitterMTD.oauth_consumer_key__c, 
                                                twitterMTD.access_token_url__c, 
                                                twitterMTD.oauth_consumer_Secret__c);
                                                
            if(responseMap != null && responseMap.size() > 0){
                String outh_token = responseMap.get('oauth_token');
                String outh_token_secret = responseMap.get('oauth_token_secret');
                String user_id = responseMap.get('user_id');
                String user_name = responseMap.get('screen_name');
                
                String fullName = 'Twitter_Infos.'+user_name;
                Map<String, Object> fieldValueMap = new Map<String, Object>();
                fieldValueMap.put('oauth_token__c', outh_token);
                fieldValueMap.put('oauth_token_secret__c', outh_token_secret);
                fieldValueMap.put('user_id__c', user_id);
                fieldValueMap.put('user_name__c', user_name);
                fieldValueMap.put('access_token_url__c', twitterMTD.access_token_url__c);
                fieldValueMap.put('request_token_url__c', twitterMTD.request_token_url__c);
                fieldValueMap.put('authorize_url__c', twitterMTD.authorize_url__c);
                fieldValueMap.put('oauth_callback__c', twitterMTD.oauth_callback__c);
                fieldValueMap.put('oauth_consumer_key__c', twitterMTD.oauth_consumer_key__c);
                fieldValueMap.put('oauth_consumer_Secret__c', twitterMTD.oauth_consumer_Secret__c);
                fieldValueMap.put('api_endpoint__c', twitterMTD.api_endpoint__c);
                
                /* Create/Update the Metadata Record */
                CreateUpdateMetadataUtils.createUpdateMetadata(fullName, user_name, fieldValueMap);
                isAuthenticated = true;
                
                /* call the method and update the User Record with Twitter UserName */
                updateUserRecord(user_name);
                
                return null;
            }
        }
        
        return null;
    }
    
    /*
     * @Author : Amit Singh
     * @Date : 8th APRIL 2019
     * @Description : Update the current User Record with the Twitter UserName
     * @Param : User u
     * @Returntype : void
     * @Name : updateUserRecord
     * throws : none
    */
    @future
    public static void updateUserRecord(String twitterUserName){
        User u = new User(Id = UserInfo.getUserId(), Twitter_User_Name__c = twitterUserName);
        update u;
    }
    
    public static List<Twitter_Infos__mdt> twitterSecretTokenInfo(String twitterUserName){
        List<Twitter_Infos__mdt> twitterTokenInfo = [Select Id, MasterLabel, 
                                                        access_token_url__c, DeveloperName,
                                                        authorize_url__c, oauth_callback__c, 
                                                        oauth_consumer_key__c,
                                                        oauth_token__c, oauth_token_secret__c, 
                                                        oauth_consumer_Secret__c,
                                                        request_token_url__c,
                                                        api_endpoint__c
                                                        From Twitter_Infos__mdt Where 
                                                        DeveloperName =: twitterUserName];
        return twitterTokenInfo;
    } 
    
    /*
     * @Author : Amit Singh
     * @Date : 8th Feb APRIL
     * @Description : Get Logged in User Twitter Time line if Already Authenticated
     * @Param : void
     * @Returntype : void
     * @Name : getTwitterTimeLine
    */
    public static void getTwitterTimeLine(){
        List<User> userInfo = [Select Id, Name, Twitter_User_Name__c From User Where Id =: UserInfo.getUserId() ];
        if(userInfo != null && userInfo.size() > 0){
            List<Twitter_Infos__mdt> tokenSecretInfo = twitterSecretTokenInfo(userInfo[0].Twitter_User_Name__c);
            System.debug(' #### tokenSecretInfo '+tokenSecretInfo);
            if(tokenSecretInfo != null && tokenSecretInfo.size() > 0){
               HttpRequest httpReq = oAuth1OUtility.prepareRequest(tokenSecretInfo[0].api_endpoint__c,
                                                    tokenSecretInfo[0].oauth_consumer_key__c,
                                                    tokenSecretInfo[0].oauth_consumer_Secret__c,
                                                    tokenSecretInfo[0].oauth_token__c,
                                                    tokenSecretInfo[0].oauth_token_secret__c,
                                                     '/1.1/statuses/user_timeline.json', 'GET');
               System.debug(' #### httpReq '+httpReq);
               HttpResponse httpRes = new HttpResponse();
               try{
                   httpRes = (new Http()).send(httpReq);
                   if(httpRes.getStatusCode() == 200){
                       String response = httpRes.getBody();
                       System.debug(' Success Response ' + response);
                       ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, response));
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
    
    public static void postTweet(){
        List<User> userInfo = [Select Id, Name, Twitter_User_Name__c From User Where Id =: UserInfo.getUserId() ];
        if(userInfo != null && userInfo.size() > 0){
            List<Twitter_Infos__mdt> tokenSecretInfo = twitterSecretTokenInfo(userInfo[0].Twitter_User_Name__c);
            System.debug(' #### tokenSecretInfo '+tokenSecretInfo);
            if(tokenSecretInfo != null && tokenSecretInfo.size() > 0){
                HttpRequest httpReq = oAuth1OUtility.prepareRequest(
                                                    tokenSecretInfo[0].api_endpoint__c,
                                                    tokenSecretInfo[0].oauth_consumer_key__c,
                                                    tokenSecretInfo[0].oauth_consumer_Secret__c,
                                                    tokenSecretInfo[0].oauth_token__c,
                                                    tokenSecretInfo[0].oauth_token_secret__c,
                                                     '/1.1/statuses/update.json?status='+EncodingUtil.urlEncode(tweetContent, 'UTF-8'), 
                                                     'POST');
               httpReq.setBody(EncodingUtil.urlEncode(tweetContent, 'UTF-8'));
               HttpResponse httpRes = new HttpResponse();
               try{
                   httpRes = (new Http()).send(httpReq);
                   if(httpRes.getStatusCode() == 200){
                       String response = httpRes.getBody();
                       System.debug(' Success Response ' + response);
                       ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, response));
                   }else{
                       String response = httpRes.getBody();
                       System.debug(' Error Response ' + response);
                       ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, response));
                   }
               }catch(Exception ex){
                   System.debug(' #### Exception Executed '+ex.getStackTraceString());
                   ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getStackTraceString()));
               }
               System.debug(' #### httpReq '+httpReq);
            }
        }
    }
    
}