/************************************************************
@Name       : Opportunity_TriggerTest
@Author     : Charles Gong
@CreateDate : 05/11/2018 
@Description:  
@UsedBy     : 
******************************************************************/
@isTest
public class Opportunity_TriggerHelperTest {
	@isTest
    public static void shareToOwnerTest(){
        Id userId = system.UserInfo.getUserId();
        Id researchId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Research').getRecordTypeId();
        Opportunity o = new Opportunity(
        	recordTypeId = researchId,
            name = 'Opp',
            stageName = 'Closed Won',
            closeDate = Date.today()
        );
        insert o;
        List<OpportunityTeamMember> otm = [Select opportunityId, TeamMemberRole, UserId from OpportunityTeamMember where opportunityId =: o.Id AND UserId=: userId];
        system.assert(otm.size() ==1 );
    }
}