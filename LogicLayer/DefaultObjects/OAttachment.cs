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
    public class TAttachment : LogicLayerSchema<OAttachment>
    {
        public SchemaGuid AttachedObjectID;
        [Size(255)]
        public SchemaString Filename;
        [Size(255)]
        public SchemaString ContentType;
        public SchemaImage FileBytes;
        public SchemaInt FileSize;
        public SchemaGuid AttachmentTypeID;
        [Size(255)]
        public SchemaString FileDescription;

        public TAttachmentType AttachmentType { get { return OneToOne<TAttachmentType>("AttachmentTypeID"); } }
    }


    /// <summary>
    /// Represents a file attachment that can be attached to
    /// any <code>PersistentObject</code>.
    /// </summary>
    [Serializable]
    public abstract class OAttachment : LogicLayerPersistentObject
    {
        /// <summary>
        /// Gets or sets the foreign key of the <code>PersistentObject</code>to which
        /// this attachment is attached to.
        /// </summary>
        public abstract Guid? AttachedObjectID { get;set;}


        /// <summary>
        /// Gets or sets the file name of this attachment.
        /// </summary>
        public abstract String Filename { get;set;}


        /// <summary>
        /// Gets or sets the MIME content type of this attachment.
        /// </summary>
        public abstract String ContentType { get;set;}


        /// <summary>
        /// Gets or sets the binary image of the attachment.
        /// </summary>
        public abstract byte[] FileBytes { get;set;}


        /// <summary>
        /// Gets or sets the file size of this attachment.
        /// </summary>
        public abstract int? FileSize { get;set;}
        
        /// <summary>
        /// Gets or sets the document type of this attachment.
        /// </summary>
        public abstract Guid? AttachmentTypeID { get;set;}


        /// <summary>
        /// Gets or sets the description given to this attachment.
        /// </summary>
        public abstract String FileDescription { get;set;}


        /// <summary>
        /// Gets the OAttachmentType object that represents
        /// the type of attachment that the user has uploaded.
        /// </summary>
        public abstract OAttachmentType AttachmentType { get; set; }

        /// <summary>
        /// This method to remove all the attachment
        /// which have been removed from the object.
        /// to release db space.
        /// </summary>
        public static void ClearRemovedAttachments()
        {
             using (Connection c = new Connection())
            {
                TablesLogic.tAttachment.DeleteList(
                    TablesLogic.tAttachment.AttachedObjectID == null);
                c.Commit();
            }
        }
    }

}

