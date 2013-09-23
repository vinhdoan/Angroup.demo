//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Text;

using Anacle.DataFramework;

namespace LogicLayer
{
    /// <summary>
    /// Represents the schema for the Activity table.
    /// </summary>
    public class TAttachmentType : LogicLayerSchema<OAttachmentType>
    {
    }


    /// <summary>
    /// Represents the type of attachment.
    /// </summary>
    [Serializable]
    public abstract class OAttachmentType : LogicLayerPersistentObject
    {
        /// <summary>
        /// Gets a list of all attachment types.
        /// </summary>
        public static List<OAttachmentType> GetAllAttachmentTypes()
        {
            return TablesLogic.tAttachmentType.LoadAll();
        }
    }
}
