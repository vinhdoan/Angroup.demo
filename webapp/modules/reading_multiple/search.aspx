<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto"
    EnableSessionState="True" meta:resourcekey="PageResource1" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.OleDb" %>
<%@ Import Namespace="Anacle.DataFramework" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">
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
        return new LocationTreePopulater(null, true, true, Security.Decrypt(Request["TYPE"]));
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
        
        // 2010.05.27
        // Kim Foong
        // Only show the Points that are active.
        //
        e.CustomCondition = e.CustomCondition & TablesLogic.tPoint.IsActive == 1;
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
        dt.Columns.Add("Reading Date");
        dt.Columns.Add("Reading Value");
        for (int i = 0; i < dataKeys.Count; i++)
        {
            DataRow dr = dt.NewRow();
            OPoint pt = TablesLogic.tPoint.Load(new Guid(dataKeys[i].ToString()));
            dr["Location"] = pt.Location != null ? pt.Location.Path : "";
            dr["Equipment"] = pt.Equipment != null ? pt.Equipment.Path : "";
            dr["Point Name"] = pt.ObjectName;
            dt.Rows.Add(dr);
        }

        DataView dv = dt.DefaultView;
        //if need sorting
        //dv.Sort = "Point Name asc";         
        return dv.ToTable();
    }

    static DataTable dtExceldata = new DataTable();

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
                    dtExceldata = new DataTable();

                    dtExceldata.Columns.Add("Location", typeof(String));
                    dtExceldata.Columns.Add("Equipment", typeof(String));
                    dtExceldata.Columns.Add("Point Name", typeof(String));
                    dtExceldata.Columns.Add("Reading Date");
                    dtExceldata.Columns.Add("Reading Value");
                    dtExceldata.Columns.Add("LocationID", typeof(Guid));
                    dtExceldata.Columns.Add("EquipmentID", typeof(Guid));
                    dtExceldata.Columns.Add("Validation", typeof(String));
                    dtExceldata.Columns.Add("ObjectID", typeof(Guid));
                    dtExceldata.Columns.Add("PointID", typeof(Guid));
                    dtExceldata.Columns.Add("Index", typeof(int));

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
                }
                catch (Exception ex)
                {
                    panel.Message = ex.Message;
                }
                finally
                {
                    excelConn.Close();
                }

                if (dtExceldata.Rows.Count == 0)
                {
                    panel.Message = Resources.Errors.Reading_EmptyFile;
                    dtExceldata.Clear();
                    gridUpload.DataBind();
                    return;
                }
                int i = 0;
                while (i < dtExceldata.Rows.Count)
                {
                    DataRow dr = dtExceldata.Rows[i];
                    if ((dr.IsNull("Location") || dr["Location"].ToString().Trim() == "")
                        && (dr.IsNull("Equipment") || dr["Equipment"].ToString().Trim() == "")
                        && (dr.IsNull("Point Name")) || dr["Point Name"].ToString().Trim() == "")
                        dtExceldata.Rows.RemoveAt(i);
                    else
                        i++;
                }
                gridUpload.DataSource = dtExceldata;
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
        panel.Message = "";
        Boolean dataError = false;
        Boolean loc = false;
        Boolean eqp = false;
        String error;

        int count = 0;
        foreach (DataRow dr in dtExceldata.Rows)
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
                if (loc)
                {
                    dr["LocationID"] = OLocation.GetLocationByPath(dr["Location"].ToString());
                    if (dr["LocationID"].Equals(Guid.Empty))
                        error = Resources.Errors.Reading_LocationDoesNotExist;
                    else
                    {
                        OPoint point = TablesLogic.tPoint.Load(TablesLogic.tPoint.ObjectName == dr["Point Name"].ToString().Trim()
                            & TablesLogic.tPoint.LocationID == dr["LocationID"].ToString());
                        if (point == null)
                            error = Resources.Errors.Reading_PointDoesNotExist;
                        else
                        {
                            dr["PointID"] = point.ObjectID;
                        }
                    }
                }

                if (eqp)
                {
                    dr["EquipmentID"] = OEquipment.GetEquipmentByPath(dr["Equipment"].ToString());
                    if (dr["EquipmentID"].Equals(Guid.Empty))
                        error = Resources.Errors.Reading_LocationDoesNotExist;
                    else
                    {
                        OPoint point = TablesLogic.tPoint.Load(TablesLogic.tPoint.ObjectName == dr["Point Name"].ToString().Trim()
                            & TablesLogic.tPoint.EquipmentID == dr["EquipmentID"].ToString());
                        if (point == null)
                            error = Resources.Errors.Reading_PointDoesNotExist;
                        else
                        {
                            dr["PointID"] = point.ObjectID;
                        }
                    }
                }

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
            gridUpload.DataSource = dtExceldata;
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
        dtExceldata.Clear();
        gridUpload.DataBind();

        panelExcelUpload.Visible = true;
        panelExcelConfirm.Visible = false;
    }

    /// <summary>
    /// Write Excel data into database
    /// </summary>
    protected void WriteToDB()
    {
        try
        {
            int count = 0;
            if (dtExceldata.Rows.Count == 0)
            {
                panel.Message = Resources.Errors.ExcelUpload_NoExcelUploaded;
            }
            else
            {
                using (Connection c = new Connection())
                {
                    foreach (DataRow dr in dtExceldata.Rows)
                    {

                        OReading reading = TablesLogic.tReading.Create();
                        if (!dr.IsNull("LocationID"))
                            reading.LocationID = (Guid)dr["LocationID"];
                        if (!dr.IsNull("EquipmentID"))
                            reading.EquipmentID = (Guid)dr["EquipmentID"];
                        reading.DateOfReading = Convert.ToDateTime(dr["Reading Date"]);
                        reading.Reading = Convert.ToDecimal(dr["Reading Value"]);
                        reading.PointID = (Guid)dr["PointID"];
                        reading.CheckForBreachOfReading(TablesLogic.tPoint.Load(reading.PointID));
                        reading.Save();
                        count++;
                    }
                    c.Commit();
                    panel.Message = Resources.Errors.ExcelUpload_UploadedSuccessfully;
                    dtExceldata.Clear();
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
                        Width="100%" OnAction="gridResults_Action" PageSize="500" 
                        DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl="" 
                        meta:resourcekey="gridResultsResource1" RowErrorColor="" style="clear:both;">
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
                            meta:resourcekey="hintExcelUploadResource1"><asp:Table runat="server" 
                            CellPadding="4" CellSpacing="0" Width="100%"><asp:TableRow runat="server"><asp:TableCell 
                                    runat="server" VerticalAlign="Top" Width="16px"><asp:Image runat="server" 
                                    ImageUrl="~/images/information.gif" /></asp:TableCell><asp:TableCell 
                                    runat="server" VerticalAlign="Top"><asp:Label runat="server"> Please click Save to confirm the import. Otherwise, click Clear. </asp:Label></asp:TableCell></asp:TableRow></asp:Table></ui:uihint>
                        <ui:UIButton runat="server" ID="BtnSave" Text="Save" OnClick="Save_Click" 
                            ImageUrl="~/images/disk-big.gif" meta:resourcekey="BtnSaveResource1" />
                        <ui:UIButton runat="server" ID="BtnClear" Text="Clear" OnClick="Clear_Click" 
                            ImageUrl="~/images/Symbol-Refresh-big.gif" 
                            meta:resourcekey="BtnClearResource1" />
                    </ui:uipanel>
                    <ui:UIGridView runat="server" ID="gridUpload" Width="100%" 
                        CheckBoxColumnVisible="False" DataKeyNames="ObjectID" GridLines="Both" 
                        ImageRowErrorUrl="" meta:resourcekey="gridUploadResource1" RowErrorColor="" 
                        style="clear:both;">
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
                        </Columns>
                    </ui:UIGridView>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
