//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
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
using System.Data;

using Anacle.DataFramework;
using Anacle.WorkflowFramework;

namespace LogicLayer
{
    [Serializable]
    public partial class LogicLayerPersistentObjectBase : PersistentObject, IWorkflowPersistentObject
    {
        /// <summary>
        /// Gets a GUID representing the foreign key link to the Activity table.
        /// </summary>
        public Guid? CurrentActivityID { get { return GetNullableField<Guid>("CurrentActivityID"); } set { } }


        /// <summary>
        /// Gets a list of file attachments attached to this PersistentObject.
        /// </summary>
        public DataList<OAttachment> Attachments { get { return GetDataList<OAttachment>("Attachments"); } }


        /// <summary>
        /// Gets a list of memo objects attached to this PersistentObject.
        /// </summary>
        public DataList<OMemo> Memos { get { return GetDataList<OMemo>("Memos"); } }


        /// <summary>
        /// Gets a list representing workflow activity history of this PersistentObject.
        /// </summary>
        public DataList<OActivity> Activities { get { return GetDataList<OActivity>("Activities"); } }


        /// <summary>
        /// Gets an OActivity object representing the current status of this PersistentObject.
        /// </summary>
        public OActivity CurrentActivity { get { return GetObject<OActivity>("CurrentActivity"); } set { SetObject<OActivity>("CurrentActivity", value); } }


        /// <summary>
        /// Gets a list representing all custommizable attribute fields.
        /// </summary>
        public DataList<OCustomizedAttributeField> CustomizedAttributeFields { get { return GetDataList<OCustomizedAttributeField>("CustomizedAttributeFields"); } }


        /// <sumary>
        /// Gets a list representing workflow activity histories of this PersistentObject
        /// </sumary>
        public DataList<OActivityHistory> ActivityHistories { get { return GetDataList<OActivityHistory>("ActivityHistories"); } }

        public Guid? CreatedUserID { get { return GetNullableField<Guid>("CreatedUserID"); } set { SetNullableField<Guid>("CreatedUserID", value); } }


        /// <summary>
        /// Gets a comma-separated list of users who are assigned to this object.
        /// 
        /// If this object does not have a workflow or state, this property returns
        /// a null string.
        /// </summary>
        public string AssignedUserNames
        {
            get
            {
                if (CurrentActivity == null)
                    return null;

                if (CurrentActivity.Users.Count > 0)
                {
                    string users = "";
                    foreach (OUser user in CurrentActivity.Users)
                        if (user != null)
                            users += (users == "" ? "" : ", ") + user.ObjectName;
                    return users;
                }
                else
                    return null;
            }
        }


        /// <summary>
        /// Gets a comma-separated list of positions who are assigned to this object.
        /// 
        /// If this object does not have a workflow or state, this property returns
        /// a null string.
        /// </summary>
        public string AssignedUserPositions
        {
            get
            {
                if (CurrentActivity == null)
                    return null;

                if (CurrentActivity.Positions.Count > 0)
                {
                    string positions = "";
                    foreach (OPosition position in CurrentActivity.Positions)
                        positions += (positions == "" ? "" : ", ") + position.ObjectName;
                    return positions;
                }
                else
                    return null;
            }
        }


        /// <summary>
        /// Gets the OLocation tracked by this object. This
        /// is used by the workflow assignment to assign
        /// this object to one or more positions. 
        /// <para></para>
        /// Descendant classes should implement this if
        /// this object can be assigned to Positions. If no
        /// location is associated with this object, return
        /// null.
        /// </summary>
        public virtual List<OLocation> TaskLocations
        {
            get { return null; }
        }


        /// <summary>
        /// Gets the OEquipment tracked by this object. This
        /// is used by the workflow assignment to assign
        /// this object to one or more positions. 
        /// <para></para>
        /// Descendant classes should implement this if
        /// this object can be assigned to Positions. If no
        /// location is associated with this object, return
        /// null.
        /// </summary>
        public virtual List<OEquipment> TaskEquipments
        {
            get { return null; }
        }


        /// <summary>
        /// Gets the OCode (type of service) tracked by this object. 
        /// This is used by the workflow assignment to assign
        /// this object to one or more positions. 
        /// <para></para>
        /// Descendant classes should implement this if
        /// this object can be assigned to Positions. If no
        /// location is associated with this object, return
        /// null.
        /// </summary>
        public virtual OCode TaskTypeOfService
        {
            get { return null; }
        }



        /// <summary>
        /// Gets the dollar amount of this task. This
        /// is used by the approval assignments to determine
        /// the users or positions to assign the object
        /// to. 
        /// <para></para>
        /// Descendant classes should implement this if
        /// this object undergoes approval, and the amount
        /// is require to determine the approvers for the
        /// object.
        /// </summary>
        public virtual decimal TaskAmount
        {
            get { return 0; }
        }

