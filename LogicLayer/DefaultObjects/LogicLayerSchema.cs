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
    public class LogicLayerSchema<T> : Schema<T>
        where T: PersistentObject
    {
        /// <summary>
        /// Represents the column for the foreign key to the activity table.
        /// </summary>
        public SchemaGuid CurrentActivityID;


        /// <summary>
        /// Represents a one-to-many join to the Attachment table.
        /// </summary>
        public TAttachment Attachments { get { return OneToMany<TAttachment>("AttachedObjectID"); } }


        /// <summary>
        /// Represents a one-to-many join to the Memo table.
        /// </summary>
        public TMemo Memos { get { return OneToMany<TMemo>("AttachedObjectID"); } }


        /// <summary>
        /// Represents a one to many join to the Activity table.
        /// </summary>
        public TActivity Activities { get { return OneToMany<TActivity>("AttachedObjectID"); } }

        /// <summary>
        /// Represents a one-to-one join to the Activity table
        /// through the CurrentActivityID.
        /// </summary>
        public TActivity CurrentActivity { get { return OneToOne<TActivity>("CurrentActivityID"); } }


        /// <summary>
        /// Represents a one-to-many join to the CustomizedAttributeField table.
        /// </summary>
        public TCustomizedAttributeField CustomizedAttributeFields { get { return OneToMany<TCustomizedAttributeField>("MainObjectID"); } }

        /// <summary>
        /// 
        /// </sumary>
        public TActivityHistory ActivityHistories { get { return OneToMany<TActivityHistory>("AttachedObjectID"); } }

        public SchemaGuid CreatedUserID;

        /// <summary>
        /// Creates a new object of the type T. If the type T implements
        /// the interface IWorkflowEnabled, then the workflow version
        /// of the object is created.
        /// </summary>
        /// <returns></returns>
        public override T Create()
        {
            Type type = typeof(T);

            if (type.GetInterface("IWorkflowEnabled") != null)
            {
                LogicLayerPersistentObject persistentObject = base.Create() as LogicLayerPersistentObject;
                return Workflow.CreateWorkflowForPersistentObject(persistentObject) as T;
            }
            else
                return base.Create();
        }


        /// <summary>
        /// Creates a new object of the type T. If the type T implements
        /// the interface IWorkflowEnabled, then the workflow version
        /// of the object is created.
        /// </summary>
        /// <returns></returns>
        public override PersistentObject CreateObject()
        {
            return Create();
        }
    }
}
