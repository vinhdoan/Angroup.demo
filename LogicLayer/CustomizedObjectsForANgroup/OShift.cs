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

    public class TShift : LogicLayerSchema<OShift>
    {
        public SchemaInt IsNonWorkingShift;
        public SchemaDateTime StartTime;
        public SchemaDateTime EndTime;
        
    }

    public abstract class OShift : LogicLayerPersistentObject
    {
        public abstract Int32? IsNonWorkingShift { get; set; }
        public abstract DateTime? StartTime { get; set; }
        public abstract DateTime? EndTime { get; set; }


        public override void Saving()
        {
            base.Saving();
            if (this.IsNonWorkingShift == 1)
            {
                this.EndTime = null;
                this.StartTime = null;
            }
        }
    }

}
