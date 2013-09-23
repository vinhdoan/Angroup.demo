using System;
using System.Collections.Generic;
using System.Text;
using Anacle.DataFramework;

namespace LogicLayer
{
    /// <summary>
    /// Created by David
    /// </summary>
    public partial class TContractServiceLevelSurvey : LogicLayerSchema<OContractServiceLevelSurvey>
    {
        public SchemaDateTime DateOfInspection;
        [Size(255)]
        public SchemaString Description;
        public SchemaDecimal DemeritScore;
        public SchemaGuid ContractID;
    }


    /// <summary>
    /// Represents a variation log on the budget.
    /// </summary> 
    public abstract partial class OContractServiceLevelSurvey : LogicLayerPersistentObject
    {
        public abstract DateTime? DateOfInspection { get; set; }
        public abstract Guid? ContractID { get; set; }
        public abstract string Description { get; set; }
        public abstract Decimal? DemeritScore { get; set; }
        public override bool IsRemovable()
        {
            return this.IsNew;
        }
    }
}
