/************************************************************
@Name       : Opportunity_Trigger
@Author     : Charles Gong
@CreateDate : 05/11/2018 
@Description:  
@UsedBy     : 
******************************************************************/
public class Opportunity_TriggerHelper {
    public static void shareToOwner(List<Opportunity> newVals) {
        Id researchId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Research').getRecordTypeId();
        List<OpportunityTeamMember> lstOppTeams = new List<OpportunityTeamMember>();
        for (Opportunity o : newVals){
            if (o.RecordTypeId == researchId){
                OpportunityTeamMember otm = new OpportunityTeamMember(
                    TeamMemberRole = 'Opportunity Creator', 
                    OpportunityId  = o.Id,
                    UserId         = o.createdById,
                    OpportunityAccessLevel = 'Read'
                );
                
                lstOppTeams.add(otm);    
            }
        }
        if (!lstOppTeams.isEmpty()) {
//			Statics.inFutureContext = true;
			insert lstOppTeams;			
		}
    }
}