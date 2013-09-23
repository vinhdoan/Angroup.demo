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

using Anacle.DataFramework;

namespace LogicLayer
{
    /// <summary>
    /// Summary description for OVendor
    /// </summary>
    public partial class TWork : LogicLayerSchema<OWork>
    {
        [Default(0)]
        public SchemaInt NotifyWorkSupervisor;
        [Default(0)]
        public SchemaInt NotifyWorkTechnician;
        [Default(0)]
        public SchemaInt IsPendingAssignmentNotified;
        [Default(0)]
        public SchemaInt IsPendingExecutionNotified;
        public SchemaInt AssignmentMode;
        public SchemaGuid TechnicianRosterItemID;
        public SchemaString EventToTrigger;
        [Size(255)]
        public SchemaString Remarks;

        public TStoreCheckOut StoreCheckOuts { get { return OneToMany<TStoreCheckOut>("WorkID"); } }
    }

    /// <summary>
    /// Represents a work object, or a work instruction used to instruct an
    /// in-house team of maintenance staff or external contractors to carry
    /// out repair works and routine maintenance works.
    /// <para></para>
    /// It should be noted that all work objects are never associated with
    /// any costs outlay that the company has to bear. All costs associated
    /// with this work are indirect and are paid by other means. For example,
    /// costs of maintenance contractors are paid through upfront warranty
    /// or insurance-type of contracts; costs of in-house maintenance staff
    /// are paid through their regular salary; costs of materials are paid
    /// through purchase into stores.
    /// <para></para>
    /// Thus, costs associated with this work are considered costs of
    /// maintenance, and are not directly payable through the finance..
    /// </summary>
    public abstract partial class OWork : LogicLayerPersistentObject, IAutoGenerateRunningNumber, IWorkflowEnabled, INotificationEnabled
    {
        /// <summary>
        /// [Column] Gets or sets the foreign key to the User table
        /// that indicates the user who called to request for this
        /// work.
        /// </summary>
        public abstract int? NotifyWorkSupervisor { get; set; }

        public abstract int? NotifyWorkTechnician { get; set; }

        public abstract int? IsPendingAssignmentNotified { get; set; }

        public abstract int? IsPendingExecutionNotified { get; set; }

        public abstract int? AssignmentMode { get; set; }

        public abstract Guid? TechnicianRosterItemID { get; set; }

        public abstract String Remarks { get; set; }

        /// <summary>
        /// [Column] Gets or sets the event to trigger when the
        /// Work is created from a Case.
        /// </summary>
        public abstract string EventToTrigger { get; set; }

        public abstract DataList<OStoreCheckOut> StoreCheckOuts { get; set; }

        public void NotifySupervisorPendingAssigment()
        {
            if (this.IsPendingAssignmentNotified != 1 & NotifyWorkSupervisor == 1)
            {
                if (this.Supervisor != null)
                {
                    OUser user = this.Supervisor;
                    this.SendMessage("Work_SupervisorPendingAssignment", user.UserBase.Email, user.UserBase.Cellphone);
                    this.IsPendingAssignmentNotified = 1;
                    this.Save();
                }
            }
        }

        public void NotifyTechnicianPendingExecution()
        {
            if (this.IsPendingExecutionNotified != 1 && NotifyWorkTechnician == 1)
            {
                foreach (OWorkCost workCost in this.WorkCost)
                {
                    if (workCost.Technician != null)
                        this.SendMessage("Work_TechnicianPendingExecution", workCost.Technician.UserBase.Email, workCost.Technician.UserBase.Cellphone);
                }
                this.IsPendingExecutionNotified = 1;
                this.Save();
            }
        }

        public void AddWorkCost(OUser technician)
        {
            OWorkCost workCost = TablesLogic.tWorkCost.Create();
            workCost.CostType = 0;
            workCost.CraftID = technician.CraftID;
            workCost.UserID = technician.ObjectID;
            workCost.ObjectName = technician.ObjectName;
            workCost.CostDescription = technician.ObjectName;
            workCost.WorkID = this.ObjectID;
            workCost.StoreID = null;
            workCost.StoreBinID = null;
            workCost.CatalogueID = null;
            if (workCost.Craft != null)
                workCost.EstimatedUnitCost = workCost.Craft.NormalHourlyRate; //non over time work
            else
                workCost.EstimatedUnitCost = 0;
            workCost.EstimatedCostFactor = 1.0M;
            workCost.EstimatedOvertime = 0; //none over time work
            workCost.EstimatedQuantity = 1; //default to 1 hours of work
            workCost.ActualCostFactor = 1.0M;
            workCost.ActualCostTotal = 0;
            workCost.ActualOvertime = 0;
            workCost.ActualQuantity = 0;
            if (workCost.Craft != null)
                workCost.ActualUnitCost = workCost.Craft.NormalHourlyRate; //non over time work
            else
                workCost.ActualUnitCost = 0;
            //workCost.ChargeOutUnitPrice = workCost.ActualUnitCost;

            this.WorkCost.Add(workCost);
        }

