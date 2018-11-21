/************************************************************
@Name       : Opportunity_Trigger
@Author     : Charles Gong
@CreateDate : 05/11/2018 
@Description:  
@UsedBy     : 
******************************************************************/
trigger Opportunity_Trigger on Opportunity (before insert,after update,after insert) {
    if (trigger.ISafter && trigger.isinsert){
		Opportunity_TriggerHelper.shareToOwner(trigger.new);
    }
}