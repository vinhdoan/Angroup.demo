//========================================================================
// $Product: Abell Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Text;

using Anacle.DataFramework;

namespace LogicLayer
{
    public partial class TMeter : LogicLayerSchema<OMeter>
    {
 
        public SchemaInt IsActive;
        public SchemaGuid LocationID;
        public SchemaString Barcode;
        public SchemaGuid TypeOfMeterID;
        public SchemaString BMSCode;
        public TCode TypeOfMeter { get { return OneToOne<TCode>("TypeOfMeterID"); } }
        public SchemaGuid UnitOfMeasureID;
        public SchemaInt IsIncreasingMeter;
        public SchemaDecimal Factor;
        public SchemaDecimal MaximumReading;
        public TLocation Location { get { return OneToOne<TLocation>("LocationID"); } }
        public TCode UnitOfMeasure { get { return OneToOne<TCode>("UnitOfMeasureID"); } }
        


    }


    /// <summary>
    /// Represents a condition-monitored point in which the 
    /// readings from any source can be tested against acceptable
    /// limits set up against this point. When the reading exceeds
    /// the acceptable limits, this can be set up to generate
    /// a Work object.
    /// <para></para>
    /// This point can also be associated with an OPC DA server,
    /// so that the OPC service can retrieve readings automatically
    /// from the OPC server.
    /// </summary>
    public abstract partial class OMeter : LogicLayerPersistentObject
    {
       
        public abstract int? IsActive { get; set; }
        public abstract Guid? LocationID { get; set; }
        public abstract string Barcode { get; set; }
        public abstract Guid? UnitOfMeasureID { get; set; }
        public abstract Guid? TypeOfMeterID { get; set; }
        public abstract String BMSCode { get; set; }
        public abstract OLocation Location { get; set; }
        public abstract OCode TypeOfMeter { get; set; }
        public abstract int? IsIncreasingMeter { get; set; }
        public abstract Decimal? MaximumReading { get; set; }
        public abstract Decimal? Factor { get; set; }
        public abstract OCode UnitOfMeasure { get; set; }

        public bool IsDuplicateName()
        {
            TMeter m = TablesLogic.tMeter;
            List<OMeter> list = m.LoadList(
                m.ObjectID != this.ObjectID & m.ObjectName == this.ObjectName &
                    m.LocationID == this.LocationID 
                 &
                m.IsActive == 1
            );
            foreach (OMeter i in list)
                return true;
            return false;
        }
        public bool IsInUsing()
        {
            List<OPoint> points = TablesLogic.tPoint.LoadList(
                TablesLogic.tPoint.meterID == this.ObjectID &
                TablesLogic.tPoint.IsDeleted == 0);
            foreach (OPoint p in points)
                return true;
            return false;
        }
        public string NameAndBarcode
        {
            get
            {
                return this.ObjectName + "(" + this.Barcode + ")";
            }
           
                
        }
    }
}

