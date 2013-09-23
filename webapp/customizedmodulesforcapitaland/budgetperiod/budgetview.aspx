<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Register Assembly="Anacle.UIFramework" Namespace="Anacle.UIFramework" TagPrefix="cc1" %>

<script runat="server">
    
    protected void SetReportHeader()
    {
        labelBudgetName.Text = BudgetPeriod.Budget.ObjectName;
        labelBudgetPeriodName.Text = BudgetPeriod.ObjectName;
        labelStartDate.Text = BudgetPeriod.StartDate.Value.ToString("dd-MMM-yyyy");
        labelEndDate.Text = BudgetPeriod.EndDate.Value.ToString("dd-MMM-yyyy");


        StringBuilder sb = new StringBuilder();
        foreach (OLocation location in BudgetPeriod.Budget.ApplicableLocations)
            sb.Append(location.Path + "<br/>");
        labelLocation.Text = sb.ToString();

    }

    //  Summary
    protected void BuildGridSummary()
    {
        DataTable dt = new DataTable();
        if (this.treeParentID.SelectedValue != null && this.treeParentID.SelectedValue != "")
            dt = BudgetPeriod.GenerateSummaryBudgetView(new Guid(this.treeParentID.SelectedValue));
        else
            dt = BudgetPeriod.GenerateSummaryBudgetView(null);
        this.gridSummaryView.DataSource = dt;
        this.gridSummaryView.DataBind();
    }

    //  YTD
    protected void BuildGridYear()
    {
        DataTable dt = new DataTable();
        if (this.treeParentID.SelectedValue != null && this.treeParentID.SelectedValue != "")
            dt = BudgetPeriod.GenerateYearlyBudgetView(new Guid(this.treeParentID.SelectedValue));
        else
            dt = BudgetPeriod.GenerateYearlyBudgetView(null);
        this.gridYearView.DataSource = dt;
        this.gridYearView.DataBind();
    }

    //  MTD
    protected void BuildGridMonth()
    {
        DataTable dt = new DataTable();
        if (this.treeParentID.SelectedValue != null && this.treeParentID.SelectedValue != "")
            dt = BudgetPeriod.GenerateIntervalView(
           BudgetViewOptions.AddOpeningBalance, null, null, new Guid(this.treeParentID.SelectedValue));
        else
            dt = BudgetPeriod.GenerateIntervalView(
            BudgetViewOptions.AddOpeningBalance, null, null, null);
        this.gridMonthView.DataSource = dt;
        this.gridMonthView.DataBind();
    }

    protected void BuildGridReallocated()
    {
        DataTable dt = new DataTable();
        if (this.treeParentID.SelectedValue != null && this.treeParentID.SelectedValue != "")
            dt = BudgetPeriod.GenerateIntervalView(
               BudgetViewOptions.AddVariations, new int[] { BudgetVariationType.Reallocation }, null, new Guid(this.treeParentID.SelectedValue));
        else
            dt = BudgetPeriod.GenerateIntervalView(
           BudgetViewOptions.AddVariations, new int[] { BudgetVariationType.Reallocation }, null, null);
        this.gridReallocated.DataSource = dt;
        this.gridReallocated.DataBind();
    }

    protected void BuildGridAdjusted()
    {
        DataTable dt = new DataTable();
        if (this.treeParentID.SelectedValue != null && this.treeParentID.SelectedValue != "")
            dt = BudgetPeriod.GenerateIntervalView(
               BudgetViewOptions.AddVariations, new int[] { BudgetVariationType.Adjustment }, null, new Guid(this.treeParentID.SelectedValue));
        else
            dt = BudgetPeriod.GenerateIntervalView(
            BudgetViewOptions.AddVariations, new int[] { BudgetVariationType.Adjustment }, null, null);
        this.gridAdjusted.DataSource = dt;
        this.gridAdjusted.DataBind();
    }

    protected void BuildGridPendingApproval()
    {
        DataTable dt = new DataTable();
        if (this.treeParentID.SelectedValue != null && this.treeParentID.SelectedValue != "")
            dt = BudgetPeriod.GenerateIntervalView(
               BudgetViewOptions.AddTransactions, null, new int[] { BudgetTransactionType.PurchasePendingApproval }, new Guid(this.treeParentID.SelectedValue));
        else
            dt = BudgetPeriod.GenerateIntervalView(
            BudgetViewOptions.AddTransactions, null, new int[] { BudgetTransactionType.PurchasePendingApproval }, null);
        this.gridPendingApproval.DataSource = dt;
        this.gridPendingApproval.DataBind();
    }

    protected void BuildGridApproved()
    {
        DataTable dt = new DataTable();
        if (this.treeParentID.SelectedValue != null && this.treeParentID.SelectedValue != "")
            dt = BudgetPeriod.GenerateIntervalView(
               BudgetViewOptions.AddTransactions, null, new int[] { BudgetTransactionType.PurchaseApproved, BudgetTransactionType.PurchaseInvoiceApproved }, new Guid(this.treeParentID.SelectedValue));
        else
            dt = BudgetPeriod.GenerateIntervalView(
            BudgetViewOptions.AddTransactions, null, new int[] { BudgetTransactionType.PurchaseApproved, BudgetTransactionType.PurchaseInvoiceApproved }, null);
        this.gridApproved.DataSource = dt;
        this.gridApproved.DataBind();
    }

    protected void BuildGridExpensed()
    {
        DataTable dt = new DataTable();
        if (this.treeParentID.SelectedValue != null && this.treeParentID.SelectedValue != "")
            dt = BudgetPeriod.GenerateIntervalView(
               BudgetViewOptions.AddTransactions, null, new int[] { BudgetTransactionType.DirectInvoiceApproved }, new Guid(this.treeParentID.SelectedValue));
        else
            dt = BudgetPeriod.GenerateIntervalView(
            BudgetViewOptions.AddTransactions, null, new int[] { BudgetTransactionType.DirectInvoiceApproved }, null);

        this.gridExpensed.DataSource = dt;
        this.gridExpensed.DataBind();
    }

    protected void BuildGridExpensedPendingApproval()
    {
        DataTable dt = new DataTable();
        if (this.treeParentID.SelectedValue != null && this.treeParentID.SelectedValue != "")
            dt = BudgetPeriod.GenerateIntervalView(
               BudgetViewOptions.AddTransactions, null, new int[] { BudgetTransactionType.DirectInvoicePendingApproval }, new Guid(this.treeParentID.SelectedValue));
        else
            dt = BudgetPeriod.GenerateIntervalView(
            BudgetViewOptions.AddTransactions, null, new int[] { BudgetTransactionType.DirectInvoicePendingApproval }, null);
        this.gridExpensedPendingApproval.DataSource = dt;
        this.gridExpensedPendingApproval.DataBind();
    }

    protected void BuildGridInvoiced()
    {
        DataTable dt = new DataTable();
        if (this.treeParentID.SelectedValue != null && this.treeParentID.SelectedValue != "")
            dt = BudgetPeriod.GenerateIntervalView(
                BudgetViewOptions.AddTransactions, null, new int[] { BudgetTransactionType.PurchaseInvoiceApproved }, new Guid(this.treeParentID.SelectedValue));
        else
            dt = BudgetPeriod.GenerateIntervalView(
            BudgetViewOptions.AddTransactions, null, new int[] { BudgetTransactionType.PurchaseInvoiceApproved }, null);
        this.gridInvoiced.DataSource = dt;
        this.gridInvoiced.DataBind();
    }

    protected void BuildGridPayment()
    {
        /*
        //Write code to build data table for the MTD Payment view here
        DataTable dt = new DataTable();
        OYearlyBudget objYearlyBudget = TablesLogic.tYearlyBudget[this.BudgetID];
        dt = OYearlyBudget.BuildTreeViewEffect(objYearlyBudget.Payment());
        //assign datatable to respective grid
        this.gridPayment.DataSource = dt;
        this.gridPayment.DataBind();
         * */
    }

    protected void BuildGridAvailable()
    {
        DataTable dt = new DataTable();
        if (this.treeParentID.SelectedValue != null && this.treeParentID.SelectedValue != "")
            dt = BudgetPeriod.GenerateIntervalViewForCapitaland(
               BudgetViewOptions.AddOpeningBalance |
               BudgetViewOptions.AddVariations |
               BudgetViewOptions.SubtractTransactions,
               null,
               null, new Guid(this.treeParentID.SelectedValue));
        else
            dt = BudgetPeriod.GenerateIntervalViewForCapitaland(
            BudgetViewOptions.AddOpeningBalance |
            BudgetViewOptions.AddVariations |
            BudgetViewOptions.SubtractTransactions,
            null,
            null, null);
        this.gridAvailable.DataSource = dt;
        this.gridAvailable.DataBind();
    }
    protected void BuildGridAdjustmentDetails()
    {
        DataTable dt = new DataTable();
        if (this.treeParentID.SelectedValue != null && this.treeParentID.SelectedValue != "")
            dt = BudgetPeriod.GenerateBudgetAdjustmentDetail(new Guid(this.treeParentID.SelectedValue));
        else
            dt = BudgetPeriod.GenerateBudgetAdjustmentDetail(null);
        this.gridAdjustmentDetails.DataSource = dt;
        this.gridAdjustmentDetails.DataBind();
    }
    protected void BuildGridReallocationDetails()
    {
        DataTable dt = new DataTable();
        if (this.treeParentID.SelectedValue != null && this.treeParentID.SelectedValue != "")
            dt = BudgetPeriod.GenerateBudgetReallocationDetail(new Guid(this.treeParentID.SelectedValue));
        else
            dt = BudgetPeriod.GenerateBudgetReallocationDetail(null);
        this.gridReallocationDetails.DataSource = dt;
        this.gridReallocationDetails.DataBind();
    }

    /// <summary>
    /// A cached copy of the application's base currency symbol.
    /// </summary>
    string currencySymbol = null;


    /// <summary>
    /// Gets the currency symbol.
    /// </summary>
    public string CurrencySymbol
    {
        get
        {
            if (currencySymbol == null)
                currencySymbol = OApplicationSetting.Current.BaseCurrency.CurrencySymbol;
            return currencySymbol;
        }
    }


    /// <summary>
    /// Sets up the grid to show the budget line item.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    void grid_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        GridView grid = sender as GridView;

        // Hide the intervals that are greater than the total
        // number of intervals in this budget period
        //
        if (e.Row.RowType == DataControlRowType.Header)
        {
            int numberOfIntervals = budgetPeriod.TotalNumberOfIntervals;
            int monthsPerInterval = budgetPeriod.NumberOfMonthsPerInterval.Value;
            for (int i = 0; i < grid.Columns.Count; i++)
            {
                if (grid.Columns[i] is UIGridViewBoundColumn &&
                    ((UIGridViewBoundColumn)grid.Columns[i]).PropertyName.StartsWith("Interval") &&
                    ((UIGridViewBoundColumn)grid.Columns[i]).PropertyName.EndsWith("Amount"))
                {
                    int interval = Convert.ToInt32(((UIGridViewBoundColumn)grid.Columns[i]).PropertyName
                        .Replace("Interval", "").Replace("Amount", ""));
                    if (interval > numberOfIntervals)
                        grid.Columns[i].Visible = false;
                    else
                    {
                        DateTime intervalStartDate = budgetPeriod.StartDate.Value.AddMonths((interval - 1) * monthsPerInterval);
                        if (intervalStartDate.Day == 1)
                            e.Row.Cells[i].Text =
                                intervalStartDate.ToString("MMM-yyyy");
                        else
                            e.Row.Cells[i].Text =
                                intervalStartDate.ToString("dd-MMM-yyyy");
                    }
                }
            }
            e.Row.Cells[0].Visible = false;
            e.Row.Cells[1].Visible = false;
            e.Row.Cells[2].Visible = false;
            e.Row.Cells[3].Visible = false;
            e.Row.Cells[4].Visible = false;
        }

        if (e.Row.RowType == DataControlRowType.DataRow || e.Row.RowType == DataControlRowType.Footer)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                // if the Account is not a line item type, 
                // set the font of the Account to bold
                //
                if (Convert.ToInt32(e.Row.Cells[3].Text) == 0)
                    e.Row.Cells[4].Font.Bold = true;

                // Adding padding to simulate a tree effect.
                //
                int level = Convert.ToInt32(e.Row.Cells[2].Text);
                e.Row.Cells[4].Text = "<p style='padding-left: " + (level * 10).ToString() + "px'>" +
                    e.Row.Cells[4].Text.ToString() + "</p>";
            }

            // Show the currency (and highlight in red if negative.
            // 
            for (int i = 0; i < grid.Columns.Count; i++)
            {
                if (grid.Columns[i] is UIGridViewBoundColumn &&
                    (((UIGridViewBoundColumn)grid.Columns[i]).PropertyName.StartsWith("Total") ||
                    ((UIGridViewBoundColumn)grid.Columns[i]).PropertyName.StartsWith("Interval")))
                {
                    try
                    {

                        if (e.Row.Cells[i].Text != "" &&
                            e.Row.Cells[i].Text != "&nbsp;")
                        {
                            if (Convert.ToDecimal(e.Row.Cells[i].Text) < 0)
                            {
                                e.Row.Cells[i].ForeColor = System.Drawing.Color.Red;
                                e.Row.Cells[i].Text = Convert.ToDecimal(e.Row.Cells[i].Text).ToString("n");
                            }
                            else
                            {
                                e.Row.Cells[i].Text = Convert.ToDecimal(e.Row.Cells[i].Text).ToString("n");
                            }
                        }
                    }
                    catch
                    {
                        i = i;
                    }
                }
            }

            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                if (Convert.ToInt32(e.Row.Cells[3].Text) == 1)
                {
                    HyperLink account = (HyperLink)e.Row.FindControl("linkAccount");
                    string sAccount = e.Row.Cells[4].Text;
                    string[] acc = sAccount.Split(';');
                    sAccount = sAccount.Replace("&nbsp;", "");
                    sAccount = sAccount.Trim();
                    account.Text = sAccount;
                    account.NavigateUrl = "WJDetails.aspx?AccountID=" + HttpUtility.UrlEncode(Security.Encrypt(e.Row.Cells[1].Text)) +
                        "&BudgetPeriodID=" + HttpUtility.UrlEncode(Security.Encrypt(BudgetPeriod.ObjectID.ToString()));
                    Label lblAccount = (Label)e.Row.FindControl("lblAccount");
                    string a = "";
                    for (int i = 0; i < acc.Length - 1; i++)
                        a = a + "&nbsp;";
                    lblAccount.Text = a;
                    lblAccount.Visible = false;
                }
                else
                {
                    HyperLink account = (HyperLink)e.Row.FindControl("linkAccount");
                    account.Visible = false;
                    Label lblAccount = (Label)e.Row.FindControl("lblAccount");
                    lblAccount.Text = e.Row.Cells[4].Text;
                    lblAccount.Font.Bold = true;
                    lblAccount.Visible = true;
                }
            }
            e.Row.Cells[0].Visible = false;
            e.Row.Cells[1].Visible = false;
            e.Row.Cells[2].Visible = false;
            e.Row.Cells[3].Visible = false;
            e.Row.Cells[4].Visible = false;
        }
    }


    void gridYearView_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        grid_RowDataBound(sender, e);
    }

    void gridAvailable_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        grid_RowDataBound(sender, e);
    }

    void gridPayment_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        grid_RowDataBound(sender, e);
    }

    void gridInvoiced_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        grid_RowDataBound(sender, e);
    }

    void gridExpensed_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        grid_RowDataBound(sender, e);
    }

    void gridExpensedPendingApproval_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        grid_RowDataBound(sender, e);
    }

    void gridApproved_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        grid_RowDataBound(sender, e);
    }

    void gridPendingApproval_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        grid_RowDataBound(sender, e);
    }

    void gridAdjusted_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        grid_RowDataBound(sender, e);
    }

    void gridReallocated_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        grid_RowDataBound(sender, e);
    }

    void gridMonthView_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        grid_RowDataBound(sender, e);
    }


    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        this.gridSummaryView.RowDataBound += new GridViewRowEventHandler(gridYearView_RowDataBound);
        this.gridYearView.RowDataBound += new GridViewRowEventHandler(gridYearView_RowDataBound);
        this.gridMonthView.RowDataBound += new GridViewRowEventHandler(gridMonthView_RowDataBound);
        this.gridReallocated.RowDataBound += new GridViewRowEventHandler(gridReallocated_RowDataBound);
        this.gridAdjusted.RowDataBound += new GridViewRowEventHandler(gridAdjusted_RowDataBound);
        this.gridPendingApproval.RowDataBound += new GridViewRowEventHandler(gridPendingApproval_RowDataBound);
        this.gridApproved.RowDataBound += new GridViewRowEventHandler(gridApproved_RowDataBound);
        this.gridExpensed.RowDataBound += new GridViewRowEventHandler(gridExpensed_RowDataBound);
        this.gridExpensedPendingApproval.RowDataBound += new GridViewRowEventHandler(gridExpensedPendingApproval_RowDataBound);
        this.gridInvoiced.RowDataBound += new GridViewRowEventHandler(gridInvoiced_RowDataBound);
        this.gridPayment.RowDataBound += new GridViewRowEventHandler(gridPayment_RowDataBound);
        this.gridAvailable.RowDataBound += new GridViewRowEventHandler(gridAvailable_RowDataBound);

        treeParentID.PopulateTree();

        if (!IsPostBack)
        {
            if (BudgetPeriod.Budget.BudgetDeductionPolicy == BudgetDeductionPolicy.DeductAtSubmission)
                gridSummaryView.Columns[15].HeaderText = Resources.Strings.BudgetView_SummaryWithPendingApproval;
            else
                gridSummaryView.Columns[15].HeaderText = Resources.Strings.BudgetView_SummaryWithoutPendingApproval;

            BuildReport();
            SetLabels();
            SetReportHeader();

            if (Request["AccountID"] != null)
            {
                try
                {
                    Guid accountID = new Guid(Security.Decrypt(Request["AccountID"]));


                    OAccount account = TablesLogic.tAccount[accountID];
                    if (account != null)
                    {
                        Guid? SecondLevelAccountID = TablesLogic.tAccount.Select(
                        TablesLogic.tAccount.ObjectID)
                        .Where(account.HierarchyPath.Like(TablesLogic.tAccount.HierarchyPath + "%") &
                        TablesLogic.tAccount.Parent.ParentID == null);
                        if (SecondLevelAccountID != null)
                            treeParentID.SelectedValue = SecondLevelAccountID.Value.ToString();
                    }
                }
                catch { }

            }
        }

    }

    protected void SetLabels()
    {
        this.summaryLabel.Text = this.yearLabel.Text + DateTime.Now.ToString("dd-MMM-yyy HH:mm");
        this.yearLabel.Text = this.yearLabel.Text + DateTime.Now.ToString("dd-MMM-yyy HH:mm");
        this.monthLabel.Text = this.monthLabel.Text + DateTime.Now.ToString("dd-MMM-yyy HH:mm");
        this.reallocateLabel.Text = this.reallocateLabel.Text + DateTime.Now.ToString("dd-MMM-yyy HH:mm");
        this.adjustedLabel.Text = this.adjustedLabel.Text + DateTime.Now.ToString("dd-MMM-yyy HH:mm");

        this.pendingLabel.Text = this.pendingLabel.Text + DateTime.Now.ToString("dd-MMM-yyy HH:mm");
        this.approveLabel.Text = this.approveLabel.Text + DateTime.Now.ToString("dd-MMM-yyy HH:mm");
        this.expenseLabel.Text = this.expenseLabel.Text + DateTime.Now.ToString("dd-MMM-yyy HH:mm");
        this.expensePendingApprovalLabel.Text = this.expenseLabel.Text + DateTime.Now.ToString("dd-MMM-yyy HH:mm");
        this.invoicedLabel.Text = this.invoicedLabel.Text + DateTime.Now.ToString("dd-MMM-yyy HH:mm");
        this.paymentLabel.Text = this.paymentLabel.Text + DateTime.Now.ToString("dd-MMM-yyy HH:mm");
        this.availableLabel.Text = this.availableLabel.Text + DateTime.Now.ToString("dd-MMM-yyy HH:mm");


    }

    protected void BuildReport()
    {
        switch (RequestView)
        {
            case 0:
                BuildGridSummary();
                break;
            case 1:
                BuildGridYear();
                break;
            case 2:
                this.BuildGridMonth();
                break;
            case 3:
                this.BuildGridReallocated();
                this.BuildGridReallocationDetails();
                break;
            case 4:
                this.BuildGridAdjusted();
                BuildGridAdjustmentDetails();
                break;
            case 5:
                this.BuildGridPendingApproval();
                break;
            case 6:
                this.BuildGridApproved();
                break;
            case 7:
                this.BuildGridExpensed();
                break;
            case 8:
                this.BuildGridExpensedPendingApproval();
                break;
            case 9:
                this.BuildGridInvoiced();
                break;
            case 10:
                this.BuildGridPayment();
                break;
            case 11:
                this.BuildGridAvailable();
                this.BuildGridAdjusted();
                this.BuildGridPendingApproval();
                this.BuildGridApproved();
                this.BuildGridExpensed();
                break;

        }
    }

    public int RequestView
    {
        get
        {
            if (ViewState["RequestView"] != null)
                return Convert.ToInt32(ViewState["RequestView"]);
            else
                //return year budget view by default
                return 0;
        }
        set
        {
            ViewState["RequestView"] = value;
        }
    }


    /// <summary>
    /// Gets the budget period ID from the query string.
    /// </summary>
    public Guid BudgetPeriodID
    {
        get
        {
            return new Guid(Security.DecryptGuid(Request["ID"].ToString()).ToString());
        }
    }


    /// <summary>
    /// A cached copy of the budget period object.
    /// </summary>
    OBudgetPeriod budgetPeriod = null;


    /// <summary>
    /// Gets the budget period object by loading it from the database.
    /// Once loaded, the budget period object is cached for the current postback.
    /// </summary>
    public OBudgetPeriod BudgetPeriod
    {
        get
        {
            if (budgetPeriod == null)
                budgetPeriod = TablesLogic.tBudgetPeriod.Load(BudgetPeriodID);
            return budgetPeriod;
        }
    }




    protected void summaryView_OnClick(object sender, EventArgs e)
    {
        RequestView = 0;
        BuildReport();
    }

    protected void yearView_OnClick(object sender, EventArgs e)
    {
        RequestView = 1;
        BuildReport();
    }

    protected void monthView_OnClick(object sender, EventArgs e)
    {
        RequestView = 2;
        BuildReport();
    }

    protected void reallocated_OnClick(object sender, EventArgs e)
    {
        RequestView = 3;
        BuildReport();
    }

    protected void adjusted_OnClick(object sender, EventArgs e)
    {
        RequestView = 4;
        BuildReport();
    }

    protected void pendingApproval_OnClick(object sender, EventArgs e)
    {
        RequestView = 5;
        BuildReport();
    }

    protected void approved_OnClick(object sender, EventArgs e)
    {
        RequestView = 6;
        BuildReport();
    }

    protected void expensed_OnClick(object sender, EventArgs e)
    {
        RequestView = 7;
        BuildReport();
    }

    protected void expensedPendingApproval_OnClick(object sender, EventArgs e)
    {
        RequestView = 8;
        BuildReport();
    }

    protected void invoiced_OnClick(object sender, EventArgs e)
    {
        RequestView = 9;
        BuildReport();
    }

    protected void payment_OnClick(object sender, EventArgs e)
    {
        RequestView = 10;
        BuildReport();
    }

    protected void available_OnClick(object sender, EventArgs e)
    {
        RequestView = 11;
        BuildReport();
    }

    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        //grid visiblity
        this.summaryPanel.Visible = RequestView == 0;
        this.yearPanel.Visible = RequestView == 1;
        this.monthPanel.Visible = RequestView == 2;
        this.reallocatePanel.Visible = RequestView == 3;
        this.adjustedPanel.Visible = (RequestView == 4 || RequestView == 11);
        this.pendingPanel.Visible = (RequestView == 5 || RequestView == 11);
        this.approvePanel.Visible = (RequestView == 6 || RequestView == 11);
        this.expensePanel.Visible = (RequestView == 7 || RequestView == 11);
        this.expensePendingApprovalPanel.Visible = (RequestView == 8 || RequestView == 11);
        this.invoicedPanel.Visible = RequestView == 9;
        this.paymentPanel.Visible = RequestView == 10;
        this.availablePanel.Visible = RequestView == 11;


        //reformat month number header for each column
        ReformatMonthNameHeader(this.gridAvailable);
        ReformatMonthNameHeader(this.gridExpensed);
        ReformatMonthNameHeader(this.gridInvoiced);
        ReformatMonthNameHeader(this.gridMonthView);
        ReformatMonthNameHeader(this.gridPayment);
        ReformatMonthNameHeader(this.gridPendingApproval);
        ReformatMonthNameHeader(this.gridReallocated);
        ReformatMonthNameHeader(this.gridAdjusted);
        ReformatMonthNameHeader(this.gridApproved);
        BuildReport();
    }

    protected void ReformatMonthNameHeader(UIGridView grid)
    {
        /*
        OYearlyBudget objYearlyBudget = TablesLogic.tYearlyBudget[this.BudgetID];
        int month = 1;
        for (int i = 5; i <= 16; i++)
        {
            grid.Columns[i].HeaderText = objYearlyBudget.GetFinancialMonthStart(month++).ToString("MMM");            
        }
         * */
    }

    protected void gridReallocationDetails_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        // Show the currency (and highlight in red if negative.
        // 
        for (int i = 0; i < gridReallocationDetails.Columns.Count; i++)
        {
            if (gridReallocationDetails.Columns[i] is UIGridViewBoundColumn &&
                (((UIGridViewBoundColumn)gridReallocationDetails.Columns[i]).DataField.StartsWith("Amount")))
            {
                try
                {

                    if (e.Row.Cells[i].Text != "" &&
                        e.Row.Cells[i].Text != "&nbsp;")
                    {
                        if (Convert.ToDecimal(e.Row.Cells[i].Text) < 0)
                        {
                            e.Row.Cells[i].ForeColor = System.Drawing.Color.Red;
                            e.Row.Cells[i].Text = Convert.ToDecimal(e.Row.Cells[i].Text).ToString("n");
                        }
                        else
                        {
                            e.Row.Cells[i].Text = Convert.ToDecimal(e.Row.Cells[i].Text).ToString("n");
                        }
                    }
                }
                catch
                {
                    i = i;
                }
            }
        }
    }
    protected TreePopulater treeParentID_AcquireTreePopulater(object sender)
    {


        if (Request["AccountID"] != "" && Request["AccountID"] != null)
        {
            return new AccountTreePopulater(new Guid(Security.Decrypt(Request["AccountID"].ToString())), true, true, BudgetPeriodID);
        }
        else
            return new AccountTreePopulater(null, true, true, BudgetPeriodID);

    }

    protected void treeParentID_SelectedNodeChanged(object sender, EventArgs e)
    {

    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <style type="text/css">
    .grid-row td
    {
	    border-bottom: solid 1px #dddddd;
	    border-left: solid 1px #dddddd;
	    border-right: solid 1px #dddddd;
	    height: 0px;
    }
    </style>
    <form id="form2" runat="server">
    <ui:UIPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabStrip" BorderStyle="NotSet" meta:resourcekey="tabStripResource1">
                <table cellspacing="0" border='0' cellpadding='0'>
                    <tr>
                        <td style="padding: 16px 16px 0px 16px">
                            <ui:UIFieldTreeList ID="treeParentID" runat="server" Caption="Search Account" OnAcquireTreePopulater="treeParentID_AcquireTreePopulater"
                                PropertyName="ParentID" ShowCheckBoxes="None" TreeValueMode="SelectedNode" OnSelectedNodeChanged="treeParentID_SelectedNodeChanged">
                            </ui:UIFieldTreeList>
                        </td>
                    </tr>
                </table>
                <div style="display:none">
                <ui:UITabView runat="server" ID="tabSummaryView" Caption="Summary" OnClick="summaryView_OnClick"
                    BorderStyle="NotSet" meta:resourcekey="tabSummaryViewResource1">
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabYearView" Caption="YTD" OnClick="yearView_OnClick"
                    BorderStyle="NotSet" meta:resourcekey="tabYearViewResource1">
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabMonthView" Caption="Opening" OnClick="monthView_OnClick"
                    BorderStyle="NotSet" meta:resourcekey="tabMonthViewResource1">
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabReallocated" Caption="Reallocated" OnClick="reallocated_OnClick"
                    BorderStyle="NotSet" meta:resourcekey="tabReallocatedResource1">
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabAdjusted" Caption="Adjusted" OnClick="adjusted_OnClick"
                    BorderStyle="NotSet" meta:resourcekey="tabAdjustedResource1">
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabPendingApproval" Caption="Pending" OnClick="pendingApproval_OnClick"
                    BorderStyle="NotSet" meta:resourcekey="tabPendingApprovalResource1">
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabApprove" Caption="Approved" OnClick="approved_OnClick"
                    BorderStyle="NotSet" meta:resourcekey="tabApproveResource1">
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabExpensed" Caption="D.Invoice Pending" OnClick="expensedPendingApproval_OnClick"
                    BorderStyle="NotSet" meta:resourcekey="tabExpensedResource1">
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabExpensedPendingApproval" Caption="D.Invoice Approved"
                    OnClick="expensed_OnClick" BorderStyle="NotSet" meta:resourcekey="tabExpensedPendingApprovalResource1">
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabInvoiced" Caption="PO Invoiced" OnClick="invoiced_OnClick"
                    BorderStyle="NotSet" meta:resourcekey="tabInvoicedResource1">
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabAvailable" Caption="Available" OnClick="available_OnClick"
                    BorderStyle="NotSet" meta:resourcekey="tabAvailableResource1">
                </ui:UITabView>
                </div>
            </ui:UITabStrip>
            <div class="div-form">
                <table>
                    <tr>
                        <td width="150px">
                            <asp:Label ID="labelBudgetNameCaption" runat="server" Text="Budget: " Font-Bold="True"
                                meta:resourcekey="labelBudgetNameCaptionResource1"></asp:Label>
                        </td>
                        <td>
                            <asp:Label ID="labelBudgetName" runat="server" meta:resourcekey="labelBudgetNameResource1"></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Label ID="labelBudgetPeriodNameCaption" runat="server" Text="Budget Period: "
                                Font-Bold="True" meta:resourcekey="labelBudgetPeriodNameCaptionResource1"></asp:Label>
                        </td>
                        <td>
                            <asp:Label ID="labelBudgetPeriodName" runat="server" meta:resourcekey="labelBudgetPeriodNameResource1"></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Label ID="labelStartDateCaption" runat="server" Text="Date: " Font-Bold="True"
                                meta:resourcekey="labelStartDateCaptionResource1"></asp:Label>
                        </td>
                        <td>
                            <asp:Label ID="labelStartDate" runat="server" meta:resourcekey="labelStartDateResource1"></asp:Label>
                            <asp:Label ID="labelTo" runat="server" Text=" to " meta:resourcekey="labelToResource1"></asp:Label>
                            <asp:Label ID="labelEndDate" runat="server" meta:resourcekey="labelEndDateResource1"></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Label ID="labelLocationCaption" runat="server" Text="Location: " Font-Bold="True"
                                meta:resourcekey="labelLocationCaptionResource1"></asp:Label>
                        </td>
                        <td>
                            <asp:Label ID="labelLocation" runat="server" meta:resourcekey="labelLocationResource1"></asp:Label>
                        </td>
                    </tr>
                </table>
                <hr />
                <ui:UIPanel runat="server" ID="summaryPanel" BorderStyle="NotSet" meta:resourcekey="summaryPanelResource1">
                    <asp:Label runat="server" ID="summaryLabel" Text="Summary Budget as at " Font-Bold="True"
                        meta:resourcekey="summaryLabelResource1"></asp:Label>
                    <br />
                    <br />
                    <ui:uigridview ID="gridSummaryView" runat="server" DataKeyField="AccountID" CssClass="datagrid" 
                        BorderColor="#CCCCCC" BorderWidth="1px" CellPadding="1" AutoGenerateColumns="False"
                        Width="100%" meta:resourcekey="gridSummaryViewResource1" ShowFooter="true" PageSize="1000" ShowCaption="false" AllowSorting="false">
                        <Columns>
                            <ui:uigridviewboundcolumn PropertyName="AccountID" ReadOnly="True"></ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Level" ReadOnly="True"></ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Type" ReadOnly="True"></ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="AccountName" ReadOnly="True" HeaderText="Account">
                                <ItemStyle HorizontalAlign="Left" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewtemplatecolumn HeaderText="Account">
                                <ItemTemplate>
                                    <asp:Label runat="server" ID="lblAccount" meta:resourcekey="lblAccountResource1"></asp:Label>
                                    <asp:HyperLink runat="server" ID="linkAccount" meta:resourcekey="linkAccountResource1"></asp:HyperLink>
                                </ItemTemplate>
                            </ui:uigridviewtemplatecolumn>
                            <ui:uigridviewboundcolumn PropertyName="AccountCode" ReadOnly="True" HeaderText="Account Code">
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="TotalOpeningBalance" ReadOnly="True" HeaderText="(1) Opening Balance" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" Width="80px" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="TotalAdjustedAmount" ReadOnly="True" HeaderText="(2) Adjusted Amount" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" Width="80px" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="TotalReallocatedAmount" ReadOnly="True" HeaderText="(3) Reallocated Amount" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" Width="80px" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="TotalBalanceAfterVariation" ReadOnly="True" HeaderText="(4) Total After Adjustments<br/>(1)+(2)+(3)" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" Width="80px" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="TotalPendingApproval" ReadOnly="True" HeaderText="(5) Total Pending Approval" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" Width="80px" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="TotalApproved" ReadOnly="True" HeaderText="(6) Total Approved" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" Width="80px" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="TotalInvoiceApproved" ReadOnly="True" HeaderText="(7) Total Invoiced" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" Width="80px" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="TotalDirectInvoicePendingApproval" ReadOnly="True" HeaderText="(8) Total Direct Invoice Pending Approval " FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" Width="80px" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="TotalDirectInvoiceApproved" ReadOnly="True" HeaderText="(9) Total Direct Invoice Approved " FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" Width="80px" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="TotalAvailableBalance" ReadOnly="True" HeaderText="(10) Total Available<br/>(4)-(5)-(6)-(8)-(9)" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" Width="80px" />
                            </ui:uigridviewboundcolumn>
                        </Columns>
                        <HeaderStyle CssClass="grid-header" />
                    </ui:uigridview>
                </ui:UIPanel>
                <ui:UIPanel runat="server" ID="yearPanel" BorderStyle="NotSet" meta:resourcekey="yearPanelResource1">
                    <asp:Label runat="server" ID="yearLabel" Text="YTD Budget as at " Font-Bold="True"
                        meta:resourcekey="yearLabelResource1"></asp:Label>
                    <br />
                    <br />
                    <ui:uigridview ID="gridYearView" runat="server" DataKeyField="AccountID" CssClass="datagrid"
                        BorderColor="#CCCCCC" BorderWidth="1px" CellPadding="1" AutoGenerateColumns="False"
                        Width="100%" meta:resourcekey="gridYearViewResource1" ShowFooter="true" PageSize="1000" ShowCaption="false" AllowSorting="false">
                        <Columns>
                            <ui:uigridviewboundcolumn PropertyName="AccountID" ReadOnly="True"></ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Level" ReadOnly="True"></ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Type" ReadOnly="True"></ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="AccountName" ReadOnly="True" HeaderText="Account">
                                <ItemStyle HorizontalAlign="Left" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewtemplatecolumn HeaderText="Account">
                                <ItemTemplate>
                                    <asp:Label runat="server" ID="lblAccount" meta:resourcekey="lblAccountResource2"></asp:Label>
                                    <asp:HyperLink runat="server" ID="linkAccount" meta:resourcekey="linkAccountResource2"></asp:HyperLink>
                                </ItemTemplate>
                            </ui:uigridviewtemplatecolumn>
                            <ui:uigridviewboundcolumn PropertyName="AccountCode" ReadOnly="True" HeaderText="Account Code">
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="TotalOpeningBalance" ReadOnly="True" HeaderText="(1) Opening Balance" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" Width="80px" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="TotalAdjustedAmount" ReadOnly="True" HeaderText="(2) Adjusted Amount" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" Width="80px" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="TotalReallocatedAmount" ReadOnly="True" HeaderText="(3) Reallocated Amount" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" Width="80px" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="TotalBalanceAfterVariation" ReadOnly="True" HeaderText="(4) Total After Adjustments<br/>(1)+(2)+(3)" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" Width="80px" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="TotalBalanceAfterVariationYTD" ReadOnly="True" HeaderText="(5) Total After Adjustments YTD<br/>" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" Width="80px" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="TotalCommittedYTD" ReadOnly="True" HeaderText="(6) Committed YTD<br/>" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" Width="80px" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="TotalCommittedRestOfBudgetPeriod" ReadOnly="True" HeaderText="(7) Committed Rest of Budget Period<br/>" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" Width="80px" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="TotalCommittedAfterCurrentBudgetPeriod" ReadOnly="True"
                                HeaderText="(8) Committed for Future Years<br/>" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" Width="80px" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="PercentageVarianceYTD" ReadOnly="True" HeaderText="(9) % YTD Variance<br/>((5)-(6))/(5) * 100%"
                                DataFormatString="{0:##0.00}">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" Width="80px" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="TotalAvailableBalanceExcludingPendingApprovals" ReadOnly="True"
                                HeaderText="(10) Total Available<br/>(4)-(6)-(7)" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" Width="80px" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="TotalPendingApproval" ReadOnly="True" HeaderText="(11) Total Pending Approval" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" Width="80px" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="TotalAvailableBalance" ReadOnly="True" HeaderText="(12) Total Available After Deducting Pending Approval<br/>(10)-(11)" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" Width="80px" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="TotalPendingApprovalYTD" ReadOnly="True" HeaderText="(11) Current Pending Approval" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" Width="80px" />
                            </ui:uigridviewboundcolumn>
                        </Columns>
                        <HeaderStyle CssClass="grid-header" />
                    </ui:uigridview>
                </ui:UIPanel>
                <ui:UIPanel runat="server" ID="availablePanel" BorderStyle="NotSet" meta:resourcekey="availablePanelResource1">
                    <asp:Label runat="server" ID="availableLabel" Text="MTD Available as at " Font-Bold="True"
                        meta:resourcekey="availableLabelResource1"></asp:Label>
                    <br />
                    <br />
                    <ui:uigridview ID="gridAvailable" runat="server" DataKeyField="AccountID" CssClass="datagrid"
                        BorderColor="#CCCCCC" BorderWidth="1px" CellPadding="1" AutoGenerateColumns="False"
                        Width="100%" meta:resourcekey="gridAvailableResource1" ShowFooter="true" PageSize="1000" ShowCaption="false" AllowSorting="false">
                        <Columns>
                            <ui:uigridviewboundcolumn PropertyName="AccountID" ReadOnly="True"></ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Level" ReadOnly="True"></ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Type" ReadOnly="True"></ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="AccountName" ReadOnly="True" HeaderText="Account">
                                <ItemStyle HorizontalAlign="Left" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewtemplatecolumn HeaderText="Account">
                                <ItemTemplate>
                                    <asp:Label runat="server" ID="lblAccount" meta:resourcekey="lblAccountResource3"></asp:Label>
                                    <asp:HyperLink runat="server" ID="linkAccount" meta:resourcekey="linkAccountResource3"></asp:HyperLink>
                                </ItemTemplate>
                            </ui:uigridviewtemplatecolumn>
                            <ui:uigridviewboundcolumn PropertyName="AccountCode" ReadOnly="True" HeaderText="Account Code">
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="TotalAmount" ReadOnly="True" HeaderText="Total" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval01Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval02Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval03Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval04Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval05Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval06Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval07Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval08Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval09Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval10Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval11Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval12Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval13Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval14Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval15Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval16Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval17Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval18Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval19Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval20Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval21Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval22Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval23Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval24Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval25Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval26Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval27Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval28Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval29Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval30Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval31Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval32Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval33Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval34Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval35Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval36Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                        </Columns>
                        <HeaderStyle CssClass="grid-header" />
                    </ui:uigridview>
                    <br />
                    <br />
                </ui:UIPanel>
                <ui:UIPanel runat="server" ID="monthPanel" BorderStyle="NotSet" meta:resourcekey="monthPanelResource1">
                    <asp:Label runat="server" ID="monthLabel" Text="MTD budget as at " Font-Bold="True"
                        meta:resourcekey="monthLabelResource1"></asp:Label>
                    <br />
                    <br />
                    <ui:uigridview ID="gridMonthView" runat="server" DataKeyField="AccountID" CssClass="datagrid"
                        BorderColor="#CCCCCC" BorderWidth="1px" CellPadding="1" AutoGenerateColumns="False"
                        Width="100%" meta:resourcekey="gridMonthViewResource1" ShowFooter="true" PageSize="1000" ShowCaption="false" AllowSorting="false">
                        <Columns>
                            <ui:uigridviewboundcolumn PropertyName="AccountID" ReadOnly="True"></ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Level" ReadOnly="True"></ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Type" ReadOnly="True"></ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="AccountName" ReadOnly="True" HeaderText="Account">
                                <ItemStyle HorizontalAlign="Left" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewtemplatecolumn HeaderText="Account">
                                <ItemTemplate>
                                    <asp:Label runat="server" ID="lblAccount" meta:resourcekey="lblAccountResource4"></asp:Label>
                                    <asp:HyperLink runat="server" ID="linkAccount" meta:resourcekey="linkAccountResource4"></asp:HyperLink>
                                </ItemTemplate>
                            </ui:uigridviewtemplatecolumn>
                            <ui:uigridviewboundcolumn PropertyName="AccountCode" ReadOnly="True" HeaderText="Account Code">
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="TotalAmount" ReadOnly="True" HeaderText="Total" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval01Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval02Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval03Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval04Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval05Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval06Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval07Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval08Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval09Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval10Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval11Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval12Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval13Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval14Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval15Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval16Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval17Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval18Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval19Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval20Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval21Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval22Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval23Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval24Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval25Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval26Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval27Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval28Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval29Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval30Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval31Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval32Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval33Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval34Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval35Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval36Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                        </Columns>
                        <HeaderStyle CssClass="grid-header" />
                    </ui:uigridview>
                    <br />
                    <br />
                </ui:UIPanel>
                <ui:UIPanel runat="server" ID="reallocatePanel" BorderStyle="NotSet" meta:resourcekey="reallocatePanelResource1">
                    <asp:Label runat="server" ID="reallocateLabel" Text="MTD Reallocated as at " Font-Bold="True"
                        meta:resourcekey="reallocateLabelResource1"></asp:Label>
                    <br />
                    <br />
                    <ui:uigridview ID="gridReallocated" runat="server" DataKeyField="AccountID" CssClass="datagrid"
                        BorderColor="#CCCCCC" BorderWidth="1px" CellPadding="1" AutoGenerateColumns="False"
                        Width="100%" meta:resourcekey="gridReallocatedResource1" ShowFooter="true" PageSize="1000" ShowCaption="false" AllowSorting="false">
                        <Columns>
                            <ui:uigridviewboundcolumn PropertyName="AccountID" ReadOnly="True"></ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Level" ReadOnly="True"></ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Type" ReadOnly="True"></ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="AccountName" ReadOnly="True" HeaderText="Account">
                                <ItemStyle HorizontalAlign="Left" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewtemplatecolumn HeaderText="Account">
                                <ItemTemplate>
                                    <asp:Label runat="server" ID="lblAccount" meta:resourcekey="lblAccountResource5"></asp:Label>
                                    <asp:HyperLink runat="server" ID="linkAccount" meta:resourcekey="linkAccountResource5"></asp:HyperLink>
                                </ItemTemplate>
                            </ui:uigridviewtemplatecolumn>
                            <ui:uigridviewboundcolumn PropertyName="AccountCode" ReadOnly="True" HeaderText="Account Code">
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="TotalAmount" ReadOnly="True" HeaderText="Total" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval01Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval02Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval03Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval04Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval05Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval06Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval07Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval08Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval09Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval10Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval11Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval12Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval13Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval14Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval15Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval16Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval17Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval18Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval19Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval20Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval21Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval22Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval23Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval24Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval25Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval26Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval27Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval28Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval29Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval30Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval31Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval32Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval33Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval34Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval35Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval36Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                        </Columns>
                        <HeaderStyle CssClass="grid-header" />
                    </ui:uigridview>
                    <br />
                    <br />
                    <ui:uigridview ID="gridReallocationDetails" runat="server" DataKeyField="AccountID"
                        CssClass="datagrid" BorderColor="#CCCCCC" BorderWidth="1px" CellPadding="1" AutoGenerateColumns="False"
                        Width="100%" OnRowDataBound="gridReallocationDetails_RowDataBound" meta:resourcekey="gridReallocationDetailsResource1"
                        ShowFooter="true" PageSize="1000" ShowCaption="false" AllowSorting="false">
                        <Columns>
                            <ui:uigridviewboundcolumn PropertyName="ReallocateNumber" ReadOnly="True" HeaderText="Adjustment Number">
                                <ItemStyle Width="200px" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="AccountName" ReadOnly="True" HeaderText="Account">
                                <ItemStyle HorizontalAlign="Left" VerticalAlign="Middle" Width="500px" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="AccountCode" ReadOnly="True" HeaderText="Account Code">
                                <ItemStyle Width="200px" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Month" ReadOnly="True" HeaderText="Month">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Amount" ReadOnly="True" HeaderText="Amount" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                        </Columns>
                        <HeaderStyle CssClass="grid-header" />
                    </ui:uigridview>
                    <br />
                    <br />
                </ui:UIPanel>
                <ui:UIPanel runat="server" ID="adjustedPanel" BorderStyle="NotSet" meta:resourcekey="adjustedPanelResource1">
                    <asp:Label runat="server" ID="adjustedLabel" Text="MTD Adjusted as at " Font-Bold="True"
                        meta:resourcekey="adjustedLabelResource1"></asp:Label>
                    <br />
                    <br />
                    <ui:uigridview ID="gridAdjusted" runat="server" DataKeyField="AccountID" CssClass="datagrid"
                        BorderColor="#CCCCCC" BorderWidth="1px" CellPadding="1" AutoGenerateColumns="False"
                        Width="100%" meta:resourcekey="gridAdjustedResource1" ShowFooter="true" PageSize="1000" ShowCaption="false" AllowSorting="false">
                        <Columns>
                            <ui:uigridviewboundcolumn PropertyName="AccountID" ReadOnly="True"></ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Level" ReadOnly="True"></ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Type" ReadOnly="True"></ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="AccountName" ReadOnly="True" HeaderText="Account">
                                <ItemStyle HorizontalAlign="Left" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewtemplatecolumn HeaderText="Account">
                                <ItemTemplate>
                                    <asp:Label runat="server" ID="lblAccount" meta:resourcekey="lblAccountResource6"></asp:Label>
                                    <asp:HyperLink runat="server" ID="linkAccount" meta:resourcekey="linkAccountResource6"></asp:HyperLink>
                                </ItemTemplate>
                            </ui:uigridviewtemplatecolumn>
                            <ui:uigridviewboundcolumn PropertyName="AccountCode" ReadOnly="True" HeaderText="Account Code">
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="TotalAmount" ReadOnly="True" HeaderText="Total" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval01Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval02Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval03Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval04Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval05Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval06Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval07Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval08Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval09Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval10Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval11Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval12Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval13Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval14Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval15Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval16Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval17Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval18Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval19Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval20Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval21Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval22Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval23Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval24Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval25Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval26Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval27Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval28Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval29Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval30Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval31Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval32Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval33Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval34Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval35Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval36Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                        </Columns>
                        <HeaderStyle CssClass="grid-header" />
                    </ui:uigridview>
                    <br />
                    <ui:uigridview ID="gridAdjustmentDetails" runat="server" DataKeyField="AccountID"
                        CssClass="datagrid" BorderColor="#CCCCCC" BorderWidth="1px" CellPadding="1" AutoGenerateColumns="False"
                        Width="100%" meta:resourcekey="gridAdjustmentDetailsResource1" ShowFooter="true" PageSize="1000" ShowCaption="false" AllowSorting="false">
                        <Columns>
                            <ui:uigridviewboundcolumn PropertyName="AdjustNumber" ReadOnly="True" HeaderText="Adjustment Number">
                                <ItemStyle Width="200px" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="AccountName" ReadOnly="True" HeaderText="Account">
                                <ItemStyle HorizontalAlign="Left" VerticalAlign="Middle" Width="500px" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="AccountCode" ReadOnly="True" HeaderText="Account Code">
                                <ItemStyle Width="200px" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Month" ReadOnly="True" HeaderText="Month">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Amount" ReadOnly="True" HeaderText="Amount" DataFormatString="{0:#,##0.00}">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                        </Columns>
                        <HeaderStyle CssClass="grid-header" />
                    </ui:uigridview>
                </ui:UIPanel>
                <ui:UIPanel runat="server" ID="pendingPanel" BorderStyle="NotSet" meta:resourcekey="pendingPanelResource1">
                    <asp:Label runat="server" ID="pendingLabel" Text="MTD Pending Approval as at " Font-Bold="True"
                        meta:resourcekey="pendingLabelResource1"></asp:Label>
                    <br />
                    <br />
                    <ui:uigridview ID="gridPendingApproval" runat="server" DataKeyField="AccountID" CssClass="datagrid"
                        BorderColor="#CCCCCC" BorderWidth="1px" CellPadding="1" AutoGenerateColumns="False"
                        Width="100%" meta:resourcekey="gridPendingApprovalResource1" ShowFooter="true" PageSize="1000" ShowCaption="false" AllowSorting="false">
                        <Columns>
                            <ui:uigridviewboundcolumn PropertyName="AccountID" ReadOnly="True"></ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Level" ReadOnly="True"></ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Type" ReadOnly="True"></ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="AccountName" ReadOnly="True" HeaderText="Account">
                                <ItemStyle HorizontalAlign="Left" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewtemplatecolumn HeaderText="Account">
                                <ItemTemplate>
                                    <asp:Label runat="server" ID="lblAccount" meta:resourcekey="lblAccountResource7"></asp:Label>
                                    <asp:HyperLink runat="server" ID="linkAccount" meta:resourcekey="linkAccountResource7"></asp:HyperLink>
                                </ItemTemplate>
                            </ui:uigridviewtemplatecolumn>
                            <ui:uigridviewboundcolumn PropertyName="AccountCode" ReadOnly="True" HeaderText="Account Code">
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="TotalAmount" ReadOnly="True" HeaderText="Total" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval01Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval02Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval03Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval04Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval05Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval06Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval07Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval08Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval09Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval10Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval11Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval12Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval13Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval14Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval15Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval16Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval17Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval18Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval19Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval20Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval21Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval22Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval23Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval24Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval25Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval26Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval27Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval28Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval29Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval30Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval31Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval32Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval33Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval34Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval35Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval36Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                        </Columns>
                        <HeaderStyle CssClass="grid-header" />
                    </ui:uigridview>
                    <br />
                    <br />
                </ui:UIPanel>
                <ui:UIPanel runat="server" ID="approvePanel" BorderStyle="NotSet" meta:resourcekey="approvePanelResource1">
                    <asp:Label runat="server" ID="approveLabel" Text="MTD Approved as at " Font-Bold="True"
                        meta:resourcekey="approveLabelResource1"></asp:Label>
                    <br />
                    <br />
                    <ui:uigridview ID="gridApproved" runat="server" DataKeyField="AccountID" CssClass="datagrid"
                        BorderColor="#CCCCCC" BorderWidth="1px" CellPadding="1" AutoGenerateColumns="False"
                        Width="100%" meta:resourcekey="gridApprovedResource1" ShowFooter="true" PageSize="1000" ShowCaption="false" AllowSorting="false">
                        <Columns>
                            <ui:uigridviewboundcolumn PropertyName="AccountID" ReadOnly="True"></ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Level" ReadOnly="True"></ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Type" ReadOnly="True"></ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="AccountName" ReadOnly="True" HeaderText="Account">
                                <ItemStyle HorizontalAlign="Left" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewtemplatecolumn HeaderText="Account">
                                <ItemTemplate>
                                    <asp:Label runat="server" ID="lblAccount" meta:resourcekey="lblAccountResource8"></asp:Label>
                                    <asp:HyperLink runat="server" ID="linkAccount" meta:resourcekey="linkAccountResource8"></asp:HyperLink>
                                </ItemTemplate>
                            </ui:uigridviewtemplatecolumn>
                            <ui:uigridviewboundcolumn PropertyName="AccountCode" ReadOnly="True" HeaderText="Account Code">
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="TotalAmount" ReadOnly="True" HeaderText="Total" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval01Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval02Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval03Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval04Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval05Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval06Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval07Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval08Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval09Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval10Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval11Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval12Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval13Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval14Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval15Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval16Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval17Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval18Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval19Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval20Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval21Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval22Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval23Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval24Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval25Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval26Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval27Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval28Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval29Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval30Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval31Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval32Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval33Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval34Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval35Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval36Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                        </Columns>
                        <HeaderStyle CssClass="grid-header" />
                    </ui:uigridview>
                    <br />
                    <br />
                </ui:UIPanel>
                <ui:UIPanel runat="server" ID="expensePendingApprovalPanel" BorderStyle="NotSet"
                    meta:resourcekey="expensePendingApprovalPanelResource1">
                    <asp:Label runat="server" ID="expensePendingApprovalLabel" Text="MTD Direct Invoices (Pending Approval) as at "
                        Font-Bold="True" meta:resourcekey="expensePendingApprovalLabelResource1"></asp:Label>
                    <br />
                    <br />
                    <ui:uigridview ID="gridExpensedPendingApproval" runat="server" DataKeyField="AccountID"
                        CssClass="datagrid" BorderColor="#CCCCCC" BorderWidth="1px" CellPadding="1" AutoGenerateColumns="False"
                        Width="100%" meta:resourcekey="gridExpensedPendingApprovalResource1"
                        ShowFooter="true" PageSize="1000" ShowCaption="false" AllowSorting="false">
                        <Columns>
                            <ui:uigridviewboundcolumn PropertyName="AccountID" ReadOnly="True"></ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Level" ReadOnly="True"></ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Type" ReadOnly="True"></ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="AccountName" ReadOnly="True" HeaderText="Account">
                                <ItemStyle HorizontalAlign="Left" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewtemplatecolumn HeaderText="Account">
                                <ItemTemplate>
                                    <asp:Label runat="server" ID="lblAccount" meta:resourcekey="lblAccountResource9"></asp:Label>
                                    <asp:HyperLink runat="server" ID="linkAccount" meta:resourcekey="linkAccountResource9"></asp:HyperLink>
                                </ItemTemplate>
                            </ui:uigridviewtemplatecolumn>
                            <ui:uigridviewboundcolumn PropertyName="AccountCode" ReadOnly="True" HeaderText="Account Code">
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="TotalAmount" ReadOnly="True" HeaderText="Total" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval01Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval02Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval03Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval04Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval05Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval06Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval07Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval08Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval09Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval10Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval11Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval12Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval13Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval14Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval15Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval16Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval17Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval18Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval19Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval20Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval21Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval22Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval23Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval24Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval25Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval26Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval27Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval28Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval29Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval30Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval31Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval32Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval33Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval34Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval35Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval36Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                        </Columns>
                        <HeaderStyle CssClass="grid-header" />
                    </ui:uigridview>
                    <br />
                    <br />
                </ui:UIPanel>
                <ui:UIPanel runat="server" ID="expensePanel" BorderStyle="NotSet" meta:resourcekey="expensePanelResource1">
                    <asp:Label runat="server" ID="expenseLabel" Text="MTD Direct Invoices (Pending Approval) as at "
                        Font-Bold="True" meta:resourcekey="expenseLabelResource1"></asp:Label>
                    <br />
                    <br />
                    <ui:uigridview ID="gridExpensed" runat="server" DataKeyField="AccountID" CssClass="datagrid"
                        BorderColor="#CCCCCC" BorderWidth="1px" CellPadding="1" AutoGenerateColumns="False"
                        Width="100%" meta:resourcekey="gridExpensedResource1"
                        ShowFooter="true" PageSize="1000" ShowCaption="false" AllowSorting="false">
                        <Columns>
                            <ui:uigridviewboundcolumn PropertyName="AccountID" ReadOnly="True"></ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Level" ReadOnly="True"></ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Type" ReadOnly="True"></ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="AccountName" ReadOnly="True" HeaderText="Account">
                                <ItemStyle HorizontalAlign="Left" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewtemplatecolumn HeaderText="Account">
                                <ItemTemplate>
                                    <asp:Label runat="server" ID="lblAccount" meta:resourcekey="lblAccountResource10"></asp:Label>
                                    <asp:HyperLink runat="server" ID="linkAccount" meta:resourcekey="linkAccountResource10"></asp:HyperLink>
                                </ItemTemplate>
                            </ui:uigridviewtemplatecolumn>
                            <ui:uigridviewboundcolumn PropertyName="AccountCode" ReadOnly="True" HeaderText="Account Code">
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="TotalAmount" ReadOnly="True" HeaderText="Total" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval01Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval02Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval03Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval04Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval05Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval06Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval07Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval08Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval09Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval10Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval11Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval12Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval13Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval14Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval15Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval16Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval17Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval18Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval19Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval20Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval21Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval22Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval23Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval24Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval25Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval26Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval27Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval28Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval29Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval30Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval31Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval32Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval33Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval34Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval35Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval36Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                        </Columns>
                        <HeaderStyle CssClass="grid-header" />
                    </ui:uigridview>
                    <br />
                    <br />
                </ui:UIPanel>
                <ui:UIPanel runat="server" ID="invoicedPanel" BorderStyle="NotSet" meta:resourcekey="invoicedPanelResource1">
                    <asp:Label runat="server" ID="invoicedLabel" Text="MTD PO Invoiced as at " Font-Bold="True"
                        meta:resourcekey="invoicedLabelResource1"></asp:Label>
                    <br />
                    <br />
                    <ui:uigridview ID="gridInvoiced" runat="server" DataKeyField="AccountID" CssClass="datagrid"
                        BorderColor="#CCCCCC" BorderWidth="1px" CellPadding="1" AutoGenerateColumns="False"
                        Width="100%" meta:resourcekey="gridInvoicedResource1"
                        ShowFooter="true" PageSize="1000" ShowCaption="false" AllowSorting="false">
                        <Columns>
                            <ui:uigridviewboundcolumn PropertyName="AccountID" ReadOnly="True"></ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Level" ReadOnly="True"></ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Type" ReadOnly="True"></ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="AccountName" ReadOnly="True" HeaderText="Account">
                                <ItemStyle HorizontalAlign="Left" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewtemplatecolumn HeaderText="Account">
                                <ItemTemplate>
                                    <asp:Label runat="server" ID="lblAccount" meta:resourcekey="lblAccountResource11"></asp:Label>
                                    <asp:HyperLink runat="server" ID="linkAccount" meta:resourcekey="linkAccountResource11"></asp:HyperLink>
                                </ItemTemplate>
                            </ui:uigridviewtemplatecolumn>
                            <ui:uigridviewboundcolumn PropertyName="AccountCode" ReadOnly="True" HeaderText="Account Code">
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="TotalAmount" ReadOnly="True" HeaderText="Total" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval01Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval02Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval03Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval04Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval05Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval06Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval07Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval08Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval09Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval10Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval11Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval12Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval13Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval14Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval15Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval16Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval17Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval18Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval19Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval20Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval21Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval22Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval23Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval24Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval25Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval26Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval27Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval28Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval29Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval30Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval31Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval32Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval33Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval34Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval35Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Interval36Amount" ReadOnly="True">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                        </Columns>
                        <HeaderStyle CssClass="grid-header" />
                    </ui:uigridview>
                    <br />
                    <br />
                </ui:UIPanel>
                <ui:UIPanel runat="server" ID="paymentPanel" BorderStyle="NotSet" meta:resourcekey="paymentPanelResource1">
                    <asp:Label runat="server" ID="paymentLabel" Text="MTD Payment as at " Font-Bold="True"
                        meta:resourcekey="paymentLabelResource1"></asp:Label>
                    <br />
                    <br />
                    <ui:uigridview ID="gridPayment" runat="server" DataKeyField="AccountID" CssClass="datagrid"
                        BorderColor="#CCCCCC" BorderWidth="1px" CellPadding="1" AutoGenerateColumns="False"
                        Width="100%" meta:resourcekey="gridPaymentResource1"
                        ShowFooter="true" PageSize="1000" ShowCaption="false" AllowSorting="false">
                        <Columns>
                            <ui:uigridviewboundcolumn PropertyName="AccountID" ReadOnly="True"></ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="LevelOfBudgetCategory" ReadOnly="True">
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="CategoryType" ReadOnly="True"></ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="BudgetCategoryName" ReadOnly="True" HeaderText="Account">
                                <ItemStyle HorizontalAlign="Left" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="FinanceCode" ReadOnly="True" HeaderText="Finance Code">
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Payment" ReadOnly="True" HeaderText="(8) Total Paid by Finance" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Month01Amount" ReadOnly="True" HeaderText="Jan" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Month02Amount" ReadOnly="True" HeaderText="Feb" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Month03Amount" ReadOnly="True" HeaderText="Mar" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Month04Amount" ReadOnly="True" HeaderText="Apr" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Month05Amount" ReadOnly="True" HeaderText="May" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Month06Amount" ReadOnly="True" HeaderText="Jun" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Month07Amount" ReadOnly="True" HeaderText="Jul" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Month08Amount" ReadOnly="True" HeaderText="Aug" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Month09Amount" ReadOnly="True" HeaderText="Sep" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Month10Amount" ReadOnly="True" HeaderText="Oct" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Month11Amount" ReadOnly="True" HeaderText="Nov" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                            <ui:uigridviewboundcolumn PropertyName="Month12Amount" ReadOnly="True" HeaderText="Dec" FooterAggregate="Sum">
                                <HeaderStyle HorizontalAlign="Right" /><FooterStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" />
                            </ui:uigridviewboundcolumn>
                        </Columns>
                        <HeaderStyle CssClass="grid-header" />
                    </ui:uigridview>
                    <br />
                    <br />
                </ui:UIPanel>
            </div>
        </div>
    </ui:UIPanel>
    </form>
</body>
</html>
