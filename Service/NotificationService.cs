using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Anacle.DataFramework;
using LogicLayer;

namespace Service
{
    /// <summary>
    /// Represents a service responsible for sending
    /// workflow notifications to recipients when an object
    /// is running in a workflow process.
    /// </summary>
    public class NotificationService : AnacleServiceBase
    {

        public override void OnExecute()
        {
            base.OnExecute();

            DateTime now  = DateTime.Now;
            List<ONotification> notifications =
                TablesLogic.tNotification.LoadList(
                TablesLogic.tNotification.NextNotificationDateTime < now);

            foreach (ONotification notification in notifications)
            {
                try
                {
                    // Load up the object and test if the expected
                    // field is null. 
                    // 
                    OActivity activity = TablesLogic.tActivity.Load(notification.ActivityID);
                    ONotificationProcess notificationProcess = TablesLogic.tNotificationProcess.Load(notification.NotificationProcessID);
                    ONotificationMilestones milestones = notificationProcess.NotificationMilestones;

                    // 2010.06.30
                    // Kim Foong
                    // Checks if any of the objects are null, if so, we terminate the
                    // notification.
                    //
                    if (activity == null || notificationProcess == null || milestones == null)
                    {
                        using (Connection c = new Connection())
                        {
                            notification.NextNotificationDateTime = null;
                            notification.Save();
                            c.Commit();
                        }
                        continue;
                    }

                    Type type = typeof(TablesLogic).Assembly.GetType("LogicLayer." + activity.ObjectTypeName);
                    LogicLayerPersistentObject obj = PersistentObject.LoadObject(type, activity.AttachedObjectID.Value) as LogicLayerPersistentObject;
                    if (obj == null)
                    {
                        // 2010.06.30
                        // Kim Foong
                        // Terminate the notification.
                        //
                        using (Connection c = new Connection())
                        {
                            notification.NextNotificationDateTime = null;
                            notification.Save();
                            c.Commit();
                        }
                        continue;
                    }

                    int milestoneNumber = notification.NextNotificationMilestone.Value;
                    int notificationLevel = notification.NextNotificationLevel.Value;
                    string expectedField = (string)milestones.DataRow["ExpectedField" + milestoneNumber];

                    object value = DataFrameworkBinder.GetValue(obj, expectedField, false);
                    using (Connection c = new Connection())
                    {
                        if (value == null)
                        {
                            // Now since this value is null, we must send a notification.
                            //
                            // But we need to first find out the list of all the recipients 
                            // configured to receive the notification.
                            //
                            ONotificationHierarchyLevel notificationHierarchyLevel =
                                notificationProcess.NotificationHierarchy.FindNotificationHierarchyLevelByLevel(notificationLevel);

                            StringBuilder email = new StringBuilder();
                            StringBuilder cellphone = new StringBuilder();

                            // Assign users/roles to the task.
                            //
                            StringBuilder emails = new StringBuilder();
                            StringBuilder cellphones = new StringBuilder();
                            if (notificationHierarchyLevel != null)
                            {
                                List<OUser> notifyUsers = new List<OUser>();
                                List<OPosition> notifyPositions = new List<OPosition>();

                                // Here we assigned the users
                                //
                                foreach (OUser user in notificationHierarchyLevel.Users)
                                    notifyUsers.Add(user);

                                // Then we assign the positions.
                                //
                                foreach (OPosition position in notificationHierarchyLevel.Positions)
                                    notifyPositions.Add(position);

                                // Then we assign the positions through the roles.
                                //
                                List<string> roleCodes = new List<string>();
                                foreach (ORole role in notificationHierarchyLevel.Roles)
                                    roleCodes.Add(role.RoleCode);
                                List<OPosition> assignedPositions = OPosition.GetPositionsByRoleCodesAndObject(obj, roleCodes.ToArray());
                                notifyPositions.AddRange(assignedPositions);

                                // Then we get a distinct list of users who will be
                                // the recipients to our notification.
                                //
                                List<OUser> users = TablesLogic.tUser.LoadList(
                                    TablesLogic.tUser.ObjectID.In(notifyUsers) |
                                    TablesLogic.tUser.Positions.ObjectID.In(notifyPositions));

                                // Construct the list of email and SMS recipients.
                                //
                                string emailRecipients = "";
                                string smsRecipients = "";
                                foreach (OUser user in users)
                                {
                                    if (user.UserBase.Email != null && user.UserBase.Email.Trim() != "")
                                        emailRecipients += user.UserBase.Email.Trim() + ";";
                                    if (user.UserBase.Cellphone != null && user.UserBase.Cellphone.Trim() != "")
                                        smsRecipients += user.UserBase.Cellphone.Trim() + ";";
                                }

                                // Generate and the send message to the users.
                                //
                                OMessageTemplate messageTemplate = null;
                                object messageTemplateId = notificationProcess.DataRow["MessageTemplate" + milestoneNumber + "ID"];
                                if (messageTemplateId != null && messageTemplateId != DBNull.Value)
                                    messageTemplate = TablesLogic.tMessageTemplate.Load((Guid)messageTemplateId);
                                if (messageTemplate != null)
                                    messageTemplate.GenerateAndSendMessage(obj, emailRecipients, smsRecipients);

                            }
                        }


                        // Now, determine the next notification date.
                        //
                        // Find out when is the next date/time the next
                        // notification should occur.
                        //
                        DateTime? nextNotificationDateTime = null;
                        int? nextNotificationLevel = null;
                        int? nextNotificationMilestone = null;

                        notificationProcess.GetNextNotificationDateTime(obj, notification.NextNotificationDateTime,
                            ref nextNotificationDateTime, ref nextNotificationMilestone, ref nextNotificationLevel);

                        notification.NextNotificationDateTime = nextNotificationDateTime;
                        notification.NextNotificationLevel = nextNotificationLevel;
                        notification.NextNotificationMilestone = nextNotificationMilestone;
                        notification.Save();
                        c.Commit();
                    }
                }
                catch (Exception ex)
                {
                    LogEvent("An error occured while performing notification ObjectID = '" + notification.ObjectID + "' " + ex.Message + "\n" + ex.StackTrace);
                }
            }
        }
    }
}
