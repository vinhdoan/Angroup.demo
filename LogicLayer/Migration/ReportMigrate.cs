using System;
using System.Collections.Generic;
using System.Text;
using Anacle.DataFramework;
namespace LogicLayer
{
    [Database("#database_migrate"), Map("Report")]
    [Serializable] public partial class TReportMigrate : LogicLayerSchema<OReportMigrate>
    {
        public SchemaInt ContextTree;
        public SchemaGuid CascadeControlID;
        public SchemaInt ReportType;
        public SchemaImage ReportFileBytes;
        [Size(100)]
        public SchemaString ReportFileName;
        public SchemaString CategoryName;
        public SchemaText ReportQuery;
        [Size(255)]
        public SchemaString DataSourceName;
        public SchemaInt OdbcSyntax;
        public SchemaString ParamPrefix;

        public SchemaInt UseCSharpQuery;
        [Size(255)]
        public SchemaString CSharpMethodName;
        public SchemaInt VisibleColumnAtStart;


        public TReportFieldMigrate CascadeControl { get { return OneToOne<TReportFieldMigrate>("CascadeControlID"); } }
        public TReportDataSetMigrate ReportDataSet { get { return OneToMany<TReportDataSetMigrate>("ReportID"); } }
        public TReportFieldMigrate ReportFields { get { return OneToMany<TReportFieldMigrate>("ReportID"); } }
        public TRoleMigrate Roles { get { return ManyToMany<TRoleMigrate>("ReportRole", "ReportID", "DashboardID"); } }
    }
    [Serializable] public abstract partial class OReportMigrate : LogicLayerPersistentObject
    {
        public abstract string DataSourceName { get; set; }
        public abstract Guid? CascadeControlID { get; set; }
        public abstract int? OdbcSyntax { get; set; }
        public abstract string ParamPrefix { get; set; }
        public abstract int? ContextTree { get; set; }
        public abstract int? ReportType { get; set; }
        public abstract byte[] ReportFileBytes { get;set;}
        public abstract string ReportFileName { get; set; }
        public abstract string CategoryName { get; set; }
        public abstract string ReportQuery { get; set; }
        public abstract int? UseCSharpQuery { get; set; }
        public abstract string CSharpMethodName { get; set; }
        public abstract int? VisibleColumnAtStart{get;set;}

        public abstract OReportFieldMigrate CascadeControl { get; set; }
        public abstract DataList<OReportDataSetMigrate> ReportDataSet { get;}
        public abstract DataList<OReportFieldMigrate> ReportFields { get; }
        public abstract DataList<ORoleMigrate> Roles { get; }
    }
}

