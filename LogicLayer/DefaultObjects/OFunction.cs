//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Text;
using System.Data;
using System.Reflection;
using Anacle.DataFramework;

namespace LogicLayer
{
    public class TFunction : LogicLayerSchema<OFunction>
    {
        [Size(255)]
        public SchemaString FunctionName;
        [Size(255)]
        public SchemaString CategoryName;
        [Size(255)]
        public SchemaString SubCategoryName;
        [Size(255)]
        public SchemaString ObjectTypeName;
        [Size(255), Default("~/modules/???/search.aspx")]
        public SchemaString MainUrl;
        [Size(255), Default("~/modules/???/edit.aspx")]
        public SchemaString EditUrl;

        [Default(1)]
        public SchemaInt IsCustomizable;

        public SchemaInt DisplayOrder;

        public TRoleFunction RoleFunctions { get { return OneToMany<TRoleFunction>("FunctionID"); } }
    }
    public abstract class OFunction : LogicLayerPersistentObject, IAuditTrailEnabled
    {
        /// <summary>
        /// [Column] Gets or sets the name of the function.
        /// </summary>
        public abstract string FunctionName { get;set;}

        /// <summary>
        /// [Column] Gets or sets the name of the category.
        /// </summary>
        public abstract string CategoryName { get;set;}

        /// <summary>
        /// [Column] Gets or sets the name of the sub category. 
        /// This field is optional.
        /// </summary>
        public abstract string SubCategoryName { get;set;}

        /// <summary>
        /// [Column] Gets or sets the ObjectType of the Function
        /// </summary>
        public abstract string ObjectTypeName { get;set; }

        /// <summary>
        /// [Column] Gets or sets the Url of the Main page
        /// </summary>
        public abstract string MainUrl { get;set;}

        /// <summary>
        /// [Column] Gets or sets the Url of the Edit page
        /// </summary>
        public abstract string EditUrl { get;set;}

        /// <summary>
        /// [Column] Gets or sets a flag indicating whether
        /// the object editable by this function is customizable
        /// or not.
        /// </summary>
        public abstract int? IsCustomizable { get;set;}

        /// <summary>
        /// [Column] Gets or sets displayed order of the function
        /// </summary>
        public abstract int? DisplayOrder { get;set; }

        /// <summary>
        /// [One-to-One Join OPCPoint.EquipmentID = Equipment.ObjectID]
        /// Gets a list of ORoleFunction objects representing
        /// the list of roles that have access to this function.
        /// </summary>
        public abstract DataList<ORoleFunction> RoleFunctions { get; }

        /// <summary>
        /// Gets a string that concatenates the category and 
        /// the function name.
        /// </summary>
        public string CategoryAndFunctionName
        {
            get
            {
                if (SubCategoryName != "")
                    return CategoryName + " > " + SubCategoryName + " > " + FunctionName;
                else
                    return CategoryName + " > " + FunctionName;
            }
        }


