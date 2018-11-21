/************************************************************
@Name       : Event_Trigger Test
@Author     : Charles Gong
@CreateDate : 05/11/2018 
@Description:  
@UsedBy     : 
******************************************************************/
@isTest
public class Event_Trigger_Test {
    @isTest
    public static void testTrigger(){
        Event e = new Event();
        DateTime d = dateTime.now(); 
        e.startDateTime = d;
        e.EndDateTime = d;
        insert e;
        Event e1 = [Select IsReminderSet, ReminderDateTime From Event];
        system.assertEquals(e1.IsReminderSet, True);
        system.assertEquals(e1.ReminderDateTime, d.addMinutes(-15) );
    }
}