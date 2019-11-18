public with sharing class TwitterFollowersMap {
    @AuraEnabled(cacheable = true)
    public static List<Twitter_Follower__c> getFollowers() {
        List<Twitter_Follower__c> followers = [ SELECT Id, 
                                               Name, Twitter_Handle__c, 
                                               Location__c, Description__c, followers_count__c, 
                                               Profile__c, Profile_Pic__c FROM Twitter_Follower__c
                                               Where Location__c != null
                                              Limit 100
                                              ];
        return followers;
    }
    
    @AuraEnabled(cacheable = true ) 
    public static List<Twitter_Follower__c> findFollowers(String searchParam, String locationParam) {
        String likeFilter = '\'%'+searchParam+'%\'';
        String locationFilter = '\'%'+locationParam+'%\'';
        String Query = 'SELECT Id, Name, Twitter_Handle__c, Location__c, Description__c, followers_count__c,'+
                       +'Profile__c, Profile_Pic__c FROM Twitter_Follower__c Where Name != null ';
        if ( searchParam != null ) {
            Query += ' AND Name Like ' + likeFilter ;
        }
        if ( locationParam != null ) {
            Query += ' AND Location__c Like ' + locationFilter ;
        }
        Query += ' Order By LastModifiedDate ASC Limit 100';
        List<sObject> objectList = new List<sObject>();   
        objectList = Database.Query(Query);
        return objectList;
    }
}