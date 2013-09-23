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

    public partial class TUserCreation : LogicLayerSchema<OUserCreation>
    {
        [Default(0)]
        public SchemaInt IsApproved;
        public TUserCreationUser UserCreationUser { get { return OneToMany<TUserCreationUser>("UserCreationID"); } }
    }

    public abstract partial class OUserCreation : LogicLayerPersistentObject, IAutoGenerateRunningNumber, IWorkflowEnabled
    {
        public abstract int? IsApproved { get; set; }
        public abstract DataList<OUserCreationUser> UserCreationUser { get; set; }

        public void setApproved()
        {
            using (Connection c = new Connection())
            {
                if (this.IsApproved != 1)
                {
                    this.IsApproved = 1;
                    this.Save();
                    this.CreateUsers();
                    c.Commit();
                }
            }
        }

        public void CreateUsers()
        {
            foreach (OUserCreationUser u in this.UserCreationUser)
            {
                using (Connection c = new Connection())
                {
                    OUser newUser = TablesLogic.tUser.Create();
                    newUser.ObjectName = u.ObjectName;
                    newUser.Description = u.Description;
                    newUser.IsActiveDirectoryUser = u.IsActiveDirectoryUser;
                    newUser.ActiveDirectoryDomain = u.ActiveDirectoryDomain;

                    OUserBase newUserBase = TablesLogic.tUserBase.Create();
                    newUserBase.Cellphone = u.CellPhone;
                    newUserBase.Email = u.Email;
                    newUserBase.Fax = u.Fax;
                    newUserBase.Phone = u.Phone;
                    newUserBase.AddressCountry = u.Country;
                    newUserBase.AddressCity = u.City;
                    newUserBase.Address = u.Address;
                    newUserBase.LoginName = u.LoginName;
                    newUserBase.Save();
                    newUser.UserBaseID = newUserBase.ObjectID;
                    newUser.SetNewPassword(u.Password.ToString(), true);

                    foreach(OUserPermanentPosition pp in u.PermanentPosition)
                    {
                        pp.UserID = newUser.ObjectID;
                        newUser.PermanentPositions.Add(pp);
                    }
                    u.NewUserID = newUser.ObjectID;
                    u.Save();
                    newUser.Save();
                    c.Commit();
                    
                }
            }
        }
    }
    
}
