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
    /// Summary description for OOperatingUnit
    /// </summary>
    [Database("#database"), Map("OperatingUnit")]
    [Serializable]
    public partial class TOperatingUnit : LogicLayerSchema<OOperatingUnit>
    {

    }


    /// <summary>
    /// Represents an operating unit.
    /// </summary>
    [Serializable]
    public abstract partial class OOperatingUnit : LogicLayerPersistentObject
    {

    }
}



