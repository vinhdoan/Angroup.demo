#region References

using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;
using LogicLayer.ExchangeWebServices;
using Microsoft.Exchange.WebServices.Data;

#endregion References

namespace LogicLayer
{
    class ExchangeHelper
    {
        static ExchangeServiceBinding service = new ExchangeServiceBinding();

        /********************************************************************
          * INITIALIZE MS EXCHANGE WEB SERVICE
          ********************************************************************/
        public static void InitMSExchange()
        {
            OApplicationSetting appSetting = OApplicationSetting.Current;
            service.RequestServerVersionValue = new RequestServerVersion();
            service.RequestServerVersionValue.Version = ExchangeVersionType.Exchange2007_SP1;

            ServicePointManager.ServerCertificateValidationCallback = delegate(
                Object obj, X509Certificate certificate, X509Chain chain, SslPolicyErrors errors)
            {
                // trust any certificate
                return true;
            };

            // enable compression
            service.EnableDecompression = true;
            // your email account userName, password and the windows domain
            service.Credentials = new NetworkCredential(appSetting.EmailUserName, appSetting.EmailPassword, appSetting.EmailDomain);
            service.Url = appSetting.EmailExchangeWebServiceUrl;
        }


        /********************************************************************
          * GET UNREAD ITEMS FROM A FOLDER
          ********************************************************************/
        public static List<OEmailLog> GetUnReadItems()
        {
            List<OEmailLog> emailList = new List<OEmailLog>();
            // serialize response2  object for diagnostics purposes here
            
            int count = GetUnreadFolderItemsCount("Inbox");

            if (count != 0)
            {
                List<ItemType> InboxList = GetUnReadFolderItems("Inbox");
                foreach (ItemType InboxListItem in InboxList)
                {
                    MessageType InboxListItemMessae = (MessageType)InboxListItem;
                    // Creates OEmailLog object from Email details.
                    emailList.Add(OEmailLog.WriteToEmailLog(InboxListItemMessae.From.Item.EmailAddress,
                        InboxListItemMessae.Subject,InboxListItemMessae.Body.Value));
                }
                // Moves mail to deleted folder
                MoveMailToDeletedFolder();
            }
            return emailList;
        }

        public static void MoveMailToDeletedFolder()
        {
            OApplicationSetting applicationSetting = OApplicationSetting.Current;

            ServicePointManager.ServerCertificateValidationCallback =
            delegate(Object obj, X509Certificate certificate, X509Chain chain, SslPolicyErrors errors)
            {
                // trust any certificate
                return true;
            };

            ExchangeService service = new ExchangeService(ExchangeVersion.Exchange2007_SP1);

            service.Credentials = new NetworkCredential(applicationSetting.EmailUserName, applicationSetting.EmailPassword, applicationSetting.EmailDomain);
            service.Url = new Uri(applicationSetting.EmailExchangeWebServiceUrl);

            FindItemsResults<Item> findResults =
            service.FindItems(WellKnownFolderName.Inbox, new ItemView(10));
            if (findResults.TotalCount > 0)
            {
                service.LoadPropertiesForItems(findResults.Items, PropertySet.FirstClassProperties);
                foreach (Item item in findResults.Items)
                {
                    item.Delete(DeleteMode.MoveToDeletedItems);
                }
            }
        }

        /********************************************************************
          * MARK ITEM AS READ
          ********************************************************************/
        public static bool SetReadStatus(ItemIdType item)
        {
            SetItemFieldType setField = new SetItemFieldType();
            PathToUnindexedFieldType path = new PathToUnindexedFieldType();

            MessageType message = new MessageType();
            message.IsRead = true;
            message.IsReadSpecified = true;
            setField.Item1 = message;
            path.FieldURI = UnindexedFieldURIType.messageIsRead;

            setField.Item = path;
            ItemChangeType[] updatedItems = new ItemChangeType[1];
            updatedItems[0] = new ItemChangeType();
            updatedItems[0].Updates = new ItemChangeDescriptionType[1];
            updatedItems[0].Updates[0] = setField;

            ItemChangeDescriptionType[] updates = new ItemChangeDescriptionType[1];
            updates[0] = new ItemChangeDescriptionType();
            updates[0].Item = path;

            updatedItems[0].Item = new ItemIdType();
            ((ItemIdType)updatedItems[0].Item).Id = item.Id;
            ((ItemIdType)updatedItems[0].Item).ChangeKey = item.ChangeKey;
            UpdateItemType request = new UpdateItemType();
            request.ItemChanges = updatedItems;
            request.ConflictResolution = ConflictResolutionType.AutoResolve;
            request.MessageDisposition = MessageDispositionType.SaveOnly;
            request.MessageDispositionSpecified = true;

            UpdateItemResponseType response = service.UpdateItem(request);

            if (response.ResponseMessages.Items[0].ResponseClass !=
                                 ResponseClassType.Success)
                return false;
            else
                return true;
        }


