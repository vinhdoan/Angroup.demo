using System.Collections.Generic;

//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System.Data;
using Anacle.DataFramework;

namespace LogicLayer
{
    public partial class TStoreTransfer : LogicLayerSchema<OStoreTransfer>
    {
        [Default(0)]
        public SchemaInt IsApprovedForTransfer;
    }

    public abstract partial class OStoreTransfer : LogicLayerPersistentObject
    {
        public int? IsApprovedForTransfer { get; set; }

        public void ApprovedForTransfer()
        {
            if (this.IsApprovedForTransfer == 0 || this.IsApprovedForTransfer == null)
            {
                using (Connection c = new Connection())
                {
                    foreach (OStoreTransferItem sti in this.StoreTransferItems)
                    {
                        OStoreBinReservation sbr = TablesLogic.tStoreBinReservation.Create();
                        sbr.StoreBinID = sti.FromStoreBinID;
                        sbr.CatalogueID = sti.CatalogueID;
                        sbr.BaseQuantityRequired = sti.QuantityToTransfer;
                        sbr.BaseQuantityReserved = sti.QuantityToTransfer;
                        sbr.StoreTransferItemID = this.ObjectID;
                        sbr.Save();
                    }
                    this.IsApprovedForTransfer = 1;
                    this.Save();
                    c.Commit();
                }
            }
        }

        public void sendEmailToTransfer()
        {
            bool same = true;
            foreach (OStoreTransferItem item in this.StoreTransferItems)
            {
                if (item.QuantityToTransfer != item.Quantity)
                {
                    same = false;
                    break;
                }
            }
            string email = "";
            /*
            if (this.FromStore.NotifyUser1 != null)
            {
               email += this.FromStore.NotifyUser1.UserBase.Email + ";";
            }
            if (this.FromStore.NotifyUser2 != null)
            {
               email += this.FromStore.NotifyUser2.UserBase.Email + ";";
            } if (this.FromStore.NotifyUser3 != null)
            {
               email += this.FromStore.NotifyUser3.UserBase.Email + ";";
            } if (this.FromStore.NotifyUser4 != null)
            {
               email += this.FromStore.NotifyUser4.UserBase.Email + ";";
            }*/

            List<OUser> users = OUser.GetUsersByRoleAndAboveLocation(this.FromStore.Location, "INVENTORYADMIN");
            foreach (OUser user in users)
                if (user.UserBase.Email != null && user.UserBase.Email.Trim() != "")
                    email += user.UserBase.Email + ";";

            if (same)
                this.SendMessage("StoreTransfer_FullReceipt", email, "");
            else
                this.SendMessage("StoreTransfer_PartialReceipt", email, "");
        }

        public override DataSet DocumentTemplateDataSet
        {
            get
            {
                DataSet dsTemp = null;
                DataSet ds = new DataSet();
                ds.DataSetName = "StoreTransfer";

                DataTable dtStoreTransfer = TablesLogic.tStoreTransfer.Select(
                    TablesLogic.tStoreTransfer.ObjectNumber.As("StoreTransferNumber"),
                    TablesLogic.tStoreTransfer.CreatedUser,
                    TablesLogic.tStoreTransfer.CreatedDateTime,
                    TablesLogic.tStoreTransfer.ModifiedUser,
                    TablesLogic.tStoreTransfer.FromStore.ObjectName.As("FromStore"),
                    TablesLogic.tStoreTransfer.ToStore.ObjectName.As("ToStore")
                    ).Where(
                    TablesLogic.tStoreTransfer.ObjectID == this.ObjectID
                    & TablesLogic.tStoreTransfer.IsDeleted == 0
                    );

                dtStoreTransfer.TableName = "StoreTransfer";
                dsTemp = dtStoreTransfer.DataSet;
                dsTemp.Tables.Remove(dtStoreTransfer);
                ds.Tables.Add(dtStoreTransfer);

                DataTable dtItems = TablesLogic.tStoreTransfer.Select(
                    TablesLogic.tStoreTransfer.StoreTransferItems.Catalogue.ObjectName.As("Description"),
                    TablesLogic.tStoreTransfer.StoreTransferItems.FromStoreBin.ObjectName.As("FromStoreBin"),
                    TablesLogic.tStoreTransfer.StoreTransferItems.ToStoreBin.ObjectName.As("ToStoreBin"),
                    TablesLogic.tStoreTransfer.StoreTransferItems.Catalogue.UnitOfMeasure.ObjectName.As("UOM"),
                    TablesLogic.tStoreTransfer.StoreTransferItems.Quantity
                    ).Where(
                    TablesLogic.tStoreTransfer.ObjectID == this.ObjectID
                    & TablesLogic.tStoreTransfer.StoreTransferItems.IsDeleted == 0
                    )
                    .OrderBy(
                    TablesLogic.tStoreTransfer.StoreTransferItems.Catalogue.ObjectName.Asc,
                    TablesLogic.tStoreTransfer.StoreTransferItems.Quantity.Asc
                   );

                dtItems.TableName = "StoreTransferItems";
                dsTemp = dtItems.DataSet;
                dsTemp.Tables.Remove(dtItems);
                ds.Tables.Add(dtItems);

                return ds;
            }
        }
    }
}