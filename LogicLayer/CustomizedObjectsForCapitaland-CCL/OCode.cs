//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
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
    public partial class TCode : LogicLayerSchema<OCode>
    {
        //Nguyen Quoc Phuong 21-Nov-2012
        [Default(0)]
        public SchemaInt RequiredCRVSerialNumber;
        //End Nguyen Quoc Phuong 21-Nov-2012

        //Nguyen Quoc Phuong 17-Dec-2012
        [Default(0)]
        public SchemaInt OnlyApplicableForTermContract;
        //End Nguyen Quoc Phuong 17-Dec-2012
    }

    public abstract partial class OCode : LogicLayerPersistentObject, IHierarchy
    {
        public abstract int? RequiredCRVSerialNumber { get; set; }//Nguyen Quoc Phuong 21-Nov-2012
        public abstract int? OnlyApplicableForTermContract { get; set; }//Nguyen Quoc Phuong 17-Dec-2012
        /// <summary>
        /// 
        /// </summary>
        /// <param name="user"></param>
        /// <param name="objectType"></param>
        /// <param name="includingPurchaseGroupTypeId"></param>
        /// <returns></returns>
        public static List<OCode> GetPurchaseGroupTypes(OUser user, string objectType, Guid? includingPurchaseGroupTypeId)
        {
            List<OCode> typeOfPurchaseList = GetAccessiblePurchaseTypes(user, objectType);

            return TablesLogic.tCode.LoadList(
                (TablesLogic.tCode.IsDeleted == 0 &
                TablesLogic.tCode.CodeType.ObjectName == "PurchaseTypeClassification" &
                (typeOfPurchaseList == null ? Query.True :
                TablesLogic.tCode.Children.ObjectID.In(typeOfPurchaseList))) |
                TablesLogic.tCode.ObjectID == includingPurchaseGroupTypeId, true
                );
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="user"></param>
        /// <param name="objectType"></param>
        /// <returns></returns>
        public static List<OCode> GetAccessiblePurchaseTypes(OUser user, string objectType)
        {
            List<OCode> typeOfPurchaseList = new List<OCode>();
            List<OPosition> positions = user.GetPositionsByObjectType(objectType);

            foreach (OPosition position in positions)
            {
                if (position.AppliesToAllPurchaseTypes == 0)
                    foreach (OCode typeOfPurchase in position.PurchaseTypesAccess)
                        typeOfPurchaseList.Add(typeOfPurchase);
                else
                    return null;
            }
            return typeOfPurchaseList;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="user"></param>
        /// <param name="purchaseGroupId"></param>
        /// <param name="objectType"></param>
        /// <param name="includingPurchaseTypeId"></param>
        /// <returns></returns>
        public static List<OCode> GetPurchaseTypes(OUser user, Guid? purchaseGroupId, string objectType, Guid? includingPurchaseTypeId)
        {
            List<OCode> typeOfPurchaseList = GetAccessiblePurchaseTypes(user, objectType);

            return TablesLogic.tCode.LoadList(
                (TablesLogic.tCode.IsDeleted == 0 &
                TablesLogic.tCode.CodeType.ObjectName == "PurchaseType" &
                (purchaseGroupId == null ? Query.True : 
                TablesLogic.tCode.ParentID == purchaseGroupId) &
                (typeOfPurchaseList == null ? Query.True :
                TablesLogic.tCode.ObjectID.In(typeOfPurchaseList))) |
                TablesLogic.tCode.ObjectID == includingPurchaseTypeId,
                true, TablesLogic.tCode.ParentID.Asc, TablesLogic.tCode.ObjectName.Asc
                );
        }
    }
}