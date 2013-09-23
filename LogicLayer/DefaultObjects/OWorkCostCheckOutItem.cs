//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using Anacle.DataFramework;

namespace LogicLayer
{
    /// <summary>
    /// </summary>
    [Database("#database"), Map("WorkCostCheckOutItem")]
    public partial class TWorkCostCheckOutItem : LogicLayerSchema<OWorkCostCheckOutItem>
    {
        public SchemaGuid WorkCostID;
        public SchemaGuid StoreBinItemID;
        public SchemaDecimal UnitPrice;
        public SchemaDecimal Quantity;

        public TWorkCost WorkCost { get { return OneToOne<TWorkCost>("WorkCostID"); } }
        public TStoreBinItem StoreBinItem { get { return OneToOne<TStoreBinItem>("StoreBinItemID"); } }
    }


    /// <summary>
    /// Represents a record that will be generated automatically
    /// when the work successfully checks out an item from
    /// the store. 
    /// </summary>
    public abstract partial class OWorkCostCheckOutItem : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the WorkCost table 
        /// that indicates the cost item that this record is
        /// generated from. This record can only be generated from a 
        /// work cost whose CostType = 3 (material).
        /// </summary>
        public abstract Guid? WorkCostID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the StoreBinItem table 
        /// that indicates the batch the material was checked out from.
        /// </summary>
        public abstract Guid? StoreBinItemID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the unit price of the material.
        /// </summary>
        public abstract Decimal? UnitPrice { get; set; }

        /// <summary>
        /// [Column] Gets or sets the quantity of material that
        /// was checked out from the store.
        /// </summary>
        public abstract Decimal? Quantity { get; set; }

        /// <summary>
        /// Gets or sets the OWorkCost object that represents the cost 
        /// item that this record is generated from. This 
        /// record can only be generated from a 
        /// work cost whose CostType = 3 (material).
        /// </summary>
        public abstract OWorkCost WorkCost { get; set; }

        /// <summary>
        /// Gets or sets the O object that represents 
        /// the batch the material was checked out from.
        /// </summary>
        public abstract OStoreBinItem StoreBinItem { get; set; }

    }
}
