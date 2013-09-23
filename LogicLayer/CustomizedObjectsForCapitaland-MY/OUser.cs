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

    }


    /// <summary>
    /// Represents a user account in the system. Details
    /// about the user, including his/her contact details and login
    /// credentials can be found in the UserBase property, which
    /// is an OUserBase object.
    /// </summary>
    public abstract partial class OUser : LogicLayerPersistentObject,ICloneable
    {
        public abstract int? EnableAllBuildingForGWJ { get; set; }

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
    }
}
