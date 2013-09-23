//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Data;
using System.Collections.Generic;
using System.Text;

using Anacle.DataFramework;

namespace LogicLayer
{
    [Database("#database"), Map("PurchaseOrderReceipt")]
    public class TPurchaseOrderReceipt : LogicLayerSchema<OPurchaseOrderReceipt>
    {
        public SchemaGuid PurchaseOrderID;
        public SchemaDateTime DateOfReceipt;
        public SchemaGuid StoreID;
        public SchemaGuid StoreBinID;
        public SchemaString DeliveryOrderNumber;
        public SchemaString Description;

        public TStore Store { get { return OneToOne<TStore>("StoreID"); } }
        public TStoreBin StoreBin { get { return OneToOne<TStoreBin>("StoreBinID"); } }
        public TPurchaseOrder PurchaseOrder { get { return OneToOne<TPurchaseOrder>("PurchaseOrderID"); } }
        public TPurchaseOrderReceiptItem PurchaseOrderReceiptItems { get { return OneToMany<TPurchaseOrderReceiptItem>("PurchaseOrderReceiptID"); } }
    }


    /// <summary>
    /// Represents a single receipt performed against a purchase order.
    /// A purchase order may have multiple receipts, each receiving the
    /// materials and services ordered in part or in full. When 
    /// a receipt of material items is committed, the material items
    /// will be checked in to the store as inventory.
    /// </summary>
    public abstract class OPurchaseOrderReceipt : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the PurchaseOrder table 
        /// that indicates the purchase order this receipt is performed
        /// against.
        /// </summary>
        public abstract Guid? PurchaseOrderID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the date the items was received.
        /// </summary>
        public abstract DateTime? DateOfReceipt { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Store table 
        /// that indicates the store that material items will
        /// be checked in to.
        /// </summary>
        public abstract Guid? StoreID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the StoreBin table 
        /// that indicates the bin that material items will
        /// be checked in to.
        /// </summary>
        public abstract Guid? StoreBinID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the delivery order number associated
        /// with this receipt.
        /// </summary>
        public abstract String DeliveryOrderNumber { get; set; }

        /// <summary>
        /// [Column] Gets or sets the description of this receipt.
        /// </summary>
        public abstract String Description { get; set; }

        /// <summary>
        /// Gets or sets the OStore object that represents
        /// that material items will be checked in to.
        /// </summary>
        public abstract OStore Store { get; set; }

        /// <summary>
        /// Gets or sets the OStoreBin object that represents
        /// the bin that material items will be checked in to.
        /// </summary>
        public abstract OStoreBin StoreBin { get; set; }

        /// <summary>
        /// Gets or sets the OPurchaseOrder object that represents
        /// the purchase order this receipt is performed
        /// against.
        /// </summary>
        public abstract OPurchaseOrder PurchaseOrder { get; set; }

        /// <summary>
        /// Gets a one-to-many list of OPurchaseOrderReceiptItem 
        /// objects that represents a list of items and the quantity
        /// received for this purchass order.
        /// </summary>
        public abstract DataList<OPurchaseOrderReceiptItem> PurchaseOrderReceiptItems { get; }

    }
}
