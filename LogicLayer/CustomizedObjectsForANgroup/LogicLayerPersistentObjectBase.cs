//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Collections;
using System.Collections.ObjectModel;
using System.Collections.Generic;
using System.Text;
using System.Reflection;
using System.Workflow.Activities;
using System.Workflow.ComponentModel;
using System.Workflow.Runtime;

using Anacle.DataFramework;
using Anacle.WorkflowFramework;
using System.Data;
namespace LogicLayer
{
   
    public partial class LogicLayerPersistentObjectBase : PersistentObject, IWorkflowPersistentObject
    {

        public void SendEmailToLowerLevelApprovers(string messageTemplateCode)
        {
            SendEmailToLowerLevelApprovers(messageTemplateCode, "Approve");

            #region commented out
            /**********
            if (this.CurrentActivity != null)
            {
                ArrayList lastSubmitDate = Query.Select(TablesLogic.tActivityHistory.ModifiedDateTime.Max())
                                                   .Where(TablesLogic.tActivityHistory.AttachedObjectID == this.ObjectID &
                                                          TablesLogic.tActivityHistory.TriggeringEventName == "SubmitForApproval");
                if (lastSubmitDate.Count > 0)
                {
                    List<OActivityHistory> ahs = TablesLogic.tActivityHistory.LoadList(
                                            TablesLogic.tActivityHistory.AttachedObjectID == this.CurrentActivity.AttachedObjectID &
                                            TablesLogic.tActivityHistory.ModifiedDateTime > Convert.ToDateTime(lastSubmitDate[0]) &
                                            TablesLogic.tActivityHistory.TriggeringEventName == "Approve", TablesLogic.tActivityHistory.CurrentApprovalLevel.Desc);

                    OMessageTemplate messageTemplate = TablesLogic.tMessageTemplate.Load(
                                                        TablesLogic.tMessageTemplate.MessageTemplateCode == messageTemplateCode);

                    if (messageTemplate != null)
                    {
                        string emailRecipients = "";
                        foreach (OActivityHistory ah in ahs)
                        {
                            if (ah.ApprovedByUserID != null)
                            {
                                OUser user = TablesLogic.tUser.Load(ah.ApprovedByUserID.Value);
                                if (user != null)
                                {
                                    // 2010.05.21
                                    // Kim Foong
                                    // Modified to check the e-mail addresses to ensure they are
                                    // not null, because migrated data can sometimes be null.
                                    //
                                    if (user.UserBase.Email != null && user.UserBase.Email.Trim() != "")
                                        emailRecipients += user.UserBase.Email.Trim() + ";";
                                }
                            }
                        }


                        //     Generate and the send message to the users.
                        messageTemplate.GenerateAndSendMessage(this, emailRecipients, "");
                    }
                }


                
                OMessageTemplate messageTemplate = TablesLogic.tMessageTemplate.Load(
                                                 TablesLogic.tMessageTemplate.MessageTemplateCode == messageTemplateCode);

                if (messageTemplate != null)
                {
                    List<OActivityHistory> ahs = TablesLogic.tActivityHistory.LoadList(
                        TablesLogic.tActivityHistory.AttachedObjectID == this.CurrentActivity.AttachedObjectID &
                        TablesLogic.tActivityHistory.TriggeringEventName.In("SubmitForApproval", "Approve"),
                        TablesLogic.tActivityHistory.ModifiedDateTime.Desc);

                    string emailRecipients = "";
                    foreach (OActivityHistory ah in ahs)
                    {
                        if (ah.ApprovedByUserID != null)
                        {
                            OUser user = TablesLogic.tUser.Load(ah.ApprovedByUserID.Value);
                            if (user != null)
                            {
                                if (user.UserBase.Email != null && user.UserBase.Email.Trim() != "")
                                    emailRecipients += user.UserBase.Email.Trim() + ";";
                            }
                        }

                        if (ah.TriggeringEventName != "Approve")
                            break;
                    }

                    //     Generate and the send message to the users.
                    messageTemplate.GenerateAndSendMessage(this, emailRecipients, "");
                    
                }
            }
             **************/
            #endregion
        }