        /// <summary>
        /// Gets the DataSet of this object.
        /// This is used for printing out and
        /// exporting to PDF via RDL form.
        /// </summary>
        public virtual DataSet DocumentTemplateDataSet
        {
            get { return null; }
        }

        /// <summary>
        /// Get the Attachments attached to this task
        /// for purpose of sending email.
        /// </summary>
        public virtual List<OAttachment> EmailMessageAttachments
        {
            get { return null; }
        }

        /// <summary>
        /// Gets the Importance of the task.
        /// </summary>
        public virtual int? TaskPriority
        {
            get { return null; }
        }

        /// <summary>
        /// Generates the next running number and sets it
        /// to the ObjectNumber of this persistent object.
        /// </summary>
        protected virtual void GenerateNextRunningNumber()
        {
            ORunningNumberGenerator generator = TablesLogic.tRunningNumberGenerator.Load(
                TablesLogic.tRunningNumberGenerator.ObjectTypeName == this.GetType().Name);

            if (generator == null)
                return;
        }


        /// <summary>
        /// Overrides the PostSaving method to auto generate the running number,
        /// and update the task name and the task number of the current activity.
        /// </summary>
        //protected override void PostSaving()
        //{
        //    base.PostSaving();

        //    // Auto-generates the running number if it has not yet
        //    // been generated before, and if this object has implemented
        //    // the IAutoGenerateRunningNumber interface.
        //    //
        //    if (this.ObjectNumber == null || this.ObjectNumber.Trim() == "")
        //    {
        //        if (this is IAutoGenerateRunningNumber)
        //        {
        //            ORunningNumberGenerator.GenerateNextRunningNumber(DateTime.Now, this);
        //        }
        //    }

        //    if (CurrentActivity != null)
        //    {
        //        CurrentActivity.TaskName = ObjectName;
        //        CurrentActivity.TaskNumber = ObjectNumber;
        //        CurrentActivity.TaskAmount = this.TaskAmount;

        //        // override the previous task amount
        //    }
        //}


        /// <summary>
        /// Overrides the deactivating method to deactivate
        /// the CurrentActivity when this object is deactivated.
        /// </summary>
        public override void Deactivating()
        {
            base.Deactivating();
            if (this.IsDeleted == 0)
            {
                // When this object is deactivated, deactivate also the current activity,
                // so users will no longer see it on the task list.
                // 
                if (this.CurrentActivity != null)
                    this.CurrentActivity.Deactivate();
            }
        }


        /// <summary>
        /// Overrides the activating method to activate the
        /// CurrentActivity object when this object is activated.
        /// </summary>
        public override void Activating()
        {
            base.Activating();
            if (this.IsDeleted == 1)
            {
                // When this object is activated, activate the current activity also,
                // so users will be able see it on the task list.
                // 
                if (this.CurrentActivity != null)
                    this.CurrentActivity.Activate();
            }
        }


        /// <summary>
        /// Triggers an event that will be passed to the Workflow Engine
        /// to execute. It is the responsibility of the developer to 
        /// save any modified changes to this object BEFORE calling
        /// this method. 
        /// </summary>
        /// <remarks>
        /// The following is an example on how to call this method by passing
        /// in the object with the event declarations, and the event name to
        /// trigger.
        /// <example>
        /// <code>
        ///    OWork work = TablesLogic.tWork.Load(workId);
        ///    work.SupervisorID = userID;
        ///    
        ///    // The work must be saved before the TriggerWorkflowEvent
        ///    // method is called.
        ///    //
        ///    work.Save();
        ///    work.TriggerWorkflowEvent("SubmitForApproval");
        /// </code>
        /// </example>
        /// </remarks>
        /// <param name="transitEventName">The name of the event that has been
        /// declared in the WorkflowFramework.IAnacleEvents interface.</param>
        public void TriggerWorkflowEvent(string transitEventName)
        {
            if (transitEventName == "" || transitEventName == "-")
                return;

            // 2010.10.01
            // Kim Foong
            // Critical: This must be here so that the triggering event name is updated
            // to the one passed in from the transitEventName parameter.
            //
            this.CurrentActivity.TriggeringEventName = transitEventName;
            this.Save();

            if (CurrentActivity == null)
                throw new WorkflowTransitionException(String.Format(Resources.Errors.Workflow_WorkflowNotCreated, this.GetType().Name, this.ObjectID.ToString()));
            if (CurrentActivity.WorkflowInstanceID == null)
                throw new WorkflowTransitionException(String.Format(Resources.Errors.Workflow_NoWorkflowInstanceID, this.GetType().Name, this.ObjectID.ToString()));

            WorkflowEngine.Engine.TriggerWorkflowEvent(this, this.CurrentActivity.ObjectName, CurrentActivity.WorkflowInstanceID, transitEventName);
            this.Reload();
        }


