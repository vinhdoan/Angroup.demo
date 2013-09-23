//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Collections.Generic;

using Anacle.DataFramework;

namespace LogicLayer
{
    /// <summary>
    /// Summary description for OApprovalProcess
    /// </summary>
    public partial class TApprovalProcess : LogicLayerSchema<OApprovalProcess>
    {
        public SchemaInt AppliesToAllTransactionTypes;
        public SchemaInt BudgetReallocationType;

        public TCode TransactionTypes { get { return ManyToMany<TCode>("ApprovalProcessTransactionTypes", "ApprovalProcessID", "TransactionTypeID"); } }

        public TAccount Accounts { get { return ManyToMany<TAccount>("ApprovalProcessAccounts", "ApprovalProcessID", "AccountID"); } }
    }

    public abstract partial class OApprovalProcess : LogicLayerPersistentObject, IAuditTrailEnabled, ICloneable
    {
        public abstract int? AppliesToAllTransactionTypes { get; set; }

        public abstract int? BudgetReallocationType { get; set; }

        public abstract DataList<OCode> TransactionTypes { get; set; }

        public abstract DataList<OAccount> Accounts { get; set; }

        /// <summary>
        /// Returns a string indicating a summarized description of
        /// this object that is to appear in the audit trail.
        /// </summary>
        public override string AuditObjectDescription
        {
            get
            {
                return this.Description;
            }
        }

        // 2010.07.30
        // Kim Foong
        // Added this to filter the approval process by another further condition.
        //
        /// <summary>
        /// Gets a list of approval process details object by the
        /// specified approval process code and applicable to the
        /// persistent object after filtering those whose
        /// FLEE conditions return true.
        /// </summary>
        /// <param name="logicLayerPersistentObject"></param>
        /// <returns></returns>
        public static List<OApprovalProcess> GetApprovalProcesses(
            LogicLayerPersistentObject logicLayerPersistentObject)
        {
            List<OApprovalProcess> approvalProcesses = GetApprovalProcessesRegardlessOfFLEECondition(logicLayerPersistentObject);

            ExpressionEvaluator e = new ExpressionEvaluator();
            e["obj"] = logicLayerPersistentObject;
            for (int i = approvalProcesses.Count - 1; i >= 0; i--)
            {
                if (approvalProcesses[i].FLEECondition == null || approvalProcesses[i].FLEECondition.Trim() == "")
                    continue;

                if (e.CompileAndEvaluate<bool>(approvalProcesses[i].FLEECondition) != true)
                    approvalProcesses.RemoveAt(i);
            }
            return approvalProcesses;
        }

