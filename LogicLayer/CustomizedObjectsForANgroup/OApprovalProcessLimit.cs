using System;
using System.Collections.Generic;
using System.Text;
using Anacle.DataFramework;

namespace LogicLayer
{
    /// <summary>
    /// Represents one level in the approval hierarchy.
    /// </summary>
    public partial class TApprovalProcessLimit : LogicLayerSchema<OApprovalProcessLimit>
    {
    }


    /// <summary>
    /// Represents one level in the approval hierarchy.
    /// </summary>
    public abstract partial class OApprovalProcessLimit : LogicLayerPersistentObject, IAuditTrailEnabled
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

    }
}
