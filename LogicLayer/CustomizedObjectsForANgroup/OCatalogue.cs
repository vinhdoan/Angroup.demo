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
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using Anacle.DataFramework;

namespace LogicLayer
{
    public partial class TCatalogue : LogicLayerSchema<OCatalogue>
    {
        public SchemaDecimal DefaultChargeOut;
        public SchemaInt IsRemovedAfterExpended;
        public SchemaInt IsSharedAcrossAllStores;
        [Size(255)]
        public SchemaString ObtainedMethod;
        public SchemaInt HasInputTax;
        public SchemaInt PremiumType;
        public TStore Store { get { return ManyToMany<TStore>("CatalogueStores", "CatalogID", "StoreID"); } }
    }


    /// <summary>
    /// Represents a master catalogue of store items that can be tracked
    /// by this system. Apart from tracking stock code, manufacturer 
    /// information, this also tracks the standard unit price for this 
    /// item, which may then be used in a purchase agreement to cost 
    /// for purchase of store items in a purchase order.
    /// </summary>
    public abstract partial class OCatalogue : LogicLayerPersistentObject, IHierarchy, IAutoGenerateRunningNumber
    {
        /// <summary>
        /// [Column] Gets or sets the DefaultChargeOut.
        /// </summary>
        public abstract decimal? DefaultChargeOut { get; set; }

        /// <summary>
        /// 
        /// </summary>
        public abstract int? PremiumType { get; set; }
        /// <summary>
        /// [Column] Gets or sets the IsRemovedAFterExpended.
        /// </summary>
        public abstract int? IsRemovedAfterExpended { get; set; }

        /// <summary>
        /// [Column] Gets or sets the IsSharedAcrossAllStores.
        /// </summary>
        public abstract int? IsSharedAcrossAllStores { get; set; }

        /// <summary>
        /// [Column] Gets or sets the method this catalog
        /// was obtained from.
        /// </summary>
        public abstract string ObtainedMethod { get; set; }

        /// <summary>
        /// [Column] Gets or sets the method whether this catalog
        /// item has input tax or not.
        /// <list>
        ///     <items>0 - No </items>
        ///     <items>1 - Yes </items>
        /// </list>
        /// </summary>
        public abstract int? HasInputTax { get; set; }

        /// <summary>
        /// Gets a list of stores 
        /// </summary>
        public abstract DataList<OStore> Store { get; }


        // 2010.10.08
        // Kim Foong
        // Consider commenting this off. Not necessary anymore.
        // Should use "Catalogue.Parent.ObjectName"
        public string ParentFolder
        {
            get
            {
                string parentname = "";
                DataTable dt = TablesLogic.tCatalogue.Select(
                TablesLogic.tCatalogue.ObjectName,
                TablesLogic.tCatalogue.Parent.ObjectName,
                TablesLogic.tCatalogue.Parent.Parent.ObjectName,
                TablesLogic.tCatalogue.Parent.Parent.Parent.ObjectName,
                TablesLogic.tCatalogue.Parent.Parent.Parent.Parent.ObjectName,
                TablesLogic.tCatalogue.Parent.Parent.Parent.Parent.Parent.ObjectName,
                TablesLogic.tCatalogue.Parent.Parent.Parent.Parent.Parent.Parent.ObjectName,
                TablesLogic.tCatalogue.Parent.Parent.Parent.Parent.Parent.Parent.Parent.ObjectName,
                TablesLogic.tCatalogue.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.ObjectName,
                TablesLogic.tCatalogue.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.ObjectName
                )
                .Where(
                    TablesLogic.tCatalogue.ObjectID == this.ObjectID);
                for (int i = 0; i < dt.Columns.Count; i++)
                {
                    if (dt.Rows[0][i].ToString() != null && dt.Rows[0][i].ToString() != "")
                    {
                        parentname = dt.Rows[0][i].ToString();
                        if (i > 0)
                        {
                            parentname = dt.Rows[0][i-1].ToString();
                        }
                    }
                }

                return parentname;
            }
        }

        /// <summary>
        /// Gets the location indicated by this catalogue.
        /// </summary>
        public override List<OLocation> TaskLocations
        {
            get
            {                
                List<OLocation> l  = new List<OLocation>();
                foreach (OStore s in this.Store)
                    l.Add(s.Location);                    
                return l;
            }
        }

        //15th March 2011, Joey:
        /// <summary>
        /// Set object number as - if it is a catalogue group 
        /// </summary>
        public override void Saving()
        {   
            base.Saving();
            if (this.IsNew && 
                this.IsCatalogueItem != null && 
                this.IsCatalogueItem != 1)
            {
                this.ObjectNumber = '-'.ToString();
            }
        }
    }
}