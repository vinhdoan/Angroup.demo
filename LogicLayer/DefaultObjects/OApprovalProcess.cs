//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Text;
using Anacle.DataFramework;

namespace LogicLayer
{
    public partial class TApprovalProcess : LogicLayerSchema<OApprovalProcess>
    {
        public SchemaGuid LocationID;
        public SchemaGuid EquipmentID;
        public SchemaString ObjectTypeName;
        public SchemaInt ModeOfForwarding;
        [Size(255)]
        public SchemaString Description;
        [Size(1)]
        public SchemaInt UseDefaultLimits;
        public SchemaGuid ApprovalHierarchyID;
        [Size(500)]
        public SchemaString FLEECondition;

        public TApprovalHierarchy ApprovalHierarchy { get { return OneToOne<TApprovalHierarchy>("ApprovalHierarchyID"); } }
        public TApprovalProcessLimit ApprovalProcessLimits { get { return OneToMany<TApprovalProcessLimit>("ApprovalProcessID"); } }
        public TLocation Location { get { return OneToOne<TLocation>("LocationID"); } }
        public TEquipment Equipment { get { return OneToOne<TEquipment>("EquipmentID"); } }
    }


    /// <summary>
    /// Represents an approval process specific to a persistent object
    /// type and a state within its workflow. This approval process
    /// specifies approval hierarchies applicable to the persistent object
    /// depending on the location/equipment specified in the persistent
    /// object.
    /// </summary>
    public abstract partial class OApprovalProcess : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the
        /// Location table that represents the location
        /// this approval process applies to.
        /// </summary>
        public abstract Guid? LocationID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the
        /// Equipment table that represents the equipment
        /// this approval process applies to.
        /// </summary>
        public abstract Guid? EquipmentID { get; set; }


        /// <summary>
        /// [Column] Gets or sets the type name of the persistent
        /// object that this approval process applies to. 
        /// </summary>
        public abstract string ObjectTypeName { get; set; }


        /// <summary>
        /// [Column] Gets or sets the Foreign key to the ApprovalProcess table.
        /// </summary>
        public abstract Guid? ApprovalProcessID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the mode of forwarding for the approval
        /// process at this location/equipment.
        /// <para></para>
        /// The mode of forwarding determines how the object will be
        /// assigned to the users/roles in the approval hierarchy.
        /// </summary>
        public abstract int? ModeOfForwarding { get; set; }

        /// <summary>
        /// [Column] Gets or sets the description of
        /// this approval process detail.
        /// </summary>
        public abstract string Description { get; set; }

        /// <summary>
        /// [Column] Gets or sets a flag indicating whether
        /// the default approval limits set in the approval
        /// hierarchy should be used.
        /// </summary>
        public abstract int? UseDefaultLimits { get; set; }

        /// <summary>
        /// [Column] Gets or sets the Foreign key to the ApprovalHierarchy table.
        /// This is compulsory when the ModeOfApproval = 1
        /// </summary>
        public abstract Guid? ApprovalHierarchyID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the Fast Lightweight Expression Evaluator
        /// condition that returns a flag indicating whether this approval process 
        /// is applicable to the object.
        /// </summary>
        public abstract string FLEECondition { get; set; }

        /// <summary>
        /// Gets or sets the OApprovalHierarchy object representing
        /// the hierarchy of users/roles and their approval limits
        /// that will be used for approving objects.
        /// </summary>
        public abstract OApprovalHierarchy ApprovalHierarchy { get; set; }


        /// <summary>
        /// Gets a reference to a list of OApprovalHierarchy objects 
        /// representing the approval limits applicable to this
        /// approval process.
        /// </summary>
        public abstract DataList<OApprovalProcessLimit> ApprovalProcessLimits { get; }


        /// <summary>
        /// Gets or sets the OLocation object representing the
        /// location to which this approval process applies.
        /// </summary>
        public abstract OLocation Location { get; set; }


        /// <summary>
        /// Gets or sets the OEquipment object representing the
        /// equipment to which this approval process applies.
        /// </summary>
        public abstract OEquipment Equipment { get; set; }