        /// <summary>
        /// Saves the object and then transits the object.
        /// </summary>
        /// <param name="transitEventName"></param>
        public void SaveAndTransit(string transitEventName)
        {
            //this.CurrentActivity.TriggeringEventName = transitEventName;
            //this.CurrentActivity.TaskCurrentComments = "";
            //Save();
            this.CurrentActivity.TaskCurrentComments = "";
            TriggerWorkflowEvent(transitEventName);
            Save();
        }


        /// <summary>
        /// Archives the current activity into the activity history.
        /// </summary>
        /// <param name="historyType"></param>
        public void ArchiveActivity(int historyType)
        {
            // Create a new activity history record, clone most of its fields
            // and save it into the database.
            //
            OActivityHistory activityHistory = TablesLogic.tActivityHistory.Create();
            if (this.CurrentActivity != null)
            {
                activityHistory.ShallowCopy(this.CurrentActivity);
                foreach (OUser user in this.CurrentActivity.Users)
                    activityHistory.Users.Add(user);
                foreach (OUser user in this.CurrentActivity.CarbonCopyUsers)
                    activityHistory.CarbonCopyUsers.Add(user);
                foreach (OPosition position in this.CurrentActivity.Positions)
                    activityHistory.Positions.Add(position);

                // 2010.08.01
                // Kim Foong
                // Sometimes the service can do an auto-transit, so we must
                // never assume that the Workflow.CurrentUser contains a valid user.
                // 
                if (Workflow.CurrentUser != null)
                    activityHistory.ApprovedByUserID = Workflow.CurrentUser.ObjectID;
            }
            activityHistory.HistoryType = historyType;
            activityHistory.Save();
        }


        /// <summary>
        /// Assigns the task to a user, or a group of users based on their
        /// system role, or business role. After the assignment, this
        /// current activity is archived into the 
        /// ActivityHistory table for future reference.
        /// <para></para>
        /// This method is only called by the SetStateAndAssign custom activity
        /// in the workflow, but should not be called by the developer.
        /// </summary>
        /// <param name="activity"></param>
        /// <param name="stateName"></param>
        /// <param name="priority"></param>
        /// <param name="scheduledStartDateTime"></param>
        /// <param name="scheduledEndDateTime"></param>
        /// <param name="usersToAssignToThisTask"></param>
        /// <param name="roleCodes"></param>
        public virtual void AssignTask(
            string workflowInstanceId,
            string stateName,
            bool notifyAssignedRecipients,
            int priority,
            DateTime? scheduledStartDateTime,
            DateTime? scheduledEndDateTime,
            IEnumerable usersToAssignToThisTask,
            string roleCodes)
        {
            if (this.CurrentActivity == null)
                this.CurrentActivity = TablesLogic.tActivity.Create();

            // Set the current activity properties.
            //
            this.CurrentActivity.AttachedObjectID = this.ObjectID;
            this.CurrentActivity.ObjectTypeName = this.GetType().BaseType.Name;
            this.CurrentActivity.ObjectName = stateName;
            this.CurrentActivity.CurrentStateName = this.CurrentActivity.ObjectName;
            this.CurrentActivity.WorkflowInstanceID = workflowInstanceId;
            this.CurrentActivity.Priority = priority;
            this.CurrentActivity.ScheduledStartDateTime = scheduledStartDateTime;
            this.CurrentActivity.ScheduledEndDateTime = scheduledEndDateTime;
            this.CurrentActivity.TaskPreviousComments = this.CurrentActivity.TaskCurrentComments;
            this.CurrentActivity.TaskCurrentComments = "";
            this.CurrentActivity.Users.Clear();
            this.CurrentActivity.Positions.Clear();

            // Clear all approval-related properties
            //
            this.CurrentActivity.PreviousApprovalLevel = this.CurrentActivity.CurrentApprovalLevel;
            this.CurrentActivity.CurrentApprovalLevel = null;
            this.CurrentActivity.ApprovalProcessID = null;
            this.CurrentActivity.NumberOfApprovalsAtCurrentLevel = null;
            this.CurrentActivity.NumberOfApprovalsRequiredAtCurrentLevel = null;

            // Assign users/roles to the task.
            //
            if (usersToAssignToThisTask != null)
            {
                foreach (object user in usersToAssignToThisTask)
                {
                    if (!(user is OUser))
                        throw new WorkflowAssignmentException(Resources.Errors.Workflow_ListInvalid);
                    this.CurrentActivity.Users.Add((OUser)user);
                }
            }

            /*
            List<OPosition> positionsToAssignToThisTask = new List<OPosition>();
            if (roleCodes != null)
            {
                foreach (object role in roleCodes)
                {
                    if (!(role is ORole))
                        throw new WorkflowAssignmentException(Resources.Errors.Workflow_ListInvalid);
                    positionsToAssignToThisTask.AddRange(OPosition.GetPositionsByRoleCodesAndObject(this, ((ORole)role).RoleCode));
                }

                foreach (OPosition position in positionsToAssignToThisTask)
                    this.CurrentActivity.Positions.Add(position);
            }
            */

            
            if (roleCodes != null && roleCodes.Trim() != "")
            {
                List<OPosition> positionsToAssignToThisTask =
                    OPosition.GetPositionsByRoleCodesAndObject(
                    this, roleCodes.Split(','));
                foreach (OPosition position in positionsToAssignToThisTask)
                    this.CurrentActivity.Positions.Add(position);
            }
            
            if (this.CurrentActivity.Users.Count == 0 &&
                this.CurrentActivity.Positions.Count == 0)
            {
                throw new WorkflowAssignmentException(Resources.Errors.Workflow_UnableToAssignUsersOrPositions);
            }

            // Save a copy of the activity into the activity history table.
            //
            ArchiveActivity(0);

            // Apply the notification process and timings
            // to this object, if applicable.
            //
            ApplyNotificationProcess();

            // We need to save the persistent object to ensure that the
            // statuses are all saved.
            //
            //if (!this.IsNew)
            Save();

            // Notifies users/positions assigned to this task.
            //
            if (notifyAssignedRecipients)
                NotifyAssignedRecipient(this);
        }



