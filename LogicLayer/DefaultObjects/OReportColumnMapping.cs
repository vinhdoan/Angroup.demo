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
    public class TReportColumnMapping: LogicLayerSchema<OReportColumnMapping>
    {
        public SchemaGuid ReportID;
        public SchemaString DataFormatString;
        [Size(255)]
        public SchemaString ColumnName;
        public SchemaString HeaderText;
        public SchemaString ResourceAssemblyName;
        public SchemaString ResourceName;
    }
    public abstract class OReportColumnMapping : LogicLayerPersistentObject
    {
        public abstract Guid? ReportID { get;set;}
        public abstract string DataFormatString { get;set;}
        public abstract string ColumnName { get;set;}
        public abstract string HeaderText { get;set;}
        
        /// <summary>
        /// Gets or sets the resource assembly name used to translate
        /// content in thec column.
        /// </summary>
        public abstract string ResourceAssemblyName { get; set; }

        /// <summary>
        /// Gets or sets the resource name used to translate
        /// content in thec column. For example, Resources.WorkflowStates
        /// </summary>
        public abstract string ResourceName { get; set; }
    }
}
