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
    public class TMessageAttachment : LogicLayerSchema<OMessageAttachment>
    {
        public SchemaGuid MessageID;
        [Size(255)]
        public SchemaString Filename;
        public SchemaImage FileBytes;
        public SchemaInt FileSize;

    }


    /// <summary>
    /// Represents a file attachment that can be attached to
    /// any <code>PersistentObject</code>.
    /// </summary>
    [Serializable]
    public abstract class OMessageAttachment : LogicLayerPersistentObject
    {
        /// <summary>
        /// Gets or sets the foreign key of the <code>PersistentObject</code>to which
        /// this attachment is attached to.
        /// </summary>
        public abstract Guid? MessageID { get; set; }


        /// <summary>
        /// Gets or sets the file name of this attachment.
        /// </summary>
        public abstract String Filename { get;set;}


        /// <summary>
        /// Gets or sets the binary image of the attachment.
        /// </summary>
        public abstract byte[] FileBytes { get;set;}


        /// <summary>
        /// Gets or sets the file size of this attachment.
        /// </summary>
        public abstract int? FileSize { get;set;}


        /// <summary>
        /// Creates a new OMessageAttachment object, so that you
        /// can use it to pass into the OMessage.SendMail method.
        /// </summary>
        /// <param name="filename"></param>
        /// <param name="fileBytes"></param>
        /// <returns></returns>
        public static OMessageAttachment NewAttachment(string filename, byte[] fileBytes)
        {
            OMessageAttachment messageAttachment = TablesLogic.tMessageAttachment.Create();
            messageAttachment.FileBytes = fileBytes;
            messageAttachment.FileSize = fileBytes.Length;
            messageAttachment.Filename = filename;
            return messageAttachment;
        }
    }

}

