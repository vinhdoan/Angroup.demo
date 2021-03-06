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
    public partial class TCalendarHoliday : LogicLayerSchema<OCalendarHoliday>
    {

    }


    /// <summary>
    /// Represents a record containing information about a holiday
    /// in a calendar.
    /// </summary>
    public abstract partial class OCalendarHoliday : LogicLayerPersistentObject
    {
        

    }


}