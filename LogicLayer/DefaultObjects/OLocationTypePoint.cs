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
    [Database("#database"), Map("LocationTypePoint")]
    [Serializable]
    public partial class TLocationTypePoint : LogicLayerSchema<OLocationTypePoint>
    {
        public SchemaGuid LocationTypeID;
        public SchemaGuid UnitOfMeasureID;

        public SchemaInt IsIncreasingMeter;
        public SchemaDecimal Factor;
        public SchemaDecimal MaximumReading;
        
        [Default(0)]
        public SchemaInt CreateWorkOnBreach;
        public SchemaDecimal MinimumAcceptableReading;
        public SchemaDecimal MaximumAcceptableReading;
        public SchemaInt NumberOfBreachesToTriggerAction;
             
        public SchemaGuid PointTriggerID;
        public SchemaGuid TypeOfWorkID;
        public SchemaGuid TypeOfServiceID;
        public SchemaGuid TypeOfProblemID;
        public SchemaInt Priority;
        [Size(255)]
        public SchemaString WorkDescription;

        public TCode UnitOfMeasure { get { return OneToOne<TCode>("UnitOfMeasureID"); } }
        public TPointTrigger PointTrigger { get { return OneToOne<TPointTrigger>("PointTriggerID"); } }

       
    }
    [Serializable]
    public abstract partial class OLocationTypePoint : LogicLayerPersistentObject
    {

        public abstract Guid? LocationTypeID{ get; set; }
        public abstract Guid? UnitOfMeasureID{ get; set; }

        public abstract int? IsIncreasingMeter{ get; set; }
        public abstract Decimal? Factor{ get; set; }
        public abstract Decimal? MaximumReading{ get; set; }
        
        public abstract int? CreateWorkOnBreach{ get; set; }
        public abstract Decimal? MinimumAcceptableReading{ get; set; }
        public abstract Decimal? MaximumAcceptableReading{ get; set; }
        public abstract int? NumberOfBreachesToTriggerAction{ get; set; }

        public abstract Guid? PointTriggerID{ get; set; }
        public abstract Guid? TypeOfWorkID{ get; set; }
        public abstract Guid? TypeOfServiceID{ get; set; }
        public abstract Guid? TypeOfProblemID{ get; set; }
        public abstract int? Priority{ get; set; }        
        public abstract String WorkDescription{ get; set; }

        public abstract OCode UnitOfMeasure { get; set; }
        public abstract OPointTrigger PointTrigger { get; set; }


        /// <summary>
        /// Gets the text indicating whether this point is
        /// an increasing meter.
        /// </summary>
        public string IsIncreasingMeterText
        {
            get
            {
                if (IsIncreasingMeter == 0)
                    return Resources.Strings.Point_AbsoluteMeter;
                //return "Absolute";
                else if (IsIncreasingMeter == 1)
                    return Resources.Strings.Point_IncreasingMeter;
                //return "Increasing";
                return "";

            }
        }
    }
}