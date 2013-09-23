<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.Odbc" %>
<%@ Import Namespace="System.Data.Common" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Reflection" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Import Namespace="Anacle.WorkflowFramework" %>
<%@ Import Namespace="Anacle.DataFramework" %>

<script runat="server">
    protected void pagePanel1_Load(object sender, EventArgs e)
    {
        gv_Result.PageSize = 100;
        gv_Result.Grid.AutoGenerateColumns = true;
        gv_Result.Grid.RowStyle.HorizontalAlign = HorizontalAlign.NotSet;
        gv_Result.Grid.HeaderStyle.HorizontalAlign = HorizontalAlign.Left;
        gv_Result.Grid.HeaderStyle.BackColor = System.Drawing.Color.LightGray;
        //if (AppSession.User.UserBase.LoginName.ToLower() != "sa")
        //{
        //    Response.Redirect("~/appbottom.aspx");
        //}
    }

    protected void pagePanel1_Click(object sender, string commandName)
    {
        if (commandName == "GenerateSQL")
        {
            string
                text =
                DatabaseSetup.GenerateSetupSQL(typeof(TablesLogic)) + "\n\n" +
                DatabaseSetup.GenerateSetupSQL(typeof(TablesWorkflow)) + "\n\n" +
                DatabaseSetup.GenerateSetupSQL(typeof(TablesAuditTrail));
            Window.Download(text, "database.sql", "text/html");
        }

    }

    /// <summary>
    /// Updates the hierarchy path
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonUpdateHierarchy_Click(object sender, EventArgs e)
    {
        if (dropObject.SelectedIndex > 0)
        {
            FieldInfo fi = typeof(TablesLogic).GetField(dropObject.SelectedItem.Text,
                BindingFlags.Static | BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic);
            SchemaBase s = fi.GetValue(null) as SchemaBase;

            IEnumerable list = s.LoadObjects(s.ParentID == null);
            using (Connection c = new Connection())
            {
                foreach (PersistentObject p in list)
                {
                    p.UpdateChildObjectHierarchy("", p);
                }
                pagePanel1.Message = "Hierarchy path for '" + dropObject.SelectedItem.Text + "' updated successfully.";
                c.Commit();
            }
        }
    }

    /// <summary>
    /// Update the workflow by plucking out the original workflow, and attaching
    /// the latest one in.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonUpdateWorkflow_Click(object sender, EventArgs e)
    {
        if (this.dropWorkflowObject.SelectedIndex > 0)
        {
            string errors = "";
            int count = 0;
            FieldInfo fi = typeof(TablesLogic).GetField(dropWorkflowObject.SelectedItem.Text,
                BindingFlags.Static | BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic);
            SchemaBase s = fi.GetValue(null) as SchemaBase;

            ExpressionDataString w =
                s.GetJoinTable("CurrentActivity").GetColumn("WorkflowInstanceID") as ExpressionDataString;

            ExpressionDataString w1 =
                s.GetJoinTable("CurrentActivity").GetColumn("ObjectName") as ExpressionDataString;

            IEnumerable list = null;
            if (radioMigrateMode.SelectedIndex == 0)
                list = s.LoadObjects(Query.True, false, s.GetColumn("ContractStartDate").Asc);
            else
                //list = s.LoadObjects((w == null | w == "") & (w1 == "PendingApproval" | w1 == "Draft" | w1 == "RejectedforRework" | w1 == "Awarded")); // RFQ
                list = s.LoadObjects((w == null | w == "") & (w1 == "Draft" | w1 == "Approved")); // Invoice
            //list = s.LoadObjects((w == null | w == "") & (w1 == "PendingReceipt")); // Purchase Order
            //list = s.LoadObjects((w == null | w == "") & (w1 == "PendingClosure" | w1 == "PendingExecution" | w1 == "PendingAssignment" | w1 == "PendingMaterial" | w1 == "Draft")); // Work

            foreach (LogicLayerPersistentObject p in list)
            {
                try
                {
                    if (String.IsNullOrEmpty(textWorkflowObjectNumber.Text) || p.ObjectNumber == textWorkflowObjectNumber.Text)
                    {
                        // Disconnect the current Workflow instance
                        // from the object.
                        //
                        p.CurrentActivity.WorkflowInstanceID = null;
                        using (Connection c = new Connection())
                        {
                            Workflow.CreateWorkflowForPersistentObject(p);
                            p.Touch();
                            p.Save();
                            //WindowsWorkflowEngine.Engine.SetState(
                            //    p.CurrentActivity.WorkflowInstanceID,
                            //    p.CurrentActivity.CurrentStateName);
                            WindowsWorkflowEngine.Engine.SetState(p, p.CurrentActivity.CurrentStateName, p.CurrentActivity.WorkflowInstanceID, p.CurrentActivity.CurrentStateName);
                            c.Commit();
                            count++;
                        }
                    }
                }
                catch (Exception ex)
                {
                    errors += "&nbsp;&nbsp;&nbsp;&nbsp;" + p.ObjectNumber + ": " + ex.Message + "<br/>";
                }
            }

            if (errors == "")
                pagePanel1.Message = "All " + count + " workflow(s) migrated successfully.";
            else
                pagePanel1.Message = "" + count + " workflow(s) migrated successfully. The following has failed: <br/>" + errors;
        }
    }

    /// <summary>
    /// Loads up and saves all object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonSaveObject_Click(object sender, EventArgs e)
    {
        if (dropSaveObject.SelectedIndex > 0)
        {
            FieldInfo fi = typeof(TablesLogic).GetField(dropSaveObject.SelectedItem.Text,
                BindingFlags.Static | BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic);
            SchemaBase s = fi.GetValue(null) as SchemaBase;

            IEnumerable list = null;

            if (s is TContract)
                list = s.LoadObjects(Query.True, false, s.GetColumn("ContractStartDate").Asc);
            else
                list = s.LoadObjects(Query.True);
            using (Connection c = new Connection())
            {
                int count = 0;
                foreach (PersistentObject p in list)
                {
                    p.Touch();
                    p.Save();
                    count++;
                }
                pagePanel1.Message = "Updated " + count + " '" + dropSaveObject.SelectedItem.Text + "' object(s) successfully.";
                c.Commit();
            }
        }
    }

    /// <summary>
    /// Updates the object's status.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonUpdateObjectStatus_Click(object sender, EventArgs e)
    {
        if (this.dropUpdateStatusForObject.SelectedIndex > 0)
        {
            string errors = "";
            FieldInfo fi = typeof(TablesLogic).GetField(dropUpdateStatusForObject.SelectedItem.Text,
                BindingFlags.Static | BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic);
            SchemaBase s = fi.GetValue(null) as SchemaBase;

            IEnumerable objects = s.LoadObjects(s.ObjectNumber == textUpdateStatusForObjectNumber.Text);

            int count = 0;
            foreach (PersistentObject o in objects)
            {
                LogicLayerPersistentObject po = o as LogicLayerPersistentObject;
                if (po != null && po.CurrentActivity != null)
                /*&& po.CurrentActivity.WorkflowInstanceID != null)*/
                {
                    //WindowsWorkflowEngine.Engine.SetState(po.CurrentActivity.WorkflowInstanceID, textUpdateState.Text);
                    WindowsWorkflowEngine.Engine.SetState(po, po.CurrentActivity.CurrentStateName, po.CurrentActivity.WorkflowInstanceID, textUpdateState.Text);
                    count++;
                    pagePanel1.Message = "Updated the state successfully.";
                }
            }
            if (count == 0)
            {
                pagePanel1.Message = "Unable to update the status because the object does not exist, or it does not have a workflow attached.";
            }
        }
    }

    protected void btnSelect_Click(object sender, EventArgs e)
    {
        tb_Query.ErrorMessage = pagePanel1.Message = "";
        try
        {

            string sql = "";
            sql = tb_Query.Text;

            if (sql.Trim() != "")
            {
                DataSet ResultSet = new DataSet();
                DataTable Result = new DataTable();

                ResultSet = Connection.ExecuteQuery("#database", sql, null);
                Result = ResultSet.Tables[0];

                if (!Result.Columns.Contains("ObjectID"))
                    Result.Columns.Add("ObjectID");

                this.gv_Result.Visible = true;
                labelMessage.Text = "(" + Result.Rows.Count + " row(s) affected)";
                this.gv_Result.DataKeyNames[0] = Result.Columns[0].ColumnName;
                this.gv_Result.DataSource = Result;
                this.gv_Result.DataBind();
            }
        }
        catch (Exception ex)
        {
            //tb_Query.ErrorMessage = pagePanel1.Message = ex.Message;
            this.gv_Result.Visible = false;
            labelMessage.Text = "(0 row(s) affected)" + "<br /><br />" + "<div><font style='color: red'>" + ex.Message + "</font></div>";
        }

    }

    protected void btnUpdateInsert_Click(object sender, EventArgs e)
    {
        tb_Query.ErrorMessage = pagePanel1.Message = "";
        int AffectedRow = 0;
        try
        {
            string sql = "";
            sql = tb_Query.Text;
            if (sql.Trim() != "")
            {
                using (Connection c = new Connection())
                {
                    AffectedRow = Connection.ExecuteNonQuery("#database", sql, null);
                    //Result.Columns.Add("Affected Row");
                    //Result.Columns.Add("ObjectID");
                    //Result.Rows.Add(new object[] { AffectedRow, " Row(s) affected." });
                    c.Commit();
                }

                if (AffectedRow < 0)
                    AffectedRow = 0;

                this.gv_Result.Visible = false;
                labelMessage.Text = "(" + AffectedRow + " row(s) affected)";
            }

        }
        catch (Exception ex)
        {
            //tb_Query.ErrorMessage = pagePanel1.Message = ex.Message;
            this.gv_Result.Visible = false;
            labelMessage.Text = "(" + AffectedRow + " row(s) affected)" + "<br /><br />" + "<div><font style='color: red'>" + ex.Message + "</font></div>";
        }

    }

    public static string RenderPrimitive(object x)
    {
        if (x == null)
            return ("null");
        else if (x == DBNull.Value)
            return ("null");
        else if (x is int)
            return (x.ToString());
        else if (x is double)
            return (x.ToString());
        else if (x is decimal)
            return (x.ToString());
        else if (x is DateTime)
            return ("{ts '" + ((DateTime)x).ToString("yyyy-MM-dd HH:mm:ss.fff") + "'}");
        else if (x is string)
            return ("N'" + x.ToString().Replace("'", "''") + "'");
        else if (x is Guid)
            return ("'" + ((Guid)x).ToString() + "'");
        else if (x is byte[])
        {
            StringBuilder sb = new StringBuilder(((byte[])x).Length * 2);
            sb.Append("0x");
            foreach (byte b in (byte[])x)
                sb.Append(b.ToString("X2"));
            return sb.ToString();
        }
        else
            return x.ToString();
    }

    protected void btnTransferPurchaseBudget_Click(object sender, EventArgs e)
    {
        List<OPurchaseInvoice> invoiceList =
            TablesLogic.tPurchaseInvoice.LoadList(
            TablesLogic.tPurchaseInvoice.MatchType == 1 &
            TablesLogic.tPurchaseInvoice.IsApproved == 1 &
            TablesLogic.tPurchaseInvoice.InvoiceType == 0 &
            TablesLogic.tPurchaseInvoice.CurrentActivity.ObjectName != "Draft",
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
                //Response.Write(invoice.ObjectNumber + ": " + ex.Message + "<br/>");
                pagePanel1.Message = invoice.ObjectNumber + ": " + ex.Message + "<br/>";
                //break;
            }
        }
    }

    protected void btnCreateBudgetSummary_Click(object sender, EventArgs e)
    {
        List<ORequestForQuotation> rfqs = TablesLogic.tRequestForQuotation.LoadList
            (TablesLogic.tRequestForQuotation.CurrentActivity.ObjectName == "Close",
            TablesLogic.tRequestForQuotation.CreatedDateTime.Asc);

        foreach (ORequestForQuotation rfq in rfqs)
        {
            try
            {
                using (Connection c = new Connection())
                {
                    if (rfq.PurchaseBudgetSummaries.Count == 0)
                    {
                        List<OBudgetTransactionLog> newTransactions = new List<OBudgetTransactionLog>();
                        List<OBudgetTransactionLog> modifiedTransactions = new List<OBudgetTransactionLog>();
                        OPurchaseBudget.CreateBudgetTransactionLogs(rfq.PurchaseBudgets, BudgetTransactionType.PurchasePendingApproval, newTransactions, modifiedTransactions);

                        // Creates the budget summaries and stamp them with the current
                        // budget available balance.
                        //
                        List<OPurchaseBudgetSummary> budgetSummaries =
                            OPurchaseBudgetSummary.CreateBudgetSummariesForSubmission(newTransactions);

                        foreach (OBudgetTransactionLog transaction in newTransactions)
                            transaction.TransactionType = BudgetTransactionType.PurchaseApproved;

                        rfq.PurchaseBudgetSummaries.AddRange(budgetSummaries);
                        OPurchaseBudgetSummary.UpdateBudgetSummariesAfterApproval(newTransactions, rfq.PurchaseBudgetSummaries);

                        rfq.Save();
                        c.Commit();
                    }
                }
            }
            catch (Exception ex)
            {
                //Response.Write(invoice.ObjectNumber + ": " + ex.Message + "<br/>");
                pagePanel1.Message = rfq.ObjectNumber + ": " + ex.Message + "<br/>";
                //break;
            }

        }

    }

    protected void btnCreateBudgetSummaryTwentyAnson_Click(object sender, EventArgs e)
    {
        List<ORequestForQuotation> rfqs = TablesLogic.tRequestForQuotation.LoadList
            (TablesLogic.tRequestForQuotation.Location.ObjectName == "Twenty Anson",
            TablesLogic.tRequestForQuotation.CreatedDateTime.Asc);

        foreach (ORequestForQuotation rfq in rfqs)
        {
            try
            {
                using (Connection c = new Connection())
                {
                    if (rfq.PurchaseBudgetSummaries.Count == 0)
                    {
                        List<OBudgetTransactionLog> newTransactions = new List<OBudgetTransactionLog>();
                        List<OBudgetTransactionLog> modifiedTransactions = new List<OBudgetTransactionLog>();
                        //OPurchaseBudget.CreateBudgetTransactionLogs(rfq.PurchaseBudgets, BudgetTransactionType.PurchasePendingApproval, newTransactions, modifiedTransactions);

                        // Creates the budget summaries and stamp them with the current
                        // budget available balance.
                        //
                        List<OPurchaseBudgetSummary> budgetSummaries =
                            OPurchaseBudgetSummary.CreateBudgetSummariesForSubmission(newTransactions);

                        foreach (OBudgetTransactionLog transaction in newTransactions)
                            transaction.TransactionType = BudgetTransactionType.PurchaseApproved;

                        rfq.PurchaseBudgetSummaries.AddRange(budgetSummaries);
                        OPurchaseBudgetSummary.UpdateBudgetSummariesAfterApproval(newTransactions, rfq.PurchaseBudgetSummaries);

                        rfq.Save();
                        c.Commit();
                    }
                }
            }
            catch (Exception ex)
            {
                //Response.Write(invoice.ObjectNumber + ": " + ex.Message + "<br/>");
                pagePanel1.Message = rfq.ObjectNumber + ": " + ex.Message + "<br/>";
                //break;
            }

        }

    }
    
    protected void btnGeneratePOfromWJ_Click(object sender, EventArgs e)
    {
        string[] WJnumbers = txtGeneratePOfromWJ.Text.Split(';');
        for (int i = 0; i < WJnumbers.Length; i++)
            WJnumbers[i] = WJnumbers[i].Trim();
        List<ORequestForQuotation> listWJs = TablesLogic.tRequestForQuotation.LoadList(TablesLogic.tRequestForQuotation.ObjectNumber.In(WJnumbers));
        if (listWJs == null || listWJs.Count == 0)
        {
            pagePanel1.Message = "No WJs found.";
            return;
        }

        string obj = "";
        string message = "";

        string replacetxt = txtReplacePOfromWJ.Text.Trim();
        try
        {
            foreach (ORequestForQuotation rfq in listWJs)
            {
                obj = rfq.ObjectNumber;
                List<Guid> rfqItemIds = new List<Guid>();
                foreach (ORequestForQuotationItem rfqi in rfq.RequestForQuotationItems)
                {
                    rfqi.OrderQuantity = rfqi.QuantityRequired;
                    if (rfqi.AwardedVendorID == null)
                        rfqItemIds.Add((Guid)rfqi.ObjectID);
                }

                if (rfq.RequestForQuotationVendors.Count == 1)
                {
                    Guid vendorId = (Guid)rfq.RequestForQuotationVendors[0].VendorID;
                    rfq.AwardLineItemsToVendor(vendorId, rfqItemIds);
                    rfq.UpdateBudgetAmount();
                    using (Connection c = new Connection())
                    {
                        rfq.Save();
                        c.Commit();
                    }
                }

                rfq.SubmitForApprovalForCapitaland();
                //rfq.ApproveForCapitaland();
                if (rfq.CurrentActivity.CurrentStateName == "Draft")
                {
                    WindowsWorkflowEngine.Engine.SetState(rfq, rfq.CurrentActivity.CurrentStateName, rfq.CurrentActivity.WorkflowInstanceID, "Awarded");

                    List<ORequestForQuotationItem> items = rfq.RequestForQuotationItems.Order();
                    int poType = Convert.ToInt32(rdlPOType.SelectedValue);
                    OPurchaseOrder po = OPurchaseOrder.CreatePOFromRFQLineItems(items, poType);
                    if (po == null)
                        message = rfq.ObjectNumber + ";";
                    else if (!String.IsNullOrEmpty(replacetxt) && replacetxt.Contains(">"))
                    {
                        string[] arr = replacetxt.Split('>');
                        if (arr.Length == 2)
                            using (Connection c = new Connection())
                            {
                                po.ObjectNumber = po.ObjectNumber.Replace(arr[0].Trim(), arr[1].Trim());
                                po.RequestForQuotationID = rfq.ObjectID;
                                po.Save();
                                c.Commit();
                            }
                    }
                }
            }
            if (!String.IsNullOrEmpty(message))
                pagePanel1.Message = "Unable to generate PO / LOA for the following WJs: " + message;
            else
                pagePanel1.Message = "Generate PO successfully.";
        }
        catch (Exception ex)
        {
            pagePanel1.Message = obj + ": " + ex.Message;
        }
    }

    protected void btnGenerateScript_Click(object sender, EventArgs e)
    {
        string tableslogic = DatabaseSetup.GenerateDropTablesNotInSchema(typeof(TablesLogic));
        string workflow = DatabaseSetup.GenerateDropTablesNotInSchema(typeof(TablesWorkflow));
        string audittrail = DatabaseSetup.GenerateDropTablesNotInSchema(typeof(TablesAuditTrail));
        string test = DatabaseSetup.GenerateDropTablesNotInSchema(typeof(TablesData));
        string output = "SELECT 'DROP TABLE ' + name from sys.tables where name not in (" + tableslogic + "," + workflow + "," + audittrail + "," + test + ")";
        output += @" and name not like 'Report%' and name not like 'sys%'";
        lblResults.Text = output;
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <web:pagepanel ID="pagePanel1" runat="server" Caption="Database Setup" meta:resourcekey="pagePanelResource1"
        Button1_Caption="Generate SQL" Button1_CommandName="GenerateSQL" Button1_ImageUrl="~/images/Symbol-Check-big.gif"
        OnClick="pagePanel1_Click" OnLoad="pagePanel1_Load" />
    <div class="div-main">
        <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1">
            <ui:UITabView runat="server" ID="uitabview1" Caption="Details" meta:resourcekey="uitabview1Resource1">
                <ui:UISeparator runat='server' ID="sep1" Caption="Save Object / Update Hierarchy Path" />
                <ui:UIFieldDropDownList runat="server" ID="dropObject" Caption="Object">
                    <Items>
                        <asp:ListItem Value=""></asp:ListItem>
                        <asp:ListItem Value="0">tLocation</asp:ListItem>
                        <asp:ListItem Value="1">tLocationType</asp:ListItem>
                        <asp:ListItem Value="2">tEquipment</asp:ListItem>
                        <asp:ListItem Value="3">tEquipmentType</asp:ListItem>
                        <asp:ListItem Value="4">tAccount</asp:ListItem>
                        <asp:ListItem Value="5">tCode</asp:ListItem>
                        <asp:ListItem Value="6">tCatalogue</asp:ListItem>
                        <asp:ListItem Value="7">tFixedRate</asp:ListItem>
                    </Items>
                </ui:UIFieldDropDownList>
                <table>
                    <tr>
                        <td style='width: 158px'>
                        </td>
                        <td>
                            <ui:UIButton runat="server" ID="buttonUpdateHierarchy" Text="Update Hierarchy" OnClick="buttonUpdateHierarchy_Click" />
                        </td>
                    </tr>
                </table>
                <ui:UISeparator runat='server' ID="UISeparator1" Caption="Migrate Workflow" />
                <ui:UIFieldDropDownList runat="server" ID="dropWorkflowObject" Caption="Object">
                    <Items>
                        <asp:ListItem Value=""></asp:ListItem>
                        <asp:ListItem Value="0">tRequestForQuotation</asp:ListItem>
                        <asp:ListItem Value="1">tPurchaseOrder</asp:ListItem>
                        <asp:ListItem Value="2">tPurchaseInvoice</asp:ListItem>
                        <asp:ListItem Value="3">tContract</asp:ListItem>
                        <asp:ListItem Value="4">tWork</asp:ListItem>
                        <asp:ListItem Value="5">tCase</asp:ListItem>
                    </Items>
                </ui:UIFieldDropDownList>
                <ui:UIFieldTextBox runat="server" ID="textWorkflowObjectNumber" Caption="Object Number"
                    Hint="Apply to one object only.">
                </ui:UIFieldTextBox>
                <ui:UIFieldRadioList runat="server" ID="radioMigrateMode">
                    <Items>
                        <asp:ListItem Value="0" Selected='True'>Migrate all objects and override existing workflows</asp:ListItem>
                        <asp:ListItem Value="1">Migrate only objects that are not attached to any workflows</asp:ListItem>
                    </Items>
                </ui:UIFieldRadioList>
                <table>
                    <tr>
                        <td style='width: 158px'>
                        </td>
                        <td>
                            <ui:UIButton runat="server" ID="buttonUpdateWorkflow" Text="Update Workflow" OnClick="buttonUpdateWorkflow_Click" />
                        </td>
                    </tr>
                </table>
                <ui:UISeparator runat='server' ID="UISeparator4" Caption="Transfer Purchase Budget for Purchase Invoice (Matched-PO)" />
                <table>
                    <tr>
                        <td style='width: 158px'>
                        </td>
                        <td>
                            <ui:UIButton runat="server" ID="btnTransferPurchaseBudget" Text="Transfer Purchase Budget"
                                OnClick="btnTransferPurchaseBudget_Click" />
                        </td>
                    </tr>
                </table>
                <ui:UISeparator runat='server' ID="UISeparator5" Caption="Update Purchase Budget Summary for Work Justification" />
                <table>
                    <tr>
                        <td style='width: 158px'>
                        </td>
                        <td>
                            <ui:UIButton runat="server" ID="btnCreateBudgetSummary" Text="Create Purchase Budget Summary"
                                OnClick="btnCreateBudgetSummary_Click" />
                            <ui:UIButton runat="server" ID="btnCreateBudgetSummaryTwentyAnson" Text="Create Purchase Budget Summary (Twenty Anson)"
                                OnClick="btnCreateBudgetSummaryTwentyAnson_Click" />    
                        </td>
                    </tr>
                </table>
                <ui:UISeparator runat='server' ID="UISeparator2" Caption="Touch and Save Object" />
                <ui:UIFieldDropDownList runat="server" ID="dropSaveObject" Caption="Object">
                    <Items>
                        <asp:ListItem Value=""></asp:ListItem>
                        <asp:ListItem Value="0">tRequestForQuotation</asp:ListItem>
                        <asp:ListItem Value="1">tPurchaseOrder</asp:ListItem>
                        <asp:ListItem Value="2">tPurchaseInvoice</asp:ListItem>
                        <asp:ListItem Value="3">tContract</asp:ListItem>
                        <asp:ListItem Value="4">tWork</asp:ListItem>
                        <asp:ListItem Value="5">tCase</asp:ListItem>
                        <asp:ListItem Value="6">tApprovalProcess</asp:ListItem>
                        <asp:ListItem Value="7">tSurveyPlanner</asp:ListItem>
                    </Items>
                </ui:UIFieldDropDownList>
                <table>
                    <tr>
                        <td style='width: 158px'>
                        </td>
                        <td>
                            <ui:UIButton runat="server" ID="buttonSaveObject" Text="Save Object" OnClick="buttonSaveObject_Click" />
                        </td>
                    </tr>
                </table>
                <ui:UISeparator runat='server' ID="UISeparator3" Caption="Forced Object Status" />
                <ui:UIFieldDropDownList runat="server" ID="dropUpdateStatusForObject" Caption="Object">
                    <Items>
                        <asp:ListItem Value=""></asp:ListItem>
                        <asp:ListItem Value="0">tRequestForQuotation</asp:ListItem>
                        <asp:ListItem Value="1">tPurchaseOrder</asp:ListItem>
                        <asp:ListItem Value="2">tPurchaseInvoice</asp:ListItem>
                        <asp:ListItem Value="3">tContract</asp:ListItem>
                        <asp:ListItem Value="4">tWork</asp:ListItem>
                        <asp:ListItem Value="5">tCase</asp:ListItem>
                        <asp:ListItem Value="6">tBudgetPeriod</asp:ListItem>
                        <asp:ListItem Value="7">tBudgetAdjustment</asp:ListItem>
                        <asp:ListItem Value="8">tBudgetReallocation</asp:ListItem>
                        <asp:ListItem Value="9">tStoreCheckIn</asp:ListItem>
                        <asp:ListItem Value="10">tStoreCheckOut</asp:ListItem>
                        <asp:ListItem Value="11">tStoreTransfer</asp:ListItem>
                    </Items>
                </ui:UIFieldDropDownList>
                <ui:UIFieldTextBox runat="server" ID="textUpdateStatusForObjectNumber" Caption="Object Number">
                </ui:UIFieldTextBox>
                <ui:UIFieldTextBox runat="server" ID="textUpdateState" Caption="State to Update to">
                </ui:UIFieldTextBox>
                <table>
                    <tr>
                        <td style='width: 158px'>
                        </td>
                        <td>
                            <ui:UIButton runat="server" ID="buttonUpdateObjectStatus" Text="Update Object Status"
                                OnClick="buttonUpdateObjectStatus_Click" />
                        </td>
                    </tr>
                </table>
                <ui:UISeparator runat='server' ID="UISeparator6" Caption="Generate PO from WJ" />
                <ui:UIFieldTextBox runat="server" ID="txtGeneratePOfromWJ" Caption="Object Number"
                    Hint="Separate by ;">
                </ui:UIFieldTextBox>
                <ui:UIFieldTextBox runat="server" ID="txtReplacePOfromWJ" Caption="Change Object Number"
                    Hint="Use > to indicate, for ex: WJ > PO, WJ0001 will generate PO0001">
                </ui:UIFieldTextBox>
                <ui:UIFieldRadioList runat="server" Caption="Type" ID="rdlPOType" RepeatColumns="3"
                    RepeatDirection="Vertical" TextAlign="Right">
                    <Items>
                        <asp:ListItem Value="0" Selected="True" meta:resourcekey="ListItemResource2">LOA</asp:ListItem>
                        <asp:ListItem Value="1" meta:resourcekey="ListItemResource3">PO</asp:ListItem>
                    </Items>
                </ui:UIFieldRadioList>
                <table>
                    <tr>
                        <td style='width: 158px'>
                        </td>
                        <td>
                            <ui:UIButton runat="server" ID="btnGeneratePOfromWJ" Text="Update WJs" OnClick="btnGeneratePOfromWJ_Click" />
                        </td>
                    </tr>
                </table>
                <ui:UIFieldLabel runat="server" ID="labelGeneratePOfromWJ" Visible="false">
                </ui:UIFieldLabel>
                <ui:UISeparator runat="server" ID="sepDropTables" Caption="Drop tables not in schema" />
                <ui:UIButton runat="server" ID="btnGenerateScript" OnClick="btnGenerateScript_Click" Text="Generate" />
                <ui:UIFieldTextBox runat="server" ID="lblResults" TextMode="MultiLine" Rows="20" ShowCaption="false"></ui:UIFieldTextBox>
            </ui:UITabView>
            <ui:UITabView runat="server" ID="uitabview2" Caption="SQL" CssClass="div-form">
                <table>
                    <tr>
                        <td style='width: 158px'>
                        </td>
                        <td>
                            <ui:UIButton runat="server" ID="btnSelect" AlwaysEnabled="true" CommandName="Select"
                                ImageUrl="~/images/information.gif" Text="SELECT" OnClick="btnSelect_Click" />
                            <ui:UIButton runat="server" ID="btnUpdateInsert" AlwaysEnabled="true" CommandName="UpdateInsert"
                                ImageUrl="~/images/warn-True.gif" Text="UPDATE / INSERT" OnClick="btnUpdateInsert_Click" />
                        </td>
                    </tr>
                </table>
                <ui:UIFieldTextBox runat="Server" ID="tb_Query" Caption="Query" Span="Full" TextMode="MultiLine"
                    MaxLength="0" Rows="10" />
                <div style="padding: 8px 8px 8px 8px; height: 550px; overflow: scroll">
                    <ui:UISeparator runat="server" ID="sepResult" Caption="Result" />
                    <ui:UIFieldLabel runat="server" ID="labelMessage" ShowCaption="false">
                    </ui:UIFieldLabel>
                    <ui:UIGridView ID="gv_Result" runat="server" CheckBoxColumnVisible="false" Width="100%"
                        AllowSorting="false" EnableTheming="false" ShowCaption="false" BindObjectsToRows="false">
                    </ui:UIGridView>
                </div>
            </ui:UITabView>
        </ui:UITabStrip>
    </div>
    </form>
</body>
</html>
