//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Collections.Generic;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using Anacle.DataFramework;

namespace LogicLayer
{
    /// <summary>
    /// Summary description for OCodeType
    /// </summary>
    [Database("#database"), Map("CodeType")]
    [Serializable] public partial class TCodeType : LogicLayerSchema<OCodeType>
    {
        public SchemaInt IsSystemCode;
        public SchemaString Identifier;

        public TCodeType Children { get { return OneToMany<TCodeType>("ParentID"); } }
        public TCodeType Parent { get { return OneToOne<TCodeType>("ParentID"); } }
    }


    /// <summary>
    /// Represents a record used as a hierarchical classification for codes.
    /// </summary>
    public abstract partial class OCodeType : LogicLayerPersistentObject, IHierarchy
    {
        /// <summary>
        /// [Column] This is obsolete and not used.
        /// </summary>
        public abstract int? IsSystemCode { get; set; }
        /// <summary>
        /// [Column] This is obsolete and not used.
        /// </summary>
        public abstract string Identifier { get; set; }

        /// <summary>
        /// Gets a one-to-many list of OCodeType objects that represents 
        /// the next level code types under this current one.
        /// </summary>
        public abstract DataList<OCodeType> Children { get; }
        /// <summary>
        /// Gets or sets the OCodeType object that represents the parent 
        /// code under which this current one belongs to.
        /// </summary>
        public abstract OCodeType Parent { get; }


        /// <summary>
        /// Disallows delete if a non-deleted code already uses this code.
        /// </summary>
        /// <returns></returns>
        public override bool IsDeactivatable()
        {
            if (TablesLogic.tCode.LoadList(TablesLogic.tCode.CodeTypeID == this.ObjectID).Count > 0)
                return false;
            return base.IsDeactivatable();
        }


        //---------------------------------------------------------------
        /// <summary>
        /// Tests if the object's parent is a cyclical reference back
        /// to itself.
        /// </summary>
        /// <returns></returns>
        //---------------------------------------------------------------
        public bool IsCyclicalReference()
        {
            OCodeType codeType = this;
            while (true)
            {
                codeType = codeType.Parent;
                if (codeType == null)
                    return false;
                if (codeType.ObjectID == this.ObjectID)
                    return true;
            }
        }


        // 2010.04.29
        /// <summary>
        /// Gets a list of all selectable code types.
        /// </summary>
        /// <returns></returns>
        public static List<OCodeType> GetAllCodeTypes()
        {
            return TablesLogic.tCodeType.LoadAll();
        }


        //---------------------------------------------------------------
        /// <summary>
        /// Get all root codes.
        /// </summary>
        /// <returns></returns>
        //---------------------------------------------------------------
        public static List<OCodeType> GetRootCodeTypes()
        {
            return TablesLogic.tCodeType[TablesLogic.tCodeType.ParentID == null];
        }


        //---------------------------------------------------------------
        /// <summary>
        /// Get all root codes.
        /// </summary>
        /// <returns></returns>
        //---------------------------------------------------------------
        public static List<OCodeType> GetLowerCodeTypes(OCodeType codeType)
        {
            return TablesLogic.tCodeType[TablesLogic.tCodeType.HierarchyPath.Like(codeType.HierarchyPath + "%")];
        }


        //---------------------------------------------------------------
        /// <summary>
        /// 
        /// </summary>
        /// <param name="name"></param>
        /// <returns></returns>
        //---------------------------------------------------------------
        public static List<OCodeType> FindCodeTypes(string name)
        {
            return TablesLogic.tCodeType[TablesLogic.tCodeType.ObjectName.Like("%" + name + "%")];
        }
    }
}