//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Data;
using Anacle.DataFramework;

namespace LogicLayer
{
    /// <summary>
    /// Summary description for OAccount
    /// </summary>
    public partial class TAccount : LogicLayerSchema<OAccount>
    {
    }

    public abstract partial class OAccount : LogicLayerPersistentObject, IHierarchy, IAuditTrailEnabled
    {
        public string ParentPath
        {
            get
            {
                DataSet ds = Connection.ExecuteQuery("#database",
                    " select " +
                    " isnull(la.objectname + ' > ', '') + " +
                    " isnull(l9.objectname + ' > ', '') + " +
                    " isnull(l8.objectname + ' > ', '') + " +
                    " isnull(l7.objectname + ' > ', '') + " +
                    " isnull(l6.objectname + ' > ', '') + " +
                    " isnull(l5.objectname + ' > ', '') + " +
                    " isnull(l4.objectname + ' > ', '') + " +
                    " isnull(l3.objectname + ' > ', '') + " +
                    " isnull(l2.objectname, '') " +
                    " from account l1 " +
                    " left join account l2 on l1.parentid = l2.objectid " +
                    " left join account l3 on l2.parentid = l3.objectid " +
                    " left join account l4 on l3.parentid = l4.objectid " +
                    " left join account l5 on l4.parentid = l5.objectid " +
                    " left join account l6 on l5.parentid = l6.objectid " +
                    " left join account l7 on l6.parentid = l7.objectid " +
                    " left join account l8 on l7.parentid = l8.objectid " +
                    " left join account l9 on l8.parentid = l9.objectid " +
                    " left join account la on l9.parentid = la.objectid " +
                    " where l1.objectid = @ObjectID " +
                    " group by la.objectname, l9.objectname, l8.objectname, " +
                    " l7.objectname, l6.objectname, l5.objectname, " +
                    " l4.objectname, l3.objectname, l2.objectname ",
                    Anacle.DataFramework.Parameter.Create("ObjectID", this.ObjectID.Value));

                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0
                    && ds.Tables[0].Rows[0][0] != DBNull.Value)
                    return (string)ds.Tables[0].Rows[0][0];
                else
                    return "";
            }
        }

        public string FullPath
        {
            get
            {
                DataSet ds = Connection.ExecuteQuery("#database",
                    " select " +
                    " isnull(la.objectname + ' > ', '') + " +
                    " isnull(l9.objectname + ' > ', '') + " +
                    " isnull(l8.objectname + ' > ', '') + " +
                    " isnull(l7.objectname + ' > ', '') + " +
                    " isnull(l6.objectname + ' > ', '') + " +
                    " isnull(l5.objectname + ' > ', '') + " +
                    " isnull(l4.objectname + ' > ', '') + " +
                    " isnull(l3.objectname + ' > ', '') + " +
                    " isnull(l2.objectname + ' > ', '') + " +
                    " isnull(l1.objectname, '') " +
                    " from account l1 " +
                    " left join account l2 on l1.parentid = l2.objectid " +
                    " left join account l3 on l2.parentid = l3.objectid " +
                    " left join account l4 on l3.parentid = l4.objectid " +
                    " left join account l5 on l4.parentid = l5.objectid " +
                    " left join account l6 on l5.parentid = l6.objectid " +
                    " left join account l7 on l6.parentid = l7.objectid " +
                    " left join account l8 on l7.parentid = l8.objectid " +
                    " left join account l9 on l8.parentid = l9.objectid " +
                    " left join account la on l9.parentid = la.objectid " +
                    " where l1.objectid = @ObjectID " +
                    " group by la.objectname, l9.objectname, l8.objectname, " +
                    " l7.objectname, l6.objectname, l5.objectname, " +
                    " l4.objectname, l3.objectname, l2.objectname, l1.objectname ",
                    Anacle.DataFramework.Parameter.Create("ObjectID", this.ObjectID.Value));

                if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0
                    && ds.Tables[0].Rows[0][0] != DBNull.Value)
                    return (string)ds.Tables[0].Rows[0][0];
                else
                    return "";
            }
        }

        /// <summary>
        /// Determines whether this account is capex.
        /// This method will determine IsCapex based on the level 3 of hierarchy path.
        /// All Accounts -> Ops -> Capex : This is level 3.
        /// </summary>
        /// <returns>
        ///   <c>true</c> if this instance is capex; otherwise, <c>false</c>.
        /// </returns>
        public bool IsCapex()
        {
            //Each lvl hass 25 chars
            if (this.HierarchyPath.Length >= 75)
            {
                string levelthreepath = this.HierarchyPath.Substring(0, 75);
                List<OAccount> lvlthreeAcc = TablesLogic.tAccount.LoadList(TablesLogic.tAccount.HierarchyPath == levelthreepath);
                if (lvlthreeAcc.Count != 1)
                    throw new Exception("No or more than 1 account with hierarchy path " + levelthreepath + " found.");
                else if (lvlthreeAcc[0].ObjectName.Contains("Capex"))
                    return true;
            }
            return false;
        }
    }
}