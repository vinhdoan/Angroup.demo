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
    public partial class TRole : LogicLayerSchema<ORole>
    {
        [Size(255)]
        public SchemaString RoleCode;
        [Size(255)]
        public SchemaString RoleName;
        public TRoleFunction RoleFunctions { get { return OneToMany<TRoleFunction>("RoleID"); } }
        public TReport ReportRole { get { return ManyToMany<TReport>("ReportRole", "RoleID", "ReportID"); } }
        public TDashboard DashboardRole { get { return ManyToMany<TDashboard>("DashboardRole", "RoleID", "DashboardID"); } }
        public TPosition Positions { get { return OneToMany<TPosition>("RoleID"); } }
    }


    public abstract partial class ORole : LogicLayerPersistentObject, IAuditTrailEnabled
    {
        /// <summary>
        /// [Column] Gets or sets the role code that is
        /// used by the application to identify this role.
        /// </summary>
        public abstract string RoleCode { get;set; }

        /// <summary>
        /// [Column] Gets or sets the role name of this
        /// role.
        /// </summary>
        public abstract string RoleName { get;set;}

        /// <summary>
        /// Gets the list of ORoleFunction objects that represent
        /// the list of functions and create/edit/view/delete rights
        /// that this role has been granted access to.
        /// </summary>
        public abstract DataList<ORoleFunction> RoleFunctions { get; }

        /// <summary>
        /// Gets the list of OReport objects that represents the list
        /// of reports that this role has been granted access
        /// to.
        /// </summary>
        public abstract DataList<OReport> ReportRole { get;}

        /// <summary>
        /// Gets the list of ODashboard objects that represents
        /// the list of dashboards that this role has been granted
        /// access to.
        /// </summary>
        public abstract DataList<ODashboard> DashboardRole { get;}

        /// <summary>
        /// Gets or sets the positions associated
        /// with this role.
        /// </summary>
        public abstract DataList<OPosition> Positions { get; set; }


        public override string AuditObjectDescription
        {
            get
            {
                return this.RoleName;
            }
        }


        /// <summary>
        /// Gets a list of all roles.
        /// </summary>
        /// <returns></returns>
        public static List<ORole> GetAllRoles()
        {
            return TablesLogic.tRole.LoadAll(TablesLogic.tRole.RoleName.Asc);
        }


        /// <summary>
        /// Overrides the Saved method to clear the FunctionID/RoleID of the 
        /// removed ORoleFunction objects.
        /// </summary>
        public override void Saved()
        {
            base.Saved();

            // The DataFramework would have set the FunctionID to null for
            // the removed ORoleFunction objects, but we also need to
            // set the RoleID to null, so that it does not appear in the
            // Roles page.
            //
            TablesLogic.tRoleFunction.DeleteList(
                TablesLogic.tRoleFunction.FunctionID == null |
                TablesLogic.tRoleFunction.RoleID == null);
            List<ORoleFunction> roleFunctions =
                TablesLogic.tRoleFunction.LoadList(
                TablesLogic.tRoleFunction.FunctionID == null |
                TablesLogic.tRoleFunction.RoleID == null);
            foreach (ORoleFunction roleFunction in roleFunctions)
            {
                roleFunction.FunctionID = null;
                roleFunction.RoleID = null;
                roleFunction.Deactivate();
            }
        }


        /// <summary>
        /// Determines if this role is a duplicate of another
        /// role with the same role code.
        /// </summary>
        /// <returns></returns>
        public bool IsDuplicateRoleCode()
        {
            if (TablesLogic.tRole[
                TablesLogic.tRole.RoleCode == this.RoleCode &
                TablesLogic.tRole.ObjectID != this.ObjectID].Count > 0)
                return true;

            return false;
        }


        /// <summary>
        /// Get all roles that the specified position is associated to
        /// </summary>
        /// <param name="position"></param>
        /// <returns></returns>
        public static List<ORole> GetRolesByPosition(OPosition position)
        {
            if (position != null)
            {
                List<ORole> list = TablesLogic.tRole[TablesLogic.tRole.ObjectID == position.RoleID];
                return list;
            }
            else
                return null;
        }


        /// <summary>
        /// When user create a new role and save it to database,
        /// a position associtated to this role is automatically created
        /// with position name is same as the RoleCode of this role.
        /// </summary>
        public override void Saving()
        {
            base.Saving();

            if (this.IsNew)
            {
                // 2010.07.21
                // Kim Foong
                // Bug fix to pass in role's ID.
                //
                OPosition position = OPosition.CreatePosition(this.RoleName, this.ObjectID);
                this.Positions.Add(position);
            }
        }


        /// <summary>
        /// Removes all positions that are currently associated
        /// to this role.
        /// </summary>
        public override void Deactivated()
        {
            base.Deactivated();

            using (Connection c = new Connection())
            {
                List<OPosition> positions = TablesLogic.tPosition.LoadList(
                    TablesLogic.tPosition.RoleID == this.ObjectID);

                foreach (OPosition position in positions)
                    position.Deactivate();

                // Remove the role functions attached to this role.
                //
                List<ORoleFunction> roleFunctions = TablesLogic.tRoleFunction.LoadList(
                    TablesLogic.tRoleFunction.RoleID == this.ObjectID);
                foreach (ORoleFunction roleFunction in roleFunctions)
                    roleFunction.Deactivate();

                c.Commit();
            }
        }
    }
}
