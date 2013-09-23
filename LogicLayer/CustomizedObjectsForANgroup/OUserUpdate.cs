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

    public partial class TUserUpdate : LogicLayerSchema<OUserUpdate>
    {
        [Default(0)]
        public SchemaInt IsApproved;
        public TUserUpdateUser UserUpdateUser { get { return OneToMany<TUserUpdateUser>("UserUpdateID"); } }
    }

    public abstract partial class OUserUpdate : LogicLayerPersistentObject, IAutoGenerateRunningNumber, IWorkflowEnabled
    {
        public abstract int? IsApproved { get; set; }
        public abstract DataList<OUserUpdateUser> UserUpdateUser { get; set; }

        public void setApproved()
        {
            using (Connection c = new Connection())
            {
                if (this.IsApproved != 1)
                {
                    this.IsApproved = 1;
                    this.Save();
                    this.UpdatePositions();
                    c.Commit();
                }
            }
        }

        /// <summary>
        /// Runs through all the UserUpdateUser in UserUpdate Object
        /// If there are any positions in the UserUpdateUser Object
        /// It Will replace the current users with the new positions.
        /// </summary>
        public void UpdatePositions()
        {
            foreach (OUserUpdateUser u in this.UserUpdateUser)
            {
                if (u.PermanentPositions.Count > 0)
                {
                    OUser currentUser = TablesLogic.tUser.Load(u.UserID);
                    currentUser.PermanentPositions.Clear();
                    foreach (OUserPermanentPosition p in u.PermanentPositions)
                    {
                        using (Connection c = new Connection())
                        {
                            OUserPermanentPosition newPP = TablesLogic.tUserPermanentPosition.Create();
                            newPP.PositionID = p.PositionID;
                            newPP.StartDate = p.StartDate;
                            newPP.EndDate = p.EndDate;
                            newPP.UserID = p.UserID;
                            newPP.Save();
                            currentUser.PermanentPositions.Add(newPP);
                            currentUser.Save();
                            c.Commit();
                        }
                    }
                }
            }
        }
    }
    
}