        /********************************************************************
          * GET UNREAD ITEM COUNT FROM A FOLDER
          ********************************************************************/
        public static int GetUnreadFolderItemsCount(String folderName)
        {
            int unReadCount = -1;
            // Identify the folder properties to return.
            FolderResponseShapeType properties = new FolderResponseShapeType();
            PathToUnindexedFieldType ptuft = new PathToUnindexedFieldType();
            ptuft.FieldURI = UnindexedFieldURIType.folderManagedFolderInformation;
            PathToUnindexedFieldType[] ptufts = new PathToUnindexedFieldType[1] { ptuft };
            properties.AdditionalProperties = ptufts;
            properties.BaseShape = DefaultShapeNamesType.AllProperties;

            // Form the get folder request.
            BaseFolderIdType p_folder = FindFolderID(folderName);

            GetFolderType request = new GetFolderType();
            request.FolderIds = new BaseFolderIdType[1] { p_folder };
            request.FolderShape = properties;

            // Send the request and get the response.
            GetFolderResponseType response = service.GetFolder(request);

            ArrayOfResponseMessagesType aormt = response.ResponseMessages;
            LogicLayer.ExchangeWebServices.ResponseMessageType[] rmta = aormt.Items;
            foreach (LogicLayer.ExchangeWebServices.ResponseMessageType rmt in rmta)
            {
                if (rmt.ResponseClass == ResponseClassType.Error)
                {
                    throw new Exception(rmt.MessageText);
                }
                else
                {
                    FolderInfoResponseMessageType firmt;
                    firmt = (rmt as FolderInfoResponseMessageType);
                    BaseFolderType[] folders = firmt.Folders;

                    foreach (BaseFolderType rfolder in folders)
                    {
                        if (rfolder is FolderType)
                        {
                            FolderType myFolder;
                            myFolder = (rfolder as FolderType);
                            if (myFolder.UnreadCountSpecified)
                            {
                                unReadCount = myFolder.UnreadCount;
                            }
                        }
                    }
                }
            }
            return unReadCount;
        }

        /********************************************************************
          * FIND FOLDER ID FOR THE NAME GIVEN
          ********************************************************************/
        public static FolderIdType FindFolderID(String folderName)
        {
            DistinguishedFolderIdType objSearchRootFolder = new DistinguishedFolderIdType();
            objSearchRootFolder.Id = DistinguishedFolderIdNameType.msgfolderroot;

            FindFolderType requestFindFolder = new FindFolderType();
            requestFindFolder.Traversal = FolderQueryTraversalType.Deep;
            requestFindFolder.ParentFolderIds = new DistinguishedFolderIdType[] { objSearchRootFolder };
            requestFindFolder.FolderShape = new FolderResponseShapeType();
            requestFindFolder.FolderShape.BaseShape = DefaultShapeNamesType.IdOnly;

            //Search filter definition
            requestFindFolder.Restriction = new RestrictionType();

            #region Contains expression

            ContainsExpressionType objContainsExpression = new ContainsExpressionType();
            objContainsExpression.ContainmentMode = ContainmentModeType.FullString;
            objContainsExpression.ContainmentModeSpecified = true;
            objContainsExpression.ContainmentComparison = ContainmentComparisonType.Exact;
            objContainsExpression.ContainmentComparisonSpecified = true;

            PathToUnindexedFieldType objFieldFolderName = new PathToUnindexedFieldType();
            objFieldFolderName.FieldURI = UnindexedFieldURIType.folderDisplayName;
            objContainsExpression.Item = objFieldFolderName;

            objContainsExpression.Constant = new ConstantValueType();
            objContainsExpression.Constant.Value = folderName;

            #endregion Contains expression

            requestFindFolder.Restriction.Item = objContainsExpression;

            FindFolderResponseType objFindFolderResponse =
                service.FindFolder(requestFindFolder);

            if (objFindFolderResponse.ResponseMessages.Items.Length == 0)
                return null;

            foreach (LogicLayer.ExchangeWebServices.ResponseMessageType responseMsg in
                objFindFolderResponse.ResponseMessages.Items)
            {
                if (responseMsg.ResponseClass == ResponseClassType.Success)
                {
                    FindFolderResponseMessageType objFindResponse =
                        responseMsg as FindFolderResponseMessageType;
                    foreach (
                        BaseFolderType objFolderType in objFindResponse.RootFolder.Folders)
                    {
                        return objFolderType.FolderId;
                    }
                }
            }
            return null;
        }

