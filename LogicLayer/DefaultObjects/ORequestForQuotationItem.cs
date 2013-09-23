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
    [Serializable] 
    public partial class TRequestForQuotationItem : LogicLayerSchema<ORequestForQuotationItem>
    {
        public SchemaGuid RequestForQuotationID;
        public SchemaInt ItemNumber;
        public SchemaInt ItemType;
        [Size(2500)]
        public SchemaString ItemDescription;
        public SchemaGuid CatalogueID;
        public SchemaGuid FixedRateID;
        public SchemaGuid UnitOfMeasureID;
        public SchemaDecimal QuantityRequired;

        [Default(0)]
        public SchemaInt ReceiptMode;
        public SchemaGuid PurchaseRequestItemID;
        public SchemaGuid AwardedRequestForQuotationVendorItemID;
        public SchemaGuid AwardedVendorID;
        public SchemaGuid CurrencyID;
        public SchemaDecimal QuantityProvided;
        public SchemaDecimal UnitPriceInSelectedCurrency;
        public SchemaDecimal UnitPrice;

        public TCode UnitOfMeasure { get { return OneToOne<TCode>("UnitOfMeasureID"); } }
        public TCatalogue Catalogue { get { return OneToOne<TCatalogue>("CatalogueID"); } }
        public TFixedRate FixedRate { get { return OneToOne<TFixedRate>("FixedRateID"); } }
        public TRequestForQuotationVendorItem AwardedRequestForQuotationVendorItem { get { return OneToOne<TRequestForQuotationVendorItem>("AwardedRequestForQuotationVendorItemID"); } }
        public TVendor AwardedVendor { get { return OneToOne<TVendor>("AwardedVendorID"); } }
        public TRequestForQuotation RequestForQuotation { get { return OneToOne<TRequestForQuotation>("RequestForQuotationID"); } }
        public TPurchaseRequestItem PurchaseRequestItem { get { return OneToOne<TPurchaseRequestItem>("PurchaseRequestItemID"); } }
        public TPurchaseOrderItem PurchaseOrderItem { get { return OneToOne<TPurchaseOrderItem>("PurchaseOrderItemID"); } }
        public TCurrency Currency { get { return OneToOne<TCurrency>("CurrencyID"); } }
    }


    /// <summary>
    /// Represents 
    /// </summary>
    [Serializable] public abstract partial class ORequestForQuotationItem : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the RequestForQuotation table 
        /// that indicates the request for quotation object that contains
        /// this item.
        /// </summary>
        public abstract Guid? RequestForQuotationID { get; set; }

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
        /// [Column] Gets or sets the quantity of the material
        /// or service ordered from the vendor.
        /// </summary>
        public abstract Decimal? QuantityRequired { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the PurchaseRequestItem table 
        /// that indicates the purchase request item this purchase order
        /// item was copied from.
        /// </summary>
        public abstract Guid? PurchaseRequestItemID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the mode that this purchase order item should be
        /// received in.
        /// <list>
        ///     <item>0 - Receive quantity </item>
        ///     <item>1 - Receive dollar amount </item>
        /// </list>
        /// </summary>
        public abstract Int32? ReceiptMode { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the RequestForQuotationVendorItem table
        /// that represents the quotation line item that this awarded item was based on.
        /// </summary>
        public abstract Guid? AwardedRequestForQuotationVendorItemID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Vendor table
        /// that represents the vendor that this line item is
        /// awarded to.
        /// </summary>
        public abstract Guid? AwardedVendorID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Currency
        /// table that represents the currency that the awarded
        /// vendor is quoting in. 
        /// </summary>
        public abstract Guid? CurrencyID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the quantity provided by the
        /// vendor awarded this item.
        /// </summary>
        public abstract decimal? QuantityProvided { get; set; }

        /// <summary>
        /// [Column] Gets or sets the awarded unit price of
        /// this item in the selected currency.
        /// </summary>
        public abstract decimal? UnitPriceInSelectedCurrency { get; set; }

        /// <summary>
        /// [Column] Gets or sets the awarded unit price of
        /// this item in base currency.
        /// </summary>
        public abstract decimal? UnitPrice { get; set; }

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
        /// Gets or sets the ORequestForQuotationVendor object that represents
        /// the quotation this awarded item in the request.
        /// </summary>
        public abstract ORequestForQuotationVendorItem AwardedRequestForQuotationVendorItem { get; set; }

        /// <summary>
        /// Gets or sets the OVendor object that represents
        /// the vendor awarded this line item in the request.
        /// </summary>
        public abstract OVendor AwardedVendor { get; set; }

        /// <summary>
        /// Gets or sets the ORequestForQuotation object that represents 
        /// the request for quotation object that contains
        /// this item.
        /// </summary>
        public abstract ORequestForQuotation RequestForQuotation { get; set; }

        /// <summary>
        /// Gets or sets the OPurchaseRequestItem object that represents
        /// the purchase request item this request for quotation 
        /// item was copied from.
        /// </summary>
        public abstract OPurchaseRequestItem PurchaseRequestItem { get; set; }

        /// <summary>
        /// Gets or sets the OCurrency object that represents the
        /// currency this line item is quoted in.
        /// </summary>
        public abstract OCurrency Currency { get; set; }

        /// <summary>
        /// Gets the text of the mode of receipt for this
        /// purchase order item.
        /// </summary>
        public string ReceiptModeText
        {
            get
            {
                if (ReceiptMode == 0)
                    return LogicLayer.Resources.Strings.ReceiptMode_Quantity;
                else
                    return LogicLayer.Resources.Strings.ReceiptMode_Dollar;
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
                else if (ItemType == 3)
                    return Resources.Strings.PurchaseItemType_Others;
                return "";
            }
        }

        /// <summary>
        /// Gets the purcahse order item that this
        /// request for quotation item was copied to.
        /// </summary>
        public OPurchaseOrderItem PurchaseOrderItem
        {
            get
            {
                List<OPurchaseOrderItem> items = TablesLogic.tPurchaseOrderItem[
                    TablesLogic.tPurchaseOrderItem.RequestForQuotationItemID == this.ObjectID];
                if (items.Count > 0)
                    return items[0];
                else
                    return null;
            }
        }

        /// <summary>
        /// Gets the purchase request number that this
        /// request for quotation item was copied from.
        /// </summary>
        public string CopiedFromObjectNumber
        {
            get
            {
                if (PurchaseRequestItem != null && PurchaseRequestItem.PurchaseRequest!=null)
                    return PurchaseRequestItem.PurchaseRequest.ObjectNumber;
                return "";
            }
        }

        /// <summary>
        /// Gets the purchase order number that this
        /// request for quotation item was copied to.
        /// </summary>
        public string CopiedToObjectNumber
        {
            get
            {
                if (PurchaseOrderItem != null && PurchaseOrderItem.PurchaseOrder != null)
                    return PurchaseOrderItem.PurchaseOrder.ObjectNumber;
                return "";
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
                return Round(this.QuantityProvided * this.UnitPrice);
            }
        }

    }
}
