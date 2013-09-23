<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" EnableSessionState="True" meta:resourcekey="PageResource1"  %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script type="text/javascript" >
function Check(checkBoxID,readingID,dateID)
{    
    var checkbox = document.getElementById(checkBoxID);    
    var readingBox = document.getElementById(readingID);  
    var dateBox = document.getElementById(dateID);    
    checkbox.checked = true;
    var tballcb = document.getElementById("Allcb");
    var allcb = tballcb.rows[0].cells[0].childNodes[0].childNodes[0];    
    if (!allcb.checked)
    {
        var thetime=new Date();
        var date = thetime.getDate() + "-" + mmToMMM(thetime.getMonth()) + "-"  + thetime.getYear(); 
        if (dateBox.childNodes[0].value == "" && readingBox.value=="")
        {
            dateBox.childNodes[0].value =date;
            dateBox.childNodes[1].value =sToss(thetime.getHours());
            dateBox.childNodes[2].value =sToss(thetime.getMinutes());
            dateBox.childNodes[3].value =sToss(thetime.getSeconds());    
        }
    }
    else
    {
        var tballdate = window.document.getElementById("AllDate");
        var alldate = tballdate.rows[0].cells[0].childNodes[0];    
        dateBox.childNodes[0].value =alldate.childNodes[0].value;
        dateBox.childNodes[1].value =alldate.childNodes[1].value;
        dateBox.childNodes[2].value =alldate.childNodes[2].value;
        dateBox.childNodes[3].value =alldate.childNodes[3].value;    
    }    
    
    document.getElementById('ModifiedFlag').value = 'True';
}

function UnCheck(checkBoxID,readingID,dateID)
{
    var checkbox = document.getElementById(checkBoxID);    
    var readingBox = document.getElementById(readingID);  
    var dateBox = document.getElementById(dateID);  
    if (readingBox.value == "")
    {        
        checkbox.checked = false;
        dateBox.childNodes[0].value = "";
        dateBox.childNodes[1].value ="00";
        dateBox.childNodes[2].value ="00";
        dateBox.childNodes[3].value ="00"; 
    }
    document.getElementById('ModifiedFlag').value = '';
}

function mmToMMM(num)
{
    switch(num)
    {
        case 0:return "Jan";
        case 1:return "Feb";
        case 2:return "Mar";
        case 3:return "Apr";
        case 4:return "May";
        case 5:return "Jun";
        case 6:return "Jul";
        case 7:return "Aug";
        case 8:return "Sep";        
        case 9:return "Oct";
        case 10:return "Nov";
        case 11:return "Dec";
    }
}
function sToss(num)
{
    switch(num)
    {
        case 0:return "00";
        case 1:return "01";
        case 2:return "02";
        case 3:return "03";
        case 4:return "04";
        case 5:return "05";
        case 6:return "06";
        case 7:return "07";
        case 8:return "08";        
        case 9:return "09";
        default:return num;        
    }
}
</script>