        /********************************************************************
          * GET UNREAD FOLDER ITEMS
          ********************************************************************/
        private static List<ItemType> GetUnReadFolderItems(String folderName)
        {

            FindItemType findRequest = new FindItemType();
            findRequest.ItemShape = new ItemResponseShapeType();

            ItemResponseShapeType itemProperties = new ItemResponseShapeType();
            // Use the Default shape for the response.            
            itemProperties.BaseShape = DefaultShapeNamesType.AllProperties;
            itemProperties.BodyType = BodyTypeResponseType.Text;
            itemProperties.BodyTypeSpecified = true;

            RestrictionType restrict = new RestrictionType();
            IsEqualToType isEqTo = new IsEqualToType();
            PathToUnindexedFieldType ptuift = new PathToUnindexedFieldType();
            ptuift.FieldURI = UnindexedFieldURIType.messageIsRead;
            isEqTo.Item = ptuift;
            FieldURIOrConstantType msgReadYes = new FieldURIOrConstantType();
            msgReadYes.Item = new ConstantValueType();
            (msgReadYes.Item as ConstantValueType).Value = "0";  //1= boolean yes; so you'll get the list of read messages
            isEqTo.FieldURIOrConstant = msgReadYes;
            restrict.Item = isEqTo;
            findRequest.Restriction = restrict;

            findRequest.ItemShape = itemProperties;

            //Set the inbox as the parent search folder in search attachementRequest.
            BaseFolderIdType p_folder = FindFolderID(folderName);
            findRequest.ParentFolderIds = new BaseFolderIdType[] { p_folder };
            findRequest.Traversal = ItemQueryTraversalType.Shallow;


            // Perform the inbox search
            FindItemResponseType response = service.FindItem(findRequest);
            FindItemResponseMessageType responseMessage = response.ResponseMessages.Items[0] as FindItemResponseMessageType;
            if (responseMessage.ResponseCode != ResponseCodeType.NoError)
            {
                throw new Exception(responseMessage.MessageText);
            }
            else
            {

                // find items details
                GetItemResponseType response2 = service.GetItem(new GetItemType
                {
                    ItemIds = ((response as FindItemResponseType)
                                .ResponseMessages
                                .Items
                                .Select(n => n as FindItemResponseMessageType)
                                .Select(n => n.RootFolder).Single().Item as ArrayOfRealItemsType)
                                .Items
                                .Select(n => new ItemIdType { Id = n.ItemId.Id })
                                .ToArray()
                    ,
                    ItemShape = new ItemResponseShapeType
                    {
                        BaseShape = DefaultShapeNamesType.Default,
                        BodyType = BodyTypeResponseType.Text
                    }
                });

                List<ItemType> messages = new List<ItemType>();

                for (int j = 0; j < response2.ResponseMessages.Items.Count(); j++)
                    messages.Add(((ItemInfoResponseMessageType)response2.ResponseMessages.Items[j]).Items.Items[0]);


                return messages;
            }
        }

        /********************************************************************
          * GET ITEM FOR ID SUPPLIED
          ********************************************************************/
        private static ItemType GetItemForID(String id)
        {
            ItemIdType iit = new ItemIdType();
            iit.Id = id;

            GetItemType git = new GetItemType();
            git.ItemIds = new ItemIdType[] { iit };
            git.ItemShape = new ItemResponseShapeType();
            git.ItemShape.BaseShape = DefaultShapeNamesType.AllProperties;

            GetItemResponseType girt = service.GetItem(git);

            if (girt.ResponseMessages.Items[0].ResponseClass == ResponseClassType.Error)
                throw new Exception(String.Format("Unable to get message item and Mime Content\r\n{0}\r\n{1}",
                                                                               girt.ResponseMessages.Items[0].ResponseCode,
                                                                               girt.ResponseMessages.Items[0].MessageText));
            ItemType message = null;
            if (girt.ResponseMessages.Items.Count() > 0)
                message = (((ItemInfoResponseMessageType)girt.ResponseMessages.Items[0]).Items.Items[0]);

            return message;
        }

        /********************************************************************
          * REPLY AN EMAIL WITH THE ITEMID AND THE REPLYBODY
          ********************************************************************/
        private static void Reply(String itemID, String replyBody)
        {

            ItemIdType iit = new ItemIdType();
            iit.Id = itemID;

            CreateItemType request = new CreateItemType();
            request.MessageDisposition = MessageDispositionType.SendAndSaveCopy;
            request.MessageDispositionSpecified = true;
            request.SavedItemFolderId = new TargetFolderIdType();
            request.SavedItemFolderId.Item = new DistinguishedFolderIdType();
            (request.SavedItemFolderId.Item as DistinguishedFolderIdType).Id = DistinguishedFolderIdNameType.sentitems;

            ReplyToItemType reply = new ReplyToItemType();
            // Id of the message to which to reply
            reply.ReferenceItemId = iit;
            reply.NewBodyContent = new LogicLayer.ExchangeWebServices.BodyType();
            reply.NewBodyContent.BodyType1 = BodyTypeType.HTML;
            reply.NewBodyContent.Value = replyBody;

            // Set additional properties on the reply object if you wish...
            CreateItemResponseType response = service.CreateItem(request);

            if (response.ResponseMessages.Items[0].ResponseClass == ResponseClassType.Success)
            {
                // Success, the reply was sent and saved in the SentItems folder.
                // NB: Since sending a message is an asynchronous operation, NO ITEM ID IS RETURNED.
                // To obtain the Id of the reply message, set the MessageDisposition flag above to SaveOnly.
                // The Id can be found in the response:
                // ItemIdType replyId = ((ItemInfoResponseMessageType)response.ResponseMessages.Items[0]).Items.Items[0].ItemId;
                // You can then call SendItem to send the message.
            }
            else
            {
                // An error has occurred
            }
        }
    }
}