//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
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

    public class TVendorContact : LogicLayerSchema<OVendorContact>
    {
        [Size(255)]
        public SchemaString Position;
        public SchemaString ClientDept;
        public SchemaString Phone;
        public SchemaString Fax;
        public SchemaString Email;
        public SchemaString Cellphone;
        public SchemaGuid VendorID;

    }


    public abstract class OVendorContact : LogicLayerPersistentObject
    {
        public abstract String Position { get; set; }
        public abstract String ClientDept { get; set; }
        public abstract String Phone { get; set; }
        public abstract String Fax { get; set; }
        public abstract String Email { get; set; }
        public abstract String Cellphone { get; set; }
        public abstract Guid? VendorID { get; set; }
    }

}
