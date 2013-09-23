//========================================================================
// $Product: Abell Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
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
    public partial class TActivityHistory : LogicLayerSchema<OActivityHistory>
    {
        [Size(255)]
        public SchemaString ApprovedOnBehalfOfUser;

        /// <summary>
        /// Represents a many-to-many join to the User table.
        /// </summary>
        public TUser CarbonCopyUsers { get { return ManyToMany<TUser>("ActivityHistoryCarbonCopyUser", "ActivityHistoryID", "UserID"); } }

        public TUser OnBehalfOfUser { get { return OneToOne<TUser>("OnBehalfOfUserID"); } }

        public SchemaGuid ApprovedByUserID;

        public TUser ApprovedByUser { get { return OneToOne<TUser>("ApprovedByUserID"); } }
    }


    /// <summary>
    /// Represents the current activity or a task of an object.
    /// </summary>
    public abstract partial class OActivityHistory : PersistentObject
    {
        /// <summary>
        /// Gets or sets the name of the user this task was
        /// approved on behalf of.
        /// </summary>
        public abstract string ApprovedOnBehalfOfUser { get; set; }


        public abstract Guid? ApprovedByUserID { get; set; }

        public abstract OUser ApprovedByUser { get; set; }

        /// <summary>
        /// Gets a list of users that are assigned to this task.
        /// </summary>
        public abstract DataList<OUser> CarbonCopyUsers { get; }

    }
}
