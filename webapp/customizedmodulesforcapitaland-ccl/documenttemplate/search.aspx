<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.Common" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>

<script runat="server">
    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        dropObjectTypeName.Bind(OFunction.GetAllFunctionsWithObjectTypes(), "ObjectTypeName", "ObjectTypeName", true);
        foreach (ListItem item in dropObjectTypeName.Items)
        {
            string translatedText = Resources.Objects.ResourceManager.GetString(item.Text);
            if (translatedText != null && translatedText != "")
                item.Text = translatedText;
        }
    }
    
</script>

<body>
    <form id="form1" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
            meta:resourcekey="panelMainResource1">
            <web:search ID="panel" runat="server" BaseTable="tDocumentTemplate" 
                Caption="Document Template" EditButtonVisible="false" SearchType="ObjectQuery"
                AutoSearchOnLoad="true" SearchTextBoxHint="" 
                MaximumNumberOfResults="30" SearchTextBoxPropertyNames="ObjectName,ObjectTypeName"
                AdvancedSearchPanelID="panelAdvanced"
                GridViewID="gridResults" OnPopulateForm="panel_PopulateForm" meta:resourcekey="panelResource1"/>
            <div class="div-form">
                <%--<ui:UITabStrip runat="server" ID="ODocumentTemplateStrip" BorderStyle="NotSet" 
                    meta:resourcekey="ODocumentTemplateStripResource1">
                    <ui:UITabView runat="server" ID="tabSearch" Caption="Search" 
                        BorderStyle="NotSet" meta:resourcekey="tabSearchResource1" >--%>
                    <ui:UIPanel runat="server" ID="panelAdvanced" BorderStyle="NotSet">
                        <ui:UIFieldDropDownList runat="server" ID="dropObjectTypeName" 
                            Caption="Object Type Name" PropertyName="ObjectTypeName" 
                            meta:resourcekey="dropObjectTypeNameResource1" >
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldTextBox runat="server" ID="FileDescription" Caption="File Description"
                            PropertyName="FileDescription" InternalControlWidth="95%" 
                            meta:resourcekey="FileDescriptionResource1" />
                    </ui:UIPanel>
                    <%--</ui:UITabView>
                    <ui:UITabView runat="server" ID="tabResuilt" Caption="Results" 
                        BorderStyle="NotSet" meta:resourcekey="tabResuiltResource1">--%>
                        <ui:UIGridView ID="gridResults" runat="server" Width="100%" KeyName="ObjectID" 
                            DataKeyNames="ObjectID" GridLines="Both" 
                            SortExpression="ObjectTypeName"
                            meta:resourcekey="gridResultsResource1" RowErrorColor="" style="clear:both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                    CommandName="DeleteObject" CommandText="Delete Selected" 
                                    ConfirmText="Are you sure you wish to delete the selected items?" 
                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
                            </commands>
                            <Columns>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" 
                                    ImageUrl="~/images/edit.gif" meta:resourcekey="UIGridViewButtonColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" 
                                    ConfirmText="Are you sure you wish to delete this item?" 
                                    ImageUrl="~/images/delete.gif" 
                                    meta:resourcekey="UIGridViewButtonColumnResource2">
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
                                <cc1:UIGridViewBoundColumn DataField="FileDescription" 
                                    HeaderText="File Description" meta:resourcekey="UIGridViewBoundColumnResource2" 
                                    PropertyName="FileDescription" ResourceAssemblyName="" 
                                    SortExpression="FileDescription">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn Headertext="Applicable States" PropertyName="ApplicableStates" DataField="ApplicableStates" meta:resourcekey="UIGridViewBoundColumnResource3" ResourceAssemblyName="" SortExpression="ApplicableStates">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn Headertext="Applicable Condition" PropertyName="FLEECondition" DataField="FLEECondition" meta:resourcekey="UIGridViewBoundColumnResource4" ResourceAssemblyName="" SortExpression="FLEECondition">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn HeaderText="Output Format" PropertyName="OutputFormatText" DataField="OutputFormatText" meta:resourcekey="UIGridViewBoundColumnResource5" ResourceAssemblyName="" SortExpression="OutputFormatText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                    <%--</ui:UITabView>
                </ui:UITabStrip>--%>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
