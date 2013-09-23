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
    [Database("#database"), Map("StoreCheckOutItem")]
    [Serializable] public partial class TStoreCheckOutItem : LogicLayerSchema<OStoreCheckOutItem>
    {
        public SchemaGuid StoreCheckOutID;
        public SchemaGuid CatalogueID;
        public SchemaGuid StoreBinID;
        public SchemaDecimal BaseQuantity;
        public SchemaDecimal BaseQuantityCheckedOut;
        public SchemaDecimal EstimatedUnitCost;
        public SchemaGuid ActualUnitOfMeasureID;
        public SchemaDecimal ActualQuantity;

        public TCatalogue Catalogue { get { return OneToOne<TCatalogue>("CatalogueID"); } }
        public TStoreCheckOut StoreCheckOut { get { return OneToOne<TStoreCheckOut>("StoreCheckOutID"); } }
        public TStoreItem StoreItem { get { return OneToOne<TStoreItem>("StoreItemID"); } }
        public TStoreBin StoreBin { get { return OneToOne<TStoreBin>("StoreBinID"); } }
        public TCode ActualUnitOfMeasure { get { return OneToOne<TCode>("ActualUnitOfMeasureID"); } }
    }


    /// <summary>
    /// Represents a record containing information about the item to check out.
    /// </summary>
    [Serializable] public abstract partial class OStoreCheckOutItem : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the StoreCheckOut table.
        /// </summary>
        public abstract Guid? StoreCheckOutID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Catalogue table
        /// that indicates the catalogue of the item to be checked out.
        /// </summary>
        public abstract Guid? CatalogueID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the StoreBin table
        /// that indicates the store bin to check out from.
        /// </summary>
        public abstract Guid? StoreBinID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the quantity (in the original
        /// item's base unit of measure) to check out.
        /// </summary>
        public abstract Decimal? BaseQuantity { get; set; }

        /// <summary>
        /// [Column] Gets or sets the quantity (in the original
        /// item's base unit of measure) that has been successfully 
        /// check out.
        /// </summary>
        public abstract Decimal? BaseQuantityCheckedOut { get; set; }

        /// <summary>
        /// [Column] Gets or sets the estimated unit cost
        /// of the items that will be checked out.
        /// <para></para>
        /// This estimated unit cost is used only for determining
        /// who in the approval hierarchy to send to for approval.
        /// <para></para>
        /// The actual unit cost of items checked out will be known
        /// once the check-out is approved and committed.
        /// </summary>
        public abstract Decimal? EstimatedUnitCost { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Code table
        /// that the check-out unit of measure to check out the item. If
        /// this is different from the item's base unit of measure,
        /// the actual quantity will be converted to a base quantity
        /// as defined in the Unit Conversion module.
        /// </summary>
        public abstract Guid? ActualUnitOfMeasureID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the quantity of items to check
        /// out in the check-out unit of measure.
        /// </summary>
        public abstract Decimal? ActualQuantity { get; set; }

        public bool Valid = true;

        /// <summary>
        /// Gets or sets the OCatalogue object that represents
        /// the catalogue of the item to be checked out.
        /// </summary>
        public abstract OCatalogue Catalogue { get; set; }

        /// <summary>
        /// Gets or sets the OStoreCheckOut object that represents
        /// the main check-out object that contains this record.
        /// </summary>
        public abstract OStoreCheckOut StoreCheckOut { get; set; }

        /// <summary>
        /// Gets or sets the OStoreBin object that represents
        /// the store bin to check the items out from.
        /// </summary>
        public abstract OStoreBin StoreBin { get; set; }

        /// <summary>
        /// Gets or sets the OCode object that represents
        /// the check-out unit of measure to check out the item. 
        /// If this is different from the item's base unit of measure,
        /// the actual quantity will be converted to a base quantity
        /// as defined in the Unit Conversion module.
        /// </summary>
        public abstract OCode ActualUnitOfMeasure { get; set; }


        /// <summary>
        /// Gets a text to be displayed on screen for an example of the conversion of units.
        /// </summary>
        public string ConversionText
        {
            get
            {
                if (CatalogueID != null && ActualUnitOfMeasureID != null)
                {
                    decimal conversionFactor = OUnitConversion.FindConversionFactor((Guid)Catalogue.UnitOfMeasureID, (Guid)ActualUnitOfMeasureID);

                    if (conversionFactor > 0 && (Guid)Catalogue.UnitOfMeasureID != (Guid)ActualUnitOfMeasureID)
                        return 
                            "1 " + Catalogue.UnitOfMeasure.ObjectName + " = " + conversionFactor + " " + ActualUnitOfMeasure.ObjectName + "; " +
                            "1 " + ActualUnitOfMeasure.ObjectName + " = " + 1 / conversionFactor + " " + Catalogue.UnitOfMeasure.ObjectName + "; " +
                            "";
                }
                return "";
            }
        }


        /// <summary>
        /// Gets the sub-total as the unit price multiplied
        /// by the quantity.
        /// </summary>
        public decimal? SubTotal
        {
            get
            {
                return this.EstimatedUnitCost * this.BaseQuantity;
            }
        }


        public void ComputeBaseQuantity()
        {
            decimal conversionFactor = OUnitConversion.FindConversionFactor((Guid)Catalogue.UnitOfMeasureID, (Guid)ActualUnitOfMeasureID);
            if (conversionFactor <= 0)
                this.BaseQuantity = null;
            else
                this.BaseQuantity = (decimal)this.ActualQuantity / conversionFactor;
        }


        /// <summary>
        /// Computes the estimated unit cost of the check out items.
        /// </summary>
        public void ComputeEstimatedUnitCost()
        {
            decimal estimatedUnitCost = 0;
            decimal estimatedTotalCost = 0;


            this.StoreBin.Store.PeekItemsUnitCost(
                this.StoreBinID.Value,
                this.CatalogueID.Value,
                this.ActualQuantity.Value,
                this.ActualUnitOfMeasureID.Value,
                out estimatedUnitCost,
                out estimatedTotalCost);

            this.EstimatedUnitCost = estimatedUnitCost;
        }
    }
}
