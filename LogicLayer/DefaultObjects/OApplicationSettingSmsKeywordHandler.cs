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
    //--------------------------------------------------------
    // TO REMOVE THIS!
    //--------------------------------------------------------
    public class TApplicationSettingSmsKeywordHandler : LogicLayerSchema<OApplicationSettingSmsKeywordHandler>
    {
        public SchemaGuid ApplicationSettingID;
        [Size(255)]
        public SchemaString Keywords;
        [Size(255)]
        public SchemaString HandlerUrl;
    }

    public abstract class OApplicationSettingSmsKeywordHandler : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets a foreign key to the ApplicationSetting
        /// table that indicates the application setting that this
        /// keyword handler belongs under.
        /// </summary>
        public abstract int? ApplicationSettingID { get; set; }

        /// <summary>
        /// [Column] Gets or sets a list of keywords 
        /// (comma-separated).
        /// </summary>
        public abstract String Keywords { get; set; }

        /// <summary>
        /// [Column] Gets or sets a URL that will 
        /// process the set of keywords specified in
        /// this handler.
        /// </summary>
        public abstract String HandlerUrl { get; set; }
    }
}
