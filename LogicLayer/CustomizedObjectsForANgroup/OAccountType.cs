//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Data.Sql;
using System.Data.SqlClient;

using Anacle.DataFramework;
using System.Collections;

namespace LogicLayer
{
    /// <summary>
    /// Summary description for OAccount
    /// </summary>
    public partial class TAccountType : LogicLayerSchema<OAccountType>
    {
        public SchemaInt IsTermContractType;
    }


    /// <summary>
    /// 
    /// </summary>
    public abstract partial class OAccountType : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets a flag indicating whether
        /// this is a term contract type.
        /// <para></para>
        /// This flag is used by the ACG report generator to display
        /// all the term contract accounts.
        /// </summary>
        public abstract int? IsTermContractType { get; set; }


        /// <summary>
        /// Returns a text representing whether this account type
        /// is used as a term contract account type.
        /// </summary>
        public string IsTermContractTypeText
        {
            get
            {
                if (this.IsTermContractType == 0)
                    return Resources.Strings.General_No;
                else if (this.IsTermContractType == 1)
                    return Resources.Strings.General_Yes;
                return "";

            }
        }


        /// <summary>
        /// Gets a list of all account types.
        /// </summary>
        /// <returns></returns>
        public static List<OAccountType> GetAllAccountTypes()
        {
            return TablesLogic.tAccountType.LoadAll();
        }

    }
}
