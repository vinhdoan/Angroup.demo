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
    
    public partial class TTenantContact : LogicLayerSchema<OTenantContact>
    {
        public SchemaGuid LocationID;
        public SchemaString AMOSInstanceID;
        public TTenantLease TenantLeases { get { return OneToMany<TTenantLease>("TenantContactID"); } }

        public TLocation Location { get { return OneToOne<TLocation>("LocationID"); } }
    }


    /// <summary>
    /// </summary>
    public abstract partial class OTenantContact : LogicLayerPersistentObject
    {
        public abstract Guid? LocationID { get; set; }
        public abstract String AMOSInstanceID { get; set; }

        //public List<OTenantLease> TenantLeases 
        //{
        //    get
        //    {
        //        return TablesLogic.tTenantLease.LoadList(TablesLogic.tTenantLease.TenantContactID == this.ObjectID);
        //    }
        //}

        public abstract DataList<OTenantLease> TenantLeases { get; set; }

        public abstract OLocation Location { get; set; }

        public string TenantLeasesLocations
        {
            get
            {
                string strLocation = "";
                this.TenantLeases.Sort("Location.FastPath", true);
                foreach (OTenantLease lease in TenantLeases)
                {
                    OLocation location = lease.Location;
                    string loc = location.Parent.Parent.ObjectName + " > " + location.Parent.ObjectName + " > " + location.ObjectName;
                    strLocation = strLocation == "" ? strLocation + loc : strLocation + "<br> " + loc;                    
                }
                return strLocation;
            }
        }
    
    }
}

