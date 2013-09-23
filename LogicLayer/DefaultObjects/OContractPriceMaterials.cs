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
    [Database("#database"), Map("ContractPriceMaterial")]
    [Serializable] public partial class TContractPriceMaterial : LogicLayerSchema<OContractPriceMaterial>
    {
        public SchemaGuid ContractID;
        public SchemaGuid CatalogueID;
        public SchemaDecimal PriceFactor;

        public TContract Contract { get { return OneToOne<TContract>("ContractID"); } }
        public TCatalogue Catalogue { get { return OneToOne<TCatalogue>("CatalogueID"); } }
    }


    /// <summary>
    /// Represents part of a purchase agreement that indicates
    /// the catalogue items or set of catalogue items set out in the purchase 
    /// agreement contract along with a price factor applied to 
    /// the standard rates indicated in the catalogue items.
    /// </summary>
    [Serializable]
    public abstract partial class OContractPriceMaterial : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the Contract table.
        /// </summary>
        public abstract Guid? ContractID { get; set; }
        /// <summary>
        /// [Column] Gets or sets the foreign key to the Catalogue table.
        /// </summary>
        public abstract Guid? CatalogueID { get; set; }
        /// <summary>
        /// [Column] Gets or sets the price factor that applies to the 
        /// items at and under the Catalogue item associated with this 
        /// agreement, so that when a Purchase Order is tied to this 
        /// contract, all prices of materials are computed by multiplying 
        /// this price factor and the fixed price stated in the 
        /// Catalogue item.
        /// </summary>
        public abstract Decimal? PriceFactor { get; set; }

        /// <summary>
        /// Gets or sets the OContract object that represents the 
        /// contract that is associated with this agreement.
        /// </summary>
        public abstract OContract Contract { get; set; }
        /// <summary>
        /// Gets or sets the OCatalogue object that represents the catalogue item or items that this agreement covers.
        /// </summary>
        public abstract OCatalogue Catalogue { get; set; }

    }


}