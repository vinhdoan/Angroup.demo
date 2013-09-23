//========================================================================
// $Product: Anacle Enterprise Asset Management
// $Version: 6.0
//
// Copyright 2006 (c) Anacle Systems Pte. Ltd.
// All rights reserved.
//========================================================================
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using Anacle.DataFramework;

namespace LogicLayer
{
    /// <summary>
    /// Summary description for OAccount
    /// </summary>
    public partial class TAccount : LogicLayerSchema<OAccount>
    {
        public SchemaInt AppliesToAllPurchaseTypes;
        public SchemaGuid AccountTypeID;
        public SchemaString ReallocationGroupName;
        public SchemaGuid SubCategoryID;

        public TCode PurchaseTypes { get { return ManyToMany<TCode>("AccountPurchaseType", "AccountID", "PurchaseTypeID"); } }

        public TAccountType AccountType { get { return OneToOne<TAccountType>("AccountTypeID"); } }

        public TAccount SubCategory { get { return OneToOne<TAccount>("SubCategoryID"); } }
    }

    public abstract partial class OAccount : LogicLayerPersistentObject, IHierarchy, IAuditTrailEnabled
    {
        public abstract int? AppliesToAllPurchaseTypes { get; set; }

        public abstract Guid? AccountTypeID { get; set; }

        public abstract string ReallocationGroupName { get; set; }

        public abstract Guid? SubCategoryID { get; set; }

        public abstract DataList<OCode> PurchaseTypes { get; set; }

        public abstract OAccountType AccountType { get; set; }

        public abstract OAccount SubCategory { get; set; }

        public static Hashtable GetInheritedGroupNames(List<Guid?> accountIds)
        {
            Hashtable groupName = new Hashtable();

            DataTable dt = TablesLogic.tAccount.Select(
                TablesLogic.tAccount.ObjectID,
            TablesLogic.tAccount.ReallocationGroupName,
            TablesLogic.tAccount.Parent.ReallocationGroupName,
            TablesLogic.tAccount.Parent.Parent.ReallocationGroupName,
            TablesLogic.tAccount.Parent.Parent.Parent.ReallocationGroupName,
            TablesLogic.tAccount.Parent.Parent.Parent.Parent.ReallocationGroupName,
            TablesLogic.tAccount.Parent.Parent.Parent.Parent.Parent.ReallocationGroupName,
            TablesLogic.tAccount.Parent.Parent.Parent.Parent.Parent.Parent.ReallocationGroupName,
            TablesLogic.tAccount.Parent.Parent.Parent.Parent.Parent.Parent.Parent.ReallocationGroupName,
            TablesLogic.tAccount.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.ReallocationGroupName,
            TablesLogic.tAccount.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.ReallocationGroupName,
            TablesLogic.tAccount.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.ReallocationGroupName)
            .Where(
                TablesLogic.tAccount.ObjectID.In(accountIds));
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                for (int j = 1; j < dt.Columns.Count; j++)
                {
                    if (dt.Rows[i][j].ToString() != null && dt.Rows[i][j].ToString() != "")
                    {
                        groupName[dt.Rows[i][0]] = dt.Rows[i][j].ToString();
                        break;
                    }
                }
                if (groupName[dt.Rows[i][0]] == null)
                    groupName[dt.Rows[i][0]] = "";
            }

            return groupName;
        }

        //public static string GetInheritedGroupName(Guid? accountId)
        //{
        //    string groupName = "";
        //        DataTable dt = TablesLogic.tAccount.Select(
        //        TablesLogic.tAccount.ReallocationGroupName,
        //        TablesLogic.tAccount.Parent.ReallocationGroupName,
        //        TablesLogic.tAccount.Parent.Parent.ReallocationGroupName,
        //        TablesLogic.tAccount.Parent.Parent.Parent.ReallocationGroupName,
        //        TablesLogic.tAccount.Parent.Parent.Parent.Parent.ReallocationGroupName,
        //        TablesLogic.tAccount.Parent.Parent.Parent.Parent.Parent.ReallocationGroupName,
        //        TablesLogic.tAccount.Parent.Parent.Parent.Parent.Parent.Parent.ReallocationGroupName,
        //        TablesLogic.tAccount.Parent.Parent.Parent.Parent.Parent.Parent.Parent.ReallocationGroupName,
        //        TablesLogic.tAccount.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.ReallocationGroupName,
        //        TablesLogic.tAccount.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.ReallocationGroupName,
        //        TablesLogic.tAccount.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.ReallocationGroupName)
        //        .Where(
        //            TablesLogic.tAccount.ObjectID == accountId);
        //        for (int i = 0; i < dt.Rows.Count; i++)
        //        {
        //            if (dt.Rows[i][0].ToString() != null && dt.Rows[i][0].ToString() != "")
        //            {
        //                groupName = dt.Rows[i][0].ToString();
        //            }
        //        }

