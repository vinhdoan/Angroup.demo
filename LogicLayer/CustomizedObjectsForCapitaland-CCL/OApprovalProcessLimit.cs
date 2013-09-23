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
        public SchemaString ApprovalEvent;
    }


    /// <summary>
    /// Represents one level in the approval hierarchy.
    /// </summary>
    public abstract partial class OApprovalProcessLimit : LogicLayerPersistentObject
    {
        public abstract string ApprovalEvent { get; set; }

    }
}
