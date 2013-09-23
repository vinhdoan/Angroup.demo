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
    /// <summary>
    /// Summary description for OStoreItem
    /// Catalogue item that could be store in the store.
    /// Actual item with its quantity will be reflected in the storebin object
    /// </summary>
    [Database("#database"), Map("StoreItemTransaction")]
    [Serializable] public partial class TStoreItemTransaction : LogicLayerSchema<OStoreItemTransaction>
    {
        public SchemaGuid StoreBinItemID;
        public SchemaGuid SourceObjectID;
        public SchemaGuid StoreItemID;
        public SchemaDecimal Quantity;
        public SchemaDecimal UnitPrice;

        public SchemaDateTime DateOfTransaction;
        public SchemaInt TransactionType;
        public SchemaGuid FromStoreID;
        public SchemaGuid ToStoreID;
        public SchemaInt DestinationType;
        public SchemaGuid WorkID;
        public SchemaGuid UserID;
        public SchemaGuid LocationID;
        public SchemaGuid EquipmentID;
        
        public TStoreItem StoreItem { get { return OneToOne<TStoreItem>("StoreItemID"); } }
        public TStore FromStore { get { return OneToOne<TStore>("FromStoreID"); } }
        public TStore ToStore { get { return OneToOne<TStore>("ToStoreID"); } }
        public TWork Work { get { return OneToOne<TWork>("WorkID"); } }
        public TUser User { get { return OneToOne<TUser>("UserID"); } }
        public TLocation Location { get { return OneToOne<TLocation>("LocationID"); } }
        public TEquipment Equipment { get { return OneToOne<TEquipment>("EquipmentID"); } }
        
    }


    /// <summary>
    /// Represents a single history of transaction against an item
    /// batch in the store.
    /// </summary>
    [Serializable] 
    public abstract partial class OStoreItemTransaction : LogicLayerPersistentObject
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the StoreBinItem table
        /// that represents the batch that this transaction acted upon.
        /// </summary>
        public abstract Guid? StoreBinItemID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the StoreCheckInItem,
        /// or StoreCheckOutItem, or StoreTransferItem, or StoreAdjustItem,
        /// or the WorkCost table the original object that resulted in a 
        /// transaction with the batch.
        /// </summary>
        public abstract Guid? SourceObjectID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the StoreItem table.
        /// </summary>
        public abstract Guid? StoreItemID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the quantity adjusted on the item. If this transaction represents a check-in, the quantity will be a positive value. If the transaction represents a check-out, the quantity will be negative value.
        /// </summary>
        public abstract decimal? Quantity { get; set; }

        /// <summary>
        /// [Column] Gets or sets the unit price of the item involved in this transaction.
        /// </summary>
        public abstract decimal? UnitPrice { get; set; }
        
        /// <summary>
        /// [Column] Gets or sets the system date/time the transaction on the
        /// item occured.
        /// </summary>
        public abstract DateTime? DateOfTransaction { get; set; }

        /// <summary>
        /// [Column] Gets or sets the transaction type of this transaction.
        /// <para></para>
        /// 	<list>
        /// 		<item>0 / StoreItemTransactionType.CheckIn: The transaction is a check-in transaction.</item>
        /// 		<item>1 / StoreItemTransactionType.CheckOut: The transaction is a check-out transaction.</item>
        /// 		<item>2 / StoreItemTransactionType.StoreTransfer: The transaction is a store-to-store transfer.</item>
        /// 		<item>3 / StoreItemTransactionType.Receive: The transaction is a receive.</item>
        /// 		<item>4 / StoreItemTransactionType.Adjust: The transaction is a adjustment.</item>
        /// 	</list>
        /// </summary>
        public abstract int? TransactionType { get; set; }

        /// <summary>
        /// [Column] Gets or sets the destination type.
        /// <para></para>
        /// 	<list>
        /// 		<item>0 - StoreDestinationType.None: No destination</item>
        /// 		<item>1 - StoreDestinationType.User: Items are consumed by a user.</item>
        /// 		<item>2 - StoreDestinationType.Work: Items are consumed by a work.</item>
        /// 		<item>3 - StoreDestinationType.Location: Items are consumed by a location.</item>
        /// 		<item>4 - StoreDestinationType.Equipment: Items are consumed by a equipment.</item>
        /// 	</list>
        /// </summary>
        public abstract int? DestinationType { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Store table that 
        /// indicates the store the item was consumed from in this 
        /// transaction.
        /// </summary>
        public abstract Guid? FromStoreID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Store table that 
        /// indicates the store the item was added to in this 
        /// transaction.
        /// </summary>
        public abstract Guid? ToStoreID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Work table that indicates the work that 
        /// consumed the items during this transaction.
        /// </summary>
        public abstract Guid? WorkID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the User table that 
        /// indicates the user who consumed the items during this transaction.
        /// </summary>
        public abstract Guid? UserID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Location table to 
        /// indicate the location that consumed the item in this transaction.
        /// </summary>
        public abstract Guid? LocationID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the Equipment table to indicate the equipment that consumed the item in this transaction.
        /// </summary>
        public abstract Guid? EquipmentID { get; set; }

        /// <summary>
        /// Gets or sets the OStoreItem object that represents the store 
        /// item that this transaction record belongs to.
        /// </summary>
        public abstract OStoreItem StoreItem { get; set; }

        /// <summary>
        /// Gets or sets the OStore object that represents the store the item 
        /// was consumed from in this transaction.
        /// </summary>
        public abstract OStore FromStore { get; set; }

        /// <summary>
        /// Gets or sets the OStore object that represents the store the item 
        /// was added to in this transaction.
        /// </summary>
        public abstract OStore ToStore { get; set; }

        /// <summary>
        /// Gets or sets the OWork object that represents the work that 
        /// consumed the items during this transaction.
        /// </summary>
        public abstract OWork Work { get; set; }

        /// <summary>
        /// Gets or sets the OUser object that represents the user who consumed 
        /// the items during this transaction.
        /// </summary>
        public abstract OUser User { get; set; }

        /// <summary>
        /// Gets or sets the OLocation object that represents the location
        /// that consumed the item in this transaction.
        /// </summary>
        public abstract OLocation Location { get; set; }

        /// <summary>
        /// Gets or sets the OEquipment object that represents the equipment 
        /// that consumed the item in this transaction.
        /// </summary>
        public abstract OEquipment Equipment { get; set; }

        /// <summary>
        /// Gets the localized text representing the transaction type.
        /// </summary>
        public string TransactionTypeText
        {
            get
            {
                if (TransactionType == StoreItemTransactionType.CheckIn)
                    return Resources.Strings.TransactionType_CheckIn;
                else if (TransactionType == StoreItemTransactionType.CheckOut)
                    return Resources.Strings.TransactionType_CheckOut;
                else if (TransactionType == StoreItemTransactionType.StoreTransfer)
                    return Resources.Strings.TransactionType_StoreTransfer;
                else if (TransactionType == StoreItemTransactionType.Receive)
                    return Resources.Strings.TransactionType_Receive;
                else if (TransactionType == StoreItemTransactionType.Adjust)
                    return Resources.Strings.TransactionType_Adjust;
                else if (TransactionType == StoreItemTransactionType.Issue)
                    return Resources.Strings.TransactionType_Issue;
                else if (TransactionType == StoreItemTransactionType.Return)
                    return Resources.Strings.TransactionType_Return;
                return "";
            }
        }


        /// <summary>
        /// Get store item transactions in a data table format, for the specified
        /// year, month and store catalogue item.
        /// </summary>
        /// <param name="year"></param>
        /// <param name="month"></param>
        /// <returns></returns>
        public static List<OStoreItemTransaction> GetStoreItemTransactions(Guid storeItemId, int year, int month)
        {
            DateTime start = new DateTime(year, month, 1);
            DateTime end = start.AddMonths(1);            
            
            return TablesLogic.tStoreItemTransaction[
                TablesLogic.tStoreItemTransaction.StoreItemID == storeItemId &
                TablesLogic.tStoreItemTransaction.DateOfTransaction >= start &
                TablesLogic.tStoreItemTransaction.DateOfTransaction < end];
        }


        /// <summary>
        /// Reverses this transaction by adjusting the values back 
        /// to the OStoreBinItem. An additional transaction is
        /// NOT created to log the adjustment; instead this
        /// transaction is deactivated from the database.
        /// <para></para>
        /// This method is used to cancel check-in/check-out/ 
        /// adjustment/transfer transactions. 
        /// </summary>
        public void ReverseTransaction()
        {
            if (this.IsDeleted == 0)
            {
                using (Connection c = new Connection())
                {
                    // Loads up the store bin item from the database and then
                    // reverses the quantity out caused by the transaction.
                    // 
                    OStoreBinItem storeBinItem = TablesLogic.tStoreBinItem.Load(
                        TablesLogic.tStoreBinItem.ObjectID == this.StoreBinItemID, true);

                    if (this.Quantity != null)
                        storeBinItem.AdjustQuantityForReversal(-this.Quantity.Value);

                    this.Deactivate();
                    c.Commit();
                }
            }
        }


        /// <summary>
        /// Determines if there are transactions that occured after this
        /// transaction on the same OStoreBinItem. 
        /// <para></para>
        /// NOTE: Only active transactions (IsDeleted=0) that occured 
        /// after this will be considered.
        /// </summary>
        /// <returns>
        /// Returns true if there are later transactions, false otherwise.
        /// </returns>
        public bool HasTransactionsThatOccuredAfterThis()
        {
            // Look for any other transactions for the store bin
            // item that has taken place in the future.
            // 
            List<OStoreItemTransaction> allTransactions =
                TablesLogic.tStoreItemTransaction.LoadList(
                TablesLogic.tStoreItemTransaction.DateOfTransaction > this.DateOfTransaction &
                TablesLogic.tStoreItemTransaction.StoreBinItemID == this.StoreBinItemID);

            if (allTransactions.Count > 0)
                return true;
            return false;
        }


        /// <summary>
        /// Gets a list of transactions associated with the
        /// source object, the source object being the line
        /// item in the store check-in/check-out/adjustment/
        /// transfer.
        /// <para></para>
        /// Note: Only the active transactions (IsDeleted=0)
        /// will be returned.
        /// </summary>
        /// <param name="sourceObject">The source object
        /// to get the associated transactions.</param>
        /// <returns>A list of OStoreItemTransaction objects
        /// associated with the source object.</returns>
        public static List<OStoreItemTransaction> GetTransactionsAssociatedWithSourceObject(PersistentObject sourceObject)
        {
            return
                TablesLogic.tStoreItemTransaction.LoadList(
                TablesLogic.tStoreItemTransaction.SourceObjectID == sourceObject.ObjectID);
        }
    }


    public class StoreItemTransactionType
    {
        public const int CheckIn = 0;
        public const int CheckOut = 1;
        public const int StoreTransfer = 2;

        public const int Receive = 3;
        public const int Adjust = 4;
        public const int Issue = 5;
        public const int Return = 6;
    }
}
