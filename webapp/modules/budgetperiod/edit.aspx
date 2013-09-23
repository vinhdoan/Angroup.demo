<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.Common" %>
<%@ Import Namespace="System.Data.OleDb" %>
<%@ Import Namespace="System.IO" %>

<script runat="server">
    
    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OBudgetPeriod budgetPeriod = (OBudgetPeriod)panel.SessionObject;

        if (budgetPeriod.IsNew && Request["PrevID"] != null)
        {
            Guid prevBudgetPeriodID = new Guid(Security.Decrypt(Request["PrevID"]));
            budgetPeriod.CopyBudgetPeriod(prevBudgetPeriodID);
        }

        dropBudget.Bind(OBudget.GetAllBudgets(budgetPeriod.BudgetID));
        treeAccount.PopulateTree();
        gridBudgetPeriodOpeningBalances.Width = Unit.Empty;

        if (budgetPeriod.BudgetPeriodOpeningBalances.Count > 0)
            InitializeOpeningBalanceGrid();

        if (objectBase.CurrentObjectState.Is("Activated", "Close", "Cancelled"))
        {
            gridBudgetPeriodOpeningBalances.Commands[0].Button.Enabled = false;
            gridBudgetPeriodOpeningBalances.CheckBoxColumnVisible = false;
        }
        else
        {
            gridBudgetPeriodOpeningBalances.Commands[0].Button.Enabled = true;
            gridBudgetPeriodOpeningBalances.CheckBoxColumnVisible = true;
        }

        if (!IsPostBack)
        {
            labelBudgetTotal.Caption = labelBudgetTotal.Caption + " (" + OApplicationSetting.Current.BaseCurrency.CurrencySymbol + ")";
        }

        using (Connection c = new Connection())
        {
            panel.ObjectPanel.BindObjectToControls(budgetPeriod);
        }
    }


    /// <summary>
    /// Saves the calendar to the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OBudgetPeriod budgetPeriod = (OBudgetPeriod)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(budgetPeriod);

            // Validate
            //
            OBudgetPeriod overlappingBudgetPeriod = budgetPeriod.ValidateBudgetPeriodDoesNotOverlapExistingPeriods();
            if (overlappingBudgetPeriod != null)
            {
                dateEndDate.ErrorMessage =
                dateStartDate.ErrorMessage =
                    String.Format(Resources.Errors.BudgetPeriod_BudgetPeriodOverlapsExistingBudgetPeriod,
                    overlappingBudgetPeriod.ObjectName,
                    overlappingBudgetPeriod.StartDate,
                    overlappingBudgetPeriod.EndDate);
            }

            foreach (OBudgetPeriodOpeningBalance openingBalance in budgetPeriod.BudgetPeriodOpeningBalances)
            {
                if (!openingBalance.ValidateTotal())
                {
                    for (int i = 0; i < gridBudgetPeriodOpeningBalances.DataKeys.Count; i++)
                    {
                        Guid id = (Guid)gridBudgetPeriodOpeningBalances.DataKeys[i][0];
                        if (id == openingBalance.ObjectID.Value)
                        {
                            UIFieldTextBox textTotalOpeningBalance = gridBudgetPeriodOpeningBalances.Rows[i].FindControl("textTotalOpeningBalance") as UIFieldTextBox;
                            textTotalOpeningBalance.ErrorMessage = Resources.Errors.BudgetPeriod_OpeningBalanceTotalNotEqualsToIndividualIntervals;
                        }
                    }
                }
            }

            if (!panel.ObjectPanel.IsValid)
                return;

            // Save
            //
            budgetPeriod.Save();
            c.Commit();
        }
    }


    /// <summary>
    /// Constructs and returns the account tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeAccount_AcquireTreePopulater(object sender)
    {
        return new AccountTreePopulater(null, false, true);
    }


    /// <summary>
    /// Occurs when the budget is selected.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropBudget_SelectedIndexChanged(object sender, EventArgs e)
    {
        SetDefaultEndDate();
    }


    /// <summary>
    /// Occurs when the end date is selected.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dateEndDate_DateTimeChanged(object sender, EventArgs e)
    {

    }



    /// <summary>
    /// Occurs when the start date is selected.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dateStartDate_DateTimeChanged(object sender, EventArgs e)
    {
        SetDefaultEndDate();
    }


    /// <summary>
    /// Occurs when the number of months per interval is changed.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void textNumberOfMonthsPerInterval_TextChanged(object sender, EventArgs e)
    {

    }


    /// <summary>
    /// Sets the default end date based on the default number of valid months
    /// in the selected budget.
    /// </summary>
    protected void SetDefaultEndDate()
    {
        if (dateEndDate.DateTime == null && dateStartDate.DateTime != null && dropBudget.SelectedIndex > 0)
        {
            Guid budgetId = new Guid(dropBudget.SelectedValue);
            OBudget budget = TablesLogic.tBudget.Load(budgetId);

            if (budget != null && budget.DefaultNumberOfMonthsPerBudgetPeriod != null)
            {
                dateEndDate.DateTime = dateStartDate.DateTime.Value.AddMonths(budget.DefaultNumberOfMonthsPerBudgetPeriod.Value).AddDays(-1);
            }
            if (budget != null && budget.DefaultNumberOfMonthsPerBudgetPeriod != null)
            {
                textNumberOfMonthsPerInterval.Text = budget.DefaultNumberOfMonthsPerInterval.ToString();
            }
        }
    }


    /// <summary>
    /// Hides and shows elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        int numberOfMonths = 0;
        base.OnPreRender(e);

        tabBudgetAmounts.Visible =
            dropBudget.SelectedIndex > 0 &&
            dateStartDate.DateTime != null &&
            dateEndDate.DateTime != null &&
            Int32.TryParse(textNumberOfMonthsPerInterval.Text, out numberOfMonths);

        panelDetails.Enabled = gridBudgetPeriodOpeningBalances.Rows.Count == 0;
        
        treeAccount.Enabled =
            panelExcel.Enabled = 
            objectBase.CurrentObjectState.Is("Start", "Draft");
        

        panelClosingDate.Enabled = !objectBase.CurrentObjectState.Is("Cancelled");
        panelDetails2.Visible = !objectBase.CurrentObjectState.Is("Cancelled");
        tabBudgetAmounts.Enabled = !objectBase.CurrentObjectState.Is("PendingApproval");
    }



    /// <summary>
    /// Initializes the opening balance GridView to show the 
    /// correct number of columns, and correct header texts.
    /// </summary>
    protected void InitializeOpeningBalanceGrid()
    {
        OBudgetPeriod budgetPeriod = panel.SessionObject as OBudgetPeriod;

        int numberOfMonthsPerInterval = budgetPeriod.NumberOfMonthsPerInterval.Value;
        int numberOfIntervals = budgetPeriod.TotalNumberOfIntervals;

        DateTime startDate = budgetPeriod.StartDate.Value;
        for (int i = 0; i < 36; i++)
        {
            if (i < numberOfIntervals)
            {
                DateTime intervalStartDate = startDate.AddMonths(i);
                gridBudgetPeriodOpeningBalances.Columns[i + 3].Visible = true;
                if (intervalStartDate.Day == 1)
                    gridBudgetPeriodOpeningBalances.Columns[i + 3].HeaderText =
                        startDate.AddMonths(i * numberOfMonthsPerInterval).ToString("MMM-yyyy");
                else
                    gridBudgetPeriodOpeningBalances.Columns[i + 3].HeaderText =
                        startDate.AddMonths(i * numberOfMonthsPerInterval).ToString("dd-MMM-yyyy");
            }
            else
            {
                gridBudgetPeriodOpeningBalances.Columns[i + 3].Visible = false;

            }
        }
    }




    /// <summary>
    /// Occurs when the user selects a node in the account tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void treeAccount_SelectedNodeChanged(object sender, EventArgs e)
    {
        if (treeAccount.SelectedValue != "")
        {
            Guid accountId = new Guid(treeAccount.SelectedValue);

            OBudgetPeriod budgetPeriod = panel.SessionObject as OBudgetPeriod;
            panel.ObjectPanel.BindControlsToObject(budgetPeriod);

            if (budgetPeriod.ValidateAccountIdDoesNotExist(accountId))
            {
                OBudgetPeriodOpeningBalance openingBalance = TablesLogic.tBudgetPeriodOpeningBalance.Create();
                openingBalance.AccountID = accountId;
                budgetPeriod.BudgetPeriodOpeningBalances.Add(openingBalance);

                if (gridBudgetPeriodOpeningBalances.Rows.Count == 0)
                    InitializeOpeningBalanceGrid();

                panel.ObjectPanel.BindObjectToControls(budgetPeriod);
                panel.Message = "";
            }
            else
                panel.Message = Resources.Errors.BudgetPeriod_UnableToAddDuplicateAccount;

            treeAccount.SelectedValue = "";
        }
    }


    int numberOfColumns = 0;

    /// <summary>
    /// Occurs when the opening balance grid view is data bound.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gridBudgetPeriodOpeningBalances_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        OBudgetPeriod budgetPeriod = panel.SessionObject as OBudgetPeriod;
        if (e.Row.RowIndex == 0)
        {
            numberOfColumns = budgetPeriod.TotalNumberOfIntervals;
        }

        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            UIFieldTextBox textTotalOpeningBalance = e.Row.FindControl("textTotalOpeningBalance") as UIFieldTextBox;
            for (int i = 0; i < 36; i++)
            {
                UIFieldTextBox textOpeningBalance = e.Row.FindControl("textOpeningBalance" + String.Format("{0:00}", i)) as UIFieldTextBox;

                if (textOpeningBalance != null)
                {
                    textOpeningBalance.Control.Attributes["onchange"] =
                        "computeTotal('" + e.Row.UniqueID + "$textOpeningBalance','" + textTotalOpeningBalance.Control.ClientID + "'); ";
                }
            }

            textTotalOpeningBalance.Control.Attributes["onchange"] = "formatThis('" + textTotalOpeningBalance.Control.ClientID + "');";
            HyperLink linkDistribute = e.Row.FindControl("linkDistribute") as HyperLink;
            if (linkDistribute != null)
            {
                linkDistribute.Attributes["onclick"] =
                    "distributeTotal('" + e.Row.UniqueID + "$textOpeningBalance','" + textTotalOpeningBalance.Control.ClientID + "', " + numberOfColumns + ",'" + Resources.Errors.BudgetPeriod_TotalNegative + "'); ";
            }
            
            // if the budget period has been activated, or closed, or cancelled,
            // make sure we disable all the text boxes.
            //
            if (objectBase.CurrentObjectState.Is("Activated", "Close", "Cancelled", "PendingApproval"))
            {
                for (int i = 4; i < e.Row.Cells.Count; i++)
                    e.Row.Cells[i].Enabled = false;
            }
        }
    }


    /// <summary>
    /// Opens up this window again with the 
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonOpenNewBudgetPeriod_Click(object sender, EventArgs e)
    {
        OBudgetPeriod budgetPeriod = panel.SessionObject as OBudgetPeriod;

        Window.OpenAddObjectPage(this, "OBudgetPeriod",
            "PrevID=" + HttpUtility.UrlEncode(Security.Encrypt(budgetPeriod.ObjectID.ToString())));
    }


    /// <summary>
    /// Occurs when the user clicks on the show budget view button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonShowBudgetView_Click(object sender, EventArgs e)
    {
        Window.Open("budgetview.aspx?ID=" +
            HttpUtility.UrlEncode(Security.Encrypt(panel.SessionObject.ObjectID.ToString())));
        panel.FocusWindow = false;
    }

    protected void btnDownload_Click(object sender, EventArgs e)
    {
        OBudgetPeriod ybudget = panel.SessionObject as OBudgetPeriod;
        panel.ObjectPanel.BindControlsToObject(ybudget);
        Guid id = Guid.NewGuid();
        string filePath = ConfigurationManager.AppSettings["ReportTempFolder"] + id.ToString().Replace("-", "") + ".xls";
        string worksheetname = "BudgetPeriod";
        int compulsoryColumns = 0;
        DataTable dt = GenerateExcelData();

        OAttachment file = ExcelWriter.GenerateExcelFile(dt, filePath, worksheetname, compulsoryColumns);

        panel.FocusWindow = false;
        Window.Download(file.FileBytes, file.Filename, file.ContentType);
    }

    protected DataTable GenerateExcelData()
    {
        OBudgetPeriod bp = panel.SessionObject as OBudgetPeriod;
        int numberOfIntervals = bp.TotalNumberOfIntervals < 36 ? bp.TotalNumberOfIntervals : 36;
        int numberOfMonthsPerInterval = bp.NumberOfMonthsPerInterval.Value;
        DateTime startDate = bp.StartDate.Value;
        String header;
        DataTable dt = new DataTable();
        dt.Columns.Add("Account");
        for (int i = 0; i < numberOfIntervals; i++)
        {
            DateTime intervalStartDate = startDate.AddMonths(i);
            if (intervalStartDate.Day == 1)
                header = startDate.AddMonths(i * numberOfMonthsPerInterval).ToString("MMM-yyyy");
            else
                header = startDate.AddMonths(i * numberOfMonthsPerInterval).ToString("dd-MMM-yyyy");
            dt.Columns.Add(header);
        }

        // if user selected any account, generate excel data for selected account
        // otherwise generate for all account?
        if (bp.BudgetPeriodOpeningBalances.Count != 0)
        {
            foreach (OBudgetPeriodOpeningBalance i in bp.BudgetPeriodOpeningBalances)
            {
                DataRow dr = dt.NewRow();
                dr["Account"] = i.Account.Path;
                for (int j = 1; j <= numberOfIntervals; j++)
                {
                    dr[j] = i.OpeningBalanceGet(j).Value.ToString("#,##0.00");
                }
                dt.Rows.Add(dr);
            }
        }


        DataView dv = dt.DefaultView;
        dv.Sort = "Account asc";
        return dv.ToTable();
    }

    private bool ValidateInputFile()
    {
        bool validate = true;
        if (this.InputFile.Control.PostedFile.FileName == "" || this.InputFile.Control.PostedFile == null
            || this.InputFile.Control.PostedFile.ContentLength == 0
            || !this.InputFile.Control.PostedFile.FileName.ToLower().EndsWith(".xls"))
        {
            validate = false;
            panel.Message = Resources.Errors.Reading_InvalidFile;
        }
        return validate;
    }

    /// <summary>
    /// Upload Button Clicked, read Excel file and write into local harddisk
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnUploadConfirm_Click(object sender, EventArgs e)
    {
        panel.Message = "";
        OBudgetPeriod bp = panel.SessionObject as OBudgetPeriod;

        if (ValidateInputFile())
        {
            //read data from excel
            try
            {
                Guid id = Guid.NewGuid();
                string filePath = ConfigurationManager.AppSettings["ReportTempFolder"] + id.ToString().Replace("-", "") + ".xls";

                this.InputFile.Control.PostedFile.SaveAs(filePath);
                DataTable dtExceldata = new DataTable();

                string connString = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + filePath + ";Extended Properties='Excel 8.0;HDR=Yes;IMEX=1;Notify=True'";

                OleDbCommand excelCommand = new OleDbCommand();
                OleDbDataAdapter excelDataAdapter = new OleDbDataAdapter();

                OleDbConnection excelConn = new OleDbConnection(connString);
                excelConn.Open();

                String sheetName = "";

                DataTable dtExcelSheets = new DataTable();
                dtExcelSheets = excelConn.GetOleDbSchemaTable(OleDbSchemaGuid.Tables, null);
                if (dtExcelSheets.Rows.Count > 0)
                {
                    sheetName = dtExcelSheets.Rows[0]["TABLE_NAME"].ToString();
                }
                OleDbCommand OleCmdSelect = new OleDbCommand("SELECT * FROM [" + sheetName + "]", excelConn);
                OleDbDataAdapter OleAdapter = new OleDbDataAdapter(OleCmdSelect);

                OleAdapter.FillSchema(dtExceldata, System.Data.SchemaType.Source);
                OleAdapter.Fill(dtExceldata);
                excelConn.Close();

                if (dtExceldata.Rows.Count == 0)
                {
                    panel.Message = Resources.Errors.Reading_InvalidFile;
                    dtExceldata.Clear();
                    gridBudgetPeriodOpeningBalances.DataBind();
                    return;
                }

                foreach (DataRow dr in dtExceldata.Rows)
                {
                    if (!dr.Table.Columns.Contains("Account"))
                    {
                        panel.Message = Resources.Errors.Reading_InvalidFile;
                        return;
                    }

                    if (dr["Account"].ToString() != "")
                    {
                        Guid acc = OAccount.GetAccountByPath(dr["Account"].ToString());
                        if (acc == null)
                        {
                            panel.Message = String.Format(Resources.Errors.General_ItemNotExist, dr["Account"].ToString());
                            return;
                        }
                        else
                        {
                            OBudgetPeriodOpeningBalance bpob =
                                bp.BudgetPeriodOpeningBalances.Find((r) => r.AccountID == acc);
                            if (bpob == null)
                            {
                                bpob = TablesLogic.tBudgetPeriodOpeningBalance.Create();
                                bpob.BudgetPeriodID = bp.ObjectID;
                                bpob.AccountID = acc;
                            }
                            int count = bp.TotalNumberOfIntervals < 36 ? bp.TotalNumberOfIntervals : 36;

                            for (int i = 1; i <= count; i++)
                            {
                                try
                                {
                                    bpob.OpeningBalanceSet(i, Convert.ToDecimal(dr[i]));
                                }
                                catch (Exception ex)
                                {
                                    panel.Message = Resources.Errors.Budget_ExcelNotMatch;
                                    return;
                                }
                            }
                            bpob.CalculateTotal();
                            bp.BudgetPeriodOpeningBalances.Add(bpob);
                        }
                    }
                }
                panel.ObjectPanel.BindObjectToControls(bp);
                panelUpload.Visible = false;

            }
            catch (Exception ex) { panel.Message = ex.Message; }
        }
    }

    protected void btnUpload_Click(object sender, EventArgs e)
    {
        panelUpload.Visible = true;
    }

    protected void btnUploadCancel_Click(object sender, EventArgs e)
    {
        panelUpload.Visible = false;
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        this.ScriptManager.RegisterPostBackControl(btnUploadConfirm);
    }

    protected void gridBudgetPeriodOpeningBalances_Action(object sender, string commandName, List<object> dataKeys)
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

        function formatC(amount) {
            var delimiter = ","; // replace comma if desired
            s = new String(amount);
            var a = s.split('.', 2);
            while (a[0].indexOf(delimiter) >= 0)
            { a[0] = a[0].replace(delimiter, ''); }
            var i = parseInt(a[0]);
            var d = parseFloat("0." + a[1]);

            // round up to .00 precision	      
            d = parseInt((d + .005) * 100);
            d = d / 100;
            dStr = new String(d);

            if (dStr.indexOf('.') < 0) { dStr += '.00'; }
            if (dStr.indexOf('.') == (dStr.length - 2)) { dStr += '0'; }

            dStr = dStr.substring(dStr.indexOf("."))

            if (isNaN(i)) { return ''; }
            var minus = '';
            if (i < 0) { minus = '-'; }
            i = Math.abs(i);
            i = i + d;

            var iStr = new String(i);
            iStr = iStr.split('.', 2)[0];
            var b = [];
            while (iStr.length > 3) {
                var temp = iStr.substr(iStr.length - 3);
                b.unshift(temp);
                iStr = iStr.substr(0, iStr.length - 3);
            }
            if (iStr.length > 0) { b.unshift(iStr); }
            iStr = b.join(delimiter);
            s = minus + iStr + dStr;
            return s
        }

        function formatThis(id) {
            var input = document.getElementById(id);
            input.value = formatC(input.value);
        }

        function computeTotal(inputControlPrefix, totalControlId) {

            var inputs = document.getElementsByTagName("input");
            var total = 0.0;
            for (var i = 0; i < inputs.length; i++) {
                if (inputs[i].type == 'text' &&
                        inputs[i].name.indexOf(inputControlPrefix) >= 0 &&
                        inputs[i].id != totalControlId) {
                    var v = parseFloat(inputs[i].value.replace(/,/g, ""));
                    if (!isNaN(v)) {
                        inputs[i].value = formatC(inputs[i].value);
                        total += v;
                    }
                }
            }

            var totalControl = document.getElementById(totalControlId);
            //totalControl.value = Math.round(total);
            totalControl.value = formatC(total);
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
                                rowInputs[i].value = formatC(tavg);
                            else
                                rowInputs[i].value = formatC(tlast);
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

    <ui:uiobjectpanel runat="server" id="panelMain">
        <web:object runat="server" ID="panel" Caption="Budget Period" BaseTable="tBudgetPeriod" OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1" ></web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1" >
                <ui:UITabView ID="tabDetails" runat="server" Caption="Details" meta:resourcekey="tabDetailsResource1" >
                    <web:base ID="objectBase" runat="server" ObjectNameVisible="true" ObjectNumberVisible="false" ObjectNameCaption="Budget Period Name" ObjectNameValidateRequiredField="true" meta:resourcekey="objectBaseResource1" ></web:base>
                    <ui:UIPanel runat="server" ID="panelDetails" meta:resourcekey="panelDetailsResource1" >
                        <ui:UIFieldDropDownList runat="server" ID="dropBudget" PropertyName="BudgetID" Caption="Budget" ValidateRequiredField="true" OnSelectedIndexChanged="dropBudget_SelectedIndexChanged" meta:resourcekey="dropBudgetResource1" >
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDateTime runat="server" ID="dateStartDate" PropertyName="StartDate" 
                            Caption="Start Date" Span="Half" ValidateRequiredField="true" 
                            OnDateTimeChanged="dateStartDate_DateTimeChanged" ValidateDataTypeCheck="True" 
                            ValidationDataType="Date" meta:resourcekey="dateStartDateResource1" >
                        </ui:UIFieldDateTime>
                        <ui:UIFieldDateTime runat="server" ID="dateEndDate" PropertyName="EndDate" 
                            Caption="End Date" Span="Half" ValidateRequiredField="true" 
                            OnDateTimeChanged="dateEndDate_DateTimeChanged" ValidateCompareField="True" 
                            ValidateDataTypeCheck="True" ValidationCompareControl="dateStartDate" 
                            ValidationCompareOperator="GreaterThanEqual" ValidationCompareType="Date" 
                            ValidationDataType="Date" meta:resourcekey="dateEndDateResource1" >
                        </ui:UIFieldDateTime>
                        <ui:UIFieldTextBox runat="server" ID="textNumberOfMonthsPerInterval" 
                            PropertyName="NumberOfMonthsPerInterval" Caption="Months per Interval" 
                            ValidateRequiredField="true" Span="Half" 
                            OnTextChanged="textNumberOfMonthsPerInterval_TextChanged" 
                            ValidateDataTypeCheck="True" ValidateRangeField="True" 
                            ValidationDataType="Integer" ValidationRangeMax="36" ValidationRangeMin="0" 
                            ValidationRangeType="Integer" meta:resourcekey="textNumberOfMonthsPerIntervalResource1" >
                        </ui:UIFieldTextBox>
                    </ui:UIPanel>
                    <ui:UIHint runat="server" ID="hintNumberOfMonthsPerInterval" meta:resourcekey="hintNumberOfMonthsPerIntervalResource1" >
                            Each budget period (usually a yearly budget) can be broken down into 
                            further accounting periods (usually months). 
                            In the case of a yearly budget, the number of months per interval
                            is usually 1.
                            <br />
                            <br />
                            Please note that the total number of intervals (deduced from the entire
                            period of the budget divided by the number of months per interval) must
                            <b>not</b> be greater than 36.
                    </ui:UIHint>
                    <br />
                    <br />
                    <ui:UIPanel runat="server" ID="panelClosingDate" meta:resourcekey="panelClosingDateResource1" >
                        <ui:UIFieldDateTime runat="server" ID="dateClosingDate" PropertyName="ClosingDate" Caption="Closing Date" Span="Half" ValidateCompareField='true' ValidationCompareControl="dateEndDate" ValidationCompareOperator="GreaterThanEqual" ValidationCompareType="Date" meta:resourcekey="dateClosingDateResource1" >
                        </ui:UIFieldDateTime>
                        <ui:UIHint runat="server" ID="hintClosingDate" meta:resourcekey="hintClosingDateResource1" >
                            The closing date indicates the date that expenditures
                            can no longer be created against this budget period.
                        </ui:UIHint>
                        <br />
                    </ui:UIPanel>
                    <ui:UIPanel runat="server" ID="panelDetails2" meta:resourcekey="panelDetails2Resource1" >
                        <ui:UIButton runat="server" ID="buttonOpenNewBudgetPeriod" Text="Open new budget period" OnClick="buttonOpenNewBudgetPeriod_Click" ConfirmText="Are you sure you wish to open a new budget period? Please ensure that this budget period has been saved before opening a new budget period." ImageUrl="~/images/tick.gif"  meta:resourcekey="buttonOpenNewBudgetPeriodResource1" />
                        <br />
                        <br />
                        <ui:UIButton runat='server' ID="buttonShowBudgetView" Text="Show Budget View" ImageUrl="~/images/printer.gif" OnClick="buttonShowBudgetView_Click"  meta:resourcekey="buttonShowBudgetViewResource1" />
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView ID="tabBudgetAmounts" runat="server" Caption="Balances" meta:resourcekey="tabBudgetAmountsResource1" >
                    <ui:uipanel runat="server" id="panelExcel">
                        <ui:UIButton runat="server" ID="btnDownload" ImageUrl="~/images/download.png" Text="Download Excel template" OnClick="btnDownload_Click" AlwaysEnabled="true"  meta:resourcekey="btnDownloadResource1" />
                        <ui:UIButton runat="server" ID="btnUpload" Text="Upload Excel Data" ImageUrl="~/images/upload.png" OnClick="btnUpload_Click"  meta:resourcekey="btnUploadResource1" />
                        <br />
                        <ui:UIPanel runat="server" ID="panelUpload" Visible="false" BackColor="#FFFFCC" Height="25" meta:resourcekey="panelUploadResource1" >
                            <ui:UIFieldInputFile runat="server" ID="InputFile" Caption="Budget Adjustment" Width="50%" />
                            <ui:UIButton runat="server" ID="btnUploadConfirm" Text="Confirm" ImageUrl="~/images/tick.gif" OnClick="btnUploadConfirm_Click" ConfirmText="All existing budget opening amounts will be lost and new openings will be created based on the Excel spreadsheet. Are you sure you wish to continue?"  meta:resourcekey="btnUploadConfirmResource1" />
                            <ui:UIButton runat="server" ID="btnUploadCancel" Text="Cancel" ImageUrl="~/images/remove.gif" OnClick="btnUploadCancel_Click"  meta:resourcekey="btnUploadCancelResource1" />
                        </ui:UIPanel>
                    </ui:uipanel>
                    <br />
                    <ui:uiseparator runat="server" id="sep1" />
                    <br />
                    <ui:UIFieldTreeList runat="server" ID="treeAccount" Caption="Add Account" OnAcquireTreePopulater="treeAccount_AcquireTreePopulater" OnSelectedNodeChanged="treeAccount_SelectedNodeChanged" meta:resourcekey="treeAccountResource1" >
                    </ui:UIFieldTreeList>
                    <ui:uifieldlabel runat="server" id="labelBudgetTotal" PropertyName="BudgetTotal" Caption="Budget Total" DataFormatString="{0:n}" meta:resourcekey="labelBudgetTotalResource1"></ui:uifieldlabel>
                    <ui:UIGridView runat="server" ID="gridBudgetPeriodOpeningBalances" PageSize="1000" PropertyName="BudgetPeriodOpeningBalances" Caption="Opening Balances" BindObjectsToRows="true" OnRowDataBound="gridBudgetPeriodOpeningBalances_RowDataBound" SortExpression="Account.Path" OnAction="gridBudgetPeriodOpeningBalances_Action" meta:resourcekey="gridBudgetPeriodOpeningBalancesResource1" >
                        <Commands>
                            <ui:UIGridViewCommand CommandName="RemoveObject" CommandText="Remove Selected" ConfirmText="Are you sure you wish to remove the selected items?" ImageUrl="~/images/delete.gif" />
                        </Commands>
                        <Columns>
                            <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" ImageUrl="~/images/delete.gif" ConfirmText="Are you sure you want to remove this item?" meta:resourcekey="UIGridViewButtonColumnResource1" >
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewBoundColumn HeaderText="Account" PropertyName="Account.Path" ItemStyle-Width="200px" meta:resourcekey="UIGridViewBoundColumnResource1" >
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewTemplateColumn HeaderText="Is Active?" meta:resourcekey="UIGridViewTemplateColumnResource1" >
                                <ItemTemplate>
                                    <ui:UIFieldCheckBox runat="server" ID="checkIsActive" PropertyName="IsActive" Caption="Is Active?" ShowCaption="false" FieldLayout="Flow" meta:resourcekey="checkIsActiveResource1" >
                                    </ui:UIFieldCheckBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false" >
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textOpeningBalance01" ValidateRequiredField="true" PropertyName="OpeningBalance01" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="textOpeningBalance01Resource1" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false" >
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textOpeningBalance02" ValidateRequiredField="true" PropertyName="OpeningBalance02" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="textOpeningBalance02Resource1" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false" >
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textOpeningBalance03" ValidateRequiredField="true" PropertyName="OpeningBalance03" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="textOpeningBalance03Resource1" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false" >
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textOpeningBalance04" ValidateRequiredField="true" PropertyName="OpeningBalance04" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="textOpeningBalance04Resource1" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false" >
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textOpeningBalance05" ValidateRequiredField="true" PropertyName="OpeningBalance05" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="textOpeningBalance05Resource1" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false" >
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textOpeningBalance06" ValidateRequiredField="true" PropertyName="OpeningBalance06" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="textOpeningBalance06Resource1" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false" >
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textOpeningBalance07" ValidateRequiredField="true" PropertyName="OpeningBalance07" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="textOpeningBalance07Resource1" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false" >
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textOpeningBalance08" ValidateRequiredField="true" PropertyName="OpeningBalance08" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="textOpeningBalance08Resource1" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false" >
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textOpeningBalance09" ValidateRequiredField="true" PropertyName="OpeningBalance09" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="textOpeningBalance09Resource1" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false" >
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textOpeningBalance10" ValidateRequiredField="true" PropertyName="OpeningBalance10" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="textOpeningBalance10Resource1" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false" >
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textOpeningBalance11" ValidateRequiredField="true" PropertyName="OpeningBalance11" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="textOpeningBalance11Resource1" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false" >
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textOpeningBalance12" ValidateRequiredField="true" PropertyName="OpeningBalance12" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="textOpeningBalance12Resource1" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false" >
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textOpeningBalance13" ValidateRequiredField="true" PropertyName="OpeningBalance13" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="textOpeningBalance13Resource1" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false" >
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textOpeningBalance14" ValidateRequiredField="true" PropertyName="OpeningBalance14" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="textOpeningBalance14Resource1" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false" >
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textOpeningBalance15" ValidateRequiredField="true" PropertyName="OpeningBalance15" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="textOpeningBalance15Resource1" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false" >
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textOpeningBalance16" ValidateRequiredField="true" PropertyName="OpeningBalance16" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="textOpeningBalance16Resource1" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false" >
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textOpeningBalance17" ValidateRequiredField="true" PropertyName="OpeningBalance17" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="textOpeningBalance17Resource1" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false" >
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textOpeningBalance18" ValidateRequiredField="true" PropertyName="OpeningBalance18" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="textOpeningBalance18Resource1" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false" >
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textOpeningBalance19" ValidateRequiredField="true" PropertyName="OpeningBalance19" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="textOpeningBalance19Resource1" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false" >
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textOpeningBalance20" ValidateRequiredField="true" PropertyName="OpeningBalance20" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="textOpeningBalance20Resource1" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false" >
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textOpeningBalance21" ValidateRequiredField="true" PropertyName="OpeningBalance21" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="textOpeningBalance21Resource1" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false" >
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textOpeningBalance22" ValidateRequiredField="true" PropertyName="OpeningBalance22" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="textOpeningBalance22Resource1" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false" >
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textOpeningBalance23" ValidateRequiredField="true" PropertyName="OpeningBalance23" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="textOpeningBalance23Resource1" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false" >
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textOpeningBalance24" ValidateRequiredField="true" PropertyName="OpeningBalance24" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="textOpeningBalance24Resource1" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false" >
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textOpeningBalance25" ValidateRequiredField="true" PropertyName="OpeningBalance25" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="textOpeningBalance25Resource1" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false" >
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textOpeningBalance26" ValidateRequiredField="true" PropertyName="OpeningBalance26" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="textOpeningBalance26Resource1" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false" >
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textOpeningBalance27" ValidateRequiredField="true" PropertyName="OpeningBalance27" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="textOpeningBalance27Resource1" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false" >
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textOpeningBalance28" ValidateRequiredField="true" PropertyName="OpeningBalance28" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="textOpeningBalance28Resource1" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false" >
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textOpeningBalance29" ValidateRequiredField="true" PropertyName="OpeningBalance29" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="textOpeningBalance29Resource1" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false" >
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textOpeningBalance30" ValidateRequiredField="true" PropertyName="OpeningBalance30" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="textOpeningBalance30Resource1" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false" >
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textOpeningBalance31" ValidateRequiredField="true" PropertyName="OpeningBalance31" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="textOpeningBalance31Resource1" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false" >
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textOpeningBalance32" ValidateRequiredField="true" PropertyName="OpeningBalance32" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="textOpeningBalance32Resource1" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false" >
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textOpeningBalance33" ValidateRequiredField="true" PropertyName="OpeningBalance33" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="textOpeningBalance33Resource1" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false" >
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textOpeningBalance34" ValidateRequiredField="true" PropertyName="OpeningBalance34" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="textOpeningBalance34Resource1" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false" >
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textOpeningBalance35" ValidateRequiredField="true" PropertyName="OpeningBalance35" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="textOpeningBalance35Resource1" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false" >
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textOpeningBalance36" ValidateRequiredField="true" PropertyName="OpeningBalance36" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="textOpeningBalance36Resource1" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderText="Total" ItemStyle-BackColor="#eeeeee" meta:resourcekey="UIGridViewTemplateColumnResource38" >
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textTotalOpeningBalance" ValidateRequiredField="true" PropertyName="TotalOpeningBalance" Caption="Total" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="textTotalOpeningBalanceResource1" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn >
                                <ItemTemplate>
                                    <asp:HyperLink runat='server' ID="linkDistribute" NavigateUrl="javascript:void(0)" Text="Distribute" meta:resourcekey="linkDistributeResource1" ></asp:HyperLink>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                            <ui:UIGridViewTemplateColumn HeaderText="Threshold (%)" ItemStyle-BackColor="#eeeeee" meta:resourcekey="UIGridViewTemplateColumnResource40">
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textLowBudgetThreshold" ValidateRequiredField="true" PropertyName="LowBudgetThreshold" Caption="Threshold (%)" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="True" ValidationRangeMin="0" ValidationRangeMax="100" ValidationRangeType="Currency">
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </ui:UIGridViewTemplateColumn>
                        </Columns>
                    </ui:UIGridView>
                    <ui:UIObjectPanel runat="server" ID="panelbudgetperiod" meta:resourcekey="panelbudgetperiodResource1" >
                        <web:subpanel runat='server' ID="subpanelBudgetPeriod" GridViewID="gridBudgetPeriodOpeningBalances"  meta:resourcekey="subpanelBudgetPeriodResource1" />
                    </ui:UIObjectPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabMemo" Caption="Memo" meta:resourcekey="tabMemoResource1" >
                    <web:memo runat="server" ID="memo1" meta:resourcekey="memo1Resource1" ></web:memo>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabAttachments" Caption="Attachments" meta:resourcekey="tabAttachmentsResource1" >
                    <web:attachments runat="server" ID="attachments" meta:resourcekey="attachmentsResource1" ></web:attachments>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:uiobjectpanel>
    </form>
</body>
</html>
