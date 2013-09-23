<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto" meta:resourcekey="PageResource1" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
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
        dropObjectTypeName.Bind(OFunction.GetObjectTypeNamesByImplementation("", typeof(IAutoGenerateRunningNumber)), 
            "ObjectTypeName", "ObjectTypeName");

        foreach (ListItem item in dropObjectTypeName.Items)
        {
            string translatedText = Resources.Objects.ResourceManager.GetString(item.Text);
            if (translatedText != null && translatedText != "")
                item.Text = translatedText;
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
        <ui:UIObjectPanel runat="server" ID="panelMain" 
            BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
            <web:search runat="server" ID="panel" Caption="Running Number Generator" GridViewID="gridResults" EditButtonVisible="false"
                BaseTable="tRunningNumberGenerator" OnPopulateForm="panel_PopulateForm" SearchType="ObjectQuery" meta:resourcekey="panelResource1">
            </web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" 
                    BorderStyle="NotSet" meta:resourcekey="tabSearchResource1">
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" 
                        BorderStyle="NotSet" meta:resourcekey="uitabview3Resource1" >
                        <ui:UIFieldDropDownList runat="server" ID="dropObjectTypeName" 
                            Caption="Object Type Name" PropertyName="ObjectTypeName" 
                            meta:resourcekey="dropObjectTypeNameResource1" ></ui:UIFieldDropDownList>
                        <ui:UIFieldTextBox runat="server" id="textObjectTypePrefix" 
                            Caption="Object Type Code" PropertyName="ObjectTypeCode" 
                            InternalControlWidth="95%" meta:resourcekey="textObjectTypePrefixResource1" ></ui:UIFieldTextBox>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Results" 
                        BorderStyle="NotSet" meta:resourcekey="uitabview4Resource1" >
                        <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" Width="100%" 
                            DataKeyNames="ObjectID" GridLines="Both" 
                            SortExpression="ObjectTypeName"
                            meta:resourcekey="gridResultsResource1" RowErrorColor="" 
                            style="clear:both;" ImageRowErrorUrl="">
                            <PagerSettings Mode="NumericFirstLast" />
                            <commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                    CommandName="DeleteObject" CommandText="Delete Selected" 
                                    ConfirmText="Are you sure you wish to delete the selected items?" 
                                    ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource1" />
                            </commands>
                            <Columns>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" 
                                    ImageUrl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewObject" 
                                    ImageUrl="~/images/view.gif" meta:resourcekey="UIGridViewButtonColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" 
                                    ConfirmText="Are you sure you wish to delete this item?" 
                                    ImageUrl="~/images/delete.gif" 
                                    meta:resourcekey="UIGridViewButtonColumnResource3">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="ObjectTypeName" 
                                    HeaderText="Object Type Name" meta:resourcekey="UIGridViewBoundColumnResource1" 
                                    PropertyName="ObjectTypeName" ResourceAssemblyName="" 
                                    ResourceName="Resources.Objects" SortExpression="ObjectTypeName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ObjectTypeCode" 
                                    HeaderText="Object Type Code" meta:resourcekey="UIGridViewBoundColumnResource2" 
                                    PropertyName="ObjectTypeCode" ResourceAssemblyName="" 
                                    SortExpression="ObjectTypeCode">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="RunningNumberBehaviorText" 
                                    HeaderText="Running Number Behavior" 
                                    meta:resourcekey="UIGridViewBoundColumnResource3" 
                                    PropertyName="RunningNumberBehaviorText" ResourceAssemblyName="" 
                                    SortExpression="RunningNumberBehaviorText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="IsLocationOrEquipmentCodeAddedText" 
                                    HeaderText="Is Location/Equipment Code Added" 
                                    meta:resourcekey="UIGridViewBoundColumnResource4" 
                                    PropertyName="IsLocationOrEquipmentCodeAddedText" ResourceAssemblyName="" 
                                    SortExpression="IsLocationOrEquipmentCodeAddedText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn PropertyName="FLEECondition" HeaderText="Applicable Condition" DataField="FLEECondition" meta:resourcekey="UIGridViewBoundColumnResource5" ResourceAssemblyName="" SortExpression="FLEECondition">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn PropertyName="FormatString" HeaderText="Format String" DataField="FormatString" meta:resourcekey="UIGridViewBoundColumnResource6" ResourceAssemblyName="" SortExpression="FormatString">
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
