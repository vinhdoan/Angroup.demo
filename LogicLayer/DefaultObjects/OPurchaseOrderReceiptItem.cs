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
    [Database("#database"), Map("PurchaseOrderReceiptItem")]
    public partial class TPurchaseOrderReceiptItem : LogicLayerSchema<OPurchaseOrderReceiptItem>
    {
        public SchemaGuid PurchaseOrderReceiptID;
        public SchemaGuid PurchaseOrderItemID;
        public SchemaDecimal UnitPrice;
        public SchemaDecimal QuantityDelivered;
        public SchemaDateTime ExpiryDate;
        public SchemaString LotNumber;

        public SchemaString EquipmentName;
        public SchemaGuid EquipmentParentID;
        public SchemaString EquipmentModelNumber;
        public SchemaString EquipmentSerialNumber;
        public SchemaDateTime EquipmentWarrantyExpiryDate;
        public SchemaDateTime EquipmentDateOfManufacture;
        public SchemaString EquipmentBarcode;

        public TPurchaseOrderReceipt PurchaseOrderReceipt { get { return OneToOne<TPurchaseOrderReceipt>("PurchaseOrderReceiptID"); } }
        public TPurchaseOrderItem PurchaseOrderItem { get { return OneToOne<TPurchaseOrderItem>("PurchaseOrderItemID"); } }
        public TEquipment EquipmentParent { get { return OneToOne<TEquipment>("EquipmentParentID"); } }
    }


    /// <summary>
    /// Represents the record that contains information
    /// about the quantity of the item received from
    /// the vendor. This is associated one of the line
    /// items of the purchase order line items.
    /// </summary>
    public abstract partial class OPurchaseOrderReceiptItem : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the PurchaseOrderReceipt table 
        /// that indicates the receipt that contains this item.
        /// </summary>
        public abstract Guid? PurchaseOrderReceiptID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the PurchaseOrderItem table 
        /// that indicates the item in the purchase order this receipt item
        /// is associated with.
        /// </summary>
        public abstract Guid? PurchaseOrderItemID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the unit price or the dollar amount 
        /// delivered for this item. This is editable if the receipt 
        /// mode of the item is dollar amount.
        /// </summary>
        public abstract Decimal? UnitPrice { get; set; }

        /// <summary>
        /// [Column] Gets or sets the quantity delivered for this item.
        /// This is editable if the receipt mode of the item is quantity.
        /// </summary>
        public abstract Decimal? QuantityDelivered { get; set; }

        /// <summary>
        /// [Column] Gets or sets the expiry date of this batch of
        /// items if applicable. When checking in materials into the store,
        /// this value will be copied to the item batch's details.
        /// </summary>
        public abstract DateTime? ExpiryDate { get; set; }

        /// <summary>
        /// [Column] Gets or sets the lot number of this batch of
        /// items if applicable. When checking in materials into the store,
        /// this value will be copied to the item batch's details.
        /// </summary>
        public abstract string LotNumber { get; set; }

        /// <summary>
        /// [Column] Gets or sets the name of the equipment
        /// that will be checked-in.
        /// </summary>
        public abstract string EquipmentName { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the
        /// Equipment table that indicates the equipment that
        /// this equipment to be checked-in belongs under.
        /// </summary>
        public abstract Guid? EquipmentParentID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the model number of the
        /// equipment to be checked-in.
        /// </summary>
        public abstract string EquipmentModelNumber { get; set; }

        /// <summary>
        /// [Column] Gets or sets the serial number of the
        /// equipment to be checked-in.
        /// </summary>
        public abstract string EquipmentSerialNumber { get; set; }

        /// <summary>
        /// [Column] Gets or sets the warranty expiry date of the
        /// equipment to be checked-in.
        /// </summary>
        public abstract DateTime? EquipmentWarrantyExpiryDate { get; set; }

        /// <summary>
        /// [Column] Gets or sets the date of manufacture of the
        /// equipment to be checked-in.
        /// </summary>
        public abstract DateTime? EquipmentDateOfManufacture { get; set; }

        /// <summary>
        /// [Column] Gets or sets the barcode of the equipment
        /// to be checked in.
        /// </summary>
        public abstract string EquipmentBarcode { get; set; }

        /// <summary>
        /// Gets or sets the O object that represents
        /// </summary>
        public abstract OPurchaseOrderReceipt PurchaseOrderReceipt { get; set; }

        /// <summary>
        /// Gets or sets the OPurchaseOrderItem object that 
        /// represents the purchase order this receipt item
        /// is associated with.
        /// </summary>
        public abstract OPurchaseOrderItem PurchaseOrderItem { get; set; }

        /// <summary>
        /// Gets or sets a reference to the OEquipment object
        /// that represents the parent equipment a
        /// new equipment should be classified under.
        /// </summary>
        public abstract OEquipment EquipmentParent { get; set; }

        //----------------------------------------------------------------
        /// <summary>
        /// Check in as a store item, if the purchase order item was
        /// of a material type.
        /// </summary>
        //----------------------------------------------------------------
        //public override void Saving()
        //{
        //    base.Saving();

        //    // check items into the store only if this is a new item, 
        //    // and this is a material type
        //    //
        //    if (this.IsNew && this.PurchaseOrderItem.ItemType==PurchaseItemType.Material)
        //    {
        //        StoreCheckInItemDetail checkInDetail = new StoreCheckInItemDetail();

        //        checkInDetail.BaseQuantity = (decimal)this.QuantityDelivered;
        //        checkInDetail.ExpiryDate = this.ExpiryDate;
        //        checkInDetail.LotNumber = this.LotNumber;

        //        if (this.PurchaseOrderItem.UnitPrice != null)
        //        {
        //            checkInDetail.UnitPrice =
        //                this.PurchaseOrderItem.UnitPrice.Value;
        //        }
        //        else
        //            checkInDetail.UnitPrice = 0;

        //        this.PurchaseOrderReceipt.Store.CheckInNewItems(
        //            (Guid)this.PurchaseOrderReceipt.StoreBinID,
        //            (Guid)this.PurchaseOrderItem.CatalogueID, checkInDetail, this.ObjectID);
        //    }
        //}
    }
}