        public override string AuditObjectDescription
        {
            get
            {
                return CategoryAndFunctionName;
            }
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
        /// Removes all positions that are currently associated
        /// to this role.
        /// </summary>
        public override void Deactivated()
        {
            base.Deactivated();

            using (Connection c = new Connection())
            {
                // 2010.07.10
                // Kim Foong
                // Removed this bug of deactivating Positions
                // unnecessarily. (This piece was code was
                // errorneously copied from the ORole.Deactivated()
                // method.
                /*
                List<OPosition> positions = TablesLogic.tPosition.LoadList(
                    TablesLogic.tPosition.RoleID == this.ObjectID);

                foreach (OPosition position in positions)
                    position.Deactivate();
                 * */

                // Remove the role functions attached to this role.
                //
                List<ORoleFunction> roleFunctions = TablesLogic.tRoleFunction.LoadList(
                    TablesLogic.tRoleFunction.FunctionID == this.ObjectID);
                foreach (ORoleFunction roleFunction in roleFunctions)
                    roleFunction.Deactivate();

                c.Commit();
            }
        }


        /// <summary>
        /// Gets list of all functions which sorted by Object Type
        /// </summary>
        /// <returns></returns>
        public static List<OFunction> GetAllFunction() {
            return TablesLogic.tFunction[Query.True,TablesLogic.tFunction.ObjectTypeName.Asc];
        }


        /// <summary>
        /// Determines if this function is a duplicate function
        /// based on the object type.
        /// </summary>
        /// <returns></returns>
        public bool IsDuplicateObjectType()
        {
            if (TablesLogic.tFunction[
                TablesLogic.tFunction.ObjectTypeName == this.ObjectTypeName &
                TablesLogic.tFunction.ObjectID != this.ObjectID].Count > 0)
                return true;

            return false;
        }


        /// <summary>
        /// Queries all function names and returns
        /// them in a DataView.
        /// </summary>
        /// <returns></returns>
        public static DataView ListFunctionName() 
        {
            DataTable tbl = new DataTable();
            tbl.Columns.Add("FunctionName");
            tbl.Columns.Add("ObjectID");

            tbl.Rows.Add("", "");
            List<OFunction> listFunc=TablesLogic.tFunction[Query.True];
            
            foreach (OFunction fun in listFunc) {
                tbl.Rows.Add(fun.CategoryName + " > " + fun.FunctionName, fun.ObjectID);
            }
            tbl.DefaultView.Sort = "FunctionName ASC";

            return tbl.DefaultView;
        }


        public static DataTable GetFunctionTable()
        {
            DataTable tbl = new DataTable();
            tbl.Columns.Add("FunctionName");
            tbl.Columns.Add("ObjectID");

            tbl.Rows.Add("", "");
            List<OFunction> listFunc = TablesLogic.tFunction[Query.True];

            foreach (OFunction fun in listFunc)
            {
                tbl.Rows.Add(fun.CategoryName + " > " + fun.FunctionName, fun.ObjectID);
            }
            tbl.DefaultView.Sort = "FunctionName ASC";
            return tbl;
        }

        /// <summary>
        /// Gets a list of all functions.
        /// </summary>
        /// <returns></returns>
        public static List<OFunction> GetAllFunctions()
        {
            return TablesLogic.tFunction.LoadAll(
                TablesLogic.tFunction.CategoryName.Asc,
                TablesLogic.tFunction.SubCategoryName.Asc,
                TablesLogic.tFunction.FunctionName.Asc);
        }


        /// <summary>
        /// Gets a function based on the object type.
        /// </summary>
        /// <returns></returns>
        public static OFunction GetFunctionByObjectType(string objectType)
        {
            return TablesLogic.tFunction.Load(
                TablesLogic.tFunction.ObjectTypeName == objectType);
        }


        /// <summary>
        /// Gets a list of role codes of the roles
        /// associated with this function.
        /// </summary>
        /// <returns></returns>
        public static List<string> GetRoleCodes(string objectType)
        {
            List<ORole> roles = TablesLogic.tRole.LoadList(
                TablesLogic.tRole.RoleFunctions.Function.ObjectTypeName == objectType);

            List<string> roleCodes = new List<string>();
            foreach(ORole role in roles)
                roleCodes.Add(role.RoleCode);

            return roleCodes;
        }


        /// <summary>
        /// Gets the function menus accessible by the user and returns
        /// it as a DataTable.
        /// </summary>
        /// <param name="user"></param>
        /// <returns></returns>
        public static DataTable GetMenusAccessibleByUser(OUser user)
        {
            return TablesLogic.tFunction.SelectDistinct(
                TablesLogic.tFunction.DisplayOrder,
                TablesLogic.tFunction.CategoryName,
                TablesLogic.tFunction.SubCategoryName,
                TablesLogic.tFunction.FunctionName,
                TablesLogic.tFunction.MainUrl,
                TablesLogic.tFunction.EditUrl,
                TablesLogic.tFunction.ObjectTypeName
                )
                .Where(
                TablesLogic.tFunction.IsDeleted == 0 &
                TablesLogic.tFunction.RoleFunctions.Role.IsDeleted == 0 &
                TablesLogic.tFunction.RoleFunctions.Role.Positions.IsDeleted == 0 &
                TablesLogic.tFunction.RoleFunctions.Role.Positions.Users.ObjectID == user.ObjectID)
                .OrderBy(
                TablesLogic.tFunction.DisplayOrder.Asc,
                TablesLogic.tFunction.CategoryName.Asc,
                TablesLogic.tFunction.SubCategoryName.Asc,
                TablesLogic.tFunction.FunctionName.Asc);
        }


        /// <summary>
        /// Gets a list of all functions createable by the specified
        /// user.
        /// </summary>
        /// <param name="user"></param>
        /// <returns></returns>
        public static DataTable GetFunctionsCreateableByUser(OUser user)
        {
            return TablesLogic.tFunction.SelectDistinct(
                TablesLogic.tFunction.DisplayOrder,
                TablesLogic.tFunction.CategoryName,
                TablesLogic.tFunction.SubCategoryName,
                TablesLogic.tFunction.FunctionName,
                TablesLogic.tFunction.MainUrl,
                TablesLogic.tFunction.EditUrl,
                TablesLogic.tFunction.ObjectTypeName
                )
                .Where(
                TablesLogic.tFunction.IsDeleted==0 &
                TablesLogic.tFunction.RoleFunctions.Role.Positions.Users.ObjectID == user.ObjectID &
                TablesLogic.tFunction.RoleFunctions.AllowCreate == 1)
                .OrderBy(
                TablesLogic.tFunction.CategoryName.Asc,
                TablesLogic.tFunction.DisplayOrder.Asc);
        }


        /// <summary>
        /// Gets and returns a list of functions with a specified object
        /// type.
        /// </summary>
        /// <returns></returns>
        public static List<OFunction> GetAllFunctionsWithObjectTypes()
        {
            return TablesLogic.tFunction.LoadList(
                TablesLogic.tFunction.ObjectTypeName != null &
                TablesLogic.tFunction.ObjectTypeName != "",
                TablesLogic.tFunction.ObjectTypeName.Asc);
        }


        /// <summary>
        /// Gets and returns a list of all object type names.
        /// </summary>
        /// <returns></returns>
        public static DataTable GetAllObjectTypeNames(string includeObjectTypeName)
        {
            DataTable dt =
                TablesLogic.tFunction.SelectDistinct(
                TablesLogic.tFunction.ObjectTypeName)
                .Where(
                (TablesLogic.tFunction.ObjectTypeName != null &
                TablesLogic.tFunction.ObjectTypeName != "" &
                TablesLogic.tFunction.IsDeleted == 0) |
                TablesLogic.tFunction.ObjectTypeName == includeObjectTypeName
                )
                .OrderBy(
                TablesLogic.tFunction.ObjectTypeName.Asc);

            return dt;
        }


        /// <summary>
        /// Gets and returns a list of all object type names.
        /// </summary>
        /// <returns></returns>
        public static DataTable GetObjectTypeNamesByImplementation(string includeObjectTypeName, Type implementedType)
        {
            DataTable dt =
                TablesLogic.tFunction.SelectDistinct(
                TablesLogic.tFunction.ObjectTypeName)
                .Where(
                (TablesLogic.tFunction.ObjectTypeName != null &
                TablesLogic.tFunction.ObjectTypeName != "" &
                TablesLogic.tFunction.IsDeleted == 0) |
                TablesLogic.tFunction.ObjectTypeName == includeObjectTypeName
                )
                .OrderBy(
                TablesLogic.tFunction.ObjectTypeName.Asc);

            Assembly executingAssembly = Assembly.GetExecutingAssembly();
            for (int i = dt.Rows.Count - 1; i >= 0; i--)
            {
                string objectTypeName = (string)dt.Rows[i][0];
                Type type = executingAssembly.GetType("LogicLayer."+objectTypeName);
                if (!implementedType.IsAssignableFrom(type))
                    dt.Rows.RemoveAt(i);
            }
            return dt;
        }


        /// <summary>
        /// Gets and returns a list of functions with a specified object
        /// type and that the object type is customizable.
        /// </summary>
        /// <returns></returns>
        public static List<OFunction> GetAllFunctionsWithCustomizableObjectTypes()
        {
            return TablesLogic.tFunction.LoadList(
                TablesLogic.tFunction.IsCustomizable == 1 &
                TablesLogic.tFunction.ObjectTypeName != null &
                TablesLogic.tFunction.ObjectTypeName != "",
                TablesLogic.tFunction.ObjectTypeName.Asc);
        }


    }

}
