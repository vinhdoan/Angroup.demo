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
    public class TRoleFunction : LogicLayerSchema<ORoleFunction>
    {
        public SchemaGuid FunctionID;
        public SchemaInt AllowCreate;
        public SchemaInt AllowEditAll;
        public SchemaInt AllowViewAll;
        public SchemaInt AllowDeleteAll;
        public SchemaGuid RoleID;

        public TFunction Function { get { return OneToOne<TFunction>("FunctionID"); } }
        public TRole Role { get { return OneToOne<TRole>("RoleID"); } }
    }


    public abstract class ORoleFunction : LogicLayerPersistentObject, IAuditTrailEnabled
    {
        public abstract Guid? FunctionID {get;set;}
        public abstract int? AllowCreate { get;set;}
        public abstract int? AllowEditAll { get;set;}
        public abstract int? AllowViewAll { get;set;}
        public abstract int? AllowDeleteAll { get;set;}
        public abstract Guid? RoleID { get;set;}
        
        public abstract OFunction Function { get;set;}
        public abstract ORole Role { get; set; }
        

    }

    
}
