//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Configuration;
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
    /// Summary description for OChecklist
    /// </summary>
    [Database("#database"), Map("Craft")]
    [Serializable] public partial class TCraft : LogicLayerSchema<OCraft>
    {
        public SchemaDecimal NormalHourlyRate;
        public SchemaDecimal OvertimeHourlyRate;

        public TUser Users { get { return OneToMany<TUser>("CraftID"); } }
    }


    /// <summary>
    /// Represents a craft record containing information
    /// about the normal and overtime hourly rates of a technician.
    /// Basically, craft is a record indicating the superiority
    /// of the in-house technician in a company, and his pay scale.
    /// </summary>
    [Serializable]
    public abstract partial class OCraft : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the hourly rate for normal hours work.
        /// </summary>
        public abstract decimal? NormalHourlyRate { get;set;}
        /// <summary>
        /// [Column] Gets or sets the hourly rate for overtime work.
        /// </summary>
        public abstract decimal? OvertimeHourlyRate { get;set;}

        /// <summary>
        /// Gets a one-to-many list of OUser objects that represents a list 
        /// of users associated with this craft.
        /// </summary>
        public abstract DataList<OUser> Users { get; }


        /// <summary>
        /// Disallows the deletion if:
        /// 1. There is at least one user with this craft.
        /// </summary>
        /// <returns></returns>
        public override bool IsDeactivatable()
        {
            if (TablesLogic.tUser.LoadList(
                TablesLogic.tUser.CraftID == this.ObjectID).Count > 0)
                return false;

            return base.IsDeactivatable();
        }


        public static List<OCraft> GetAllCraft()
        {
            return TablesLogic.tCraft[Query.True];
        }

        public static List<OCraft> GetCraftByLocation(OLocation location)
        {
            return null;
            /*
             * TODO: Resolve user access control later
            if (location == null)
                return null;
            else
                return TablesLogic.tCraft[
                    ((ExpressionDataString)location.HierarchyPath).Like(
                    TablesLogic.tCraft.Users.LocationAccess.HierarchyPath + "%")];*/
        }
    }

}
