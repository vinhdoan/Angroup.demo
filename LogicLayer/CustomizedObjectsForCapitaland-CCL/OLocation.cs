//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
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
    /// Summary description for OLocationType
    /// </summary>

    public partial class TLocation : LogicLayerSchema<OLocation>
    {
        public SchemaString AMOSInstanceID;
        public SchemaString DepartmentCode; //Nguyen Quoc Phuong 19-Nov-2012
        //public SchemaInt SyncCRV; //Nguyen Quoc Phuong 21-Nov-2012
        public SchemaString SystemCode;//Nguyen Quoc Phuong 10-Dec-2012
    }

    public abstract partial class OLocation : LogicLayerPersistentObject, IHierarchy
    {
        public abstract String AMOSInstanceID { get; set; }
        public abstract String DepartmentCode { get; set; } //Nguyen Quoc Phuong 19-Nov-2012
        //public abstract int? SyncCRV { get; set; } //Nguyen Quoc Phuong 21-Nov-2012

        //Nguyen Quoc Phuong 10-Dec-2012
        public abstract string SystemCode { get; set; }
        public int? SyncCRV
        {
            get
            {
                OLocation location = this;
                while (string.IsNullOrEmpty(location.SystemCode) && location.Parent != null)
                    location = location.Parent;
                return string.IsNullOrEmpty(location.SystemCode) ? 0 : 1;
            }
        }
        //End Nguyen Quoc Phuong 10-Dec-2012

        //Nguyen Quoc Phuong 10-Dec-2012
        public string GetSystemCode()
        {
            OLocation location = this;
            while (string.IsNullOrEmpty(location.SystemCode) && location.Parent != null)
                location = location.Parent;
            return location.SystemCode;
        }
        //End Nguyen Quoc Phuong 10-Dec-2012
    }
}