        /// <summary>
        /// Assigns the task to approvers based on the approval
        /// hierarchy.
        /// <para></para>
        /// This method is only called by the SetStateAndAssignApprovers 
        /// custom activity in the workflow, but should not be called by 
        /// the developer.
        /// </summary>
        /// <param name="activity"></param>
        /// <param name="stateName"></param>
        /// <param name="priority"></param>
        /// <param name="scheduledStartDateTime"></param>
        /// <param name="scheduledEndDateTime"></param>
        public virtual bool AssignTaskToApprovers(
            string workflowInstanceId,
            string stateName,
            bool notifyAssignedRecipients,
            int priority,
            DateTime? scheduledStartDateTime,
            DateTime? scheduledEndDateTime)
        {
            if (this.CurrentActivity == null)
                this.CurrentActivity = TablesLogic.tActivity.Create();

            // Set the default last approval level to 1.
            //
            if (this.CurrentActivity.LastApprovalLevel == null)
                this.CurrentActivity.LastApprovalLevel = 1;

            // Make sure that the user has already selected the 
            // approval process before we proceed.
            //
            if (this.CurrentActivity.ApprovalProcess == null)
                throw new WorkflowAssignmentException(Resources.Errors.Workflow_ApprovalProcessDetailNotSpecified);

            // Keep track of the users who approved this task
            // and increment the total number of users who approved.
            //
            if (Workflow.CurrentUser != null &&
                this.CurrentActivity.CurrentApprovalLevel != null &&
                this.CurrentActivity.ApprovedUsers.FindObject(Workflow.CurrentUser.ObjectID.Value) == null)
            {
                this.CurrentActivity.ApprovedUsers.Add(Workflow.CurrentUser);
                
                if (this.CurrentActivity.NumberOfApprovalsAtCurrentLevel == null)
                    this.CurrentActivity.NumberOfApprovalsAtCurrentLevel = 1;
                else
                    this.CurrentActivity.NumberOfApprovalsAtCurrentLevel = this.CurrentActivity.NumberOfApprovalsAtCurrentLevel + 1;
            }

            // If the number of approvals given has not met the required
            // then we have to remain in the same level.
            //
            int? nextApprovalLevel = this.CurrentActivity.CurrentApprovalLevel;
            List<OApprovalHierarchyLevel> nextApprovalHierarchyLevels = new List<OApprovalHierarchyLevel>();

            // Calls a method to get the next level approvers
            // if the current user approves this task.
            //
            bool isApproved = false;
            int approvalResult =
                this.CurrentActivity.ApprovalProcess.GetApprovalHierarchyLevels(
                this, nextApprovalHierarchyLevels, out nextApprovalLevel);

            if (approvalResult == ApprovalResult.Approved ||
                approvalResult == ApprovalResult.NoApprovalRequired)
            {
                isApproved = true;
                this.CurrentActivity.NumberOfApprovalsAtCurrentLevel = 0;
                this.CurrentActivity.ApprovedUsers.Clear();
            }
            else
            {
                if ((this.CurrentActivity.CurrentApprovalLevel == null && nextApprovalLevel != null) ||
                    (this.CurrentActivity.CurrentApprovalLevel != null && nextApprovalLevel == null) ||
                    (this.CurrentActivity.CurrentApprovalLevel != nextApprovalLevel))
                {
                    this.CurrentActivity.NumberOfApprovalsAtCurrentLevel = 0;
                    this.CurrentActivity.ApprovedUsers.Clear();
                }

                this.CurrentActivity.PreviousApprovalLevel = this.CurrentActivity.CurrentApprovalLevel;
                this.CurrentActivity.CurrentApprovalLevel = nextApprovalLevel;

                if (this.CurrentActivity.ApprovalProcess.ModeOfForwarding == ApprovalModeOfForwarding.HierarchicalWithLastRejectedSkipping)
                    this.CurrentActivity.LastApprovalLevel = nextApprovalLevel;
                else
                    this.CurrentActivity.LastApprovalLevel = null;
            }


            if (!isApproved)
            {
                // If the task is not considered approved, then
                // perform the assignment.
                //
                this.CurrentActivity.AttachedObjectID = this.ObjectID;
                this.CurrentActivity.ObjectTypeName = this.GetType().BaseType.Name;
                this.CurrentActivity.WorkflowInstanceID = workflowInstanceId;
                this.CurrentActivity.ObjectName = stateName;
                this.CurrentActivity.CurrentStateName = this.CurrentActivity.ObjectName;
                this.CurrentActivity.Priority = priority;
                this.CurrentActivity.ScheduledStartDateTime = scheduledStartDateTime;
                this.CurrentActivity.ScheduledEndDateTime = scheduledEndDateTime;
                this.CurrentActivity.TaskPreviousComments = this.CurrentActivity.TaskCurrentComments;
                this.CurrentActivity.TaskCurrentComments = "";

                // If we are not remaining at the same level,
                // get the list of all the approvers and assign to
                // this task.
                //
                this.CurrentActivity.Users.Clear();
                this.CurrentActivity.Positions.Clear();

                // Perform the assignment of the approvers (users and positions)
                // to the activity. 
                //
                foreach (OApprovalHierarchyLevel approvalHierarchyLevel in nextApprovalHierarchyLevels)
                {
                    if (approvalHierarchyLevel.IsRouted)
                    {
                        // Here we assigned the users
                        //
                        foreach (OUser user in approvalHierarchyLevel.UsersToBeAssigned)
                            this.CurrentActivity.Users.Add(user);

                        // Then we assign the positions
                        //
                        foreach (OPosition position in approvalHierarchyLevel.Positions)
                            this.CurrentActivity.Positions.Add(position);

                        // Then we assign the positions based on the assigned roles.
                        //
                        List<string> roleCodes = new List<string>();
                        foreach (ORole role in approvalHierarchyLevel.Roles)
                            roleCodes.Add(role.RoleCode);
                        List<OPosition> assignedPositions = OPosition.GetPositionsByRoleCodesAndObject(this, roleCodes.ToArray());
                        this.CurrentActivity.Positions.AddRange(assignedPositions);

                        if (this.CurrentActivity.ApprovalProcess.ModeOfForwarding == ApprovalModeOfForwarding.Direct ||
                            this.CurrentActivity.ApprovalProcess.ModeOfForwarding == ApprovalModeOfForwarding.Hierarchical ||
                            this.CurrentActivity.ApprovalProcess.ModeOfForwarding == ApprovalModeOfForwarding.HierarchicalWithLastRejectedSkipping)
                            this.CurrentActivity.NumberOfApprovalsRequiredAtCurrentLevel = approvalHierarchyLevel.NumberOfApprovalsRequired;
                        else
                            this.CurrentActivity.NumberOfApprovalsRequiredAtCurrentLevel = 1;
                    }
                }

                if (this.CurrentActivity.Users.Count == 0 &&
                    this.CurrentActivity.Positions.Count == 0)
                {
                    throw new WorkflowAssignmentException(Resources.Errors.Workflow_UnableToAssignApprovers);
                }

                // Save a copy of the activity into the activity history table.
                // We should only archive the activity into the history table,
                // because in the event this task is approved, it should be
                // transited into an approved state, in which the SetStateAndAssign
                // activity (and hence the AssignTask method) will be executed.
                // 
                ArchiveActivity(0);
            }

            // Apply the notification process and timings
            // to this object, if applicable.
            //
            ApplyNotificationProcess();

            // We need to save the persistent object to ensure that the
            // statuses are all saved.
            //
            //if (!this.IsNew)
            Save();

            // Notifies users/positions assigned to this task.
            //
            if (!isApproved && notifyAssignedRecipients)
                NotifyAssignedRecipient(this);

            return isApproved;
        }


