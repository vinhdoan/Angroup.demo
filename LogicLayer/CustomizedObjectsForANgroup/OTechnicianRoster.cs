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

    public class TTechnicianRoster : LogicLayerSchema<OTechnicianRoster>
    {
        public SchemaGuid LocationID;
        public SchemaInt Year;
        public SchemaInt Month;
        public SchemaInt DefaultAssignmentMode;
        public TLocation Location { get { return OneToOne<TLocation>("LocationID"); } }
        public TTechnicianRosterItem TechnicianRosterItems { get { return OneToMany<TTechnicianRosterItem>("TechnicianRosterID"); } }
    }
    public abstract class OTechnicianRoster : LogicLayerPersistentObject
    {
        public abstract Guid? LocationID { get; set; }
        public abstract int? Year { get; set; }
        public abstract int? Month { get; set; }
        public abstract int? DefaultAssignmentMode { get; set; }
        public abstract OLocation Location { get; set; }
        public abstract DataList<OTechnicianRosterItem> TechnicianRosterItems { get; set; }
        public bool IsDuplicateTechnicianRoster()
        {
            OTechnicianRoster techRoster = TablesLogic.tTechnicianRoster.Load(
                                            TablesLogic.tTechnicianRoster.LocationID == this.LocationID &
                                            TablesLogic.tTechnicianRoster.Year == this.Year &
                                            TablesLogic.tTechnicianRoster.Month == this.Month &
                                            TablesLogic.tTechnicianRoster.ObjectID != this.ObjectID);
            if (techRoster != null)
                return true;
            return false;
        }
        public static DataTable BindMonth()
        {
            DataTable dtmonth = new DataTable();
            dtmonth.Columns.Add("Month");
            dtmonth.Columns.Add("MonthName");
            dtmonth.Rows.Add(new object[] { 1, "Jan" });
            dtmonth.Rows.Add(new object[] { 2, "Feb" });
            dtmonth.Rows.Add(new object[] { 3, "Mar" });
            dtmonth.Rows.Add(new object[] { 4, "Apr" });
            dtmonth.Rows.Add(new object[] { 5, "May" });
            dtmonth.Rows.Add(new object[] { 6, "Jun" });
            dtmonth.Rows.Add(new object[] { 7, "Jul" });
            dtmonth.Rows.Add(new object[] { 8, "Aug" });
            dtmonth.Rows.Add(new object[] { 9, "Sep" });
            dtmonth.Rows.Add(new object[] { 10, "Oct" });
            dtmonth.Rows.Add(new object[] { 11, "Nov" });
            dtmonth.Rows.Add(new object[] { 12, "Dec" });
            return dtmonth;
        }
      
        public static DataTable BindYear()
        {
            DataTable dtyear = new DataTable();
            dtyear.Columns.Add("Year");
            for (int i = 2000; i < 2050; i++)
            {
                DataRow dr = dtyear.NewRow();
                dr["Year"] = i;
                dtyear.Rows.Add(dr);
            }
            return dtyear;
        }
        public string AssignmentModeName
        {
            get
            {
                if (this.DefaultAssignmentMode == 0)
                    return "Manually Assign Technicians by Roster";
                else if (this.DefaultAssignmentMode == 1)
                    return "Automatically Assign All";
                else
                    return "Automatically Assign One (in Round-Robin Fashion)";

            }
        }
    }
    public class AssigmentType
    {
        public const int ManuallyAssign = 0;
        public const int AutoAssignAll = 1;
        public const int AutoAssignOne = 2;
    }
}