        public String TechnicianNames
        {
            get
            {
                string tech = "";
                foreach (OWorkCost wc in this.WorkCost)
                {
                    if (wc.CostType == WorkCostType.Technician && wc.Technician != null)
                    {
                        tech = (tech != "" ? tech + ',' + wc.Technician.ObjectName : wc.Technician.ObjectName);
                    }
                }
                return tech;
            }
        }

        public DataSet DocumentTemplateDataSetForCheckOut()
        {
            DataSet dsTemp = null;
            DataSet ds = new DataSet();
            ds.DataSetName = "WorkPrint";

            DataTable dtWork = TablesLogic.tWork.Select(
                TablesLogic.tWork.ObjectNumber.As("WorkNumber"),
                TablesLogic.tWork.CreatedUser,
                TablesLogic.tWork.CreatedDateTime,
                TablesLogic.tWork.ModifiedUser,
                this.Location.ObjectName.As("UnitNo"),
                ((ExpressionDataString)(this.Equipment == null ? string.Empty : this.Equipment.Path)).As("EquipmentPath"),
                TablesLogic.tWork.Requestor.ObjectName.As("TenantName"),
                TablesLogic.tWork.ReportedDateTime,
                //TablesLogic.tWork.Department.ObjectName.As("DepartmentName"),
                TablesLogic.tWork.TypeOfWork.ObjectName.As("TypeOfWork"),
                TablesLogic.tWork.TypeOfService.ObjectName.As("TypeOfService"),
                TablesLogic.tWork.TypeOfProblem.ObjectName.As("TypeOfProblem"),
                //TablesLogic.tWork.Priority,
                this.PriorityText.As("Priority"),
                TablesLogic.tWork.WorkDescription,
                TablesLogic.tWork.ArrivalDateTime,
                TablesLogic.tWork.ActualStartDateTime,
                TablesLogic.tWork.ActualEndDateTime,
                TablesLogic.tWork.ResolutionDescription
                ).Where(
                TablesLogic.tWork.ObjectID == this.ObjectID
                );

            dtWork.TableName = "WorkOrder";
            dsTemp = dtWork.DataSet;
            dsTemp.Tables.Remove(dtWork);
            ds.Tables.Add(dtWork);

            DataTable dtCost = TablesLogic.tWork.Select(
                Anacle.DataFramework.Case.When(TablesLogic.tWork.WorkCost.CostType == WorkCostType.Technician, (ExpressionDataString)Resources.Strings.CostType_Technician)
                    .When(TablesLogic.tWork.WorkCost.CostType == WorkCostType.FixedRate, (ExpressionDataString)Resources.Strings.CostType_FixedRate)
                    .When(TablesLogic.tWork.WorkCost.CostType == WorkCostType.AdhocRate, (ExpressionDataString)Resources.Strings.CostType_AdhocRate)
                    .When(TablesLogic.tWork.WorkCost.CostType == WorkCostType.Material, (ExpressionDataString)Resources.Strings.CostType_Material)
                    .Else((ExpressionDataString)string.Empty).End.As("CostTypeName"),
                Anacle.DataFramework.Case.When(TablesLogic.tWork.WorkCost.CostType == WorkCostType.Technician, TablesLogic.tWork.WorkCost.Craft.ObjectName)
                    .When(TablesLogic.tWork.WorkCost.CostType == WorkCostType.Material & TablesLogic.tWork.WorkCost.StoreID != null & TablesLogic.tWork.WorkCost.StoreBinID != null, TablesLogic.tWork.WorkCost.Store.ObjectName + "(" + TablesLogic.tWork.WorkCost.StoreBin.ObjectName + ")")
                    .Else((ExpressionDataString)string.Empty).End.As("CraftStore"),
                TablesLogic.tWork.WorkCost.CostDescription,
                Anacle.DataFramework.Case.When(TablesLogic.tWork.WorkCost.UnitOfMeasureID != null, TablesLogic.tWork.WorkCost.UnitOfMeasure.ObjectName)
                    .When(TablesLogic.tWork.WorkCost.CostType == 0, (ExpressionDataString)Resources.Strings.UnitOfMeasureText_Hour)
                    .Else((ExpressionDataString)string.Empty).End.As("UnitOfMeasureText"),
                TablesLogic.tWork.WorkCost.EstimatedUnitCost,
                TablesLogic.tWork.WorkCost.EstimatedCostFactor,
                TablesLogic.tWork.WorkCost.EstimatedQuantity,
                Anacle.DataFramework.Case.When(TablesLogic.tWork.WorkCost.EstimatedCostTotal == null, TablesLogic.tWork.WorkCost.EstimatedUnitCost * TablesLogic.tWork.WorkCost.EstimatedCostFactor * TablesLogic.tWork.WorkCost.EstimatedQuantity)
                    .Else(TablesLogic.tWork.WorkCost.EstimatedCostTotal).End.As("EstimatedSubTotal"),
                TablesLogic.tWork.WorkCost.ActualUnitCost,
                TablesLogic.tWork.WorkCost.ActualCostFactor,
                TablesLogic.tWork.WorkCost.ActualQuantity,
                Anacle.DataFramework.Case.When(TablesLogic.tWork.WorkCost.ActualCostTotal == null, TablesLogic.tWork.WorkCost.ActualUnitCost * TablesLogic.tWork.WorkCost.ActualCostFactor * TablesLogic.tWork.WorkCost.ActualQuantity)
                    .Else(TablesLogic.tWork.WorkCost.ActualCostTotal).End.As("ActualSubTotal"),
                TablesLogic.tWork.WorkCost.ChargeOut,
                TablesLogic.tWork.WorkCost.DisplayOrder,
                TablesLogic.tWork.WorkCost.TaxAmount,
                TablesLogic.tWork.WorkCost.Store.ObjectName.As("StoreName"),
                TablesLogic.tWork.WorkCost.StoreBin.ObjectName.As("StoreBinName"),
                TablesLogic.tWork.WorkCost.UnitOfMeasure.ObjectName.As("UOM"),
                TablesLogic.tWork.WorkCost.ObjectID
                ).Where(
                TablesLogic.tWork.ObjectID == this.ObjectID
                & TablesLogic.tWork.WorkCost.IsDeleted == 0
                & TablesLogic.tWork.WorkCost.CostType != WorkCostType.Technician
                )
                .OrderBy(
                TablesLogic.tWork.WorkCost.DisplayOrder.Asc,
                Anacle.DataFramework.Case.When(TablesLogic.tWork.WorkCost.CostType == WorkCostType.Technician, (ExpressionDataString)Resources.Strings.CostType_Technician)
                    .When(TablesLogic.tWork.WorkCost.CostType == WorkCostType.FixedRate, (ExpressionDataString)Resources.Strings.CostType_FixedRate)
                    .When(TablesLogic.tWork.WorkCost.CostType == WorkCostType.AdhocRate, (ExpressionDataString)Resources.Strings.CostType_AdhocRate)
                    .When(TablesLogic.tWork.WorkCost.CostType == WorkCostType.Material, (ExpressionDataString)Resources.Strings.CostType_Material)
                    .Else((ExpressionDataString)string.Empty).End.Asc,
                Anacle.DataFramework.Case.When(TablesLogic.tWork.WorkCost.CostType == WorkCostType.Technician, TablesLogic.tWork.WorkCost.Craft.ObjectName)
                    .When(TablesLogic.tWork.WorkCost.CostType == WorkCostType.Material & TablesLogic.tWork.WorkCost.StoreID != null & TablesLogic.tWork.WorkCost.StoreBinID != null, TablesLogic.tWork.WorkCost.Store.ObjectName + "(" + TablesLogic.tWork.WorkCost.StoreBin.ObjectName + ")")
                    .Else((ExpressionDataString)string.Empty).End.Asc,
                TablesLogic.tWork.WorkCost.CostDescription.Asc
               );

            dtCost.TableName = "WorkCosts";
            dsTemp = dtCost.DataSet;
            dsTemp.Tables.Remove(dtCost);
            ds.Tables.Add(dtCost);

            //List<string> lstStr = new List<string>();
            string storeName = "";
            foreach (DataRow dr in dtCost.Rows)
            {
                if (!storeName.Contains(dr["StoreName"].ToString()))
                    storeName = storeName + (dr["StoreName"].ToString()) + ", ";
            }
            storeName = storeName.Remove(storeName.Length - 2);
            DataTable dtInfo = new DataTable("WorkInformation");
            dtInfo.Columns.Add("StoreName", typeof(string));
            DataRow r = dtInfo.NewRow();
            r["StoreName"] = storeName;
            dtInfo.Rows.Add(r);

            if (dtInfo.DataSet != null)
            {
                dsTemp = dtInfo.DataSet;
                dsTemp.Tables.Remove(dtInfo);
            }
            ds.Tables.Add(dtInfo);

            return ds;
        }

