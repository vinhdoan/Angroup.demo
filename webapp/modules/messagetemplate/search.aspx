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
        dropObjectTypeName.Bind(OWorkflowRepository.GetAllWorkflowRepositories(), "ObjectTypeName", "ObjectTypeName", true);
        foreach (ListItem item in dropObjectTypeName.Items)
        {
            string translatedText = Resources.Objects.ResourceManager.GetString(item.Text);
            if (translatedText != null && translatedText != "")
                item.Text = translatedText;
        }
    
    }

    
    /// <summary>
    /// Occurs when the user selects a value on the radio button list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void radioWhereUsed_SelectedIndexChanged(object sender, EventArgs e)
    {
        
    }

    
    /// <summary>
    /// Hides/shows elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        panelGeneral.Visible = radioWhereUsed.SelectedValue == "0";
        if (!panelGeneral.Visible)
            textTemplateCode.Text = "";
        panelNotifyAssignedWorkflowRecipients.Visible = radioWhereUsed.SelectedValue == "1";
        if (!panelNotifyAssignedWorkflowRecipients.Visible)
        {
            dropObjectTypeName.SelectedIndex = 0;
            textStateName.Text = "";
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
            <web:search runat="server" ID="panel" Caption="Message Template" GridViewID="gridResults" EditButtonVisible="false"
                BaseTable="tMessageTemplate" OnPopulateForm="panel_PopulateForm" SearchType="ObjectQuery" meta:resourcekey="panelResource1">
            </web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" BorderStyle="NotSet" 
                    meta:resourcekey="tabSearchResource1">
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" 
                        BorderStyle="NotSet" meta:resourcekey="uitabview3Resource1" >
                        <ui:UIFieldTextBox runat="server" ID="textTemplateName" Caption="Template Name" 
                            PropertyName="ObjectName"  captionwidth="150px" InternalControlWidth="95%" 
                            meta:resourcekey="textTemplateNameResource1"></ui:UIFieldTextBox>
                        <ui:UIFieldRadioList runat="server" ID="radioWhereUsed" 
                            PropertyName="WhereUsed" Caption="Where Used" 
                            OnSelectedIndexChanged="radioWhereUsed_SelectedIndexChanged" 
                            CaptionWidth="150px" meta:resourcekey="radioWhereUsedResource1" 
                            TextAlign="Right">
                            <Items>
                                <asp:ListItem Selected="True" meta:resourcekey="ListItemResource1">Any</asp:ListItem>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource2">General</asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource3">Notify Assigned Workflow Recipients</asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIPanel runat="server" ID="panelGeneral" BorderStyle="NotSet" 
                            meta:resourcekey="panelGeneralResource1">
                            <ui:UIFieldTextBox runat="server" ID="textTemplateCode" 
                                Caption="Message Template Code" PropertyName="MessageTemplateCode" Span="Half"  
                                captionwidth="150px" InternalControlWidth="95%" 
                                meta:resourcekey="textTemplateCodeResource1"></ui:UIFieldTextBox>
                        </ui:UIPanel>
                        <ui:UIPanel runat="server" ID="panelNotifyAssignedWorkflowRecipients" 
                            BorderStyle="NotSet" 
                            meta:resourcekey="panelNotifyAssignedWorkflowRecipientsResource1">
                            <ui:UIFieldDropDownList runat="server" ID="dropObjectTypeName" 
                                Caption="Object Type Name" PropertyName="ObjectTypeName"  captionwidth="150px" 
                                meta:resourcekey="dropObjectTypeNameResource1"></ui:UIFieldDropDownList>
                            <ui:UIFieldTextBox runat="server" ID="textStateName" Caption="State Name" 
                                PropertyName="StateName" captionwidth="150px" InternalControlWidth="95%" 
                                meta:resourcekey="textStateNameResource1"></ui:UIFieldTextBox>
                        </ui:UIPanel>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Results" 
                        BorderStyle="NotSet" meta:resourcekey="uitabview4Resource1" >
                        <ui:UIGridView runat="server" ID="gridResults" KeyName="ObjectID" Width="100%" 
                            DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl="" 
                            meta:resourcekey="gridResultsResource1" RowErrorColor="" style="clear:both;">
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
                                <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Template Name" 
                                    meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="ObjectName" 
                                    ResourceAssemblyName="" SortExpression="ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="WhereUsedText" HeaderText="Where Used" 
                                    meta:resourcekey="UIGridViewBoundColumnResource2" PropertyName="WhereUsedText" 
                                    ResourceAssemblyName="" SortExpression="WhereUsedText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="MessageTemplateCode" 
                                    HeaderText="Message Template Code" 
                                    meta:resourcekey="UIGridViewBoundColumnResource3" 
                                    PropertyName="MessageTemplateCode" ResourceAssemblyName="" 
                                    SortExpression="MessageTemplateCode">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ObjectTypeName" 
                                    HeaderText="Object Type Name" meta:resourcekey="UIGridViewBoundColumnResource4" 
                                    PropertyName="ObjectTypeName" ResourceAssemblyName="" 
                                    ResourceName="Resources.Objects" SortExpression="ObjectTypeName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="StateName" HeaderText="State Name" 
                                    meta:resourcekey="UIGridViewBoundColumnResource5" PropertyName="StateName" 
                                    ResourceAssemblyName="" ResourceName="Resources.WorkflowStates" 
                                    SortExpression="StateName">
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
