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

    static String[] listID;
    
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            String str = Session["SelectedPoint"].ToString();
            listID = str.Split(';');
            //Session.Remove("SelectedPoint");
            BindData();
        }       
    }
   
    protected void pagePanelMain_Click(object sender, string commandName)
    {
        if (commandName.Equals("Save"))
        {
            if (UpdateReading())
                BindData();
        }
        else if (commandName.Equals("Save_close"))
        {
            if (UpdateReading())
                Window.Close();
        }       
        else if (commandName.Equals("Close"))
        {
            Window.WriteJavascript(
                "if( document.getElementById('ModifiedFlag').value!='' ) " +
                "{if( confirm( '" + Resources.Messages.General_ItemModifiedConfirmClose + "') ) window.close();}else window.close();");

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
            TablesLogic.tPoint.Factor
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
                if (read.Reading!=null)
                    dr["Latest Reading"] = read.Reading ;
                if(read.DateOfReading!=null)
                dr["Time of Reading"] =  read.DateOfReading;
            }
        }
        gridResults.DataSource = dt;
        gridResults.DataBind();
    }
    
    protected bool UpdateReading()
    {
        int count = 0;        
        pagePanelMain.Message = "";
        using (Connection c = new Connection())
        {
            for (int i = 0; i < gridResults.Rows.Count; i++)
            {   
                CheckBox cb = (CheckBox)gridResults.Rows[i].FindControl("checkMultiple");                
                if (cb.Checked)
                {
                    count++;
                    TextBox tbRead = (TextBox)gridResults.Rows[i].FindControl("CReading");
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
                            read.Reading = value;
                            read.PointID = pt.ObjectID;
                            read.Source = 0;
                            read.CheckForBreachOfReading(pt);
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
            else
            {
                c.Commit();
                pagePanelMain.Message = "Upload Success";
                return true;
            }            
        } 
    }



    protected void gridResults_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            TextBox CReading = e.Row.FindControl("CReading") as TextBox;
            UIFieldDateTime CDate = e.Row.FindControl("CDate") as UIFieldDateTime;
            CheckBox CCB = e.Row.FindControl("checkMultiple") as CheckBox;
            CReading.Attributes["onfocus"] = "Check('"+CCB.ClientID +"','" + CReading.ClientID + "','" + CDate.Control.ClientID + "')";
            CReading.Attributes["onblur"] = "UnCheck('" + CCB.ClientID + "','" + CReading.ClientID + "','" + CDate.Control.ClientID + "')";          
            
        }
    }

    protected void DownloadTemplate()
    {
        Guid id = Guid.NewGuid();
        string filePath = ConfigurationManager.AppSettings["ReportTempFolder"] + id.ToString().Replace("-", "") + ".xls";
        string worksheetname = "PointReading";
        int compulsoryColumns = 0;
        DataTable dt = GenerateExcelData();

        OAttachment file = ExcelWriter.GenerateExcelFile(dt, filePath, worksheetname, compulsoryColumns);
        //panel.FocusWindow = false;
        Window.Download(file.FileBytes, file.Filename, file.ContentType);
    }

    protected DataTable GenerateExcelData()
    {
        DataTable dt = new DataTable();

        dt.Columns.Add("Location", typeof(String));
        dt.Columns.Add("Equipment", typeof(String));
        dt.Columns.Add("Point Name", typeof(String));
        dt.Columns.Add("Reading Date");
        dt.Columns.Add("Reading Value");
        for (int i = 0; i < listID.Length - 1; i++)
        {
            DataRow dr = dt.NewRow();
            OPoint pt = TablesLogic.tPoint.Load(new Guid(listID[i]));
            dr["Location"] = pt.Location != null ? pt.Location.Path:"" ;
            dr["Equipment"] = pt.Equipment != null ? pt.Equipment.Path : "";
            dr["Point Name"] = pt.ObjectName;
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
            Button2_Caption="Save and Close" Button2_ImageUrl="~/images/disk-big.gif" Button2_CommandName="Save_close"
            Button3_Caption="Close" Button3_ImageUrl="~/images/Window-Delete-big.gif" Button3_CommandName="Close"
            Button4_Caption="Download Excel Template" Button4_ImageUrl="~/images/download.png" Button4_CommandName="Download"
            OnClick="pagePanelMain_Click" meta:resourcekey="pagePanelMainResource1" />
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
                            GridLines="Both" ImageRowErrorUrl="" meta:resourcekey="gridResultsResource1" 
                            RowErrorColor="" style="clear:both;" PageSize="500" >
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
                                        <asp:TextBox ID="CReading" runat="server" meta:resourcekey="CReadingResource1" 
                                            Width="50pt"></asp:TextBox>
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
