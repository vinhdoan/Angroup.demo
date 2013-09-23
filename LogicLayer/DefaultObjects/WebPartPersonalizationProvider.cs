//========================================================================
// $Product: Simplism Enterprise Asset Management
// $Version: 1.0
//
// All rights reserved.
//========================================================================
using System;
using System.Configuration.Provider;
using System.Security.Permissions;
using System.Web;
using System.Web.UI.WebControls.WebParts;
using System.Collections.Specialized;
using System.Security.Cryptography;
using System.Text;
using System.IO;

using Anacle.DataFramework;

namespace LogicLayer
{
    public class WebPartsPersonalizationProvider : PersonalizationProvider
    {
        /// <summary>
        /// This property is not supported.
        /// </summary>
        public override string ApplicationName
        {
            get
            {
                throw new NotSupportedException();
            }
            set
            {
                throw new NotSupportedException();
            }
        }


        /// <summary>
        /// Loads the personalization data bytes.
        /// </summary>
        /// <param name="webPartManager"></param>
        /// <param name="path"></param>
        /// <param name="userName"></param>
        /// <param name="sharedDataBlob"></param>
        /// <param name="userDataBlob"></param>
        protected override void LoadPersonalizationBlobs(WebPartManager webPartManager, string path, string userName, ref byte[] sharedDataBlob, ref byte[] userDataBlob)
        {
            userName = Workflow.CurrentUser.UserBase.LoginName;
            OUserWebPartsPersonalization p = OUserWebPartsPersonalization.GetPersonalization("", path, userName);

            if (p != null)
            {
                if (String.IsNullOrEmpty(userName))
                    sharedDataBlob = p.Bytes;
                else
                    userDataBlob = p.Bytes;
            }
        }

        /// <summary>
        /// Deletes the personalization data from the database.
        /// </summary>
        /// <param name="webPartManager"></param>
        /// <param name="path"></param>
        /// <param name="userName"></param>
        protected override void ResetPersonalizationBlob(WebPartManager webPartManager, string path, string userName)
        {
            userName = Workflow.CurrentUser.UserBase.LoginName;
            OUserWebPartsPersonalization.DeletePersonalization("", path, userName);
        }


        /// <summary>
        /// Saves the personalization data into the database.
        /// </summary>
        /// <param name="webPartManager"></param>
        /// <param name="path"></param>
        /// <param name="userName"></param>
        /// <param name="dataBlob"></param>
        protected override void SavePersonalizationBlob(WebPartManager webPartManager, string path, string userName, byte[] dataBlob)
        {
            using (Connection c = new Connection())
            {
                userName = Workflow.CurrentUser.UserBase.LoginName;
                OUserWebPartsPersonalization p = OUserWebPartsPersonalization.GetPersonalization("", path, userName);

                if (p == null)
                    p = TablesLogic.tUserWebPartsPersonalization.Create();
                p.ApplicationName = "";
                p.Path = path;
                p.UserName = userName;
                p.Bytes = dataBlob;
                p.Save();
                c.Commit();
            }
        }


        /// <summary>
        /// This method is not supported.
        /// </summary>
        /// <param name="scope"></param>
        /// <param name="query"></param>
        /// <param name="pageIndex"></param>
        /// <param name="pageSize"></param>
        /// <param name="totalRecords"></param>
        /// <returns></returns>
        public override PersonalizationStateInfoCollection FindState(PersonalizationScope scope, PersonalizationStateQuery query, int pageIndex, int pageSize, out int totalRecords)
        {
            throw new NotSupportedException();
        }


        /// <summary>
        /// This method is not supported.
        /// </summary>
        /// <param name="scope"></param>
        /// <param name="query"></param>
        /// <returns></returns>
        public override int GetCountOfState(PersonalizationScope scope, PersonalizationStateQuery query)
        {
            throw new NotSupportedException();
        }


        /// <summary>
        /// This method is not supported.
        /// </summary>
        /// <param name="scope"></param>
        /// <param name="paths"></param>
        /// <param name="usernames"></param>
        /// <returns></returns>
        public override int ResetState(PersonalizationScope scope, string[] paths, string[] usernames)
        {
            throw new NotSupportedException();
        }


        /// <summary>
        /// This method is not supported.
        /// </summary>
        /// <param name="path"></param>
        /// <param name="userInactiveSinceDate"></param>
        /// <returns></returns>
        public override int ResetUserState(string path, DateTime userInactiveSinceDate)
        {
            throw new NotSupportedException();
        }

    }
}
