<%@ Page Language="C#" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.Common" %>
<script runat="server">

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        if (!IsPostBack)
        {
            
        }
    }

    protected void btnGenerate_Click(object sender, EventArgs e)
    {
        IEnumerable list = null;
        lblMessage.Text = "";
        if (ddlObject.SelectedValue == "0")
            list = TablesLogic.tLocation.LoadList(
            TablesLogic.tLocation.ParentID == null);
        else if (ddlObject.SelectedValue == "1")
            list = TablesLogic.tLocationType.LoadList(
            TablesLogic.tLocationType.ParentID == null);
        else if (ddlObject.SelectedValue == "2")
            list = TablesLogic.tEquipment.LoadList(
            TablesLogic.tEquipment.ParentID == null);
        else if (ddlObject.SelectedValue == "3")
            list = TablesLogic.tEquipmentType.LoadList(
            TablesLogic.tEquipmentType.ParentID == null);
        else if (ddlObject.SelectedValue == "4")
            list = TablesLogic.tAccount.LoadList(
            TablesLogic.tAccount.ParentID == null);
        else if (ddlObject.SelectedValue == "5")
            list = TablesLogic.tCode.LoadList(
            TablesLogic.tCode.ParentID == null);
        else if (ddlObject.SelectedValue == "6")
            list = TablesLogic.tCatalogue.LoadList(
            TablesLogic.tCatalogue.ParentID == null);
        else if (ddlObject.SelectedValue == "7")
            list = TablesLogic.tFixedRate.LoadList(
            TablesLogic.tFixedRate.ParentID == null);

        using (Connection c = new Connection())
        {
            foreach (PersistentObject p in list)
            {
                p.UpdateChildObjectHierarchy("", p);
            }
            lblMessage.Text = "Done!";
            c.Commit();
        }
    }

    protected void btnGenerateWorkflow_Click(object sender, EventArgs e)
    {
        if (ddlObjectForWorkflow.SelectedValue == "0")
        {
            List<ORequestForQuotation> rfqList = TablesLogic.tRequestForQuotation.LoadList(
                                                        (TablesLogic.tRequestForQuotation.CurrentActivity.WorkflowInstanceID == null |
                                                        TablesLogic.tRequestForQuotation.CurrentActivity.WorkflowInstanceID == "") 
                                                    );
            
            
            foreach (ORequestForQuotation rfq in rfqList)
            {
                if (rfq.CurrentActivity == null ||
                    rfq.CurrentActivity.WorkflowInstanceID == null || rfq.CurrentActivity.WorkflowInstanceID == "")
                {
                    try
                    {
                        using (Connection c = new Connection())
                        {
                            if (rfq.CurrentActivity.CurrentStateName != "Close" && rfq.CurrentActivity.CurrentStateName != "Cancelled")
                            {
                                Workflow.CreateWorkflowForPersistentObject(rfq);
                                rfq.Save();
                                WindowsWorkflowEngine.Engine.SetState(rfq.CurrentActivity.WorkflowInstanceID, rfq.CurrentActivity.CurrentStateName);

                            }
                            c.Commit();
                        }
                    }
                    catch (Exception ex)
                    {
                        Response.Write(rfq.ObjectNumber + ": " + ex.Message + "<br/>");
                    }
                }
            }
        }
        else if (ddlObjectForWorkflow.SelectedValue == "1")
        {
            List<OPurchaseOrder> poList = TablesLogic.tPurchaseOrder.LoadList(
                                                        TablesLogic.tPurchaseOrder.CurrentActivity.WorkflowInstanceID == null |
                                                        TablesLogic.tPurchaseOrder.CurrentActivity.WorkflowInstanceID == "");
            foreach (OPurchaseOrder po in poList)
            {
                if (po.CurrentActivity == null ||
                    po.CurrentActivity.WorkflowInstanceID == null || po.CurrentActivity.WorkflowInstanceID == "")
                {
                    try
                    {
                        using (Connection c = new Connection())
                        {
                            if (po.CurrentActivity.CurrentStateName != "Close" && po.CurrentActivity.CurrentStateName != "Cancelled")
                            {
                                Workflow.CreateWorkflowForPersistentObject(po);
                                po.Save();
                                WindowsWorkflowEngine.Engine.SetState(po.CurrentActivity.WorkflowInstanceID, po.CurrentActivity.CurrentStateName);
                            }
                            c.Commit();
                        }
                    }
                    catch (Exception ex)
                    {
                        Response.Write(po.ObjectNumber + ": " + ex.Message + "<br/>");
                    }
                }
            }
        }
        else if (ddlObjectForWorkflow.SelectedValue == "2")
        {
            List<OPurchaseInvoice> poList = TablesLogic.tPurchaseInvoice.LoadList(
                                                        (TablesLogic.tPurchaseInvoice.CurrentActivity.WorkflowInstanceID == null |
                                                        TablesLogic.tPurchaseInvoice.CurrentActivity.WorkflowInstanceID == ""),
                                                        TablesLogic.tPurchaseInvoice.PurchaseOrder.ObjectNumber.Asc, 
                                                        TablesLogic.tPurchaseInvoice.DateOfInvoice.Asc);
            foreach (OPurchaseInvoice invoice in poList)
            {
                if (invoice.CurrentActivity == null ||
                    invoice.CurrentActivity.WorkflowInstanceID == null || invoice.CurrentActivity.WorkflowInstanceID == "")
                {
                    try
                    {
                        using (Connection c = new Connection())
                        {
                            if (invoice.CurrentActivity.CurrentStateName != "Close" && invoice.CurrentActivity.CurrentStateName != "Cancelled")
                            {
                                Workflow.CreateWorkflowForPersistentObject(invoice);
                                invoice.Save();
                                WindowsWorkflowEngine.Engine.SetState(invoice.CurrentActivity.WorkflowInstanceID, invoice.CurrentActivity.CurrentStateName);
                            }
                            c.Commit();
                        }
                    }
                    catch (Exception ex)
                    {
                        Response.Write(invoice.ObjectNumber + ": " + ex.Message + "<br/>");
                    }
                }
            }
        }
        else if (ddlObjectForWorkflow.SelectedValue == "3")
        {
            List<OContract> poList = TablesLogic.tContract.LoadList(
                                                        (TablesLogic.tContract.CurrentActivity.WorkflowInstanceID == null |
                                                        TablesLogic.tContract.CurrentActivity.WorkflowInstanceID == ""));
            foreach (OContract contract in poList)
            {
                if (contract.CurrentActivity == null ||
                    contract.CurrentActivity.WorkflowInstanceID == null || contract.CurrentActivity.WorkflowInstanceID == "")
                {
                    try
                    {
                        using (Connection c = new Connection())
                        {
                            if (contract.CurrentActivity == null ||
                                (contract.CurrentActivity.CurrentStateName != "Close" && contract.CurrentActivity.CurrentStateName != "Cancelled"))
                            {
                                Workflow.CreateWorkflowForPersistentObject(contract);
                                contract.Save();
                                WindowsWorkflowEngine.Engine.SetState(contract.CurrentActivity.WorkflowInstanceID, contract.CurrentActivity.ObjectName);
                            }
                            c.Commit();
                        }
                    }
                    catch (Exception ex)
                    {
                        Response.Write(contract.ObjectNumber + ": " + ex.Message + "<br/>");
                    }
                }
            }
        }
        else if (ddlObjectForWorkflow.SelectedValue == "4")
        {
            List<OContract> poList = TablesLogic.tContract.LoadList(
                                                        (TablesLogic.tContract.CurrentActivity.WorkflowInstanceID == null |
                                                        TablesLogic.tContract.CurrentActivity.WorkflowInstanceID == ""));
            foreach (OContract contract in poList)
            {
                if (contract.CurrentActivity == null ||
                    contract.CurrentActivity.WorkflowInstanceID == null || contract.CurrentActivity.WorkflowInstanceID == "")
                {
                    try
                    {
                        using (Connection c = new Connection())
                        {
                            if (contract.CurrentActivity == null ||
                                (contract.CurrentActivity.CurrentStateName != "Close" && contract.CurrentActivity.CurrentStateName != "Cancelled"))
                            {
                                Workflow.CreateWorkflowForPersistentObject(contract);
                                contract.Save();
                                if (contract.ContractEndDate > DateTime.Now)
                                    WindowsWorkflowEngine.Engine.SetState(contract.CurrentActivity.WorkflowInstanceID, "InProgress");
                                else
                                {
                                    WindowsWorkflowEngine.Engine.SetState(contract.CurrentActivity.WorkflowInstanceID, "Expired");
                                }
                            }
                            c.Commit();
                        }
                    }
                    catch (Exception ex)
                    {
                        Response.Write(contract.ObjectNumber + ": " + ex.Message + "<br/>");
                    }
                }
            }
        }
    }

    protected void btnTransferBudget_Click(object sender, EventArgs e)
    {
        List<OPurchaseInvoice> invoiceList =
            TablesLogic.tPurchaseInvoice.LoadList(
            TablesLogic.tPurchaseInvoice.MatchType == 1 &
            TablesLogic.tPurchaseInvoice.IsApproved == 1 &
            TablesLogic.tPurchaseInvoice.InvoiceType == 0,
            TablesLogic.tPurchaseInvoice.PurchaseOrder.ObjectNumber.Asc, 
            TablesLogic.tPurchaseInvoice.DateOfInvoice.Asc);
        foreach (OPurchaseInvoice invoice in invoiceList)
        {
            try
            {
                using (Connection c = new Connection())
                {
                    if (invoice.PurchaseBudgets.Count == 0)
                    {
                        List<OPurchaseBudget> purchaseBudgets =
                        OPurchaseBudget.TransferPartialPurchaseBudgets(
                        invoice.PurchaseOrder.PurchaseBudgets, null, invoice.TotalAmount);
                        invoice.PurchaseBudgets.AddRange(purchaseBudgets);
                        invoice.Save();
                    }

                    List<Guid> ids = new List<Guid>();
                    foreach (OPurchaseBudget pb in invoice.PurchaseBudgets)
                        ids.Add(pb.ObjectID.Value);

                    if ((int)TablesLogic.tBudgetTransactionLog.Select(
                        TablesLogic.tBudgetTransactionLog.ObjectID.Count())
                        .Where(
                        TablesLogic.tBudgetTransactionLog.PurchaseBudgetID.In(ids)) == 0)
                    {
                        List<OBudgetTransactionLog> newTransactions = new List<OBudgetTransactionLog>();
                        List<OBudgetTransactionLog> modifiedTransactions = new List<OBudgetTransactionLog>();
                        OPurchaseBudget.CreateBudgetTransactionLogs(invoice.PurchaseBudgets, BudgetTransactionType.PurchaseInvoiceApproved,
                            newTransactions, modifiedTransactions);
                        foreach (OBudgetTransactionLog log in newTransactions)
                            log.Save();
                        foreach (OBudgetTransactionLog log in modifiedTransactions)
                            log.Save();
                    }
                    c.Commit();
                }
            }
            catch (Exception ex)
            {
                Response.Write(invoice.ObjectNumber + ": " + ex.Message + "<br/>");
                //break;
            }
        }
    }

    protected void btnUpdateInvoiceStatus_Click(object sender, EventArgs e)
    {
        DataSet ds = Connection.ExecuteQuery("#Database", "Select * from UpdatePurchaseInvoice$");
        if (ds.Tables.Count > 0)
        {
            if (ds.Tables[0].Rows.Count > 0)
            {
                string number = "";
                string n = "";
                foreach (DataRow row in ds.Tables[0].Rows)
                {
                    try
                    {
                        using (Connection c = new Connection())
                        {
                            string invoiceNumber = row["Vendor Invoice Number"].ToString();
                            n = invoiceNumber;
                            string LocationPath = row["Location Path"].ToString();
                            OLocation loc = TablesLogic.tLocation.Load(TablesLogic.tLocation.ObjectName == LocationPath.Split('>')[2].Trim());
                            if (loc != null)
                            {
                                OPurchaseInvoice invoice = TablesLogic.tPurchaseInvoice.Load(
                                                            TablesLogic.tPurchaseInvoice.ObjectNumber == invoiceNumber &
                                                            TablesLogic.tPurchaseInvoice.LocationID == loc.ObjectID);

                                if (invoice != null)
                                {
                                    if (invoice.CurrentActivity.CurrentStateName != "Draft")
                                        continue;
                                    if (invoice.CurrentActivity.ApprovalProcessID == null)
                                    {
                                        OApprovalProcess ap = TablesLogic.tApprovalProcess.Load(
                                                              ((ExpressionDataString)loc.HierarchyPath).Like(TablesLogic.tApprovalProcess.Location.HierarchyPath + "%") &
                                                                TablesLogic.tApprovalProcess.ModeOfForwarding == 0 &
                                                                TablesLogic.tApprovalProcess.ObjectTypeName == "OPurchaseInvoice");
                                        if (ap == null)
                                        {
                                            number += "There is no approval process for the PurchaseInvoice in Location: " + LocationPath + ";<br/>";
                                            break;
                                        }
                                        else
                                        {
                                            invoice.CurrentActivity.ApprovalProcessID = ap.ObjectID;
                                        }
                                    }
                                    if (row["Actual Status"].ToString() == "Approve" ||
                                        row["Actual Status"].ToString() == "Approved" ||
                                        invoice.ObjectNumber == "2008446351")
                                        invoice.TriggerWorkflowEvent("SubmitForApproval");
                                    else if (row["Actual Status"].ToString() == "Cancel" ||
                                            row["Actual Status"].ToString() == "Cancelled" ||
                                            invoice.ObjectNumber == "2008446352")
                                        invoice.TriggerWorkflowEvent("Cancel");
                                    else
                                    {
                                        number += "Invoice Number " + invoiceNumber + " status is not valid;<br/>";
                                    }
                                }
                                else
                                    number += "Invoice Number " + invoiceNumber + " is not existing;<br/>";
                                invoice.Save();
                            }
                            else
                                number += LocationPath + " does not exist";
                            c.Commit();
                        }
                    }
                    catch (Exception ex)
                    {
                        number += ex.ToString() + ";<br/>";
                    }


                }
                lblMessage.Text = number != "" ? number : "Successful!";
            }
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    
        <asp:Label runat="server" ID="lblMessage" ForeColor="Red"></asp:Label>
        <br />
        <asp:DropDownList runat="server" ID="ddlObject" Caption="Object">
                <asp:ListItem Value="0">OLocation</asp:ListItem>
                <asp:ListItem Value="1">OLocationType</asp:ListItem>
                <asp:ListItem Value="2">OEquipment</asp:ListItem>
                <asp:ListItem Value="3">OEquipmentType</asp:ListItem>
                <asp:ListItem Value="4">OAccount</asp:ListItem>
                <asp:ListItem Value="5">OCode</asp:ListItem>
                <asp:ListItem Value="6">OCatalogue</asp:ListItem>
                <asp:ListItem Value="7">OFixedRate</asp:ListItem>

        </asp:DropDownList>
        <asp:Button runat="server" ID="btnGenerate" Text="Generate" OnClick="btnGenerate_Click" />
        <br />
        <br />
        <ui:UISeparator runat="server" Caption="Generate Workflow" />
        <br />
        <asp:DropDownList runat="server" ID="ddlObjectForWorkflow" Caption="Object">
                <asp:ListItem Value="0">ORequestForQuotation</asp:ListItem>
                <asp:ListItem Value="1">OPurchaseOrder</asp:ListItem>
                <asp:ListItem Value="2">OPurchaseInvoice</asp:ListItem>
                <asp:ListItem Value="3">OContract</asp:ListItem>
                <asp:ListItem Value="4">OContract-China</asp:ListItem>
        </asp:DropDownList>
        <asp:Button runat="server" ID="btnGenerateWorkflow" Text="Generate Workflow" OnClick="btnGenerateWorkflow_Click" />
        <br />
        <br />
        <ui:UISeparator ID="UISeparator1" runat="server" Caption="Transfer Purchase Budget for Invoice" />
        <br />
        <asp:Button runat="server" ID="btnTransferBudget" Text="Transfer Budget" OnClick="btnTransferBudget_Click" />    
        <br />
        <br />
        <ui:UISeparator ID="UISeparator2" runat="server" Caption="Update Purchase Invoice Status" Font-Bold="true" />
        
        <br />
        <br />
        <asp:Button runat="server" ID="btnUpdateInvoiceStatus" Text="Update" OnClick="btnUpdateInvoiceStatus_Click" />    
        <br />
    </div>
    </form>
</body>
</html>
