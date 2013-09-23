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
    public partial class TApprovalProcessLimit : LogicLayerSchema<OApprovalProcessLimit>
    {
        public SchemaGuid ApprovalProcessID;
        public SchemaInt ApprovalLevel;
        public SchemaDecimal ApprovalLimit;
    }


    /// <summary>
    /// Represents one level in the approval hierarchy.
    /// </summary>
    public abstract partial class OApprovalProcessLimit : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the 
        /// ApprovalHierarchy table that represents that
        /// approval hierarchy under which this approval
        /// hierarchy level belongs to.
        /// </summary>
        public abstract Guid? ApprovalProcessID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the numeric approval
        /// level of this approval hierarchy level. 
        /// </summary>
        public abstract int? ApprovalLevel { get; set; }

        /// <summary>
        /// [Column] Gets or sets the approval limit in
        /// the base currency.
        /// <para></para>
        /// This approval limit overrides the default
        /// approval limit in the approval hierarchy level,
        /// if the user indicates not to use the default
        /// approval limit in the approval process.
        /// </summary>
        public abstract Decimal? ApprovalLimit { get; set; }

    }
}
