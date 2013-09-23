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
    /// </summary>
    [Database("#database"), Map("StoreBinReservation")]
    [Serializable] public partial class TStoreBinReservation : LogicLayerSchema<OStoreBinReservation>
    {
        public SchemaGuid WorkCostID;
        public SchemaGuid StoreRequestItemID;
        public SchemaGuid StoreBinID;
        public SchemaGuid CatalogueID;
        public SchemaDecimal BaseQuantityRequired;
        public SchemaDecimal BaseQuantityReserved;
        public SchemaDateTime DateOfReservation;
        public SchemaDateTime DateOfUse;

        public TWorkCost WorkCost { get { return OneToOne<TWorkCost>("WorkCostID"); } }
        public TStoreRequestItem StoreRequestItem { get { return OneToOne<TStoreRequestItem>("StoreRequestItemID"); } }
        public TStoreBin StoreBin { get { return OneToOne<TStoreBin>("StoreBinID"); } }
        public TCatalogue Catalogue { get { return OneToOne<TCatalogue>("CatalogueID"); } }
    }


    /// <summary>
    /// Represents a reservation record raised by the Work 
    /// module to hold items from being checked out, so that 
    /// the Work module may consume and check-out these
    /// items at a later time.
    /// </summary>
    [Serializable] public abstract partial class OStoreBinReservation : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the WorkCost table to indicate the WorkCost line item that resulted in this reservation.
        /// </summary>
        public abstract Guid? WorkCostID { get; set; }
        /// <summary>
        /// [Column] Gets or sets the foreign key to the StoreRequest table to indicate the StoreRequest line item that resulted in this reservation.
        /// </summary>
        public abstract Guid? StoreRequestItemID { get; set; }
        /// <summary>
        /// [Column] Gets or sets the foreign key to the StoreBin table to indicate the bin the reservation is made against.
        /// </summary>
        public abstract Guid? StoreBinID { get; set; }
        /// <summary>
        /// [Column] Gets or sets the foreign key to the Catalogue table to indicate the item to be reserved.
        /// </summary>
        public abstract Guid? CatalogueID { get; set; }
        /// <summary>
        /// [Column] Gets or sets the base quantity required by
        /// the Work.
        /// </summary>
        public abstract Decimal? BaseQuantityRequired { get; set; }
        /// <summary>
        /// [Column] Gets or sets the base quantity eventually 
        /// reserved by the work. This must be less than or equals
        /// to the quantity required.
        /// </summary>
        public abstract Decimal? BaseQuantityReserved { get; set; }
        /// <summary>
        /// [Column] Gets or sets the system date/time at the point the 
        /// reservation was made.
        /// </summary>
        public abstract DateTime? DateOfReservation { get; set; }
        /// <summary>
        /// [Column] Gets or sets the expected date/time this item 
        /// is required for use in the Work.
        /// </summary>
        public abstract DateTime? DateOfUse { get; set; }

        /// <summary>
        /// Gets or sets the OWorkCost object that represents the 
        /// work cost line item that resulted in this reservation.
        /// </summary>
        public abstract OWorkCost WorkCost { get; set; }
        /// <summary>
        /// Gets or sets the OStoreRequest object that represents the 
        /// Store Request line item that resulted in this reservation.
        /// </summary>
        public abstract OStoreRequestItem StoreRequestItem { get; set; }
        /// <summary>
        /// Gets or sets the OStoreBin object that represents the bin 
        /// this reservation is for. Note that the reservation must 
        /// identify both the store and the bin.
        /// </summary>
        public abstract OStoreBin StoreBin { get; set; }
        /// <summary>
        /// Gets or sets the OCatalogue object that represents the 
        /// item to be reserved.
        /// </summary>
        public abstract OCatalogue Catalogue { get; set; }


        //----------------------------------------------------------------
        /// <summary>
        /// Adjust the reservation quantity.
        /// </summary>
        /// <param name="quantityToAdjust"></param>
        //----------------------------------------------------------------
        internal void AdjustReservation(decimal quantityToAdjust)
        {
            BaseQuantityReserved += quantityToAdjust;
            if (BaseQuantityReserved > BaseQuantityRequired)
                BaseQuantityReserved = BaseQuantityRequired;
            if (BaseQuantityReserved < 0)
                BaseQuantityReserved = 0;

            this.Save();
        }


    }

}
