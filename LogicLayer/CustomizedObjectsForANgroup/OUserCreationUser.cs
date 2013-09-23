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

    public partial class TUserCreationUser : LogicLayerSchema<OUserCreationUser>
    {
        public SchemaGuid NewUserID;
        public SchemaString Description;
        public SchemaString CellPhone;
        public SchemaString Email;
        public SchemaString Fax;
        public SchemaString Phone;
        public SchemaString Country;
        public SchemaString City;
        public SchemaString Address;
        public SchemaGuid CraftID;
        public SchemaGuid LanguageID;
        public SchemaString LoginName;
        public SchemaInt IsActiveDirectoryUser;
        public SchemaString ActiveDirectoryDomain;
        public SchemaInt ResetPassword;
        public SchemaString Password;
        public SchemaGuid UserCreationID;

        public TCraft Craft { get { return OneToOne<TCraft>("CraftID"); } }
        public TLanguage Language { get { return OneToOne<TLanguage>("LanguageID"); } }
        public TUserCreation UserCreation { get { return OneToOne<TUserCreation>("UserCreationID"); } }
        public TUserPermanentPosition PermanentPosition { get { return OneToMany<TUserPermanentPosition>("UserID"); } }
public TPosition Position { get { return OneToMany<TPosition>("UserID"); } }
        //public TGrantedPositions GrantedPositions { get { return ManyToMany<TGrantedPositions>("UserCreationGrantedPositions", "TenantID", "TenantActivityID"); } }

    }

    public abstract partial class OUserCreationUser : LogicLayerPersistentObject
    {
        public abstract Guid? NewUserID { get; set; }
        public abstract string Description { get; set; }
        public abstract string CellPhone { get; set; }
        public abstract string Email { get; set; }
        public abstract string Fax { get; set; }
        public abstract string Phone { get; set; }
        public abstract string Country { get; set; }
        public abstract string City { get; set; }
        public abstract string Address { get; set; }
        public abstract Guid? CraftID { get; set; }
        public abstract OCraft Craft { get; set; }
        public abstract Guid? LanguageID { get; set; }
        public abstract OLanguage Language { get; set; }
        public abstract string LoginName { get; set; }
        public abstract int? IsActiveDirectoryUser { get; set; }
        public abstract string ActiveDirectoryDomain { get; set; }
        public abstract int? ResetPassword { get; set; }
        public abstract string Password { get; set; }
        public abstract Guid? UserCreationID { get; set; }
        public abstract DataList<OUserPermanentPosition> PermanentPosition { get; set; }
        

        public string IsActiveDirectoryUserText
        {
            get
            {
                return this.IsActiveDirectoryUser == 1 ? Resources.Strings.General_Yes : Resources.Strings.General_No;
            }
        }

        public bool IsDuplicateUserEmail()
        {
            if (TablesLogic.tUser[
                TablesLogic.tUser.UserBase.Email == this.Email &
                TablesLogic.tUser.ObjectID != this.ObjectID].Count > 0)
                return true;

            return false;
        }
    }
}
