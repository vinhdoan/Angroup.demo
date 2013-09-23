using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Anacle.DataFramework;
using LogicLayer;
using System.Data;

namespace Service
{
    public class InboxNotificationService :AnacleServiceBase
    {
        public override void OnExecute()
        {
            LogEvent("Service Started");
            List<OUser> userList = OActivity.GetDistinctUserForActivities();

            foreach (OUser user in userList)
            {
                DataTable dtActivityList = OActivity.GetOutstandingTasksGroupedByObjectTypeAndStatus(user, DateTime.Now, "PendingApproval", "PendingCancellation");
                if (dtActivityList.Rows.Count > 0)
                {
                    OInboxReminder reminder = TablesLogic.tInboxReminder.Create();
                    reminder.UserID = user.ObjectID;

                    // caleb. save the last notification date to the current day and date
                    //user.LastNotificationDate = DateTime.Today;

                    OInboxReminderItem reminderItem = TablesLogic.tInboxReminderItem.Create();

                    // create the first reminder item by default

                    reminderItem.ObjectName = dtActivityList.Rows[0]["ObjectTypeName"].ToString().TranslateObjectType();
                    //test.
                    reminder.InboxReminderItems.Add(reminderItem);


                    foreach (DataRow row in dtActivityList.Rows)
                    {

                        // if it is a different object, create a reminder object
                        if (reminderItem.ObjectName != row["ObjectTypeName"].ToString().TranslateObjectType())
                        {
                            reminderItem = TablesLogic.tInboxReminderItem.Create();
                            reminderItem.ObjectName = row["ObjectTypeName"].ToString().TranslateObjectType();
                            reminder.InboxReminderItems.Add(reminderItem);
                        }

                        OInboxReminderItemState inboxReminderItemState = TablesLogic.tInboxReminderItemState.Create();

                        inboxReminderItemState.StateName = row["ObjectName"].ToString().TranslateWorkflowState();
                        inboxReminderItemState.ObjectNumber = row["TaskNumber"].ToString();
                        inboxReminderItemState.ObjectName = row["TaskName"].ToString();
                        inboxReminderItemState.ItemCount = Convert.ToInt32(row["Count"].ToString());

                        reminderItem.InboxReminderItemStates.Add(inboxReminderItemState);

                    }

                    using (Connection c = new Connection())
                    {
                        reminder.Save();
                        //user.Save();
                        LogEvent("Sending Message");
                        reminder.SendMessage("InboxReminder_Template", user);
                        c.Commit();
                    }
                }

            }
            LogEvent("Service Ended");
        }
    }
}
