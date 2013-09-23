//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;

using Anacle.DataFramework;

namespace LogicLayer
{
    /// <summary>
    /// Summary description for OWork
    /// </summary>
    public partial class TWork : LogicLayerSchema<OWork>
    {
        public SchemaDateTime ReportedDateTime;

        public SchemaGuid RequestorID;

        public TUser Requestor { get { return OneToOne<TUser>("RequestorID"); } }

        public SchemaGuid TenantContactID;

        public TTenantContact TenantContact { get { return OneToOne<TTenantContact>("TenantContactID"); } }

        public SchemaGuid TenantLeaseID;

        public TTenantLease TenantLease { get { return OneToOne<TTenantLease>("TenantLeaseID"); } }

        public SchemaString RequestorName;
        public SchemaString RequestorCellPhone;
        public SchemaString RequestorFax;
        public SchemaString RequestorEmail;
        public SchemaString RequestorPhone;

        public SchemaInt WorkClassification;
        public SchemaGuid ActualTypeOfWorkID;
        public SchemaGuid ActualTypeOfServiceID;
        public SchemaGuid ActualTypeOfProblemID;

        public SchemaGuid ChargeTypeID;

        public TChargeType ChargeType { get { return OneToOne<TChargeType>("ChargeTypeID"); } }

        public TRequestForQuotation RequestForQuotations { get { return OneToMany<TRequestForQuotation>("WorkID"); } }

        [Default(0)]
        public SchemaInt BillToAMOSStatus;

        [Size(255)]
        public SchemaString AMOSErrorMessage;

        public SchemaGuid LastestBillID;
    }

