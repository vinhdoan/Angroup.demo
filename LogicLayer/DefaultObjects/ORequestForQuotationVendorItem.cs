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
    [Serializable] 
    public partial class TRequestForQuotationVendorItem : LogicLayerSchema<ORequestForQuotationVendorItem>
    {
        public SchemaGuid RequestForQuotationVendorID;
        public SchemaGuid RequestForQuotationItemID;

        public SchemaInt ItemNumber;
        public SchemaInt ItemType;
        [Size(2500)]
        public SchemaString ItemDescription;
        public SchemaGuid CatalogueID;
        public SchemaGuid FixedRateID;
        public SchemaGuid UnitOfMeasureID;
        public SchemaGuid CurrencyID;
        public SchemaDecimal UnitPriceInSelectedCurrency;
        public SchemaDecimal UnitPrice;
        public SchemaDecimal QuantityProvided;
        public SchemaDecimal ItemDiscount;

        public TCode UnitOfMeasure { get { return OneToOne<TCode>("UnitOfMeasureID"); } }
        public TCatalogue Catalogue { get { return OneToOne<TCatalogue>("CatalogueID"); } }
        public TFixedRate FixedRate { get { return OneToOne<TFixedRate>("FixedRateID"); } }
        public TRequestForQuotationVendor RequestForQuotationVendor { get { return OneToOne<TRequestForQuotationVendor>("RequestForQuotationVendorID"); } }
        public TRequestForQuotationItem RequestForQuotationItem { get { return OneToOne<TRequestForQuotationItem>("RequestForQuotationItemID"); } }
        public TCurrency Currency { get { return OneToOne<TCurrency>("CurrencyID"); } }
    }


    /// <summary>
    /// Represents an object that contains the quoted price of a line
    /// item from a request for quotation item object.
    /// </summary>
    [Serializable] public abstract partial class ORequestForQuotationVendorItem : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the RequestForQuotationVendor table 
        /// that indicates the quotation object that contains this item.
        /// </summary>
        public abstract Guid? RequestForQuotationVendorID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the RequestForQuotationItem table 
        /// that indicates the line item in the request for quotation
        /// that this quote is for.
        /// </summary>
        public abstract Guid? RequestForQuotationItemID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the item number of this purchase
        /// request item.
        /// </summary>
        public abstract int? ItemNumber { get; set; }

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
        public abstract int? ItemType { get; set; }

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
        /// [Column] Gets or sets the foreign key to the
        /// Currency table that represents the currency 
        /// of this line item.
        /// </summary>
        public abstract Guid? CurrencyID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the unit price of this item
        /// in the selected currency.
        /// </summary>
        public abstract Decimal? UnitPriceInSelectedCurrency { get; set; }

        /// <summary>
        /// [Column] Gets or sets the unit price of this item in
        /// the base currency.
        /// </summary>
        public abstract Decimal? UnitPrice { get; set; }

        /// <summary>
        /// [Column] Gets or sets the quantity of the material
        /// or service provided by the vendor. This is usually
        /// the same as the QuantityRequired in the ORequestForQuotationItem
        /// object, but vendors can choose to provide less or
        /// more depending on the arrangement.
        /// </summary>
        public abstract Decimal? QuantityProvided { get; set; }

        /// <summary>
        /// This field is not used.
        /// </summary>
        public abstract Decimal? ItemDiscount { get; set; }

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
        /// the quotation object that contains this item.
        /// </summary>
        public abstract ORequestForQuotationVendor RequestForQuotationVendor { get; set; }

        /// <summary>
        /// Gets or sets the ORequestForQuotationItem object that represents
        /// the line item in the request for quotation
        /// that this quote is for.
        /// </summary>
        public abstract ORequestForQuotationItem RequestForQuotationItem { get; set; }

        /// <summary>
        /// Gets or sets the OCurrency object that represents
        /// the currency of the unit price of this line item.
        /// </summary>
        public abstract OCurrency Currency { get; set; }

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
    }
}