        /// <summary>
        /// Gets the text representing the mode of approval.
        /// </summary>
        public string ModeOfForwardingText
        {
            get
            {
                if (ModeOfForwarding == ApprovalModeOfForwarding.None)
                    return Resources.Strings.ModeOfForwarding_None;
                else if (ModeOfForwarding == ApprovalModeOfForwarding.Direct)
                    return Resources.Strings.ModeOfForwarding_Direct;
                else if (ModeOfForwarding == ApprovalModeOfForwarding.Hierarchical)
                    return Resources.Strings.ModeOfForwarding_Hierarchical;
                else if (ModeOfForwarding == ApprovalModeOfForwarding.HierarchicalWithLastRejectedSkipping)
                    return Resources.Strings.ModeOfForwarding_HierarchicalWithLastRejectedSkipping;
                else if (ModeOfForwarding == ApprovalModeOfForwarding.HierarchicalWithRequestorAndLastRejectedSkipping)
                    return Resources.Strings.ModeOfForwarding_HierarchicalWithLastRejectedAndNextRequiredApprovalSkipping;
                else if (ModeOfForwarding == ApprovalModeOfForwarding.All)
                    return Resources.Strings.ModeOfForwarding_All;
                return "";
            }
        }


        /// <summary>
        /// Disallow deleting if:
        /// <para></para>
        /// 1. 
        /// </summary>
        /// <returns></returns>
        public override bool IsDeactivatable()
        {
            if ((int)TablesLogic.tActivity.Select(
                TablesLogic.tActivity.ObjectID.Count())
                .Where(
                TablesLogic.tActivity.IsDeleted == 0 &
                TablesLogic.tActivity.ApprovalProcessID == this.ObjectID) > 0)
                return false;

            return true;
        }


        /// <summary>
        /// Returns a list of all active approval processes in the system.
        /// </summary>
        /// <returns></returns>
        public static List<OApprovalProcess> GetAllApprovalProcesses()
        {
            return TablesLogic.tApprovalProcess[TablesLogic.tApprovalProcess.IsDeleted == 0];
        }

        

