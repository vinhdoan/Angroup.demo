//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Text;

using Anacle.DataFramework;

namespace LogicLayer
{
    public partial class TPurchaseOrderReceiptItem : LogicLayerSchema<OPurchaseOrderReceiptItem>
    {

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
        //----------------------------------------------------------------
        /// <summary>
        /// Check in as a store item, if the purchase order item was
        /// of a material type.
        /// </summary>
        //----------------------------------------------------------------
        public override void Saving()
        {
            base.Saving();

            // check items into the store only if this is a new item, 
            // and this is a material type
            //
            if (this.IsNew && this.PurchaseOrderItem.ItemType == PurchaseItemType.Material)
            {
                StoreCheckInItemDetail checkInDetail = new StoreCheckInItemDetail();

                checkInDetail.BaseQuantity = (decimal)this.QuantityDelivered;
                checkInDetail.ExpiryDate = this.ExpiryDate;
                checkInDetail.LotNumber = this.LotNumber;
                checkInDetail.PurchaseOrder = this.PurchaseOrderItem.PurchaseOrder;
                checkInDetail.UnitPriceInSelectedCurrency = PurchaseOrderItem.UnitPriceInSelectedCurrency;


                if (this.PurchaseOrderItem.UnitPrice != null)
                {
                    checkInDetail.UnitPrice =
                        this.PurchaseOrderItem.UnitPrice.Value;
                }
                else
                    checkInDetail.UnitPrice = 0;

                this.PurchaseOrderReceipt.Store.CheckInNewItems(
                    (Guid)this.PurchaseOrderReceipt.StoreBinID,
                    (Guid)this.PurchaseOrderItem.CatalogueID, checkInDetail, this.ObjectID);
            }
        }
    }
}
