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

namespace LogicLayer
{
    /*** CAPITALAND ***/
    public partial class LogicLayerPersistentObject : LogicLayerPersistentObjectBase, IWorkflowPersistentObject
    {
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
            this.CurrentActivity.Priority = this.CurrentActivity.Priority >= priority ? this.CurrentActivity.Priority : priority;
            this.CurrentActivity.ScheduledStartDateTime = scheduledStartDateTime;
            this.CurrentActivity.ScheduledEndDateTime = scheduledEndDateTime;
            this.CurrentActivity.TaskPreviousComments = this.CurrentActivity.TaskCurrentComments;
            this.CurrentActivity.TaskCurrentComments = "";
            this.CurrentActivity.Users.Clear();
            this.CurrentActivity.Positions.Clear();
            this.CurrentActivity.SecretaryPositions.Clear();
            this.CurrentActivity.ApprovedOnBehalfOfUser = "";

            // Clear all approval-related properties
            //
            this.CurrentActivity.PreviousApprovalLevel = this.CurrentActivity.CurrentApprovalLevel;
            this.CurrentActivity.CurrentApprovalLevel = null;

            this.CurrentActivity.NextApprovalLevel = null;

            //20120212 ptb
            //comment to use SubmitForApproval_Supporter
            //this.CurrentActivity.ApprovalProcessID = null;
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
        /// This method overrides the default AssignTaskToApprovers method in LogicLayerPersistentObjectBase,
        /// and is here only for CapitaLand.
        /// </summary>
        /// <param name="activity"></param>
        /// <param name="stateName"></param>
        /// <param name="priority"></param>
        /// <param name="scheduledStartDateTime"></param>
        /// <param name="scheduledEndDateTime"></param>
        public override bool AssignTaskToApprovers(
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
            if (this.CurrentActivity.NextApprovalLevel == null)
                this.CurrentActivity.NextApprovalLevel = 1;

            // Set the default last approval level to 1.
            //
            if (this.CurrentActivity.LastApprovalLevel == null)
                this.CurrentActivity.LastApprovalLevel = this.CurrentActivity.NextApprovalLevel;

            // Make sure that the user has already selected the 
            // approval process before we proceed.
            //
            if (this.CurrentActivity.ApprovalProcess == null)
                throw new WorkflowAssignmentException(Resources.Errors.Workflow_ApprovalProcessDetailNotSpecified);

            // Keep track of the users who approved this task
            // and increment the total number of users who approved.
            // at current level.
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

            // Get the current hierarchy level to apply trigger event.
            //
            OApprovalHierarchyLevel currentApprovalHierarchyLevel = null;
            if (this.CurrentActivity.CurrentApprovalLevel != null)
                currentApprovalHierarchyLevel = this.CurrentActivity.ApprovalProcess.ApprovalHierarchy.FindApprovalHierarchyLevelByLevel((int)this.CurrentActivity.CurrentApprovalLevel);

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
                this.CurrentActivity.ApprovedPositions.Clear();
            }
            else
            {
                if ((this.CurrentActivity.CurrentApprovalLevel == null && nextApprovalLevel != null) ||
                    (this.CurrentActivity.CurrentApprovalLevel != null && nextApprovalLevel == null) ||
                    (this.CurrentActivity.CurrentApprovalLevel != nextApprovalLevel))
                {
                    this.CurrentActivity.NumberOfApprovalsAtCurrentLevel = 0;
                    this.CurrentActivity.ApprovedUsers.Clear();
                    this.CurrentActivity.ApprovedPositions.Clear();
                }

                this.CurrentActivity.PreviousApprovalLevel = this.CurrentActivity.CurrentApprovalLevel;
                this.CurrentActivity.CurrentApprovalLevel = nextApprovalLevel;

                if (this.CurrentActivity.ApprovalProcess.ModeOfForwarding == ApprovalModeOfForwarding.HierarchicalWithLastRejectedSkipping ||
                    this.CurrentActivity.ApprovalProcess.ModeOfForwarding == ApprovalModeOfForwarding.HierarchicalWithRequestorAndLastRejectedSkipping)
                {
                    this.CurrentActivity.LastApprovalLevel = nextApprovalLevel;
                    this.CurrentActivity.NextApprovalLevel = nextApprovalLevel;
                }
                else
                {
                    this.CurrentActivity.LastApprovalLevel = null;
                    this.CurrentActivity.NextApprovalLevel = null;
                }
            }
            //ApprovedByUserID
            this.CurrentActivity.ApprovedByUserID = Workflow.CurrentUser.ObjectID;

            if (currentApprovalHierarchyLevel != null && currentApprovalHierarchyLevel.FinalApprovalEvent != null && currentApprovalHierarchyLevel.FinalApprovalEvent != "")
                this.CurrentActivity.TriggeringEventName = currentApprovalHierarchyLevel.FinalApprovalEvent;