        /// <summary>
        /// Gets a list of approval process details object by the
        /// specified approval process code and applicable to the 
        /// persistent object.
        /// </summary>
        /// <param name="logicLayerPersistentObject"></param>
        /// <returns></returns>
        public static List<OApprovalProcess> GetApprovalProcesses_original(
            LogicLayerPersistentObject logicLayerPersistentObject)
        {
            List<OLocation> taskLocations = logicLayerPersistentObject.TaskLocations;
            List<OEquipment> taskEquipments = logicLayerPersistentObject.TaskEquipments;

            // Construct the condition to look for the approval process
            // detail that covers all locations/equipment of the task.
            //
            TApprovalProcess d1 = new TApprovalProcess();

            ExpressionCondition conditionLocation = Query.True;
            if (taskLocations != null)
                foreach (OLocation taskLocation in taskLocations)
                    if (taskLocation != null)
                        conditionLocation &= TablesLogic.tApprovalProcess.ObjectID.In(d1.Select(d1.ObjectID).Where(taskLocation.HierarchyPath.Like(d1.Location.HierarchyPath + "%")));

            ExpressionCondition conditionEquipment = Query.True;
            if (taskEquipments != null)
                foreach (OEquipment taskEquipment in taskEquipments)
                    if (taskEquipment != null)
                        conditionEquipment &= TablesLogic.tApprovalProcess.ObjectID.In(d1.Select(d1.ObjectID).Where(taskEquipment.HierarchyPath.Like(d1.Equipment.HierarchyPath + "%")));

            // query and returns the result.
            //
            Guid? transactionTypeGroupId = null;
            Guid? transactionTypeId = null;

            if (logicLayerPersistentObject is OPurchaseRequest)
            {
                return TablesLogic.tApprovalProcess.LoadList(
                    TablesLogic.tApprovalProcess.ObjectTypeName == logicLayerPersistentObject.GetType().BaseType.Name &
                    (TablesLogic.tApprovalProcess.AppliesToAllTransactionTypes == 1 |
                    TablesLogic.tApprovalProcess.TransactionTypes.ObjectID == ((OPurchaseRequest)logicLayerPersistentObject).PurchaseTypeID) &
                    conditionLocation &
                    conditionEquipment,
                    TablesLogic.tApprovalProcess.Location.HierarchyPath.Length().Desc,
                    TablesLogic.tApprovalProcess.Equipment.HierarchyPath.Length().Desc
                    );
            }
            else if (logicLayerPersistentObject is ORequestForQuotation)
            {
                return TablesLogic.tApprovalProcess.LoadList(
                    TablesLogic.tApprovalProcess.ObjectTypeName == logicLayerPersistentObject.GetType().BaseType.Name &
                    (TablesLogic.tApprovalProcess.AppliesToAllTransactionTypes == 1 |
                    TablesLogic.tApprovalProcess.TransactionTypes.ObjectID == ((ORequestForQuotation)logicLayerPersistentObject).PurchaseTypeID) &
                    conditionLocation &
                    conditionEquipment,
                    TablesLogic.tApprovalProcess.Location.HierarchyPath.Length().Desc,
                    TablesLogic.tApprovalProcess.Equipment.HierarchyPath.Length().Desc
                    );
            }
            else if (logicLayerPersistentObject is OPurchaseOrder)
            {
                return TablesLogic.tApprovalProcess.LoadList(
                    TablesLogic.tApprovalProcess.ObjectTypeName == logicLayerPersistentObject.GetType().BaseType.Name &
                    (TablesLogic.tApprovalProcess.AppliesToAllTransactionTypes == 1 |
                    TablesLogic.tApprovalProcess.TransactionTypes.ObjectID == ((OPurchaseOrder)logicLayerPersistentObject).PurchaseTypeID) &
                    conditionLocation &
                    conditionEquipment,
                    TablesLogic.tApprovalProcess.Location.HierarchyPath.Length().Desc,
                    TablesLogic.tApprovalProcess.Equipment.HierarchyPath.Length().Desc
                    );
            }

            return TablesLogic.tApprovalProcess.LoadList(
                TablesLogic.tApprovalProcess.ObjectTypeName == logicLayerPersistentObject.GetType().BaseType.Name &
                conditionLocation &
                conditionEquipment,
                TablesLogic.tApprovalProcess.Location.HierarchyPath.Length().Desc,
                TablesLogic.tApprovalProcess.Equipment.HierarchyPath.Length().Desc
                );
        }


