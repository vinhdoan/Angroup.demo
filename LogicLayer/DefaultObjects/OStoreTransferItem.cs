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
    /// Summary description for OStoreTransfer
    /// Transfer item from one store to another. It represent one check in and one check out object
    /// </summary>
    [Database("#database"), Map("StoreTransferItem")]
    [Serializable] public partial class TStoreTransferItem : LogicLayerSchema<OStoreTransferItem>
    {
        public SchemaGuid StoreTransferID;

        public SchemaGuid CatalogueID;
        public SchemaGuid FromStoreBinID;
        public SchemaGuid ToStoreBinID;
        public SchemaGuid StoreBinItemID;
        public SchemaDecimal EstimatedUnitCost;
        public SchemaDecimal Quantity;

        public TStoreTransfer StoreTransfer { get { return OneToOne<TStoreTransfer>("StoreTransferID"); } }
        public TCatalogue Catalogue { get { return OneToOne<TCatalogue>("CatalogueID"); } }
        public TStoreItem FromStoreItem { get { return OneToOne<TStoreItem>("FromStoreItemID"); } }
        public TStoreBin FromStoreBin { get { return OneToOne<TStoreBin>("FromStoreBinID"); } }
        public TStoreItem ToStoreItem { get { return OneToOne<TStoreItem>("ToStoreItemID"); } }
        public TStoreBin ToStoreBin { get { return OneToOne<TStoreBin>("ToStoreBinID"); } }
        public TStoreBinItem StoreBinItem { get { return OneToOne<TStoreBinItem>("StoreBinItemID"); } }
    }


    /// <summary>
    /// Represents the record containing information about the 
    /// item to be transferred.
    /// </summary>
    [Serializable]
    public abstract partial class OStoreTransferItem : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the StoreTransfer table 
        /// that indicates the transfer object that contains this record.
        /// </summary>
        public abstract Guid? StoreTransferID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Catalogue table 
        /// that indicates the catalogue of the item to transfer.
        /// </summary>
        public abstract Guid? CatalogueID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the StoreBin table 
        /// that indicates the bin to transfer the item from.
        /// </summary>
        public abstract Guid? FromStoreBinID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the StoreBin table 
        /// that indicates the bin to transfer the item to.
        /// </summary>
        public abstract Guid? ToStoreBinID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the
        /// StoreBinItem object.
        /// </summary>
        public abstract Guid? StoreBinItemID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the estimated unit cost
        /// of the item to transfer.
        /// <para></para>
        /// This estimated unit cost is used only for determining
        /// who in the approval hierarchy to send to for approval.
        /// <para></para>
        /// The actual unit cost of items checked out will be known
        /// once the transfer is approved and committed.
        /// </summary>
        public abstract decimal? EstimatedUnitCost { get; set; }

        /// <summary>
        /// [Column] Gets or sets the quantity (in the base unit)
        /// of the item to transfer.
        /// </summary>
        public abstract decimal? Quantity { get; set; }

        /// <summary>
        /// Gets or sets the OStoreTransfer object that represents
        /// the transfer object that contains this record.
        /// </summary>
        public abstract OStoreTransfer StoreTransfer { get; set; }

        /// <summary>
        /// Gets or sets the OCatalogue object that represents
        /// the catalogue of the item to transfer.
        /// </summary>
        public abstract OCatalogue Catalogue { get; set; }

        /// <summary>
        /// Gets or sets the OStoreBin object that represents
        /// the bin to transfer the item from.
        /// </summary>
        public abstract OStoreBin FromStoreBin { get; set; }

        /// <summary>
        /// Gets or sets the OStoreBin object that represents
        /// the bin to transfer the item to.
        /// </summary>
        public abstract OStoreBin ToStoreBin { get; set; }

        /// <summary>
        /// Gets or sets the OStoreBinItem object that represents
        /// the bin to transfer the item to.
        /// </summary>
        public abstract OStoreBinItem StoreBinItem { get; set; }

        public bool Valid = true;

        /// <summary>
        /// Gets the sub-total as the unit price multiplied
        /// by the quantity.
        /// </summary>
        public decimal? SubTotal
        {
            get
            {
                return this.EstimatedUnitCost * this.Quantity;
            }
        }

        /// <summary>
        /// Computes the estimated unit cost of the check out items.
        /// </summary>
        public void ComputeEstimatedUnitCost()
        {
            decimal estimatedUnitCost = 0;
            decimal estimatedTotalCost = 0;

            this.FromStoreBin.Store.PeekItemsUnitCost(
                this.FromStoreBinID.Value,
                this.CatalogueID.Value,
                this.Quantity.Value,
                this.Catalogue.UnitOfMeasureID.Value,
                out estimatedUnitCost,
                out estimatedTotalCost);

            this.EstimatedUnitCost = estimatedUnitCost;
        }
    }
}
