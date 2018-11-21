/*
*    @description:    This will prompt the user on whatever the value is in the "Prompt Field".
*    @author:         Jade Serrano (jade.serrano@asggroup.com.au)
*    @createddate:    October 24,2018
*/
public without sharing class RecordPromptController {
	@AuraEnabled
    public static String recordPrompt(Id recId, String promptField) {
    	String ret;
    	try{
	    	Schema.SObjectType sobjectType = recId.getSObjectType();
			String sobjectName = sobjectType.getDescribe().getName();
			SObject record = Database.query('SELECT Id, '+promptField+' FROM ' + sobjectName + ' WHERE Id =: recId');
			ret = String.valueOf(record.get(promptField));
		}catch(Exception e){
			System.debug('Exception: '+e);
		}

        return ret;
    }
}