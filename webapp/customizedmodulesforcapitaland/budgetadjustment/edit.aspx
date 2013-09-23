<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.Common" %>
<%@ Import Namespace="System.Data.OleDb" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="LogicLayer" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">       
    
    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_OnPopulateForm(object sender, EventArgs e)
    {
        OBudgetAdjustment budgetAdjust = panel.SessionObject as OBudgetAdjustment;

        dropBudget.Bind(OBudget.GetAccessibleBugets(AppSession.User, budgetAdjust.BudgetID, "OBudgetAdjustment"));
        dropBudgetPeriod.Bind(OBudgetPeriod.GetOpenBudgetPeriodsByBudgetID(budgetAdjust.BudgetID, budgetAdjust.BudgetPeriodID));
        treeAccount.PopulateTree();

        if (budgetAdjust.BudgetAdjustmentDetails.Count > 0)
        {
            InitializeGrid();
            
            if(objectBase.CurrentObjectState.Is("Start", "Draft", "RejectedforRework"))
                budgetAdjust.ComputeBudgetSummary();
        }
        
        panel.ObjectPanel.BindObjectToControls(budgetAdjust);
    }

    /// <summary>
    /// Hides/shows elements
    /// Checks if item  exists at the budget adjustment detail grid:
    ///     1. if no: enable Location and Budget.
    ///     2. if yes: disable them.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        OBudgetAdjustment budgetAdjustment = panel.SessionObject as OBudgetAdjustment;

        tabAdjustment.Visible = dropBudget.SelectedIndex > 0 && dropBudgetPeriod.SelectedIndex > 0;

        dropBudget.Enabled = gridAdjustmentDetail.Rows.Count == 0;
        dropBudgetPeriod.Enabled = gridAdjustmentDetail.Rows.Count == 0;
        objectBase.ObjectNumberVisible = !budgetAdjustment.IsNew;

        panelDetails.Enabled = objectBase.CurrentObjectState.Is("Start", "Draft", "RejectedforRework");
        tabAdjustment.Enabled = objectBase.CurrentObjectState.Is("Start", "Draft", "RejectedforRework");

        gridAdjustmentDetailSummary.Visible = !objectBase.CurrentObjectState.Is("Committed", "Cancelled");
        
        panel.SpellCheckButtonVisible = budgetAdjustment.CurrentActivity == null || 
            budgetAdjustment.CurrentActivity.ObjectName.Is("Start", "Draft");
    }

    /// <summary>
    /// Validates and saves the budget readjustment object into the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OBudgetAdjustment budgetAdjustment = panel.SessionObject as OBudgetAdjustment;
            panel.ObjectPanel.BindControlsToObject(budgetAdjustment);

            // Validate
            if (objectBase.SelectedAction.Is("SubmitForApproval", "Approve"))
            {
                string listOfAccounts = ((OBudgetAdjustment)panel.SessionObject).CheckSufficientAvailableAmount();
                if (listOfAccounts != "")
                    gridAdjustmentDetail.ErrorMessage = String.Format(Resources.Errors.BudgetAdjustment_InsufficientAmount, listOfAccounts);

                // 2011.03.31
                // Kim Foong
                // Validates to ensure that total = monthly breakdown.
                //
                listOfAccounts = ((OBudgetAdjustment)panel.SessionObject).ValidateIntervalAmountsEqualTotal();
                if (listOfAccounts != "")
                    gridAdjustmentDetail.ErrorMessage = String.Format(Resources.Errors.BudgetAdjustment_IntervalAmountNotEqualsTotal, listOfAccounts);
                
            }
            
            if (!panel.ObjectPanel.IsValid)
                return;

            // Save
            //
            budgetAdjustment.Save();
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
    /// Occurs when the user selects a node in the account tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void treeAccount_SelectedNodeChanged(object sender, EventArgs e)
    {
        if (treeAccount.SelectedValue != "")
        {
            Guid accountId = new Guid(treeAccount.SelectedValue);

            OBudgetAdjustment budgetAdjustment = panel.SessionObject as OBudgetAdjustment;
            panel.ObjectPanel.BindControlsToObject(budgetAdjustment);

            if (budgetAdjustment.ValidateAccountIdDoesNotExist(accountId))
            {
                OBudgetAdjustmentDetail budgetAdjustmentDetail = TablesLogic.tBudgetAdjustmentDetail.Create();
                budgetAdjustmentDetail.AccountID = accountId;
                budgetAdjustment.BudgetAdjustmentDetails.Add(budgetAdjustmentDetail);

                if (gridAdjustmentDetail.Rows.Count == 0)
                    InitializeGrid();


                if (objectBase.CurrentObjectState.Is("Start", "Draft", "RejectedforRework"))
                    budgetAdjustment.ComputeBudgetSummary();

                panel.ObjectPanel.BindObjectToControls(budgetAdjustment);
                panel.Message = "";
            }
            else
                panel.Message = Resources.Errors.BudgetPeriod_UnableToAddDuplicateAccount;

            //treeAccount.SelectedValue = "";
        }
    }


    /// <summary>
    /// Initializes the opening balance GridView to show the 
    /// correct number of columns, and correct header texts.
    /// </summary>
    protected void InitializeGrid()
    {
        OBudgetAdjustment budgetAdjustment = panel.SessionObject as OBudgetAdjustment;

        if (budgetAdjustment.BudgetPeriod != null)
        {
            int numberOfMonthsPerInterval = budgetAdjustment.BudgetPeriod.NumberOfMonthsPerInterval.Value;
            int numberOfIntervals = budgetAdjustment.BudgetPeriod.TotalNumberOfIntervals;

            DateTime startDate = budgetAdjustment.BudgetPeriod.StartDate.Value;
            for (int i = 0; i < 36; i++)
            {
                if (i < numberOfIntervals)
                {
                    DateTime intervalStartDate = startDate.AddMonths(i);
                    gridAdjustmentDetail.Columns[i + 2].Visible = true;
                    if (intervalStartDate.Day == 1)
                        gridAdjustmentDetail.Columns[i + 2].HeaderText =
                            startDate.AddMonths(i * numberOfMonthsPerInterval).ToString("MMM-yyyy");
                    else
                        gridAdjustmentDetail.Columns[i + 2].HeaderText =
                            startDate.AddMonths(i * numberOfMonthsPerInterval).ToString("dd-MMM-yyyy");
                }
                else
                {
                    gridAdjustmentDetail.Columns[i + 2].Visible = false;
                }
            }
        }
    }


    /// <summary>
    /// Occurs when user mades selection on the budget drop down list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropBudget_SelectedIndexChanged(object sender, EventArgs e)
    {
        Guid? budgetId = null;
        if (dropBudget.SelectedValue != "")
            budgetId = new Guid(dropBudget.SelectedValue);

        dropBudgetPeriod.Bind(OBudgetPeriod.GetOpenBudgetPeriodsByBudgetID(budgetId, null));
    }


    int numberOfColumns = 0;

    /// <summary>
    /// Occurs when a row in the gridview is databound.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gridAdjustmentDetail_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowIndex == 0)
        {
            OBudgetAdjustment budgetAdjustment = panel.SessionObject as OBudgetAdjustment;
            numberOfColumns = budgetAdjustment.BudgetPeriod.TotalNumberOfIntervals;
        }

        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            UIFieldTextBox textTotalAmount = e.Row.FindControl("textTotalAmount") as UIFieldTextBox;                
            for (int i = 0; i < 36; i++)
            {
                UIFieldTextBox textIntervalAmount = e.Row.FindControl("textInterval" + String.Format("{0:00}", i) + "Amount") as UIFieldTextBox;
                if (textIntervalAmount != null)
                {
                    textIntervalAmount.Control.Attributes["onchange"] =
                        "computeTotal('" + e.Row.UniqueID + "','" + textTotalAmount.Control.ClientID + "','" + this.gridAdjustmentDetail.ID + "','lblTotalAdjustmentAmount'); ";
                }                
            }
            textTotalAmount.Control.Attributes["onchange"] = "formatThis('" + textTotalAmount.Control.ClientID + "','" + this.gridAdjustmentDetail.ID + "','lblTotalAdjustmentAmount');";
            HyperLink linkDistribute = e.Row.FindControl("linkDistribute") as HyperLink;
            if (linkDistribute != null)
            {
                
                linkDistribute.Attributes["onclick"] =
                    "distributeTotal('" + e.Row.UniqueID + "','" + textTotalAmount.Control.ClientID + "'," + numberOfColumns +  "); ";
            }

            e.Row.Cells[2].Text += "<img src='../../images/blank.gif' width='200px' height='1px' />";
        }
        else if (e.Row.RowType == DataControlRowType.Footer)
        {
            OBudgetAdjustment budgetAdjustment = panel.SessionObject as OBudgetAdjustment;
            e.Row.Cells[numberOfColumns + 2].Text = Resources.Strings.Capitaland_BudgetReallocation_FooterTotal;
            e.Row.Cells[39].ID = "lblTotalAdjustmentAmount";
            e.Row.Cells[39].Text = budgetAdjustment.TotalAdjustmentAmount.ToString("#,##0.00");
        }

    }

    
    /// <summary>
    /// Occurs when the user selects a budget period.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void dropBudgetPeriod_SelectedIndexChanged(object sender, EventArgs e)
    {

    }

    protected void btnDownload_Click(object sender, EventArgs e)
    {
        OBudgetAdjustment ba = panel.SessionObject as OBudgetAdjustment;
        panel.ObjectPanel.BindControlsToObject(ba);
        Guid id = Guid.NewGuid();
        string filePath = ConfigurationManager.AppSettings["ReportTempFolder"] + id.ToString().Replace("-", "") + ".xls";
        string worksheetname = "BudgetAdjustment";
        int compulsoryColumns = 0;
        DataTable dt = GenerateExcelData();

        OAttachment file = ExcelWriter.GenerateExcelFile(dt, filePath, worksheetname, compulsoryColumns);

        panel.FocusWindow = false;
        Window.Download(file.FileBytes, file.Filename, file.ContentType);
    }

    protected DataTable GenerateExcelData()
    {
        OBudgetAdjustment ba = panel.SessionObject as OBudgetAdjustment;
        int numberOfIntervals = ba.BudgetPeriod.TotalNumberOfIntervals;
        int numberOfMonthsPerInterval = ba.BudgetPeriod.NumberOfMonthsPerInterval.Value;
        DateTime startDate = ba.BudgetPeriod.StartDate.Value;
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
        
        // if user not selected any account, generate excel data for its budget period account
        // otherwise generate for selected account
        if (ba.BudgetAdjustmentDetails.Count == 0)
        {
            foreach (OBudgetPeriodOpeningBalance i in ba.BudgetPeriod.BudgetPeriodOpeningBalances)
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
            foreach (OBudgetAdjustmentDetail i in ba.BudgetAdjustmentDetails)
            {
                OBudgetPeriodOpeningBalance temp = ba.BudgetPeriod.BudgetPeriodOpeningBalances.Find((r) => r.AccountID == i.AccountID);
                DataRow dr = dt.NewRow();
                dr["Account"] = i.Account.Path;
                for (int j = 1; j <= numberOfIntervals; j++)
                {
                    Decimal approvedVariationAmount = (Decimal)Query.Select(TablesLogic.tBudgetVariationLog.VariationAmount.Sum())
                                                             .Where(TablesLogic.tBudgetVariationLog.BudgetID == ba.BudgetID &
                                                                     TablesLogic.tBudgetVariationLog.BudgetPeriodID == ba.BudgetPeriodID &
                                                                     TablesLogic.tBudgetVariationLog.AccountID == i.AccountID &
                                                                     TablesLogic.tBudgetVariationLog.IntervalNumber == j &
                                                                     TablesLogic.tBudgetVariationLog.VariationStatus == 1);
                    if (temp != null)
                        dr[j] = (temp.OpeningBalanceGet(j).Value + approvedVariationAmount).ToString("#,##0.00");
                    else
                        dr[j] = approvedVariationAmount.ToString("#,##0.00");
                }
                dt.Rows.Add(dr);
            }
        }
        
        DataView dv = dt.DefaultView;
        dv.Sort = "Account asc";
        return dv.ToTable();
    }

    protected void btnUpload_Click(object sender, EventArgs e)
    {
        panelUpload.Visible = true;
    }

    protected void btnUploadCancel_Click(object sender, EventArgs e)
    {
        panelUpload.Visible = false;
    }

    /// <summary>
    /// Upload Button Clicked, read Excel file and write into local harddisk
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnUploadConfirm_Click(object sender, EventArgs e)
    {
        panel.Message = "";
        OBudgetAdjustment ba = panel.SessionObject as OBudgetAdjustment;
        panel.ObjectPanel.BindControlsToObject(ba);

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
                    gridAdjustmentDetail.DataBind();
                    return;
                }
                int added = 0;
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
                        if (acc == Guid.Empty)
                        {
                            panel.Message = String.Format(Resources.Errors.General_ItemNotExist, dr["Account"].ToString());
                            return;
                        }
                        else
                        {
                            OBudgetAdjustmentDetail bad = ba.BudgetAdjustmentDetails
                                .Find((r) => r.AccountID == acc);
                            if (bad == null)
                            {
                                bad = TablesLogic.tBudgetAdjustmentDetail.Create();
                                bad.BudgetAdjustmentID = ba.ObjectID;
                                bad.AccountID = acc;
                            }
                            TBudgetPeriodOpeningBalance tbpob = TablesLogic.tBudgetPeriodOpeningBalance;
                            OBudgetPeriodOpeningBalance bpob = tbpob.Load(
                                tbpob.AccountID == bad.AccountID & tbpob.BudgetPeriodID == ba.BudgetPeriodID);
                            
                            // 2010.05.24
                            // Kim Foong
                            // Allow adding of a budget adjustment for an account
                            // that doesn't exist in the original budget period's opening
                            // balance.
                            //if (bpob != null)
                            {
                                bool add = false;
                                int count = ba.BudgetPeriod.TotalNumberOfIntervals < 36 ? ba.BudgetPeriod.TotalNumberOfIntervals : 36;
                                
                                for (int i = 1; i <= count; i++)
                                {
                                    try
                                    {
                                        // 2010.05.24
                                        // Kim Foong
                                        // If there budget period's opening balance record cannot be found,
                                        // then take it that the opening balance for that account is zero.
                                        //
                                        //Decimal diff = Convert.ToDecimal(dr[i]) - (Decimal)bpob.OpeningBalanceGet(i);
                                        Decimal diff = Convert.ToDecimal(dr[i]) - (bpob == null ? 0.0M : (Decimal)bpob.OpeningBalanceGet(i));
                                        diff = System.Decimal.Round(diff, 2, MidpointRounding.AwayFromZero);
                                        Decimal old = (Decimal)bad.IntervalAmountGet(i);                                        
                                        if (diff != old)
                                        {
                                            bad.IntervalAmountSet(i, diff);                                            
                                            add = true;
                                        }
                                    }
                                    catch (Exception ex)
                                    {
                                        panel.Message = Resources.Errors.Budget_ExcelNotMatch;
                                        return;     
                                    }                                    
                                }
                                bad.CalculateTotal();
                                if (!bad.IsZeroAdjustment())
                                {
                                    ba.BudgetAdjustmentDetails.Add(bad);
                                    added++;
                                }
                                else
                                    ba.BudgetAdjustmentDetails.Remove(bad);
                                
                                //if (add)
                                //{
                                //    bad.CalculateTotal();
                                //    ba.BudgetAdjustmentDetails.Add(bad);
                                //    added++;
                                //}
                                //else
                                //{
                                //    ba.BudgetAdjustmentDetails.Remove(bad);
                                //}
                            }
                        }
                    }
                }
                InitializeGrid();
                panel.ObjectPanel.BindObjectToControls(ba);
                panelUpload.Visible = false;
                panel.Message = String.Format(Resources.Errors.BudgetAdjustment_Added, added.ToString());
            }
            catch (Exception ex) { panel.Message = ex.Message; }
        }
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

    protected void Page_Load(object sender, EventArgs e)
    {
        this.ScriptManager.RegisterPostBackControl(btnUploadConfirm);
    }


    protected void gridAdjustmentDetail_Action(object sender, string commandName, List<object> dataKeys)
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
        
            function formatC(amount)
            {            
                var delimiter = ","; // replace comma if desired
                s = new String(amount);     
                var a = s.split('.',2);
                
                while (a[0].indexOf(delimiter) >= 0)  
                {a[0] = a[0].replace(delimiter,'');}
                var i = parseInt(a[0]);                
	            var d = parseFloat("0." + a[1]);
    	      
                // round up to .00 precision	      
	            d = parseInt((d + .005) * 100);
	            d = d / 100;
	            dStr = new String(d);
    	          
	            if(dStr.indexOf('.') < 0) { dStr += '.00'; }
	            if(dStr.indexOf('.') == (dStr.length - 2)) { dStr += '0'; }
    	        
	            dStr = dStr.substring(dStr.indexOf("."))
    	        
	            if(isNaN(i)) { return ''; }
	            var minus = '';
	            if(i < 0) { minus = '-'; }
	            i = Math.abs(i);
	            i = i +d;	         
    	        
	            var iStr = new String(i);
	            iStr = iStr.split('.',2)[0];
	            var b = [];
	            while(iStr.length > 3)
	            {
		            var temp = iStr.substr(iStr.length-3);
		            b.unshift(temp);
		            iStr = iStr.substr(0,iStr.length-3);
	            }
	            if(iStr.length > 0) { b.unshift(iStr); }
	            iStr = b.join(delimiter);
	            s = minus + iStr  + dStr;	        
	            return s
            }

            function formatThis(id, gridPrefix, totalPrefix) {

                var inputs = document.getElementsByTagName("input");
                var cells = document.getElementsByTagName("td");
                var totalAmount = 0.0;
                
                var input = document.getElementById(id);
                input.value = formatC(input.value);

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
                            inputs[i].value = formatC(inputs[i].value);
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
                //totalControl.value = Math.round(total);
                totalControl.value = formatC(total);

                for (var i = 0; i < cells.length; i++) {
                    if (cells[i].id.indexOf(totalPrefix) >= 0) {
                        cells[i].innerHTML = formatC(totalAmount);
                        break;
                    }
                }
            }

            function distributeTotal(inputControlPrefix, totalControlId, divisor) {
            
                var totalControl = document.getElementById(totalControlId);
                var t = parseFloat(totalControl.value.replace(/,/g, ""));

                
                        if (!isNaN(t)){ 
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
            }
        </script>
        <ui:UIObjectPanel runat="server" ID="panelMain" meta:resourcekey="panelMainResource1" BorderStyle="NotSet">
            <web:object runat="server" ID="panel" Caption="Budget Adjustment" BaseTable="tBudgetAdjustment" SpellCheckButtonVisible="true"
                 OnValidateAndSave="panel_ValidateAndSave" OnPopulateForm="panel_OnPopulateForm" meta:resourcekey="panelResource1"></web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1" BorderStyle="NotSet">
                    <ui:UITabView ID="tabDetail" runat="server" Caption="Details" meta:resourcekey="tabDetailResource1" BorderStyle="NotSet">
                        <web:base ID="objectBase" runat="server" ObjectNumberEnabled="false" ObjectNameVisible="false" meta:resourcekey="objectBaseResource1">
                        </web:base>
                        <ui:UIPanel runat="server" ID="panelDetails" meta:resourcekey="panelDetailsResource1" BorderStyle="NotSet">
                        <ui:UIFieldCheckBox runat="server" ID="cbNewVersion" PropertyName="IsNewVersion" Caption="New Version" Text="Yes, this budget adjustment is considered a new version of the budget." meta:resourcekey="cbNewVersionResource1" TextAlign="Right" ></ui:UIFieldCheckBox>
                        <ui:UIFieldTextBox runat="server" ID="textVersionName" PropertyName="VersionName" 
                                Caption="Version Name" InternalControlWidth="95%" 
                                meta:resourcekey="textVersionNameResource1"></ui:UIFieldTextBox>
                        <ui:UIFieldDropDownList ID="dropBudget" runat="server" Caption="Budget" PropertyName="BudgetID" ValidateRequiredField="True"
                            ToolTip="Budget to be readjusted." OnSelectedIndexChanged="dropBudget_SelectedIndexChanged" meta:resourcekey="dropBudgetResource1" />
                        <ui:UIFieldDropDownList ID="dropBudgetPeriod" runat="server" Caption="Budget Period" PropertyName="BudgetPeriodID" ValidateRequiredField="True"
                            ToolTip="Budget period to be readjusted." OnSelectedIndexChanged="dropBudgetPeriod_SelectedIndexChanged" meta:resourcekey="dropBudgetPeriodResource1" />
                        <ui:UIFieldRichTextBox ID="textDescription" runat="server" Caption="Description"
                            PropertyName="Description" ToolTip="Description of the readjustment" meta:resourcekey="textDescriptionResource1" EditorHeight="" />
                        </ui:UIPanel>
                    </ui:UITabView>
                    <ui:UITabView ID="tabAdjustment" runat="server" Caption="Adjustment" meta:resourcekey="tabAdjustmentResource1" BorderStyle="NotSet">
                         <ui:UIButton runat="server" ID="btnDownload" ImageUrl="~/images/download.png" Text="Download Excel template" CausesValidation="False"  OnClick="btnDownload_Click" meta:resourcekey="btnDownloadResource1" />
                         <ui:UIButton runat="server" ID="btnUpload" Text="Upload Excel Data" ImageUrl="~/images/upload.png" OnClick="btnUpload_Click" CausesValidation="False" meta:resourcekey="btnUploadResource1" /><br />
                         <ui:UIPanel runat="server" ID="panelUpload" Visible="False" BackColor="#FFFFCC" Height="25px" meta:resourcekey="panelUploadResource1" BorderStyle="NotSet" >
                            <ui:UIFieldInputFile runat="server" ID="InputFile" Caption="Budget Adjustment" Width="50%" meta:resourcekey="InputFileResource1" />
                            <ui:UIButton runat="server" ID="btnUploadConfirm" Text="Confirm" ImageUrl="~/images/tick.gif" OnClick="btnUploadConfirm_Click" CausesValidation="False" meta:resourcekey="btnUploadConfirmResource1"  
                            ConfirmText="All existing budget adjustment amounts will be lost and new adjustments will be created based on the Excel spreadsheet. Are you sure you wish to continue?" />
                            <ui:UIButton runat="server" ID="btnUploadCancel" Text="Cancel" ImageUrl="~/images/remove.gif" OnClick="btnUploadCancel_Click" CausesValidation="False" meta:resourcekey="btnUploadCancelResource1"/>                         
                        </ui:UIPanel>
                        <ui:uiseparator runat="server" id="sep1" meta:resourcekey="sep1Resource1" />
                        <ui:UIFieldTreeList runat="server" ID="treeAccount" Caption="Add Account" OnAcquireTreePopulater="treeAccount_AcquireTreePopulater" OnSelectedNodeChanged="treeAccount_SelectedNodeChanged" meta:resourcekey="treeAccountResource1" ShowCheckBoxes="None" TreeValueMode="SelectedNode"></ui:UIFieldTreeList>
                        <ui:UIGridView runat="server" ID="gridAdjustmentDetail" ShowFooter="True" 
                             PropertyName="BudgetAdjustmentDetails" BindObjectsToRows="True"
                            ValidateRequiredField="True" Caption="Budget Adjustment Details" 
                             KeyName="ObjectID" OnRowDataBound="gridAdjustmentDetail_RowDataBound"  
                             SortExpression="Account.Path" OnAction="gridAdjustmentDetail_Action" 
                             meta:resourcekey="gridAdjustmentDetailResource1" DataKeyNames="ObjectID" 
                             GridLines="Both" RowErrorColor="" style="clear:both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject" CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?" ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
                            </commands>
                            <Columns>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?" ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewButtonColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="Account.Path" HeaderText="Account" meta:resourceKey="UIGridViewBoundColumnResource1" PropertyName="Account.Path" ResourceAssemblyName="" SortExpression="Account.Path">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource39">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textInterval01Amount" runat="server" DataFormatString="{0:#,##0.00}" FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="textInterval01AmountResource1" PropertyName="Interval01Amount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource40">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textInterval02Amount" runat="server" DataFormatString="{0:#,##0.00}" FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="textInterval02AmountResource1" PropertyName="Interval02Amount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource41">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textInterval03Amount" runat="server" DataFormatString="{0:#,##0.00}" FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="textInterval03AmountResource1" PropertyName="Interval03Amount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource42">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textInterval04Amount" runat="server" DataFormatString="{0:#,##0.00}" FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="textInterval04AmountResource1" PropertyName="Interval04Amount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource43">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textInterval05Amount" runat="server" DataFormatString="{0:#,##0.00}" FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="textInterval05AmountResource1" PropertyName="Interval05Amount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource44">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textInterval06Amount" runat="server" DataFormatString="{0:#,##0.00}" FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="textInterval06AmountResource1" PropertyName="Interval06Amount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource45">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textInterval07Amount" runat="server" DataFormatString="{0:#,##0.00}" FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="textInterval07AmountResource1" PropertyName="Interval07Amount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource46">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textInterval08Amount" runat="server" DataFormatString="{0:#,##0.00}" FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="textInterval08AmountResource1" PropertyName="Interval08Amount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource47">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textInterval09Amount" runat="server" DataFormatString="{0:#,##0.00}" FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="textInterval09AmountResource1" PropertyName="Interval09Amount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource48">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textInterval10Amount" runat="server" DataFormatString="{0:#,##0.00}" FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="textInterval10AmountResource1" PropertyName="Interval10Amount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource49">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textInterval11Amount" runat="server" DataFormatString="{0:#,##0.00}" FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="textInterval11AmountResource1" PropertyName="Interval11Amount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource50">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textInterval12Amount" runat="server" DataFormatString="{0:#,##0.00}" FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="textInterval12AmountResource1" PropertyName="Interval12Amount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource51">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textInterval13Amount" runat="server" DataFormatString="{0:#,##0.00}" FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="textInterval13AmountResource1" PropertyName="Interval13Amount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource52">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textInterval14Amount" runat="server" DataFormatString="{0:#,##0.00}" FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="textInterval14AmountResource1" PropertyName="Interval14Amount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource53">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textInterval15Amount" runat="server" DataFormatString="{0:#,##0.00}" FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="textInterval15AmountResource1" PropertyName="Interval15Amount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource54">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textInterval16Amount" runat="server" DataFormatString="{0:#,##0.00}" FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="textInterval16AmountResource1" PropertyName="Interval16Amount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource55">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textInterval17Amount" runat="server" DataFormatString="{0:#,##0.00}" FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="textInterval17AmountResource1" PropertyName="Interval17Amount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource56">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textInterval18Amount" runat="server" DataFormatString="{0:#,##0.00}" FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="textInterval18AmountResource1" PropertyName="Interval18Amount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource57">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textInterval19Amount" runat="server" DataFormatString="{0:#,##0.00}" FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="textInterval19AmountResource1" PropertyName="Interval19Amount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource58">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textInterval20Amount" runat="server" DataFormatString="{0:#,##0.00}" FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="textInterval20AmountResource1" PropertyName="Interval20Amount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource59">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textInterval21Amount" runat="server" DataFormatString="{0:#,##0.00}" FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="textInterval21AmountResource1" PropertyName="Interval21Amount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource60">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textInterval22Amount" runat="server" DataFormatString="{0:#,##0.00}" FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="textInterval22AmountResource1" PropertyName="Interval22Amount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource61">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textInterval23Amount" runat="server" DataFormatString="{0:#,##0.00}" FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="textInterval23AmountResource1" PropertyName="Interval23Amount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource62">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textInterval24Amount" runat="server" DataFormatString="{0:#,##0.00}" FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="textInterval24AmountResource1" PropertyName="Interval24Amount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource63">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textInterval25Amount" runat="server" DataFormatString="{0:#,##0.00}" FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="textInterval25AmountResource1" PropertyName="Interval25Amount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource64">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textInterval26Amount" runat="server" DataFormatString="{0:#,##0.00}" FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="textInterval26AmountResource1" PropertyName="Interval26Amount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource65">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textInterval27Amount" runat="server" DataFormatString="{0:#,##0.00}" FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="textInterval27AmountResource1" PropertyName="Interval27Amount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource66">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textInterval28Amount" runat="server" DataFormatString="{0:#,##0.00}" FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="textInterval28AmountResource1" PropertyName="Interval28Amount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource67">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textInterval29Amount" runat="server" DataFormatString="{0:#,##0.00}" FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="textInterval29AmountResource1" PropertyName="Interval29Amount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource68">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textInterval30Amount" runat="server" DataFormatString="{0:#,##0.00}" FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="textInterval30AmountResource1" PropertyName="Interval30Amount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource69">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textInterval31Amount" runat="server" DataFormatString="{0:#,##0.00}" FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="textInterval31AmountResource1" PropertyName="Interval31Amount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource70">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textInterval32Amount" runat="server" DataFormatString="{0:#,##0.00}" FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="textInterval32AmountResource1" PropertyName="Interval32Amount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource71">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textInterval33Amount" runat="server" DataFormatString="{0:#,##0.00}" FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="textInterval33AmountResource1" PropertyName="Interval33Amount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource72">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textInterval34Amount" runat="server" DataFormatString="{0:#,##0.00}" FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="textInterval34AmountResource1" PropertyName="Interval34Amount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource73">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textInterval35Amount" runat="server" DataFormatString="{0:#,##0.00}" FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="textInterval35AmountResource1" PropertyName="Interval35Amount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource74">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textInterval36Amount" runat="server" DataFormatString="{0:#,##0.00}" FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="textInterval36AmountResource1" PropertyName="Interval36Amount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle Font-Bold="False" HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn HeaderText="Total" meta:resourceKey="UIGridViewTemplateColumnResource1">
                                    <ItemTemplate>
                                        <cc1:UIFieldTextBox ID="textTotalAmount" runat="server" DataFormatString="{0:#,##0.00}" FieldLayout="Flow" InternalControlWidth="60px" meta:resourceKey="textTotalAmountResource1" PropertyName="TotalAmount" ShowCaption="False" ValidateDataTypeCheck="True" ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMin="0" ValidationRangeType="Currency">
                                        </cc1:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle BackColor="#EEEEEE" HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn meta:resourcekey="UIGridViewTemplateColumnResource75">
                                    <ItemTemplate>
                                        <asp:HyperLink ID="linkDistribute" runat="server" meta:resourceKey="linkDistributeResource1" NavigateUrl="javascript:void(0)" Text="Distribute"></asp:HyperLink>
                                    </ItemTemplate>
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                            </Columns>
                        </ui:UIGridView>
                        <ui:UIObjectPanel runat="server" ID="panelAdjustmentDetail"  meta:resourcekey="panelAdjustmentDetailResource1" BorderStyle="NotSet">
                            <web:subpanel runat='server' ID="subpanelAdjustmentDetail" GridViewID="gridAdjustmentDetail" />
                        </ui:UIObjectPanel>
                        <br />
                        <br />
                        <ui:UIGridView runat="server" ID="gridAdjustmentDetailSummary" 
                             PropertyName="BudgetAdjustmentDetails" Caption="Budget Adjustment Details Summary As Of Now"
                            KeyName="ObjectID" DataKeyNames="ObjectID" GridLines="Both" 
                             meta:resourcekey="gridAdjustmentDetailSummaryResource1" RowErrorColor="" 
                             style="clear:both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Columns>
                                <cc1:UIGridViewBoundColumn DataField="Account.Path" HeaderText="Account" meta:resourceKey="UIGridViewBoundColumnResource1" PropertyName="Account.Path" ResourceAssemblyName="" SortExpression="Account.Path">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TotalOpeningBalance" DataFormatString="{0:#,##0.00}" HeaderText="(1) Opening Balance" meta:resourcekey="UIGridViewBoundColumnResource2" PropertyName="TotalOpeningBalance" ResourceAssemblyName="" SortExpression="TotalOpeningBalance">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TotalAdjustedAmount" DataFormatString="{0:#,##0.00}" HeaderText="(2) Adjusted Amount" meta:resourcekey="UIGridViewBoundColumnResource3" PropertyName="TotalAdjustedAmount" ResourceAssemblyName="" SortExpression="TotalAdjustedAmount">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TotalReallocatedAmount" DataFormatString="{0:#,##0.00}" HeaderText="(3) Reallocated Amount" meta:resourcekey="UIGridViewBoundColumnResource4" PropertyName="TotalReallocatedAmount" ResourceAssemblyName="" SortExpression="TotalReallocatedAmount">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TotalBalanceAfterVariation" DataFormatString="{0:#,##0.00}" HeaderText="(4) Total After Adjustments&lt;br /&gt;(1)+(2)+(3)" HtmlEncode="False" meta:resourcekey="UIGridViewBoundColumnResource5" PropertyName="TotalBalanceAfterVariation" ResourceAssemblyName="" SortExpression="TotalBalanceAfterVariation">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TotalPendingApproval" DataFormatString="{0:#,##0.00}" HeaderText="(5) Total Pending Approval" meta:resourcekey="UIGridViewBoundColumnResource6" PropertyName="TotalPendingApproval" ResourceAssemblyName="" SortExpression="TotalPendingApproval">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TotalApproved" DataFormatString="{0:#,##0.00}" HeaderText="(6) Total Approved" meta:resourcekey="UIGridViewBoundColumnResource7" PropertyName="TotalApproved" ResourceAssemblyName="" SortExpression="TotalApproved">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TotalDirectInvoicePendingApproval" DataFormatString="{0:#,##0.00}" HeaderText="(7) Total Direct Invoice Pending Approval" meta:resourcekey="UIGridViewBoundColumnResource8" PropertyName="TotalDirectInvoicePendingApproval" ResourceAssemblyName="" SortExpression="TotalDirectInvoicePendingApproval">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TotalDirectInvoiceApproved" DataFormatString="{0:#,##0.00}" HeaderText="(8) Total Direct Invoice Approved" meta:resourcekey="UIGridViewBoundColumnResource9" PropertyName="TotalDirectInvoiceApproved" ResourceAssemblyName="" SortExpression="TotalDirectInvoiceApproved">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TotalAvailableBalance" DataFormatString="{0:#,##0.00}" HeaderText="(9) Total Available&lt;br /&gt;(4)-(5)-(6)-(7)-(8)" HtmlEncode="False" meta:resourcekey="UIGridViewBoundColumnResource10" PropertyName="TotalAvailableBalance" ResourceAssemblyName="" SortExpression="TotalAvailableBalance">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Status History"   meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">
                        <web:ActivityHistory runat="server" ID="ActivityHistory" />
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabMemo" Caption="Memo"  meta:resourcekey="tabMemoResource1" BorderStyle="NotSet">
                        <web:memo runat="server" ID="memo1" meta:resourcekey="memo1Resource1"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView ID="tabAttachments" runat="server" Caption="Attachments"  meta:resourcekey="tabAttachmentsResource1" BorderStyle="NotSet">
                        <web:attachments runat="server" ID="attachments" meta:resourcekey="attachmentsResource1"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