        //    return groupName;
        //}
        public static DataTable WJDetails(Guid AccountID, Guid BudgetID, DateTime startDate, DateTime endDate)
        {
            endDate = endDate.AddDays(1);
            SqlParameter p1 = new SqlParameter("@accountID", AccountID);
            SqlParameter p2 = new SqlParameter("@BudgetID", BudgetID);
            SqlParameter p3 = new SqlParameter("@startDate", startDate);
            SqlParameter p4 = new SqlParameter("@endDate", endDate);

            string wj = @"select RFQNumber,RFQID,PONumber,InvoiceNumber,Description, DateOfExpenditure,sum(Amount) as Amount,CreatedUser,AccountID
from
(select rfq.ObjectNumber as 'RFQNumber',rfq.ObjectID as 'RFQID'
,po.ObjectNumber as 'PONumber',pIn.ObjectNumber as 'InvoiceNumber',
rfq.Description,
btl.DateOfExpenditure,max(btl.TransactionAmount) as Amount,rfq.CreatedUser,pb.AccountID
from
PurchaseBudget pb
left join RequestForQuotation rfq on rfq.ObjectID = pb.RequestForQuotationID
left join BudgetTransactionLog btl on btl.PurchaseBudgetID = pb.ObjectID
left join RequestForQuotationItem rfqItem on rfq.ObjectID = rfqItem.RequestForQuotationID
left join PurchaseOrderItem poItem on poItem.RequestForQuotationItemID = rfqItem.ObjectID and poItem.IsDeleted=0
left join PurchaseOrder po on po.ObjectID = poItem.PurchaseOrderID and po.IsDeleted=0
left join PurchaseInvoice pIn on pIn.PurchaseOrderID = po.ObjectID and pIn.IsDeleted = 0
where pb.AccountID = @accountID and btl.BudgetID = @BudgetID and btl.DateOfExpenditure >= @startDate and btl.DateOfExpenditure < @endDate
and pb.IsDeleted = 0
and rfq.ObjectID is not null and rfq.IsDeleted = 0 and rfqItem.IsDeleted = 0
group by rfq.ObjectNumber,btl.DateOfExpenditure,po.ObjectNumber,pIn.ObjectNumber,rfq.Description,rfq.CreatedUser,pb.AccountID,rfq.ObjectID

union

select rfq.ObjectNumber as 'RFQNumber',rfq.ObjectID as 'RFQID'
,po.ObjectNumber as 'PONumber',pIn.ObjectNumber as 'InvoiceNumber',
rfq.Description,
btl.DateOfExpenditure,max(btl.transactionAmount),rfq.CreatedUser,pb.AccountID
from PurchaseBudget pb
left join PurchaseOrder po on po.ObjectID = pb.PurchaseOrderID
left join BudgetTransactionLog btl on btl.PurchaseBudgetID = pb.ObjectID
left join PurchaseOrderItem poItem on po.ObjectID = poItem.PurchaseOrderID
left join RequestForQuotationItem rfqItem on poItem.RequestForQuotationItemID = rfqItem.ObjectID
left join RequestForQuotation rfq on rfq.ObjectID = rfqItem.RequestForQuotationID
left join PurchaseInvoice pIn on pIn.PurchaseOrderID = po.ObjectID and pIn.IsDeleted = 0
where
pb.AccountID = @accountID  and btl.BudgetID = @BudgetID and btl.DateOfExpenditure >= @startDate and btl.DateOfExpenditure < @endDate
and rfq.ObjectID is not null and
pb.IsDeleted = 0
and po.ObjectID is not null and po.IsDeleted = 0 and poItem.IsDeleted = 0
and rfq.IsDeleted = 0 and rfqItem.IsDeleted = 0
group by rfq.ObjectNumber,btl.DateOfExpenditure,po.ObjectNumber,pIn.ObjectNumber,rfq.Description,rfq.CreatedUser,pb.AccountID,rfq.ObjectID

union
select rfq.ObjectNumber as 'RFQNumber',rfq.ObjectID as 'RFQID'
,po.ObjectNumber as 'PONumber',pIn.ObjectNumber as 'InvoiceNumber',
rfq.Description,
btl.DateOfExpenditure,max(btl.transactionAmount),rfq.CreatedUser,pb.AccountID
from PurchaseBudget pb
left join PurchaseInvoice pIn on pIn.ObjectID = pb.PurchaseInvoiceID
left join PurchaseOrder po on po.ObjectID = pIn.PurchaseOrderID
left join BudgetTransactionLog btl on btl.PurchaseBudgetID = pb.ObjectID
left join PurchaseOrderItem poItem on po.ObjectID = poItem.PurchaseOrderID
left join RequestForQuotationItem rfqItem on poItem.RequestForQuotationItemID = rfqItem.ObjectID
left join RequestForQuotation rfq on rfq.ObjectID = rfqItem.RequestForQuotationID
where
pb.AccountID = @accountID  and btl.BudgetID = @BudgetID and btl.DateOfExpenditure >= @startDate and btl.DateOfExpenditure < @endDate
and rfq.ObjectID is not null and pIn.ObjectID is not null and
pb.IsDeleted = 0
and po.ObjectID is not null and po.IsDeleted = 0 and poItem.IsDeleted = 0
and rfq.IsDeleted = 0 and rfqItem.IsDeleted = 0 and pIn.IsDeleted = 0
group by rfq.ObjectNumber,btl.DateOfExpenditure,po.ObjectNumber,pIn.ObjectNumber,rfq.Description,rfq.CreatedUser,pb.AccountID,rfq.ObjectID

) as tbl
group by RFQNumber,PONumber,InvoiceNumber,Description, DateOfExpenditure,CreatedUser,AccountID,RFQID";

            DataTable dtWJDetails = Connection.ExecuteQuery("#database", wj, p1, p2, p3, p4).Tables[0];

            //get list of approvers
            SqlParameter accID = new SqlParameter("@accountID", AccountID);
            SqlParameter bgID = new SqlParameter("@BudgetID", BudgetID);
            SqlParameter sDate = new SqlParameter("@startDate", startDate);
            SqlParameter eDate = new SqlParameter("@endDate", endDate);
            DataTable dtApprovalList = Connection.ExecuteQuery("#database", @"select rfq.ObjectID as 'rfqID',ah.CreatedUser as 'ApprovedBy',ah.PreviousApprovalLevel
from PurchaseBudget pb
left join RequestForQuotation rfq on pb.RequestForQuotationID = rfq.ObjectID
left join BudgetTransactionLog btl on pb.ObjectID = btl.PurchaseBudgetID
left join ActivityHistory ah on rfq.ObjectID = ah.AttachedObjectID
where pb.AccountID = @accountID and btl.BudgetID = @BudgetID and btl.DateOfExpenditure >= @startDate and btl.DateOfExpenditure < @endDate
and pb.IsDeleted = 0
and ah.ModifiedDateTime > (select top 1 ModifiedDateTime from ActivityHistory where AttachedObjectID = rfq.ObjectID and TriggeringEventName='SubmitForApproval' order by ModifiedDateTime desc)
and ah.TriggeringEventName = 'Approve' and rfq.IsDeleted = 0
group by rfq.ObjectID,ah.CreatedUser,ah.PreviousApprovalLevel
order by ah.PreviousApprovalLevel", accID, bgID, sDate, eDate).Tables[0];

            Hashtable htApprovers = new Hashtable();
            foreach (DataRow row in dtApprovalList.Rows)
            {
                if (htApprovers[row["rfqID"]] == null)
                    htApprovers.Add(row["rfqID"], row["ApprovedBy"]);
                else
                    htApprovers[row["rfqID"]] = Convert.ToString(htApprovers[row["rfqID"]]) + "," + row["ApprovedBy"];
            }
            dtWJDetails.Columns.Add("ApprovedBy");
            //add approver list to wjdetails
            foreach (DataRow row in dtWJDetails.Rows)
            {
                row["ApprovedBy"] = htApprovers[row["RFQID"]];
                row.AcceptChanges();
            }
            dtWJDetails.AcceptChanges();
            return dtWJDetails;
        }

        public static DataTable DirectInvoice(Guid AccountID, Guid BudgetID, DateTime startDate, DateTime endDate)
        {
            endDate = endDate.AddDays(1);
            SqlParameter p1 = new SqlParameter("@accountID", AccountID);
            SqlParameter p2 = new SqlParameter("@BudgetID", BudgetID);
            SqlParameter p3 = new SqlParameter("@startDate", startDate);
            SqlParameter p4 = new SqlParameter("@endDate", endDate);

            DataTable dtInvoice = Connection.ExecuteQuery("#database", @"select pIn.ObjectNumber as 'InvoiceNumber',pIn.ObjectID as 'InvoiceID',
pIn.Description,
btl.DateOfExpenditure,sum(btl.transactionAmount) as Amount,pb.AccountID,pIn.CreatedUser
from PurchaseBudget pb
left join PurchaseInvoice pIn on pIn.ObjectID = pb.PurchaseInvoiceID
left join BudgetTransactionLog btl on btl.PurchaseBudgetID = pb.ObjectID
where
pb.AccountID = @accountID  and btl.BudgetID = @BudgetID and btl.DateOfExpenditure >= @startDate and btl.DateOfExpenditure < @endDate
and
pb.IsDeleted = 0 and pIn.IsDeleted = 0 and pIn.PurchaseOrderID is null
group by btl.DateOfExpenditure,pIn.ObjectNumber,pb.AccountID,pIn.ObjectID,pIn.Description,pIn.CreatedUser", p1, p2, p3, p4).Tables[0];

            //get list of approvers
            SqlParameter accID = new SqlParameter("@accountID", AccountID);
            SqlParameter bgID = new SqlParameter("@BudgetID", BudgetID);
            SqlParameter sDate = new SqlParameter("@startDate", startDate);
            SqlParameter eDate = new SqlParameter("@endDate", endDate);
            DataTable dtapprovers = Connection.ExecuteQuery("#database", @"
select pIn.ObjectID as 'invoiceID',ah.CreatedUser as 'ApprovedBy',ah.PreviousApprovalLevel
from PurchaseBudget pb
left join PurchaseInvoice pIn on pIn.ObjectID = pb.PurchaseInvoiceID
left join BudgetTransactionLog btl on btl.PurchaseBudgetID = pb.ObjectID
left join ActivityHistory ah on pIn.ObjectID = ah.AttachedObjectID
where
pb.AccountID = @accountID  and btl.BudgetID = @BudgetID and btl.DateOfExpenditure >= @startDate and btl.DateOfExpenditure < @endDate
and pb.IsDeleted = 0 and pIn.IsDeleted = 0 and pIn.PurchaseOrderID is null
and ah.ModifiedDateTime > (select top 1 ModifiedDateTime from ActivityHistory where AttachedObjectID = pIn.ObjectID and TriggeringEventName='SubmitForApproval' order by ModifiedDateTime desc)
and ah.TriggeringEventName = 'Approve'
group by pIn.ObjectID,ah.CreatedUser,ah.PreviousApprovalLevel
order by ah.PreviousApprovalLevel", accID, bgID, sDate, eDate).Tables[0];

            Hashtable htApprovers = new Hashtable();
            foreach (DataRow row in dtapprovers.Rows)
            {
                if (htApprovers[row["invoiceID"]] == null)
                    htApprovers.Add(row["invoiceID"], row["ApprovedBy"]);
                else
                    htApprovers[row["invoiceID"]] = Convert.ToString(htApprovers[row["invoiceID"]]) + "," + row["ApprovedBy"];
            }
            dtInvoice.Columns.Add("ApprovedBy");
            //add approver list to wjdetails
            foreach (DataRow row in dtInvoice.Rows)
            {
                row["ApprovedBy"] = htApprovers[row["InvoiceID"]];
                row.AcceptChanges();
            }
            dtInvoice.AcceptChanges();
            return dtInvoice;
        }
    }
}