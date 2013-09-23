<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" meta:resourcekey="PageResource1" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.Common" %>
<%@ Import Namespace="System.Data.OleDb" %>
<%@ Import Namespace="System.IO" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

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

            // 2010.05.13
            // Validates the total but only when submitting for approval.
            // 
            //
            if (objectBase.CurrentObjectState.Is("SubmitForApproval"))
            {
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
        OBudgetPeriod budgetPeriod = panel.SessionObject as OBudgetPeriod;
        
        int numberOfMonths = 0;
        base.OnPreRender(e);

        tabBudgetAmounts.Visible =
            dropBudget.SelectedIndex > 0 &&
            dateStartDate.DateTime != null &&
            dateEndDate.DateTime != null &&
            Int32.TryParse(textNumberOfMonthsPerInterval.Text, out numberOfMonths);

        panelDetails.Enabled = gridBudgetPeriodOpeningBalances.Rows.Count == 0 &&
            objectBase.CurrentObjectState.Is("Start", "Draft");

        treeAccount.Enabled =
            panelExcel.Enabled =
            objectBase.CurrentObjectState.Is("Start", "Draft") &&
            (budgetPeriod.IsActive == 0 || budgetPeriod.IsActive == null);

        panelClosingDate.Enabled = !objectBase.CurrentObjectState.Is("Cancelled");
        panelDetails2.Visible = !objectBase.CurrentObjectState.Is("Cancelled");

        bool enabled = objectBase.CurrentObjectState.Is("Start", "Draft") && (budgetPeriod.IsActive == 0 || budgetPeriod.IsActive == null);
        gridBudgetPeriodOpeningBalances.Commands[0].Visible = enabled;
        gridBudgetPeriodOpeningBalances.Columns[0].Visible = enabled;
        
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
            if (objectBase.CurrentObjectState.Is("Activated", "Close", "Cancelled", "PendingApproval") || budgetPeriod.IsActive == 1)
            {
                for (int i = 4; i < e.Row.Cells.Count; i++)
                    e.Row.Cells[i].Enabled = false;
            }

            e.Row.Cells[2].Text += "<img src='../../images/blank.gif' width='200px' height='1px' />";
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
        else
        {
            List<OAccount> listAccounts = TablesLogic.tAccount.LoadList(TablesLogic.tAccount.Type == 1);
            decimal? openingBalances = 0M;
            foreach (OAccount account in listAccounts)
            {
                DataRow dr = dt.NewRow();
                dr["Account"] = account.Path;
                for (int j = 1; j <= numberOfIntervals; j++)
                {
                    dr[j] = openingBalances.Value.ToString("#,##0.00");
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
            || !(this.InputFile.Control.PostedFile.FileName.ToLower().EndsWith(".xls") || this.InputFile.Control.PostedFile.FileName.ToLower().EndsWith(".xlsx"))
            )
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

        // 2010.07.12
        // Kim Foong
        // Must bind the controls to the budget period object
        // before upload. 
        //
        panel.ObjectPanel.BindControlsToObject(bp);

        if (ValidateInputFile())
        {
            //read data from excel
            try
            {
                Guid id = Guid.NewGuid();
                string filePath = ConfigurationManager.AppSettings["ReportTempFolder"] + id.ToString().Replace("-", "") + ".xls";

                this.InputFile.Control.PostedFile.SaveAs(filePath);
                DataTable dtExceldata = new DataTable();
                ExcelReader excelReader = new ExcelReader();
                
                dtExceldata = excelReader.LoadExcelFile(filePath);
                
                //string connString = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + filePath + ";Extended Properties='Excel 8.0;HDR=Yes;IMEX=1;Notify=True'";

                //OleDbCommand excelCommand = new OleDbCommand();
                //OleDbDataAdapter excelDataAdapter = new OleDbDataAdapter();

                //OleDbConnection excelConn = new OleDbConnection(connString);
                //excelConn.Open();

                //String sheetName = "";

                //DataTable dtExcelSheets = new DataTable();
                //dtExcelSheets = excelConn.GetOleDbSchemaTable(OleDbSchemaGuid.Tables, null);
                //if (dtExcelSheets.Rows.Count > 0)
                //{
                //    sheetName = dtExcelSheets.Rows[0]["TABLE_NAME"].ToString();
                //}
                //OleDbCommand OleCmdSelect = new OleDbCommand("SELECT * FROM [" + sheetName + "]", excelConn);
                //OleDbDataAdapter OleAdapter = new OleDbDataAdapter(OleCmdSelect);

                //OleAdapter.FillSchema(dtExceldata, System.Data.SchemaType.Source);
                //OleAdapter.Fill(dtExceldata);
                //excelConn.Close();

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
                        Guid acc = OAccount.GetAccountByPath(dr["Account"].ToString(), true);
                        
                        // 2011.02.07
                        // Kim Foong
                        // Fixed this bug to detect check for errorneous account.
                        //if (acc == null)
                        if (acc == Guid.Empty)
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
                                    // 2011.03.24
                                    // Kim Foong
                                    // Modified the error message to show a more friendly error.
                                    //
                                    panel.Message = String.Format(Resources.Errors.Budget_ExcelNotMatch, dr[i].ToString(), i, dr["Account"].ToString());
                                    return;
                                }
                            }
                            bpob.CalculateTotal();
                            bp.BudgetPeriodOpeningBalances.Add(bpob);
                        }
                    }
                }
                
                // 2011.02.07
                // Kim Foong
                // Updated this to initialize the budget period grid upon uploading of Excel template.
                InitializeOpeningBalanceGrid();
                
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
                if (err == "Err") {
                    alert(errMsg);
                }

            }
        }
    </script>

    <ui:uiobjectpanel runat="server" id="panelMain" BorderStyle="NotSet" 
        meta:resourcekey="panelMainResource1">
        <web:object runat="server" ID="panel" Caption="Budget Period" BaseTable="tBudgetPeriod" 
            OnPopulateForm="panel_PopulateForm" ShowWorkflowActionAsButtons="true" SaveButtonsVisible="false"
            OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1" ></web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" 
                meta:resourcekey="tabObjectResource1" BorderStyle="NotSet" >
                <ui:UITabView ID="tabDetails" runat="server" Caption="Details" 
                    meta:resourcekey="tabDetailsResource1" BorderStyle="NotSet" >
                    <web:base ID="objectBase" runat="server" ObjectNameVisible="true" ObjectNumberVisible="false" ObjectNameCaption="Budget Period Name" ObjectNameValidateRequiredField="true" meta:resourcekey="objectBaseResource1" ></web:base>
                    <ui:UIPanel runat="server" ID="panelDetails" 
                        meta:resourcekey="panelDetailsResource1" BorderStyle="NotSet" >
                        <ui:UIFieldDropDownList runat="server" ID="dropBudget" PropertyName="BudgetID" 
                            Caption="Budget" ValidateRequiredField="True" 
                            OnSelectedIndexChanged="dropBudget_SelectedIndexChanged" 
                            meta:resourcekey="dropBudgetResource1" >
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDateTime runat="server" ID="dateStartDate" PropertyName="StartDate" 
                            Caption="Start Date" Span="Half" ValidateRequiredField="True" 
                            OnDateTimeChanged="dateStartDate_DateTimeChanged" ValidateDataTypeCheck="True" 
                            ValidationDataType="Date" meta:resourcekey="dateStartDateResource1" 
                            ShowDateControls="True" >
                        </ui:UIFieldDateTime>
                        <ui:UIFieldDateTime runat="server" ID="dateEndDate" PropertyName="EndDate" 
                            Caption="End Date" Span="Half" ValidateRequiredField="True" 
                            OnDateTimeChanged="dateEndDate_DateTimeChanged" ValidateCompareField="True" 
                            ValidateDataTypeCheck="True" ValidationCompareControl="dateStartDate" 
                            ValidationCompareOperator="GreaterThanEqual" ValidationCompareType="Date" 
                            ValidationDataType="Date" meta:resourcekey="dateEndDateResource1" 
                            ShowDateControls="True" >
                        </ui:UIFieldDateTime>
                        <ui:UIFieldTextBox runat="server" ID="textNumberOfMonthsPerInterval" 
                            PropertyName="NumberOfMonthsPerInterval" Caption="Months per Interval" 
                            ValidateRequiredField="True" Span="Half" 
                            OnTextChanged="textNumberOfMonthsPerInterval_TextChanged" 
                            ValidateDataTypeCheck="True" ValidateRangeField="True" 
                            ValidationDataType="Integer" ValidationRangeMax="36" ValidationRangeMin="0" 
                            ValidationRangeType="Integer" 
                            meta:resourcekey="textNumberOfMonthsPerIntervalResource1" 
                            InternalControlWidth="95%" >
                        </ui:UIFieldTextBox>
                    </ui:UIPanel>
                    <ui:UIHint runat="server" ID="hintNumberOfMonthsPerInterval" 
                        meta:resourcekey="hintNumberOfMonthsPerIntervalResource1" 
                        Text="
                        &amp;nbsp;&amp;nbsp;&amp;nbsp;&amp;nbsp;&amp;nbsp;&amp;nbsp;Each budget period (usually a yearly budget) can be broken down into 
                        further accounting periods (usually months). In the case of a yearly budget, the 
                        number of months per interval is usually 1. &lt;br __designer:mapid=&quot;1446&quot; /&gt;
                        &lt;br __designer:mapid=&quot;1447&quot; /&gt;Please note that the total number of intervals (deduced from the entire period of the budget divided by the number of months per interval) must 
                        &lt;b __designer:mapid=&quot;1448&quot;&gt;not&lt;/b&gt; be greater than 36." >
                        </ui:UIHint>
                    <br />
                    <br />
                    <ui:UIPanel runat="server" ID="panelClosingDate" 
                        meta:resourcekey="panelClosingDateResource1" BorderStyle="NotSet" >
                        <ui:UIFieldDateTime runat="server" ID="dateClosingDate" 
                            PropertyName="ClosingDate" Caption="Closing Date" Span="Half" 
                            ValidateCompareField='True' ValidationCompareControl="dateEndDate" 
                            ValidationCompareOperator="GreaterThanEqual" ValidationCompareType="Date" 
                            meta:resourcekey="dateClosingDateResource1" ShowDateControls="True" >
                        </ui:UIFieldDateTime>
                        <ui:UIHint runat="server" ID="hintClosingDate" 
                            meta:resourcekey="hintClosingDateResource1" Text="
                            &amp;nbsp;&amp;nbsp;&amp;nbsp;&amp;nbsp;&amp;nbsp;&amp;nbsp;&amp;nbsp;The closing date indicates the date that expenditures can no longer 
                            be created against this budget period." >
                            </ui:UIHint>
                        <br />
                    </ui:UIPanel>
                    <ui:UIPanel runat="server" ID="panelDetails2" 
                        meta:resourcekey="panelDetails2Resource1" BorderStyle="NotSet" >
                        <ui:UIButton runat="server" ID="buttonOpenNewBudgetPeriod" Text="Open new budget period" OnClick="buttonOpenNewBudgetPeriod_Click" ConfirmText="Are you sure you wish to open a new budget period? Please ensure that this budget period has been saved before opening a new budget period." ImageUrl="~/images/tick.gif"  meta:resourcekey="buttonOpenNewBudgetPeriodResource1" />
                        <br />
                        <br />
                        <ui:UIButton runat='server' ID="buttonShowBudgetView" Text="Show Budget View" ImageUrl="~/images/printer.gif" OnClick="buttonShowBudgetView_Click"  meta:resourcekey="buttonShowBudgetViewResource1" />
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView ID="tabBudgetAmounts" runat="server" Caption="Balances" 
                    meta:resourcekey="tabBudgetAmountsResource1" BorderStyle="NotSet" >
                    <ui:uipanel runat="server" id="panelExcel" BorderStyle="NotSet" 
                        meta:resourcekey="panelExcelResource1">
                        <ui:UIButton runat="server" ID="btnDownload" ImageUrl="~/images/download.png" 
                            Text="Download Excel template" OnClick="btnDownload_Click" 
                            AlwaysEnabled="True"  meta:resourcekey="btnDownloadResource1" />
                        <ui:UIButton runat="server" ID="btnUpload" Text="Upload Excel Data" ImageUrl="~/images/upload.png" OnClick="btnUpload_Click"  meta:resourcekey="btnUploadResource1" />
                        <br />
                        <ui:UIPanel runat="server" ID="panelUpload" Visible="False" BackColor="#FFFFCC" 
                            Height="25px" meta:resourcekey="panelUploadResource1" BorderStyle="NotSet" >
                            <ui:UIFieldInputFile runat="server" ID="InputFile" Caption="Budget Adjustment" 
                                Width="50%" meta:resourcekey="InputFileResource1" />
                            <ui:UIButton runat="server" ID="btnUploadConfirm" Text="Confirm" ImageUrl="~/images/tick.gif" OnClick="btnUploadConfirm_Click" ConfirmText="All existing budget opening amounts will be lost and new openings will be created based on the Excel spreadsheet. Are you sure you wish to continue?"  meta:resourcekey="btnUploadConfirmResource1" />
                            <ui:UIButton runat="server" ID="btnUploadCancel" Text="Cancel" ImageUrl="~/images/remove.gif" OnClick="btnUploadCancel_Click"  meta:resourcekey="btnUploadCancelResource1" />
                        </ui:UIPanel>
                    </ui:uipanel>
                    <br />
                    <ui:uiseparator runat="server" id="sep1" meta:resourcekey="sep1Resource1" />
                    <br />
                    <ui:UIFieldTreeList runat="server" ID="treeAccount" Caption="Add Account" 
                        OnAcquireTreePopulater="treeAccount_AcquireTreePopulater" 
                        OnSelectedNodeChanged="treeAccount_SelectedNodeChanged" 
                        meta:resourcekey="treeAccountResource1" ShowCheckBoxes="None" 
                        TreeValueMode="SelectedNode" >
                    </ui:UIFieldTreeList>
                    <ui:uifieldlabel runat="server" id="labelBudgetTotal" PropertyName="BudgetTotal" Caption="Budget Total" DataFormatString="{0:n}" meta:resourcekey="labelBudgetTotalResource1"></ui:uifieldlabel>
                    <ui:UIGridView runat="server" ID="gridBudgetPeriodOpeningBalances" 
                        PageSize="1000" PropertyName="BudgetPeriodOpeningBalances" 
                        Caption="Opening Balances" BindObjectsToRows="True" 
                        OnRowDataBound="gridBudgetPeriodOpeningBalances_RowDataBound" 
                        SortExpression="Account.Path" OnAction="gridBudgetPeriodOpeningBalances_Action" 
                        meta:resourcekey="gridBudgetPeriodOpeningBalancesResource1" 
                        DataKeyNames="ObjectID" GridLines="Both" RowErrorColor="" 
                        style="clear:both;" >
                        <PagerSettings Mode="NumericFirstLast" />
                        <commands>
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                CommandName="RemoveObject" CommandText="Remove Selected" 
                                ConfirmText="Are you sure you wish to remove the selected items?" 
                                ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource1" />
                        </commands>
                        <Columns>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" 
                                ConfirmText="Are you sure you want to remove this item?" 
                                ImageUrl="~/images/delete.gif" 
                                meta:resourceKey="UIGridViewButtonColumnResource1">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewBoundColumn DataField="Account.Path" HeaderText="Account" 
                                PropertyName="Account.Path"
                                ResourceAssemblyName="" SortExpression="Account.Path" 
                                meta:resourcekey="UIGridViewBoundColumnResource2">
                                <HeaderStyle HorizontalAlign="Left" Width="200px" />
                                <ItemStyle HorizontalAlign="Left" Width="200px" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewTemplateColumn HeaderText="Is Active?" 
                                meta:resourceKey="UIGridViewTemplateColumnResource1">
                                <ItemTemplate>
                                    <cc1:UIFieldCheckBox ID="checkIsActive" runat="server" Caption="Is Active?" 
                                        FieldLayout="Flow" meta:resourceKey="checkIsActiveResource1" 
                                        PropertyName="IsActive" ShowCaption="False" TextAlign="Right">
                                    </cc1:UIFieldCheckBox>
                                </ItemTemplate>
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource2">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textOpeningBalance01" runat="server" 
                                        DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="60px" 
                                        meta:resourceKey="textOpeningBalance01Resource1" 
                                        PropertyName="OpeningBalance01" ShowCaption="False" 
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                        ValidateRequiredField="True" ValidationDataType="Currency" 
                                        ValidationRangeMin="0" ValidationRangeType="Currency">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource3">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textOpeningBalance02" runat="server" 
                                        DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="60px" 
                                        meta:resourceKey="textOpeningBalance02Resource1" 
                                        PropertyName="OpeningBalance02" ShowCaption="False" 
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                        ValidateRequiredField="True" ValidationDataType="Currency" 
                                        ValidationRangeMin="0" ValidationRangeType="Currency">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource4">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textOpeningBalance03" runat="server" 
                                        DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="60px" 
                                        meta:resourceKey="textOpeningBalance03Resource1" 
                                        PropertyName="OpeningBalance03" ShowCaption="False" 
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                        ValidateRequiredField="True" ValidationDataType="Currency" 
                                        ValidationRangeMin="0" ValidationRangeType="Currency">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource5">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textOpeningBalance04" runat="server" 
                                        DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="60px" 
                                        meta:resourceKey="textOpeningBalance04Resource1" 
                                        PropertyName="OpeningBalance04" ShowCaption="False" 
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                        ValidateRequiredField="True" ValidationDataType="Currency" 
                                        ValidationRangeMin="0" ValidationRangeType="Currency">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource6">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textOpeningBalance05" runat="server" 
                                        DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="60px" 
                                        meta:resourceKey="textOpeningBalance05Resource1" 
                                        PropertyName="OpeningBalance05" ShowCaption="False" 
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                        ValidateRequiredField="True" ValidationDataType="Currency" 
                                        ValidationRangeMin="0" ValidationRangeType="Currency">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource7">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textOpeningBalance06" runat="server" 
                                        DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="60px" 
                                        meta:resourceKey="textOpeningBalance06Resource1" 
                                        PropertyName="OpeningBalance06" ShowCaption="False" 
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                        ValidateRequiredField="True" ValidationDataType="Currency" 
                                        ValidationRangeMin="0" ValidationRangeType="Currency">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource8">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textOpeningBalance07" runat="server" 
                                        DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="60px" 
                                        meta:resourceKey="textOpeningBalance07Resource1" 
                                        PropertyName="OpeningBalance07" ShowCaption="False" 
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                        ValidateRequiredField="True" ValidationDataType="Currency" 
                                        ValidationRangeMin="0" ValidationRangeType="Currency">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource9">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textOpeningBalance08" runat="server" 
                                        DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="60px" 
                                        meta:resourceKey="textOpeningBalance08Resource1" 
                                        PropertyName="OpeningBalance08" ShowCaption="False" 
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                        ValidateRequiredField="True" ValidationDataType="Currency" 
                                        ValidationRangeMin="0" ValidationRangeType="Currency">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource10">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textOpeningBalance09" runat="server" 
                                        DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="60px" 
                                        meta:resourceKey="textOpeningBalance09Resource1" 
                                        PropertyName="OpeningBalance09" ShowCaption="False" 
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                        ValidateRequiredField="True" ValidationDataType="Currency" 
                                        ValidationRangeMin="0" ValidationRangeType="Currency">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource11">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textOpeningBalance10" runat="server" 
                                        DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="60px" 
                                        meta:resourceKey="textOpeningBalance10Resource1" 
                                        PropertyName="OpeningBalance10" ShowCaption="False" 
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                        ValidateRequiredField="True" ValidationDataType="Currency" 
                                        ValidationRangeMin="0" ValidationRangeType="Currency">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource12">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textOpeningBalance11" runat="server" 
                                        DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="60px" 
                                        meta:resourceKey="textOpeningBalance11Resource1" 
                                        PropertyName="OpeningBalance11" ShowCaption="False" 
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                        ValidateRequiredField="True" ValidationDataType="Currency" 
                                        ValidationRangeMin="0" ValidationRangeType="Currency">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource13">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textOpeningBalance12" runat="server" 
                                        DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="60px" 
                                        meta:resourceKey="textOpeningBalance12Resource1" 
                                        PropertyName="OpeningBalance12" ShowCaption="False" 
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                        ValidateRequiredField="True" ValidationDataType="Currency" 
                                        ValidationRangeMin="0" ValidationRangeType="Currency">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource14">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textOpeningBalance13" runat="server" 
                                        DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="60px" 
                                        meta:resourceKey="textOpeningBalance13Resource1" 
                                        PropertyName="OpeningBalance13" ShowCaption="False" 
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                        ValidateRequiredField="True" ValidationDataType="Currency" 
                                        ValidationRangeMin="0" ValidationRangeType="Currency">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource15">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textOpeningBalance14" runat="server" 
                                        DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="60px" 
                                        meta:resourceKey="textOpeningBalance14Resource1" 
                                        PropertyName="OpeningBalance14" ShowCaption="False" 
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                        ValidateRequiredField="True" ValidationDataType="Currency" 
                                        ValidationRangeMin="0" ValidationRangeType="Currency">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource16">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textOpeningBalance15" runat="server" 
                                        DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="60px" 
                                        meta:resourceKey="textOpeningBalance15Resource1" 
                                        PropertyName="OpeningBalance15" ShowCaption="False" 
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                        ValidateRequiredField="True" ValidationDataType="Currency" 
                                        ValidationRangeMin="0" ValidationRangeType="Currency">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource17">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textOpeningBalance16" runat="server" 
                                        DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="60px" 
                                        meta:resourceKey="textOpeningBalance16Resource1" 
                                        PropertyName="OpeningBalance16" ShowCaption="False" 
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                        ValidateRequiredField="True" ValidationDataType="Currency" 
                                        ValidationRangeMin="0" ValidationRangeType="Currency">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource18">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textOpeningBalance17" runat="server" 
                                        DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="60px" 
                                        meta:resourceKey="textOpeningBalance17Resource1" 
                                        PropertyName="OpeningBalance17" ShowCaption="False" 
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                        ValidateRequiredField="True" ValidationDataType="Currency" 
                                        ValidationRangeMin="0" ValidationRangeType="Currency">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource19">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textOpeningBalance18" runat="server" 
                                        DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="60px" 
                                        meta:resourceKey="textOpeningBalance18Resource1" 
                                        PropertyName="OpeningBalance18" ShowCaption="False" 
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                        ValidateRequiredField="True" ValidationDataType="Currency" 
                                        ValidationRangeMin="0" ValidationRangeType="Currency">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource20">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textOpeningBalance19" runat="server" 
                                        DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="60px" 
                                        meta:resourceKey="textOpeningBalance19Resource1" 
                                        PropertyName="OpeningBalance19" ShowCaption="False" 
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                        ValidateRequiredField="True" ValidationDataType="Currency" 
                                        ValidationRangeMin="0" ValidationRangeType="Currency">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource21">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textOpeningBalance20" runat="server" 
                                        DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="60px" 
                                        meta:resourceKey="textOpeningBalance20Resource1" 
                                        PropertyName="OpeningBalance20" ShowCaption="False" 
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                        ValidateRequiredField="True" ValidationDataType="Currency" 
                                        ValidationRangeMin="0" ValidationRangeType="Currency">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource22">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textOpeningBalance21" runat="server" 
                                        DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="60px" 
                                        meta:resourceKey="textOpeningBalance21Resource1" 
                                        PropertyName="OpeningBalance21" ShowCaption="False" 
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                        ValidateRequiredField="True" ValidationDataType="Currency" 
                                        ValidationRangeMin="0" ValidationRangeType="Currency">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource23">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textOpeningBalance22" runat="server" 
                                        DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="60px" 
                                        meta:resourceKey="textOpeningBalance22Resource1" 
                                        PropertyName="OpeningBalance22" ShowCaption="False" 
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                        ValidateRequiredField="True" ValidationDataType="Currency" 
                                        ValidationRangeMin="0" ValidationRangeType="Currency">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource24">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textOpeningBalance23" runat="server" 
                                        DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="60px" 
                                        meta:resourceKey="textOpeningBalance23Resource1" 
                                        PropertyName="OpeningBalance23" ShowCaption="False" 
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                        ValidateRequiredField="True" ValidationDataType="Currency" 
                                        ValidationRangeMin="0" ValidationRangeType="Currency">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource25">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textOpeningBalance24" runat="server" 
                                        DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="60px" 
                                        meta:resourceKey="textOpeningBalance24Resource1" 
                                        PropertyName="OpeningBalance24" ShowCaption="False" 
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                        ValidateRequiredField="True" ValidationDataType="Currency" 
                                        ValidationRangeMin="0" ValidationRangeType="Currency">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource26">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textOpeningBalance25" runat="server" 
                                        DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="60px" 
                                        meta:resourceKey="textOpeningBalance25Resource1" 
                                        PropertyName="OpeningBalance25" ShowCaption="False" 
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                        ValidateRequiredField="True" ValidationDataType="Currency" 
                                        ValidationRangeMin="0" ValidationRangeType="Currency">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource27">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textOpeningBalance26" runat="server" 
                                        DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="60px" 
                                        meta:resourceKey="textOpeningBalance26Resource1" 
                                        PropertyName="OpeningBalance26" ShowCaption="False" 
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                        ValidateRequiredField="True" ValidationDataType="Currency" 
                                        ValidationRangeMin="0" ValidationRangeType="Currency">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource28">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textOpeningBalance27" runat="server" 
                                        DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="60px" 
                                        meta:resourceKey="textOpeningBalance27Resource1" 
                                        PropertyName="OpeningBalance27" ShowCaption="False" 
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                        ValidateRequiredField="True" ValidationDataType="Currency" 
                                        ValidationRangeMin="0" ValidationRangeType="Currency">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource29">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textOpeningBalance28" runat="server" 
                                        DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="60px" 
                                        meta:resourceKey="textOpeningBalance28Resource1" 
                                        PropertyName="OpeningBalance28" ShowCaption="False" 
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                        ValidateRequiredField="True" ValidationDataType="Currency" 
                                        ValidationRangeMin="0" ValidationRangeType="Currency">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource30">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textOpeningBalance29" runat="server" 
                                        DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="60px" 
                                        meta:resourceKey="textOpeningBalance29Resource1" 
                                        PropertyName="OpeningBalance29" ShowCaption="False" 
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                        ValidateRequiredField="True" ValidationDataType="Currency" 
                                        ValidationRangeMin="0" ValidationRangeType="Currency">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource31">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textOpeningBalance30" runat="server" 
                                        DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="60px" 
                                        meta:resourceKey="textOpeningBalance30Resource1" 
                                        PropertyName="OpeningBalance30" ShowCaption="False" 
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                        ValidateRequiredField="True" ValidationDataType="Currency" 
                                        ValidationRangeMin="0" ValidationRangeType="Currency">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource32">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textOpeningBalance31" runat="server" 
                                        DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="60px" 
                                        meta:resourceKey="textOpeningBalance31Resource1" 
                                        PropertyName="OpeningBalance31" ShowCaption="False" 
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                        ValidateRequiredField="True" ValidationDataType="Currency" 
                                        ValidationRangeMin="0" ValidationRangeType="Currency">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource33">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textOpeningBalance32" runat="server" 
                                        DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="60px" 
                                        meta:resourceKey="textOpeningBalance32Resource1" 
                                        PropertyName="OpeningBalance32" ShowCaption="False" 
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                        ValidateRequiredField="True" ValidationDataType="Currency" 
                                        ValidationRangeMin="0" ValidationRangeType="Currency">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource34">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textOpeningBalance33" runat="server" 
                                        DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="60px" 
                                        meta:resourceKey="textOpeningBalance33Resource1" 
                                        PropertyName="OpeningBalance33" ShowCaption="False" 
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                        ValidateRequiredField="True" ValidationDataType="Currency" 
                                        ValidationRangeMin="0" ValidationRangeType="Currency">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource35">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textOpeningBalance34" runat="server" 
                                        DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="60px" 
                                        meta:resourceKey="textOpeningBalance34Resource1" 
                                        PropertyName="OpeningBalance34" ShowCaption="False" 
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                        ValidateRequiredField="True" ValidationDataType="Currency" 
                                        ValidationRangeMin="0" ValidationRangeType="Currency">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource36">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textOpeningBalance35" runat="server" 
                                        DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="60px" 
                                        meta:resourceKey="textOpeningBalance35Resource1" 
                                        PropertyName="OpeningBalance35" ShowCaption="False" 
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                        ValidateRequiredField="True" ValidationDataType="Currency" 
                                        ValidationRangeMin="0" ValidationRangeType="Currency">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource37">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textOpeningBalance36" runat="server" 
                                        DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="60px" 
                                        meta:resourceKey="textOpeningBalance36Resource1" 
                                        PropertyName="OpeningBalance36" ShowCaption="False" 
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                        ValidateRequiredField="True" ValidationDataType="Currency" 
                                        ValidationRangeMin="0" ValidationRangeType="Currency">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn HeaderText="Total" 
                                meta:resourceKey="UIGridViewTemplateColumnResource38">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textTotalOpeningBalance" runat="server" Caption="Total" 
                                        DataFormatString="{0:n}" FieldLayout="Flow" InternalControlWidth="60px" 
                                        meta:resourceKey="textTotalOpeningBalanceResource1" 
                                        PropertyName="TotalOpeningBalance" ShowCaption="False" 
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                        ValidateRequiredField="True" ValidationDataType="Currency" 
                                        ValidationRangeMin="0" ValidationRangeType="Currency">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle BackColor="#EEEEEE" HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource39">
                                <ItemTemplate>
                                    <asp:HyperLink ID="linkDistribute" runat="server" 
                                        meta:resourceKey="linkDistributeResource1" NavigateUrl="javascript:void(0)" 
                                        Text="Distribute"></asp:HyperLink>
                                </ItemTemplate>
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn HeaderText="Threshold (%)" 
                                meta:resourceKey="UIGridViewTemplateColumnResource40">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="textLowBudgetThreshold" runat="server" 
                                        Caption="Threshold (%)" DataFormatString="{0:n}" FieldLayout="Flow" 
                                        InternalControlWidth="50px" meta:resourcekey="textLowBudgetThresholdResource1" 
                                        PropertyName="LowBudgetThreshold" ShowCaption="False" 
                                        ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                        ValidateRequiredField="True" ValidationDataType="Currency" 
                                        ValidationRangeMax="100" ValidationRangeMin="0" ValidationRangeType="Currency">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle BackColor="#EEEEEE" HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                        </Columns>
                    </ui:UIGridView>
                    <ui:UIObjectPanel runat="server" ID="panelbudgetperiod" 
                        meta:resourcekey="panelbudgetperiodResource1" BorderStyle="NotSet" >
                        <web:subpanel runat='server' ID="subpanelBudgetPeriod" GridViewID="gridBudgetPeriodOpeningBalances"  meta:resourcekey="subpanelBudgetPeriodResource1" />
                    </ui:UIObjectPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview1" Caption="Status History" meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">
                    <web:ActivityHistory runat="server" ID="ActivityHistory"  meta:resourcekey="ActivityHistoryResource1" />
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabMemo" Caption="Memo" 
                    meta:resourcekey="tabMemoResource1" BorderStyle="NotSet" >
                    <web:memo runat="server" ID="memo1" meta:resourcekey="memo1Resource1" ></web:memo>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabAttachments" Caption="Attachments" 
                    meta:resourcekey="tabAttachmentsResource1" BorderStyle="NotSet" >
                    <web:attachments runat="server" ID="attachments" meta:resourcekey="attachmentsResource1" ></web:attachments>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:uiobjectpanel>
    </form>
</body>
</html>
