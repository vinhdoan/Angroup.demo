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
    [Database("#database"), Map("StoreItemReservation")]
    [Serializable] public partial class TStoreItemReservation : LogicLayerSchema<OStoreItemReservation>
    {
        public SchemaGuid WorkCostID;
        public SchemaGuid StoreID;
        public SchemaGuid CatalogueID;
        public SchemaGuid BinID;
        public SchemaInt IsReservationSuccessful;
        public SchemaGuid UnitOfMeasureID;
        public SchemaDecimal QuantityReserved;
        public SchemaDateTime DateOfReservation;
    }

    /// <summary>
    /// This class is not in use.
    /// </summary>
    [Serializable] public abstract partial class OStoreItemReservation : PersistentObject
    {
        public abstract Guid? WorkCostID { get; set; }
        public abstract Guid? StoreID { get; set; }
        public abstract Guid? CatalogueID { get; set; }
        public abstract Guid? BinID { get; set; }
        public abstract int? IsReservationSuccessful { get; set; }
        public abstract Guid? UnitOfMeasureID { get; set; }
        public abstract Decimal? QuantityReserved { get; set; }
        public abstract DateTime? DateOfReservation { get; set; }


        //----------------------------------------------------------------
        /// <summary>
        /// Try to reserve an item from the store. If successful, set the
        /// IsReservationSuccessful flag to 1 and return true. Otherwise,
        /// set the IsReservationSuccessful flag to 0 and return false.
        /// </summary>
        /// <returns></returns>
        //----------------------------------------------------------------
        public bool ReserveItem()
        {
            return false;
        }


        //----------------------------------------------------------------
        /// <summary>
        /// Unreserves the item from the store by adjusting the corresponding
        /// StoreBinItems' available quantity upwards.
        /// </summary>
        //----------------------------------------------------------------
        public void UnreserveItem()
        {
            if (IsReservationSuccessful == 0)
                return;

        }
    }
}
