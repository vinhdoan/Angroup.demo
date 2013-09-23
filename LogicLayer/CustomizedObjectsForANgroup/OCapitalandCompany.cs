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
    [Database("#database"), Map("CapitalandCompany")]
    public partial class TCapitalandCompany : LogicLayerSchema<OCapitalandCompany>
    {
        [Size(255)]
        public SchemaString Description;
        [Size(255)]
        public SchemaString Address;
        [Size(255)]
        public SchemaString Country;
        public SchemaString PostalCode;
        public SchemaString PhoneNo;
        public SchemaString FaxNo;
        [Size(255)]
        public SchemaString ContactPerson;
        public SchemaString RegNo;
        [Size(255)]
        public SchemaString PaymentName;
        public SchemaImage LogoFile;
        [Size(255)]
        public SchemaString LogoFileName;
        public SchemaInt IsDeactivated;
    }


    /// <summary>
    /// </summary>
    public abstract partial class OCapitalandCompany : LogicLayerPersistentObject, IAuditTrailEnabled
    {
        /// <summary>
        /// 
        /// </summary>
        public abstract string Description { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public abstract string Address { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public abstract string Country { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public abstract string PostalCode { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public abstract string PhoneNo { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public abstract string FaxNo { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public abstract string ContactPerson { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public abstract string RegNo { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public abstract string PaymentName { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public abstract byte[] LogoFile { get; set; }
        /// <summary>
        /// 
        /// </summary>
        public abstract string LogoFileName { get; set; }
        public abstract int? IsDeactivated { get; set; }

        public static List<OCapitalandCompany> GetCapitalandCompanies(Guid? includingId)
        {
            return TablesLogic.tCapitalandCompany.LoadList
                (Query.True | 
                TablesLogic.tCapitalandCompany.ObjectID == includingId);
        }

        /// <summary>
        /// Returns a concatenated string of both company
        /// name and the address.
        /// </summary>
        public string ObjectNameAndAddress
        {
            get
            {
                return this.ObjectName + " (" + this.Address + ")";
            }
        }


        /// <summary>
        /// Returns the image URL for the image.
        /// </summary>
        public string ImageUrl
        {
            get
            {
                HttpContext c = HttpContext.Current;

                string url = c.Request.Url.Scheme + "://" + c.Request.Url.Host + c.Request.ApplicationPath + "/components/loadlogo.aspx?ID=" + this.ObjectID;
                return url;
            }
        }
    }
}
