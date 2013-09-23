//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Data;
using System.Configuration;
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
    /// Summary description for OCode
    /// </summary>
    [Database("#database"), Map("Code")]
    [Serializable]
    public partial class TCode : LogicLayerSchema<OCode>
    {
        public SchemaGuid CodeTypeID;
        public SchemaString Identifier;
        public SchemaString RunningNumberCode;

        public TCode Children { get { return OneToMany<TCode>("ParentID"); } }
        public TCode Parent { get { return OneToOne<TCode>("ParentID"); } }

        public TCodeType CodeType { get { return OneToOne<TCodeType>("CodeTypeID"); } }
    }


    /// <summary>
    /// Represents codes that can be attached to other objects for 
    /// categorization. Examples of codes are work types, types of service, 
    /// caller types, vendor classification. 
    /// <para></para>
    /// Code Types are declared hierarchically, and so the hierarchical structure
    /// of the type of Code objects will also follow the Code Types.
    /// <para></para>
    /// As these codes can be entered by the user at the front end through the 
    /// Code module, there should be as little logic tied to these codes as 
    /// possible.
    /// </summary>
    public abstract partial class OCode : LogicLayerPersistentObject, IHierarchy
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the CodeType table 
        /// that indicates the code type this code is associated with. The 
        /// OCodeType is used to differentiate the different classes of 
        /// codes. For example, the application may have codes that 
        /// belong to 'VendorClassification', 'WorkType', 'LoanType', etc.
        /// </summary>
        public abstract Guid? CodeTypeID { get; set; }

        /// <summary>
        /// [Column] This is currently not used.
        /// </summary>
        public abstract string Identifier { get; set; }

        /// <summary>
        /// [Column] Gets or sets a running number code that 
        /// can be added to an Equipment if set up
        /// in the Running Number Generator.
        /// </summary>
        public abstract String RunningNumberCode { get; set; }

        /// <summary>
        /// Gets a one-to-many list of OCode objects that represents 
        /// the next level code types under this current one.
        /// </summary>
        public abstract DataList<OCode> Children { get; }

        /// <summary>
        /// Gets or sets the OCode object that represents the parent 
        /// code under which this current one belongs to.
        /// </summary>
        public abstract OCode Parent { get; }

        /// <summary>
        /// Gets or sets the OCodeType object that represents the code 
        /// type this code is associated with. The OCodeType is used to 
        /// differentiate the different classes of codes. For example, the 
        /// application may have codes that belong to  
        /// 'VendorClassification', 'WorkType', 'LoanType', etc.
        /// </summary>
        public abstract OCodeType CodeType { get; }


        //---------------------------------------------------------------
        /// <summary>
        /// Returns the parent's name concatenated with this object's 
        /// name.
        /// </summary>
        //---------------------------------------------------------------
        public string ParentPath
        {
            get
            {
                if (Parent != null)
                    return Parent.ObjectName + " > " + this.ObjectName;
                else
                    return this.ObjectName;
            }
        }


        /// <summary>
        /// Disallows delete if the code is being used in a work,
        /// or a work cost
        /// </summary>
        /// <returns></returns>
        public override bool IsDeactivatable()
        {
            if (TablesLogic.tWork.LoadList(
                TablesLogic.tWork.TypeOfWorkID == this.ObjectID |
                TablesLogic.tWork.TypeOfServiceID == this.ObjectID |
                TablesLogic.tWork.TypeOfProblemID == this.ObjectID |
                TablesLogic.tWork.CauseOfProblemID == this.ObjectID |
                TablesLogic.tWork.ResolutionID == this.ObjectID).Count > 0)
                return false;

            if (TablesLogic.tScheduledWork.LoadList(
                TablesLogic.tScheduledWork.TypeOfWorkID == this.ObjectID |
                TablesLogic.tScheduledWork.TypeOfServiceID == this.ObjectID |
                TablesLogic.tScheduledWork.TypeOfProblemID == this.ObjectID).Count > 0)
                return false;

            if (TablesLogic.tWorkCost.LoadList(
                TablesLogic.tWorkCost.UnitOfMeasureID == this.ObjectID).Count > 0)
                return false;

            if (TablesLogic.tCatalogue.LoadList(
                TablesLogic.tCatalogue.UnitOfMeasureID == this.ObjectID).Count > 0)
                return false;

            if (TablesLogic.tFixedRate.LoadList(
                TablesLogic.tFixedRate.UnitOfMeasureID == this.ObjectID).Count > 0)
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
            OCode code = this;
            while (true)
            {
                code = code.Parent;
                if (code == null)
                    return false;
                if (code.ObjectID == this.ObjectID)
                    return true;
            }
        }


        //---------------------------------------------------------------
        /// <summary>
        /// Get all root codes.
        /// </summary>
        /// <returns></returns>
        //---------------------------------------------------------------
        public static List<OCode> GetRootCodes()
        {

            return TablesLogic.tCode[TablesLogic.tCode.ParentID == null];
        }


        //---------------------------------------------------------------
        /// <summary>
        /// Get all root codes.
        /// </summary>
        /// <returns></returns>
        //---------------------------------------------------------------
        public static List<OCode> FindCodes(string name)
        {
            return TablesLogic.tCode[TablesLogic.tCode.ObjectName.Like("%" + name + "%")];
        }

        public static List<OCode> FindCodesByType(string name, string typeName)
        {
            return TablesLogic.tCode[TablesLogic.tCode.ObjectName.Like("%" + name + "%") &
                TablesLogic.tCode.CodeType.ObjectName == typeName];
        }

        //---------------------------------------------------------------
        /// <summary>
        /// Get all codes by type.
        /// </summary>
        /// <param name="typeName"></param>
        /// <returns></returns>
        //---------------------------------------------------------------
        public static List<OCode> GetCodesByType(string typeName, Guid? includingCodeId)
        {
            return TablesLogic.tCode.LoadList(
                (TablesLogic.tCode.CodeType.ObjectName == typeName &
                TablesLogic.tCode.IsDeleted==0) |
                TablesLogic.tCode.ObjectID == includingCodeId, true);
        }


        //---------------------------------------------------------------
        /// <summary>
        /// Get all codes by type and order it by the parent's name 
        /// concatenant with the current code's name.
        /// </summary>
        /// <param name="typeName"></param>
        /// <returns></returns>
        //---------------------------------------------------------------
        public static List<OCode> GetCodesByTypeOrderByParentPath(string typeName)
        {
            return TablesLogic.tCode[TablesLogic.tCode.CodeType.ObjectName == typeName,
                (TablesLogic.tCode.Parent.ObjectName + " > " + TablesLogic.tCode.ObjectName).Asc];
        }
        /// <summary>
        /// Get all codes with full path and order by path
        /// </summary>
        /// <param name="typeName"></param>
        /// <returns></returns>
        public static DataTable GetTableCodesWithPath(string typeName)
        {
            return Query.Select((TablesLogic.tCode.Parent.ObjectName + " > " + TablesLogic.tCode.ObjectName).As("Path"),
                                TablesLogic.tCode.ObjectID)
                          .Where(TablesLogic.tCode.IsDeleted == 0 & TablesLogic.tCode.CodeType.ObjectName == typeName)
                          .OrderBy((TablesLogic.tCode.Parent.ObjectName + " > " + TablesLogic.tCode.ObjectName).Asc);
        }
        //---------------------------------------------------------------
        /// <summary>
        /// Get all codes by type and order it by the parent's name 
        /// concatenant with the current code's name.
        /// </summary>
        /// <param name="typeName"></param>
        /// <returns></returns>
        //---------------------------------------------------------------
        public static DataTable GetCodesByTypeOrderByParentPathAsDataTable(string typeName)
        {
            return TablesLogic.tCode.Select(
                TablesLogic.tCode.ObjectID,
                (TablesLogic.tCode.Parent.ObjectName + " > " + TablesLogic.tCode.ObjectName).As("Path"))
                .Where(
                TablesLogic.tCode.IsDeleted == 0 &
                TablesLogic.tCode.CodeType.ObjectName == typeName)
                .OrderBy(
                (TablesLogic.tCode.Parent.ObjectName + " > " + TablesLogic.tCode.ObjectName).Asc);
        }


        //---------------------------------------------------------------
        /// <summary>
        /// Get all codes given a specific type and parent ID.
        /// </summary>
        /// <param name="typeName"></param>
        /// <returns></returns>
        //---------------------------------------------------------------
        public static List<OCode> GetCodesByTypeAndParentID(string typeName, Guid? parentId, Guid? includingCodeId)
        {
            return TablesLogic.tCode.LoadList(
                (TablesLogic.tCode.IsDeleted == 0 &
                TablesLogic.tCode.CodeType.ObjectName == typeName &
                TablesLogic.tCode.ParentID == parentId) |
                TablesLogic.tCode.ObjectID == includingCodeId, true);
        }


        //---------------------------------------------------------------
        /// <summary>
        /// Get all codes given a specific type and parent ID.
        /// </summary>
        /// <param name="typeName"></param>
        /// <returns></returns>
        //---------------------------------------------------------------
        public static List<OCode> GetCodesByParentID(Guid? parentId, Guid? includingCodeId)
        {
            return TablesLogic.tCode.LoadList(
                (TablesLogic.tCode.IsDeleted==0 &
                TablesLogic.tCode.ParentID == parentId) |
                TablesLogic.tCode.ObjectID==includingCodeId,
                true);
        }


        /// <summary>
        /// Gets a list of types of services accessible by the user 
        /// when adding or editing the specified object type. If the positions
        /// allows access to all types of services, then this returns null.
        /// </summary>
        /// <param name="user"></param>
        /// <param name="objectType"></param>
        /// <returns></returns>
        public static List<OCode> GetAccessibleTypesOfService(OUser user, string objectType)
        {
            List<OCode> typeOfServiceList = new List<OCode>();
            foreach (OPosition position in user.GetPositionsByObjectType(objectType))
            {
                if (position.AppliesToAllTypeOfServices == 0)
                    foreach (OCode typeOfService in position.TypesOfServiceAccess)
                        typeOfServiceList.Add(typeOfService);
                else
                    return null;
            }
            return typeOfServiceList;
        }


        //---------------------------------------------------------------
        /// <summary>
        /// Get accessible work types based on the roleNameCode list.
        /// </summary>
        /// <param name="typeName"></param>
        /// <returns></returns>
        //---------------------------------------------------------------
        public static List<OCode> GetWorkTypes(OUser user, string objectType, Guid? includingWorkTypeId)
        {
            List<OCode> typeOfServiceList = GetAccessibleTypesOfService(user, objectType);

            return TablesLogic.tCode.LoadList(
                (TablesLogic.tCode.IsDeleted==0 &
                TablesLogic.tCode.CodeType.ObjectName == "TypeOfWork" &
                (typeOfServiceList == null ? Query.True : 
                TablesLogic.tCode.Children.ObjectID.In(typeOfServiceList))) |
                TablesLogic.tCode.ObjectID==includingWorkTypeId, true
                );
        }



        //---------------------------------------------------------------
        /// <summary>
        /// Get accessible types of services based on the specified 
        /// user, workTypeId and a list of roleNameCode
        /// </summary>
        /// <param name="typeName"></param>
        /// <returns></returns>
        //---------------------------------------------------------------
        public static List<OCode> GetTypeOfServices(OUser user, Guid? workTypeId, string objectType, Guid? includingTypeOfServiceId)
        {
            List<OCode> typeOfServiceList = GetAccessibleTypesOfService(user, objectType);

            return TablesLogic.tCode.LoadList(
                (TablesLogic.tCode.IsDeleted==0 &
                TablesLogic.tCode.CodeType.ObjectName == "TypeOfService" &
                TablesLogic.tCode.ParentID == workTypeId &
                (typeOfServiceList == null ? Query.True :
                TablesLogic.tCode.ObjectID.In(typeOfServiceList))) |
                TablesLogic.tCode.ObjectID==includingTypeOfServiceId,
                true
                );
        }

    }
}