        /// <summary>
        /// Get the next notification date based on a reference field on this object
        /// and the notification time in minutes.
        /// </summary>
        /// <param name="referenceField"></param>
        /// <param name="notificationTimeInMinutes"></param>
        /// <returns></returns>
        public object GetNextNotificationDateTime(string referenceField, int? notificationTimeInMinutes)
        {
            if (notificationTimeInMinutes == null)
                return DBNull.Value;

            object referenceFieldValue = DataFrameworkBinder.GetValue(this, referenceField, false);
            DateTime? referenceDateTime = referenceFieldValue as DateTime?;

            if (referenceDateTime == null)
                return DBNull.Value;
            return referenceDateTime.Value.AddMinutes(notificationTimeInMinutes.Value);
        }


        /// <summary>
        /// Searches for and applies the notification process to the
        /// task.
        /// </summary>
        public void ApplyNotificationProcess()
        {
            if (this is INotificationEnabled)
            {
                List<ONotificationProcess> notificationProcesses = ONotificationProcess.GetNotificationProcesses(this);

                if (notificationProcesses.Count > 0)
                {
                    if (this.CurrentActivity.NotificationID == null)
                    {
                        ONotificationProcess notificationProcess = notificationProcesses[0];
                        ONotification notification = TablesLogic.tNotification.Create();
                        ONotificationMilestones milestones = notificationProcess.NotificationMilestones;

                        // Find out when is the next date/time the next
                        // notification should occur.
                        //
                        DateTime? nextNotificationDateTime = null;
                        int? nextNotificationLevel = null;
                        int? nextNotificationMilestone = null;

                        // 2010.05.13
                        // Kim Foong
                        // Modified to pass in the current date/time so as
                        // to get the next notification date/time after the
                        // current date/time.
                        //
                        notificationProcess.GetNextNotificationDateTime(this, DateTime.Now.AddMinutes(-10),
                            ref nextNotificationDateTime, ref nextNotificationMilestone, ref nextNotificationLevel);

                        notification.NextNotificationDateTime = nextNotificationDateTime;
                        notification.NextNotificationLevel = nextNotificationLevel;
                        notification.NextNotificationMilestone = nextNotificationMilestone;


                        // Set up the service level time limit. 
                        // This is used by reports, where required
                        // to benchmark the service level requirements
                        // against the actual milestone completion.
                        // 
                        if (notificationProcess.NotificationLevelAsLimit != null)
                        {
                            if (notificationProcess.UseDefaultTimings == 1)
                            {
                                ONotificationHierarchyLevel level = notificationProcess.NotificationHierarchy.FindNotificationHierarchyLevelByLevel(notificationProcess.NotificationLevelAsLimit.Value);
                                if (level != null && milestones != null)
                                {
                                    if (milestones.DateTimeLimitField1 != "" && milestones.DateTimeLimitField1 != null)
                                    {
                                        this.DataRow[milestones.DateTimeLimitField1] = GetNextNotificationDateTime(milestones.ReferenceField1, level.NotificationTimeInMinutes1);
                                        this.Touch();
                                    }
                                    if (milestones.DateTimeLimitField2 != "" && milestones.DateTimeLimitField2 != null)
                                    {
                                        this.DataRow[milestones.DateTimeLimitField2] = GetNextNotificationDateTime(milestones.ReferenceField2, level.NotificationTimeInMinutes2);
                                        this.Touch();
                                    }
                                    if (milestones.DateTimeLimitField3 != "" && milestones.DateTimeLimitField3 != null)
                                    {
                                        this.DataRow[milestones.DateTimeLimitField3] = GetNextNotificationDateTime(milestones.ReferenceField3, level.NotificationTimeInMinutes3);
                                        this.Touch();
                                    }
                                    if (milestones.DateTimeLimitField4 != "" && milestones.DateTimeLimitField4 != null)
                                    {
                                        this.DataRow[milestones.DateTimeLimitField4] = GetNextNotificationDateTime(milestones.ReferenceField4, level.NotificationTimeInMinutes4);
                                        this.Touch();
                                    }
                                }
                            }
                            else
                            {
                                ONotificationProcessTiming notificationProcessTiming = notificationProcess.FindNotificationProcessTimingByLevel(notificationProcess.NotificationLevelAsLimit.Value);
                                if (notificationProcessTiming != null && milestones != null)
                                {
                                    if (milestones.DateTimeLimitField1 != "" && milestones.DateTimeLimitField1 != null)
                                    {
                                        this.DataRow[milestones.DateTimeLimitField1] = GetNextNotificationDateTime(milestones.ReferenceField1, notificationProcessTiming.NotificationTimeInMinutes1);
                                        this.Touch();
                                    }
                                    if (milestones.DateTimeLimitField2 != "" && milestones.DateTimeLimitField2 != null)
                                    {
                                        this.DataRow[milestones.DateTimeLimitField2] = GetNextNotificationDateTime(milestones.ReferenceField2, notificationProcessTiming.NotificationTimeInMinutes2);
                                        this.Touch();
                                    }
                                    if (milestones.DateTimeLimitField3 != "" && milestones.DateTimeLimitField3 != null)
                                    {
                                        this.DataRow[milestones.DateTimeLimitField3] = GetNextNotificationDateTime(milestones.ReferenceField3, notificationProcessTiming.NotificationTimeInMinutes3);
                                        this.Touch();
                                    }
                                    if (milestones.DateTimeLimitField4 != "" && milestones.DateTimeLimitField4 != null)
                                    {
                                        this.DataRow[milestones.DateTimeLimitField4] = GetNextNotificationDateTime(milestones.ReferenceField4, notificationProcessTiming.NotificationTimeInMinutes4);
                                        this.Touch();
                                    }
                                }
                            }
                        }

                        this.CurrentActivity.NotificationID = notification.ObjectID;
                        notification.ActivityID = this.CurrentActivityID;
                        notification.NotificationProcessID = notificationProcess.ObjectID;
                        notification.Save();
                    }
                }
                else
                {
                    if (this.CurrentActivity.NotificationID != null)
                    {
                        this.CurrentActivity.Notification.NextNotificationDateTime = null;
                        this.CurrentActivity.Notification.ActivityID = null;
                        this.CurrentActivity.Notification.Deactivate();
                        this.CurrentActivity.NotificationID = null;
                    }
                }
            }
        }


