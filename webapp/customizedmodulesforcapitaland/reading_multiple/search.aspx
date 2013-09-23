<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto"
    EnableSessionState="True" meta:resourcekey="PageResource1" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.OleDb" %>
<%@ Import Namespace="Anacle.DataFramework" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">
    
    static ArrayList listPointID;
    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        dropOPCDAServer.Bind(OOPCDAServer.GetAllOPCDAServers());
        treeLocation.PopulateTree();
        treeEquipment.PopulateTree();
        panel.AddButtonVisible = false;
        panel.EditButtonVisible = false;

        tabExcelUpload.Visible = AppSession.User.AllowCreate("OReading");
        gridResults.Commands[0].Visible = AppSession.User.AllowCreate("OReading");

        if (DateTime.Today.Day <= OApplicationSetting.Current.PostingEndDay)
            dateApplicableMonth.DateTime = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1).AddMonths(0).AddDays(-1);
        else 
            dateApplicableMonth.DateTime = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1).AddMonths(1).AddDays(-1);

        dtExcelData = null;
    }


    /// <summary>
    /// Constructs the equipment tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeEquipment_AcquireTreePopulater(object sender)
    {
        return new EquipmentTreePopulater(null, true, true, Security.Decrypt(Request["TYPE"]));
    }

    /// <summary>
    /// Constructs the location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        return new LocationTreePopulaterForCapitaland(null, true, true, Security.Decrypt(Request["TYPE"]),false,false);
    }



    protected void gridResults_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "UpdateObject")
        {

            String str = "";
            if (dataKeys.Count == 0)
            {
                panel.Message = Resources.Errors.General_SelectOneOrMoreItemsToAdd;
                return;
            }
            foreach (object ob in dataKeys)
                str += (ob.ToString() + ";");
            Session["SelectedPoint"] = str;
            Window.Open("edit.aspx", "");
        }
        else if (commandName == "DownloadObject")
        {
            DownloadTemplate(dataKeys);
        }
    }

    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        e.CustomCondition = Query.True;
        if (treeEquipment.SelectedValue != "")
        {
            OEquipment oEquipment = TablesLogic.tEquipment[new Guid(treeEquipment.SelectedValue)];
            if (oEquipment != null)
                e.CustomCondition = e.CustomCondition & TablesLogic.tPoint.Equipment.HierarchyPath.Like(oEquipment.HierarchyPath + "%");

        }
        if (treeLocation.SelectedValue != "")
        {
            OLocation location = TablesLogic.tLocation[new Guid(treeLocation.SelectedValue)];
            if (location != null)
                e.CustomCondition = e.CustomCondition & (TablesLogic.tPoint.Location.HierarchyPath.Like(location.HierarchyPath + "%") | TablesLogic.tPoint.Equipment.Location.HierarchyPath.Like(location.HierarchyPath + "%"));
        }
        if (treeLocation.SelectedValue == "" && treeEquipment.SelectedValue == "")
        {
            ExpressionCondition locCondition = Query.False;
            ExpressionCondition eqptCondition = TablesLogic.tPoint.EquipmentID == null;
            foreach (OPosition position in AppSession.User.GetPositionsByObjectType("OReading"))
            {
                foreach (OLocation location in position.LocationAccess)
                    locCondition = locCondition | TablesLogic.tPoint.Location.HierarchyPath.Like(location.HierarchyPath + "%") | TablesLogic.tPoint.Equipment.Location.HierarchyPath.Like(location.HierarchyPath + "%");
                foreach (OEquipment equipment in position.EquipmentAccess)
                    eqptCondition = eqptCondition | TablesLogic.tPoint.Equipment.HierarchyPath.Like(equipment.HierarchyPath + "%");
            }
            e.CustomCondition = locCondition & eqptCondition;
        }

        e.CustomCondition = e.CustomCondition &
            TablesLogic.tPoint.IsActive == 1;

    }

    protected void DownloadTemplate(List<object> dataKeys)
    {
        if (dataKeys.Count == 0)
        {
            panel.Message = Resources.Errors.General_SelectOneOrMoreItemsToAdd;
            return;
        }
        Guid id = Guid.NewGuid();
        string filePath = ConfigurationManager.AppSettings["ReportTempFolder"] + id.ToString().Replace("-", "") + ".xls";
        string worksheetname = "PointReading";
        int compulsoryColumns = 0;
        DataTable dt = GenerateExcelData(dataKeys);

        OAttachment file = ExcelWriter.GenerateExcelFile(dt, filePath, worksheetname, compulsoryColumns);
        //panel.FocusWindow = false;
        Window.Download(file.FileBytes, file.Filename, file.ContentType);
    }

    protected DataTable GenerateExcelData(List<object> dataKeys)
    {
        DataTable dt = new DataTable();

        dt.Columns.Add("Location", typeof(String));
        dt.Columns.Add("Equipment", typeof(String));
        dt.Columns.Add("Point Name", typeof(String));
        dt.Columns.Add("Barcode", typeof(String));
        dt.Columns.Add("Last Reading Date");
        dt.Columns.Add("Last Reading Value");
        dt.Columns.Add("Reading Date");
        dt.Columns.Add("Reading Value");
        dt.Columns.Add("Tenant Name");
        dt.Columns.Add("Shop Name");
        dt.Columns.Add("Lease Start Date");
        dt.Columns.Add("Lease End Date");
        dt.Columns.Add("Lease Status");
        dt.Columns.Add("PointID", typeof(String));

        DateTime readingDate = DateTime.Today;
        if ((OApplicationSetting.Current.PostingStartDay <= DateTime.Today.Day && OApplicationSetting.Current.PostingEndDay >= DateTime.Today.Day))
            readingDate = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1, 23, 59, 59).AddDays(-1);

        for (int i = 0; i < dataKeys.Count; i++)
        {
            DataRow dr = dt.NewRow();
            OPoint pt = TablesLogic.tPoint.Load(new Guid(dataKeys[i].ToString()));
            OReading latestReading = pt.LatestReading;
            
            dr["Location"] = pt.Location != null ? pt.Location.Path : "";
            dr["Equipment"] = pt.Equipment != null ? pt.Equipment.Path : "";
            dr["Point Name"] = pt.ObjectName;
            dr["Tenant Name"] = pt.TenantName;
            dr["Shop Name"] = pt.TenantLease != null ? pt.TenantLease.ShopName : "";
            dr["Lease Start Date"] = pt.TenantLease != null ? pt.TenantLease.LeaseStartDate.Value.ToString("dd-MMM-yyyy") : null;
            dr["Lease End Date"] = pt.TenantLease != null ? pt.TenantLease.LeaseEndDate.Value.ToString("dd-MMM-yyyy") : null;
            dr["Lease Status"] = pt.TenantLease != null ? pt.TenantLease.Status : "";
            dr["Last Reading Date"] = latestReading != null ? latestReading.DateOfReading.Value.ToString("dd-MMM-yyyy") : "";
            dr["Last Reading Value"] = latestReading != null ? latestReading.Reading.Value.ToString() : pt.LastReading.ToString();
            dr["Reading Date"] = readingDate.ToString("dd-MMM-yyyy");
            dr["Barcode"] = pt.Barcode;
            dr["PointID"] = pt.ObjectID;
            dt.Rows.Add(dr);
        }

        DataView dv = dt.DefaultView;
        //if need sorting
        //dv.Sort = "Point Name asc";         
        return dv.ToTable();
    }

    
    /// <summary>
    /// Stores the excel upload in the session.
    /// </summary>
    private DataTable dtExcelData
    {
        get
        {
            return Session["dtExcelData"] as DataTable;
        }
        set
        {
            Session["dtExcelData"] = value;
        }
    }

    /// <summary>
    /// Validates utility values file which will be used to migrate utility values.
    /// </summary>
    /// <returns></returns>
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
    protected void Upload_Click(object sender, EventArgs e)
    {
        panel.Message = "";
        listPointID = new ArrayList();
        
        if (ValidateInputFile())
        {
            //read data from excel
            try
            {
                Guid id = Guid.NewGuid();
                string filePath = ConfigurationManager.AppSettings["ReportTempFolder"] + id.ToString().Replace("-", "") + ".xls";

                this.InputFile.Control.PostedFile.SaveAs(filePath);


                string connString = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + filePath + ";Extended Properties='Excel 8.0;HDR=Yes;IMEX=1;Notify=True'";

                OleDbCommand excelCommand = new OleDbCommand();
                OleDbDataAdapter excelDataAdapter = new OleDbDataAdapter();

                OleDbConnection excelConn = new OleDbConnection(connString);
                excelConn.Open();

                String sheetName = "";
                try
                {
                    dtExcelData = new DataTable();

                    dtExcelData.Columns.Add("Location", typeof(String));
                    dtExcelData.Columns.Add("Equipment", typeof(String));
                    dtExcelData.Columns.Add("Point Name", typeof(String));
                    dtExcelData.Columns.Add("Reading Date");
                    dtExcelData.Columns.Add("Reading Value");
                    dtExcelData.Columns.Add("LocationID", typeof(Guid));
                    dtExcelData.Columns.Add("EquipmentID", typeof(Guid));
                    dtExcelData.Columns.Add("Validation", typeof(String));
                    dtExcelData.Columns.Add("ObjectID", typeof(Guid));
                    dtExcelData.Columns.Add("PointID", typeof(String));
                    dtExcelData.Columns.Add("Index", typeof(int));

                    DataTable dtExcelSheets = new DataTable();
                    dtExcelSheets = excelConn.GetOleDbSchemaTable(OleDbSchemaGuid.Tables, null);
                    if (dtExcelSheets.Rows.Count > 0)
                    {
                        sheetName = dtExcelSheets.Rows[0]["TABLE_NAME"].ToString();
                    }
                    OleDbCommand OleCmdSelect = new OleDbCommand("SELECT * FROM [" + sheetName + "]", excelConn);
                    OleDbDataAdapter OleAdapter = new OleDbDataAdapter(OleCmdSelect);

                    OleAdapter.FillSchema(dtExcelData, System.Data.SchemaType.Source);
                    OleAdapter.Fill(dtExcelData);
                }
                catch (Exception ex)
                {
                    panel.Message = ex.Message;
                }
                finally
                {
                    excelConn.Close();
                }

                if (dtExcelData.Rows.Count == 0)
                {
                    panel.Message = Resources.Errors.Reading_EmptyFile;
                    dtExcelData.Clear();
                    gridUpload.DataBind();
                    return;
                }
                int i = 0;
                while (i < dtExcelData.Rows.Count)
                {
                    DataRow dr = dtExcelData.Rows[i];
                    if ((dr.IsNull("Location") || dr["Location"].ToString().Trim() == "")
                        && (dr.IsNull("Equipment") || dr["Equipment"].ToString().Trim() == "")
                        && (dr.IsNull("Point Name") || dr["Point Name"].ToString().Trim() == "")
                        && (dr.IsNull("PointID") || dr["PointID"].ToString().Trim() == ""))
                        dtExcelData.Rows.RemoveAt(i);
                    else
                    {
                        i++;
                        dr["ObjectID"] = dr["PointID"];
                    }
                }
                
                // Determine if the consumption is
                // 1.5 times greater than the previous
                // consumption.
                //
                foreach (DataRow dr in dtExcelData.Rows)
                {
                    try
                    {
                        Guid pointId = new Guid(dr["PointID"].ToString());
                        OPoint point = TablesLogic.tPoint.Load(pointId);
                        if (point != null)
                        {
                            OReading latestReading = point.LatestReading;
                            if (latestReading != null)
                            {
                                DateTime currentReadingDate = Convert.ToDateTime(dr["Reading Date"]);
                                decimal currentReadingValue = Convert.ToDecimal(dr["Reading Value"]);

                                decimal? currentConsumption = OReading.GetConsumption(pointId, currentReadingDate, currentReadingValue);
                                if (currentConsumption > latestReading.Consumption * 1.5M)
                                    listPointID.Add(pointId);
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                    }
                }
                
                gridUpload.DataSource = dtExcelData;
                gridUpload.DataBind();

                panelExcelUpload.Visible = false;
                panelExcelConfirm.Visible = true;
            }
            catch (Exception ex)
            {
                panel.Message = ex.Message;
            }
        }
    }

    /// <summary>
    /// Validates the Excel Data
    /// </summary>
    /// <returns>Boolean</returns>
    private Boolean ExcelDataError()
    {
        listPointID.Clear();    
        panel.Message = "";
        Boolean dataError = false;
        Boolean loc = false;
        Boolean eqp = false;
        String error;

        int count = 0;
        foreach (DataRow dr in dtExcelData.Rows)
        {
            count++;
            error = "";
            dr["Index"] = count;

            if (dr.IsNull("Reading Date"))
                error = Resources.Errors.Reading_DateOfReadingEmpty;
            try
            {
                DateTime date = Convert.ToDateTime(dr["Reading Date"]);
            }
            catch (Exception ex)
            {
                error = Resources.Errors.Reading_DateOfReadingNotValid;
            }

            if (dr.IsNull("Reading Value"))
                error = Resources.Errors.Reading_ReadingEmpty;
            try
            {
                Decimal value = Convert.ToDecimal(dr["Reading Value"]);
            }
            catch (Exception ex)
            {
                error = Resources.Errors.Reading_ReadingNotValid;
            }

            if (!(dr.IsNull("Location") || dr["Location"].ToString().Trim() == ""))
                loc = true;

            if (!(dr.IsNull("Equipment") || dr["Equipment"].ToString().Trim() == ""))
                eqp = true;

            if (loc && eqp)
            {
                error = Resources.Errors.Reading_LocationEquipmentEntered;
            }
            else
            {
                /*if (loc)
                {
                    dr["LocationID"] = OLocation.GetLocationByPath(dr["Location"].ToString());
                    if (dr["LocationID"].Equals(Guid.Empty))
                        error = Resources.Errors.Reading_LocationDoesNotExist;
                    else
                    {*/
                        OPoint point = 
                            TablesLogic.tPoint.Load(
                            TablesLogic.tPoint.ObjectID == dr["PointID"].ToString());
                        if (point == null)
                            error = Resources.Errors.Reading_PointDoesNotExist;
                        else
                        {
                            dr["PointID"] = point.ObjectID;
                            dr["ObjectID"] = point.ObjectID;
                            if (point.IsReadingWithTenantExist(null, Convert.ToDateTime(dr["Reading Date"]))
                                || point.IsReadingBackDate(null, Convert.ToDateTime(dr["Reading Date"])))
                            {
                                error = Resources.Messages.ReadingMultiple_DuplicateMonthWithTenantOrBackDate;
                            }
                        }
                    /*}
                }

                if (eqp)
                {
                    dr["EquipmentID"] = OEquipment.GetEquipmentByPath(dr["Equipment"].ToString());
                    if (dr["EquipmentID"].Equals(Guid.Empty))
                        error = Resources.Errors.Reading_EquipmentDoesNotExist;
                    else
                    {
                        OPoint point = TablesLogic.tPoint.Load(TablesLogic.tPoint.ObjectName == dr["Point Name"].ToString().Trim()
                            & TablesLogic.tPoint.EquipmentID == dr["EquipmentID"].ToString());
                        if (point == null)
                            error = Resources.Errors.Reading_PointDoesNotExist;
                        else
                        {
                            dr["PointID"] = point.ObjectID;
                            dr["ObjectID"] = point.ObjectID;
                            if (point.IsReadingWithTenantExist(Convert.ToDateTime(dr["Reading Date"]))
                                || point.IsReadingBackDate(Convert.ToDateTime(dr["Reading Date"])))
                            {
                                listPointID.Add(point.ObjectID);
                            }
                        }
                    }
                }
                */
                
                OReading reading = TablesLogic.tReading.Load(
                        TablesLogic.tReading.PointID == dr["PointID"] &
                        TablesLogic.tReading.DateOfReading == dr["Reading Date"]
                        );
                if (reading != null)
                    error = Resources.Errors.Reading_ReadingAlreadyExists;
            }

            dr["Validation"] = error;
            if (!error.Equals(""))
            {
                dataError = true;
                panel.Message = panel.Message + " " + count + "; ";
            }
        }

        if (dataError)
        {
            panel.Message = String.Format(Resources.Errors.ExcelUpload_UnableToUploadDueToErrors, panel.Message);
            gridUpload.DataSource = dtExcelData;
            gridUpload.DataBind();
        }

        return dataError;
    }
    
    
    
    

    protected void Save_Click(object sender, EventArgs e)
    {
        try
        {
            if (!ExcelDataError())
            {
                WriteToDB();
            }
            panelExcelUpload.Visible = true;
            panelExcelConfirm.Visible = false;
            dtExcelData = null;
        }
        catch (Exception ex)
        {
            panel.Message = ex.Message;
        }
    }

    /// <summary>
    /// Clear uploaded content
    /// </summary>
    protected void Clear_Click(object sender, EventArgs e)
    {
        panel.Message = Resources.Errors.ExcelUpload_UploadedDataCleared;
        gridUpload.DataBind();

        panelExcelUpload.Visible = true;
        panelExcelConfirm.Visible = false;
        dtExcelData = null;
    }

    /// <summary>
    /// Write Excel data into database
    /// </summary>
    protected void WriteToDB()
    {
        try
        {
            int count = 0;
            if (dtExcelData.Rows.Count == 0)
            {
                panel.Message = Resources.Errors.ExcelUpload_NoExcelUploaded;
            }
            else
            {
                using (Connection c = new Connection())
                {
                    foreach (DataRow dr in dtExcelData.Rows)
                    {
                        OPoint point = TablesLogic.tPoint.Load(new Guid(dr["PointID"].ToString()));
                        if (!point.IsReadingWithTenantExist(null, Convert.ToDateTime(dr["Reading Date"])) &&
                            !point.IsReadingBackDate(null, Convert.ToDateTime(dr["Reading Date"])))
                        {
                            OReading reading = TablesLogic.tReading.Create();
                            if(point.IsApplicableForLocation==1)
                            //if (!dr.IsNull("LocationID"))
                                reading.LocationID = point.LocationID;
                            else
                            //if (!dr.IsNull("EquipmentID"))
                                reading.EquipmentID = point.EquipmentID;
                            reading.DateOfReading = Convert.ToDateTime(dr["Reading Date"]);
                            reading.Reading = Convert.ToDecimal(dr["Reading Value"]);
                            reading.PointID = point.ObjectID;
                            reading.CheckForBreachOfReading(TablesLogic.tPoint.Load(reading.PointID));
                            reading.Save();
                            count++;
                        }
                    }
                    c.Commit();
                    panel.Message = Resources.Errors.ExcelUpload_UploadedSuccessfully;
                    gridUpload.DataSource = dtExcelData;
                    gridUpload.DataBind();
                    
                }
            }
        }
        catch (Exception ex)
        {
            throw ex;
        }
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        this.ScriptManager.RegisterPostBackControl(BtnUpload);
    }

    protected void gridResults_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        int count = 0;
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (gridResults.DataKeys[e.Row.RowIndex][0] != DBNull.Value)
            {
                OReading reading = TablesLogic.tReading.Load(new Guid(gridResults.DataKeys[e.Row.RowIndex][0].ToString()));
                if (reading != null)
                {
                    if (reading.Point != null)
                    {
                        if (reading.Point.TenantLease != null)
                        {
                            if (reading.Point.TenantLease.LeaseStatus != "N")
                            {
                                e.Row.BackColor = System.Drawing.Color.LightPink;
                                count++;
                            }
                        }
                    }
                }
            }
        }
        if (count > 0)
        {
            Hint.Visible = true;
            Hint.Text = String.Format(Resources.Messages.Reading_Hint, count);
        }
    }

    protected void gridUpload_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (listPointID != null)
            {
                if (listPointID.Contains(gridUpload.DataKeys[e.Row.RowIndex][0]))
                {
                    e.Row.BackColor = System.Drawing.Color.LightPink;
                    panel.Message = Resources.Messages.ReadingMultiple_Consumption1point5TimesGreaterThanPrevious;
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
    <form id="form2" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
        meta:resourcekey="panelMainResource1">
        <web:search runat="server" ID="panel" Caption="Reading (Multiple)" GridViewID="gridResults"
            BaseTable="tPoint" OnPopulateForm="panel_PopulateForm" SearchType="ObjectQuery"
            OnSearch="panel_Search" meta:resourcekey="panelResource1"></web:search>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabSearch" BorderStyle="NotSet" 
                meta:resourcekey="tabSearchResource1">
                <ui:UITabView runat="server" ID="uitabview3" Caption="Search" 
                    BorderStyle="NotSet" meta:resourcekey="uitabview3Resource1">
                    <ui:UIFieldDateTime runat="server" ID="dateApplicableMonth" 
                        Caption="Applicable Month" SelectMonthYear="true">
                    </ui:UIFieldDateTime>
                    <ui:UIFieldRadioList runat='server' ID="radioIsApplicableForLocation" PropertyName="IsApplicableForLocation"
                        Caption="Location/Equipment" 
                        meta:resourcekey="radioIsApplicableForLocationResource1" TextAlign="Right">
                        <Items>
                            <asp:ListItem Text="Any" Selected="True" meta:resourcekey="ListItemResource1"></asp:ListItem>
                            <asp:ListItem Value="1" Text="Location" meta:resourcekey="ListItemResource2"></asp:ListItem>
                            <asp:ListItem Value="0" Text="Equipment" meta:resourcekey="ListItemResource3"></asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>
                    <ui:uifieldtreelist runat="server" id="treeLocation" Caption="Location" 
                        OnAcquireTreePopulater="treeLocation_AcquireTreePopulater" 
                        meta:resourcekey="treeLocationResource1" ShowCheckBoxes="None" 
                        TreeValueMode="SelectedNode">
                    </ui:uifieldtreelist>
                    <ui:uifieldtreelist runat="server" id="treeEquipment" Caption="Equipment" 
                        OnAcquireTreePopulater="treeEquipment_AcquireTreePopulater" 
                        meta:resourcekey="treeEquipmentResource1" ShowCheckBoxes="None" 
                        TreeValueMode="SelectedNode">
                    </ui:uifieldtreelist>
                    <ui:UIFieldTextBox runat="server" ID="textObjectName" PropertyName="ObjectName" Caption="Point Name"
                        Span="Half" InternalControlWidth="95%" 
                        meta:resourcekey="textObjectNameResource1">
                    </ui:UIFieldTextBox>
                    <div style="clear: both">
                    </div>
                    <ui:UIFieldDropDownList runat="server" ID="dropOPCDAServer" PropertyName="OPCDAServerID"
                        Caption="OPC DA Server" meta:resourcekey="dropOPCDAServerResource1">
                    </ui:UIFieldDropDownList>
                    <ui:UIFieldTextBox runat="server" ID="textDescription" PropertyName="Description"
                        Caption="Description" InternalControlWidth="95%" 
                        meta:resourcekey="textDescriptionResource1">
                    </ui:UIFieldTextBox>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview4" Caption="Results" 
                    BorderStyle="NotSet" meta:resourcekey="uitabview4Resource1">
                    <ui:UIGridView runat="server" ID="gridResults" Caption="Results" KeyName="ObjectID"
                        Width="100%" OnAction="gridResults_Action" PageSize="1000" 
                        DataKeyNames="ObjectID" GridLines="Both" 
                        meta:resourcekey="gridResultsResource1" RowErrorColor="" 
                        style="clear:both;" OnRowDataBound="gridResults_RowDataBound" 
                        ImageRowErrorUrl="">
                        <PagerSettings Mode="NumericFirstLast" />
                        <commands>
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                CommandName="UpdateObject" CommandText="Add New Readings of Selected Points" 
                                ImageUrl="~/images/add.gif" meta:resourcekey="UIGridViewCommandResource1" />
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                CommandName="DownloadObject" CommandText="Download Excel Template" 
                                ImageUrl="~/images/download.png" 
                                meta:resourcekey="UIGridViewCommandResource2" />
                        </commands>
                        <Columns>
                            <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Name" 
                                meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="ObjectName" 
                                ResourceAssemblyName="" SortExpression="ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="OPCDAServer.ObjectName" 
                                HeaderText="OPC DA Server" meta:resourcekey="UIGridViewBoundColumnResource2" 
                                PropertyName="OPCDAServer.ObjectName" ResourceAssemblyName="" 
                                SortExpression="OPCDAServer.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Location.Path" HeaderText="Location" 
                                meta:resourcekey="UIGridViewBoundColumnResource3" PropertyName="Location.Path" 
                                ResourceAssemblyName="" SortExpression="Location.Path">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Equipment.Path" HeaderText="Equipment" 
                                meta:resourcekey="UIGridViewBoundColumnResource4" PropertyName="Equipment.Path" 
                                ResourceAssemblyName="" SortExpression="Equipment.Path">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="UnitOfMeasure.ObjectName" 
                                HeaderText="Unit Of Measure" meta:resourcekey="UIGridViewBoundColumnResource5" 
                                PropertyName="UnitOfMeasure.ObjectName" ResourceAssemblyName="" 
                                SortExpression="UnitOfMeasure.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            
                            <cc1:UIGridViewBoundColumn DataField="TenantName" 
                                HeaderText="Tenant Name" 
                                PropertyName="TenantName" ResourceAssemblyName="" 
                                SortExpression="TenantName" meta:resourcekey="UIGridViewBoundColumnResource12">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="TenantLease.ShopName" 
                                HeaderText="Shop Name" 
                                PropertyName="TenantLease.ShopName" ResourceAssemblyName="" 
                                SortExpression="TenantLease.ShopName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="TenantLease.LeaseStartDate" 
                                HeaderText="Lease Start Date" 
                                PropertyName="TenantLease.LeaseStartDate" ResourceAssemblyName="" 
                                SortExpression="TenantLease.LeaseStartDate" DataFormatString="{0:dd-MMM-yyyy}" meta:resourcekey="UIGridViewBoundColumnResource13">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="TenantLease.LeaseEndDate" 
                                HeaderText="Lease End Date" 
                                PropertyName="TenantLease.LeaseEndDate" ResourceAssemblyName="" 
                                SortExpression="TenantLease.LeaseEndDate" DataFormatString="{0:dd-MMM-yyyy}" meta:resourcekey="UIGridViewBoundColumnResource14">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="TenantLease.Status" 
                                HeaderText="Lease Status" 
                                PropertyName="TenantLease.Status" ResourceAssemblyName="" 
                                SortExpression="TenantLease.Status" meta:resourcekey="UIGridViewBoundColumnResource15">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabExcelUpload" Caption="Excel Upload" 
                    BorderStyle="NotSet" meta:resourcekey="tabExcelUploadResource1">
                    <ui:uipanel runat="server" id="panelExcelUpload" BorderStyle="NotSet" 
                        meta:resourcekey="panelExcelUploadResource1">
                        <ui:UIFieldInputFile runat="server" ID="InputFile" Caption="Point Readings" 
                            Span="Half" meta:resourcekey="InputFileResource1" />
                        <ui:UIButton runat="server" ID="BtnUpload" Text="Upload" OnClick="Upload_Click" 
                            ImageUrl="~/images/document-attach.gif" meta:resourcekey="BtnUploadResource1" />
                    </ui:uipanel>
                    <ui:uipanel runat="server" id="panelExcelConfirm" Visible="False" 
                        BorderStyle="NotSet" meta:resourcekey="panelExcelConfirmResource1">
                        <ui:uihint runat="server" id="hintExcelUpload" 
                            Text="Please review the data you have uploaded. You must click the 'Save' button to commit." 
                            meta:resourcekey="hintExcelUploadResource2" ></ui:uihint>
                        <ui:UIButton runat="server" ID="BtnSave" Text="Save" OnClick="Save_Click" 
                            ImageUrl="~/images/disk-big.gif" meta:resourcekey="BtnSaveResource1" />
                        <ui:UIButton runat="server" ID="BtnClear" Text="Clear" OnClick="Clear_Click" 
                            ImageUrl="~/images/Symbol-Refresh-big.gif" 
                            meta:resourcekey="BtnClearResource1" />
                    </ui:uipanel>
                    <ui:UIHint runat="server" ID="Hint" Visible="False" 
                        meta:resourcekey="HintResource2" >
                        
                    &nbsp;&nbsp;&nbsp;&nbsp;
                        
                    </ui:UIHint>
                    <ui:UIGridView runat="server" ID="gridUpload" Width="100%" 
                        CheckBoxColumnVisible="False" DataKeyNames="ObjectID" GridLines="Both" 
                        meta:resourcekey="gridUploadResource1" RowErrorColor="" 
                        style="clear:both;" OnRowDataBound="gridUpload_RowDataBound" 
                        Pagesize="1000" ImageRowErrorUrl="">
                        <PagerSettings Mode="NumericFirstLast" />
                        <Columns>
                            <cc1:UIGridViewBoundColumn DataField="Location" HeaderText="Location" 
                                meta:resourcekey="UIGridViewBoundColumnResource6" PropertyName="Location" 
                                ResourceAssemblyName="" SortExpression="Location">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Equipment" HeaderText="Equipment" 
                                meta:resourcekey="UIGridViewBoundColumnResource7" PropertyName="Equipment" 
                                ResourceAssemblyName="" SortExpression="Equipment">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Point Name" HeaderText="Point Name" 
                                meta:resourcekey="UIGridViewBoundColumnResource8" PropertyName="Point Name" 
                                ResourceAssemblyName="" SortExpression="Point Name">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Reading Date" 
                                DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}" HeaderText="Reading Date" 
                                meta:resourcekey="UIGridViewBoundColumnResource9" PropertyName="Reading Date" 
                                ResourceAssemblyName="" SortExpression="Reading Date">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Reading Value" HeaderText="Reading Value" 
                                meta:resourcekey="UIGridViewBoundColumnResource10" PropertyName="Reading Value" 
                                ResourceAssemblyName="" SortExpression="Reading Value">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Validation" HeaderText="Error" 
                                meta:resourcekey="UIGridViewBoundColumnResource11" PropertyName="Validation" 
                                ResourceAssemblyName="" SortExpression="Validation">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle ForeColor="Red" HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Tenant Name" 
                                HeaderText="Tenant Name" 
                                PropertyName="Tenant Name" ResourceAssemblyName="" 
                                SortExpression="Tenant Name" meta:resourcekey="UIGridViewBoundColumnResource16">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Shop Name" 
                                HeaderText="Shop Name" 
                                PropertyName="Shop Name" ResourceAssemblyName="" 
                                SortExpression="Shop Name">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Lease Start Date" 
                                HeaderText="Lease Start Date" 
                                PropertyName="Lease Start Date" ResourceAssemblyName="" 
                                SortExpression="Lease Start Date" DataFormatString="{0:dd-MMM-yyyy}" meta:resourcekey="UIGridViewBoundColumnResource17">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Lease End Date" 
                                HeaderText="Lease End Date" 
                                PropertyName="Lease End Date" ResourceAssemblyName="" 
                                SortExpression="Lease End Date" DataFormatString="{0:dd-MMM-yyyy}" meta:resourcekey="UIGridViewBoundColumnResource18">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Lease Status" 
                                HeaderText="Lease Status" 
                                PropertyName="Lease Status" ResourceAssemblyName="" 
                                SortExpression="Lease Status" meta:resourcekey="UIGridViewBoundColumnResource19">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
