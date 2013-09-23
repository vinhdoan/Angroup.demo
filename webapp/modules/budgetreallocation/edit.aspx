<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

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
        dropFromBudgetPeriod.Bind(OBudgetPeriod.GetBudgetPeriodsByBudgetID(budgetReallocation.FromBudgetID, budgetReallocation.FromBudgetPeriodID));

        dropToBudget.Bind(OBudget.GetAccessibleBugets(AppSession.User, budgetReallocation.ToBudgetID, "OBudgetReallocation"));
        dropToBudgetPeriod.Bind(OBudgetPeriod.GetBudgetPeriodsByBudgetID(budgetReallocation.ToBudgetID, budgetReallocation.ToBudgetPeriodID));

        if (budgetReallocation.BudgetReallocationFroms.Count > 0)
            InitializeFromGrid();
        if (budgetReallocation.BudgetReallocationTos.Count > 0)
            InitializeToGrid();

        treeAccountFrom.PopulateTree();
        treeAccountTo.PopulateTree();

        panel.ObjectPanel.BindObjectToControls(budgetReallocation);
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

        treeAccountFrom.Visible = dropFromBudget.SelectedIndex > 0 && dropFromBudgetPeriod.SelectedIndex > 0;
        gridReallocateFrom.Visible = dropFromBudget.SelectedIndex > 0 && dropFromBudgetPeriod.SelectedIndex > 0;

        treeAccountTo.Visible = dropToBudget.SelectedIndex > 0 && dropToBudgetPeriod.SelectedIndex > 0;
        gridReallocateTo.Visible = dropToBudget.SelectedIndex > 0 && dropToBudgetPeriod.SelectedIndex > 0;

        panelReallocateFrom.Enabled = objectBase.CurrentObjectState.Is("Start", "Draft");
        panelReallocateTo.Enabled = objectBase.CurrentObjectState.Is("Start", "Draft");
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

            if (!panel.ObjectPanel.IsValid)
                return;

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
        }
    }

    /// <summary>
    /// Initializes the opening balance GridView to show the 
    /// correct number of columns, and correct header texts.
    /// </summary>
    protected void InitializeToGrid()
    {
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

        dropFromBudgetPeriod.Bind(OBudgetPeriod.GetBudgetPeriodsByBudgetID(budgetId, null));
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

        dropToBudgetPeriod.Bind(OBudgetPeriod.GetBudgetPeriodsByBudgetID(budgetId, null));
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

            if (budgetReallocation.ValidateFromAccountIdDoesNotExist(accountId))
            {
                OBudgetReallocationFrom from = TablesLogic.tBudgetReallocationFrom.Create();
                from.AccountID = accountId;
                budgetReallocation.BudgetReallocationFroms.Add(from);

                if (gridReallocateFrom.Rows.Count == 0)
                    InitializeFromGrid();

                panel.ObjectPanel.BindObjectToControls(budgetReallocation);
                panel.Message = "";
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

            if (budgetReallocation.ValidateToAccountIdDoesNotExist(accountId))
            {
                OBudgetReallocationTo to = TablesLogic.tBudgetReallocationTo.Create();
                to.AccountID = accountId;
                budgetReallocation.BudgetReallocationTos.Add(to);

                if (gridReallocateTo.Rows.Count == 0)
                    InitializeToGrid();

                panel.ObjectPanel.BindObjectToControls(budgetReallocation);
                panel.Message = "";
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
            for (int i = 1; i <= 36; i++)
            {
                UIFieldTextBox textIntervalAmount = e.Row.FindControl("textInterval" + String.Format("{0:00}", i) + "Amount") as UIFieldTextBox;
                UIFieldTextBox textTotalAmount = e.Row.FindControl("textTotalAmount") as UIFieldTextBox;
                if (textIntervalAmount != null)
                {
                    textIntervalAmount.Control.Attributes["onchange"] =
                        "computeTotal('" + e.Row.UniqueID + "','" + textTotalAmount.Control.ClientID + "'); ";
                }

                HyperLink linkDistribute = e.Row.FindControl("linkDistribute") as HyperLink;
                if (linkDistribute != null)
                {
                    linkDistribute.Attributes["onclick"] =
                        "distributeTotal('" + e.Row.UniqueID + "','" + textTotalAmount.Control.ClientID + "', " + numberOfColumns + ",'" + Resources.Errors.BudgetReallocate_TotalNegative + "'); ";
                }
            }
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
            for (int i = 1; i <= 36; i++)
            {
                UIFieldTextBox textIntervalAmount = e.Row.FindControl("textInterval" + String.Format("{0:00}", i) + "Amount") as UIFieldTextBox;
                UIFieldTextBox textTotalAmount = e.Row.FindControl("textTotalAmount") as UIFieldTextBox;
                if (textIntervalAmount != null)
                {
                    textIntervalAmount.Control.Attributes["onchange"] =
                        "computeTotal('" + e.Row.UniqueID + "','" + textTotalAmount.Control.ClientID + "'); ";
                }

                HyperLink linkDistribute = e.Row.FindControl("linkDistribute") as HyperLink;
                if (linkDistribute != null)
                {
                    linkDistribute.Attributes["onclick"] =
                        "distributeTotal('" + e.Row.UniqueID + "','" + textTotalAmount.Control.ClientID + "', " + numberOfColumns + ",'" + Resources.Errors.BudgetReallocate_TotalNegative + "'); ";
                }
            }
        }

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
        function computeTotal(inputControlPrefix, totalControlId) {
            var inputs = document.getElementsByTagName("input");
            var total = 0.0;
            for (var i = 0; i < inputs.length; i++) {
                if (inputs[i].type == 'text' &&
                        inputs[i].name.indexOf(inputControlPrefix) >= 0 &&
                        inputs[i].id != totalControlId) {
                    var v = parseFloat(inputs[i].value.replace(/,/g, ""));
                    if (!isNaN(v)) {
                        total += v;
                    }
                }
            }

            var totalControl = document.getElementById(totalControlId);
            totalControl.value = Math.round(total);
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

    <ui:UIObjectPanel runat="server" ID="panelMain" meta:resourcekey="panelMainResource1">
        <web:object runat="server" ID="panel" Caption="Budget Reallocation" BaseTable="tBudgetReallocation"
            OnPopulateForm="panel_OnPopulateForm" OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1">
        </web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1">
                <ui:UITabView ID="uitabviewReallocateFrom" runat="server" Caption="Reallocate From" meta:resourcekey="uitabviewReallocateFromResource1">
                    <web:base ID="objectBase" runat="server" ObjectNumberEnabled="false" ObjectNameVisible="false" meta:resourcekey="objectBaseResource1">
                    </web:base>
                    <ui:UIPanel runat="server" ID="panelReallocateFrom" meta:resourcekey="panelReallocateFromResource1">
                        <ui:UIFieldTextBox ID="textAdjustmentDescription" runat="server" Caption="Description"
                            PropertyName="Description" ToolTip="Description of the reallocation"  meta:resourcekey="textAdjustmentDescriptionResource1" />
                        <br />
                        <br />
                        <ui:UIFieldDropDownList ID="dropFromBudget" runat="server" Caption="From Budget"
                            PropertyName="FromBudgetID" OnSelectedIndexChanged="dropFromBudget_SelectedIndexChanged"
                            ValidateRequiredField="true"  meta:resourcekey="dropFromBudgetResource1" />
                        <ui:UIFieldDropDownList runat="server" ID="dropFromBudgetPeriod" Caption="From Budget Period"
                            PropertyName="FromBudgetPeriodID" ValidateRequiredField="true" OnSelectedIndexChanged="dropFromBudgetPeriod_SelectedIndexChanged" meta:resourcekey="dropFromBudgetPeriodResource1">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldTreeList runat="server" ID="treeAccountFrom" Caption="Add Account" OnAcquireTreePopulater="treeAccountFrom_AcquireTreePopulater"
                            OnSelectedNodeChanged="treeAccountFrom_SelectedNodeChanged" meta:resourcekey="treeAccountFromResource1">
                        </ui:UIFieldTreeList>
                        <ui:UIGridView runat="server" ID="gridReallocateFrom" PropertyName="BudgetReallocationFroms"
                            BindObjectsToRows="true" ValidateRequiredField="true" Caption="From Budget Items"
                            KeyName="ObjectID" OnRowDataBound="gridReallocateFrom_RowDataBound" meta:resourcekey="gridReallocateFromResource1">
                            <Columns>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" CommandName="DeleteObject"
                                    ConfirmText="Are you sure you wish to delete this item?" meta:resourcekey="UIGridViewButtonColumnResource1">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Account" PropertyName="Account.Path" meta:resourcekey="UIGridViewBoundColumnResource1">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval01Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval01Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval01AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval02Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval02Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval02AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval03Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval03Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval03AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval04Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval04Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval04AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval05Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval05Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval05AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval06Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval06Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval06AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval07Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval07Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval07AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval08Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval08Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval08AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval09Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval09Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval09AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval10Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval10Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval10AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval11Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval11Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval11AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval12Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval12Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval12AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval13Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval13Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval13AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval14Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval14Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval14AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval15Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval15Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval15AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval16Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval16Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval16AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval17Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval17Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval17AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval18Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval18Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval18AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval19Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval19Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval19AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval20Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval20Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval20AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval21Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval21Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval21AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval22Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval22Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval22AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval23Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval23Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval23AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval24Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval24Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval24AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval25Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval25Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval25AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval26Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval26Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval26AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval27Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval27Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval27AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval28Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval28Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval28AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval29Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval29Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval29AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval30Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval30Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval30AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval31Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval31Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval31AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval32Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval32Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval32AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval33Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval33Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval33AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval34Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval34Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval34AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval35Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval35Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval35AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval36Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval36Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval36AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderText="Total" ItemStyle-BackColor="#eeeeee" meta:resourcekey="UIGridViewTemplateColumnResource37">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textTotalAmount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="TotalAmount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textTotalAmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn>
                                    <ItemTemplate>
                                        <asp:HyperLink runat='server' ID="linkDistribute" NavigateUrl="javascript:void(0)"
                                            Text="Distribute" meta:resourcekey="linkDistributeResource1"></asp:HyperLink>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                            </Columns>
                            <Commands>
                                <ui:UIGridViewCommand CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?"
                                    ImageUrl="~/images/delete.gif" CommandName="DeleteObject" meta:resourcekey="UIGridViewCommandResource1"></ui:UIGridViewCommand>
                            </Commands>
                        </ui:UIGridView>
                        <ui:UIObjectPanel runat="server" ID="panelBudgetReallocationFroms" meta:resourcekey="panelBudgetReallocationFromsResource1">
                            <web:subpanel runat="server" ID="subpanelBudgetReallocationFroms" GridViewID="gridReallocateFrom"  meta:resourcekey="subpanelBudgetReallocationFromsResource1" />
                        </ui:UIObjectPanel>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView ID="uitabviewReallocateTo" runat="server" Caption="Reallocate To" meta:resourcekey="uitabviewReallocateToResource1">
                    <ui:UIPanel runat="server" ID="panelReallocateTo" meta:resourcekey="panelReallocateToResource1">
                        <ui:UIFieldDropDownList ID="dropToBudget" runat="server" Caption="To Budget" PropertyName="ToBudgetID"
                            OnSelectedIndexChanged="dropToBudget_SelectedIndexChanged" ValidateRequiredField="true"  meta:resourcekey="dropToBudgetResource1" />
                        <ui:UIFieldDropDownList runat="server" ID="dropToBudgetPeriod" Caption="To Budget Period"
                            PropertyName="ToBudgetPeriodID" ValidateRequiredField="true" OnSelectedIndexChanged="dropToBudgetPeriod_SelectedIndexChanged" meta:resourcekey="dropToBudgetPeriodResource1">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldTreeList runat="server" ID="treeAccountTo" Caption="Add Account" OnAcquireTreePopulater="treeAccountTo_AcquireTreePopulater"
                            OnSelectedNodeChanged="treeAccountTo_SelectedNodeChanged" meta:resourcekey="treeAccountToResource1">
                        </ui:UIFieldTreeList>
                        <ui:UIGridView runat="server" ID="gridReallocateTo" PropertyName="BudgetReallocationTos"
                            BindObjectsToRows="true" ValidateRequiredField="true" Caption="To Budget Items"
                            Span="Full" ToolTip="Indicate budget items to reallocate to." OnRowDataBound="gridReallocateTo_RowDataBound" meta:resourcekey="gridReallocateToResource1">
                            <Columns>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" CommandName="DeleteObject"
                                    ConfirmText="Are you sure you wish to delete this item?" meta:resourcekey="UIGridViewButtonColumnResource2">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Account" PropertyName="Account.Path" meta:resourcekey="UIGridViewBoundColumnResource2">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval01Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval01Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval01AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval02Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval02Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval02AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval03Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval03Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval03AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval04Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval04Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval04AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval05Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval05Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval05AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval06Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval06Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval06AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval07Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval07Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval07AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval08Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval08Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval08AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval09Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval09Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval09AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval10Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval10Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval10AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval11Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval11Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval11AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval12Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval12Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval12AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval13Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval13Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval13AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval14Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval14Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval14AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval15Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval15Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval15AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval16Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval16Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval16AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval17Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval17Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval17AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval18Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval18Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval18AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval19Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval19Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval19AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval20Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval20Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval20AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval21Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval21Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval21AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval22Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval22Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval22AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval23Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval23Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval23AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval24Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval24Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval24AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval25Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval25Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval25AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval26Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval26Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval26AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval27Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval27Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval27AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval28Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval28Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval28AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval29Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval29Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval29AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval30Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval30Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval30AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval31Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval31Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval31AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval32Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval32Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval32AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval33Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval33Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval33AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval34Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval34Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval34AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval35Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval35Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval35AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval36Amount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="Interval36Amount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textInterval36AmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderText="Total" ItemStyle-BackColor="#eeeeee" meta:resourcekey="UIGridViewTemplateColumnResource75">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textTotalAmount" ValidateRequiredField="true"
                                            ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive='true'
                                            ValidationRangeType="Currency" PropertyName="TotalAmount" Caption="" ShowCaption="false"
                                            FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" meta:resourcekey="textTotalAmountResource1">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn>
                                    <ItemTemplate>
                                        <asp:HyperLink runat='server' ID="linkDistribute" NavigateUrl="javascript:void(0)"
                                            Text="Distribute" meta:resourcekey="linkDistributeResource1"></asp:HyperLink>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                            </Columns>
                            <Commands>
                                <ui:UIGridViewCommand CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?"
                                    ImageUrl="~/images/delete.gif" CommandName="DeleteObject" meta:resourcekey="UIGridViewCommandResource3"></ui:UIGridViewCommand>
                            </Commands>
                        </ui:UIGridView>
                        <ui:UIObjectPanel runat="server" ID="panelBudgetReallocationTos" meta:resourcekey="panelBudgetReallocationTosResource1">
                            <web:subpanel runat="server" ID="subpanelBudgetReallocationTos" GridViewID="gridReallocateTo"  meta:resourcekey="subpanelBudgetReallocationTosResource1" />
                        </ui:UIObjectPanel>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview1" Caption="Status History" meta:resourcekey="uitabview1Resource1">
                    <web:ActivityHistory runat="server" ID="ActivityHistory"  meta:resourcekey="ActivityHistoryResource1" />
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabMemo" Caption="Memo" meta:resourcekey="tabMemoResource1">
                    <web:memo runat="server" ID="memo1" meta:resourcekey="memo1Resource1"></web:memo>
                </ui:UITabView>
                <ui:UITabView ID="tabAttachments" runat="server" Caption="Attachments" meta:resourcekey="tabAttachmentsResource1">
                    <web:attachments runat="server" ID="attachments" meta:resourcekey="attachmentsResource1"></web:attachments>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