        public override DataSet DocumentTemplateDataSet
        {
            get
            {
                DataSet dsTemp = null;
                DataSet ds = new DataSet();
                ds.DataSetName = "WorkPrint";

                DataTable dtWork = TablesLogic.tWork.Select(
                    TablesLogic.tWork.ObjectNumber.As("WorkNumber"),
                    TablesLogic.tWork.CreatedUser,
                    TablesLogic.tWork.CreatedDateTime,
                    TablesLogic.tWork.ModifiedUser,
                    TablesLogic.tWork.ModifiedDateTime,
                    this.Location.ObjectName.As("UnitNo"),
                    ((ExpressionDataString)(this.Equipment == null ? string.Empty : this.Equipment.Path)).As("EquipmentPath"),
                    TablesLogic.tWork.Requestor.ObjectName.As("TenantName"),
                    TablesLogic.tWork.ReportedDateTime,
                    //TablesLogic.tWork.Department.ObjectName.As("DepartmentName"),
                    TablesLogic.tWork.TypeOfWork.ObjectName.As("TypeOfWork"),
                    TablesLogic.tWork.TypeOfService.ObjectName.As("TypeOfService"),
                    TablesLogic.tWork.TypeOfProblem.ObjectName.As("TypeOfProblem"),
                    //TablesLogic.tWork.Priority,
                    this.PriorityText.As("Priority"),
                    TablesLogic.tWork.WorkDescription,
                    TablesLogic.tWork.ArrivalDateTime,
                    TablesLogic.tWork.ActualStartDateTime,
                    TablesLogic.tWork.ActualEndDateTime,
                    TablesLogic.tWork.ResolutionDescription,
                    TablesLogic.tWork.AcknowledgementDateTime
                    ).Where(
                    TablesLogic.tWork.ObjectID == this.ObjectID
                    );

                dtWork.TableName = "WorkOrder";
                dsTemp = dtWork.DataSet;
                dsTemp.Tables.Remove(dtWork);
                ds.Tables.Add(dtWork);

                DataTable dtCost = TablesLogic.tWork.Select(
                    Anacle.DataFramework.Case.When(TablesLogic.tWork.WorkCost.CostType == WorkCostType.Technician, (ExpressionDataString)Resources.Strings.CostType_Technician)
                        .When(TablesLogic.tWork.WorkCost.CostType == WorkCostType.FixedRate, (ExpressionDataString)Resources.Strings.CostType_FixedRate)
                        .When(TablesLogic.tWork.WorkCost.CostType == WorkCostType.AdhocRate, (ExpressionDataString)Resources.Strings.CostType_AdhocRate)
                        .When(TablesLogic.tWork.WorkCost.CostType == WorkCostType.Material, (ExpressionDataString)Resources.Strings.CostType_Material)
                        .Else((ExpressionDataString)string.Empty).End.As("CostTypeName"),
                    Anacle.DataFramework.Case.When(TablesLogic.tWork.WorkCost.CostType == WorkCostType.Technician, TablesLogic.tWork.WorkCost.Craft.ObjectName)
                        .When(TablesLogic.tWork.WorkCost.CostType == WorkCostType.Material & TablesLogic.tWork.WorkCost.StoreID != null & TablesLogic.tWork.WorkCost.StoreBinID != null, TablesLogic.tWork.WorkCost.Store.ObjectName + "(" + TablesLogic.tWork.WorkCost.StoreBin.ObjectName + ")")
                        .Else((ExpressionDataString)string.Empty).End.As("CraftStore"),
                    TablesLogic.tWork.WorkCost.CostDescription,
                    Anacle.DataFramework.Case.When(TablesLogic.tWork.WorkCost.UnitOfMeasureID != null, TablesLogic.tWork.WorkCost.UnitOfMeasure.ObjectName)
                        .When(TablesLogic.tWork.WorkCost.CostType == 0, (ExpressionDataString)Resources.Strings.UnitOfMeasureText_Hour)
                        .Else((ExpressionDataString)string.Empty).End.As("UnitOfMeasureText"),
                    TablesLogic.tWork.WorkCost.EstimatedUnitCost,
                    TablesLogic.tWork.WorkCost.EstimatedCostFactor,
                    TablesLogic.tWork.WorkCost.EstimatedQuantity,
                    Anacle.DataFramework.Case.When(TablesLogic.tWork.WorkCost.EstimatedCostTotal == null, TablesLogic.tWork.WorkCost.EstimatedUnitCost * TablesLogic.tWork.WorkCost.EstimatedCostFactor * TablesLogic.tWork.WorkCost.EstimatedQuantity)
                        .Else(TablesLogic.tWork.WorkCost.EstimatedCostTotal).End.As("EstimatedSubTotal"),
                    TablesLogic.tWork.WorkCost.ActualUnitCost,
                    TablesLogic.tWork.WorkCost.ActualCostFactor,
                    TablesLogic.tWork.WorkCost.ActualQuantity,
                    Anacle.DataFramework.Case.When(TablesLogic.tWork.WorkCost.ActualCostTotal == null, TablesLogic.tWork.WorkCost.ActualUnitCost * TablesLogic.tWork.WorkCost.ActualCostFactor * TablesLogic.tWork.WorkCost.ActualQuantity)
                        .Else(TablesLogic.tWork.WorkCost.ActualCostTotal).End.As("ActualSubTotal"),
                    TablesLogic.tWork.WorkCost.ChargeOut,
                    TablesLogic.tWork.WorkCost.DisplayOrder,
                    TablesLogic.tWork.WorkCost.TaxAmount,
                    TablesLogic.tWork.WorkCost.Store.ObjectName.As("StoreName"),
                    TablesLogic.tWork.WorkCost.StoreBin.ObjectName.As("StoreBinName"),
                    TablesLogic.tWork.WorkCost.UnitOfMeasure.ObjectName.As("UOM")
                    ).Where(
                    TablesLogic.tWork.ObjectID == this.ObjectID
                    & TablesLogic.tWork.WorkCost.IsDeleted == 0
                    & TablesLogic.tWork.WorkCost.CostType != WorkCostType.Technician
                    )
                    .OrderBy(
                    TablesLogic.tWork.WorkCost.DisplayOrder.Asc,
                    Anacle.DataFramework.Case.When(TablesLogic.tWork.WorkCost.CostType == WorkCostType.Technician, (ExpressionDataString)Resources.Strings.CostType_Technician)
                        .When(TablesLogic.tWork.WorkCost.CostType == WorkCostType.FixedRate, (ExpressionDataString)Resources.Strings.CostType_FixedRate)
                        .When(TablesLogic.tWork.WorkCost.CostType == WorkCostType.AdhocRate, (ExpressionDataString)Resources.Strings.CostType_AdhocRate)
                        .When(TablesLogic.tWork.WorkCost.CostType == WorkCostType.Material, (ExpressionDataString)Resources.Strings.CostType_Material)
                        .Else((ExpressionDataString)string.Empty).End.Asc,
                    Anacle.DataFramework.Case.When(TablesLogic.tWork.WorkCost.CostType == WorkCostType.Technician, TablesLogic.tWork.WorkCost.Craft.ObjectName)
                        .When(TablesLogic.tWork.WorkCost.CostType == WorkCostType.Material & TablesLogic.tWork.WorkCost.StoreID != null & TablesLogic.tWork.WorkCost.StoreBinID != null, TablesLogic.tWork.WorkCost.Store.ObjectName + "(" + TablesLogic.tWork.WorkCost.StoreBin.ObjectName + ")")
                        .Else((ExpressionDataString)string.Empty).End.Asc,
                    TablesLogic.tWork.WorkCost.CostDescription.Asc
                   );

                dtCost.TableName = "WorkCosts";
                dsTemp = dtCost.DataSet;
                dsTemp.Tables.Remove(dtCost);
                ds.Tables.Add(dtCost);

                ////List<string> lstStr = new List<string>();
                //string storeName = "";
                //foreach (DataRow dr in dtCost.Rows)
                //{
                //    if (!storeName.Contains(dr["StoreName"].ToString()))
                //        storeName = storeName + (dr["StoreName"].ToString()) + ",";
                //}
                //storeName.Remove(storeName.Length - 1);
                //DataTable dtInfo = new DataTable();
                //dtInfo.TableName = "WorkInformation";
                //dtInfo.Columns.Add("StoreName", typeof(string));
                //DataRow r = dtInfo.NewRow();
                //r["StoreName"] = storeName;
                //dtInfo.Rows.Add(r);

                //if (dtInfo.DataSet != null)
                //{
                //    dsTemp = dtInfo.DataSet;
                //    dsTemp.Tables.Remove(dtInfo);
                //}
                //ds.Tables.Add(dtInfo);

                return ds;
            }
        }

