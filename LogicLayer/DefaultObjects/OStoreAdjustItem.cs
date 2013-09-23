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
    [Database("#database"), Map("StoreAdjustItem")]
    [Serializable] public partial class TStoreAdjustItem : LogicLayerSchema<OStoreAdjustItem>
    {
        public SchemaGuid StoreAdjustID;
        public SchemaGuid CatalogueID;
        public SchemaGuid StoreBinID;
        public SchemaGuid StoreBinItemID;
        public SchemaInt AdjustUp;
        public SchemaDecimal Quantity;

        public TStoreAdjust StoreAdjust { get { return OneToOne<TStoreAdjust>("StoreAdjustID"); } }
        public TCatalogue Catalogue { get { return OneToOne<TCatalogue>("CatalogueID"); } }
        public TStoreBin StoreBin { get { return OneToOne<TStoreBin>("StoreBinID"); } }
        public TStoreBinItem StoreBinItem { get { return OneToOne<TStoreBinItem>("StoreBinItemID"); } }
    }


    /// <summary>
    /// Represents the record containing information about the 
    /// item to be adjusted.
    /// </summary>
    [Serializable] public abstract partial class OStoreAdjustItem : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the StoreAdjust table
        /// that indicates the adjustment object that contains this 
        /// item record.
        /// </summary>
        public abstract Guid? StoreAdjustID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the ? table.
        /// that indicates the catalogue of the item to adjust.
        /// </summary>
        public abstract Guid? CatalogueID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the ? table 
        /// that indicates the store bin that contains the item
        /// to adjust.
        /// </summary>
        public abstract Guid? StoreBinID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the StoreBinItem table 
        /// that indicates the item batch to adjust.
        /// </summary>
        public abstract Guid? StoreBinItemID { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value that indicates whether 
        /// the adjustment is upwards or downwards.
        /// </summary>
        public abstract int? AdjustUp { get; set; }

        /// <summary>
        /// [Column] Gets or sets the quantity (in the base unit)
        /// to adjust. This value is always be positive, and the
        /// actual quantity to adjust depends on the AdjustUp value.
        /// </summary>
        public abstract Decimal? Quantity { get; set; }

        public bool Valid = true;

        /// <summary>
        /// Gets or sets the OStoreAdjust object that represents
        /// the adjustment object that contains this 
        /// item record.
        /// </summary>
        public abstract OStoreAdjust StoreAdjust { get; set; }

        /// <summary>
        /// Gets or sets the OCatalogue object that represents
        /// the catalogue of the item to adjust.
        /// </summary>
        public abstract OCatalogue Catalogue { get; set; }

        /// <summary>
        /// Gets or sets the OStoreBin object that represents
        /// the store bin that contains the item
        /// to adjust.
        /// </summary>
        public abstract OStoreBin StoreBin { get; set; }

        /// <summary>
        /// Gets or sets the OStoreBinItem object that represents
        /// the item batch to adjust.
        /// </summary>
        public abstract OStoreBinItem StoreBinItem { get; set; }


        /// <summary>
        /// Gets the sub-total as the unit price multiplied
        /// by the quantity.
        /// </summary>
        public decimal? SubTotal
        {
            get
            {
                return this.StoreBinItem.UnitPrice * this.Quantity;
            }
        }


        /// <summary>
        /// Gets the string text of the adjustment direction.
        /// </summary>
        public string AdjustText
        {
            get
            {
                if (AdjustUp == 0)
                    return Resources.Strings.StoreAdjustItem_Down;
                else
                    return Resources.Strings.StoreAdjustItem_Up;
            }
        }
    }
}