        /// <summary>
        /// Gets the approval hierarclies applicable to the specified
        /// persistent object. This table shows
        /// the list of approvers that the task represented by
        /// the persistent object will be routed to. 
        /// </summary>
        /// <param name="logicLayerPersistentObject"></param>
        /// <returns>
        /// 0 - Approval is required.
        /// 1 - This task will be approved by this user.
        /// 2 - There is no approval required (only for when 
        /// forwarding mode = None)
        /// 3 - Approval is required, but no approver is found.
        /// </returns>
        public int GetApprovalHierarchyLevels(
            LogicLayerPersistentObjectBase logicLayerPersistentObject,
            List<OApprovalHierarchyLevel> nextApprovalHierarchyLevels,
            out int? nextApprovalLevel)
        {
            bool thisLevelIsApproved = false;
            int? numberOfApprovalsAtCurrentLevel = logicLayerPersistentObject.CurrentActivity.NumberOfApprovalsAtCurrentLevel;

            // Copies the list of users to be assigned.
            //
            if (this.ModeOfForwarding != ApprovalModeOfForwarding.None)
                foreach (OApprovalHierarchyLevel approvalHierarchyLevel in this.ApprovalHierarchy.ApprovalHierarchyLevels)
                {
                    approvalHierarchyLevel.CopyUsersToUsersToBeAssigned();
                    approvalHierarchyLevel.CopyPositionsToPositionsToBeAssigned();
                }

            // Increment the total number of users who approved.
            //
            if (Workflow.CurrentUser != null &&
                logicLayerPersistentObject.CurrentActivity.CurrentApprovalLevel != null &&
                logicLayerPersistentObject.CurrentActivity.ApprovedUsers.FindObject(Workflow.CurrentUser.ObjectID.Value) == null)
            {
                
                if (numberOfApprovalsAtCurrentLevel == null)
                    numberOfApprovalsAtCurrentLevel = 1;
                else
                    numberOfApprovalsAtCurrentLevel = numberOfApprovalsAtCurrentLevel + 1;
            }

            // Checks if the current level is fully approved.
            //
            if (logicLayerPersistentObject.CurrentActivity.NumberOfApprovalsRequiredAtCurrentLevel == null ||
                numberOfApprovalsAtCurrentLevel >= logicLayerPersistentObject.CurrentActivity.NumberOfApprovalsRequiredAtCurrentLevel)
                thisLevelIsApproved = true;

            // Copies the approval limits.
            //
            this.LinkApprovalProcessLimits();

            nextApprovalLevel = null;

            if (this.ModeOfForwarding == ApprovalModeOfForwarding.None)
            {
                // No approval required.
                //
                return ApprovalResult.NoApprovalRequired;
            }
            else if (this.ModeOfForwarding == ApprovalModeOfForwarding.Direct)
            {
                // Direct forwarding mode.
                //
                OApprovalHierarchyLevel approvalHierarchyLevel =
                    this.ApprovalHierarchy.FindApprovalHierarchyLevelByAmount(logicLayerPersistentObject.TaskAmount);

                if (approvalHierarchyLevel != null)
                {
                    approvalHierarchyLevel.IsRouted = true;
                    if (approvalHierarchyLevel.IsAuthorizedUserAtThisLevel(Workflow.CurrentUser, this) &&
                        thisLevelIsApproved)
                        return ApprovalResult.Approved;
                    else
                    {
                        // Remove users that are not required
                        //
                        if (!thisLevelIsApproved)
                        {
                            foreach (OUser approvedUser in logicLayerPersistentObject.CurrentActivity.ApprovedUsers)
                                approvalHierarchyLevel.RemoveUsersToBeAssigned(approvedUser.ObjectID.Value);
                            if (Workflow.CurrentUser != null)
                                approvalHierarchyLevel.RemoveUsersToBeAssigned(Workflow.CurrentUser.ObjectID.Value);
                        }

                        nextApprovalLevel = approvalHierarchyLevel.ApprovalLevel.Value;
                        nextApprovalHierarchyLevels.Add(approvalHierarchyLevel);
                    }
                }
            }
            else if (this.ModeOfForwarding == ApprovalModeOfForwarding.Hierarchical ||
                this.ModeOfForwarding == ApprovalModeOfForwarding.HierarchicalWithLastRejectedSkipping ||
                this.ModeOfForwarding == ApprovalModeOfForwarding.HierarchicalWithRequestorAndLastRejectedSkipping)
            {
                if (logicLayerPersistentObject.CurrentActivity.CurrentApprovalLevel != null)
                    nextApprovalLevel = logicLayerPersistentObject.CurrentActivity.CurrentApprovalLevel;
                else
                {
                    // This implements the skipping of the approval level
                    // when the task is first submitted for approval.
                    //
                    if (this.ModeOfForwarding == ApprovalModeOfForwarding.Hierarchical)
                        nextApprovalLevel = 1;
                    else if (this.ModeOfForwarding == ApprovalModeOfForwarding.HierarchicalWithLastRejectedSkipping)
                    {
                        if (logicLayerPersistentObject.CurrentActivity.LastApprovalLevel != null &&
                            logicLayerPersistentObject.CurrentActivity.SkipToLastRejectedLevel == 1)
                            nextApprovalLevel = logicLayerPersistentObject.CurrentActivity.LastApprovalLevel;
                        else
                            nextApprovalLevel = 1;
                    }
                    else if (this.ModeOfForwarding == ApprovalModeOfForwarding.HierarchicalWithRequestorAndLastRejectedSkipping)
                    {
                        if (logicLayerPersistentObject.CurrentActivity.LastApprovalLevel != null &&
                            logicLayerPersistentObject.CurrentActivity.SkipToLastRejectedLevel == 1)
                            nextApprovalLevel = logicLayerPersistentObject.CurrentActivity.LastApprovalLevel;
                        else if (logicLayerPersistentObject.CurrentActivity.NextApprovalLevel != null &&
                            logicLayerPersistentObject.CurrentActivity.SkipToNextRequiredApprovalLevel == 1)
                            nextApprovalLevel = logicLayerPersistentObject.CurrentActivity.NextApprovalLevel;
                        else
                            nextApprovalLevel = 1;
                    }
                }

                if (logicLayerPersistentObject.CurrentActivity.CurrentApprovalLevel != null)
                {
                    // Checks if the current approval hierarchy level's
                    // approval limit exceeds the task amount. If it does
                    // this means we have already reached the first 
                    // user/role with sufficient authority to approve the
                    // task, so we set the isApproved flag to true. 
                    // Otherwise, increase the approval level.
                    // 
                    OApprovalHierarchyLevel currentHierarchyLevel =
                        this.ApprovalHierarchy.FindApprovalHierarchyLevelByLevel(
                        (int)logicLayerPersistentObject.CurrentActivity.CurrentApprovalLevel);

                    OApprovalHierarchyLevel nextHierarchyLevel =
                        this.ApprovalHierarchy.FindNextApprovalHierarchyLevelWithApprovalLimitAfterLevel(
                        (int)logicLayerPersistentObject.CurrentActivity.CurrentApprovalLevel);

                    OApprovalHierarchyLevel nextRequiredHierarchyLevel =
                        this.ApprovalHierarchy.FindNextRequiredApprovalHierarchyLevelAfterLevel(
                        (int)logicLayerPersistentObject.CurrentActivity.CurrentApprovalLevel);

                    if (thisLevelIsApproved)
                    {
                        if (currentHierarchyLevel.FinalApprovalLimit >= logicLayerPersistentObject.TaskAmount)
                        {
                            // If there are no more levels, then this level must be the last level.
                            // so consider it approved.
                            //
                            if (nextHierarchyLevel == null)
                                return ApprovalResult.Approved;

                            // If there are more levels above, this, we must make sure that the 
                            // next level's approval limit is not equals to this current level's limit,
                            // otherwise we will still have to route to the next level for approval.
                            //
                            if (nextHierarchyLevel.FinalApprovalLimit != currentHierarchyLevel.FinalApprovalLimit)
                            {
                                if (nextRequiredHierarchyLevel == null)
                                    return ApprovalResult.Approved;

                                nextHierarchyLevel = nextRequiredHierarchyLevel;
                            }
                        }
                        nextApprovalLevel = nextHierarchyLevel.ApprovalLevel.Value;
                    }
                }

                // Once we have the next approval level, load
                // the next approval level. 
                //
                nextApprovalHierarchyLevels.AddRange(
                    this.ApprovalHierarchy.FindApprovalHierarchyLevelsAboveApprovalLevelAndByAmount(
                    nextApprovalLevel.Value,
                    logicLayerPersistentObject.TaskAmount));

                // 2012.01.31, Kien Trung
                // After we load the next approval level, find
                // actual next approval level.
                //
                if (nextApprovalHierarchyLevels.Count > 0)
                    nextApprovalLevel = nextApprovalHierarchyLevels[0].ApprovalLevel;
                
                // Remove users that are not required
                //
                if (!thisLevelIsApproved)
                {
                    foreach (OUser approvedUser in logicLayerPersistentObject.CurrentActivity.ApprovedUsers)
                        nextApprovalHierarchyLevels[0].RemoveUsersToBeAssigned(approvedUser.ObjectID.Value);
                    if (Workflow.CurrentUser != null)
                        nextApprovalHierarchyLevels[0].RemoveUsersToBeAssigned(Workflow.CurrentUser.ObjectID.Value);

                    // This to remove approved position in the same level.
                    foreach (OPosition approvedPosition in logicLayerPersistentObject.CurrentActivity.ApprovedPositions)
                        nextApprovalHierarchyLevels[0].RemovePositionsToBeAssigned(approvedPosition.ObjectID.Value);
                }

                if (nextApprovalHierarchyLevels.Count > 0)
                    nextApprovalHierarchyLevels[0].IsRouted = true;
            }
            else if (this.ModeOfForwarding == ApprovalModeOfForwarding.All)
            {
                nextApprovalLevel = 1;

                // All forwarding mode.
                //
                // Assign the task to the users/roles from the next
                // approval hierarchy level all the way up to the
                // users/roles authorized to approve the task.
                //
                OUser currentUser = Workflow.CurrentUser;

                if (logicLayerPersistentObject.CurrentActivity.CurrentApprovalLevel != null)
                {
                    List<OApprovalHierarchyLevel> currentApprovalHierarchyLevels =
                        this.ApprovalHierarchy.FindApprovalHierarchyLevelsAboveApprovalLevelAndByAmount(
                        (int)logicLayerPersistentObject.CurrentActivity.CurrentApprovalLevel,
                        logicLayerPersistentObject.TaskAmount);

                    nextApprovalLevel = (int)logicLayerPersistentObject.CurrentActivity.CurrentApprovalLevel;

                    // Look for the highest approval hierarchy level 
                    // that the current logged on user is considered authorized.
                    //
                    bool found = false;
                    for (int i = currentApprovalHierarchyLevels.Count - 1; i >= 0; i--)
                    {
                        if (currentApprovalHierarchyLevels[i].IsAuthorizedUserAtThisLevel(Workflow.CurrentUser, this))
                        {
                            if (i == currentApprovalHierarchyLevels.Count - 1)
                                // If the user is authorized at the topmost 
                                // approval level, then the task is considered
                                // approved.
                                return ApprovalResult.Approved;
                            else
                                nextApprovalLevel += i + 1;
                            found = true;
                            break;
                        }
                    }
                    if (!found)
                    {
                        throw new Exception(Resources.Errors.Workflow_UnauthorizedApproverException);
                    }
                }

                nextApprovalHierarchyLevels.AddRange(
                    this.ApprovalHierarchy.FindApprovalHierarchyLevelsAboveApprovalLevelAndByAmount(
                    nextApprovalLevel.Value, logicLayerPersistentObject.TaskAmount));
                foreach (OApprovalHierarchyLevel approvalHierarchyLevel in nextApprovalHierarchyLevels)
                    approvalHierarchyLevel.IsRouted = true;
            }

            if (nextApprovalHierarchyLevels.Count == 0)
                return ApprovalResult.NoApproversFound;
            else
                return ApprovalResult.ApprovalRequired;
        }


