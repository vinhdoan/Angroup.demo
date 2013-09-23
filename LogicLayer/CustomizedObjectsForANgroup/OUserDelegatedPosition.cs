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
    [Serializable]
    public partial class TUserDelegatedPosition : LogicLayerSchema<OUserDelegatedPosition>
    {
        public SchemaGuid DelegatedByUserID;
        public SchemaGuid UserID;
        public SchemaGuid PositionID;
        [Default(0)]
        public SchemaInt AssignedFlag;
        public SchemaDateTime StartDate;
        public SchemaDateTime EndDate;

        public TUser DelegatedByUser { get { return OneToOne<TUser>("DelegatedByUserID"); } }
        public TUser User { get { return OneToOne<TUser>("UserID"); } }
        public TPosition Position { get { return OneToOne<TPosition>("PositionID"); } }
    }


    /// <summary>
    /// </summary>
    public abstract partial class OUserDelegatedPosition : LogicLayerPersistentObject, IAuditTrailEnabled
    {
        public abstract Guid? DelegatedByUserID { get; set; }
        public abstract Guid? UserID { get; set; }
        public abstract Guid? PositionID { get; set; }
        public abstract int? AssignedFlag { get; set; }
        public abstract DateTime? StartDate { get; set; }
        public abstract DateTime? EndDate { get; set; }

        public abstract OUser DelegatedByUser { get; set; }
        public abstract OUser User { get; set; }
        public abstract OPosition Position { get; set; }


        public override void Saving()
        {
            base.Saving();
            this.AssignedFlag = 0;
        }
    }
}
