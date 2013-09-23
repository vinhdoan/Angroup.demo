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
    [Database("#database"), Map("StoreRequestItemCheckOut")]
    [Serializable]
    public partial class TStoreRequestItemCheckOut : LogicLayerSchema<OStoreRequestItemCheckOut>
    {
        public SchemaGuid StoreRequestItemID;
        public SchemaGuid StoreBinItemID;
        public SchemaDecimal UnitPrice;
        public SchemaDecimal Quantity;       
        
    }


    /// <summary>
    /// </summary>
    [Serializable]
    public abstract class OStoreRequestItemCheckOut : LogicLayerPersistentObject
    {
        public abstract Guid? StoreRequestItemID { get; set; }
        public abstract Guid? StoreBinItemID { get; set; }
        public abstract decimal? UnitPrice { get; set; }
        public abstract decimal? Quantity { get; set; }    
    }

}
