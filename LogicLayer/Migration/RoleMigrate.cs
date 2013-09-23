using System;
using System.Collections.Generic;
using System.Text;
using Anacle.DataFramework;
namespace LogicLayer
{
    [Serializable] public abstract partial class ORoleMigrate : PersistentObject
    {
        public abstract String RoleNameID { get; set; }

    }

    [Serializable] public partial class TRoleMigrate : LogicLayerSchema<ORoleMigrate>
    {
        [Size(255)]
        public SchemaString RoleNameID;
    }
}
