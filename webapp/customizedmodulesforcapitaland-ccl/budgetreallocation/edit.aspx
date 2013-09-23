<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Register Assembly="Anacle.UIFramework" Namespace="Anacle.UIFramework" TagPrefix="cc1" %>

<script runat="server">

    /// <summary>
    /// Populates the form.
    /// Action:  1. bind data into the Budget combo
    ///          2. bind data into the AuthorizedPerson combo
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_OnPopulateForm(object sender, EventArgs e)
    {
        OBudgetReallocation budgetReallocation = panel.SessionObject as OBudgetReallocation;

        dropFromBudget.Bind(OBudget.GetAccessibleBugets(AppSession.User, budgetReallocation.FromBudgetID, "OBudgetReallocation"));
        dropFromBudgetPeriod.Bind(OBudgetPeriod.GetOpenBudgetPeriodsByBudgetID(budgetReallocation.FromBudgetID, budgetReallocation.FromBudgetPeriodID));

        dropToBudget.Bind(OBudget.GetAccessibleBugets(AppSession.User, budgetReallocation.ToBudgetID, "OBudgetReallocation"));
        dropToBudgetPeriod.Bind(OBudgetPeriod.GetOpenBudgetPeriodsByBudgetID(budgetReallocation.ToBudgetID, budgetReallocation.ToBudgetPeriodID));

        if (budgetReallocation.BudgetReallocationFroms.Count > 0)
        {
            InitializeFromGrid();
            if (objectBase.CurrentObjectState.Is("Start", "Draft", "PendingApproval", "RejectedforRework"))
                budgetReallocation.ComputeFromBudgetSummary();
        }
        if (budgetReallocation.BudgetReallocationTos.Count > 0)
        {
            InitializeToGrid();
            if (objectBase.CurrentObjectState.Is("Start", "Draft", "PendingApproval", "RejectedforRework"))
                budgetReallocation.ComputeToBudgetSummary();
        }

        panel.ObjectPanel.BindObjectToControls(budgetReallocation);

        treeAccountFrom.PopulateTree();
        treeAccountTo.PopulateTree();

    }

    /// <summary>
    /// Hides/shows elements.
    /// Check if item exists at the budget adjustment detail grid:
    ///     if No : enable the location tree view and the budget drop down list.
    ///     if Yes: disable them.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        OBudgetReallocation reallocate = (OBudgetReallocation)panel.SessionObject;

        objectBase.ObjectNumberVisible = !reallocate.IsNew;

        dropFromBudget.Enabled = (reallocate.BudgetReallocationFroms.Count == 0);
        dropFromBudgetPeriod.Enabled = (reallocate.BudgetReallocationFroms.Count == 0);

        dropToBudget.Enabled = (reallocate.BudgetReallocationTos.Count == 0);
        dropToBudgetPeriod.Enabled = (reallocate.BudgetReallocationTos.Count == 0);
        //dropToBudget.Enabled = false;
        //dropToBudgetPeriod.Enabled = false;

        treeAccountFrom.Visible = dropFromBudget.SelectedIndex > 0 && dropFromBudgetPeriod.SelectedIndex > 0;
        gridReallocateFrom.Visible = dropFromBudget.SelectedIndex > 0 && dropFromBudgetPeriod.SelectedIndex > 0;

        treeAccountTo.Visible = dropToBudget.SelectedIndex > 0 && dropToBudgetPeriod.SelectedIndex > 0;
        treeAccountTo.PopulateTree();
        gridReallocateTo.Visible = dropToBudget.SelectedIndex > 0 && dropToBudgetPeriod.SelectedIndex > 0;

        panelReallocateFrom.Enabled = objectBase.CurrentObjectState.Is("Start", "Draft", "RejectedforRework");
        textAdjustmentDescription.Enabled = objectBase.CurrentObjectState.Is("Start", "Draft", "RejectedforRework");
        panelReallocateTo.Enabled = objectBase.CurrentObjectState.Is("Start", "Draft", "RejectedforRework");

        //gridReallocateFromSummary.Visible = !objectBase.CurrentObjectState.Is("Committed", "Cancelled");
        //gridReallocateToSummary.Visible = !objectBase.CurrentObjectState.Is("Committed", "Cancelled");
        bool vis = !objectBase.CurrentObjectState.Is("Committed", "Cancelled");
        gridReallocateFrom.Columns[3].Visible =
            gridReallocateFrom.Columns[4].Visible =
            gridReallocateFrom.Columns[5].Visible =
            gridReallocateFrom.Columns[6].Visible =
            gridReallocateFrom.Columns[7].Visible =
            gridReallocateFrom.Columns[8].Visible =
            gridReallocateFrom.Columns[9].Visible =
            gridReallocateFrom.Columns[10].Visible =
            gridReallocateFrom.Columns[11].Visible = vis;
        gridReallocateTo.Columns[3].Visible =
            gridReallocateTo.Columns[4].Visible =
            gridReallocateTo.Columns[5].Visible =
            gridReallocateTo.Columns[6].Visible =
            gridReallocateTo.Columns[7].Visible =
            gridReallocateTo.Columns[8].Visible =
            gridReallocateTo.Columns[9].Visible =
            gridReallocateTo.Columns[10].Visible =
            gridReallocateTo.Columns[11].Visible = vis;

        panel.SpellCheckButtonVisible =
            reallocate.CurrentActivity == null ||
            reallocate.CurrentActivity.ObjectName.Is("Start", "Draft");
    }

    /// <summary>
    /// Validates and saves the budget reallocation object into the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OBudgetReallocation reallocate = panel.SessionObject as OBudgetReallocation;
            panel.ObjectPanel.BindControlsToObject(reallocate);

            // Validate
            //
            if (objectBase.SelectedAction.Is("SubmitForApproval", "Approve"))
            {
                if (!reallocate.IsEqualReallocateAmount())
                {
                    string errorMessage = String.Format(
                            Resources.Errors.BudgetReallocation_CheckTotalAmountItemsFromEqualTotalAmountItemsTo,
                            reallocate.TotalFromBudgetAmount, reallocate.TotalToBudgetAmount);

                    gridReallocateFrom.ErrorMessage = errorMessage;
                    gridReallocateTo.ErrorMessage = errorMessage;
                }

                string accounts = reallocate.CheckSufficientAvailableAmount();
                if (accounts != "")
                {
                    string errorMessage = String.Format(
                        Resources.Errors.BudgetReallocation_InsufficientAmount, accounts);
                    gridReallocateFrom.ErrorMessage = errorMessage;
                    gridReallocateTo.ErrorMessage = errorMessage;

                }
            }
            if (objectBase.SelectedAction == "SubmitForApproval")
            {
                string acrossGroups = reallocate.ValidateReallocationAcrossGroups();
                if (acrossGroups != "")
                {
                    gridReallocateTo.ErrorMessage = gridReallocateFrom.ErrorMessage = acrossGroups;
                    return;
                }
                if (!panel.ObjectPanel.IsValid)
                    return;
            }

            //List<Guid?> lstSubCategoryFrom = new List<Guid?>();
            //int mainCategoryFrom;
            //foreach (OBudgetReallocationFrom brFrom in reallocate.BudgetReallocationFroms)
            //{

            //    List<OAccount> lstAcc = TablesLogic.tAccount.LoadList(brFrom.HierarchyPath.Like(TablesLogic.tAccount.HierarchyPath + "%"));
            //    if (lstAcc.Find(lf => lf.ObjectName == OBudgetReallocation.EnumBudgetReallocationMainCategory.Capex.ToString()) != null)
            //        mainCategoryFrom = (int)OBudgetReallocation.EnumBudgetReallocationMainCategory.Capex;
            //    else
            //        mainCategoryFrom = (int)OBudgetReallocation.EnumBudgetReallocationMainCategory.NonCapex;
            //    if (!lstSubCategoryFrom.Contains(brFrom.Account.SubCategoryID))
            //        lstSubCategoryFrom.Add(brFrom.Account.SubCategoryID);
            //}
            //List<Guid?> lstSubCategoryTo = new List<Guid?>();
            //int mainCategoryTo;
            //foreach (OBudgetReallocationTo brTo in reallocate.BudgetReallocationTos)
            //{
            //    List<OAccount> lstAcc = TablesLogic.tAccount.LoadList(("%" + TablesLogic.tAccount.HierarchyPath).Like(brTo.HierarchyPath));
            //    if (lstAcc.Find(lf => lf.ObjectName == OBudgetReallocation.EnumBudgetReallocationMainCategory.Capex.ToString()) != null)
            //        mainCategoryTo = (int)OBudgetReallocation.EnumBudgetReallocationMainCategory.Capex;
            //    else
            //        mainCategoryTo = (int)OBudgetReallocation.EnumBudgetReallocationMainCategory.NonCapex;
            //    if (!lstSubCategoryTo.Contains(brTo.Account.SubCategoryID))
            //        lstSubCategoryTo.Add(brTo.Account.SubCategoryID);
            //}

            //if (lstSubCategoryFrom.Count() != 1)
            //{
            //    gridReallocateFrom.ErrorMessage = Resources.Errors.BudgetReallocation_InvalidNumberOfSubCategory;
            //}
            //if (lstSubCategoryTo.Count() != 1)
            //{
            //    gridReallocateTo.ErrorMessage = Resources.Errors.BudgetReallocation_InvalidNumberOfSubCategory;
            //}

            //if (isCapexFrom != isCapexTo)
            //{
            //    gridReallocateFrom.ErrorMessage = gridReallocateTo.ErrorMessage = Resources.Errors.BudgetReallocation_InvalidMainCategory;
            //}
            //else if (isCapexFrom == true)
            //    reallocate.

            if (reallocate.BudgetReallocationTos[0].Account.SubCategoryID ==
                    reallocate.BudgetReallocationFroms[0].Account.SubCategoryID)
                reallocate.BudgetReallocationType = (int)OBudgetReallocation.EnumBudgetReallocationType.WithinSubCategory;
            else
                reallocate.BudgetReallocationType = (int)OBudgetReallocation.EnumBudgetReallocationType.BetweenSubCategory;

            // Save
            //
            reallocate.Save();
            c.Commit();
        }
    }

    /// <summary>
    /// Initializes the opening balance GridView to show the
    /// correct number of columns, and correct header texts.
    /// </summary>
    protected void InitializeFromGrid()
    {
        /*
        OBudgetReallocation budgetReallocation = panel.SessionObject as OBudgetReallocation;

        if (budgetReallocation.FromBudgetPeriod != null)
        {
            int numberOfMonthsPerInterval = budgetReallocation.FromBudgetPeriod.NumberOfMonthsPerInterval.Value;
            int numberOfIntervals = budgetReallocation.FromBudgetPeriod.TotalNumberOfIntervals;

            DateTime startDate = budgetReallocation.FromBudgetPeriod.StartDate.Value;
            for (int i = 0; i < 36; i++)
            {
                if (i < numberOfIntervals)
                {
                    DateTime intervalStartDate = startDate.AddMonths(i);
                    this.gridReallocateFrom.Columns[i + 2].Visible = true;
                    if (intervalStartDate.Day == 1)
                        gridReallocateFrom.Columns[i + 2].HeaderText =
                            startDate.AddMonths(i * numberOfMonthsPerInterval).ToString("MMM-yyyy");
                    else
                        gridReallocateFrom.Columns[i + 2].HeaderText =
                            startDate.AddMonths(i * numberOfMonthsPerInterval).ToString("dd-MMM-yyyy");
                }
                else
                    gridReallocateFrom.Columns[i + 2].Visible = false;
            }
        }*/

    }

    /// <summary>
    /// Initializes the opening balance GridView to show the
    /// correct number of columns, and correct header texts.
    /// </summary>
    protected void InitializeToGrid()
    {
        /*
        OBudgetReallocation budgetReallocation = panel.SessionObject as OBudgetReallocation;

        if (budgetReallocation.ToBudgetPeriod != null)
        {
            int numberOfMonthsPerInterval = budgetReallocation.ToBudgetPeriod.NumberOfMonthsPerInterval.Value;
            int numberOfIntervals = budgetReallocation.ToBudgetPeriod.TotalNumberOfIntervals;

            DateTime startDate = budgetReallocation.ToBudgetPeriod.StartDate.Value;
            for (int i = 0; i < 36; i++)
            {
                if (i < numberOfIntervals)
                {
                    DateTime intervalStartDate = startDate.AddMonths(i);
                    this.gridReallocateTo.Columns[i + 2].Visible = true;
                    if (intervalStartDate.Day == 1)
                        gridReallocateTo.Columns[i + 2].HeaderText =
                            startDate.AddMonths(i * numberOfMonthsPerInterval).ToString("MMM-yyyy");
                    else
                        gridReallocateTo.Columns[i + 2].HeaderText =
                            startDate.AddMonths(i * numberOfMonthsPerInterval).ToString("dd-MMM-yyyy");
                }
                else
                    gridReallocateTo.Columns[i + 2].Visible = false;
            }

        }
         * */
    }

    /// <summary>
    /// Occurs when the user selects an item in the From Budget
    /// dropdown list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropFromBudget_SelectedIndexChanged(object sender, EventArgs e)
    {
        Guid? budgetId = null;
        if (dropFromBudget.SelectedValue != "")
            budgetId = new Guid(dropFromBudget.SelectedValue);

        dropFromBudgetPeriod.Bind(OBudgetPeriod.GetOpenBudgetPeriodsByBudgetID(budgetId, null));

        // 2010.05.24
        // Kim Foong
        // Automatically selects the To Budget.
        //
        dropToBudget.SelectedValue = dropFromBudget.SelectedValue;
        dropToBudgetPeriod.Bind(OBudgetPeriod.GetOpenBudgetPeriodsByBudgetID(budgetId, null));

    }

    /// <summary>
    /// Occurs when the user selects an item in the To Budget
    /// dropdown list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropToBudget_SelectedIndexChanged(object sender, EventArgs e)
    {
        Guid? budgetId = null;
        if (dropToBudget.SelectedValue != "")
            budgetId = new Guid(dropToBudget.SelectedValue);

        dropToBudgetPeriod.Bind(OBudgetPeriod.GetOpenBudgetPeriodsByBudgetID(budgetId, null));
    }

    /// <summary>
    /// Constructs and returns the account tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeAccountFrom_AcquireTreePopulater(object sender)
    {
        if (dropFromBudgetPeriod.SelectedValue == "")
            return null;

        return new AccountTreePopulater(null, false, true, new Guid(dropFromBudgetPeriod.SelectedValue));
    }

    /// <summary>
    /// Constructs and returns the account tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeAccountTo_AcquireTreePopulater(object sender)
    {
        if (locationToModel.SelectedValue == "0" && dropFromBudgetPeriod.SelectedValue != "")
            return new AccountTreePopulater(null, false, true, new Guid(dropFromBudgetPeriod.SelectedValue));
        else
            return new AccountTreePopulater(null, false, true);
    }

    /// <summary>
    /// Occurs when the user selects a node in the account tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void treeAccountFrom_SelectedNodeChanged(object sender, EventArgs e)
    {
        if (treeAccountFrom.SelectedValue != "")
        {
            Guid accountId = new Guid(treeAccountFrom.SelectedValue);

            OBudgetReallocation budgetReallocation = panel.SessionObject as OBudgetReallocation;
            panel.ObjectPanel.BindControlsToObject(budgetReallocation);

            OAccount fromAcc = TablesLogic.tAccount.Load(accountId);
            if (budgetReallocation.ValidateFromAccountIdDoesNotExist(accountId))
            {
                if (budgetReallocation.BudgetReallocationFroms.Count == 0 || budgetReallocation.BudgetReallocationFroms[0].Account.SubCategoryID == fromAcc.SubCategoryID)
                {
                    OBudgetReallocationFrom from = TablesLogic.tBudgetReallocationFrom.Create();
                    from.AccountID = accountId;
                    budgetReallocation.BudgetReallocationFroms.Add(from);
                    List<OApprovalProcess> lstApp = OApprovalProcess.GetApprovalProcessesRegardlessOfFLEECondition(budgetReallocation);
                    if (lstApp.Count == 0 && budgetReallocation.BudgetReallocationTos.Count > 0)
                    {
                        panel.Message = Resources.Errors.BudgetReallocation_InvalidCapexToOpex;
                        budgetReallocation.BudgetReallocationFroms.Remove(from);
                    }
                    else
                    {
                        if (gridReallocateFrom.Rows.Count == 0)
                            InitializeFromGrid();

                        if (objectBase.CurrentObjectState.Is("Start", "Draft", "RejectedforRework"))
                            budgetReallocation.ComputeFromBudgetSummary();

                        panel.ObjectPanel.BindObjectToControls(budgetReallocation);
                        panel.Message = "";
                    }
                }
                else
                    panel.Message = Resources.Errors.BudgetReallocation_InvalidNumberOfSubCategory;
            }
            else
                panel.Message = Resources.Errors.BudgetPeriod_UnableToAddDuplicateAccount;

            treeAccountFrom.SelectedValue = "";
        }
    }

    /// <summary>
    /// Occurs when the user selects a node in the account tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void treeAccountTo_SelectedNodeChanged(object sender, EventArgs e)
    {
        if (treeAccountTo.SelectedValue != "")
        {
            Guid accountId = new Guid(treeAccountTo.SelectedValue);

            OBudgetReallocation budgetReallocation = panel.SessionObject as OBudgetReallocation;
            panel.ObjectPanel.BindControlsToObject(budgetReallocation);

            OAccount toAcc = TablesLogic.tAccount.Load(accountId);
            if (budgetReallocation.ValidateToAccountIdDoesNotExist(accountId))
            {
                if (budgetReallocation.BudgetReallocationTos.Count == 0 || budgetReallocation.BudgetReallocationTos[0].Account.SubCategoryID == toAcc.SubCategoryID)
                {
                    OBudgetReallocationTo to = TablesLogic.tBudgetReallocationTo.Create();
                    to.AccountID = accountId;
                    budgetReallocation.BudgetReallocationTos.Add(to);
                    List<OApprovalProcess> lstApp = OApprovalProcess.GetApprovalProcessesRegardlessOfFLEECondition(budgetReallocation);
                    if (lstApp.Count == 0 && budgetReallocation.BudgetReallocationFroms.Count > 0)
                    {
                        panel.Message = Resources.Errors.BudgetReallocation_InvalidCapexToOpex;
                        budgetReallocation.BudgetReallocationTos.Remove(to);
                    }
                    else
                    {
                        if (gridReallocateTo.Rows.Count == 0)
                            InitializeToGrid();

                        if (objectBase.CurrentObjectState.Is("Start", "Draft", "RejectedforRework"))
                            budgetReallocation.ComputeToBudgetSummary();

                        panel.ObjectPanel.BindObjectToControls(budgetReallocation);
                        panel.Message = "";
                    }
                }
                else
                    panel.Message = Resources.Errors.BudgetReallocation_InvalidNumberOfSubCategory;
            }
            else
                panel.Message = Resources.Errors.BudgetPeriod_UnableToAddDuplicateAccount;

            treeAccountTo.SelectedValue = "";
        }
    }

    /// <summary>
    /// Occurs when the user selects an item in the From Budget Period
    /// dropdown list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropFromBudgetPeriod_SelectedIndexChanged(object sender, EventArgs e)
    {
        treeAccountFrom.PopulateTree();

        // 2010.05.24
        // Kim Foong
        // Automatically selects the To Budget Period, and automatcally populates
        // the Account To tree.
        dropToBudgetPeriod.SelectedValue = dropFromBudgetPeriod.SelectedValue;
        treeAccountTo.PopulateTree();
    }

    /// <summary>
    /// Occurs when the user selects an item in the To Budget Period
    /// dropdown list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropToBudgetPeriod_SelectedIndexChanged(object sender, EventArgs e)
    {

    }

    int numberOfColumns;

    /// <summary>
    /// Occurs when a row in the gridview is databound.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gridReallocateFrom_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowIndex == 0)
        {
            OBudgetReallocation budgetReallocation = panel.SessionObject as OBudgetReallocation;
            numberOfColumns = budgetReallocation.FromBudgetPeriod.TotalNumberOfIntervals;
        }

        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            for (int i = 1; i <= 1; i++)
            {
                //UIFieldTextBox textIntervalAmount = e.Row.FindControl("textInterval" + String.Format("{0:00}", i) + "Amount") as UIFieldTextBox;
                UIFieldTextBox textTotalAmount = e.Row.FindControl("textTotalAmount") as UIFieldTextBox;
                /*if (textIntervalAmount != null)
                {
                    textIntervalAmount.Control.Attributes["onchange"] =
                        "computeTotal('" + e.Row.UniqueID + "','" + textTotalAmount.Control.ClientID
                        + "','" + gridReallocateFrom.ID + "','lblReallocationFromTotal'); ";
                }
                */
                if (textTotalAmount != null)
                {
                    textTotalAmount.Control.Attributes["onchange"] =
                        "computeTotalAmount('" + gridReallocateFrom.ID + "','lblReallocationFromTotal'); ";
                }
                /*
                HyperLink linkDistribute = e.Row.FindControl("linkDistribute") as HyperLink;
                if (linkDistribute != null)
                {
                    linkDistribute.Attributes["onclick"] =
                        "distributeTotal('" + e.Row.UniqueID + "','" + textTotalAmount.Control.ClientID + "', " + numberOfColumns + ",'" + Resources.Errors.BudgetReallocate_TotalNegative + "'); ";
                }
                 * */
            }
        }
        else
            if (e.Row.RowType == DataControlRowType.Footer)
            {
                OBudgetReallocation budgetReallocation = panel.SessionObject as OBudgetReallocation;
                e.Row.Cells[2].Text = Resources.Strings.Capitaland_BudgetReallocation_FooterTotal;
                e.Row.Cells[3].ID = "lblReallocationFromTotal";
                e.Row.Cells[3].Text = budgetReallocation.TotalFromBudgetAmount.ToString("#,##0.00");
            }
    }

    /// <summary>
    /// Occurs when a row in the gridview is databound.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gridReallocateTo_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowIndex == 0)
        {
            OBudgetReallocation budgetReallocation = panel.SessionObject as OBudgetReallocation;
            numberOfColumns = budgetReallocation.ToBudgetPeriod.TotalNumberOfIntervals;
        }

        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            for (int i = 1; i <= 1; i++)
            {
                //UIFieldTextBox textIntervalAmount = e.Row.FindControl("textInterval" + String.Format("{0:00}", i) + "Amount") as UIFieldTextBox;
                UIFieldTextBox textTotalAmount = e.Row.FindControl("textTotalAmount") as UIFieldTextBox;

                /*if (textIntervalAmount != null)
                {
                    textIntervalAmount.Control.Attributes["onchange"] =
                        "computeTotal('" + e.Row.UniqueID + "','" + textTotalAmount.Control.ClientID
                        + "','" + this.gridReallocateTo.ID + "','lblReallocationToTotal'); ";
                }*/

                if (textTotalAmount != null)
                {
                    textTotalAmount.Control.Attributes["onchange"] =
                        "computeTotalAmount('" + gridReallocateTo.ID + "','lblReallocationToTotal'); ";
                }

                /*
                HyperLink linkDistribute = e.Row.FindControl("linkDistribute") as HyperLink;
                if (linkDistribute != null)
                {
                    linkDistribute.Attributes["onclick"] =
                        "distributeTotal('" + e.Row.UniqueID + "','" + textTotalAmount.Control.ClientID + "', " + numberOfColumns + ",'" + Resources.Errors.BudgetReallocate_TotalNegative + "'); ";
                }*/
            }
        }
        else
            if (e.Row.RowType == DataControlRowType.Footer)
            {
                OBudgetReallocation budgetReallocation = panel.SessionObject as OBudgetReallocation;
                e.Row.Cells[2].Text = Resources.Strings.Capitaland_BudgetReallocation_FooterTotal;
                e.Row.Cells[3].ID = "lblReallocationToTotal";
                e.Row.Cells[3].Text = budgetReallocation.TotalToBudgetAmount.ToString("#,##0.00");
            }

    }

    protected void locationToModel_SelectedIndexChanged(object sender, EventArgs e)
    {

    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">

    <script type='text/javascript'>
        function computeTotal(inputControlPrefix, totalControlId, gridPrefix, totalPrefix) {
            var inputs = document.getElementsByTagName("input");
            var cells = document.getElementsByTagName("td");
            var total = 0.0;
            var totalAmount = 0.0;
            for (var i = 0; i < inputs.length; i++) {
                if (inputs[i].type == 'text' &&
                        inputs[i].name.indexOf(inputControlPrefix) >= 0 &&
                        inputs[i].id != totalControlId) {
                    var v = parseFloat(inputs[i].value.replace(/,/g, ""));
                    if (!isNaN(v)) {
                        total += v;
                    }
                }

                if (inputs[i].type == 'text' &&
                        inputs[i].name.indexOf("textTotalAmount") == -1 &&
                        inputs[i].name.indexOf(gridPrefix) >= 0) {
                    var v = parseFloat(inputs[i].value.replace(/,/g, ""));
                    if (!isNaN(v)) {
                        totalAmount += v;
                    }
                }

            }

            var totalControl = document.getElementById(totalControlId);
            totalControl.value = Math.round(total);

            for (var i = 0; i < cells.length; i++) {
                if (cells[i].id.indexOf(totalPrefix) >= 0) {
                    cells[i].innerHTML = Math.round(totalAmount).toString();
                    break;
                }
            }

        }

        function computeTotalAmount(gridPrefix, totalPrefix) {
            var inputs = document.getElementsByTagName("input");
            var cells = document.getElementsByTagName("td");
            var totalAmount = 0.0;
            for (var i = 0; i < inputs.length; i++) {

                if (inputs[i].type == 'text' &&
                        inputs[i].name.indexOf("textTotalAmount") >= 0 &&
                        inputs[i].name.indexOf(gridPrefix) >= 0) {
                    var v = parseFloat(inputs[i].value.replace(/,/g, ""));
                    if (!isNaN(v)) {
                        totalAmount += v;
                    }
                }

            }

            for (var i = 0; i < cells.length; i++) {
                if (cells[i].id.indexOf(totalPrefix) >= 0) {
                    cells[i].innerHTML = Math.round(totalAmount).toString();
                    break;
                }
            }

        }

        function distributeTotal(inputControlPrefix, totalControlId, divisor, errMsg) {
            var totalControl = document.getElementById(totalControlId);
            var t = parseFloat(totalControl.value.replace(/,/g, ""));

            try {
                if (!isNaN(t)) {
                    if (t >= 0) {
                        var tavg = Math.floor(t / divisor);
                        var tlast = t - (tavg * (divisor - 1));

                        var inputs = document.getElementsByTagName("input");
                        var rowInputs = new Array();
                        for (var i = 0; i < inputs.length; i++) {
                            if (inputs[i].type == 'text' &&
                        inputs[i].name.indexOf(inputControlPrefix) >= 0 &&
                        inputs[i].id != totalControlId) {
                                rowInputs[rowInputs.length] = inputs[i];
                            }
                        }
                        for (var i = 0; i < rowInputs.length; i++) {
                            if (i != rowInputs.length - 1)
                                rowInputs[i].value = tavg;
                            else
                                rowInputs[i].value = tlast;
                        }
                    }
                    else {
                        throw "Err";
                    }

                }

            }
            catch (err) {
                if (err = "Err") {
                    alert(errMsg);
                }

            }
        }
    </script>

    <ui:UIObjectPanel runat="server" ID="panelMain" meta:resourcekey="panelMainResource1"
        BorderStyle="NotSet">
        <web:object runat="server" ID="panel" Caption="Budget Reallocation" BaseTable="tBudgetReallocation"
            OnPopulateForm="panel_OnPopulateForm" OnValidateAndSave="panel_ValidateAndSave"
            ShowWorkflowActionAsButtons="true" SaveButtonsVisible="false" meta:resourcekey="panelResource1">
        </web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1"
                BorderStyle="NotSet">
                <ui:UITabView ID="tabDetails" runat="server" Caption="Details" BorderStyle="NotSet"
                    meta:resourcekey="tabDetailsResource1">
                    <web:base ID="objectBase" runat="server" ObjectNumberEnabled="false" ObjectNameVisible="false"
                        meta:resourcekey="objectBaseResource1"></web:base>
                    <ui:UIFieldRichTextBox ID="textAdjustmentDescription" runat="server" Caption="Description"
                        EditorHeight="120px" PropertyName="Description" ToolTip="Description of the reallocation"
                        meta:resourcekey="textAdjustmentDescriptionResource1" InternalControlHeight="120px" />
                    <br />
                    <br />
                </ui:UITabView>
                <ui:UITabView ID="uitabviewReallocateFrom" runat="server" Caption="Reallocate From"
                    meta:resourcekey="uitabviewReallocateFromResource1" BorderStyle="NotSet">
                    <ui:UIPanel runat="server" ID="panelReallocateFrom" meta:resourcekey="panelReallocateFromResource1"
                        BorderStyle="NotSet">
                        <ui:UIFieldDropDownList ID="dropFromBudget" runat="server" Caption="From Budget"
                            PropertyName="FromBudgetID" OnSelectedIndexChanged="dropFromBudget_SelectedIndexChanged"
                            ValidateRequiredField="True" meta:resourcekey="dropFromBudgetResource1" />
                        <ui:UIFieldDropDownList runat="server" ID="dropFromBudgetPeriod" Caption="From Budget Period"
                            PropertyName="FromBudgetPeriodID" ValidateRequiredField="True" OnSelectedIndexChanged="dropFromBudgetPeriod_SelectedIndexChanged"
                            meta:resourcekey="dropFromBudgetPeriodResource1">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldTreeList runat="server" ID="treeAccountFrom" Caption="Add Account" OnAcquireTreePopulater="treeAccountFrom_AcquireTreePopulater"
                            OnSelectedNodeChanged="treeAccountFrom_SelectedNodeChanged" meta:resourcekey="treeAccountFromResource1"
                            ShowCheckBoxes="None" TreeValueMode="SelectedNode">
                        </ui:UIFieldTreeList>
                        <ui:UIGridView runat="server" ID="gridReallocateFrom" ShowFooter="True" PropertyName="BudgetReallocationFroms"
                            BindObjectsToRows="True" ValidateRequiredField="True" Caption="From Budget Items"
                            KeyName="ObjectID" OnRowDataBound="gridReallocateFrom_RowDataBound" meta:resourcekey="gridReallocateFromResource1"
                            DataKeyNames="ObjectID" GridLines="Both" RowErrorColor="" Style="clear: both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject"
                                    CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?"
                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
                            </Commands>
                            <Columns>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?"
                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewButtonColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="Account.Path" HeaderText="Account" meta:resourceKey="UIGridViewBoundColumnResource1"
                                    PropertyName="Account.Path" ResourceAssemblyName="" SortExpression="Account.Path">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource77">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textTotalAmount" runat="server" DataFormatString="{0:#,##0.00}"
                                            FieldLayout="Flow" InternalControlWidth="70px" meta:resourceKey="textInterval01AmountResource1"
                                            PropertyName="TotalAmount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRangeField="True"
                                            ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0"
                                            ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewBoundColumn DataField="TotalOpeningBalance" DataFormatString="{0:#,##0.00}"
                                    HeaderText="(1) Opening Balance" meta:resourcekey="UIGridViewBoundColumnResource3"
                                    PropertyName="TotalOpeningBalance" ResourceAssemblyName="" SortExpression="TotalOpeningBalance">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TotalAdjustedAmount" DataFormatString="{0:#,##0.00}"
                                    HeaderText="(2) Adjusted Amount" meta:resourcekey="UIGridViewBoundColumnResource4"
                                    PropertyName="TotalAdjustedAmount" ResourceAssemblyName="" SortExpression="TotalAdjustedAmount">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TotalReallocatedAmount" DataFormatString="{0:#,##0.00}"
                                    HeaderText="(3) Reallocated Amount" meta:resourcekey="UIGridViewBoundColumnResource5"
                                    PropertyName="TotalReallocatedAmount" ResourceAssemblyName="" SortExpression="TotalReallocatedAmount">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TotalBalanceAfterVariation" DataFormatString="{0:#,##0.00}"
                                    HeaderText="(4) Total After Adjustments&lt;br /&gt;(1)+(2)+(3)" HtmlEncode="False"
                                    meta:resourcekey="UIGridViewBoundColumnResource6" PropertyName="TotalBalanceAfterVariation"
                                    ResourceAssemblyName="" SortExpression="TotalBalanceAfterVariation">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TotalPendingApproval" DataFormatString="{0:#,##0.00}"
                                    HeaderText="(5) Total Pending Approval" meta:resourcekey="UIGridViewBoundColumnResource7"
                                    PropertyName="TotalPendingApproval" ResourceAssemblyName="" SortExpression="TotalPendingApproval">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TotalApproved" DataFormatString="{0:#,##0.00}"
                                    HeaderText="(6) Total Approved" meta:resourcekey="UIGridViewBoundColumnResource8"
                                    PropertyName="TotalApproved" ResourceAssemblyName="" SortExpression="TotalApproved">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TotalDirectInvoicePendingApproval" DataFormatString="{0:#,##0.00}"
                                    HeaderText="(7) Total Direct Invoice Pending Approval" meta:resourcekey="UIGridViewBoundColumnResource9"
                                    PropertyName="TotalDirectInvoicePendingApproval" ResourceAssemblyName="" SortExpression="TotalDirectInvoicePendingApproval">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TotalDirectInvoiceApproved" DataFormatString="{0:#,##0.00}"
                                    HeaderText="(8) Total Direct Invoice Approved" meta:resourcekey="UIGridViewBoundColumnResource10"
                                    PropertyName="TotalDirectInvoiceApproved" ResourceAssemblyName="" SortExpression="TotalDirectInvoiceApproved">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TotalAvailableBalance" DataFormatString="{0:#,##0.00}"
                                    HeaderText="(9) Total Available&lt;br /&gt;(4)-(5)-(6)-(7)-(8)" HtmlEncode="False"
                                    meta:resourcekey="UIGridViewBoundColumnResource11" PropertyName="TotalAvailableBalance"
                                    ResourceAssemblyName="" SortExpression="TotalAvailableBalance">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                        <ui:UIObjectPanel runat="server" ID="panelBudgetReallocationFroms" meta:resourcekey="panelBudgetReallocationFromsResource1"
                            BorderStyle="NotSet">
                            <web:subpanel runat="server" ID="subpanelBudgetReallocationFroms" GridViewID="gridReallocateFrom"
                                meta:resourcekey="subpanelBudgetReallocationFromsResource1" />
                        </ui:UIObjectPanel>
                        <br />
                        <br />
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView ID="uitabviewReallocateTo" runat="server" Caption="Reallocate To" meta:resourcekey="uitabviewReallocateToResource1"
                    BorderStyle="NotSet">
                    <ui:UIPanel runat="server" ID="panelReallocateTo" meta:resourcekey="panelReallocateToResource1"
                        BorderStyle="NotSet">
                        <ui:UIFieldDropDownList ID="dropToBudget" runat="server" Caption="To Budget" PropertyName="ToBudgetID"
                            OnSelectedIndexChanged="dropToBudget_SelectedIndexChanged" ValidateRequiredField="True"
                            meta:resourcekey="dropToBudgetResource1" />
                        <ui:UIFieldDropDownList runat="server" ID="dropToBudgetPeriod" Caption="To Budget Period"
                            PropertyName="ToBudgetPeriodID" ValidateRequiredField="True" OnSelectedIndexChanged="dropToBudgetPeriod_SelectedIndexChanged"
                            meta:resourcekey="dropToBudgetPeriodResource1">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldRadioList runat="server" ID="locationToModel" Caption="Show Accounts"
                            OnSelectedIndexChanged="locationToModel_SelectedIndexChanged">
                            <Items>
                                <asp:ListItem Selected="True" Text="Show accounts applicable to the current budget period"
                                    Value="0"></asp:ListItem>
                                <asp:ListItem Text="Show all accounts" Value="1"></asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIFieldTreeList runat="server" ID="treeAccountTo" Caption="Add Account" OnAcquireTreePopulater="treeAccountTo_AcquireTreePopulater"
                            OnSelectedNodeChanged="treeAccountTo_SelectedNodeChanged" meta:resourcekey="treeAccountToResource1"
                            ShowCheckBoxes="None" TreeValueMode="SelectedNode">
                        </ui:UIFieldTreeList>
                        <ui:UIGridView runat="server" ID="gridReallocateTo" ShowFooter="True" PropertyName="BudgetReallocationTos"
                            BindObjectsToRows="True" ValidateRequiredField="True" Caption="To Budget Items"
                            ToolTip="Indicate budget items to reallocate to." OnRowDataBound="gridReallocateTo_RowDataBound"
                            meta:resourcekey="gridReallocateToResource1" DataKeyNames="ObjectID" GridLines="Both"
                            RowErrorColor="" Style="clear: both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject"
                                    CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?"
                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource3" />
                            </Commands>
                            <Columns>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?"
                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewButtonColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="Account.Path" HeaderText="Account" meta:resourceKey="UIGridViewBoundColumnResource2"
                                    PropertyName="Account.Path" ResourceAssemblyName="" SortExpression="Account.Path">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource78">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textTotalAmount" runat="server" DataFormatString="{0:#,##0.00}"
                                            FieldLayout="Flow" InternalControlWidth="70px" meta:resourceKey="textInterval01AmountResource1"
                                            PropertyName="TotalAmount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRangeField="True"
                                            ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0"
                                            ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewBoundColumn DataField="TotalOpeningBalance" DataFormatString="{0:#,##0.00}"
                                    HeaderText="(1) Opening Balance" meta:resourcekey="UIGridViewBoundColumnResource12"
                                    PropertyName="TotalOpeningBalance" ResourceAssemblyName="" SortExpression="TotalOpeningBalance">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TotalAdjustedAmount" DataFormatString="{0:#,##0.00}"
                                    HeaderText="(2) Adjusted Amount" meta:resourcekey="UIGridViewBoundColumnResource13"
                                    PropertyName="TotalAdjustedAmount" ResourceAssemblyName="" SortExpression="TotalAdjustedAmount">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TotalReallocatedAmount" DataFormatString="{0:#,##0.00}"
                                    HeaderText="(3) Reallocated Amount" meta:resourcekey="UIGridViewBoundColumnResource14"
                                    PropertyName="TotalReallocatedAmount" ResourceAssemblyName="" SortExpression="TotalReallocatedAmount">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TotalBalanceAfterVariation" DataFormatString="{0:#,##0.00}"
                                    HeaderText="(4) Total After Adjustments&lt;br /&gt;(1)+(2)+(3)" HtmlEncode="False"
                                    meta:resourcekey="UIGridViewBoundColumnResource15" PropertyName="TotalBalanceAfterVariation"
                                    ResourceAssemblyName="" SortExpression="TotalBalanceAfterVariation">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TotalPendingApproval" DataFormatString="{0:#,##0.00}"
                                    HeaderText="(5) Total Pending Approval" meta:resourcekey="UIGridViewBoundColumnResource16"
                                    PropertyName="TotalPendingApproval" ResourceAssemblyName="" SortExpression="TotalPendingApproval">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TotalApproved" DataFormatString="{0:#,##0.00}"
                                    HeaderText="(6) Total Approved" meta:resourcekey="UIGridViewBoundColumnResource17"
                                    PropertyName="TotalApproved" ResourceAssemblyName="" SortExpression="TotalApproved">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TotalDirectInvoicePendingApproval" DataFormatString="{0:#,##0.00}"
                                    HeaderText="(7) Total Direct Invoice Pending Approval" meta:resourcekey="UIGridViewBoundColumnResource18"
                                    PropertyName="TotalDirectInvoicePendingApproval" ResourceAssemblyName="" SortExpression="TotalDirectInvoicePendingApproval">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TotalDirectInvoiceApproved" DataFormatString="{0:#,##0.00}"
                                    HeaderText="(8) Total Direct Invoice Approved" meta:resourcekey="UIGridViewBoundColumnResource19"
                                    PropertyName="TotalDirectInvoiceApproved" ResourceAssemblyName="" SortExpression="TotalDirectInvoiceApproved">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TotalAvailableBalance" DataFormatString="{0:#,##0.00}"
                                    HeaderText="(9) Total Available&lt;br /&gt;(4)-(5)-(6)-(7)-(8)" HtmlEncode="False"
                                    meta:resourcekey="UIGridViewBoundColumnResource20" PropertyName="TotalAvailableBalance"
                                    ResourceAssemblyName="" SortExpression="TotalAvailableBalance">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                        <ui:UIObjectPanel runat="server" ID="panelBudgetReallocationTos" meta:resourcekey="panelBudgetReallocationTosResource1"
                            BorderStyle="NotSet">
                            <web:subpanel runat="server" ID="subpanelBudgetReallocationTos" GridViewID="gridReallocateTo"
                                meta:resourcekey="subpanelBudgetReallocationTosResource1" />
                        </ui:UIObjectPanel>
                        <br />
                        <br />
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview1" Caption="Status History" meta:resourcekey="uitabview1Resource1"
                    BorderStyle="NotSet">
                    <web:ActivityHistory runat="server" ID="ActivityHistory" meta:resourcekey="ActivityHistoryResource1" />
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabMemo" Caption="Memo" meta:resourcekey="tabMemoResource1"
                    BorderStyle="NotSet">
                    <web:memo runat="server" ID="memo1" meta:resourcekey="memo1Resource1"></web:memo>
                </ui:UITabView>
                <ui:UITabView ID="tabAttachments" runat="server" Caption="Attachments" meta:resourcekey="tabAttachmentsResource1"
                    BorderStyle="NotSet">
                    <web:attachments runat="server" ID="attachments" meta:resourcekey="attachmentsResource1">
                    </web:attachments>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>