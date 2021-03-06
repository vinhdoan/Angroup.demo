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
        dropBudgetPeriod.Bind(OBudgetPeriod.GetBudgetPeriodsByBudgetID(budgetAdjust.BudgetID, budgetAdjust.BudgetPeriodID));
        treeAccount.PopulateTree();

        if (budgetAdjust.BudgetAdjustmentDetails.Count > 0)
            InitializeGrid();
        
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

        panelDetails.Enabled = objectBase.CurrentObjectState.Is("Start", "Draft");
        tabAdjustment.Enabled = objectBase.CurrentObjectState.Is("Start", "Draft");
        
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
            }
            
            if (!panel.ObjectPanel.IsValid)
                return;

            // Save
            //
            budgetAdjustment.Save();
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

                panel.ObjectPanel.BindObjectToControls(budgetAdjustment);
                panel.Message = "";
            }
            else
                panel.Message = Resources.Errors.BudgetPeriod_UnableToAddDuplicateAccount;

            treeAccount.SelectedValue = "";
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

        dropBudgetPeriod.Bind(OBudgetPeriod.GetBudgetPeriodsByBudgetID(budgetId, null));
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
                        "computeTotal('" + e.Row.UniqueID + "','" + textTotalAmount.Control.ClientID + "'); ";
                }                
            }
            textTotalAmount.Control.Attributes["onchange"] = "formatThis('"+textTotalAmount.Control.ClientID+"');";
            HyperLink linkDistribute = e.Row.FindControl("linkDistribute") as HyperLink;
            if (linkDistribute != null)
            {
                
                linkDistribute.Attributes["onclick"] =
                    "distributeTotal('" + e.Row.UniqueID + "','" + textTotalAmount.Control.ClientID + "'," + numberOfColumns +  "); ";
            }
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
                    if (temp != null)
                        dr[j] = temp.OpeningBalanceGet(j).Value.ToString("#,##0.00");
                    else
                        dr[j] = "0.00";
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
                        if (acc == null)
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
                            if (bpob != null)
                            {
                                bool add = false;
                                int count = ba.BudgetPeriod.TotalNumberOfIntervals < 36 ? ba.BudgetPeriod.TotalNumberOfIntervals : 36;
                                
                                for (int i = 1; i <= count; i++)
                                {
                                    try
                                    {
                                        Decimal diff = Convert.ToDecimal(dr[i]) - (Decimal)bpob.OpeningBalanceGet(i);
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
            
            function formatThis(id)
            {
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
        <ui:UIObjectPanel runat="server" ID="panelMain" meta:resourcekey="panelMainResource1">
            <web:object runat="server" ID="panel" Caption="Budget Adjustment" BaseTable="tBudgetAdjustment"
                 OnValidateAndSave="panel_ValidateAndSave" OnPopulateForm="panel_OnPopulateForm" meta:resourcekey="panelResource1"></web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1">
                    <ui:UITabView ID="tabDetail" runat="server" Caption="Details" meta:resourcekey="tabDetailResource1">
                        <web:base ID="objectBase" runat="server" ObjectNumberEnabled="false" ObjectNameVisible="false" meta:resourcekey="objectBaseResource1">
                        </web:base>
                        <ui:UIPanel runat="server" ID="panelDetails" meta:resourcekey="panelDetailsResource1">
                        <ui:UIFieldCheckBox runat="server" ID="cbNewVersion" PropertyName="IsNewVersion" Caption="New Version" Text="Yes, this budget adjustment is considered a new version of the budget." meta:resourcekey="cbNewVersionResource1" ></ui:UIFieldCheckBox>
                        <ui:UIFieldDropDownList ID="dropBudget" runat="server" Caption="Budget" PropertyName="BudgetID" ValidateRequiredField="true"
                            ToolTip="Budget to be readjusted." Span="full" OnSelectedIndexChanged="dropBudget_SelectedIndexChanged" meta:resourcekey="dropBudgetResource1" />
                        <ui:UIFieldDropDownList ID="dropBudgetPeriod" runat="server" Caption="Budget Period" PropertyName="BudgetPeriodID" ValidateRequiredField="true"
                            ToolTip="Budget period to be readjusted." Span="full" OnSelectedIndexChanged="dropBudgetPeriod_SelectedIndexChanged" meta:resourcekey="dropBudgetPeriodResource1" />
                        <ui:UIFieldTextBox ID="textDescription" runat="server" Caption="Description"
                            PropertyName="Description" ToolTip="Description of the readjustment" meta:resourcekey="textDescriptionResource1" />
                        </ui:UIPanel>
                    </ui:UITabView>
                    <ui:UITabView ID="tabAdjustment" runat="server" Caption="Adjustment" meta:resourcekey="tabAdjustmentResource1">
                         <ui:UIButton runat="server" ID="btnDownload" ImageUrl="~/images/download.png" Text="Download Excel template" CausesValidation="false"  OnClick="btnDownload_Click" meta:resourcekey="btnDownloadResource1" />
                         <ui:UIButton runat="server" ID="btnUpload" Text="Upload Excel Data" ImageUrl="~/images/upload.png" OnClick="btnUpload_Click" CausesValidation="false" meta:resourcekey="btnUploadResource1" /><br />
                         <ui:UIPanel runat="server" ID="panelUpload" Visible="false" BackColor="#FFFFCC" Height="25" meta:resourcekey="panelUploadResource1" >
                            <ui:UIFieldInputFile runat="server" ID="InputFile" Caption="Budget Adjustment" Width="50%" meta:resourcekey="InputFileResource1" />
                            <ui:UIButton runat="server" ID="btnUploadConfirm" Text="Confirm" ImageUrl="~/images/tick.gif" OnClick="btnUploadConfirm_Click" CausesValidation="false" meta:resourcekey="btnUploadConfirmResource1"  
                            ConfirmText="All existing budget adjustment amounts will be lost and new adjustments will be created based on the Excel spreadsheet. Are you sure you wish to continue?" />
                            <ui:UIButton runat="server" ID="btnUploadCancel" Text="Cancel" ImageUrl="~/images/remove.gif" OnClick="btnUploadCancel_Click" CausesValidation="false" meta:resourcekey="btnUploadCancelResource1"/>                         
                        </ui:UIPanel>
                        <ui:uiseparator runat="server" id="sep1" meta:resourcekey="sep1Resource1" />
                        <ui:UIFieldTreeList runat="server" ID="treeAccount" Caption="Add Account" OnAcquireTreePopulater="treeAccount_AcquireTreePopulater" OnSelectedNodeChanged="treeAccount_SelectedNodeChanged" meta:resourcekey="treeAccountResource1"></ui:UIFieldTreeList>
                        <ui:UIGridView runat="server" ID="gridAdjustmentDetail" PropertyName="BudgetAdjustmentDetails" BindObjectsToRows="true"
                            ValidateRequiredField="true" Caption="Budget Adjustment Details" KeyName="ObjectID" OnRowDataBound="gridAdjustmentDetail_RowDataBound"  SortExpression="Account.Path" OnAction="gridAdjustmentDetail_Action" meta:resourcekey="gridAdjustmentDetailResource1">
                            <Commands>
                                <ui:UIGridViewCommand CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?"
                                    ImageUrl="~/images/delete.gif" CommandName="DeleteObject" meta:resourcekey="UIGridViewCommandResource1"></ui:UIGridViewCommand>                              
                            </Commands> 
                            <Columns>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif"  
                                    CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?" meta:resourcekey="UIGridViewButtonColumnResource1">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn HeaderText="Account" PropertyName="Account.Path" meta:resourcekey="UIGridViewBoundColumnResource1">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false" >
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval01Amount" ValidateRequiredField="true"
                                            PropertyName="Interval01Amount" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="False" ValidationRangeMin="0" ValidationRangeType="Currency"  meta:resourcekey="textInterval01AmountResource1"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false" >
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval02Amount" ValidateRequiredField="true"
                                            PropertyName="Interval02Amount" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="False" ValidationRangeMin="0" ValidationRangeType="Currency"  meta:resourcekey="textInterval02AmountResource1"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval03Amount" ValidateRequiredField="true"
                                            PropertyName="Interval03Amount" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="False" ValidationRangeMin="0" ValidationRangeType="Currency"  meta:resourcekey="textInterval03AmountResource1"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval04Amount" ValidateRequiredField="true"
                                            PropertyName="Interval04Amount" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="False" ValidationRangeMin="0" ValidationRangeType="Currency"  meta:resourcekey="textInterval04AmountResource1"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval05Amount" ValidateRequiredField="true"
                                            PropertyName="Interval05Amount" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="False" ValidationRangeMin="0" ValidationRangeType="Currency"  meta:resourcekey="textInterval05AmountResource1"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval06Amount" ValidateRequiredField="true"
                                            PropertyName="Interval06Amount" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="False" ValidationRangeMin="0" ValidationRangeType="Currency"  meta:resourcekey="textInterval06AmountResource1"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval07Amount" ValidateRequiredField="true"
                                            PropertyName="Interval07Amount" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="False" ValidationRangeMin="0" ValidationRangeType="Currency"  meta:resourcekey="textInterval07AmountResource1"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval08Amount" ValidateRequiredField="true"
                                            PropertyName="Interval08Amount" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="False" ValidationRangeMin="0" ValidationRangeType="Currency"  meta:resourcekey="textInterval08AmountResource1"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval09Amount" ValidateRequiredField="true"
                                            PropertyName="Interval09Amount" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="False" ValidationRangeMin="0" ValidationRangeType="Currency"  meta:resourcekey="textInterval09AmountResource1"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval10Amount" ValidateRequiredField="true"
                                            PropertyName="Interval10Amount" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="False" ValidationRangeMin="0" ValidationRangeType="Currency"  meta:resourcekey="textInterval10AmountResource1"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                
                                
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval11Amount" ValidateRequiredField="true"
                                            PropertyName="Interval11Amount" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="False" ValidationRangeMin="0" ValidationRangeType="Currency"  meta:resourcekey="textInterval11AmountResource1"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval12Amount" ValidateRequiredField="true"
                                            PropertyName="Interval12Amount" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="False" ValidationRangeMin="0" ValidationRangeType="Currency"  meta:resourcekey="textInterval12AmountResource1"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval13Amount" ValidateRequiredField="true"
                                            PropertyName="Interval13Amount" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="False" ValidationRangeMin="0" ValidationRangeType="Currency"  meta:resourcekey="textInterval13AmountResource1"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval14Amount" ValidateRequiredField="true"
                                            PropertyName="Interval14Amount" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="False" ValidationRangeMin="0" ValidationRangeType="Currency"  meta:resourcekey="textInterval14AmountResource1"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval15Amount" ValidateRequiredField="true"
                                            PropertyName="Interval15Amount" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="False" ValidationRangeMin="0" ValidationRangeType="Currency"  meta:resourcekey="textInterval15AmountResource1"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval16Amount" ValidateRequiredField="true"
                                            PropertyName="Interval16Amount" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="False" ValidationRangeMin="0" ValidationRangeType="Currency"  meta:resourcekey="textInterval16AmountResource1"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval17Amount" ValidateRequiredField="true"
                                            PropertyName="Interval17Amount" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="False" ValidationRangeMin="0" ValidationRangeType="Currency" ValidateRegexField="False"  meta:resourcekey="textInterval17AmountResource1"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval18Amount" ValidateRequiredField="true"
                                            PropertyName="Interval18Amount" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="False" ValidationRangeMin="0" ValidationRangeType="Currency"  meta:resourcekey="textInterval18AmountResource1"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval19Amount" ValidateRequiredField="true"
                                            PropertyName="Interval19Amount" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="False" ValidationRangeMin="0" ValidationRangeType="Currency"  meta:resourcekey="textInterval19AmountResource1"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval20Amount" ValidateRequiredField="true"
                                            PropertyName="Interval20Amount" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="False" ValidationRangeMin="0" ValidationRangeType="Currency"  meta:resourcekey="textInterval20AmountResource1"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>

                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval21Amount" ValidateRequiredField="true"
                                            PropertyName="Interval21Amount" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="False" ValidationRangeMin="0" ValidationRangeType="Currency"  meta:resourcekey="textInterval21AmountResource1"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval22Amount" ValidateRequiredField="true"
                                            PropertyName="Interval22Amount" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="False" ValidationRangeMin="0" ValidationRangeType="Currency"  meta:resourcekey="textInterval22AmountResource1"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval23Amount" ValidateRequiredField="true"
                                            PropertyName="Interval23Amount" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="False" ValidationRangeMin="0" ValidationRangeType="Currency"  meta:resourcekey="textInterval23AmountResource1"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval24Amount" ValidateRequiredField="true"
                                            PropertyName="Interval24Amount" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="False" ValidationRangeMin="0" ValidationRangeType="Currency"  meta:resourcekey="textInterval24AmountResource1"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval25Amount" ValidateRequiredField="true"
                                            PropertyName="Interval25Amount" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="False" ValidationRangeMin="0" ValidationRangeType="Currency"  meta:resourcekey="textInterval25AmountResource1"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval26Amount" ValidateRequiredField="true"
                                            PropertyName="Interval26Amount" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="False" ValidationRangeMin="0" ValidationRangeType="Currency"  meta:resourcekey="textInterval26AmountResource1"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval27Amount" ValidateRequiredField="true"
                                            PropertyName="Interval27Amount" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="False" ValidationRangeMin="0" ValidationRangeType="Currency"  meta:resourcekey="textInterval27AmountResource1"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval28Amount" ValidateRequiredField="true"
                                            PropertyName="Interval28Amount" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="False" ValidationRangeMin="0" ValidationRangeType="Currency"  meta:resourcekey="textInterval28AmountResource1"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval29Amount" ValidateRequiredField="true"
                                            PropertyName="Interval29Amount" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="False" ValidationRangeMin="0" ValidationRangeType="Currency"  meta:resourcekey="textInterval29AmountResource1"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval30Amount" ValidateRequiredField="true"
                                            PropertyName="Interval30Amount" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="False" ValidationRangeMin="0" ValidationRangeType="Currency"  meta:resourcekey="textInterval30AmountResource1"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>

                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval31Amount" ValidateRequiredField="true"
                                            PropertyName="Interval31Amount" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="False" ValidationRangeMin="0" ValidationRangeType="Currency"  meta:resourcekey="textInterval31AmountResource1"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval32Amount" ValidateRequiredField="true"
                                            PropertyName="Interval32Amount" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="False" ValidationRangeMin="0" ValidationRangeType="Currency"  meta:resourcekey="textInterval32AmountResource1"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval33Amount" ValidateRequiredField="true"
                                            PropertyName="Interval33Amount" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="False" ValidationRangeMin="0" ValidationRangeType="Currency"  meta:resourcekey="textInterval33AmountResource1"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval34Amount" ValidateRequiredField="true"
                                            PropertyName="Interval34Amount" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="False" ValidationRangeMin="0" ValidationRangeType="Currency"  meta:resourcekey="textInterval34AmountResource1"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval35Amount" ValidateRequiredField="true"
                                            PropertyName="Interval35Amount" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="False" ValidationRangeMin="0" ValidationRangeType="Currency"  meta:resourcekey="textInterval35AmountResource1"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderStyle-Font-Bold="false">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textInterval36Amount" ValidateRequiredField="true"  
                                            PropertyName="Interval36Amount" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="False" ValidationRangeMin="0" ValidationRangeType="Currency"  meta:resourcekey="textInterval36AmountResource1"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn HeaderText="Total" ItemStyle-BackColor="#eeeeee" meta:resourcekey="UIGridViewTemplateColumnResource1">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="textTotalAmount" ValidateRequiredField="true"
                                            PropertyName="TotalAmount" Caption="" ShowCaption="false" FieldLayout="Flow" DataFormatString="{0:#,##0.00}" ValidateDataTypeCheck="True" ValidationDataType="Currency" ValidateRangeField="False" ValidationRangeMin="0" ValidationRangeType="Currency"  meta:resourcekey="textTotalAmountResource1"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn>
                                    <ItemTemplate>
                                        <asp:HyperLink runat='server' ID="linkDistribute" NavigateUrl="javascript:void(0)" Text="Distribute" meta:resourcekey="linkDistributeResource1" ></asp:HyperLink>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                            </Columns>                                                       
                        </ui:UIGridView>
                        <ui:UIObjectPanel runat="server" ID="panelAdjustmentDetail"  meta:resourcekey="panelAdjustmentDetailResource1">
                            <web:subpanel runat='server' ID="subpanelAdjustmentDetail" GridViewID="gridAdjustmentDetail" />
                        </ui:UIObjectPanel>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Status History"   meta:resourcekey="uitabview1Resource1">
                        <web:ActivityHistory runat="server" ID="ActivityHistory" />
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabMemo" Caption="Memo"  meta:resourcekey="tabMemoResource1">
                        <web:memo runat="server" ID="memo1" meta:resourcekey="memo1Resource1"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView ID="tabAttachments" runat="server" Caption="Attachments"  meta:resourcekey="tabAttachmentsResource1">
                        <web:attachments runat="server" ID="attachments" meta:resourcekey="attachmentsResource1"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
