//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Text;
using Anacle.DataFramework;

namespace LogicLayer
{
    [Database("#database"), Map("ReportDataSet")]
    [Serializable] public partial class TReportDataSet : LogicLayerSchema<OReportDataSet>
    {
        public SchemaGuid ReportID;
        public SchemaString DataSetName;
        public SchemaText Query;
        public SchemaText ParameterOrder;

        public TReport Report { get { return OneToOne<TReport>("ReportID"); } }
    }


    [Serializable] public abstract partial class OReportDataSet : LogicLayerPersistentObject
    {
        public abstract Guid? ReportID { get; set; }
        public abstract string DataSetName { get; set; }
        public abstract string Query { get;set;}
        public abstract string ParameterOrder { get;set;}

        public abstract OReport Report { get; }
    }

}
