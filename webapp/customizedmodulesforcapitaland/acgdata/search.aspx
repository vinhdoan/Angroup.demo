<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>

<script runat="server">

    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        BindYear();
        treeLocation.PopulateTree();
    }
    /// <summary>
    /// Constructs the location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        return new LocationTreePopulaterForCapitaland(null, false, true, 
            Security.Decrypt(Request["TYPE"]),false,false);
    }
    public void BindYear()
    {
        Year.Items.Add(new ListItem());
        Year.Items.Add(new ListItem(((DateTime.Today.Year) - 1).ToString(), ((DateTime.Today.Year) - 1).ToString()));
        Year.Items.Add(new ListItem((DateTime.Today.Year).ToString(), (DateTime.Today.Year).ToString()));
        Year.Items.Add(new ListItem(((DateTime.Today.Year) + 1).ToString(), ((DateTime.Today.Year) + 1).ToString()));
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
        <ui:UIObjectPanel runat="server" ID="panelMain">
            <web:search runat="server" ID="panel" Caption="ACG Data" GridViewID="gridResults" EditButtonVisible="false"
                BaseTable="tACGData" meta:resourcekey="panelResource1" OnPopulateForm="panel_PopulateForm">
            </web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch">
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" >
                    <ui:UIFieldDropDownList runat="server" PropertyName="Year" Caption="Year" ID="Year" Span="Half">
                    </ui:UIFieldDropDownList>
                    <ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location" PropertyName="LocationID"
                            OnAcquireTreePopulater="treeLocation_AcquireTreePopulater" Span="Half"
                            ValidateRequiredField="True" meta:resourcekey="treeLocationResource1" ShowCheckBoxes="None"
                            TreeValueMode="SelectedNode">
                        </ui:UIFieldTreeList>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Results" >
                        <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" Width="100%">
                            <Columns>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif"
                                    CommandName="EditObject" HeaderText="">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/view.gif" 
                                    CommandName="ViewObject" HeaderText="">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" 
                                    CommandName="DeleteObject" HeaderText="" ConfirmText="Are you sure you wish to delete this item?">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn PropertyName="ObjectName" HeaderText="ACG Name">
                                </ui:UIGridViewBoundColumn>
                            </Columns>
                            <Commands>
                                <ui:UIGridViewCommand CommandText="Delete Selected" ConfirmText="Are you sure you wish to delete the selected items?"
                                    ImageUrl="~/images/delete.gif" CommandName="DeleteObject"></ui:UIGridViewCommand>
                            </Commands>
                        </ui:UIGridView>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
