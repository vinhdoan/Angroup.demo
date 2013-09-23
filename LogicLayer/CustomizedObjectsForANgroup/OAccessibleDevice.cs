using System;
using System.Collections.Generic;
using System.Web;
using System.Configuration;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using Anacle.DataFramework;

namespace LogicLayer
{
    [Database("#database"), Map("AccessibleDevice")]
    [Serializable]
    public partial class TAccessibleDevice : LogicLayerSchema<OAccessibleDevice>
    {
        public SchemaString DeviceHashKey;
        public SchemaInt IsEnable;
    }


    [Serializable]
    public abstract partial class OAccessibleDevice : LogicLayerPersistentObject
    {
        public abstract String DeviceHashKey { get; set; }
        public abstract int? IsEnable { get; set; }
    }

   
}