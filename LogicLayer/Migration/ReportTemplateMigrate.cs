using System;
using System.Collections.Generic;
using System.Text;
using Anacle.DataFramework;
namespace LogicLayer
{
    [Database("#database_migrate"), Map("ReportTemplate")]
    [Serializable] public partial class TReportTemplateMigrate : LogicLayerSchema<OReportTemplateMigrate>
    {
        //reference to the report that this template is made for
        public SchemaGuid ReportID;
        //indicate the access control setting for the template: 1 is editable by public, 2 is editable by creator and viewable by all users, 3: editable and viewable by creator only
        public SchemaInt AccessControl;
        //store the columns setting of the report in XML format
        public SchemaText ReportXML;
        public SchemaString Description;
        public SchemaGuid CreatorID;
        public TReportMigrate Report { get { return OneToOne<TReportMigrate>("ReportID"); } }
        public TUser CreatorUser { get { return OneToOne<TUser>("CreatorID"); } }

    }


    [Serializable] public abstract partial class OReportTemplateMigrate : LogicLayerPersistentObject
    {
        public abstract Guid? ReportID { get; set; }
        public abstract int? AccessControl { get; set; }
        public abstract string ReportXML { get; set; }
        public abstract string Description { get; set; }
        public abstract Guid? CreatorID { get; set; }


        public abstract OUser CreatorUser { get; }
        public abstract OReportMigrate Report { get; }
    }

}
