<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto"
    meta:resourcekey="PageResource1" %>

<%@ Import Namespace="System.Collections.Generic" %>
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
        OSurveyRespondent surveyRespondent = (OSurveyRespondent)panel.SessionObject;
        treeLocation.PopulateTree();
        treeLocationAccess.PopulateTree();
        panel.ObjectPanel.BindObjectToControls(surveyRespondent);
    }

    /// <summary>
    /// Saves the survey respondent to the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OSurveyRespondent surveyRespondent = (OSurveyRespondent)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(surveyRespondent);

            // Validate
            //

            // Save
            //
            surveyRespondent.Save();
            c.Commit();
        }
    }

    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        return new LocationTreePopulaterForCapitaland(null, true, true, "", false, false);
    }

    protected void treeLocation_SelectedNodeChanged(object sender, EventArgs e)
    {

    }

    protected TreePopulater treeLocationAccess_AcquireTreePopulater(object sender)
    {
        return new LocationTreePopulaterForCapitaland(null, false, true, "", false, false);
    }

    protected void treeLocationAccess_SelectedNodeChanged(object sender, EventArgs e)
    {
        OSurveyRespondentPortfolio currentSRP = (OSurveyRespondentPortfolio)subpanel_SRPortfolio.SessionObject;
        subpanel_SRPortfolio.ObjectPanel.BindControlsToObject(currentSRP);
        currentSRP.Locations.AddGuid(new Guid(treeLocationAccess.SelectedValue.ToString()));
        subpanel_SRPortfolio.ObjectPanel.BindObjectToControls(currentSRP);
    }

    /// <summary>
    /// Hides/shows elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        OSurveyRespondent surveyRespondent = (OSurveyRespondent)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(surveyRespondent);

        panel.ObjectPanel.BindObjectToControls(surveyRespondent);
    }

    protected void gridLocationAccess_Action(object sender, string commandName, List<object> objectIds)
    {
        if (commandName == "DeleteObject")
        {
            OSurveyRespondentPortfolio currentSRP = (OSurveyRespondentPortfolio)subpanel_SRPortfolio.SessionObject;
            foreach (Guid id in objectIds)
                currentSRP.Locations.RemoveGuid(id);
            subpanel_SRPortfolio.ObjectPanel.BindObjectToControls(currentSRP);
        }
    }

    protected void subpanel_SRPortfolio_PopulateForm(object sender, EventArgs e)
    {
        OSurveyRespondent surveyRespondent = (OSurveyRespondent)panel.SessionObject;
        OSurveyRespondentPortfolio currentSRP = (OSurveyRespondentPortfolio)subpanel_SRPortfolio.SessionObject;
        treeLocationAccess.SelectedValue = null;
        ContractID.Bind(TablesLogic.tContract.LoadList(TablesLogic.tContract.IsDeleted == 0, TablesLogic.tContract.ObjectNumber.Asc), "ObjectNumber", "ObjectID");
        ContractID.SelectedValue = null;
        SurveyGroupID.Bind(OSurveyGroup.GetSurveyGroupByType(1), "ObjectName", "ObjectID", true);

        string PRP = Page.Request.Path;
        Session[PRP + "_Locations"] = (List<OLocation>)currentSRP.Locations.Order();
        Session[PRP + "_Contracts"] = (List<OContract>)currentSRP.Contracts.Order();

        subpanel_SRPortfolio.ObjectPanel.BindObjectToControls(currentSRP);
    }

    protected void subpanel_SRPortfolio_PreRender(object sender, EventArgs e)
    {
        OSurveyRespondentPortfolio currentSRP = (OSurveyRespondentPortfolio)subpanel_SRPortfolio.SessionObject;

        panel_Locations.Visible = (currentSRP.SurveyType == SurveyTargetType.SurveyContractedVendor ||
            currentSRP.SurveyType == SurveyTargetType.SurveyOthers);
        panel_Contracts.Visible = (currentSRP.SurveyType == SurveyTargetType.SurveyContractedVendorEvaluatedByMA);

    }

    protected void subpanel_SRPortfolio_Cancelled(object sender, EventArgs e)
    {
        string PRP = Page.Request.Path;
        OSurveyRespondentPortfolio currentSRP = (OSurveyRespondentPortfolio)subpanel_SRPortfolio.SessionObject;
        if (Session[PRP + "_Locations"] != null)
        {
            currentSRP.Locations.Clear();
            currentSRP.Locations.AddRange((List<OLocation>)Session[PRP + "_Locations"]);
        }
        if (Session[PRP + "_Contracts"] != null)
        {
            currentSRP.Contracts.Clear();
            currentSRP.Contracts.AddRange((List<OContract>)Session[PRP + "_Contracts"]);
        }
        subpanel_SRPortfolio.ObjectPanel.BindObjectToControls(currentSRP);
    }

    protected void gridContractAccess_Action(object sender, string commandName, List<object> objectIds)
    {
        if (commandName == "DeleteObject")
        {
            OSurveyRespondentPortfolio currentSRP = (OSurveyRespondentPortfolio)subpanel_SRPortfolio.SessionObject;
            foreach (Guid id in objectIds)
                currentSRP.Contracts.RemoveGuid(id);
            subpanel_SRPortfolio.ObjectPanel.BindObjectToControls(currentSRP);
        }
    }

    protected void gridSRPortfolio_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        OSurveyRespondent surveyRespondent = (OSurveyRespondent)panel.SessionObject;

        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            OSurveyRespondentPortfolio SRP = (OSurveyRespondentPortfolio)surveyRespondent.SurveyRespondentPortfolios.FindObject((Guid)gridSRPortfolio.DataKeys[e.Row.RowIndex][0]);
            if (SRP != null)
            {
                UIGridView subgrid_Locations = (UIGridView)e.Row.FindControl("subgrid_Locations");
                if (subgrid_Locations != null)
                    subgrid_Locations.Visible = (SRP.Locations.Count > 0);

                UIGridView subgrid_Contracts = (UIGridView)e.Row.FindControl("subgrid_Contracts");
                if (subgrid_Contracts != null)
                    subgrid_Contracts.Visible = (SRP.Contracts.Count > 0);

            }
        }
    }

    protected void btn_ContractSearch_Click(object sender, EventArgs e)
    {
        OSurveyRespondent surveyRespondent = (OSurveyRespondent)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(surveyRespondent);
        ContractID.Items.Clear();

        ExpressionCondition EC = null;

        if (treeLocation.SelectedValue != null && treeLocation.SelectedValue.ToString() != "")
        {
            OLocation location = TablesLogic.tLocation[new Guid(treeLocation.SelectedValue)];
            if (location != null)
                EC = TablesLogic.tContract.Locations.HierarchyPath.Like(location.HierarchyPath + "%") | TablesLogic.tContract.ProvideMaintenance == 0;
        }
        else
        {
            List<OLocation> locations = new List<OLocation>();
            //load location from each position
            foreach (OPosition position in AppSession.User.Positions)
                foreach (OLocation loc in position.LocationAccess)
                    locations.Add(loc);
            foreach (OLocation location in locations)
            {
                if (EC == null)
                    EC = TablesLogic.tContract.Locations.HierarchyPath.Like(location.HierarchyPath + "%");
                else
                    EC = EC | TablesLogic.tContract.Locations.HierarchyPath.Like(location.HierarchyPath + "%");
            }
        }

        EC = EC & (SearchObjectName.Text == "" ? Query.True : TablesLogic.tContract.ObjectName.Like("%" + SearchObjectName.Text + "%"));
        EC = EC & (SearchDescription.Text == "" ? Query.True : TablesLogic.tContract.Description.Like("%" + SearchDescription.Text + "%"));
        EC = EC & (SearchContractStartDate.ControlValue == null ? Query.True : TablesLogic.tContract.ContractStartDate >= Convert.ToDateTime(SearchContractStartDate.ControlValue));
        EC = EC & (SearchContractStartDate.ControlValueTo == null ? Query.True : TablesLogic.tContract.ContractStartDate <= Convert.ToDateTime(SearchContractStartDate.ControlValueTo));
        EC = EC & (SearchContractEndDate.ControlValue == null ? Query.True : TablesLogic.tContract.ContractEndDate >= Convert.ToDateTime(SearchContractEndDate.ControlValue));
        EC = EC & (SearchContractEndDate.ControlValueTo == null ? Query.True : TablesLogic.tContract.ContractEndDate <= Convert.ToDateTime(SearchContractEndDate.ControlValueTo));
        EC = EC & (SearchVendorObjectName.Text == "" ? Query.True : TablesLogic.tContract.Vendor.ObjectName.Like("%" + SearchVendorObjectName.Text + "%"));
        EC = EC & (SurveyGroupID.SelectedValue == "" ? Query.True : TablesLogic.tContract.SurveyGroupID == new Guid(SurveyGroupID.SelectedValue));

        List<OContract> Result = TablesLogic.tContract.LoadList(EC);

        ContractID.Bind(Result, "ObjectNumber", "ObjectID", true);

        EmailAddress.SetFocus();
        panel.ObjectPanel.BindObjectToControls(surveyRespondent);
    }

    protected void subpanel_SRPortfolio_ValidateAndUpdate(object sender, EventArgs e)
    {
        OSurveyRespondent surveyRespondent = (OSurveyRespondent)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(surveyRespondent);

        OSurveyRespondentPortfolio currentSRP = (OSurveyRespondentPortfolio)subpanel_SRPortfolio.SessionObject;
        subpanel_SRPortfolio.ObjectPanel.BindControlsToObject(currentSRP);

        surveyRespondent.SurveyRespondentPortfolios.Add(currentSRP);
        string PRP = Page.Request.Path;
        Session.Remove(PRP + "_Locations");
        Session.Remove(PRP + "_Contracts");
        panel.ObjectPanel.BindObjectToControls(surveyRespondent);
    }


    protected void SurveyType_SelectedIndexChanged(object sender, EventArgs e)
    {
        OSurveyRespondentPortfolio currentSRP = (OSurveyRespondentPortfolio)subpanel_SRPortfolio.SessionObject;
        currentSRP.Locations.Clear();
        currentSRP.Contracts.Clear();

        subpanel_SRPortfolio.ObjectPanel.BindControlsToObject(currentSRP);

        SearchObjectName.Text = null;
        SearchDescription.Text = null;
        SearchContractStartDate.ControlValue = null;
        SearchContractStartDate.ControlValueTo = null;
        SearchContractEndDate.ControlValue = null;
        SearchContractEndDate.ControlValueTo = null;
        SearchVendorObjectName.Text = null;
        SurveyGroupID.SelectedValue = null;
        subpanel_SRPortfolio.ObjectPanel.BindObjectToControls(currentSRP);

    }

    protected void ContractID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OSurveyRespondentPortfolio currentSRP = (OSurveyRespondentPortfolio)subpanel_SRPortfolio.SessionObject;
        subpanel_SRPortfolio.ObjectPanel.BindControlsToObject(currentSRP);
        currentSRP.Contracts.AddGuid(new Guid(ContractID.SelectedValue));
        subpanel_SRPortfolio.ObjectPanel.BindObjectToControls(currentSRP);
    }
    
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1"
        BeginningHtml="" EndingHtml="">
        <web:object runat="server" ID="panel" Caption="Survey Respondent" BaseTable="tSurveyRespondent"
            OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave"
            meta:resourcekey="panelResource1"></web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" BorderStyle="NotSet" meta:resourcekey="tabObjectResource1"
                BeginningHtml="" EndingHtml="">
                <ui:UITabView ID="tabDetails" runat="server" Caption="Details" BorderStyle="NotSet"
                    meta:resourcekey="tabDetailsResource1" BeginningHtml="" EndingHtml="">
                    <web:base ID="objectBase" runat="server" ObjectNameCaption="Survey Respondent Name"
                        ObjectNumberVisible="false" meta:resourcekey="objectBaseResource1"></web:base>
                    <ui:UIGridView runat="server" ID="gridSRPortfolio" PropertyName="SurveyRespondentPortfolios"
                        BindObjectsToRows="True" Caption="List Of Portfolios" ValidateRequiredField="True"
                        OnRowDataBound="gridSRPortfolio_RowDataBound" DataKeyNames="ObjectID" GridLines="Both"
                        ImageRowErrorUrl="" meta:resourcekey="gridSRPortfolioResource1" RowErrorColor=""
                        Style="clear: both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <PagerStyle BackColor="Silver" BorderColor="#55AAFF" Height="24px" />
                        <Commands>
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CommandName="DeleteObject" CommandText="Delete"
                                ConfirmText="Are you sure you wish to delete the selected items?" ImageUrl="~/images/delete.gif"
                                meta:resourceKey="UIGridViewCommandResource2" />
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CommandName="AddObject" CommandText="Add"
                                ImageUrl="~/images/add.gif" meta:resourceKey="UIGridViewCommandResource3" />
                        </Commands>
                        <Columns>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ImageUrl="~/images/edit.gif"
                                meta:resourceKey="UIGridViewColumnResource6">
                                <ControlStyle Width="16px" />
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?"
                                ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewButtonColumnResource1">
                                <ControlStyle Width="16px" />
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewBoundColumn DataField="SurveyTypeText" HeaderText="Responds to Survey Type"
                                meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="SurveyTypeText"
                                ResourceAssemblyName="" SortExpression="SurveyTypeText">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="EmailAddress" HeaderText="Email" meta:resourcekey="UIGridViewBoundColumnResource2"
                                PropertyName="EmailAddress" ResourceAssemblyName="" SortExpression="EmailAddress">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="ExpiryDate" DataFormatString="{0:dd-MMM-yyyy}"
                                HeaderText="Expiry Date" meta:resourcekey="UIGridViewBoundColumnResource3" PropertyName="ExpiryDate"
                                ResourceAssemblyName="" SortExpression="ExpiryDate">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewTemplateColumn HeaderText="Locations / Contracts" meta:resourcekey="UIGridViewTemplateColumnResource1">
                                <ItemTemplate>
                                    <cc1:UIGridView ID="subgrid_Locations" runat="server" AllowPaging="False" CheckBoxColumnVisible="False"
                                        DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl="" meta:resourcekey="subgrid_LocationsResource1"
                                        PropertyName="Locations" RowErrorColor="" Style="clear: both;">
                                        <PagerSettings Mode="NumericFirstLast" />
                                        <Columns>
                                            <cc1:UIGridViewBoundColumn DataField="Path" HeaderText="Path" meta:resourcekey="UIGridViewBoundColumnResource4"
                                                PropertyName="Path" ResourceAssemblyName="" SortExpression="Path">
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewBoundColumn>
                                        </Columns>
                                    </cc1:UIGridView>
                                    <cc1:UIGridView ID="subgrid_Contracts" runat="server" AllowPaging="False" CheckBoxColumnVisible="False"
                                        DataKeyNames="ObjectID" GridLines="Both" ImageRowErrorUrl="" meta:resourcekey="subgrid_ContractsResource1"
                                        PropertyName="Contracts" RowErrorColor="" Style="clear: both;">
                                        <PagerSettings Mode="NumericFirstLast" />
                                        <Columns>
                                            <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Contract Name" meta:resourcekey="UIGridViewBoundColumnResource5"
                                                PropertyName="ObjectName" ResourceAssemblyName="" SortExpression="ObjectName">
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewBoundColumn>
                                            <cc1:UIGridViewBoundColumn DataField="Vendor.ObjectName" HeaderText="Vendor" meta:resourcekey="UIGridViewBoundColumnResource6"
                                                PropertyName="Vendor.ObjectName" ResourceAssemblyName="" SortExpression="Vendor.ObjectName">
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle HorizontalAlign="Left" />
                                            </cc1:UIGridViewBoundColumn>
                                        </Columns>
                                    </cc1:UIGridView>
                                </ItemTemplate>
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                        </Columns>
                        <CaptionBarStyle BackColor="#AACCFF" BorderColor="#55AAFF" Font-Bold="True" Height="24px" />
                        <HeaderStyle BackColor="#CCDDFF" BorderColor="#55AAFF" Height="24px" />
                    </ui:UIGridView>
                    <ui:UIObjectPanel runat="server" ID="panel_SRPortfolio" Width="100%" BeginningHtml=""
                        BorderStyle="NotSet" EndingHtml="" meta:resourcekey="panel_SRPortfolioResource1">
                        <web:subpanel runat="server" ID="subpanel_SRPortfolio" GridViewID="gridSRPortfolio"
                            ObjectPanelID="panel_SRPortfolio" OnPopulateForm="subpanel_SRPortfolio_PopulateForm"
                            OnPreRender="subpanel_SRPortfolio_PreRender" OnCancelled="subpanel_SRPortfolio_Cancelled"
                            OnValidateAndUpdate="subpanel_SRPortfolio_ValidateAndUpdate"></web:subpanel>
                        <ui:UIFieldDropDownList runat="server" ID="SurveyType" PropertyName="SurveyType"
                            Caption="Survey Type" Width="100%" ValidateRequiredField="True" 
                            OnSelectedIndexChanged="SurveyType_SelectedIndexChanged" meta:resourcekey="SurveyTypeResource1">
                            <Items>
                                <asp:ListItem meta:resourcekey="ListItemResource1" />
                                <asp:ListItem Value="0" Text="Surveys for Services provided by Contracted Vendors"
                                    meta:resourcekey="ListItemResource2" />
                                <asp:ListItem Value="1" Text="Surveys for Services provided by Contracted Vendors evaluated by Managing Agents"
                                    meta:resourcekey="ListItemResource3" />
                                <asp:ListItem Value="2" Text="Surveys for Other Reasons" meta:resourcekey="ListItemResource4" />
                            </Items>
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldTextBox runat="server" ID="EmailAddress" PropertyName="EmailAddress" Caption="Email Address"
                            Span="Half" Width="100%" ValidateRequiredField="True" InternalControlWidth="95%"
                            meta:resourcekey="EmailAddressResource1" />
                        <ui:UIFieldDateTime runat="server" ID="ExpiryDate" PropertyName="ExpiryDate" Caption="Expiry Date"
                            Width="100%" ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif"
                            ValidationCompareType="Date" meta:resourcekey="ExpiryDateResource1" />
                        <ui:UIPanel runat="server" ID="panel_Locations" BeginningHtml="" BorderStyle="NotSet"
                            EndingHtml="" meta:resourcekey="panel_LocationsResource1">
                            <br />
                            <ui:UIFieldTreeList runat="server" ID="treeLocationAccess" Caption="Location" OnAcquireTreePopulater="treeLocationAccess_AcquireTreePopulater"
                                Width="100%" OnSelectedNodeChanged="treeLocationAccess_SelectedNodeChanged" meta:resourcekey="treeLocationAccessResource1"
                                ShowCheckBoxes="None" TreeValueMode="SelectedNode" />
                            <ui:UIGridView runat="server" ID="gridLocationAccess" PropertyName="Locations" OnAction="gridLocationAccess_Action"
                                Caption="List Of Accessible Location" ValidateRequiredField="True" DataKeyNames="ObjectID"
                                GridLines="Both" ImageRowErrorUrl="" meta:resourcekey="gridLocationAccessResource1"
                                RowErrorColor="" Style="clear: both;">
                                <PagerSettings Mode="NumericFirstLast" />
                                <PagerStyle BackColor="Silver" BorderColor="#55AAFF" Height="24px" />
                                <Columns>
                                    <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?"
                                        ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewButtonColumnResource2">
                                        <ControlStyle Width="16px" />
                                        <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewButtonColumn>
                                    <cc1:UIGridViewBoundColumn DataField="Path" HeaderText="Location Path" meta:resourcekey="UIGridViewBoundColumnResource7"
                                        PropertyName="Path" ResourceAssemblyName="" SortExpression="Path">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                </Columns>
                                <CaptionBarStyle BackColor="#AACCFF" BorderColor="#55AAFF" Font-Bold="True" Height="24px" />
                                <HeaderStyle BackColor="#CCDDFF" BorderColor="#55AAFF" Height="24px" />
                            </ui:UIGridView>
                        </ui:UIPanel>
                        <ui:UIPanel runat="server" ID="panel_Contracts" BeginningHtml="" BorderStyle="NotSet"
                            EndingHtml="" meta:resourcekey="panel_ContractsResource1">
                            <ui:UIPanel runat="server" ID="panel_Search" BeginningHtml="" BorderStyle="NotSet"
                                EndingHtml="" meta:resourcekey="panel_SearchResource1">
                                <ui:UISeparator runat="server" ID="Separator1" Caption="Contract Search" meta:resourcekey="Separator1Resource1">
                                </ui:UISeparator>
                                <ui:UIPanel runat="server" ID="panel_SearchBackground" BackColor="#EEEEEE" BorderWidth="1px"
                                    Height="200px" BeginningHtml="" BorderStyle="NotSet" EndingHtml="" meta:resourcekey="panel_SearchBackgroundResource1">
                                    <ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location" OnAcquireTreePopulater="treeLocation_AcquireTreePopulater"
                                        AjaxPostBack="False" IsModifiedByAjax="False" OnSelectedNodeChanged="treeLocation_SelectedNodeChanged"
                                        meta:resourcekey="treeLocationResource1" ShowCheckBoxes="None" TreeValueMode="SelectedNode" />
                                    <ui:UIFieldTextBox runat='server' ID="SearchObjectName" Caption="Contract Name" ToolTip="The name of the contract as displayed on screen."
                                        Height="20px" meta:resourcekey="UIFieldString1Resource1" Width="99%" MaxLength="255"
                                        AjaxPostBack="False" IsModifiedByAjax="False" InternalControlWidth="95%" />
                                    <ui:UIFieldTextBox runat='server' ID="SearchDescription" Caption="Description" ToolTip="The description of the contract in detail."
                                        MaxLength="255" Height="20px" meta:resourcekey="UIFieldTextBox2Resource1" Width="99%"
                                        AjaxPostBack="False" IsModifiedByAjax="False" InternalControlWidth="95%" />
                                    <ui:UIFieldDateTime runat='server' ID="SearchContractStartDate" Caption="Start Date"
                                        ToolTip="The date in which the contract starts. Works that begin within the start and end of this contract can be assigned to this contract's vendor."
                                        Height="20px" ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif"
                                        meta:resourcekey="uifieldatetime1Resource1" Width="99%" SearchType="Range" AjaxPostBack="False"
                                        IsModifiedByAjax="False" />
                                    <ui:UIFieldDateTime runat='server' ID="SearchContractEndDate" Caption="End Date"
                                        ToolTip="The date in which the contract ends. Works that begin within the start and end of this contract can be assigned to this contract's vendor."
                                        Height="20px" ImageClearUrl="~/calendar/dateclr.gif" ImageUrl="~/calendar/date.gif"
                                        meta:resourcekey="uifieldatetime2Resource1" Width="99%" SearchType="Range" AjaxPostBack="False"
                                        IsModifiedByAjax="False" />
                                    <ui:UIFieldTextBox runat='server' ID="SearchVendorObjectName" Caption="Vendor Name"
                                        ToolTip="The vendor responsible for carrying out the work as indicated by this contract."
                                        MaxLength="255" Height="20px" meta:resourcekey="UIFieldTextBox4Resource1" Width="99%"
                                        AjaxPostBack="False" IsModifiedByAjax="False" InternalControlWidth="95%" />
                                    <ui:UIFieldDropDownList ID="SurveyGroupID" runat="server" Caption="Survey Group"
                                        Width="99%" meta:resourcekey="SurveyGroupIDResource1">
                                    </ui:UIFieldDropDownList>
                                    <ui:UIButton ID="btn_ContractSearch" runat="server" Text="Search" ImageUrl="~/images/find.gif"
                                        OnClick="btn_ContractSearch_Click" meta:resourcekey="btn_ContractSearchResource1">
                                    </ui:UIButton>
                                </ui:UIPanel>
                                <ui:UISeparator runat="server" ID="Separator2" meta:resourcekey="Separator2Resource1">
                                </ui:UISeparator>
                            </ui:UIPanel>
                            <ui:UIFieldDropDownList runat="server" ID="ContractID" Caption="Contract" Width="100%"
                                OnSelectedIndexChanged="ContractID_SelectedIndexChanged" meta:resourcekey="ContractIDResource1">
                            </ui:UIFieldDropDownList>
                            <ui:UIGridView runat="server" ID="gridContractAccess" PropertyName="Contracts" Caption="List Of Accessible Contract"
                                ValidateRequiredField="True" OnAction="gridContractAccess_Action" DataKeyNames="ObjectID"
                                GridLines="Both" ImageRowErrorUrl="" meta:resourcekey="gridContractAccessResource1"
                                RowErrorColor="" Style="clear: both;">
                                <PagerSettings Mode="NumericFirstLast" />
                                <PagerStyle BackColor="Silver" BorderColor="#55AAFF" Height="24px" />
                                <Columns>
                                    <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?"
                                        ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewButtonColumnResource3">
                                        <ControlStyle Width="16px" />
                                        <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewButtonColumn>
                                    <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Contract Name" meta:resourcekey="UIGridViewBoundColumnResource8"
                                        PropertyName="ObjectName" ResourceAssemblyName="" SortExpression="ObjectName">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                    <cc1:UIGridViewBoundColumn DataField="Vendor.ObjectName" HeaderText="Vendor" meta:resourcekey="UIGridViewBoundColumnResource9"
                                        PropertyName="Vendor.ObjectName" ResourceAssemblyName="" SortExpression="Vendor.ObjectName">
                                        <HeaderStyle HorizontalAlign="Left" />
                                        <ItemStyle HorizontalAlign="Left" />
                                    </cc1:UIGridViewBoundColumn>
                                </Columns>
                                <CaptionBarStyle BackColor="#AACCFF" BorderColor="#55AAFF" Font-Bold="True" Height="24px" />
                                <HeaderStyle BackColor="#CCDDFF" BorderColor="#55AAFF" Height="24px" />
                            </ui:UIGridView>
                        </ui:UIPanel>
                    </ui:UIObjectPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabMemo" Caption="Memo" BorderStyle="NotSet" meta:resourcekey="tabMemoResource1"
                    BeginningHtml="" EndingHtml="">
                    <web:memo runat="server" ID="memo1"></web:memo>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabAttachments" Caption="Attachments" BorderStyle="NotSet"
                    meta:resourcekey="tabAttachmentsResource1" BeginningHtml="" EndingHtml="">
                    <web:attachments runat="server" ID="attachments"></web:attachments>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
