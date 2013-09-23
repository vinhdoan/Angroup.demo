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
    public class TLanguage: LogicLayerSchema<OLanguage>
    {
        public SchemaString CultureCode;
        public SchemaInt DisplayOrder;
    }
    public abstract class OLanguage : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the culture code of country.
        /// </summary>
        public abstract string CultureCode { get;set;}
        /// <summary>
        /// [Column] Gets or sets the priority number of a displayed language
        /// </summary>
        public abstract int? DisplayOrder { get;set;}
        /// <summary>
        /// Gets a list of all languages.
        /// </summary>
        /// <returns></returns>
        public static List<OLanguage> GetAllLanguages() {
            return TablesLogic.tLanguage[TablesLogic.tLanguage.IsDeleted == 0, TablesLogic.tLanguage.DisplayOrder.Asc,TablesLogic.tLanguage.ObjectName.Asc];
        }
    }
}
