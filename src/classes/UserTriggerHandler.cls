public class UserTriggerHandler {
	public static void updateUserFacultyAndBusinessUnit(Set<Id> userIds){
		System.debug('userIds: '+userIds);

	    List<User> userList =   [SELECT Id,
	                                    Business_Unit__c,
	                                    Faculty_School__c,
	                                    UserRole.Name
	                            FROM    User
	                            WHERE   Id IN: userIds];

	    System.debug('userList: '+userList);

	    for(User u: userList){
	    	String roleName = String.valueOf(u.UserRole.Name);
	    	System.debug('roleName: '+roleName);
	    	if(roleName == null){
	    		u.Business_Unit__c = '';
	            u.Faculty_School__c = '';
	    	}else{
		        List<String> roleLevel = roleName.split('-');
		        System.debug('roleLevel: '+roleLevel);
		        if(roleLevel.size() == 1){
		            System.debug('==1');
		            u.Business_Unit__c = '';
		            u.Faculty_School__c = '';
		        }else if(roleLevel.size() == 2){
		            System.debug('==2');            
		            u.Faculty_School__c = roleLevel[0];
		            u.Business_Unit__c = '';
		        }else if(roleLevel.size() == 3){
		            System.debug('==3');
		            u.Faculty_School__c = roleLevel[0];
		            u.Business_Unit__c = roleLevel[0]+'-'+roleLevel[1];          
		        }
	    	}
	    }

	    System.debug('userList.size(): '+userList.size());
	    if(!userList.isEmpty()){
	        update userList;
	    }
	}
}