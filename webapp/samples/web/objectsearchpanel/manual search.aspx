<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase"
    Culture="auto" UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web"
    TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>

<script runat="server">
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        // Constructs the condition from all the UIField controls
        // in the user interface.
        // 
        ExpressionCondition c = panel.GetCondition();
        
        TPoint p = TablesLogic.tPoint;
        TReading r = TablesLogic.tReading;
        
        // Performs a query. The columns in the result data table
        // must correspond to the columns in the grid view.
        //
        DataTable dt =
            p.Select(
            p.ObjectID,
            p.ObjectName,
            p.OPCDAServer.ObjectName.As("OPCDAServer"),
            r.SelectTop(1, r.Reading).Where(
                r.LocationID == p.LocationID)
                .OrderBy(r.DateOfReading.Desc).As("LatestReading")
            )
            .Where(c);
        
        // Then assign the DataTable to the CustomResultTable field
        // in the event argument.
        //
        e.CustomResultTable = dt;
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet"
        type="text/css" />
</head>
<body>
    <form id="form2" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain">
        <web:search runat="server" ID="panel" Caption="Point" GridViewID="gridResults"
            BaseTable="tPoint" OnSearch="panel_Search"></web:search>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabSearch">
                <ui:UITabView runat="server" ID="uitabview3" Caption="Search">
                    <ui:UIFieldTextBox runat="server" ID="textPointName" PropertyName="ObjectName" Caption="Point Name"></ui:UIFieldTextBox>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview4" Caption="Results">
                    <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID"
                        Width="100%">
                        <Columns>
                            <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif" 
                                CommandName="EditObject"
                                HeaderText="">
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewButtonColumn ImageUrl="~/images/view.gif" 
                                CommandName="ViewObject"
                                HeaderText="">
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" 
                            CommandName="DeleteObject"
                                HeaderText="" 
                                ConfirmText="Are you sure you wish to delete this item?">
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewBoundColumn PropertyName="ObjectName" 
                                HeaderText="Point Name">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="OPCDAServer" 
                                HeaderText="OPC Server">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn PropertyName="LatestReading" 
                                HeaderText="Latest Reading">
                            </ui:UIGridViewBoundColumn>
                        </Columns>
                        <Commands>
                            <ui:UIGridViewCommand CommandText="Delete Selected" 
                                ConfirmText="Are you sure you wish to delete the selected items?"
                                ImageUrl="~/images/delete.gif" CommandName="DeleteObject">
                            </ui:UIGridViewCommand>
                        </Commands>
                    </ui:UIGridView>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