        #region commented out
        /************
        public void SendEmailToLowerLevelApprovers(string messageTemplateCode, string triggeringEventName)
        {
            if (this.CurrentActivity != null)
            {
                ArrayList lastSubmitDate = Query.Select(TablesLogic.tActivityHistory.ModifiedDateTime.Max())
                                                   .Where(TablesLogic.tActivityHistory.AttachedObjectID == this.ObjectID &
                                                          TablesLogic.tActivityHistory.TriggeringEventName == triggeringEventName);
                if (lastSubmitDate.Count > 0)
                {
                    List<OActivityHistory> ahs = TablesLogic.tActivityHistory.LoadList(
                                            TablesLogic.tActivityHistory.AttachedObjectID == this.CurrentActivity.AttachedObjectID &
                                            TablesLogic.tActivityHistory.ModifiedDateTime > Convert.ToDateTime(lastSubmitDate[0]) &
                                            TablesLogic.tActivityHistory.TriggeringEventName == "Approve", TablesLogic.tActivityHistory.CurrentApprovalLevel.Desc);

                    OMessageTemplate messageTemplate = TablesLogic.tMessageTemplate.Load(
                                                        TablesLogic.tMessageTemplate.MessageTemplateCode == messageTemplateCode);

                    if (messageTemplate != null)
                    {
                        string emailRecipients = "";
                        foreach (OActivityHistory ah in ahs)
                        {
                            if (ah.ApprovedByUserID != null)
                            {
                                OUser user = TablesLogic.tUser.Load(ah.ApprovedByUserID.Value);
                                if (user != null)
                                {
                                    // 2010.05.21
                                    // Kim Foong
                                    // Modified to check the e-mail addresses to ensure they are
                                    // not null, because migrated data can sometimes be null.
                                    //
                                    if (user.UserBase.Email != null && user.UserBase.Email.Trim() != "")
                                        emailRecipients += user.UserBase.Email.Trim() + ";";
                                }
                            }
                        }


                        //     Generate and the send message to the users.
                        messageTemplate.GenerateAndSendMessage(this, emailRecipients, "");
                    }
                }

            }
        }
         ******/
        #endregion