            List<OUser> carbonCopyUsers = new List<OUser>();
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
                this.CurrentActivity.Priority = this.CurrentActivity.Priority >= priority ? this.CurrentActivity.Priority : priority;
                this.CurrentActivity.ScheduledStartDateTime = scheduledStartDateTime;
                this.CurrentActivity.ScheduledEndDateTime = scheduledEndDateTime;
                this.CurrentActivity.TaskPreviousComments = this.CurrentActivity.TaskCurrentComments;
                this.CurrentActivity.TaskCurrentComments = "";
                this.CurrentActivity.PreviousTaskAmount = this.TaskAmount;
                this.CurrentActivity.ApprovedOnBehalfOfUser = "";

                // Check if the user is currently assigned as any secretary position. 
                // 
                foreach (OPosition p in Workflow.CurrentUser.Positions)
                    if (this.CurrentActivity.SecretaryPositions.FindObject(p.ObjectID.Value) != null)
                    {
                        this.CurrentActivity.ApprovedOnBehalfOfUser += this.CurrentActivity.AssignedPositionText;
                        if (this.CurrentActivity.ApprovedOnBehalfOfUser != "")
                            this.CurrentActivity.ApprovedOnBehalfOfUser += "; ";
                        this.CurrentActivity.ApprovedOnBehalfOfUser += this.CurrentActivity.AssignedUserText;
                        break;
                    }

                #region Commented out
                /*
                if (this.CurrentActivity.SecretaryPositions.Find(Workflow.CurrentUser.ObjectID.Value) != null)
                {
                    // There should be at least two assigned users, but only one of them is the actual approver.
                    //
                    Hashtable users = new Hashtable();
                    foreach (OUser user in this.CurrentActivity.Users)
                        users[user.ObjectID.Value] = user;
                    foreach (OUser user in this.CurrentActivity.SecretaryUsers)
                        users.Remove(user.ObjectID.Value);

                    if (users.Count > 0)
                    {
                        foreach (OUser user in users.Values)
                        {
                            this.CurrentActivity.ApprovedOnBehalfOfUser = 
                                this.CurrentActivity.AssignedPositionText + " " + this.CurrentActivity.AssignedUserText;

                            break;
                        }
                    }
                }
                     **/
                #endregion

                // If we are not remaining at the same level,
                // get the list of all the approvers and assign to
                // this task.
                //
                this.CurrentActivity.Users.Clear();
                this.CurrentActivity.Positions.Clear();
                this.CurrentActivity.SecretaryPositions.Clear(); // CAPITALAND

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
                        foreach (OPosition position in approvalHierarchyLevel.PositionsToBeAssigned)
                            this.CurrentActivity.Positions.Add(position);

                        // Assign the carbon-copy users
                        //
                        // Gets a list of users assigned to the workflow task,
                        // then compose a list of email recipients and sms recipients.
                        //
                        List<OUser> ccUsers = TablesLogic.tUser.LoadList(
                            TablesLogic.tUser.Positions.ObjectID.In(approvalHierarchyLevel.CarbonCopyPositions));

                        // Get a list of positions to be CC based on assigned roles.
                        //
                        List<string> ccRoleCodes = new List<string>();
                        foreach (ORole role in approvalHierarchyLevel.CarbonCopyRoles)
                            ccRoleCodes.Add(role.RoleCode);
                        List<OPosition> ccPositions = OPosition.GetPositionsByRoleCodesAndObject(this, ccRoleCodes.ToArray());

                        // add to list of users to be assigned.
                        ccUsers.AddRange(TablesLogic.tUser.LoadList
                            (TablesLogic.tUser.Positions.ObjectID.In(ccPositions)));

                        foreach (OUser user in ccUsers)
                        {
                            this.CurrentActivity.CarbonCopyUsers.Add(user);
                            carbonCopyUsers.Add(user);
                        }

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
                        {
                            this.CurrentActivity.NumberOfApprovalsRequiredAtCurrentLevel = approvalHierarchyLevel.NumberOfApprovalsRequired;

                            // we assign the secretary positions
                            //
                            foreach (OPosition position in approvalHierarchyLevel.SecretaryPositions)
                            {
                                this.CurrentActivity.Positions.Add(position);
                                this.CurrentActivity.SecretaryPositions.Add(position);
                            }

                            // Then we assign the secretary position based on the assigned secretary roles.
                            //
                            List<string> secretaryRoleCodes = new List<string>();
                            foreach (ORole role in approvalHierarchyLevel.SecretaryRoles)
                                secretaryRoleCodes.Add(role.RoleCode);
                            List<OPosition> secretaryPositions = OPosition.GetPositionsByRoleCodesAndObject(this, secretaryRoleCodes.ToArray());
                            this.CurrentActivity.Positions.AddRange(secretaryPositions);
                            this.CurrentActivity.SecretaryPositions.AddRange(secretaryPositions);
                        }
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
                NotifyAssignedRecipient(this, carbonCopyUsers);

            return isApproved;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="v"></param>
        /// <returns></returns>
        public static decimal? Round(decimal? v)
        {
            if (v == null)
                return 0.0M;
            return Round(v.Value);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="v"></param>
        /// <returns></returns>
        public static decimal Round(decimal v)
        {
            return Math.Round(v, 2, MidpointRounding.AwayFromZero);
        }
    }

}
