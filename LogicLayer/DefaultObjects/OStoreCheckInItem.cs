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
    /// Summary description for OStoreItem
    /// </summary>
    [Database("#database"), Map("StoreCheckInItem")]
    [Serializable] 
    public partial class TStoreCheckInItem : LogicLayerSchema<OStoreCheckInItem>
    {
        public SchemaGuid StoreCheckInID;
        public SchemaGuid CatalogueID;
        public SchemaGuid StoreBinID;
        public SchemaDecimal UnitPrice;
        public SchemaDecimal Quantity;
        public SchemaDateTime ExpiryDate;
        public SchemaString LotNumber;

        public TStoreCheckIn StoreCheckIn { get { return OneToOne<TStoreCheckIn>("StoreCheckInID"); } }
        public TCatalogue Catalogue { get { return OneToOne<TCatalogue>("CatalogueID"); } }
        public TStoreBin StoreBin { get { return OneToOne<TStoreBin>("StoreBinID"); } }
    }


    /// <summary>
    /// Represents the record containing information about the 
    /// item to be checked in.
    /// </summary>
    [Serializable]
    public abstract partial class OStoreCheckInItem : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the StoreCheckIn table
        /// that indicates the store that items will be checked in to.
        /// </summary>
        public abstract Guid? StoreCheckInID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Catalogue table
        /// that indicates the catalogue of the item that will be
        /// checked in.
        /// </summary>
        public abstract Guid? CatalogueID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the StoreBin table.
        /// that indicates the store bin the item will be checked in to.
        /// </summary>
        public abstract Guid? StoreBinID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the unit price of the item that will
        /// be checked in. Each OStoreCheckInItem record can specify
        /// only one unit price. If same items of different unit prices
        /// must be checked in, there must be multiple OStoreCheckInItem
        /// record.
        /// </summary>
        public abstract decimal? UnitPrice { get; set; }

        /// <summary>
        /// [Column] Gets or sets the quantity (in the base unit) of
        /// the item to check in.
        /// </summary>
        public abstract decimal? Quantity { get; set; }

        /// <summary>
        /// [Column] Gets or sets the expiry date of the item. This
        /// is currently information, and is not used to determine
        /// the order of check outs.
        /// </summary>
        public abstract DateTime? ExpiryDate { get; set; }

        /// <summary>
        /// [Column] Gets or sets the batch or lot number of this
        /// item.
        /// </summary>
        public abstract string LotNumber { get; set; }

        /// <summary>
        /// Gets or sets the OStoreCheckIn object that represents
        /// the store that items will be checked in to.
        /// </summary>
        public abstract OStoreCheckIn StoreCheckIn { get; set; }
        
        /// <summary>
        /// Gets or sets the OCatalogue object that represents
        /// the catalogue of the item that will be checked in.
        /// </summary>
        public abstract OCatalogue Catalogue { get; set; }

        /// <summary>
        /// Gets or sets the OStoreBin object that represents
        /// the store bin the item will be checked in to.
        /// </summary>
        public abstract OStoreBin StoreBin { get; set; }


        /// <summary>
        /// Gets the sub-total as the unit price multiplied
        /// by the quantity.
        /// </summary>
        public decimal? SubTotal
        {
            get
            {
                return this.UnitPrice * this.Quantity;
            }
        }
    }
}

