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

    public partial class TVendor : LogicLayerSchema<OVendor>
    {
        public SchemaString GSTRegistrationNumber;
        public SchemaString CompanyRegistrationNumber;
        public SchemaInt IsInterestedParty;

        public SchemaString OperatingAddressPostalCode;
        public SchemaString BillingAddressPostalCode;

        public SchemaString VendorSAPCode;

        public TVendorContact VendorContacts { get { return OneToMany<TVendorContact>("VendorID"); } }
    }


    public abstract partial class OVendor : LogicLayerPersistentObject, IAuditTrailEnabled
    {
        public abstract string GSTRegistrationNumber { get; set; }
        public abstract string CompanyRegistrationNumber { get; set; }
        public abstract int? IsInterestedParty { get; set; }

        public abstract string OperatingAddressPostalCode { get; set; }
        public abstract string BillingAddressPostalCode { get; set; }

        public abstract string VendorSAPCode { get; set; }

        public string IsInterestedPartyText
        {
            get
            {
                if (IsInterestedParty == 0)
                    return Resources.Strings.General_No;
                if (IsInterestedParty == 1)
                    return Resources.Strings.General_Yes;
                return "";
            }
        }

        /// <summary>
        /// Html text to display ipt vendor indication in red for message template
        /// </summary>
        public string IsInterestedPartyTextHighlighted
        {
            get
            {
                string str = "<font style='color: Red; font-weight: Bold;'>{0}</font>";

                if (this.IsInterestedParty == 1)
                    return String.Format(str, Resources.Strings.General_Yes);
                return Resources.Strings.General_No;
            }
        }

        public abstract DataList<OVendorContact> VendorContacts { get; set; }
    }

}
