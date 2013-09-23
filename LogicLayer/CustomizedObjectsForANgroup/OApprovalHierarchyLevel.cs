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
        public TPosition CarbonCopyPositions { get { return ManyToMany<TPosition>("ApprovalHierarchyLevelCarbonCopyPosition", "ApprovalHierarchyLevelID", "PositionID"); } }
        public TPosition SecretaryPositions { get { return ManyToMany<TPosition>("ApprovalHierarchyLevelSecretaryPosition", "ApprovalHierarchyLevelID", "PositionID"); } }
    }


    /// <summary>
    /// Represents one level in the approval hierarchy.
    /// </summary>
    public abstract partial class OApprovalHierarchyLevel : LogicLayerPersistentObject, IAuditTrailEnabled
    {
        /// <summary>
        /// Returns a string indicating a summarized description of
        /// this object that is to appear in the audit trail.
        /// </summary>
        public override string AuditObjectDescription
        {
            get
            {
                if (this.ApprovalLevel != null)
                    return this.ApprovalLevel.ToString();
                return "";
            }
        }


        /// <summary>
        /// Gets the list of users who will be the
        /// assigned approvers to the task at this
        /// level.
        /// </summary>
        public abstract DataList<OPosition> CarbonCopyPositions { get; set; }


        /// <summary>
        /// Gets the list of users who will be the
        /// assigned approvers to the task at this
        /// level.
        /// </summary>
        public abstract DataList<OPosition> SecretaryPositions { get; set; }


        /*
        /// <summary>
        /// Gets a comma-separated list of user names.
        /// </summary>
        public string CarbonCopyUserNames
        {
            get
            {
                string userNames = "";
                foreach (OUser user in this.CarbonCopyUsers)
                    userNames += (userNames == "" ? "" : ", ") + user.ObjectName;
                return userNames;
            }
        }


        /// <summary>
        /// Gets a comma-separated list of user names.
        /// </summary>
        public string SecretaryUserNames
        {
            get
            {
                string userNames = "";
                foreach (OUser user in this.SecretaryUsers)
                    userNames += (userNames == "" ? "" : ", ") + user.ObjectName;
                return userNames;
            }
        }
        */


        /// <summary>
        /// Gets a comma-separated list of job names.
        /// </summary>
        public string PositionNames
        {
            get
            {
                string positionNames = "";
                foreach (OPosition position in this.Positions)
                    positionNames += (positionNames == "" ? "" : ", ") + position.PositionNameWithUserNames;
                return positionNames;
            }
        }


        /// <summary>
        /// Gets a comma-separated list of user names.
        /// </summary>
        public string CarbonCopyPositionNames
        {
            get
            {
                string positionNames = "";
                foreach (OPosition position in this.CarbonCopyPositions)
                    positionNames += (positionNames == "" ? "" : ", ") + position.PositionNameWithUserNames;
                return positionNames;
            }
        }


        /// <summary>
        /// Gets a comma-separated list of user names.
        /// </summary>
        public string SecretaryPositionNames
        {
            get
            {
                string positionNames = "";
                foreach (OPosition position in this.SecretaryPositions)
                    positionNames += (positionNames == "" ? "" : ", ") + position.PositionNameWithUserNames;
                return positionNames;
            }
        }


    }
}
