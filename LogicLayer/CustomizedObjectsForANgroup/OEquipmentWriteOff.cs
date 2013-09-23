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
    public partial class TEquipmentWriteOff : LogicLayerSchema<OEquipmentWriteOff>
    {
        [Size(255)]
        public SchemaString Description;
        public TEquipmentWriteOffItem EquipmentWriteOffItems { get { return OneToMany<TEquipmentWriteOffItem>("EquipmentWriteOffID"); } }
    }



    public abstract partial class OEquipmentWriteOff : LogicLayerPersistentObject, IWorkflowEnabled, IAutoGenerateRunningNumber
    {
        public abstract string Description { get; set; }
        public abstract DataList<OEquipmentWriteOffItem> EquipmentWriteOffItems { get; set; }
        public decimal TaskAmount
        {
            get
            {
                decimal amount = 0;
                foreach (OEquipmentWriteOffItem item in this.EquipmentWriteOffItems)
                {
                    if(item.Equipment.PriceAtOwnership != null)
                        amount += item.Equipment.PriceAtOwnership.Value;
                    
                }
                return amount;
            }
        }
        public List<OLocation> TaskLocations
        {
            get
            {
                List<Guid> locIDs = new List<Guid>();
                foreach (OEquipmentWriteOffItem item in this.EquipmentWriteOffItems)
                {
                    if (item.Equipment.IsInStore == 1)
                    {
                        if (!locIDs.Contains((Guid)item.Equipment.Store.LocationID))
                            locIDs.Add((Guid)item.Equipment.Store.LocationID);
                    }
                    else
                    {
                        if (!locIDs.Contains((Guid)item.Equipment.LocationID))
                            locIDs.Add((Guid)item.Equipment.LocationID);
                    }

                }
                return TablesLogic.tLocation.LoadList(
                            TablesLogic.tLocation.ObjectID.In(locIDs));
            }
        }
        public List<OEquipment> TaskEquipments
        {
            get
            {
                List<Guid> equipIDs = new List<Guid>();
                foreach (OEquipmentWriteOffItem item in this.EquipmentWriteOffItems)
                {
                    if (!equipIDs.Contains((Guid)item.EquipmentID))
                        equipIDs.Add((Guid)item.EquipmentID);
                }
                return TablesLogic.tEquipment.LoadList(
                            TablesLogic.tEquipment.ObjectID.In(equipIDs));
            }
        }
        public void Approved()
        {
            foreach (OEquipmentWriteOffItem item in this.EquipmentWriteOffItems)
            {
                item.Equipment.WriteOff();
            }
            OApplicationSetting appsetting = OApplicationSetting.Current;
            if (appsetting != null && appsetting.EmailForEquipmentWriteOff != String.Empty)
            {
                OMessageTemplate messageTemplate = TablesLogic.tMessageTemplate.Load(
                                    TablesLogic.tMessageTemplate.MessageTemplateCode == "Equipment_WriteOffApproved");
                if (messageTemplate != null)
                    messageTemplate.GenerateAndSendMessage(this, appsetting.EmailForEquipmentWriteOff, "");


            }

        }
        public void SetEquipmentStatus()
        { 
            using(Connection c =new Connection())
            {
                if (this.CurrentActivity.ObjectName == "PendingApproval" &&
                    this.CurrentActivity.TriggeringEventName == "SubmitForApproval")
                {
                    foreach (OEquipmentWriteOffItem item in EquipmentWriteOffItems)
                    {
                        OEquipment equip = item.Equipment;
                        item.OriginalEquipmentStatus = item.Equipment.Status;
                        item.Save();
                        equip.Status = EquipmentStatusType.PendingWriteOff;
                        equip.Save();
                    }
                }
                else if (this.CurrentActivity.ObjectName == "Approved")
                {
                    foreach (OEquipmentWriteOffItem item in EquipmentWriteOffItems)
                    {
                        OEquipment equip = item.Equipment;
                        equip.Status = EquipmentStatusType.WrittenOff;
                        equip.Save();
                    }
                }
                else if (this.CurrentActivity.ObjectName == "Cancelled" ||
                    this.CurrentActivity.ObjectName == "RejectedforRework")
                {
                    foreach (OEquipmentWriteOffItem item in EquipmentWriteOffItems)
                    {
                        OEquipment equip = item.Equipment;
                        equip.Status = item.OriginalEquipmentStatus;
                        equip.Save();
                    }
                }
                c.Commit();
            }
        }
        public bool IsEquipmentDuplicated(Guid? equipmentID,Guid? itemID)
        {
            OEquipmentWriteOffItem item = this.EquipmentWriteOffItems.Find((r) => r.EquipmentID == equipmentID
                                                                             && r.ObjectID != itemID);
            if (item != null)
                return true;
            return false;
        }
    }
    
}
