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

using Anacle.DataFramework; //DataFramework

namespace LogicLayer
{
    /// <summary>
    /// Summary description for OStoreStockTakeItem
    /// </summary>
    [Database("#database"), Map("StoreStockTakeBinItem")]
    public partial class TStoreStockTakeBinItem : LogicLayerSchema<OStoreStockTakeBinItem>
    {
        public SchemaGuid StoreStockTakeID;
        //public SchemaGuid StoreStockTakeBin;

        public SchemaGuid CatalogueID;
        public SchemaGuid StoreBinID;
        public SchemaGuid StoreBinItemID;

        /// <summary>
        /// Captures the physical quantity of the catalogue item at stock take start.
        /// </summary>
        public SchemaDecimal PhysicalQuantity;
        public SchemaDecimal ObservedQuantity;

        //public TStoreStockTakeBin StoreStockTakeBin { get { return OneToOne<TStoreStockTakeBin>("StoreStockTakeBinID"); } }
        public TCatalogue Catalogue { get { return OneToOne<TCatalogue>("CatalogueID"); } }
        public TStoreBin StoreBin { get { return OneToOne<TStoreBin>("StoreBinID"); } }
        public TStoreBinItem StoreBinItem { get { return OneToOne<TStoreBinItem>("StoreBinItemID"); } }
    }


    public abstract partial class OStoreStockTakeBinItem : LogicLayerPersistentObject //WorkflowPersistentObject
    {
        public abstract Guid? StoreStockTakeID { get; set; }
        //public abstract Guid? StoreStockTakeBinID { get; set; }

        public abstract Guid? CatalogueID { get; set; }
        public abstract Guid? StoreBinID { get; set; }
        public abstract Guid? StoreBinItemID { get; set; }

        public abstract Decimal? PhysicalQuantity { get; set; }
        public abstract Decimal? ObservedQuantity { get; set; }

        //public abstract OStoreStockTakeBin StoreStockTakeBin { get; set; }
        public abstract OCatalogue Catalogue { get; set; }
        public abstract OStoreBin StoreBin { get; set; }
        public abstract OStoreBinItem StoreBinItem { get; set; }
    }
}