        /// <summary>
        /// Gets a list of approval process details object by the
        /// specified approval process code and applicable to the
        /// persistent object.
        /// </summary>
        /// <param name="logicLayerPersistentObject"></param>
        /// <returns></returns>
        public static List<OApprovalProcess> GetApprovalProcessesRegardlessOfFLEECondition(
            LogicLayerPersistentObject logicLayerPersistentObject)
        {
            List<OLocation> taskLocations = logicLayerPersistentObject.TaskLocations;
            List<OEquipment> taskEquipments = logicLayerPersistentObject.TaskEquipments;

            // Construct the condition to look for the approval process
            // detail that covers all locations/equipment of the task.
            //
            TApprovalProcess d1 = new TApprovalProcess();

            ExpressionCondition conditionLocation = Query.True;
            if (taskLocations != null)
                foreach (OLocation taskLocation in taskLocations)
                    if (taskLocation != null)
                        conditionLocation &= TablesLogic.tApprovalProcess.ObjectID.In(d1.Select(d1.ObjectID).Where(taskLocation.HierarchyPath.Like(d1.Location.HierarchyPath + "%")));

            ExpressionCondition conditionEquipment = Query.True;
            if (taskEquipments != null)
                foreach (OEquipment taskEquipment in taskEquipments)
                    if (taskEquipment != null)
                        conditionEquipment &= TablesLogic.tApprovalProcess.ObjectID.In(d1.Select(d1.ObjectID).Where(taskEquipment.HierarchyPath.Like(d1.Equipment.HierarchyPath + "%")));

            // query and returns the result.
            //
            Guid? transactionTypeGroupId = null;
            Guid? transactionTypeId = null;

            if (logicLayerPersistentObject is OPurchaseRequest)
            {
                return TablesLogic.tApprovalProcess.LoadList(
                    TablesLogic.tApprovalProcess.ObjectTypeName == logicLayerPersistentObject.GetType().BaseType.Name &
                    (TablesLogic.tApprovalProcess.AppliesToAllTransactionTypes == 1 |
                    TablesLogic.tApprovalProcess.TransactionTypes.ObjectID == ((OPurchaseRequest)logicLayerPersistentObject).PurchaseTypeID) &
                    conditionLocation &
                    conditionEquipment,
                    TablesLogic.tApprovalProcess.Location.HierarchyPath.Length().Desc,
                    TablesLogic.tApprovalProcess.Equipment.HierarchyPath.Length().Desc
                    );
            }
            else if (logicLayerPersistentObject is ORequestForQuotation)
            {
                ORequestForQuotation rfq = (ORequestForQuotation)logicLayerPersistentObject;

                List<OApprovalProcess> rfqApproval = TablesLogic.tApprovalProcess.LoadList(
                    TablesLogic.tApprovalProcess.ObjectTypeName == logicLayerPersistentObject.GetType().BaseType.Name &
                    (TablesLogic.tApprovalProcess.AppliesToAllTransactionTypes == 1 |
                    TablesLogic.tApprovalProcess.TransactionTypes.ObjectID == ((ORequestForQuotation)logicLayerPersistentObject).PurchaseTypeID) &
                    conditionLocation &
                    conditionEquipment,
                    TablesLogic.tApprovalProcess.Location.HierarchyPath.Length().Desc,
                    TablesLogic.tApprovalProcess.Equipment.HierarchyPath.Length().Desc
                    );

                // If there is not budget reallocation
                // return the respective approval process.
                //
                if (rfq.RFQBudgetReallocationFromPeriods.Count == 0)
                    return rfqApproval;

                // Find budget reallocation approval process.
                // when there is budget reallocation within the WJ.
                //
                //List<OApprovalProcess> reallocationApproval = TablesLogic.tApprovalProcess.LoadList(
                //    TablesLogic.tApprovalProcess.ObjectTypeName == "OBudgetReallocation" &
                //    conditionLocation &
                //    conditionEquipment,
                //    TablesLogic.tApprovalProcess.Location.HierarchyPath.Length().Desc,
                //    TablesLogic.tApprovalProcess.Equipment.HierarchyPath.Length().Desc
                //    );

                //2012 12 15 ptb
                //Auto pick up the budget reallocation approval process (between/within/opex/capex)
                List<OApprovalProcess> reallocationApproval = new List<OApprovalProcess>();
                if (rfq.RFQBudgetReallocationFromPeriods.Count != 0 && rfq.RFQBudgetReallocationToPeriods.Count != 0)
                {
                    OAccount fromAcc = rfq.RFQBudgetReallocationFromPeriods[0].RFQBudgetReallocationFroms[0].Account;
                    OAccount toAcc = rfq.RFQBudgetReallocationToPeriods[0].RFQBudgetReallocationTos[0].Account;
                    //int i = fromAcc.SubCategoryID == toAcc.SubCategoryID ? 1 : 0;
                    //List<OApprovalProcess> lstFroms =
                    //    TablesLogic.tApprovalProcess.LoadList(TablesLogic.tApprovalProcess.ObjectTypeName == "OBudgetReallocation" &
                    //    fromAcc.HierarchyPath.Like(TablesLogic.tApprovalProcess.Accounts.HierarchyPath + "%") &
                    //    //br.BudgetReallocationTos[0].Account.HierarchyPath.Like(TablesLogic.tApprovalProcess.Accounts.HierarchyPath + "%") &
                    //    TablesLogic.tApprovalProcess.BudgetReallocationType == i &
                    //    conditionLocation &
                    //    conditionEquipment,
                    //    TablesLogic.tApprovalProcess.Location.HierarchyPath.Length().Desc,
                    //    TablesLogic.tApprovalProcess.Equipment.HierarchyPath.Length().Desc);

                    //List<OApprovalProcess> lstTos =
                    //    TablesLogic.tApprovalProcess.LoadList(TablesLogic.tApprovalProcess.ObjectTypeName == "OBudgetReallocation" &
                    //    //br.BudgetReallocationFroms[0].Account.HierarchyPath.Like(TablesLogic.tApprovalProcess.Accounts.HierarchyPath + "%") &
                    //    toAcc.HierarchyPath.Like(TablesLogic.tApprovalProcess.Accounts.HierarchyPath + "%") &
                    //    TablesLogic.tApprovalProcess.BudgetReallocationType == i &
                    //    conditionLocation &
                    //    conditionEquipment,
                    //    TablesLogic.tApprovalProcess.Location.HierarchyPath.Length().Desc,
                    //    TablesLogic.tApprovalProcess.Equipment.HierarchyPath.Length().Desc);

                    //foreach (OApprovalProcess ap in lstFroms)
                    //{
                    //    OApprovalProcess findAP = lstTos.Find(lf => lf.ObjectID == ap.ObjectID);
                    //    if (findAP != null)
                    //        reallocationApproval.Add(ap);
                    //}

                    reallocationApproval = GetApprovalProcessForBudgetReallocation(logicLayerPersistentObject, fromAcc, toAcc);

                    if (reallocationApproval.Count == 0)
                        return new List<OApprovalProcess>();
                }

                //end

                int maxLevel = -1;
                OApprovalProcess selectedProcess = null;

                if (rfqApproval != null)
                {
                    foreach (OApprovalProcess process in rfqApproval)
                    {
                        int level = process.MinimalApprovalLevel(rfq.TotalPurchaseBudgateAmount);
                        if (level > maxLevel)
                        {
                            maxLevel = level;
                            selectedProcess = process;
                        }
                    }
                }

                if (rfqApproval != null)
                    foreach (OApprovalProcess process in reallocationApproval)
                    {
                        int level = process.MinimalApprovalLevel(rfq.TotalPurchaseBudgateAmount);
                        if (level > maxLevel)
                        {
                            maxLevel = level;
                            selectedProcess = process;
                        }
                    }

                List<OApprovalProcess> result = new List<OApprovalProcess>();

                if (selectedProcess != null)
                    result.Add(selectedProcess);

                return result;
            }

            //
            //
            else if (logicLayerPersistentObject is OPurchaseOrder)
            {
                return TablesLogic.tApprovalProcess.LoadList(
                    TablesLogic.tApprovalProcess.ObjectTypeName == logicLayerPersistentObject.GetType().BaseType.Name &
                    (TablesLogic.tApprovalProcess.AppliesToAllTransactionTypes == 1 |
                    TablesLogic.tApprovalProcess.TransactionTypes.ObjectID == ((OPurchaseOrder)logicLayerPersistentObject).PurchaseTypeID) &
                    conditionLocation &
                    conditionEquipment,
                    TablesLogic.tApprovalProcess.Location.HierarchyPath.Length().Desc,
                    TablesLogic.tApprovalProcess.Equipment.HierarchyPath.Length().Desc
                    );
            }
            else if (logicLayerPersistentObject is OPurchaseInvoice)
            {
                return TablesLogic.tApprovalProcess.LoadList(
                    TablesLogic.tApprovalProcess.ObjectTypeName == logicLayerPersistentObject.GetType().BaseType.Name &
                    (TablesLogic.tApprovalProcess.AppliesToAllTransactionTypes == 1 |
                    TablesLogic.tApprovalProcess.TransactionTypes.ObjectID == ((OPurchaseInvoice)logicLayerPersistentObject).PaymentTypeID) &
                    conditionLocation &
                    conditionEquipment,
                    TablesLogic.tApprovalProcess.Location.HierarchyPath.Length().Desc,
                    TablesLogic.tApprovalProcess.Equipment.HierarchyPath.Length().Desc
                    );
            }
            //2011 12 13 ptb
            //BudgetReallocation customization
            else if (logicLayerPersistentObject is OBudgetReallocation)
            {
                OBudgetReallocation br = ((OBudgetReallocation)logicLayerPersistentObject);
                if (br.BudgetReallocationFroms.Count != 0 && br.BudgetReallocationTos.Count != 0)
                {
                    OAccount fromAcc = br.BudgetReallocationFroms[0].Account;
                    OAccount toAcc = br.BudgetReallocationTos[0].Account;
                    //int i = br.BudgetReallocationFroms[0].Account.SubCategoryID == br.BudgetReallocationTos[0].Account.SubCategoryID ? 1 : 0;
                    //List<OApprovalProcess> lstFroms =
                    //    TablesLogic.tApprovalProcess.LoadList(TablesLogic.tApprovalProcess.ObjectTypeName == logicLayerPersistentObject.GetType().BaseType.Name &
                    //    br.BudgetReallocationFroms[0].Account.HierarchyPath.Like(TablesLogic.tApprovalProcess.Accounts.HierarchyPath + "%") &
                    //    //br.BudgetReallocationTos[0].Account.HierarchyPath.Like(TablesLogic.tApprovalProcess.Accounts.HierarchyPath + "%") &
                    //    TablesLogic.tApprovalProcess.BudgetReallocationType == i &
                    //    conditionLocation &
                    //    conditionEquipment,
                    //    TablesLogic.tApprovalProcess.Location.HierarchyPath.Length().Desc,
                    //    TablesLogic.tApprovalProcess.Equipment.HierarchyPath.Length().Desc);

                    //List<OApprovalProcess> lstTos =
                    //    TablesLogic.tApprovalProcess.LoadList(TablesLogic.tApprovalProcess.ObjectTypeName == logicLayerPersistentObject.GetType().BaseType.Name &
                    //    //br.BudgetReallocationFroms[0].Account.HierarchyPath.Like(TablesLogic.tApprovalProcess.Accounts.HierarchyPath + "%") &
                    //    br.BudgetReallocationTos[0].Account.HierarchyPath.Like(TablesLogic.tApprovalProcess.Accounts.HierarchyPath + "%") &
                    //    TablesLogic.tApprovalProcess.BudgetReallocationType == i &
                    //    conditionLocation &
                    //    conditionEquipment,
                    //    TablesLogic.tApprovalProcess.Location.HierarchyPath.Length().Desc,
                    //    TablesLogic.tApprovalProcess.Equipment.HierarchyPath.Length().Desc);

                    //List<OApprovalProcess> returnLst = new List<OApprovalProcess>();
                    //foreach (OApprovalProcess ap in lstFroms)
                    //{
                    //    OApprovalProcess findAP = lstTos.Find(lf => lf.ObjectID == ap.ObjectID);
                    //    if (findAP != null)
                    //        returnLst.Add(ap);
                    //}

                    List<OApprovalProcess> returnLst = GetApprovalProcessForBudgetReallocation(logicLayerPersistentObject, fromAcc, toAcc);
                    return returnLst;
                }
                else
                    return new List<OApprovalProcess>();
                //return TablesLogic.tApprovalProcess.LoadList(
                //    TablesLogic.tApprovalProcess.ObjectTypeName == logicLayerPersistentObject.GetType().BaseType.Name &
                //    TablesLogic.tApprovalProcess.BudgetReallocationType == ((OBudgetReallocation)logicLayerPersistentObject).BudgetReallocationType &
                //    conditionLocation &
                //    conditionEquipment,
                //    TablesLogic.tApprovalProcess.Location.HierarchyPath.Length().Desc,
                //    TablesLogic.tApprovalProcess.Equipment.HierarchyPath.Length().Desc
                //    );
            }

            return TablesLogic.tApprovalProcess.LoadList(
                TablesLogic.tApprovalProcess.ObjectTypeName == logicLayerPersistentObject.GetType().BaseType.Name &
                conditionLocation &
                conditionEquipment,
                TablesLogic.tApprovalProcess.Location.HierarchyPath.Length().Desc,
                TablesLogic.tApprovalProcess.Equipment.HierarchyPath.Length().Desc
                );
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="amount"></param>
        /// <returns></returns>
        public int MinimalApprovalLevel(decimal amount)
        {
            if (this.ApprovalProcessLimits != null)
                foreach (OApprovalProcessLimit limit in this.ApprovalProcessLimits)
                {
                    if (limit.ApprovalLimit >= amount)
                        return limit.ApprovalLevel.Value;
                }

            return -1;
        }

        /// <summary>
        /// Validates that if the non-default timings are
        /// used, that all process timings are in
        /// increasing order, with no gaps in between.
        /// </summary>
        /// <returns></returns>
        public bool ValidateNonDefaultApprovalProcessLimits()
        {
            bool test1 = true;

            if (this.UseDefaultLimits == 0)
            {
                List<OApprovalProcessLimit> limits = new List<OApprovalProcessLimit>();

                foreach (OApprovalProcessLimit limit in this.ApprovalProcessLimits)
                    limits.Add(limit);
                limits.Sort("ApprovalLevel ASC");

                decimal previousLimit = -1;
                for (int i = 0; i < limits.Count - 1; i++)
                {
                    if (limits[i].ApprovalLimit != null)
                    {
                        if (limits[i].ApprovalLimit < previousLimit)
                            test1 = false;
                        /*
                        if (limits[i].ApprovalLimit != null &&
                            limits[i + 1].ApprovalLimit != null &&
                            limits[i].ApprovalLimit > limits[i + 1].ApprovalLimit)
                            test1 = false;
                        //return false;

                        if (limits[i].ApprovalLimit == null &&
                            limits[i + 1].ApprovalLimit != null)
                            test1 = false;
                         * */

                        previousLimit = limits[i].ApprovalLimit.Value;
                    }
                }
            }
            //OApprovalProcessLimit test2=new TApprovalProcessLimit;
            //if (this.ApprovalProcessLimits != null)
            //{
            //    foreach (OApprovalProcessLimit test2 in this.ApprovalProcessLimits)
            //    {
            //        if (test2 != null)
            //        {
            //            if (test2.ApprovalLimit.Value < 0)
            //            {
            //                test1 = false;
            //            }
            //        }

            //    }
            //}

            return test1;
            //return true;
        }

        /// <summary>
        /// Gets the approval process for budget reallocation (included within WJ reallocation).
        /// </summary>
        /// <param name="fromAcc">From acc.</param>
        /// <param name="toAcc">To acc.</param>
        /// <param name="conditionLocation">The condition location.</param>
        /// <param name="conditionEquipment">The condition equipment.</param>
        /// <returns></returns>
        public static List<OApprovalProcess> GetApprovalProcessForBudgetReallocation(LogicLayerPersistentObject logicLayerPersistentObject, OAccount fromAcc, OAccount toAcc)
        {
            List<OLocation> taskLocations = logicLayerPersistentObject.TaskLocations;
            List<OEquipment> taskEquipments = logicLayerPersistentObject.TaskEquipments;

            // Construct the condition to look for the approval process
            // detail that covers all locations/equipment of the task.
            //
            TApprovalProcess d1 = new TApprovalProcess();

            ExpressionCondition conditionLocation = Query.True;
            if (taskLocations != null)
                foreach (OLocation taskLocation in taskLocations)
                    if (taskLocation != null)
                        conditionLocation &= TablesLogic.tApprovalProcess.ObjectID.In(d1.Select(d1.ObjectID).Where(taskLocation.HierarchyPath.Like(d1.Location.HierarchyPath + "%")));

            ExpressionCondition conditionEquipment = Query.True;
            if (taskEquipments != null)
                foreach (OEquipment taskEquipment in taskEquipments)
                    if (taskEquipment != null)
                        conditionEquipment &= TablesLogic.tApprovalProcess.ObjectID.In(d1.Select(d1.ObjectID).Where(taskEquipment.HierarchyPath.Like(d1.Equipment.HierarchyPath + "%")));

            List<OApprovalProcess> reallocationApproval = new List<OApprovalProcess>();
            int i = fromAcc.SubCategoryID == toAcc.SubCategoryID ? 1 : 0;
            List<OApprovalProcess> lstFroms =
                TablesLogic.tApprovalProcess.LoadList(TablesLogic.tApprovalProcess.ObjectTypeName == "OBudgetReallocation" &
                fromAcc.HierarchyPath.Like(TablesLogic.tApprovalProcess.Accounts.HierarchyPath + "%") &
                //br.BudgetReallocationTos[0].Account.HierarchyPath.Like(TablesLogic.tApprovalProcess.Accounts.HierarchyPath + "%") &
                TablesLogic.tApprovalProcess.BudgetReallocationType == i &
                conditionLocation &
                conditionEquipment,
                TablesLogic.tApprovalProcess.Location.HierarchyPath.Length().Desc,
                TablesLogic.tApprovalProcess.Equipment.HierarchyPath.Length().Desc);

            List<OApprovalProcess> lstTos =
                TablesLogic.tApprovalProcess.LoadList(TablesLogic.tApprovalProcess.ObjectTypeName == "OBudgetReallocation" &
                //br.BudgetReallocationFroms[0].Account.HierarchyPath.Like(TablesLogic.tApprovalProcess.Accounts.HierarchyPath + "%") &
                toAcc.HierarchyPath.Like(TablesLogic.tApprovalProcess.Accounts.HierarchyPath + "%") &
                TablesLogic.tApprovalProcess.BudgetReallocationType == i &
                conditionLocation &
                conditionEquipment,
                TablesLogic.tApprovalProcess.Location.HierarchyPath.Length().Desc,
                TablesLogic.tApprovalProcess.Equipment.HierarchyPath.Length().Desc);

            foreach (OApprovalProcess ap in lstFroms)
            {
                OApprovalProcess findAP = lstTos.Find(lf => lf.ObjectID == ap.ObjectID);
                if (findAP != null)
                    reallocationApproval.Add(ap);
            }

            return reallocationApproval;
        }

        /// <summary>
        /// Creates a new object that is a copy of the current instance.
        /// </summary>
        /// <returns>
        /// A new object that is a copy of this instance.
        /// </returns>
        public object Clone()
        {
            OApprovalProcess newObject = TablesLogic.tApprovalProcess.Create();
            newObject.ShallowCopy(this);

            return newObject;
        }
    }
}