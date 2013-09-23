//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
using System.Configuration;
using System.Text;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using Anacle.DataFramework;


/// <summary>
/// Summary description for UserAccount
/// </summary>

namespace LogicLayer
{

    public partial class TUser : LogicLayerSchema<OUser>
    {
        public SchemaInt EnableAllBuildingForGWJ;

        [Default(0)]
        public SchemaInt IsSupporter;
        public SchemaString AMOSInstanceID;
    }


    /// <summary>
    /// Represents a user account in the system. Details
    /// about the user, including his/her contact details and login
    /// credentials can be found in the UserBase property, which
    /// is an OUserBase object.
    /// </summary>
    public abstract partial class OUser : LogicLayerPersistentObject
    {
        public abstract int? EnableAllBuildingForGWJ { get; set; }
        public abstract int? IsSupporter { get; set; }
        public abstract String AMOSInstanceID { get; set; }
        /// --------------------------------------------------------------
        /// <summary>
        /// Returns a list of all non-tenant, supporter users in the system.
        /// </summary>
        /// <returns></returns>
        /// --------------------------------------------------------------
        public static List<OUser> GetAllNonTenantSupporterUsers()
        {
            return TablesLogic.tUser[TablesLogic.tUser.isTenant == 0 & TablesLogic.tUser.IsSupporter == 1];
        }

        public object Clone()
        {
            OUser newUser = TablesLogic.tUser.Create();
            newUser.LanguageName = "en-US";
            foreach (OUserPermanentPosition pPos in this.PermanentPositions)
            {
                OUserPermanentPosition newPPos = TablesLogic.tUserPermanentPosition.Create();
                newPPos.PositionID = pPos.PositionID;
                newUser.PermanentPositions.Add(newPPos);
            }
            return newUser;

        }

        //Nguyen Quoc Phuong 12-Dec-2012
        public string GetSystemCodeByRole(string RoleCode)
        {
            List<OPosition> Positions = TablesLogic.tPosition.LoadList(TablesLogic.tPosition.Users.ObjectID == this.ObjectID &
                                                                       TablesLogic.tPosition.Role.RoleCode.Like("%"+RoleCode+"%"));
            List<OLocation> Locations = new List<OLocation>();
            foreach (OPosition Position in Positions)
                Locations.AddRange(Position.LocationAccess.Order());
            foreach (OLocation Location in Locations)
                if (!string.IsNullOrEmpty(Location.GetSystemCode())) return Location.GetSystemCode();
            return string.Empty;
        }
        //End Nguyen Quoc Phuong 12-Dec-2012

        public static List<OUser> GetRequestorOrTenantsByPositions(List<OPosition> positions, OLocation location)
        {
            List<OPosition> requestorPos = OPosition.GetPositionsByRoleAndLocation("CASEREQUESTOR", location);
            ExpressionCondition tenantCond1 = Query.True;
            ExpressionCondition tenantCond2 = Query.False;
            if (positions.Count > 0)
            {
                foreach (OPosition pos in positions)
                    tenantCond1 &= TablesLogic.tUser.TenantLeases.Location.HierarchyPath.Like(pos.HierarchyPath + "%") &
                        TablesLogic.tUser.TenantLeases.LeaseStatus == "N";

            }
            if (location != null)
            {
                tenantCond2 = TablesLogic.tUser.TenantLeases.LocationID == location.ObjectID &
                    TablesLogic.tUser.TenantLeases.LeaseStatus == "N";
            }
            List<OUser> tenants = TablesLogic.tUser.LoadList
                (tenantCond1 | tenantCond2);

            return TablesLogic.tUser.LoadList(
                TablesLogic.tUser.Positions.ObjectID.In(requestorPos) |
                (tenants.Count > 0 ?
                TablesLogic.tUser.ObjectID.In(tenants) :
                TablesLogic.tUser.isTenant == 1));
            
        }

        /// <summary>
        /// Gets the list of supporters.
        /// </summary>
        /// <param name="requestor">The requestor.</param>
        /// <returns></returns>
        public static List<OUser> GetListOfSupporters(OUser requestor)
        {
            List<OLocation> locs = GetInstances(requestor, "ORequestForQuotation");
            List<OPosition> positions = OPosition.GetPositionsAtOrBelowLocations(locs, ORole.GetRolesByRoleCode("SUPPORTER"));

            return OUser.GetUsersByPositions(positions);            
        }

        /// <summary>
        /// Gets the instances (ADMIN, MARCOM, OPS).
        /// </summary>
        /// <param name="requestor">The requestor.</param>
        /// <returns></returns>
        public static List<OLocation> GetInstances(OUser requestor, string objectType)
        {
            List<OLocation> locs = requestor.GetAllAccessibleLocation(OApplicationSetting.Current.LocationTypeNameForBuildingActual, objectType);
            List<OLocation> returnLst = new List<OLocation>();
            foreach (OLocation l in locs)
            {
                if (l.ParentPath.ToUpper().StartsWith("ADMIN"))
                    returnLst.AddRange(OLocation.FindLocation(false, "ADMIN"));
                else if (l.ParentPath.ToUpper().StartsWith("MARCOM"))
                    returnLst.AddRange(OLocation.FindLocation(false, "MARCOM"));
                else if (l.ParentPath.ToUpper().StartsWith("OPERATIONS"))
                    returnLst.AddRange(OLocation.FindLocation(false, "OPERATIONS"));
            }

            return returnLst;
        }
    }
}
