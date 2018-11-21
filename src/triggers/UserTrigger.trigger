/************************************************************
@Name       : User_Trigger
@Author     : Jade
@CreateDate : 05/11/2018 
@Description:  
@UsedBy     : 
******************************************************************/
trigger UserTrigger on User (after insert, after update) {
    Set<Id> userIds = new Set<Id>();

    if(Trigger.isInsert){
    	System.debug('isInsert');
    	for(User u: Trigger.new){
			userIds.add(u.Id);
    	}
	}else if(Trigger.isUpdate){
		System.debug('isUpdate');
    	for(User u: Trigger.new){
	        User oldUser = Trigger.oldMap.get(u.Id);
	        System.debug('oldUser.UserRoleId: '+oldUser.UserRoleId);
	        System.debug('u.UserRoleId: '+u.UserRoleId);
	        if(oldUser.UserRoleId != u.UserRoleId){
	            userIds.add(u.Id);
	        }
	    }
    }

    if(!userIds.isEmpty()){
    	UserTriggerHandler.updateUserFacultyAndBusinessUnit(userIds);
    }   
}