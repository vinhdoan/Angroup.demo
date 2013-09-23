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
    /// Summary description for OStoreItem
    /// Catalogue item that could be store in the store.
    /// Actual item with its quantity will be reflected in the storebin object
    /// </summary>
    public partial class TStoreItemTransaction : LogicLayerSchema<OStoreItemTransaction>
    {
       
        
    }


    /// <summary>
    /// Represents a single history of transaction against an item
    /// batch in the store.
    /// </summary>
    
    public abstract partial class OStoreItemTransaction : LogicLayerPersistentObject
    {
        //9th March 2011, Joey
        //shows the object number of the source object
        public string SourceObjectNumber
        {
            get
            {

                if (TransactionType == StoreItemTransactionType.CheckIn)
                {
                    return TablesLogic.tStoreCheckInItem.Select(
                                TablesLogic.tStoreCheckInItem.StoreCheckIn.ObjectNumber)
                                .Where(TablesLogic.tStoreCheckInItem.ObjectID == this.SourceObjectID &
                                       TablesLogic.tStoreCheckInItem.IsDeleted == 0);

                }
                else if (TransactionType == StoreItemTransactionType.CheckOut)
                {
                    return TablesLogic.tStoreCheckOutItem.Select(
                                TablesLogic.tStoreCheckOutItem.StoreCheckOut.ObjectNumber)
                                .Where(TablesLogic.tStoreCheckOutItem.ObjectID == this.SourceObjectID &
                                       TablesLogic.tStoreCheckOutItem.IsDeleted == 0);
                }
                else if (TransactionType == StoreItemTransactionType.StoreTransfer)
                {
                    return TablesLogic.tStoreTransferItem.Select(
                               TablesLogic.tStoreTransferItem.StoreTransfer.ObjectNumber)
                               .Where(TablesLogic.tStoreTransferItem.ObjectID == this.SourceObjectID &
                                      TablesLogic.tStoreTransferItem.IsDeleted == 0);
                }

                else if (TransactionType == StoreItemTransactionType.Adjust)
                {
                    return TablesLogic.tStoreAdjustItem.Select(
                               TablesLogic.tStoreAdjustItem.StoreAdjust.ObjectNumber)
                               .Where(TablesLogic.tStoreAdjustItem.ObjectID == this.SourceObjectID &
                                      TablesLogic.tStoreAdjustItem.IsDeleted == 0);
                }

                return "";
            }
        }
        /// <summary>
        /// Gets the localized text representing the transaction type.
        /// </summary>
        public string Remarks
        {
            get
            {
                
                if (TransactionType == StoreItemTransactionType.CheckIn)
                {
                    return TablesLogic.tStoreCheckInItem.Select(
                                TablesLogic.tStoreCheckInItem.StoreCheckIn.Description)
                                .Where(TablesLogic.tStoreCheckInItem.ObjectID == this.SourceObjectID &
                                       TablesLogic.tStoreCheckInItem.IsDeleted == 0);
                   
                }
                else if (TransactionType == StoreItemTransactionType.CheckOut)
                {
                    return TablesLogic.tStoreCheckOutItem.Select(
                                TablesLogic.tStoreCheckOutItem.StoreCheckOut.Description)
                                .Where(TablesLogic.tStoreCheckOutItem.ObjectID == this.SourceObjectID &
                                       TablesLogic.tStoreCheckOutItem.IsDeleted == 0);
                }
                else if (TransactionType == StoreItemTransactionType.StoreTransfer)
                {
                    return TablesLogic.tStoreTransferItem.Select(
                               TablesLogic.tStoreTransferItem.StoreTransfer.Description)
                               .Where(TablesLogic.tStoreTransferItem.ObjectID == this.SourceObjectID &
                                      TablesLogic.tStoreTransferItem.IsDeleted == 0);
                }
               
                else if (TransactionType == StoreItemTransactionType.Adjust)
                {
                    return TablesLogic.tStoreAdjustItem.Select(
                               TablesLogic.tStoreAdjustItem.StoreAdjust.Description)
                               .Where(TablesLogic.tStoreAdjustItem.ObjectID == this.SourceObjectID &
                                      TablesLogic.tStoreAdjustItem.IsDeleted == 0);
                }

                return "";
            }
        }


      
    }


   
}
