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
    /// <summary>
    /// Summary description for OChecklist
    /// </summary>
    public partial class TCalendar : LogicLayerSchema<OCalendar>
    {
        public SchemaGuid LocationID;
        public TLocation Location { get { return OneToOne<TLocation>("LocationID"); } }

        public SchemaDateTime WorkHourStart;
        public SchemaDateTime WorkHourEnd;

        public SchemaInt FirstDayOfWeek;

        
    }


    /// <summary>
    /// Represents a calendar, usually for a specific region, country, city.
    /// It indicates which days of the weeks are working days, and all the
    /// holidays associated with this calendar.
    /// </summary>

    public abstract partial class OCalendar : LogicLayerPersistentObject
    {
        public abstract Guid? LocationID { get; set; }
        public abstract OLocation Location { get; set; }

        public abstract DateTime? WorkHourStart { get; set; }
        public abstract DateTime? WorkHourEnd { get; set; }

        public abstract int? FirstDayOfWeek { get; set; }
      

    }
}

