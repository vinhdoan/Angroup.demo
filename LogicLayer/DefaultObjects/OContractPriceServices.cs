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
    [Database("#database"), Map("ContractPriceService")]
    [Serializable] public partial class TContractPriceService : LogicLayerSchema<OContractPriceService>
    {
        public SchemaGuid ContractID;
        public SchemaGuid FixedRateID;
        public SchemaDecimal PriceFactor;

        public TContract Contract { get { return OneToOne<TContract>("ContractID"); } }
        public TFixedRate FixedRate { get { return OneToOne<TFixedRate>("FixedRateID"); } }
    }


    /// <summary>
    /// Represents part of a purchase agreement that indicates
    /// the fixed rates or set of fixed rates set out in the purchase 
    /// agreement contract along with a price factor applied to 
    /// the standard rates indicated in the fixed rates.
    /// </summary>
    [Serializable]
    public abstract partial class OContractPriceService : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the Contract table.
        /// </summary>
        public abstract Guid? ContractID { get; set; }
        /// <summary>
        /// [Column] Gets or sets the foreign key to the 
        /// FixedRates table.
        /// </summary>
        public abstract Guid? FixedRateID { get; set; }
        /// <summary>
        /// [Column] Gets or sets the price factor that applies to the 
        /// items at and under the FixedRate item associated with this 
        /// agreement, so that when a Purchase Order is tied to this 
        /// contract, all prices of services are computed by multiplying 
        /// this price factor and the fixed price stated in the 
        /// FixedRate item.
        /// </summary>
        public abstract Decimal? PriceFactor { get; set; }

        /// <summary>
        /// Gets or sets the OContract object that represents the 
        /// contract that is associated with this agreement.
        /// </summary>
        public abstract OContract Contract { get; set; }
        /// <summary>
        /// Gets or sets the OFixedRate object that represents the fixed rate item or items that this agreement covers.
        /// </summary>
        public abstract OFixedRate FixedRate { get; set; }

    }
}
