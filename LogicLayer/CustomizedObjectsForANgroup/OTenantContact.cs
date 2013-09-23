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
    [Database("#database"), Map("TenantContact")]
    public partial class TTenantContact : LogicLayerSchema<OTenantContact>
    {
        public SchemaInt AmosOrgID;
        public SchemaInt AmosContactID;
        public SchemaInt AmosBillAddressID;
        public SchemaInt FromAmos;
        public SchemaDateTime updatedOn;
        public SchemaString AddressLine1;
        public SchemaString AddressLine2;
        public SchemaString AddressLine3;
        public SchemaString AddressLine4;

        public SchemaGuid TenantID;
        [Size(255)]
        public SchemaString TenantName;
        [Size(255)]
        public SchemaString Position;
        [Size(255)]
        public SchemaString Department;
        public SchemaString DID;
        public SchemaString Fax;
        public SchemaString Cellphone;
        public SchemaString Phone;
        public SchemaString Email;
        public SchemaText Remarks;
        public SchemaText Likes;
        public SchemaText Dislikes;
        public SchemaText AdditionalInformation;
        

        public TUser Tenant { get { return OneToOne<TUser>("TenantID"); } }

        public SchemaGuid TenantContactTypeID;
        public TCode TenantContactType { get { return OneToOne<TCode>("TenantContactTypeID"); } }
    }


    /// <summary>
    /// </summary>
    public abstract partial class OTenantContact : LogicLayerPersistentObject
    {

        public abstract int? AmosOrgID { get; set; }
        public abstract int? AmosContactID { get; set; }
        public abstract int? AmosBillAddressID { get; set; }
        public abstract int? FromAmos { get; set; }
        public abstract DateTime? updatedOn { get; set; }
        public abstract String AddressLine1 { get; set; }
        public abstract String AddressLine2 { get; set; }
        public abstract String AddressLine3 { get; set; }
        public abstract String AddressLine4 { get; set; }

        public abstract Guid? TenantID { get; set; }
        public abstract String Position { get; set; }
        public abstract String Department { get; set; }
        public abstract String DID { get; set; }
        public abstract String Fax { get; set; }
        public abstract String Cellphone { get; set; }
        public abstract String Phone { get; set; }
        public abstract String Email { get; set; }
        public abstract String Remarks { get; set; }
        public abstract String Likes { get; set; }
        public abstract String Dislikes { get; set; }
        public abstract String AdditionalInformation { get; set; }

        public abstract OUser Tenant { get; set; }
        public abstract Guid? TenantContactTypeID { get; set; }
        public abstract OCode TenantContactType { get; set; }
        public String FromAmosText
        {
            get
            {
                if (this.FromAmos == 1)
                    return "Yes";
                else if (this.FromAmos == 0)
                    return "No";
                else
                    return "";
            }
        }
        public override bool IsDeactivable()
        {
            if (this.FromAmos == 1)
                return false;

            return true;
        }
        public override bool IsRemovable()
        {
            if (this.FromAmos == 1)
                return false;

            return true;
        }

        public static List<OTenantContact> GetTenantContact(int? AmosOrgID)
        {
            return TablesLogic.tTenantContact.LoadList(TablesLogic.tTenantContact.AmosOrgID == AmosOrgID
);
        }
    }
}