    public abstract partial class OWork : LogicLayerPersistentObject, IAutoGenerateRunningNumber, IWorkflowEnabled, INotificationEnabled
    {
        /// <summary>
        ///
        /// </summary>
        public abstract DateTime? ReportedDateTime { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract Guid? ChargeTypeID { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract Guid? TenantContactID { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract Guid? TenantLeaseID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the foreign key to the user table.
        /// </summary>
        public abstract Guid? RequestorID { get; set; }

        /// <summary>
        /// [Column] Gets or sets the requestor name.
        /// </summary>
        public abstract String RequestorName { get; set; }

        /// <summary>
        /// [Column] Gets or sets the requestor cell phone.
        /// </summary>
        public abstract String RequestorCellPhone { get; set; }

        /// <summary>
        /// [Column] Gets or sets the requestor fax number.
        /// </summary>
        public abstract String RequestorFax { get; set; }

        /// <summary>
        /// [Column] Gets or sets the requestor email address.
        /// </summary>
        public abstract String RequestorEmail { get; set; }

        /// <summary>
        /// [Column] Gets or sets the requestor phone number.
        /// </summary>
        public abstract String RequestorPhone { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract OUser Requestor { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract OTenantLease TenantLease { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract OTenantContact TenantContact { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract OChargeType ChargeType { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract int? WorkClassification { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract Guid? ActualTypeOfWorkID { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract Guid? ActualTypeOfServiceID { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract Guid? ActualTypeOfProblemID { get; set; }

        /// <summary>
        /// Gets or sets Bill To Amos Status
        /// </summary>
        public abstract int? BillToAMOSStatus { get; set; }

        /// <summary>
        /// Gets or sets AMOS Error Message.
        /// </summary>
        public abstract string AMOSErrorMessage { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract Guid? LastestBillID { get; set; }

        /// <summary>
        ///
        /// </summary>
        public abstract DataList<ORequestForQuotation> RequestForQuotations { get; }

        public List<ORequestForQuotation> NonCancelledRequestForQuotations
        {
            get
            {
                List<ORequestForQuotation> rfqs = new List<ORequestForQuotation>();
                foreach (ORequestForQuotation rfq in this.RequestForQuotations)
                    if (!rfq.CurrentActivity.ObjectName.Is("Cancelled"))
                        rfqs.Add(rfq);
                return rfqs;
            }
        }

        public override void Saved()
        {
            base.Saved();

            // 2011.06.10, Kien Trung
            // NEW: Create a case if there is a requestor selected.
            // or Requestor Name filled in.
            // then SubmitForExecution.
            //SaveCaseAsPendingExecution();
        }

        /// <summary>
        /// 2011.06.10, Kien Trung
        /// Create a new case if there is requestor selected.
        ///
        /// </summary>
        public void SaveCaseAsPendingExecution()
        {
            using (Connection c = new Connection())
            {
                if (this.CaseID == null && (this.RequestorID != null ||
                    (this.RequestorName != null && this.RequestorName.Trim() != "")))
                {
                    OCase newCase = TablesLogic.tCase.Create();
                    newCase.ReportedDateTime = DateTime.Now;
                    newCase.RequestorID = this.RequestorID;
                    newCase.RequestorName = this.RequestorName;
                    newCase.RequestorEmail = this.RequestorEmail;
                    newCase.RequestorFax = this.RequestorFax;
                    newCase.RequestorPhone = this.RequestorPhone;
                    newCase.RequestorCellPhone = this.RequestorCellPhone;
                    newCase.LocationID = this.LocationID;
                    newCase.EquipmentID = this.EquipmentID;
                    newCase.ProblemDescription = this.WorkDescription;
                    newCase.Priority = this.Priority;
                    newCase.SaveAndTransit("SubmitForExecution");
                    this.CaseID = newCase.ObjectID;
                }
                c.Commit();
            }
        }

        public String BillToAMOSStatusText
        {
            get
            {
                if (BillToAMOSStatus == 0)
                    return Resources.Strings.BillToAMOSStatusText_NotPostedToAmos;
                else if (BillToAMOSStatus == 1)
                    return Resources.Strings.BillToAMOSStatusText_PendingPosting;
                else if (BillToAMOSStatus == 2)
                    return Resources.Strings.BillToAMOSStatusText_PostedToAmos;
                else if (BillToAMOSStatus == 3)
                    return Resources.Strings.BillToAMOSStatusText_PostedToAmosFailed;
                else if (BillToAMOSStatus == 4)
                    return Resources.Strings.BillToAMOSStatusText_PostedToAmosSuccessful;
                else if (BillToAMOSStatus == 5)
                    return Resources.Strings.BillToAMOSStatusText_UnableToPostDueToError;
                else if (BillToAMOSStatus == 6)
                    return Resources.Strings.BillToAMOSStatusText_NotPostedCancelled;
                else
                    return "";
            }
        }

        public static bool IsObjectEditOrView(OUser user, Guid objectID, String Object, bool isEditable)
        {
            bool status = false;
            if (isEditable)
            {
                if (user.AllowEditAll(Object) || OActivity.CheckAssignment(user, objectID))
                    status = true;
            }
            else
            {
                if (user.AllowViewAll(Object) || OActivity.CheckAssignment(user, objectID))
                    status = true;
            }
            return status;
        }

        /// <summary>
        /// Validates that the list of RFQ line item numbers and descriptions
        /// that have not been generated into POs.
        /// </summary>
        /// <param name="purchaseRequestItemIds"></param>
        /// <returns></returns>
        public static DataTable ValidateItemsNotGeneratedToRFQ(List<Guid> ItemIds)
        {
            StringBuilder sb = new StringBuilder();

            // Gets a list of all workcost item that have been generated
            // into POs.
            //
            TRequestForQuotationItem Item = TablesLogic.tRequestForQuotationItem;

            DataTable dt = Item.SelectDistinct(
                 Item.WorkCostID,
                 Item.ItemNumber,
                 Item.ItemDescription)
                 .Where(
                 Item.RequestForQuotation.CurrentActivity.ObjectName != "Cancelled" &
                 Item.WorkCostID.In(ItemIds) &
                 Item.IsDeleted == 0);

            return dt;
        }

        /// <summary>
        /// Validates the inventory items.
        /// If IsCheckOut is set to true: will check if any inventory items have actualquantity > 0
        /// If IsCheckOut is set to false: will check if any inventory items have actualquantity = 0
        /// </summary>
        /// <param name="IsCheckOut">if set to <c>true</c> [is check out].</param>
        /// <param name="work">The work.</param>
        /// <returns></returns>
        public static bool ValidateInventoryItems(bool IsCheckOut, OWork work)
        {
            foreach (OWorkCost wc in work.WorkCost)
            {
                if (wc.CostType == WorkCostType.Material)
                {
                    if (IsCheckOut)
                    {
                        if (wc.ActualQuantity > 0)
                            return true;
                    }
                    else
                    {
                        if (wc.ActualQuantity == 0)
                            return true;
                    }
                }
            }
            return false;
        }

        /// <summary>
        /// Reserves the inventory items.
        /// </summary>
        public void ReserveInventoryItems()
        {
            foreach (OWorkCost wc in this.WorkCost)
            {
                if (wc.CostType == WorkCostType.Material && wc.IsCheckOut == 1 && wc.IsReserve != 1)
                {
                    using (Connection c = new Connection())
                    {
                        OStoreBinReservation sbr = TablesLogic.tStoreBinReservation.Create();
                        sbr.StoreBinID = wc.StoreBinID;
                        sbr.CatalogueID = wc.CatalogueID;
                        sbr.BaseQuantityRequired = wc.ActualQuantity == null ? wc.EstimatedQuantity : wc.EstimatedQuantity - wc.ActualQuantity;
                        sbr.BaseQuantityReserved = wc.ActualQuantity == null ? wc.EstimatedQuantity : wc.EstimatedQuantity - wc.ActualQuantity;
                        sbr.WorkCostID = wc.ObjectID;
                        sbr.Save();

                        wc.IsReserve = 1;
                        wc.Save();

                        c.Commit();
                    }
                }
            }
        }

        public void CloseWork()
        {
            using (Connection c = new Connection())
            {
                //check for breach of reading at final stage
                foreach (OReading i in this.WorkPointReadings)
                    i.CheckForBreachOfReading(i.Point);

                this.ClearReservations();

                OWork newWork = this.CreateNewWorkOrderBasedOnSchedule();
                if (newWork != null)
                {
                    newWork.Save();
                    newWork.TriggerWorkflowEvent("SubmitForAssignment");
                }

                // Close related case.
                //
                if (OApplicationSetting.Current.CaseEventAfterDocumentClosedOrCancelled != "SubmitForClosure")
                    OCase.CloseCaseWhenAllDocumentsClosedOrCancelled(this.CaseID);

                //2011-12-22 ptb
                //Clear the reserved items
                foreach (OWorkCost sti in this.WorkCost)
                {
                    OStoreBinReservation sbr = TablesLogic.tStoreBinReservation.Load(
                        TablesLogic.tStoreBinReservation.WorkCostID == sti.ObjectID);
                    if (sbr != null)
                    {
                        sbr.BaseQuantityRequired = 0;
                        sbr.Save();
                        sbr.Deactivate();
                    }
                }

                c.Commit();
            }
        }

        /// <summary>
        /// Cancels this Work.
        /// </summary>
        public void Cancel()
        {
            using (Connection c = new Connection())
            {
                //2011-12-22 ptb
                //Clear the reserved items
                foreach (OWorkCost sti in this.WorkCost)
                {
                    OStoreBinReservation sbr = TablesLogic.tStoreBinReservation.Load(
                        TablesLogic.tStoreBinReservation.WorkCostID == sti.ObjectID);
                    if (sbr != null)
                    {
                        sbr.BaseQuantityRequired = 0;
                        sbr.Save();
                        sbr.Deactivate();
                    }
                }

                c.Commit();
            }
        }

        public List<OUser> GetCreator()
        {
            return TablesLogic.tUser.LoadList(TablesLogic.tUser.ObjectID == this.CreatedUserID);
        }
    }

    public enum EnumWorkClassification
    {
        Minor = 0,
        Major = 1,
        Critical = 2
    }
}