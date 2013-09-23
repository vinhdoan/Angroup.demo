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
    [Database("#database"), Map("TaxCode")]
    [Serializable] public partial class TTaxCode : LogicLayerSchema<OTaxCode>
    {
        [Size(255)]
        public SchemaString Description;
        public SchemaDecimal TaxPercentage;
        public SchemaDateTime StartDate;
        public SchemaDateTime EndDate;
    }


    /// <summary>
    /// Represents a tax code that stores information about the tax
    /// percentage that can be applied in an invoice by a vendor.
    /// </summary>
    [Serializable] public abstract partial class OTaxCode : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the description of the tax code.
        /// </summary>
        public abstract String Description { get; set; }

        /// <summary>
        /// [Column] Gets or sets the tax percentage. The values must be within 
        /// 0 to 100.
        /// </summary>
        public abstract Decimal? TaxPercentage { get; set; }

        /// <summary>
        /// [Column] Gets or sets the start date this
        /// tax code is valid for selection in an invoice.
        /// </summary>
        public abstract DateTime? StartDate { get; set; }

        /// <summary>
        /// [Column] Gets or sets the end date this
        /// tax code is valid for selection in an invoice.
        /// </summary>
        public abstract DateTime? EndDate { get; set; }

        /// <summary>
        /// Gets a string containing both the tax code's name
        /// and its description.
        /// </summary>
        public string TaxNameAndDescription
        {
            get
            {
                return ObjectName + " " + Description;
            }
        }


        /// <summary>
        /// Get all undeleted tax codes.
        /// </summary>
        /// <returns></returns>
        public static List<OTaxCode> GetAllTaxCodes()
        {
            return TablesLogic.tTaxCode[Query.True];
        }


        /// <summary>
        /// Get all tax codes including the one with the specified ID.
        /// </summary>
        /// <returns></returns>
        public static List<OTaxCode> GetAllTaxCodes(DateTime? invoiceDate, Guid? includingTaxCodeId)
        {
            TTaxCode t = TablesLogic.tTaxCode;
            return t.LoadList(
                (t.IsDeleted == 0 &
                (t.StartDate == null | t.StartDate <= invoiceDate) &
                (t.EndDate == null | t.EndDate >= invoiceDate))
                |
                TablesLogic.tTaxCode.ObjectID == includingTaxCodeId,
                true);
        }

    }

}
