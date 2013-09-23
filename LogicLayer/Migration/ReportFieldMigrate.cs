using System;
using System.Collections.Generic;
using System.Text;
using Anacle.DataFramework;
namespace LogicLayer
{
    [Database("#database_migrate"), Map("ReportField")]
    [Serializable] public partial class TReportFieldMigrate : LogicLayerSchema<OReportFieldMigrate>
    {
        public SchemaGuid ReportID;
        public SchemaInt DisplayOrder;
        public SchemaString ControlIdentifier;
        public SchemaString ControlCaption;
        public SchemaInt ControlSpan;
        public SchemaInt ControlType;
        public SchemaInt DataType;

        public SchemaInt IsPopulatedByQuery;
        public SchemaText TextList;
        public SchemaText ValueList;
        public SchemaText ListQuery;
        public SchemaString DataTextField;
        public SchemaString DataValueField;
        public SchemaGuid CascadeControlID;

        public TReportMigrate Report { get { return OneToOne<TReportMigrate>("ReportID"); } }
        public TReportFieldMigrate CascadeControl { get { return OneToOne<TReportFieldMigrate>("CascadeControlID"); } }
    }


    [Serializable] public abstract partial class OReportFieldMigrate : LogicLayerPersistentObject
    {
        public abstract Guid? ReportID { get; set; }
        public abstract int? DisplayOrder { get; set; }
        public abstract String ControlIdentifier { get; set; }
        public abstract String ControlCaption { get; set; }
        public abstract int? ControlSpan { get; set; }
        public abstract int? ControlType { get; set; }
        public abstract int? DataType { get; set; }

        public abstract int? IsPopulatedByQuery { get; set; }
        public abstract String TextList { get; set; }
        public abstract String ValueList { get; set; }
        public abstract string ListQuery { get; set; }
        public abstract String DataTextField { get; set; }
        public abstract String DataValueField { get; set; }
        public abstract Guid? CascadeControlID { get; set; }

        public abstract DataList<OReportMigrate> Report { get; set; }
        public abstract OReportFieldMigrate CascadeControl { get; set; }
    }
}