<script runat="server">

    String[] listID
    {
        get
        {
            return Session["listID"] as String[];
        }
        set
        {
            Session["listID"] = value;
        }
    }

    ArrayList listPointID
    {
        get
        {
            return Session["listPointID"] as ArrayList;
        }
        set
        {
            Session["listPointID"] = value;
        }
    }
    
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            listPointID = new ArrayList();
            String str = Session["SelectedPoint"].ToString();
            listID = str.Split(';');
            //Session.Remove("SelectedPoint");
            BindData();
            Allcb.Checked = true;
            if ((OApplicationSetting.Current.PostingStartDay <= DateTime.Today.Day && OApplicationSetting.Current.PostingEndDay >= DateTime.Today.Day))
                AllDate.DateTime = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1, 23, 59, 59).AddDays(-1);
            else
                AllDate.DateTime = DateTime.Today;
        }       
    }

    
    /// <summary>
    /// Validates to ensure that the consumption does not exceeds the previous
    /// consumption by 1.5 times. If it does, highlight the row.
    /// </summary>
    /// <returns></returns>
    bool ValidateConsumption()
    {
        bool validate = true;
        foreach (GridViewRow row in gridResults.GetSelectedRows())
        {
            try
            {
                Guid pointId = (Guid)gridResults.DataKeys[row.RowIndex][0];
                UIFieldTextBox CReading = row.FindControl("CReading") as UIFieldTextBox;
                UIFieldDateTime CDate = row.FindControl("CDate") as UIFieldDateTime;

                decimal currentReading = Convert.ToDecimal(CReading.Text);
                DateTime? currentReadingDate = CDate.DateTime;

                OPoint point = TablesLogic.tPoint.Load(pointId);
                if (OReading.DoesReadingExceedPreviousConsumptionBy1Point5Times(point, currentReadingDate, currentReading))
                {
                    row.BackColor = System.Drawing.Color.LightPink;
                    pagePanelMain.Message = Resources.Messages.ReadingMultiple_Consumption1point5TimesGreaterThanPreviousConfirm;
                    validate = false;
                }
            }
            catch
            {
            }
        }
        return validate;
    }
    
   
    protected void pagePanelMain_Click(object sender, string commandName)
    {
        if (commandName.Equals("Save"))
        {
            if (!ValidateConsumption())
            {
                pagePanelMain.Button1_CommandName = "";
                pagePanelMain.Button2_CommandName = "Confirm";
                pagePanelMain.Button3_CommandName = "Cancel";
                gridResults.Enabled = false;
                return;
            }
            
            if (UpdateReading())
                BindData();
        }
        else if (commandName.Equals("Confirm"))
        {
            if (UpdateReading())
                BindData();

            gridResults.Enabled = true;
            pagePanelMain.Button1_CommandName = "Save";
            pagePanelMain.Button2_CommandName = "";
        }
        else if (commandName.Equals("Save_close"))
        {
            if (UpdateReading())
                Window.Close();
        }       
        else if (commandName.Equals("Cancel"))
        {
            gridResults.Enabled = true;
            pagePanelMain.Button1_CommandName = "Save";
            pagePanelMain.Button2_CommandName = "";
        }
        else if (commandName.Equals("Download"))
        {
            DownloadTemplate();
        }     
       
    }

    protected void BindData()
    {
        ExpressionCondition c = Query.False;
        for (int i = 0; i < listID.Length - 1; i++)
        {
            c = c | (TablesLogic.tPoint.ObjectID == (new Guid(listID[i])));
        }
        DataTable dt = Query.Select(
            TablesLogic.tPoint.ObjectID,
            TablesLogic.tPoint.ObjectName,
            TablesLogic.tPoint.Description,
            TablesLogic.tPoint.MaximumReading,
            TablesLogic.tPoint.Factor,
            TablesLogic.tPoint.Barcode
            ).Where(c);

        dt.Columns.Add("LocEqp", typeof(String));
        dt.Columns.Add("Type", typeof(String));
        dt.Columns.Add("Latest Reading", typeof(Decimal));
        dt.Columns.Add("Time of Reading", typeof(DateTime));

        foreach (DataRow dr in dt.Rows)
        {
            OPoint pt = TablesLogic.tPoint.Load((Guid)dr["ObjectID"]);
            OReading read = pt.LatestReading;
            dr["Type"] = pt.IsIncreasingMeterText;
            dr["LocEqp"] = pt.LocationOrEquipmentPath;
            if (read != null)
            {
                if (read.Reading != null)
                    dr["Latest Reading"] = read.Reading;
                else if (pt.LastReading != null)
                    dr["Latest Reading"] = pt.LastReading;
                
                if(read.DateOfReading!=null)
                dr["Time of Reading"] =  read.DateOfReading;
            }
            else if (pt.LastReading != null)
                dr["Latest Reading"] = pt.LastReading;
        }
        gridResults.DataSource = dt;
        gridResults.DataBind();
    }
    
    protected bool UpdateReading()
    {
        int count = 0;
        int ErrorCount = 0;
        listPointID.Clear();    
        pagePanelMain.Message = "";
        using (Connection c = new Connection())
        {
            for (int i = 0; i < gridResults.Rows.Count; i++)
            {
                bool error = false;
                CheckBox cb = (CheckBox)gridResults.Rows[i].FindControl("checkMultiple");                
                if (cb.Checked)
                {
                    count++;
                    UIFieldTextBox tbRead = (UIFieldTextBox)gridResults.Rows[i].FindControl("CReading");
                    UIFieldDateTime dateRead = (UIFieldDateTime)gridResults.Rows[i].FindControl("CDate");
                    String locEqp = gridResults.Rows[i].Cells[1].Text;
                    try
                    {
                        Decimal value = Convert.ToDecimal(tbRead.Text);
                        try
                        {
                            OReading read = TablesLogic.tReading.Create();
                            OPoint pt = TablesLogic.tPoint.Load((Guid)gridResults.DataKeys[i].Value);
                            if (pt.LocationID != null)
                            {
                                read.LocationID = pt.LocationID;                                
                            }
                            else if (pt.EquipmentID != null)
                            {
                                read.EquipmentID = pt.EquipmentID;                               
                            }

                            if (pt.MaximumReading != null && value > pt.MaximumReading)
                            {
                                pagePanelMain.Message = String.Format(Resources.Errors.Reading_UpdateFailed, locEqp, Resources.Errors.Reading_ValueExceedMax);
                                return false;
                            }

                            DateTime date = Convert.ToDateTime(dateRead.DateTime);
                            read.DateOfReading = date;

                            if (pt.IsReadingWithTenantExist(null, date) || pt.IsReadingBackDate(null, date))
                            {
                                listPointID.Add(pt.ObjectID);
                                error = true;
                                ErrorCount++;
                            }
                            
                            read.Reading = value;
                            read.PointID = pt.ObjectID;
                            read.Source = 0;
                            read.CheckForBreachOfReading(pt);
                            if (!error)
                                read.Save();
                        }
                        catch (Exception ex)
                        {
                            pagePanelMain.Message = String.Format(Resources.Errors.Reading_UpdateFailed, locEqp, ex.Message);
                            return false;
                        }
                    }
                    catch (Exception ex)
                    {
                        pagePanelMain.Message = String.Format(Resources.Errors.Reading_UpdateFailed, locEqp, Resources.Errors.Reading_ValueFormatIncorrect);
                        return false;
                    }     
                }
            }           
            
            if (count == 0)
            {
                pagePanelMain.Message = Resources.Errors.Reading_NonSelected;
                return false;
            }
            else if (ErrorCount > 0)
                pagePanelMain.Message = Resources.Messages.ReadingMultiple_DuplicateMonthWithTenantOrBackDate;
            else
                pagePanelMain.Message = "Upload Success";

            c.Commit();     
            return true;   
        } 
    }



    protected void gridResults_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            UIFieldTextBox CReading = e.Row.FindControl("CReading") as UIFieldTextBox;
            UIFieldDateTime CDate = e.Row.FindControl("CDate") as UIFieldDateTime;
            CheckBox CCB = e.Row.FindControl("checkMultiple") as CheckBox;
            CReading.Control.Attributes["onfocus"] = "Check('" + CCB.ClientID + "','" + CReading.Control.ClientID + "','" + CDate.Control.ClientID + "')";
            CReading.Control.Attributes["onblur"] = "UnCheck('" + CCB.ClientID + "','" + CReading.Control.ClientID + "','" + CDate.Control.ClientID + "')";
            OPoint point = TablesLogic.tPoint.Load((Guid)gridResults.DataKeys[e.Row.RowIndex][0]);
            
            if(listPointID!=null){
                if (listPointID.Contains(gridResults.DataKeys[e.Row.RowIndex][0]))
                    e.Row.BackColor = System.Drawing.Color.LightPink;
            }
        }
    }

    protected void DownloadTemplate()
    {
        Guid id = Guid.NewGuid();
        string filePath = ConfigurationManager.AppSettings["ReportTempFolder"] + id.ToString().Replace("-", "") + ".xls";
        string worksheetname = "PointReading";
        int compulsoryColumns = 0;

        List<object> keys = new List<object>();
        foreach (string keyid in listID)
            if (keyid.Trim() != "")
                keys.Add(new Guid(keyid));
        DataTable dt = GenerateExcelData(keys);

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
            <web:pagepanel runat="server" ID="pagePanelMain" Caption="Reading (Multiple)"
                Button1_Caption="Save" Button1_ImageUrl="~/images/disk-big.gif" Button1_CommandName="Save" 
                Button1_ConfirmText="Are you sure you want to add the readings? Once added, they can only be modified in the Reading module."
                Button2_Caption="Confirm" Button2_ImageUrl="~/images/check-big.png" 
                Button3_Caption="Cancel" Button3_ImageUrl="~/images/Delete-big.png" 
                Button4_Caption="Download Excel Template" Button4_ImageUrl="~/images/download.png" Button4_CommandName="Download"
                OnClick="pagePanelMain_Click" meta:resourcekey="pagePanelMainResource1" />
            <iframe runat="server" id='frameReload' height="0px" width="0px" frameborder="0"></iframe>
            <%-- this forces a reload of the page every 30 seconds or so to retain the session. --%>
            <script type='text/javascript'>
                function reload() 
                {
                    var now = new Date();
                    document.getElementById('frameReload').src = '../../components/reload.aspx?t=' + now.getDay() + ":" + now.getHours() + ":" + now.getMinutes() + ":" + now.getSeconds() + ":" + now.getMilliseconds();
                    setTimeout('reload()', 30000);
                }
                setTimeout('reload()', 30000); 
            </script>
            <div class="div-main">       
                <ui:UITabStrip runat="server" ID="tabSearch" BorderStyle="NotSet" 
                    meta:resourcekey="tabSearchResource1">
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Upload" 
                        BorderStyle="NotSet" meta:resourcekey="uitabview3Resource1">
                    <ui:UIFieldCheckBox runat="server" ID="Allcb" ShowCaption="False" 
                            Text="Apply this time to all readings" Width="180px" 
                            meta:resourcekey="AllcbResource1" TextAlign="Right"></ui:UIFieldCheckBox>
                    <ui:UIFieldDateTime runat="server" ID="AllDate"  
                            ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif" 
                                ShowTimeControls="True" ShowCaption="False"  Width="300px" 
                            meta:resourcekey="AllDateResource1" ShowDateControls="True"/>
                        <ui:UIGridView runat="server" ID ="gridResults" Caption="Results" 
                            DataKeyNames="ObjectID" OnRowDataBound="gridResults_RowDataBound" 
                            GridLines="Both" meta:resourcekey="gridResultsResource1" 
                            RowErrorColor="" style="clear:both;" Pagesize="1000" ImageRowErrorUrl="">
                            <PagerSettings Mode="NumericFirstLast" />
                            <Columns>
                                <cc1:UIGridViewBoundColumn DataField="LocEqp" HeaderText="Location / Equipment" 
                                    meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="LocEqp" 
                                    ResourceAssemblyName="" SortExpression="LocEqp">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Point Name" 
                                    meta:resourcekey="UIGridViewBoundColumnResource2" PropertyName="ObjectName" 
                                    ResourceAssemblyName="" SortExpression="ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn HeaderText="Barcode" 
                                    PropertyName="Barcode" DataField="Barcode" 
                                    meta:resourcekey="UIGridViewBoundColumnResource9" ResourceAssemblyName="" 
                                    SortExpression="Barcode" >
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Description" HeaderText="Description" 
                                    meta:resourcekey="UIGridViewBoundColumnResource3" PropertyName="Description" 
                                    ResourceAssemblyName="" SortExpression="Description" Visible="False">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Type" HeaderText="Type" 
                                    meta:resourcekey="UIGridViewBoundColumnResource4" PropertyName="Type" 
                                    ResourceAssemblyName="" SortExpression="Type">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="MaximumReading" DataFormatString="{0:G}" 
                                    HeaderText="Maximum Reading" meta:resourcekey="UIGridViewBoundColumnResource5" 
                                    PropertyName="MaximumReading" ResourceAssemblyName="" 
                                    SortExpression="MaximumReading">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Factor" DataFormatString="{0:G}" 
                                    HeaderText="Factor" meta:resourcekey="UIGridViewBoundColumnResource6" 
                                    PropertyName="Factor" ResourceAssemblyName="" SortExpression="Factor">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Latest Reading" DataFormatString="{0:G}" 
                                    HeaderText="Last Reading" meta:resourcekey="UIGridViewBoundColumnResource7" 
                                    PropertyName="Latest Reading" ResourceAssemblyName="" 
                                    SortExpression="Latest Reading">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Time of Reading" 
                                    DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}" HeaderText="Last Date" 
                                    meta:resourcekey="UIGridViewBoundColumnResource8" 
                                    PropertyName="Time of Reading" ResourceAssemblyName="" 
                                    SortExpression="Time of Reading">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewTemplateColumn HeaderText="Current Reading" 
                                    meta:resourcekey="UIGridViewTemplateColumnResource1">
                                    <ItemTemplate>
                                        <UI:UIFieldTextBox ID="CReading" runat="server" 
                                            meta:resourcekey="CReadingResource1" FieldLayout="Flow" ShowCaption="False" 
                                            Width="50pt" InternalControlWidth="95%"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                                <cc1:UIGridViewTemplateColumn HeaderText="Current Reading Date" 
                                    meta:resourcekey="UIGridViewTemplateColumnResource2">
                                    <ItemTemplate>
                                        <cc1:UIFieldDateTime ID="CDate" runat="server" 
                                            ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif" 
                                            meta:resourcekey="CDateResource1" ShowCaption="False" ShowDateControls="True" 
                                            ShowTimeControls="True" Width="200pt">
                                        </cc1:UIFieldDateTime>
                                    </ItemTemplate>
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewTemplateColumn>
                            </Columns>
                        </ui:UIGridView>                                        
                    </ui:UITabView>                    
                </ui:UITabStrip>                    
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
