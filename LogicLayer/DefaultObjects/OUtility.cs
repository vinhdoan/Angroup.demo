//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
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
    [Database("#database"), Map("Utility")]
    [Serializable] public partial class TUtility : LogicLayerSchema<OUtility>
    {
        public SchemaGuid LocationID;
        [Size(255)]
        public SchemaString Description;
        public SchemaDateTime StartDate;
        public SchemaDateTime EndDate;

        public TUtilityValue UtilityValues { get { return OneToMany<TUtilityValue>("UtilityID"); } }
        public TLocation Location { get { return OneToOne<TLocation>("LocationID"); } }
    }


    /// <summary>
    /// Represents a single bill consisting of multiple line items of 
    /// readings, consumption and cost.
    /// </summary>
    [Serializable] public abstract partial class OUtility : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the Location table 
        /// that indicates the location that this utility entry applies
        /// to.
        /// </summary>
        public abstract Guid? LocationID { get; set; }

        /// <summary>
        /// [Column] Gets or sets a description for this utility entry.
        /// </summary>
        public abstract string Description { get; set; }

        /// <summary>
        /// [Column] Gets or sets the starting date this utility entry
        /// is applicable from. Usually, this is the starting date of
        /// the utility bill.
        /// </summary>
        public abstract DateTime? StartDate { get; set; }

        /// <summary>
        /// [Column] Gets or sets the end date this utility entry
        /// is applicable from. Usually, this is the end date of
        /// the utility bill.
        /// </summary>
        public abstract DateTime? EndDate { get; set; }

        /// <summary>
        /// Gets a one-to-many list of OUtilityValue objects that represents
        /// a list of consumptions readings or costs.
        /// </summary>
        public abstract DataList<OUtilityValue> UtilityValues { get; }

        /// <summary>
        /// Gets or sets the OLocation object that represents
        /// the location that this utility entry applies to.
        /// </summary>
        public abstract OLocation Location { get;set; }

        /// <summary>
        /// Remove any UtilityValue object from the UtilityValues list if it does not have a value
        /// </summary>
        public override void Saving()
        {
            base.Saving();            
            for (int i = this.UtilityValues.Count-1; i >= 0; i--)
            {
                if (this.UtilityValues[i].Value == null)
                {                    
                    this.UtilityValues.Remove(this.UtilityValues[i]);
                }
            }
        }     
    }
}