        protected override void PostSaving()
        {
            base.PostSaving();

            // Auto-generates the running number if it has not yet
            // been generated before, and if this object has implemented
            // the IAutoGenerateRunningNumber interface.
            //
            if (this.ObjectNumber == null || this.ObjectNumber.Trim() == "")
            {
                if (this is IAutoGenerateRunningNumber)
                {
                    ORunningNumberGenerator.GenerateNextRunningNumber(DateTime.Now, this);
                }
            }

            if (CurrentActivity != null)
            {
                CurrentActivity.TaskName = ObjectName;
                CurrentActivity.TaskNumber = ObjectNumber;
                CurrentActivity.TaskAmount = this.TaskAmount;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="messageTemplateCode"></param>
        /// <param name="triggeringEventName"></param>
        public void SendEmailToLowerLevelApprovers(string messageTemplateCode, string triggeringEventName)
        {
            if (this.CurrentActivity != null)
            {
                OMessageTemplate messageTemplate = TablesLogic.tMessageTemplate.Load(
                                                  TablesLogic.tMessageTemplate.MessageTemplateCode == messageTemplateCode);

                if (messageTemplate != null)
                {
                    List<OActivityHistory> ahs = TablesLogic.tActivityHistory.LoadList(
                        TablesLogic.tActivityHistory.AttachedObjectID == this.CurrentActivity.AttachedObjectID &
                        (TablesLogic.tActivityHistory.TriggeringEventName.Like("SubmitForApproval%") |
                        TablesLogic.tActivityHistory.TriggeringEventName.Like("Approve%")),
                        TablesLogic.tActivityHistory.ModifiedDateTime.Desc);

                    OActivityHistory requestor = ahs.FindLast((a) => a.TriggeringEventName.StartsWith("SubmitForApproval"));
                    List<OActivityHistory> AllApprovers = ahs.FindAll((a) => a.TriggeringEventName.StartsWith("Approve"));

                    // Get latest round approvers only, after the latest re-submit
                    OActivityHistory latestSubmitter = ahs.Find((a) => a.TriggeringEventName.StartsWith("SubmitForApproval"));
                    List<OActivityHistory> approvers = ahs.FindAll((a) => a.TriggeringEventName.StartsWith("Approve")
                                                                         && a.ModifiedDateTime >= latestSubmitter.ModifiedDateTime);

                    Hashtable emails = new Hashtable();
                    string emailRecipients = "";
                    string emailCCRecipients = "";

                    // Send email to requestor to notify that this task
                    // has been approved.
                    if (requestor != null &&
                        requestor.ApprovedByUserID != null)
                    {
                        // If we've already sent an email for the approval level
                        // before, don't re-send again.
                        //
                        OUser user = requestor.ApprovedByUser;
                        if (user.UserBase.Email != null && user.UserBase.Email.Trim() != "" &&
                            emails[user.UserBase.Email.Trim()] == null)
                        {
                            emails[user.UserBase.Email.Trim()] = 1;
                            emailRecipients += user.UserBase.Email.Trim() + ";";
                        }

                        // CC e-mail to cc users.
                        //
                        foreach (OUser ccUser in requestor.CarbonCopyUsers)
                        {
                            if (ccUser.UserBase.Email != null && 
                                ccUser.UserBase.Email.Trim() != "" && 
                                emails[ccUser.UserBase.Email.Trim()] == null)
                            {
                                emails[ccUser.UserBase.Email.Trim()] = 1;
                                emailCCRecipients += ccUser.UserBase.Email.Trim() + ";";
                            }
                        }
                    }

                    // CC approvers below.
                    //
                    foreach (OActivityHistory a in approvers)
                    {
                        if (a.ApprovedByUserID != null)
                        {
                            OUser user = a.ApprovedByUser;
                            if (user.UserBase.Email != null && user.UserBase.Email.Trim() != "" &&
                                emails[user.UserBase.Email.Trim()] == null)
                            {
                                emails[user.UserBase.Email.Trim()] = 1;
                                emailCCRecipients += user.UserBase.Email.Trim() + ";";
                            }
                        }

                        // CC e-mail to cc users.
                        //
                        foreach (OUser ccUser in a.CarbonCopyUsers)
                        {
                            if (ccUser.UserBase.Email != null && ccUser.UserBase.Email.Trim() != "" && emails[ccUser.UserBase.Email.Trim()] == null)
                            {
                                emails[ccUser.UserBase.Email.Trim()] = 1;
                                emailCCRecipients += ccUser.UserBase.Email.Trim() + ";";
                            }
                        }
                    }

                    // Send e-mail to the cc-users at the current level.
                    //
                    foreach (OUser user in this.CurrentActivity.CarbonCopyUsers)
                        if (user.UserBase.Email != null && user.UserBase.Email.Trim() != "" && emails[user.UserBase.Email.Trim()] == null)
                        {
                            emails[user.UserBase.Email.Trim()] = 1;
                            emailCCRecipients += user.UserBase.Email.Trim() + ";";
                        }

                    // Generate and the send message to the users.
                    messageTemplate.GenerateAndSendMessage(this, emailRecipients, emailCCRecipients, "");

                }
            }
        }

        ///// <summary>
        ///// 
        ///// </summary>
        ///// <param name="messageTemplateCode"></param>
        ///// <param name="triggeringEventName"></param>
        //public void SendEmailToSupporters(string messageTemplateCode, EnumSupportStatus supportStatus)
        //{
        //    if (this.CurrentActivity != null)
        //    {
        //        OMessageTemplate messageTemplate = TablesLogic.tMessageTemplate.Load(
        //                                          TablesLogic.tMessageTemplate.MessageTemplateCode == messageTemplateCode);

        //        if (messageTemplate != null)
        //        {
        //            ORequestForQuotation rfq = TablesLogic.tRequestForQuotation.Load(this.CurrentActivity.AttachedObjectID);

        //            string emailRecipients = "";
        //            string emailCCRecipients = "";

        //            if (supportStatus == EnumSupportStatus.Pending)
        //            {
        //                if (rfq.ListOfSupporters().Count == 0)
        //                    return;
        //                else
        //                {
        //                    // Email all supporters that they have a pending task to support
        //                    foreach (OUser supporter in rfq.ListOfSupporters())
        //                    {
        //                        emailRecipients += supporter.UserBase.Email + ";";
        //                    }
        //                }
        //            }
        //            else
        //            {
        //                OSupporter supporter = rfq.Supporters.Find(lf => lf.IsApproved == (int)EnumSupportStatus.Rejected);
        //                if (supporter == null)
        //                    return;
        //                emailRecipients = rfq.Requestor.UserBase.Email;
        //            }

        //            // Generate and the send message to the users.
        //            messageTemplate.GenerateAndSendMessage(this, emailRecipients, emailCCRecipients, "");
        //        }
        //    }
        //}

        /// <summary>
        /// Curent Logged-on user name.
        /// </summary>
        public string CurrentLoggedOnUserName
        {
            get
            {
                return Workflow.CurrentUser.ObjectName;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        public string AssignedUserPositionsWithUserNames
        {
            get
            {
                if (CurrentActivity == null)
                    return null;
                string userNames = "";
                if (CurrentActivity.Positions.Count > 0)
                {

                    foreach (OPosition position in CurrentActivity.Positions)
                        userNames += (userNames == "" ? "" : "; ") + position.PositionNameWithUserNames;
                }
                return userNames;
            }
        }

        /// <summary>
        /// Assigned usernames or position with usernames.
        /// </summary>
        public string AssignedUserNamesOrPositionUserNames
        {
            get
            {
                if (CurrentActivity == null)
                    return null;
                if (CurrentActivity.Users.Count > 0)
                    return AssignedUserNames;
                else if (CurrentActivity.Positions.Count > 0)
                    return AssignedUserPositionsWithUserNames;
                else
                    return "";
            }
        }

       
        /// <summary>
        /// Sends an e-mail or SMS message to the
        /// specified recipients based on the specified 
        /// message template.
        /// <para></para>
        /// Also carbon-copies the notification to another
        /// set of users.
        /// <para></para>
        /// It achieves this by calling the 
        /// OMessageTemplate.GenerateAndSendMessage method.
        /// Application developers can all either method,
        /// but this method is exposed to the SendMessage 
        /// workflow activity.
        /// </summary>
        protected void NotifyAssignedRecipient(LogicLayerPersistentObjectBase logiclayerPersistentObject, List<OUser> carbonCopyUsers)
        {
            if (logiclayerPersistentObject == null)
                return;
            if (logiclayerPersistentObject.CurrentActivity == null)
                return;

            OMessageTemplate messageTemplate =
                TablesLogic.tMessageTemplate.Load(
                TablesLogic.tMessageTemplate.WhereUsed == MessageTemplateUsage.NotifyAssignedWorkflowRecipients &
                TablesLogic.tMessageTemplate.ObjectTypeName == logiclayerPersistentObject.GetType().BaseType.Name &
                TablesLogic.tMessageTemplate.StateName == logiclayerPersistentObject.CurrentActivity.ObjectName);

            // Gets a list of users assigned to the workflow task,
            // then compose a list of email recipients and sms recipients.
            //
            List<OUser> users = TablesLogic.tUser.LoadList(
                TablesLogic.tUser.ObjectID.In(logiclayerPersistentObject.CurrentActivity.Users) |
                TablesLogic.tUser.Positions.ObjectID.In(logiclayerPersistentObject.CurrentActivity.Positions) &
                !TablesLogic.tUser.ObjectID.In(logiclayerPersistentObject.CurrentActivity.ApprovedUsers));

            if (messageTemplate != null)
            {
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

                // Generate the carbon copy message to the cc users
                //
                string ccemailRecipients = "";
                foreach (OUser carbonCopyUser in carbonCopyUsers)
                {
                    if (users.Find(u => u.ObjectID == carbonCopyUser.ObjectID) == null)
                        if (carbonCopyUser.UserBase.Email != null && carbonCopyUser.UserBase.Email.Trim() != "")
                            ccemailRecipients += carbonCopyUser.UserBase.Email.Trim() + ";";
                }

                // Generate and the send message to the users.
                //
                messageTemplate.GenerateAndSendMessage(this, emailRecipients, ccemailRecipients, smsRecipients);
            }
        }


        /// <summary>
        /// Get ApprovalHierarchy for document template (WJPrintOut)
        /// </summary>
        public List<Approvers> ApproverLists
        {
            get
            {
                List<Approvers> approvers = new List<Approvers>();
                string currentStatus = this.CurrentActivity.CurrentStateName;
                if (currentStatus.Is("Awarded", "Close", "Approved", "Committed"))
                {
                    //ArrayList approvalEvents = TablesLogic.tApprovalProcessLimit.SelectDistinct
                    //    (TablesLogic.tApprovalProcessLimit.ApprovalEvent)
                    //    .Where
                    //    (TablesLogic.tApprovalProcessLimit.ApprovalEvent != null &
                    //    TablesLogic.tApprovalProcessLimit.ApprovalEvent != "" &
                    //    TablesLogic.tApprovalProcessLimit.IsDeleted == 0);
                    
                    int? previousLevel = (int)TablesLogic.tActivityHistory.SelectTop
                            (1, TablesLogic.tActivityHistory.PreviousApprovalLevel)
                            .Where
                            (TablesLogic.tActivityHistory.AttachedObjectID == this.ObjectID &
                            (TablesLogic.tActivityHistory.TriggeringEventName.Like("Approve%")))
                            .OrderBy
                            (TablesLogic.tActivityHistory.ModifiedDateTime.Desc);

                    approvers = GetPreviousApproversByLevel(previousLevel);
                    
                }
                else if (currentStatus.StartsWith("PendingApproval"))
                {
                    // Add the previous approvers
                    //
                    approvers.AddRange(GetPreviousApproversByLevel(this.CurrentActivity.CurrentApprovalLevel));

                    // Add the current approvers
                    //
                    if (this.CurrentActivity.CurrentApprovalLevel != null)
                    {
                        OApprovalHierarchyLevel approvalCurrentLevel = this.CurrentActivity.ApprovalProcess.ApprovalHierarchy.FindApprovalHierarchyLevelByLevel((int)this.CurrentActivity.CurrentApprovalLevel);
                        approvalCurrentLevel.CopyPositionsToPositionsToBeAssigned();
                        approvalCurrentLevel.CopyUsersToUsersToBeAssigned();

                        List<OUser> users = OUser.GetUsersByPositions(approvalCurrentLevel.PositionsToBeAssigned);
                        users.AddRange(approvalCurrentLevel.UsersToBeAssigned);

                        if (approvalCurrentLevel != null)
                        {
                            Approvers app = new Approvers();
                            app.ApproverName = GetAssignedApprovers(users);
                            app.ApprovalLevel = approvalCurrentLevel.ApprovalLevel;
                            approvers.Add(app);
                        }
                    }

                    // Add the next approvers
                    //
                    List<OApprovalHierarchyLevel> approvalHierarchyLevels = new List<OApprovalHierarchyLevel>();
                    int? nextApprovalLevel = 0;

                    int approvalResult =
                        this.CurrentActivity.ApprovalProcess.GetApprovalHierarchyLevels(
                        (LogicLayerPersistentObject)this, approvalHierarchyLevels,
                        out nextApprovalLevel);

                    foreach (OApprovalHierarchyLevel approvalHierarchLevel in approvalHierarchyLevels)
                    {
                        approvalHierarchLevel.CopyPositionsToPositionsToBeAssigned();
                        Approvers app = new Approvers();
                        app.ApprovalLevel = approvalHierarchLevel.ApprovalLevel;
                        app.ApproverName = GetAssignedApprovers(OUser.GetUsersByPositions(approvalHierarchLevel.PositionsToBeAssigned));
                        approvers.Add(app);
                    }
                }
                else
                {

                    //ORequestForQuotation rfq = TablesLogic.tRequestForQuotation.Load(this.ObjectID);
                    List<OApprovalProcess> listApprovals = OApprovalProcess.GetApprovalProcesses((LogicLayerPersistentObject)this);

                    if (listApprovals.Count > 0)
                    {
                        List<OApprovalHierarchyLevel> approvalHierarchyLevels = new List<OApprovalHierarchyLevel>();
                        int? nextApprovalLevel = 0;

                        int approvalResult =
                            listApprovals[0].GetApprovalHierarchyLevels(
                            (LogicLayerPersistentObject)this, approvalHierarchyLevels,
                            out nextApprovalLevel);
                        
                        // if the mofe of forwading is skipping, need to get the previous approvals if the rfq was rejected before.
                        //
                        if (listApprovals[0].ModeOfForwarding == ApprovalModeOfForwarding.HierarchicalWithLastRejectedSkipping
                            && this.CurrentActivity != null && this.CurrentActivity.LastApprovalLevel != null && this.CurrentActivity.LastApprovalLevel - 1 > 0)
                            approvers = ApproversList(CurrentActivity.LastApprovalLevel.Value - 1);

                        if (listApprovals[0].ModeOfForwarding != ApprovalModeOfForwarding.Direct && approvalHierarchyLevels.Count > 0)
                        {
                            foreach (OApprovalHierarchyLevel level in approvalHierarchyLevels)
                            {
                                Approvers app = new Approvers();
                                app.ApprovalLevel = level.ApprovalLevel;
                                app.ApproverName = AssignedApproverNames(level, listApprovals);
                                approvers.Add(app);
                            }
                        }

                    }
                }
                return approvers;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="level"></param>
        /// <returns></returns>
        private List<Approvers> GetPreviousApproversByLevel(int? level)
        {
            List<Approvers> approvers = new List<Approvers>();

            TActivityHistory actHistory = TablesLogic.tActivityHistory;
            TActivityHistory activityHistory = new TActivityHistory();
            DataTable dt = actHistory.Select
                            (actHistory.PreviousApprovalLevel,
                            actHistory.CreatedDateTime,
                            actHistory.CreatedUser,
                            actHistory.TriggeringEventName)
                            .Where
                            ((actHistory.PreviousApprovalLevel <= level |
                            actHistory.PreviousApprovalLevel == null) &
                            actHistory.AttachedObjectID == this.ObjectID &
                            (actHistory.TriggeringEventName.Like("Approve%")) &
                            actHistory.CreatedDateTime.In
                            (activityHistory.Select
                            (activityHistory.CreatedDateTime.Max().As("CreatedDateTime"))
                            .Where
                            (
                            (activityHistory.PreviousApprovalLevel == actHistory.PreviousApprovalLevel | actHistory.PreviousApprovalLevel == null) &
                            (activityHistory.TriggeringEventName.Like("Approve%")) &
                            activityHistory.AttachedObjectID == this.ObjectID)
                            .GroupBy(activityHistory.PreviousApprovalLevel, activityHistory.CreatedUser)))
                            .OrderBy(actHistory.PreviousApprovalLevel.Asc);
            
            foreach (DataRow dr in dt.Rows)
            {
                Approvers app = new Approvers();
                app.ApproverName = dr["CreatedUser"].ToString();
                app.ApprovalDateTime = Convert.ToDateTime(dr["CreatedDateTime"]);

                if (dr["TriggeringEventName"].ToString().Is("Approve"))
                    app.ApprovalStatus = Resources.Strings.TriggeringEventName_Approve;
                else if (dr["TriggeringEventName"].ToString().Is("Reject"))
                    app.ApprovalStatus = Resources.Strings.TriggeringEventName_Reject;
                else if (dr["TriggeringEventName"].ToString().Is("Approve_Supporter"))
                    app.ApprovalStatus = Resources.Strings.TriggeringEventName_Approve_Supporter;
                else
                    app.ApprovalStatus = dr["TriggeringEventName"].ToString();
                if (dr["PreviousApprovalLevel"] != DBNull.Value)
                    app.ApprovalLevel = Convert.ToInt16(dr["PreviousApprovalLevel"]);
                approvers.Add(app);
            }
            return approvers;

        }


        /// <summary>
        /// This method is to get the latest approvers that have approved the rfq for each level and before the current approval level
        /// </summary>
        /// <param name="level"></param>
        /// <returns></returns>
        private List<Approvers> ApproversList(int level)
        {
            List<Approvers> approvers = new List<Approvers>();
            DataTable dt = TablesLogic.tActivityHistory.Select(TablesLogic.tActivityHistory.PreviousApprovalLevel.As("Level"),
                                                                      TablesLogic.tActivityHistory.CreatedDateTime.Max().As("CreatedDateTime"))
                                                              .Where(TablesLogic.tActivityHistory.AttachedObjectID == this.ObjectID &
                                                                     TablesLogic.tActivityHistory.TriggeringEventName == "Approve" &
                                                                     TablesLogic.tActivityHistory.PreviousApprovalLevel <= level)
                                                              .GroupBy(TablesLogic.tActivityHistory.PreviousApprovalLevel)
                                                              .OrderBy(TablesLogic.tActivityHistory.PreviousApprovalLevel.Asc);
            foreach (DataRow row in dt.Rows)
            {

                OActivityHistory ah = TablesLogic.tActivityHistory.Load(
                                        TablesLogic.tActivityHistory.PreviousApprovalLevel == Convert.ToInt16(row["Level"]) &
                                        TablesLogic.tActivityHistory.CreatedDateTime == Convert.ToDateTime(row["CreatedDateTime"]) &
                                        TablesLogic.tActivityHistory.AttachedObjectID == this.ObjectID &
                                        TablesLogic.tActivityHistory.TriggeringEventName == "Approve");
                if (ah != null)
                {
                    Approvers app = new Approvers();
                    app.ApproverName = ah.CreatedUser;
                    app.ApprovalDateTime = ah.CreatedDateTime;
                    if (ah.TriggeringEventName.Is("Approve"))
                        app.ApprovalStatus = Resources.Strings.TriggeringEventName_Approve;
                    else if (ah.TriggeringEventName.Is("Reject"))
                        app.ApprovalStatus = Resources.Strings.TriggeringEventName_Reject;
                    else if (ah.TriggeringEventName.Is("Approve_Supporter"))
                        app.ApprovalStatus = Resources.Strings.TriggeringEventName_Approve_Supporter;
                    else
                        app.ApprovalStatus = ah.TriggeringEventName;
                    app.ApprovalLevel = ah.PreviousApprovalLevel;
                    approvers.Add(app);
                }

            }
            return approvers;
        }

        /// <summary>
        /// This method to get Appover Names whether approval hierarchy is by User or Position or Role
        /// This method is being used for the approvallist method above
        /// </summary>
        /// <param name="level"></param>
        /// <param name="listApprovals"></param>
        /// <returns></returns>
        private string AssignedApproverNames(OApprovalHierarchyLevel level, List<OApprovalProcess> listApprovals)
        {
            string name = "";
            if (level.Users.Count > 0)
            {
                name = level.UserNames;
            }
            else if (level.Positions.Count > 0)
            {
                ArrayList poID = new ArrayList();
                foreach (OPosition po in level.Positions)
                    poID.Add(po.ObjectID);

                List<OUser> users = TablesLogic.tUser.LoadList(
                                        TablesLogic.tUser.Positions.ObjectID.In(poID));
                if (users.Count > 0)
                {
                    string userNames = "";
                    foreach (OUser user in users)
                        userNames += (userNames == "" ? "" : ", ") + user.ObjectName;

                    name = userNames;
                }
            }
            else if (level.Roles.Count > 0)
            {
                ArrayList roleID = new ArrayList();
                foreach (ORole role in level.Roles)
                    roleID.Add(role.ObjectID);

                List<OUser> users = TablesLogic.tUser.LoadList(
                                    TablesLogic.tUser.IsDeleted == 0 &
                                    TablesLogic.tUser.Positions.RoleID.In(roleID) &
                                    ((ExpressionDataString)listApprovals[0].Location.HierarchyPath).Like(TablesLogic.tUser.Positions.LocationAccess.HierarchyPath + "%"));
                ;

                if (users.Count > 0)
                {
                    string userNames = "";
                    foreach (OUser user in users)
                        userNames += (userNames == "" ? "" : ", ") + user.ObjectName;


                    name = userNames;

                }
            }
            return name;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="users"></param>
        /// <returns></returns>
        private string GetAssignedApprovers(List<OUser> users)
        {
            string userNames = "";

            if (users.Count > 0)
                foreach (OUser user in users)
                    if (this.CurrentActivity.ApprovedUsers.Find(lf => lf.ObjectID == user.ObjectID) == null)
                        userNames += (userNames == "" ? "" : ", ") + user.ObjectName;
            return userNames;
        }

        public override void Created()
        {
            base.Created();
            this.CreatedUserID = (Workflow.CurrentUser != null ? Workflow.CurrentUser.ObjectID : null);
        }
    }

    /// <summary>
    /// 
    /// </summary>
    public class Approvers
    {
        public string ApproverName;
        public int? ApprovalLevel;
        public DateTime? ApprovalDateTime;
        public string ApprovalStatus;
    }
}
