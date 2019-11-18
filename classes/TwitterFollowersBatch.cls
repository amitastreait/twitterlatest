global with sharing class TwitterFollowersBatch implements Database.Batchable<sObject>, 
						  Database.Stateful, 
						  Database.AllowsCallouts {
    global string cursor;
    global String Query = 'Select Id, MasterLabel From Twitter_Endpoints__mdt Limit 1';
    global TwitterFollowersBatch(String cursor, String Query){
		this.cursor = cursor;
        if ( Query != null) {
            this.Query = Query;
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
		String cur = TwitterOperations.getTwitterFollowers(cursor);
        this.cursor = cur;
    }
    
    global void finish(Database.BatchableContext BC){
        if ( cursor != null && cursor != '0') {
            Database.executeBatch( new TwitterFollowersBatch(cursor, null ), 200);
        }
    }
}