        /// <summary>
        /// Returns the total charge out amount.
        /// </summary>
        public override decimal TaskAmount
        {
            get
            {
                decimal total = 0;
                foreach (OWorkCost workCost in this.WorkCost)
                {
                    total += workCost.ChargeOut != null ? (decimal)workCost.ChargeOut : 0;
                }
                return total;
            }
        }

        /// <summary>
        /// Store check out from Work.
        /// </summary>
        /// <param name="work">The work.</param>
        /// <param name="lstWorkCost">The list work cost.</param>
        public static OStoreCheckOut StoreCheckOutFromWork(OWork work, List<OWorkCost> lstWorkCost)
        {
            using (Connection c = new Connection())
            {
                //OStoreCheckOut findCheckOut = TablesLogic.tStoreCheckOut.Load(TablesLogic.tStoreCheckOut.WorkID == work.ObjectID);
                OStoreCheckOut returnCheckOut;
                //if (findCheckOut == null)
                //{
                OStoreCheckOut checkout = TablesLogic.tStoreCheckOut.Create();
                checkout.WorkID = work.ObjectID;
                foreach (OWorkCost wc in lstWorkCost)
                {
                    OStoreCheckOutItem newScoi = TablesLogic.tStoreCheckOutItem.Create();
                    newScoi.FromWorkCostID = wc.ObjectID;
                    newScoi.StoreBinID = wc.StoreBinID;
                    newScoi.CatalogueID = wc.CatalogueID;
                    newScoi.BaseQuantity = wc.EstimatedQuantity;
                    newScoi.ActualQuantity = wc.ActualQuantity;
                    newScoi.ActualUnitOfMeasureID = wc.UnitOfMeasureID;
                    newScoi.ComputeBaseQuantity();
                    newScoi.ComputeEstimatedUnitCost();
                    checkout.StoreCheckOutItems.Add(newScoi);
                }

                checkout.UserID = Workflow.CurrentUser.ObjectID;
                checkout.StoreID = lstWorkCost[0].StoreID;

                checkout.Save();
                checkout.TriggerWorkflowEvent("SaveAsDraft");
                returnCheckOut = checkout;
                //}
                //else
                //{
                //    DataList<OStoreCheckOutItem> dlStoreCheckOutItem = findCheckOut.StoreCheckOutItems;
                //    OStoreCheckOut checkout = TablesLogic.tStoreCheckOut.Create();
                //    checkout.WorkID = work.ObjectID;
                //    foreach (OWorkCost wc in lstWorkCost)
                //    {
                //        OStoreCheckOutItem scoi = dlStoreCheckOutItem.Find(lf => lf.FromWorkCostID == wc.ObjectID);
                //        if (scoi != null)
                //            throw new Exception(String.Format(Resources.Errors.Work_ItemAlreadyCheckOut, wc.ObjectName));
                //        else
                //        {
                //            OStoreCheckOutItem newScoi = TablesLogic.tStoreCheckOutItem.Create();
                //            newScoi.FromWorkCostID = wc.ObjectID;
                //            newScoi.StoreBinID = wc.StoreBinID;
                //            newScoi.CatalogueID = wc.CatalogueID;
                //            newScoi.BaseQuantity = wc.EstimatedQuantity;
                //            newScoi.ActualQuantity = wc.ActualQuantity;
                //            newScoi.ActualUnitOfMeasureID = wc.UnitOfMeasureID;
                //            checkout.StoreCheckOutItems.Add(newScoi);
                //        }
                //    }

                //    checkout.Save();
                //    checkout.TriggerWorkflowEvent("SaveAsDraft");
                //    returnCheckOut = checkout;
                //}

                c.Commit();
                return returnCheckOut;
            }
        }
    }
}