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
    /// <summary>
    /// Represents one level in the approval hierarchy.
    /// </summary>
    public partial class TApprovalHierarchyLevel : LogicLayerSchema<OApprovalHierarchyLevel>
    {
        public SchemaGuid ApprovalHierarchyID;
        public SchemaInt ApprovalLevel;
        public SchemaDecimal ApprovalLimit;
        [Default(1)]
        public SchemaInt NumberOfApprovalsRequired;
        public TUser Users { get { return ManyToMany<TUser>("ApprovalHierarchyLevelUser", "ApprovalHierarchyLevelID", "UserID"); } }
        public TPosition Positions { get { return ManyToMany<TPosition>("ApprovalHierarchyLevelPosition", "ApprovalHierarchyLevelID", "PositionID"); } }
        public TRole Roles { get { return ManyToMany<TRole>("ApprovalHierarchyLevelRole", "ApprovalHierarchyLevelID", "RoleID"); } }
        public TApprovalHierarchy ApprovalHierarchy { get { return OneToOne<TApprovalHierarchy>("ApprovalHierarchyID"); } }
    }


    /// <summary>
    /// Represents one level in the approval hierarchy.
    /// </summary>
    public abstract partial class OApprovalHierarchyLevel : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the 
        /// ApprovalHierarchy table that represents that
        /// approval hierarchy under which this approval
        /// hierarchy level belongs to.
        /// </summary>
        public abstract Guid? ApprovalHierarchyID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the numeric approval
        /// level of this approval hierarchy level. 
        /// </summary>
        public abstract int? ApprovalLevel { get; set; }

        /// <summary>
        /// [Column] Gets or sets the default approval limit in
        /// the base currency for this approval level.
        /// <para></para>
        /// This approval limit can be overriden by the
        /// approval process's approval limit should the user
        /// indicate not to use the default approval limit.
        /// </summary>
        public abstract Decimal? ApprovalLimit { get; set; }

        /// <summary>
        /// [Column] Gets or sets the number of approvals
        /// required before the approval proceeds to the next
        /// level. 
        /// <para></para>
        /// This is not applicable if the mode of forwarding of
        /// the approval process that uses this approval hierarchy 
        /// is to 'All'.
        /// </summary>
        public abstract int? NumberOfApprovalsRequired { get; set; }

        /// <summary>
        /// Gets the list of users who will be the
        /// assigned approvers to the task at this
        /// level.
        /// </summary>
        public abstract DataList<OUser> Users { get; set; }

        /// <summary>
        /// Gets the list of users who will be the
        /// assigned approvers to the task at this
        /// level.
        /// </summary>
        public abstract DataList<OPosition> Positions { get; set; }

        /// <summary>
        /// Gets the list of users who will be the
        /// assigned approvers to the task at this
        /// level. This is a temporary variable that 
        /// holds the actual list of users to be assigned 
        /// to the task.
        /// </summary>
        public List<OUser> UsersToBeAssigned = new List<OUser>();

        public List<OPosition> PositionsToBeAssigned = new List<OPosition>();
        /// <summary>
        /// Gets the list of roles that will be used
        /// to determine the appropriate positions to
        /// be assigned to this task at this level.
        /// </summary>
        public abstract DataList<ORole> Roles { get; set; }

        public abstract OApprovalHierarchy ApprovalHierarchy { get; set; }

        /// <summary>
        /// Gets or sets a flag indicating whether
        /// or not the default approval limit defined
        /// in this approval hierarchy level should be
        /// used.
        /// </summary>
        public bool UseDefaultLimit;

        /// <summary>
        /// This is a temporary link to the OApprovalProcessLimit
        /// object associated with this approval hierarchy level.
        /// This link is not saved into the database, but allows the user to 
        /// update the non-default approval limits in the user interface.
        /// </summary>
        public OApprovalProcessLimit TempApprovalProcessLimit;

        /// <summary>
        /// Gets a value indicating the final approval limit.
        /// This final approval limit is taken from the
        /// TempApprovalProcessLimit.ApprovalLimit if UseDefaultLimit is false, 
        /// and taken from this object's ApprovalLimit if UseDefaultLimit is true.
        /// </summary>
        public Decimal? FinalApprovalLimit
        {
            get
            {
                if (UseDefaultLimit)
                    return this.ApprovalLimit;
                else
                {
                    if (TempApprovalProcessLimit != null)
                        return TempApprovalProcessLimit.ApprovalLimit;
                }
                return null;
            }
        }

        /// <summary>
        /// A flag that indicates whether
        /// the task will be routed to this 
        /// approval hierarchy level.
        /// </summary>
        protected bool isRouted;

        /// <summary>
        /// Gets or sets a flag that indicates whether
        /// the task will be routed to this 
        /// approval hierarchy level. This field is not
        /// a database column and will only be set by
        /// the OApprovalProcessDetail.GetApprovalHierarchyLevels
        /// method.
        /// </summary>
        public bool IsRouted
        {
            get { return isRouted; }
            set { isRouted = value; }
        }

        /// <summary>
        /// Gets a comma-separated list of user names.
        /// </summary>
        public string UserNames
        {
            get
            {
                string userNames = "";
                foreach (OUser user in this.Users)
                    userNames += (userNames == "" ? "" : ", ") + user.ObjectName;
                return userNames;
            }
        }


        /// <summary>
        /// Gets a comma-separated list of user names.
        /// </summary>
        public string UsersToBeAssignedNames
        {
            get
            {
                string userNames = "";
                foreach (OUser user in this.UsersToBeAssigned)
                    userNames += (userNames == "" ? "" : ", ") + user.ObjectName;
                return userNames;
            }
        }


        /// <summary>
        /// Gets a comma-separated list of job names.
        /// </summary>
        public string RoleNames
        {
            get
            {
                string roleNames = "";
                foreach (ORole role in this.Roles)
                    roleNames += (roleNames == "" ? "" : ", ") + role.RoleName;
                return roleNames;
            }
        }


        /*
        /// <summary>
        /// Gets a comma-separated list of job names.
        /// </summary>
        public string PositionNames
        {
            get
            {
                string positionNames = "";
                foreach (OPosition position in this.Positions)
                    positionNames += (positionNames == "" ? "" : ", ") + position.ObjectName;
                return positionNames;
            }
        }
        */

        /// <summary>
        /// Gets a comma-separated list of position names and the assigned users.
        /// </summary>
        public string PositionNamesWithUserNames
        {
            get
            {
                string positionNames = "";
                foreach (OPosition position in this.PositionsToBeAssigned)
                    positionNames += (positionNames == "" ? "" : ", ") + position.PositionNameWithUserNames;

                return positionNames;
            }
        }


        /// <summary>
        /// Validates that at least one user or one job has been specified.
        /// </summary>
        /// <returns></returns>
        public bool ValidateUserOrRoleOrPositionSpecified()
        {
            return (this.Roles.Count > 0 ||
                this.Positions.Count > 0 ||
                this.Users.Count > 0);
        }

        public bool IsDuplicate(OApprovalHierarchy approvalHierarchy, OApprovalHierarchyLevel approvalHierarchyLevel)
        {
            
            bool dupValue = false;
           
            foreach (OApprovalHierarchyLevel appHierLvl in approvalHierarchy.ApprovalHierarchyLevels)
            {
                if ((appHierLvl.ObjectID.ToString() != approvalHierarchyLevel.ObjectID.ToString()) &&
                appHierLvl.ApprovalLimit == approvalHierarchyLevel.ApprovalLimit)
                    dupValue = true;
            }

            return dupValue;

        }
        /// <summary>
        /// Checks if the specified user is an authorized user at
        /// this approval hierarchy level.
        /// </summary>
        /// <param name="user">The user to check if he/she is authorized
        /// at this level.</param>
        /// <param name="task">The task containing information about
        /// the location/equipment/type of service in order to
        /// determine the positions that can be assigned at this
        /// level.</param>
        /// <returns>Returns true if the specified user is an
        /// authorized user at this level, false otherwise.</returns>
        public bool IsAuthorizedUserAtThisLevel(OUser user, LogicLayerPersistentObject task)
        {
            if (this.Users.FindObject(user.ObjectID.Value) != null)
                return true;

            // 2010.05.18
            // Kim Foong
            // Find out if the user is assigned to any the positions 
            // at this level.
            //
            foreach (OPosition position in this.Positions)
                if (user.Positions.FindObject(position.ObjectID.Value) != null)
                    return true;

            // Gets a list of all positions that will be assigned to the
            // task at this approval level.
            //
            List<string> roleCodes = new List<string>();
            foreach (ORole role in this.Roles)
                roleCodes.Add(role.RoleCode);
            List<OPosition> positions = OPosition.GetPositionsByRoleCodesAndObject(task, roleCodes.ToArray());

            // Then, match them against the positions granted to the
            // specified user. If the user has at least one position
            // that will be assigned at this level, the user is 
            // considered an authorized user.
            //
            foreach (OPosition position in positions)
            {
                if (user.Positions.FindObject(position.ObjectID.Value) != null)
                    return true;
            }
            return false;
        }


        /// <summary>
        /// Validates that if the role is not set up for this level, that
        /// the number of users must be equal to or more than the 
        /// number of approvals required.
        /// </summary>
        /// <returns></returns>
        public bool ValidateNumberOfUsersMoreThanNumberOfApprovalsRequired()
        {
            if (this.Roles.Count > 0 || this.Positions.Count > 0)
                return true;


            if (this.Users.Count >= this.NumberOfApprovalsRequired)
                return true;

            return false;
        }


        /// <summary>
        /// Copies the list of users set up in the approval hierarchy
        /// to the temporary list.
        /// </summary>
        public void CopyUsersToUsersToBeAssigned()
        {
            this.UsersToBeAssigned.Clear();
            foreach (OUser user in this.Users)
                this.UsersToBeAssigned.Add(user);
        }


        /// <summary>
        /// Copies the list of users set up in the approval hierarchy
        /// to the temporary list.
        /// </summary>
        public void RemoveUsersToBeAssigned(Guid userId)
        {
            foreach (OUser user in this.UsersToBeAssigned)
                if (user.ObjectID == userId)
                {
                    this.UsersToBeAssigned.Remove(user);
                    break;
                }
        }

        /// <summary>
        /// Copies the list of users set up in the approval hierarchy
        /// to the temporary list.
        /// </summary>
        public void CopyPositionsToPositionsToBeAssigned()
        {
            this.PositionsToBeAssigned.Clear();
            foreach (OPosition pos in this.Positions)
                this.PositionsToBeAssigned.Add(pos);
        }


        /// <summary>
        /// Copies the list of users set up in the approval hierarchy
        /// to the temporary list.
        /// </summary>
        public void RemovePositionsToBeAssigned(Guid positionId)
        {
            foreach (OPosition position in this.PositionsToBeAssigned)
                if (position.ObjectID == positionId)
                {
                    this.PositionsToBeAssigned.Remove(position);
                    break;
                }
        }
    }
}
