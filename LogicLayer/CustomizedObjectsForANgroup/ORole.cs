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

using Anacle.DataFramework;
namespace LogicLayer
{
    public partial class TRole : LogicLayerSchema<ORole>
    {
        public TRole AssignableRoles { get { return ManyToMany<TRole>("RoleAssignableRole", "RoleID", "AssignableRoleID"); } }
    }


    public abstract partial class ORole : LogicLayerPersistentObject, IAuditTrailEnabled
    {
        /// <summary>
        /// Gets a list of ORole objects representing the list of 
        /// roles that a user of the current role is allowed to grant to 
        /// or revoke from other users when creating or editing
        /// a user record.
        /// </summary>
        public abstract DataList<ORole> AssignableRoles { get; }

        public static List<ORole> GetRolesByRoleCode(string roleCode)
        {
            return TablesLogic.tRole.LoadList
                (TablesLogic.tRole.RoleCode == roleCode &
                TablesLogic.tRole.IsDeleted == 0);
        }
    }
}
