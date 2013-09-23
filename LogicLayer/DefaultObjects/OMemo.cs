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
    public class TMemo : LogicLayerSchema<OMemo>
    {
        public SchemaGuid AttachedObjectID;
        public SchemaText Message;
    }


    /// <summary>
    /// Represents a Memorandum object that can be used to 
    /// attach to any other PersistentObject in the system.
    /// </summary>
    [Serializable]
    public abstract class OMemo : PersistentObject
    {
        /// <summary>
        /// Gets or sets the foreign key to the ObjectID of the PersistentObject
        /// that this OMemo object is attached to.
        /// </summary>
        public abstract Guid? AttachedObjectID { get;set;}

        /// <summary>
        /// Gets or sets the message of the memo.
        /// </summary>
        public abstract String Message { get;set;}
    }
}
