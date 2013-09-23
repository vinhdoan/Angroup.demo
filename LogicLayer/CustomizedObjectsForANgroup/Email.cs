//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Net;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;
using Anacle.DataFramework;
using Microsoft.Exchange.WebServices.Data;
using Pop3;

namespace LogicLayer
{
    public class Email
    {
        public static List<OEmailLog> ReadEmail()
        {
            if (OApplicationSetting.Current.EnableReceiveEmail == 1)
            {
                if (OApplicationSetting.Current.EmailServerType == (int)EnumReceiveEmailServerType.POP3)
                    return GetPOP3Mail();
                else if (OApplicationSetting.Current.EmailServerType == (int)EnumReceiveEmailServerType.MicrosoftExchangeServer2007)
                    return GetExchange2007Email();
            }
            return null;
        }

        /// <summary>
        /// Gets POP3 email.
        /// </summary>
        /// <returns></returns>
        private static List<OEmailLog> GetPOP3Mail()
        {
            OApplicationSetting applicationSetting = OApplicationSetting.Current;

            Pop3Client email = new Pop3Client(applicationSetting.EmailUserName,
                Security.Decrypt(applicationSetting.EmailPassword), applicationSetting.EmailServer, applicationSetting.EmailPort);

            List<OEmailLog> emailList = new List<OEmailLog>();

            email.OpenInbox();

            while (email.NextEmail())
            {
                emailList.Add(OEmailLog.WriteToEmailLog(email.From, email.Subject, email.Body));
                email.DeleteEmail();
            }
            email.CloseConnection();
            return emailList;
        }

        /// <summary>
        /// Method to trust all certificates
        /// </summary>
        /// <param name="obj"></param>
        /// <param name="certificate"></param>
        /// <param name="chain"></param>
        /// <param name="errors"></param>
        /// <returns></returns>
        private static bool TrustAllCertificates(Object obj, X509Certificate certificate, X509Chain chain, SslPolicyErrors errors)
        {
            // trust any certificate
            return true;
        }

        /// <summary>
        /// Gets e-mail using Exchange 2007.
        /// </summary>
        /// <returns></returns>
        public static List<OEmailLog> GetExchange2007Email()
        {
            ServicePointManager.ServerCertificateValidationCallback = TrustAllCertificates;

            OApplicationSetting appSetting = OApplicationSetting.Current;
            ExchangeService service = new ExchangeService(ExchangeVersion.Exchange2007_SP1);
            service.Credentials = new NetworkCredential(appSetting.EmailUserName, Security.Decrypt(appSetting.EmailPassword), appSetting.EmailDomain);
            service.Url = new Uri(appSetting.EmailExchangeWebServiceUrl);

            FindItemsResults<Item> findResults =
                service.FindItems(WellKnownFolderName.Inbox, new ItemView(100));

            List<OEmailLog> emailList = new List<OEmailLog>();
            foreach (Item item in findResults.Items)
            {
                EmailMessage emailMessage = item as EmailMessage;

                if (emailMessage != null)
                {
                    emailMessage.Load();
                    OEmailLog emailLog1 = OEmailLog.WriteToEmailLog(emailMessage.From.Address, emailMessage.Subject, emailMessage.Body);
                    //Connection.ExecuteQuery("#database", "INSERT INTO EmailLog (DateTimeReceived, FromRecipient, Subject, EmailBody, ObjectID, IsDeleted, CreatedDateTime, ModifiedDateTime, CreatedUser, ModifiedUser) VALUES ('" + DateTime.Now.ToString() + "', '" + emailMessage.From.Address +
                    //    "', '" + emailMessage.Subject + "', '" + emailMessage.Body + "', newid(), 0, getdate(), getdate(), '*** SYSTEM ***', '*** SYSTEM ***')");
                    //OEmailLog emailLog = TablesLogic.tEmailLog.Load(TablesLogic.tEmailLog.FromRecipient == emailMessage.From.Address & TablesLogic.tEmailLog.Subject == emailMessage.Subject);

                    OEmailLog emailLog = TablesLogic.tEmailLog.Load(emailLog1.ObjectID);
                    if (emailLog != null)
                    {
                        emailList.Add(emailLog1);
                        emailMessage.Delete(DeleteMode.MoveToDeletedItems);
                    }
                    else
                    {
                        string message = emailMessage.From.Address + "<br/>" + emailMessage.Subject + "<br/>" + emailMessage.Body;
                        OMessage.SendMail(appSetting.EmailForAMOSFailure, appSetting.MessageEmailSender, "Received Email Log (CAMPS CCL) Failure on " + DateTime.Now.ToString(), message, true);
                    }
                }
            }

            return emailList;
        }
    }
}