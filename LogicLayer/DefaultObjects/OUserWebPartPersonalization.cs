//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Data;
using System.Collections;
using System.Collections.Generic;
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
    [Serializable]
    public partial class TUserWebPartsPersonalization : LogicLayerSchema<OUserWebPartsPersonalization>
    {
        [Size(255)]
        public SchemaString ApplicationName;
        [Size(255)]
        public SchemaString Path;
        [Size(255)]
        public SchemaString UserName;
        public SchemaImage Bytes;
    }


    /// <summary>
    /// Represents WebPart personalization used by ASP.NET
    /// to persist webparts personalization data.
    /// </summary>
    public abstract partial class OUserWebPartsPersonalization : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the application name
        /// that this personalization data is meant for.
        /// </summary>
        public abstract string ApplicationName { get; set; }

        /// <summary>
        /// [Column] Gets or sets the path of the page
        /// that this personalization data is meant for.
        /// </summary>
        public abstract String Path { get; set; }

        /// <summary>
        /// [Column] Gets or sets the name of the user
        /// that this personalization data is meant for.
        /// <para></para>
        /// When the scope of the personalization data
        /// is non-user-specific, the UserName field
        /// can be an empty string.
        /// </summary>
        public abstract String UserName { get; set; }

        /// <summary>
        /// [Column] Gets or sets the data bytes.
        /// </summary>
        public abstract byte[] Bytes { get; set; }


        /// <summary>
        /// Gets the personalization object with the specified
        /// application name, path and user name.
        /// </summary>
        /// <param name="applicationName"></param>
        /// <param name="path"></param>
        /// <param name="userName"></param>
        /// <returns></returns>
        public static OUserWebPartsPersonalization GetPersonalization(
            string applicationName, string path, string userName)
        {
            return TablesLogic.tUserWebPartsPersonalization.Load(
                TablesLogic.tUserWebPartsPersonalization.ApplicationName == applicationName &
                TablesLogic.tUserWebPartsPersonalization.Path == path &
                TablesLogic.tUserWebPartsPersonalization.UserName == userName);
        }


        /// <summary>
        /// Physically removes the personalization object with 
        /// the specified application name, path and user name
        /// from the database.
        /// </summary>
        /// <param name="applicationName"></param>
        /// <param name="path"></param>
        /// <param name="userName"></param>
        public static void DeletePersonalization(
            string applicationName, string path, string userName)
        {
            // 2010.05.23
            // An error occurs when we delete the last dashboard
            // on the dashboard page, so we have to wrap the delete
            // within a Connection boundary.
            //
            using (Connection c = new Connection())
            {
                TablesLogic.tUserWebPartsPersonalization.DeleteList(
                    TablesLogic.tUserWebPartsPersonalization.ApplicationName == applicationName &
                    TablesLogic.tUserWebPartsPersonalization.Path == path &
                    TablesLogic.tUserWebPartsPersonalization.UserName == userName);

                c.Commit();
            }
        }
    }
}