        /// <summary>
        /// Rejects this task.
        /// <para></para>
        /// This method is called only by the RejectTask activity
        /// in a workflow and should not be called directly by the
        /// developer.
        /// </summary>
        /// <returns></returns>
        public void RejectTask()
        {
            using (Connection c = new Connection())
            {
                this.CurrentActivity.CurrentApprovalLevel = null;
                this.Save();
                c.Commit();
            }
        }


        /// <summary>
        /// Approves this task.
        /// <para></para>
        /// This method is called only by the ApproveTask activity
        /// in a workflow and should not be called directly by the
        /// developer.
        /// </summary>
        /// <returns></returns>
        public void ApproveTask()
        {
            using (Connection c = new Connection())
            {
                this.Save();
                c.Commit();
            }
        }


        /// <summary>
        /// Sends an e-mail or SMS message to the
        /// specified recipients based on the specified 
        /// message template.
        /// <para></para>
        /// It achieves this by calling the 
        /// OMessageTemplate.GenerateAndSendMessage method.
        /// Application developers can all either method,
        /// but this method is exposed to the SendMessage 
        /// workflow activity.
        /// </summary>
        /// <param name="messageTemplateCode"></param>
        /// <param name="emailRecipients"></param>
        /// <param name="smsRecipients"></param>
        public void SendMessage(string messageTemplateCode, string emailRecipients, string smsRecipients)
        {
            OMessageTemplate messageTemplate =
                TablesLogic.tMessageTemplate.Load(
                TablesLogic.tMessageTemplate.WhereUsed == MessageTemplateUsage.General &
                TablesLogic.tMessageTemplate.MessageTemplateCode == messageTemplateCode);

            if (messageTemplate == null)
                throw new Exception(String.Format(Resources.Errors.MessageTemplate_MessageTemplateCannotBeFound, messageTemplateCode));

            messageTemplate.GenerateAndSendMessage(this, emailRecipients, smsRecipients);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="subjectMessageTemplate"></param>
        /// <param name="bodyMessageTemplate"></param>
        /// <param name="emailRecipients"></param>
        /// <param name="smsRecipients"></param>
        public void SendMessageWithComposedEmailMessage(string subjectMessageTemplate, string bodyMessageTemplate, string emailRecipients, string emailCCRecipients, string smsRecipients)
        {
            OMessageTemplate.GenerateAndSendComposedEmailMessage(this, subjectMessageTemplate, bodyMessageTemplate, emailRecipients, smsRecipients);
        }

        /// <summary>
        /// Sends an e-mail or SMS message to the
        /// specified recipients based on the specified 
        /// message template.
        /// <para></para>
        /// It achieves this by calling the 
        /// OMessageTemplate.GenerateAndSendMessage method.
        /// Application developers can all either method,
        /// but this method is exposed to the SendMessage 
        /// workflow activity.
        /// </summary>
        /// <param name="messageTemplateCode"></param>
        /// <param name="emailRecipients"></param>
        /// <param name="smsRecipients"></param>
        public void SendMessage(string messageTemplateCode, string emailRecipients, string emailCCRecipients, string smsRecipients)
        {
            OMessageTemplate messageTemplate =
                TablesLogic.tMessageTemplate.Load(
                TablesLogic.tMessageTemplate.WhereUsed == MessageTemplateUsage.General &
                TablesLogic.tMessageTemplate.MessageTemplateCode == messageTemplateCode);

            if (messageTemplate == null)
                throw new Exception(String.Format(Resources.Errors.MessageTemplate_MessageTemplateCannotBeFound, messageTemplateCode));

            messageTemplate.GenerateAndSendMessage(this, emailRecipients, emailCCRecipients, smsRecipients);
        }


        /// <summary>
        /// Sends an e-mail or SMS message to the
        /// specified recipients based on the specified 
        /// message template.
        /// <para></para>
        /// It achieves this by calling the SendMessage method.
        /// </summary>
        /// <param name="messageTemplateCode"></param>
        /// <param name="emailRecipients"></param>
        /// <param name="smsRecipients"></param>
        public void SendMessage(string messageTemplateCode, params OUser[] users)
        {
            string cellphone = "";
            string email = "";
            foreach (OUser user in users)
            {
                if (user != null)
                {
                    if (user.UserBase.Cellphone != null && user.UserBase.Cellphone.Trim() != "")
                        cellphone += user.UserBase.Cellphone + ";";
                    if (user.UserBase.Email != null && user.UserBase.Email.Trim() != "")
                        email += user.UserBase.Email + ";";
                }
            }
            SendMessage(messageTemplateCode, email, cellphone);
        }

        /// <summary>
        /// Sends an e-mail or SMS message to the
        /// specified recipients based on the specified 
        /// message template.
        /// <para></para>
        /// It achieves this by calling the SendMessage method.
        /// </summary>
        /// <param name="messageTemplateCode"></param>
        /// <param name="emailRecipients"></param>
        /// <param name="smsRecipients"></param>
        public void SendMessage(string messageTemplateCode, List<OUser> users, List<OUser> ccUsers)
        {
            string cellphone = "";
            string email = "";
            string ccEmail = "";
            Hashtable emails = new Hashtable();

            foreach (OUser user in users)
            {
                if (user != null)
                {
                    if (user.UserBase.Cellphone != null && user.UserBase.Cellphone.Trim() != "")
                        cellphone += user.UserBase.Cellphone + ";";
                    if (user.UserBase.Email != null && user.UserBase.Email.Trim() != "" && emails[user.UserBase.Email] == null)
                    {
                        emails[user.UserBase.Email] = 1;
                        email += user.UserBase.Email + ";";
                    }
                }
            }

            foreach (OUser user in ccUsers)
            {
                if (user != null)
                {
                    if (user.UserBase.Email != null && user.UserBase.Email.Trim() != "" && emails[user.UserBase.Email] == null)
                    {
                        emails[user.UserBase.Email] = 1;
                        ccEmail += user.UserBase.Email + ";";
                    }
                }
            }

            SendMessage(messageTemplateCode, email, ccEmail, cellphone);
        }


        /// <summary>
        /// Sends an e-mail or SMS message to the
        /// specified recipients based on the specified 
        /// message template.
        /// <para></para>
        /// It achieves this by calling the 
        /// OMessageTemplate.GenerateAndSendMessage method.
        /// Application developers can all either method,
        /// but this method is exposed to the SendMessage 
        /// workflow activity.
        /// </summary>
        protected void NotifyAssignedRecipient(LogicLayerPersistentObjectBase logiclayerPersistentObject)
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
                TablesLogic.tUser.Positions.ObjectID.In(logiclayerPersistentObject.CurrentActivity.Positions));

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

