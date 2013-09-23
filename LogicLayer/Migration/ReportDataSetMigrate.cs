using System;
using System.Collections.Generic;
using System.Text;

using Anacle.DataFramework;
namespace LogicLayer
{
    [Database("#database_migrate"), Map("ReportDataSet")]
    [Serializable] public partial class TReportDataSetMigrate : LogicLayerSchema<OReportDataSetMigrate>
    {
        public SchemaGuid ReportID;
        public SchemaString DataSetName;
        public SchemaText Query;
        public SchemaText ParameterOrder;

        public TReportMigrate Report { get { return OneToOne<TReportMigrate>("ReportID"); } }
    }


    [Serializable] public abstract partial class OReportDataSetMigrate : LogicLayerPersistentObject
    {
        public abstract Guid? ReportID { get; set; }
        public abstract string DataSetName { get; set; }
        public abstract string Query { get;set;}
        public abstract string ParameterOrder { get;set;}

        public abstract OReportMigrate Report { get; }
    }
}

