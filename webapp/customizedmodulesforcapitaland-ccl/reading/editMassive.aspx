<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto"
    EnableSessionState="True" meta:resourcekey="PageResource1" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    static String[] listID;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            String str = Session["SelectedReading"].ToString();
            listID = str.Split(';');
            //Session.Remove("SelectedPoint");
            BindData();
        }
    }

    protected void pagePanelMain_Click(object sender, string commandName)
    {
        if (commandName.Equals("Save"))
        {
            if (!panelMain.IsValid)
                return;
            if (UpdateReading())
            {
                BindData();
                Window.Opener.Refresh();
            }
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
    }

    protected void BindData()
    {
        ExpressionCondition c = Query.False;
        for (int i = 0; i < listID.Length - 1; i++)
        {
            c = c | (TablesLogic.tReading.ObjectID == (new Guid(listID[i])));
        }
        List<OReading> readings = TablesLogic.tReading.LoadList(c);

        DataTable dt = new DataTable();
        dt.Columns.Add("Source", typeof(int));
        dt.Columns.Add("SourceName", typeof(String));
        dt.Columns.Add("LocEqp", typeof(String));
        dt.Columns.Add("ObjectID", typeof(Guid));
        dt.Columns.Add("PointID", typeof(Guid));
        dt.Columns.Add("ObjectName", typeof(string));
        dt.Columns.Add("Reading", typeof(decimal));
        dt.Columns.Add("DateOfReading", typeof(DateTime));
        dt.Columns.Add("CreateOnBreachWorkID", typeof(Guid));
        dt.Columns.Add("CreateOnBreachWork.ObjectNumber", typeof(string));

        foreach (OReading reading in readings)
        {
            DataRow dr = dt.NewRow();
            dr["Source"] = reading.Source == null ? DBNull.Value : (object)reading.Source;
            dr["SourceName"] = reading.SourceName;
            dr["LocEqp"] = reading.Point.LocationOrEquipmentPath;
            dr["ObjectID"] = reading.ObjectID == null ? DBNull.Value : (object)reading.ObjectID;
            dr["PointID"] = reading.PointID == null ? DBNull.Value : (object)reading.PointID;
            dr["ObjectName"] = reading.ObjectName == null ? DBNull.Value : (object)reading.ObjectName;
            dr["Reading"] = reading.Reading == null ? DBNull.Value : (object)reading.Reading;
            dr["DateOfReading"] = reading.DateOfReading == null ? DBNull.Value : (object)reading.DateOfReading;
            dr["CreateOnBreachWorkID"] = reading.CreateOnBreachWorkID == null ? DBNull.Value : (object)reading.CreateOnBreachWorkID;
            dr["CreateOnBreachWork.ObjectNumber"] = reading.CreateOnBreachWork == null || reading.CreateOnBreachWork.ObjectNumber == null ? DBNull.Value : (object)reading.CreateOnBreachWork.ObjectNumber;
            dt.Rows.Add(dr);
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
                UIFieldTextBox tbRead = (UIFieldTextBox)gridResults.Rows[i].FindControl("CReading");
                UIFieldDateTime dateRead = (UIFieldDateTime)gridResults.Rows[i].FindControl("CDate");
                String locEqp = gridResults.Rows[i].Cells[1].Text;
                try
                {
                    Decimal value = Convert.ToDecimal(tbRead.Text);
                    DateTime date = Convert.ToDateTime(dateRead.DateTime);

                    OReading read = TablesLogic.tReading.Load((Guid)gridResults.DataKeys[i].Value);
                    if (!(read.Reading == value && read.DateOfReading == date))
                    {
                        read.DateOfReading = date;
                        read.Reading = value;
                        read.Source = ReadingSource.Direct;
                        read.Save();
                        count++;
                    }
                }
                catch (Exception ex)
                {
                    pagePanelMain.Message = String.Format(Resources.Errors.Reading_UpdateFailed, locEqp, ex.Message);
                    return false;
                }
            }
            if (count == 0)
            {
                pagePanelMain.Message = Resources.Errors.Reading_NothingChanged;
                return false;
            }
            c.Commit();
            pagePanelMain.Message = "Upload Success";
            return true;

        }
    }

    protected void gridResults_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            UIFieldTextBox tbRead = (UIFieldTextBox)e.Row.FindControl("CReading");
            UIFieldDateTime dateRead = (UIFieldDateTime)e.Row.FindControl("CDate");
            tbRead.Text = e.Row.Cells[6].Text;
            DateTime temp = Convert.ToDateTime(e.Row.Cells[7].Text);
            dateRead.DateTime = temp;

            if (((DataRowView)e.Row.DataItem)["Source"].Equals(ReadingSource.Direct) &&
                ((DataRowView)e.Row.DataItem)["CreateOnBreachWorkID"] == DBNull.Value)
            {
                tbRead.Enabled = true;
                dateRead.Enabled = true;
            }
            else
            {
                tbRead.Enabled = false;
                dateRead.Enabled = false;
            }
        }

        if (e.Row.RowType == DataControlRowType.DataRow ||
            e.Row.RowType == DataControlRowType.Header)
        {
            e.Row.Cells[6].Visible = false;
            e.Row.Cells[7].Visible = false;
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
        <web:pagepanel runat="server" ID="pagePanelMain" Caption="Readings" Button1_Caption="Save"
            Button1_ImageUrl="~/images/disk-big.gif" Button1_CommandName="Save" Button2_Caption="Save and Close"
            Button2_ImageUrl="~/images/disk-big.gif" Button2_CommandName="Save_close" Button3_Caption="Close"
            Button3_ImageUrl="~/images/Window-Delete-big.gif" Button3_CommandName="Close"
            Button4_Caption="" Button4_ImageUrl="" Button4_CommandName="" OnClick="pagePanelMain_Click" meta:resourcekey="pagePanelMainResource1" />
        <div class="div-main">
            <div class="div-form">
                <ui:UIGridView runat="server" ID="gridResults" Caption="Readings" DataKeyNames="ObjectID"
                    CheckBoxColumnVisible="False" BindObjectsToRows="True" 
                    OnRowDataBound="gridResults_RowDataBound" GridLines="Both"  PageSize="500"
                    meta:resourcekey="gridResultsResource1" RowErrorColor="" 
                    style="clear:both;" ImageRowErrorUrl="">
                    <PagerSettings Mode="NumericFirstLast" />
                    <Columns>
                        <cc1:UIGridViewBoundColumn DataField="SourceName" HeaderText="Source" 
                            meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="SourceName" 
                            ResourceAssemblyName="" SortExpression="SourceName">
                            <HeaderStyle HorizontalAlign="Left" />
                            <ItemStyle HorizontalAlign="Left" />
                        </cc1:UIGridViewBoundColumn>
                        <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Point Name" 
                            meta:resourcekey="UIGridViewBoundColumnResource2" PropertyName="ObjectName" 
                            ResourceAssemblyName="" SortExpression="ObjectName">
                            <HeaderStyle HorizontalAlign="Left" />
                            <ItemStyle HorizontalAlign="Left" />
                        </cc1:UIGridViewBoundColumn>
                        <cc1:UIGridViewBoundColumn DataField="LocEqp" HeaderText="Location / Equipment" 
                            meta:resourcekey="UIGridViewBoundColumnResource3" PropertyName="LocEqp" 
                            ResourceAssemblyName="" SortExpression="LocEqp">
                            <HeaderStyle HorizontalAlign="Left" />
                            <ItemStyle HorizontalAlign="Left" />
                        </cc1:UIGridViewBoundColumn>
                        <cc1:UIGridViewTemplateColumn HeaderText="Reading" 
                            meta:resourcekey="UIGridViewTemplateColumnResource1">
                            <ItemTemplate>
                                <cc1:UIFieldTextBox ID="CReading" runat="server" InternalControlWidth="95%" 
                                    meta:resourcekey="CReadingResource1" PropertyName="Reading" ShowCaption="False" 
                                    ValidateDataTypeCheck="True" ValidateRequiredField="True" 
                                    ValidationDataType="Double">
                                </cc1:UIFieldTextBox>
                            </ItemTemplate>
                            <HeaderStyle HorizontalAlign="Left" />
                            <ItemStyle HorizontalAlign="Left" />
                        </cc1:UIGridViewTemplateColumn>
                        <cc1:UIGridViewTemplateColumn HeaderText="Current Reading Date" 
                            meta:resourcekey="UIGridViewTemplateColumnResource2">
                            <ItemTemplate>
                                <cc1:UIFieldDateTime ID="CDate" runat="server" 
                                    ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif" 
                                    meta:resourcekey="CDateResource1" PropertyName="DateOfReading" 
                                    ShowCaption="False" ShowDateControls="True" ShowTimeControls="True" 
                                    ValidateRequiredField="True" Width="210pt">
                                </cc1:UIFieldDateTime>
                            </ItemTemplate>
                            <HeaderStyle HorizontalAlign="Left" />
                            <ItemStyle HorizontalAlign="Left" />
                        </cc1:UIGridViewTemplateColumn>
                        <cc1:UIGridViewBoundColumn DataField="Reading" 
                            meta:resourcekey="UIGridViewBoundColumnResource4" PropertyName="Reading" 
                            ResourceAssemblyName="" SortExpression="Reading">
                            <HeaderStyle HorizontalAlign="Left" />
                            <ItemStyle HorizontalAlign="Left" />
                        </cc1:UIGridViewBoundColumn>
                        <cc1:UIGridViewBoundColumn DataField="DateOfReading" 
                            meta:resourcekey="UIGridViewBoundColumnResource5" PropertyName="DateOfReading" 
                            ResourceAssemblyName="" SortExpression="DateOfReading">
                            <HeaderStyle HorizontalAlign="Left" />
                            <ItemStyle HorizontalAlign="Left" />
                        </cc1:UIGridViewBoundColumn>
                        <cc1:UIGridViewBoundColumn DataField="CreateOnBreachWork.ObjectNumber" 
                            HeaderText="Work Number (created during breach)" 
                            meta:resourcekey="UIGridViewBoundColumnResource6" 
                            PropertyName="CreateOnBreachWork.ObjectNumber" ResourceAssemblyName="" 
                            SortExpression="CreateOnBreachWork.ObjectNumber">
                            <HeaderStyle HorizontalAlign="Left" />
                            <ItemStyle HorizontalAlign="Left" />
                        </cc1:UIGridViewBoundColumn>
                    </Columns>
                </ui:UIGridView>
            </div>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