                // Generate and the send message to the users.
                //
                messageTemplate.GenerateAndSendMessage(this, emailRecipients, smsRecipients);
            }
        }


        /// <summary>
        /// Asserts if the persistent object passed in is derived from
        /// LogicLayerPersistentObject.
        /// </summary>
        /// <param name="persistentObject">The persistent object to test.</param>
        public static void AssertObjectType(PersistentObject persistentObject)
        {
            if (!(persistentObject is LogicLayerPersistentObject))
                throw new Exception("The current object of type '" + persistentObject.GetType().BaseType.Name + "' does not derive from LogicLayerPersistentObject");
        }

        /// <summary>
        /// Check if the LogicLayerPersistentObject has reached the last level of approval.
        /// </summary>
        /// <param name="persistentObject"></param>
        public bool IsFinalApprover()
        {
            OApprovalProcess approvalProcess;
            if (this.CurrentActivity.ApprovalProcessID != null)
            {
                approvalProcess = TablesLogic.tApprovalProcess.Load(this.CurrentActivity.ApprovalProcessID);

                OApprovalHierarchyLevel nextApprovalHierarchyLevel;
                int? nextApprovalLevel = 0;
                if (this.CurrentActivity.CurrentApprovalLevel != null)
                {
                    nextApprovalLevel = this.CurrentActivity.CurrentApprovalLevel;
                    nextApprovalHierarchyLevel = approvalProcess.ApprovalHierarchy.FindApprovalHierarchyLevelByLevel((int)nextApprovalLevel);
                    if (Math.Abs(this.TaskAmount) <= nextApprovalHierarchyLevel.ApprovalLimit)
                    {
                        return true;
                    }
                }
            }

            return false;
        }

    }

    /// <summary>
    /// 
    /// </summary>
    public enum EnumTaskImportance
    {
        Low = 0,
        Normal = 1,
        High = 3
    }
}
