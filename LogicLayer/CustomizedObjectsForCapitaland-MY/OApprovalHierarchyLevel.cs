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
        public TRole SecretaryRoles { get { return ManyToMany<TRole>("ApprovalHierarchyLevelSecretaryRole", "ApprovalHierarchyID", "RoleID"); } }
        public TRole CarbonCopyRoles { get { return ManyToMany<TRole>("ApprovalHierarchyLevelCarbonCopyRole", "ApprovalHierarchyID", "RoleID"); } }
    }


    /// <summary>
    /// Represents one level in the approval hierarchy.
    /// </summary>
    public abstract partial class OApprovalHierarchyLevel : LogicLayerPersistentObject, IAuditTrailEnabled
    {
        public abstract DataList<ORole> SecretaryRoles { get; }
        public abstract DataList<ORole> CarbonCopyRoles { get; }

        /// <summary>
        /// Gets or sets a flag indicating whether
        /// or not the default approval Event defined
        /// in this approval hierarchy level should be
        /// used.
        /// </summary>
        public bool UseDefaultEvent;

        public string FinalApprovalEvent
        {
            get
            {
                if (UseDefaultEvent)
                    return null;
                else
                {
                    if (TempApprovalProcessLimit != null)
                        return TempApprovalProcessLimit.ApprovalEvent;
                }
                return null;
            }
        }

        public string SecretaryRoleNames
        {
            get
            {
                string roleNames = "";
                foreach (ORole role in this.SecretaryRoles)
                    roleNames += (roleNames == "" ? "" : ", ") + role.RoleName;
                return roleNames;
            }
        }

        public string CarbonCopyRoleNames
        {
            get
            {
                string roleNames = "";
                foreach (ORole role in this.CarbonCopyRoles)
                    roleNames += (roleNames == "" ? "" : ", ") + role.RoleName;
                return roleNames;
            }
        }

    }
}
