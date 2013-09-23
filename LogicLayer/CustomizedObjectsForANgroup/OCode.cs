//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Data;
using System.Configuration;
using System.Collections.Generic;
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
    /// Summary description for OCode
    /// </summary>
    public partial class TCode : LogicLayerSchema<OCode>
    {
        public SchemaInt IsWholeNumberUnit;
    }


    /// <summary>
    /// Represents codes that can be attached to other objects for 
    /// categorization. Examples of codes are work types, types of service, 
    /// caller types, vendor classification. 
    /// <para></para>
    /// Code Types are declared hierarchically, and so the hierarchical structure
    /// of the type of Code objects will also follow the Code Types.
    /// <para></para>
    /// As these codes can be entered by the user at the front end through the 
    /// Code module, there should be as little logic tied to these codes as 
    /// possible.
    /// </summary>
    public abstract partial class OCode : LogicLayerPersistentObject, IHierarchy
    {
        public abstract int? IsWholeNumberUnit { get; set; }

        public static List<OCode> GetTenantContactTypes(OUser user, Guid? includingTenantContactTypeID)
        {
            List<OCode> tenantContactTypes = new List<OCode>();
            foreach (OPosition position in user.Positions)
            {
                foreach (OCode c in position.TenantContactTypes)
                    tenantContactTypes.Add(c);
            }
            return TablesLogic.tCode.LoadList(
                        (TablesLogic.tCode.IsDeleted == 0 &
                        TablesLogic.tCode.CodeType.ObjectName == "TenantContactType" &
                        (tenantContactTypes == null ? Query.True :
                        TablesLogic.tCode.ObjectID.In(tenantContactTypes))) |
                        TablesLogic.tCode.ObjectID == includingTenantContactTypeID
                        );

        }
    }
}