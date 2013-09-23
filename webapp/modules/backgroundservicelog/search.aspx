<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Register Assembly="Anacle.UIFramework" Namespace="Anacle.UIFramework" TagPrefix="cc1" %>

<script runat="server">

    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
    }

    /// <summary>
    /// Performs search with custom conditions.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        List<ColumnOrder> columnOrders = new List<ColumnOrder>();
        columnOrders.Add(TablesLogic.tBackgroundServiceLog.CreatedDateTime.Desc);
        e.CustomSortOrder = columnOrders;
    }


    /// <summary>
    /// Hides/shows elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
    }



    protected void gridResults_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //message type
            if (e.Row.Cells[3].Text == "1") //Error
                e.Row.Cells[3].Text = Resources.Strings.BackgroundLogMessageType_Error;
            else if (e.Row.Cells[3].Text == "2") //Warning
                e.Row.Cells[3].Text = Resources.Strings.BackgroundLogMessageType_Warning;
            else if (e.Row.Cells[3].Text == "4") //Information
                e.Row.Cells[3].Text = Resources.Strings.BackgroundLogMessageType_Information;
            else if (e.Row.Cells[3].Text == "8") //SuccessAudit
                e.Row.Cells[3].Text = Resources.Strings.BackgroundLogMessageType_SuccessAudit;
            else if (e.Row.Cells[3].Text == "16") //FailAudit
                e.Row.Cells[3].Text = Resources.Strings.BackgroundLogMessageType_FailAudit;
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
        <web:search runat="server" ID="panel" Caption="Background Service Log" GridViewID="gridResults"
            BaseTable="tBackgroundServiceLog" OnSearch="panel_Search" EditButtonVisible="false"
            OnPopulateForm="panel_PopulateForm" SearchType="ObjectQuery" meta:resourcekey="panelResource1"
            SearchTextBoxVisible="true" SearchTextBoxPropertyNames="ServiceName,Message">
        </web:search>
        <div class="div-form">
            <ui:UIGridView runat="server" ID="gridResults" BorderColor="Black" KeyName="ObjectID"
                SortExpression="CreatedDateTime DESC" meta:resourcekey="gridResultsResource1"
                Width="100%" DataKeyNames="ObjectID" CheckBoxColumnVisible="False" GridLines="Both"
                RowErrorColor="" Style="clear: both;" CaptionPosition="Side" ScrollableHeight="400px"
                ImageRowErrorUrl="" OnRowDataBound="gridResults_RowDataBound">
                <PagerSettings Mode="NumericFirstLast" />
                <Columns>
                    <cc1:UIGridViewBoundColumn DataField="CreatedDateTime" DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}"
                        HeaderText="Date/Time" meta:resourcekey="UIGridViewBoundColumnResource3" PropertyName="CreatedDateTime"
                        SortExpression="CreatedDateTime" ResourceAssemblyName="">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="ServiceName" HeaderText="Service Name" PropertyName="ServiceName"
                        ResourceAssemblyName="" SortExpression="ServiceName" meta:resourcekey="UIGridViewBoundColumnResource1">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="MessageType" HeaderText="Message Type" PropertyName="MessageType"
                        ResourceAssemblyName="" SortExpression="Message" meta:resourcekey="UIGridViewBoundColumnResource4">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="Message" HeaderText="Status Message" PropertyName="Message"
                        ResourceAssemblyName="" SortExpression="Message" meta:resourcekey="UIGridViewBoundColumnResource2">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                </Columns>
            </ui:UIGridView>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
