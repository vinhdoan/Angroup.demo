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
    [Database("#database"), Map("PurchaseRequestItem")]
    public partial class TPurchaseRequestItem : LogicLayerSchema<OPurchaseRequestItem>
    {
        public SchemaGuid PurchaseRequestID;
        public SchemaInt ItemNumber;
        public SchemaInt ItemType;
        [Size(255)]
        public SchemaString ItemDescription;
        public SchemaGuid CatalogueID;
        public SchemaGuid FixedRateID;
        public SchemaGuid UnitOfMeasureID;
        public SchemaDecimal QuantityRequired;
        public SchemaDecimal UnitPrice;

        [Default(0)]
        public SchemaInt ReceiptMode;

        public TPurchaseRequest PurchaseRequest { get { return OneToOne<TPurchaseRequest>("PurchaseRequestID"); } }
        public TCode UnitOfMeasure { get { return OneToOne<TCode>("UnitOfMeasureID"); } }
        public TCatalogue Catalogue { get { return OneToOne<TCatalogue>("CatalogueID"); } }
        public TFixedRate FixedRate { get { return OneToOne<TFixedRate>("FixedRateID"); } }
    }


    /// <summary>
    /// Represents the item requested in a purchase request object.
    /// </summary>
    public abstract partial class OPurchaseRequestItem : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the PurchaseRequest table 
        /// that indicates the purchase request that contains this item.
        /// </summary>
        public abstract Guid? PurchaseRequestID { get; set; }

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
        /// [Column] Gets or sets the quantity required.
        /// </summary>
        public abstract Decimal? QuantityRequired { get; set; }

        /// <summary>
        /// [Column] Gets or sets the estimated unit price of
        /// this item.
        /// </summary>
        public abstract Decimal? UnitPrice { get; set; }

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
        /// Gets or sets the OPurchaseRequest object that represents
        /// the purchase request that contains this item.
        /// </summary>
        public abstract OPurchaseRequest PurchaseRequest { get; set; }

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
        /// Gets the amount in dollars of this line item.
        /// </summary>
        public decimal? Amount
        {
            get
            {
                return QuantityRequired * UnitPrice;
            }
        }

        /// <summary>
        /// Gets the purchase order item that this request item 
        /// has been copied to.
        /// </summary>
        public OPurchaseOrderItem PurchaseOrderItem 
        {
            get
            {
                List<OPurchaseOrderItem> items = TablesLogic.tPurchaseOrderItem[
                    TablesLogic.tPurchaseOrderItem.PurchaseRequestItemID == this.ObjectID];
                if (items.Count > 0)
                    return items[0];
                else
                    return null;
            }
        }


        /// <summary>
        /// Gets the request for quotation item that this request
        /// item has been copied to.
        /// </summary>
        public ORequestForQuotationItem RequestForQuotationItem 
        {
            get
            {
                List<ORequestForQuotationItem> items = TablesLogic.tRequestForQuotationItem[
                    TablesLogic.tRequestForQuotationItem.PurchaseRequestItemID == this.ObjectID];
                if (items.Count > 0)
                    return items[0];
                else
                    return null;
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
        /// Gets the request for quotation number or purchase
        /// order number that this item has been copied.
        /// </summary>
        public string CopiedToObjectNumber
        {
            get
            {
                if (PurchaseOrderItem != null && PurchaseOrderItem.PurchaseOrder != null)
                    return PurchaseOrderItem.PurchaseOrder.ObjectNumber;
                else if (RequestForQuotationItem != null && RequestForQuotationItem.RequestForQuotation != null)
                    return RequestForQuotationItem.RequestForQuotation.ObjectNumber;
                return "";
            }
        }


    }


    /// <summary>
    /// Enumerates the different line item types in the Procurement module.
    /// </summary>
    public class PurchaseItemType
    {
        /// <summary>
        /// Indicates that the line item is a material/inventory item.
        /// </summary>
        public const int Material = 0;

        /// <summary>
        /// Indicates that the line item is a service item.
        /// </summary>
        public const int Service = 1;

        /// <summary>
        /// Indicates that the line item is any other item that do not
        /// fall into the Material or Service categories.
        /// </summary>
        public const int Others = 2;
    }


    /// <summary>
    /// Enumerates the various receipt modes.
    /// </summary>
    public class ReceiptModeType
    {
        /// <summary>
        /// Indicates that the line item is received by the quantity.
        /// This mode is commonly used for inventory items.
        /// </summary>
        public const int Quantity = 0;

        /// <summary>
        /// Indicates that the line item is received by dollar amount.
        /// This mode is commonly used for services.
        /// </summary>
        public const int Dollar = 1;
    }
}
