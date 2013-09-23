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
using System.Text;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using Anacle.DataFramework;


/// <summary>
/// Summary description for CapitalandCompany
/// </summary>

namespace LogicLayer
{
    public partial class TTenantActivity : LogicLayerSchema<OTenantActivity>
    {
        public SchemaGuid TenantID;
        public SchemaDateTime DateTimeOfActivity;
        [Size(200)]
        public SchemaString NameOfStaff;
        [Size(1000)]
        public SchemaString Agenda;
        public SchemaText Description;
        public SchemaGuid ActivityTypeID;
        public TCode ActivityType { get { return OneToOne<TCode>("ActivityTypeID"); } }
        public TUser Tenants { get { return ManyToMany<TUser>("TenantTenantActivity", "TenantActivityID", "TenantID"); } }
    }


    /// <summary>
    /// </summary>
    public abstract partial class OTenantActivity : LogicLayerPersistentObject
    {
        public abstract Guid? TenantID { get; set; }
        public abstract DateTime? DateTimeOfActivity { get; set; }
        public abstract String NameOfStaff { get; set; }
        public abstract String Agenda { get; set; }
        public abstract string Description { get; set; }
        public abstract Guid? ActivityTypeID { get; set; }
        public abstract OCode ActivityType { get; set; }
        public abstract DataList<OUser> Tenants { get; set; }

        public string TenantNames
        {
            get
            {
                string name = "";
                foreach (OUser tenant in Tenants)
                    name = (name != "" ? name + ", " + tenant.ObjectName : tenant.ObjectName);
                return name;
            }
        }
    }
}

