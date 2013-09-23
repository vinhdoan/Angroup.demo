//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
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
    /// <summary>
    /// Summary description for OEquipmentType
    /// </summary>
    [Database("#database"), Map("EquipmentTypeSpare")]
    [Serializable] public partial class TEquipmentTypeSpare : LogicLayerSchema<OEquipmentTypeSpare>
    {
        public SchemaGuid EquipmentTypeID;
        public SchemaGuid CatalogueID;
        public SchemaDecimal Quantity;

        public TEquipmentType EquipmentType { get { return OneToOne<TEquipmentType>("EquipmentTypeID"); } }
        public TCatalogue Catalogue { get { return OneToOne<TCatalogue>("CatalogueID"); } }
    }


    /// <summary>
    /// Represents information about the possible spares that
    /// may be used during the breakdown of an equipment of
    /// a specific equipment type. Note that this record
    /// does not contain information about the actual spares
    /// stored in physical equipment.
    /// </summary>
    [Serializable]
    public abstract partial class OEquipmentTypeSpare : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the 
        /// EquipmentType table.
        /// </summary>
        public abstract Guid? EquipmentTypeID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the 
        /// Catalogue table.
        /// </summary>
        public abstract Guid? CatalogueID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the default quantity that 
        /// should be checked out from the store if an 
        /// equipment of this type is sent for repair.
        /// </summary>
        public abstract Decimal? Quantity { get; set; }

        /// <summary>
        /// Gets or sets the OEquipmentType object that 
        /// represents the equipment type that this spare 
        /// is meant for.
        /// </summary>
        public abstract OEquipmentType EquipmentType { get; set; }

        /// <summary>
        /// Gets or sets the OCatalogue object that 
        /// represents the master catalogue type that this 
        /// spare is of.
        /// </summary>
        public abstract OCatalogue Catalogue { get; set; }

    }
}