        /// <summary>
        /// Links the notification process timings to the notification
        /// hierarchy levels.
        /// </summary>
        public void LinkApprovalProcessLimits()
        {
            if (this.ApprovalHierarchy != null)
            {
                foreach (OApprovalHierarchyLevel approvalHierarchyLevel in
                    this.ApprovalHierarchy.ApprovalHierarchyLevels)
                {
                    approvalHierarchyLevel.UseDefaultLimit = this.UseDefaultLimits == 1;
                    approvalHierarchyLevel.UseDefaultEvent = this.UseDefaultEvents == 1;
                    // look for the notification process timing
                    // with the same notification level.
                    //
                    OApprovalProcessLimit limit = this.ApprovalProcessLimits.Find(p => p.ApprovalLevel == approvalHierarchyLevel.ApprovalLevel);
                    if (limit == null)
                    {
                        limit = TablesLogic.tApprovalProcessLimit.Create();
                        limit.ApprovalLevel = approvalHierarchyLevel.ApprovalLevel;
                        this.ApprovalProcessLimits.Add(limit);
                    }
                    approvalHierarchyLevel.TempApprovalProcessLimit = limit;
                }
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="AppProcess"></param>
        /// <returns></returns>
        public bool CheckApprovalLimitValue(OApprovalProcess AppProcess)
        {
            bool withinRange = true;
           
            List<OApprovalProcessLimit> limits = new List<OApprovalProcessLimit>();

            foreach (OApprovalProcessLimit limit in this.ApprovalProcessLimits)
            {
                if (limit.ApprovalLimit != null && (limit.ApprovalProcessID.ToString().Equals(AppProcess.ObjectID.ToString())))
                {
                    if (limit.ApprovalLimit.Value<=0)
                    {
                        withinRange = false;
                    }
                   
                }
                
            }

            return withinRange;
        }


        //public bool ValidateNonDefaultApprovalProcessLimits()
        //{
        //    if (this.UseDefaultLimits == 0)
        //    {
        //        List<OApprovalProcessLimit> limits = new List<OApprovalProcessLimit>();
        //        foreach (OApprovalProcessLimit limit in this.ApprovalProcessLimits)
        //            limits.Add(limit);
        //        limits.Sort("ApprovalLevel ASC");

        //        for (int i = 0; i < limits.Count - 1; i++)
        //        {
        //            if (limits[i].ApprovalLimit != null &&
        //                limits[i + 1].ApprovalLimit != null &&
        //                limits[i].ApprovalLimit >= limits[i + 1].ApprovalLimit)
        //                return false;
        //        }
        //    }
        //    return true;
        //}

    }


    /// <summary>
    /// Enumerates the different modes of approval forwarding.
    /// </summary>
    public class ApprovalModeOfForwarding
    {
        /// <summary>
        /// This indicates that the task will not be forwarded
        /// to any user/role and will be considered approved.
        /// </summary>
        public const int None = 0;

        /// <summary>
        /// This indicates that the task will be forwarded to
        /// the first user/role authorized to approve this
        /// task based on its amount.
        /// </summary>
        public const int Direct = 1;

        /// <summary>
        /// This indicates that the task will be forwarded
        /// in a hierarchical manner from the first user/role
        /// in the approval hierarchy to the first user/role
        /// authorized to approve the task. Each assigned
        /// approver must approve the task before the next
        /// approver will be assigned the task for approval.
        /// </summary>
        public const int Hierarchical = 2;

        /// <summary>
        /// This indicates that the task will be forwarded
        /// in a hierarchical manner from the first user/role
        /// in the approval hierarchy to the first user/role
        /// authorized to approve the task. Each assigned
        /// approver must approve the task before the next
        /// approver will be assigned the task for approval.
        /// <para></para>
        /// However, if the task is rejected and resubmitted
        /// for approval, it starts off at the level that
        /// was rejected.
        /// </summary>
        public const int HierarchicalWithLastRejectedSkipping = 4;

        public const int HierarchicalWithRequestorAndLastRejectedSkipping = 5;

        /// <summary>
        /// This indicates that the task will be forwarded
        /// to the users/roles from the first in the hierarchy
        /// to the first authorized to approve the task all at
        /// once. When an assigned user approves the task, 
        /// it will be assigned to the all persons/roles from
        /// the next level to the first authorized to approve
        /// the task.
        /// </summary>
        public const int All = 3;
    }



    /// <summary>
    /// Enumerates a list of approval results returned
    /// by the OApprovalProcessDetail.GetApprovalHierarchyLevels.
    /// </summary>
    public class ApprovalResult
    {
        /// <summary>
        /// Indicates that approval is required, and the
        /// results returned contains the list of the
        /// approval hierarchy levels.
        /// </summary>
        public const int ApprovalRequired = 0;

        /// <summary>
        /// Indicates that the task will be approved
        /// by the current user.
        /// </summary>
        public const int Approved = 1;

        /// <summary>
        /// Indicates that the task does not require
        /// any approval.
        /// </summary>
        public const int NoApprovalRequired = 2;

        /// <summary>
        /// Indicates that the task requires approval,
        /// but no appropriate approvers are found configured
        /// in the approval process.
        /// </summary>
        public const int NoApproversFound = 3;

        /// <summary>
        /// Indicated that the task requires approval,
        /// but the person is not authorized.
        /// </summary>
        public const int UnableToSubmit = 4;

        /// <summary>
        /// Indicates the task cannot be approved
        /// By the person due to the task has been approved by him/her
        /// </summary>
        public const int UnableToApprove = 5;
    }


    /// <summary>
    /// Declares some special approval limits with special meaning.
    /// </summary>
    public class ApprovalLimit
    {
        public static decimal RequiredApprovalLimit = 999999999999;       // There 12 9s
    }
}
