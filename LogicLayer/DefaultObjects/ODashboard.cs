//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
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
    [Database("#database"), Map("Dashboard")]
    [Serializable] public partial class TDashboard : LogicLayerSchema<ODashboard>
    {

        public SchemaInt DashboardType;
        public SchemaInt DashboardSeriesType;
        public SchemaInt DashboardPieType;
        [Default(0)]
        public SchemaInt DashboardShowHorizontal;
        public SchemaInt Dashboard3D;
        public SchemaText DashboardQuery;

        public SchemaInt XAxisType;
        public SchemaInt YAxisType;
        [Size(255)]
        public SchemaString XAxisColumnName;
        [Size(255)]
        public SchemaString YAxisColumnName;
        [Size(255)]
        public SchemaString SeriesColumnName;
        [Size(255)]
        public SchemaString SizeColumnName;

        [Size(255)]
        public SchemaString XAxisName;
        [Size(255)]
        public SchemaString YAxisName;

        public SchemaInt IsAutoCalibrate;
        [Default(0)]
        public SchemaInt SeriesByColumns;
        public SchemaDecimal YAxisMinimum;
        public SchemaDecimal YAxisMaximum;
        public SchemaDecimal YAxisInterval;

        public SchemaInt UseCSharpQuery;
        [Size(255)]
        public SchemaString CSharpMethodName;
        [Size(255)]
        public SchemaString YAxisLabelText;
        [Size(255)]
        public SchemaString XAxisLabelText;

        public TRole Roles { get { return ManyToMany<TRole>("DashboardRole", "DashboardID", "RoleID"); } }
        public TDashboardField DashboardFields { get { return OneToMany<TDashboardField>("DashboardID"); } }

    }


    [Serializable] public abstract partial class ODashboard : LogicLayerPersistentObject
    {
        public abstract int? DashboardType { get;set;}
        public abstract int? DashboardSeriesType { get;set;}
        public abstract int? DashboardPieType { get;set;}
        public abstract int? DashboardShowHorizontal { get;set;}
        public abstract int? Dashboard3D { get;set;}
        public abstract string DashboardQuery { get;set;}

        public abstract int? XAxisType { get;set;}
        public abstract int? YAxisType { get;set;}
        public abstract String XAxisColumnName { get;set;}
        public abstract String YAxisColumnName { get;set;}
        public abstract String SeriesColumnName { get;set;}
        public abstract String SizeColumnName { get;set;}

        public abstract String XAxisName { get;set;}
        public abstract String YAxisName { get;set;}

        public abstract int? IsAutoCalibrate { get;set;}
        public abstract int? SeriesByColumns { get; set; }
        public abstract Decimal? YAxisMinimum { get;set;}
        public abstract Decimal? YAxisMaximum { get;set;}
        public abstract Decimal? YAxisInterval { get;set;}

        public abstract int? UseCSharpQuery { get; set; }
        public abstract string CSharpMethodName { get; set; }

        public abstract string YAxisLabelText { get;set;}
        public abstract string XAxisLabelText { get;set;}

        public abstract DataList<ORole> Roles { get; }
        public abstract DataList<ODashboardField> DashboardFields { get; }

        public string DashboardTypeText
        {
            get
            {
                if (DashboardType == LogicLayer.DashboardType.Basic)
                    return Resources.Strings.DashboardType_Basic;
                else if (DashboardType == LogicLayer.DashboardType.Bubble)
                    return Resources.Strings.DashboardType_Bubble;
                else if (DashboardType == LogicLayer.DashboardType.Gauge)
                    return Resources.Strings.DashboardType_Gauge;
                else if (DashboardType == LogicLayer.DashboardType.Grid)
                    return Resources.Strings.DashboardType_Grid;
                else if (DashboardType == LogicLayer.DashboardType.Pie)
                    return Resources.Strings.DashboardType_Pie;
                else if (DashboardType == LogicLayer.DashboardType.Polar)
                    return Resources.Strings.DashboardType_Polar;
                else if (DashboardType == LogicLayer.DashboardType.Radar)
                    return Resources.Strings.DashboardType_Radar;
                else if (DashboardType == LogicLayer.DashboardType.Scatter)
                    return Resources.Strings.DashboardType_Scatter;
                return "";
            }
        }



        /// <summary>
        /// Gets a list of dashboards accessible by the 
        /// specified user based on his user roles.
        /// </summary>
        /// <param name="user"></param>
        /// <returns></returns>
        public static List<ODashboard> GetDashboardByUserRoles(OUser user)
        {
            return TablesLogic.tDashboard[
                TablesLogic.tDashboard.Roles.RoleCode.In(user.GetRoleCodes())];
        }


        /// <summary>
        /// Loads all dashboards from the database.
        /// </summary>
        /// <returns></returns>
        public static List<ODashboard> GetAllDashboards()
        {
            return TablesLogic.tDashboard[Query.True];
        }


        /// <summary>
        /// Get all fields that are dropdowns only
        /// </summary>
        /// <returns></returns>
        public List<ODashboardField> GetDropDownDashboardFields()
        {
            List<ODashboardField> dashboardFields = new List<ODashboardField>();
            if (this.DashboardFields.Count > 0)
            {
                foreach (ODashboardField field in this.DashboardFields)
                {
                    if (field.ControlType == 2 || field.ControlType == 3 || field.ControlType == 5)
                        dashboardFields.Add(field);
                }
            }
            return dashboardFields;
        }


        /// <summary>
        /// Get all fields that are dropdowns only
        /// </summary>
        /// <returns></returns>
        public List<ODashboardField> GetDropDownDashboardFields(string excludeFieldName)
        {
            List<ODashboardField> dashboardFields = new List<ODashboardField>();
            if (this.DashboardFields.Count > 0)
            {
                foreach (ODashboardField field in this.DashboardFields)
                {
                    if ((field.ControlType == 2 || field.ControlType == 3 || field.ControlType == 5) &&
                        field.ControlIdentifier != excludeFieldName)
                        dashboardFields.Add(field);
                }
            }
            return dashboardFields;
        }


        /// --------------------------------------------------------------
        /// <summary>
        /// Traverse into the cascading fields to search for loops.
        /// </summary>
        /// <param name="field"></param>
        /// <returns></returns>
        /// --------------------------------------------------------------      
        protected bool TraverseCascade(Hashtable h, ODashboardField field, DataTable cascadeTable)
        {
            Hashtable used = new Hashtable();
            ODashboardField currentField = field;

            while (currentField != null)
            {
                if (used[currentField.ObjectID.Value] != null)
                    return true;  // a loop is found

                used[currentField.ObjectID.Value] = true;
                int count = 0;
                if (currentField.CascadeControl.Count > 0)
                {
                    foreach (ODashboardField f in currentField.CascadeControl)
                    {
                        if (used[f.ObjectID.Value] != null ||
                             IsLoopCascade(cascadeTable, field, f))
                            return true;  // a loop is found
                        count++;
                        used[f.ObjectID.Value] = true;
                        cascadeTable.Rows.Add(new object[] { field.ObjectID.Value.ToString(), f.ObjectID.Value.ToString() });
                        if (count == currentField.CascadeControl.Count)
                            currentField = null;
                    }
                }
                else
                    break;
            }
            return false;
        }

        /// <summary>
        /// Checks to see if any of the fields has cascade loops.
        /// </summary>
        /// <param name="field"></param>
        /// <returns></returns>
        public bool CascadeHasLoops()
        {
            Hashtable h = new Hashtable();
            DataTable cascadeTable = new DataTable();
            cascadeTable.Columns.Add("Field");
            cascadeTable.Columns.Add("CascadeTo");
            foreach (ODashboardField field in this.DashboardFields)
                h[field.ObjectID.Value] = field;

            foreach (ODashboardField field in this.DashboardFields)
                if (TraverseCascade(h, field, cascadeTable))
                    return true;
            return false;
        }


        /// <summary>
        /// Checks if there is a loop cascade between a pair of report fields.
        /// </summary>
        /// <param name="cascadeTable"></param>
        /// <param name="field"></param>
        /// <param name="cascadeTo"></param>
        /// <returns></returns>
        public bool IsLoopCascade(DataTable cascadeTable, ODashboardField field, ODashboardField cascadeTo)
        {
            foreach (DataRow row in cascadeTable.Rows)
            {
                if (row["Field"].ToString() == cascadeTo.ObjectID.Value.ToString()
                    && row["CascadeTo"].ToString() == field.ObjectID.Value.ToString())
                    return true;
            }
            return false;
        }


        /// <summary>
        /// Get all the dashboard fields for this dashboard in display order
        /// </summary>
        /// <returns></returns>
        public List<ODashboardField> GetDashboardFieldsInOrder()
        {
            List<ODashboardField> dashboardFields = new List<ODashboardField>();
            foreach (ODashboardField field in this.DashboardFields)
                dashboardFields.Add(field);
            dashboardFields.Sort("DisplayOrder", true);
            return dashboardFields;
        }


        /// <summary>
        /// Validates to ensure that no two fields have the same identifiers.
        /// </summary>
        /// <returns></returns>
        public bool ValidateNoDuplicateIdentifiers(ODashboardField field)
        {
            foreach (ODashboardField dashboardField in this.DashboardFields)
            {
                if (dashboardField.ObjectID != field.ObjectID &&
                    dashboardField.ControlIdentifier.ToLower() == field.ControlIdentifier.ToLower())
                {
                    return false;
                }
            }
            return true;
        }
    }


    /// <summary>
    /// Enumerates the various axis types.
    /// </summary>
    public class DashboardAxisType
    {
        /// <summary>
        /// A normal numeric or category axis that does not 
        /// have special scaling.
        /// </summary>
        public const int Normal = 0;

        /// <summary>
        /// A stacked axis that stacks a series on
        /// top of another series.
        /// </summary>
        public const int Stacked = 1;

        /// <summary>
        /// A stacked axis that stacks a series on
        /// top of another series and scales their
        /// values to a 100%.
        /// </summary>
        public const int FullStacked = 2;

        /// <summary>
        /// A date/time axis.
        /// </summary>
        public const int DateTime = 3;
    }


    /// <summary>
    /// Enumerates the types of series.
    /// </summary>
    public class DashboardSeriesType
    {
        public const int Bar = 0;
        public const int Line = 1;
        public const int AreaLine = 2;
        public const int Spline = 3;
        public const int AreaSpline = 4;
        public const int Cone = 5;
        public const int Pyramid = 6;
        public const int Cylinder = 7;
    }


    /// <summary>
    /// Enumerates the types of pies charts.
    /// </summary>
    public class DashboardPieType
    {
        public const int Pies = 0;
        public const int NestedPies = 1;
        public const int Donuts = 2;
    }


    /// <summary>
    /// Enumerates the different types of dashboards 
    /// available for display.
    /// </summary>
    public class DashboardType
    {
        public const int Grid = 0;
        public const int Gauge = 1;
        public const int Pie = 2;
        public const int Scatter = 3;
        public const int Bubble = 4;
        public const int Basic = 5;
        public const int Radar = 6;
        public const int Polar = 7;

    }
}

