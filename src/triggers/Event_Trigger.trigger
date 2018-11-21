/************************************************************
@Name       : Event_Trigger
@Author     : Charles Gong
@CreateDate : 05/11/2018 
@Description:  
@UsedBy     : 
******************************************************************/
trigger Event_Trigger on Event (before insert) {
    // Currently there's a bug in SF lightning global quick action layout with set reminder for Event
    // This component is to auto set reminder for the event created from global quick action
    if (trigger.isinsert && trigger.isbefore){
        for (Event e:trigger.new){
            if (e.ReminderDateTime == null){
                e.IsReminderSet = true;
                e.ReminderDateTime = e.StartDateTime.addMinutes(-15);
            }
        }
    }
}