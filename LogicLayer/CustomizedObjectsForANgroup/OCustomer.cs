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
    /// Summary description for TCustomer
    /// </summary>
    public partial class TCustomer : LogicLayerSchema<OCustomer>
    {
        public SchemaString CMND;
        public SchemaString CustomerName;
        public SchemaDateTime CustomerDateOfBirth;
        [Size(255)]
        public SchemaString CustomerAddress;
        public TCustomerAccount CustomerAccounts { get { return OneToMany<TCustomerAccount>("CustomerID"); } }
        public SchemaString Email;
        public SchemaString Phone;
    }

    /// <summary>
    /// Summary description for OCustomer
    /// </summary>
    public abstract partial class OCustomer : LogicLayerPersistentObject, IAutoGenerateRunningNumber
    {
        public abstract string CMND { get; set; }
        public abstract string CustomerName { get; set; }
        public abstract DateTime? CustomerDateOfBirth { get; set; }
        public abstract string CustomerAddress { get; set; }
        public abstract DataList<OCustomerAccount> CustomerAccounts { get; set; }
        public abstract string Email { get; set; }
        public abstract string Phone { get; set; }
    }
}

