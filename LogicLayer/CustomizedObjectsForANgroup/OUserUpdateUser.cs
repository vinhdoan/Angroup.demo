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

    public partial class TUserUpdateUser : LogicLayerSchema<OUserUpdateUser>
    {
        public SchemaGuid UserID;
        public SchemaGuid UserUpdateID;

        public TUser User { get { return OneToOne<TUser>("UserID"); } }
        public TUserUpdate UserUpdate { get { return OneToOne<TUserUpdate>("UserUpdateID"); } }
        public TPosition Position { get { return ManyToMany<TPosition>("UserUpdateUserPositions", "UserUpdateUserID", "PositionID"); } }
        public TUserPermanentPosition PermanentPositions { get { return OneToMany<TUserPermanentPosition>("UserID"); } }
    }

    public abstract partial class OUserUpdateUser : LogicLayerPersistentObject
    {
        public abstract Guid? UserID { get; set; }
        public abstract Guid? UserUpdateID { get; set; }

        public abstract OUser User { get; set; }
        public abstract OUserUpdate UserUpdate { get; set; }
        public abstract DataList<OPosition> Position { get; set; }
        public abstract DataList<OUserPermanentPosition> PermanentPositions { get; set; }

        public string NewPositionsText
        {
            get
            {
                string positions = "";
                
                foreach (OUserPermanentPosition p in this.PermanentPositions)
                    positions += (positions == "" ? "" : ", ") + p.Position.ObjectName;
                return positions;
            }
        }

        public string CurrentPositionsText
        {
            get
            {
                string positions = "";
                foreach (OUserPermanentPosition p in this.User.PermanentPositions)
                    positions += (positions == "" ? "" : ", ") + p.Position.ObjectName;
                return positions;
            }
        }
    }
}
