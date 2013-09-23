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
    [Database("#database"), Map("PurchaseOrderItem")]
    public partial class TPurchaseOrderItem : LogicLayerSchema<OPurchaseOrderItem>
    {
        public SchemaGuid PurchaseOrderID;
        public SchemaInt ItemNumber;
        public SchemaInt ItemType;
        [Size(2500)]
        public SchemaString ItemDescription;
        public SchemaGuid CatalogueID;
        public SchemaGuid FixedRateID;
        public SchemaGuid UnitOfMeasureID;
        public SchemaGuid CurrencyID;
        public SchemaDecimal UnitPrice;
        public SchemaDecimal UnitPriceInSelectedCurrency;
        public SchemaDecimal QuantityOrdered;

        public SchemaGuid PurchaseRequestItemID;
        public SchemaGuid RequestForQuotationItemID;

        [Default(0)]
        public SchemaInt ReceiptMode;
            
        public TPurchaseOrder PurchaseOrder { get { return OneToOne<TPurchaseOrder>("PurchaseOrderID"); } }
        public TCode UnitOfMeasure { get { return OneToOne<TCode>("UnitOfMeasureID"); } }
        public TCatalogue Catalogue { get { return OneToOne<TCatalogue>("CatalogueID"); } }
        public TFixedRate FixedRate { get { return OneToOne<TFixedRate>("FixedRateID"); } }
        public TCurrency Currency { get { return OneToOne<TCurrency>("CurrencyID"); } }

        public TPurchaseRequestItem PurchaseRequestItem { get { return OneToOne<TPurchaseRequestItem>("PurchaseRequestItemID"); } }
        public TRequestForQuotationItem RequestForQuotationItem { get { return OneToOne<TRequestForQuotationItem>("RequestForQuotationItemID"); } }

    }


    /// <summary>
    /// Represents the item requested in a purchase order object.
    /// </summary>
    public abstract partial class OPurchaseOrderItem : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the PurchaseOrder table 
        /// that indicates the purchase order that contains this item.
        /// </summary>
        public abstract Guid? PurchaseOrderID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the item number of this purchase
        /// request item.
        /// </summary>
        public abstract Int32? ItemNumber { get; set; }

        /// <summary>
        /// [Column] Gets or sets a value that indicates the type
        /// this item belongs to.
        /// <para></para>
        /// <list>
        ///   <item>0 - Material</item>
        ///   <item>1 - Services</item>
        ///   <item>2 - Others</item>
        /// </list>
        /// </summary>
        public abstract Int32? ItemType { get; set; }

        /// <summary>
        /// [Column] Gets or sets the description of this item.
        /// This description is filled up with the material's (catalogue)
        /// or service's (fixed rate) name. If ItemType = 2, however,
        /// this description is entered by the user manually through
        /// the user interface.
        /// </summary>
        public abstract String ItemDescription { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Catalogue table 
        /// that indicates the material item requested.
        /// This is applicable if ItemType = 0.
        /// </summary>
        public abstract Guid? CatalogueID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the FixedRate table 
        /// that indicates the service item requested.
        /// This is applicable if ItemType = 1.
        /// </summary>
        public abstract Guid? FixedRateID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Code table 
        /// that indicates the unit of measure of this material
        /// or service. 
        /// </summary>
        public abstract Guid? UnitOfMeasureID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Currency table 
        /// that indicates the currency of the unit price of this
        /// purchase order line item.
        /// </summary>
        public abstract Guid? CurrencyID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the unit price of this item.
        /// </summary>
        public abstract Decimal? UnitPrice { get; set; }

        /// <summary>
        /// [Column] Gets or sets the unit price of this item 
        /// in the system's base currency. This value is currently 
        /// always the same as the unit price.
        /// </summary>
        public abstract Decimal? UnitPriceInSelectedCurrency { get; set; }

        /// <summary>
        /// [Column] Gets or sets the quantity of the material
        /// or service ordered from the vendor.
        /// </summary>
        public abstract Decimal? QuantityOrdered { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the PurchaseRequestItem table 
        /// that indicates the purchase request item this purchase order
        /// item was copied from.
        /// </summary>
        public abstract Guid? PurchaseRequestItemID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the RequestForQuotationItem table 
        /// that indicates the request from quotation item this purchase order
        /// item was copied from.
        /// </summary>
        public abstract Guid? RequestForQuotationItemID { get; set; }

        /// <summary>
        /// Gets or sets the mode that this purchase order item should be
        /// received in.
        /// <list>
        ///     <item>0 - Receive quantity </item>
        ///     <item>1 - Receive dollar amount </item>
        /// </list>
        /// </summary>
        public abstract Int32? ReceiptMode { get; set; }

        /// <summary>
        /// Gets or sets the OPurchaseOrder object that represents
        /// the purchase order that contains this item.
        /// </summary>
        public abstract OPurchaseOrder PurchaseOrder { get; set; }

        /// <summary>
        /// Gets or sets the OCode object that represents
        /// the unit of measure of this material
        /// or service. 
        /// </summary>
        public abstract OCode UnitOfMeasure { get; set; }

        /// <summary>
        /// Gets or sets the OCatalogue object that represents
        /// the material item requested.
        /// This is applicable if ItemType = 0.
        /// </summary>
        public abstract OCatalogue Catalogue { get; set; }

        /// <summary>
        /// Gets or sets the OFixedRate object that represents
        /// the service item requested.
        /// This is applicable if ItemType = 1.
        /// </summary>
        public abstract OFixedRate FixedRate { get; set; }

        /// <summary>
        /// Gets or sets the OCurrency object that represents 
        /// that currency of this line item.
        /// </summary>
        public abstract OCurrency Currency { get; set; }

        /// <summary>
        /// Gets or sets the OPurchaseRequestItem object that represents
        /// the purchase request item this purchase order
        /// item was copied from.
        /// </summary>
        public abstract OPurchaseRequestItem PurchaseRequestItem { get; set; }

        /// <summary>
        /// Gets or sets the ORequestForQuotationItem object that represents
        /// the request from quotation item this purchase order
        /// item was copied from.
        /// </summary>
        public abstract ORequestForQuotationItem RequestForQuotationItem { get; set; }


        /// <summary>
        /// Gets the text of the mode of receipt for this
        /// purchase order item.
        /// </summary>
        public string ReceiptModeText
        {
            get
            {
                if (ReceiptMode == ReceiptModeType.Quantity)
                    return LogicLayer.Resources.Strings.ReceiptMode_Quantity;
                else if (ReceiptMode == ReceiptModeType.Dollar)
                    return LogicLayer.Resources.Strings.ReceiptMode_Dollar;
                return "";
            }
        }


        /// <summary>
        /// Gets the total quantity delivered for this item by
        /// computing the total receipts.
        /// </summary>
        public Decimal QuantityDelivered 
        {
            get
            {
                return (decimal)Query.Select(
                    TablesLogic.tPurchaseOrderReceiptItem.QuantityDelivered.Sum())
                    .Where(
                    TablesLogic.tPurchaseOrderReceiptItem.QuantityDelivered > 0 &
                    TablesLogic.tPurchaseOrderReceiptItem.PurchaseOrderItemID == this.ObjectID &
                    TablesLogic.tPurchaseOrderReceiptItem.PurchaseOrderReceipt.IsDeleted == 0);
            }
        }

        /// <summary>
        /// Gets the total quantity delivered for this item by
        /// computing the total receipts.
        /// </summary>
        public Decimal DollarAmountDelivered
        {
            get
            {
                return (decimal)Query.Select(
                    TablesLogic.tPurchaseOrderReceiptItem.UnitPrice.Sum())
                    .Where(
                    TablesLogic.tPurchaseOrderReceiptItem.UnitPrice > 0 &
                    TablesLogic.tPurchaseOrderReceiptItem.PurchaseOrderItemID == this.ObjectID &
                    TablesLogic.tPurchaseOrderReceiptItem.PurchaseOrderReceipt.IsDeleted == 0);
            }
        }


        /// <summary>
        /// Gets the sub total awarded for this
        /// line item. The sub-total is the unit price (in base currency) 
        /// multiplied by the quantity provided.
        /// </summary>
        public decimal? Subtotal
        {
            get
            {
                return Round(this.QuantityOrdered * this.UnitPrice);
            }
        }


        /// <summary>
        /// Gets the localized text for the item type.
        /// </summary>
        public string ItemTypeText
        {
            get
            {
                if (ItemType == 0)
                    return Resources.Strings.PurchaseItemType_Material;
                else if (ItemType == 1)
                    return Resources.Strings.PurchaseItemType_Service;
                else if (ItemType == 2)
                    return Resources.Strings.PurchaseItemType_Others;
                return "";
            }
        }


        /// <summary>
        /// Gets the purchase request number or request for quotation number
        /// that this purchase order item was copied from.
        /// </summary>
        public string CopiedFromObjectNumber
        {
            get
            {
                if (PurchaseRequestItem != null && PurchaseRequestItem.PurchaseRequest != null)
                    return PurchaseRequestItem.PurchaseRequest.ObjectNumber;
                else if (RequestForQuotationItem != null && RequestForQuotationItem.RequestForQuotation != null)
                    return RequestForQuotationItem.RequestForQuotation.ObjectNumber;
                return "";
            }
        }
    }
}
