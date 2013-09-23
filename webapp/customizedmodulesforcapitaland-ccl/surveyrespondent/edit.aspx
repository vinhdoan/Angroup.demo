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
        OSurveyRespondentPortfolio portfolio = (OSurveyRespondentPortfolio)panel.SessionObject;
        treeLocation.PopulateTree();
        //listLocations.Bind(AppSession.User.GetAllAccessibleLocation(OApplicationSetting.Current.LocationTypeNameForBuildingActual, "OSurveyRespondentPortfolio"), "ParentPath", "ObjectID");

        panel.ObjectPanel.BindObjectToControls(portfolio);
        
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
            OSurveyRespondentPortfolio portfolio = (OSurveyRespondentPortfolio)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(portfolio);

            // Validate
            //

            // Save
            //
            portfolio.Save();
            c.Commit();
        }  
    }

    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        OSurveyRespondentPortfolio sr = (OSurveyRespondentPortfolio)panel.SessionObject;
        return new LocationTreePopulaterForCapitaland(null, false, true,
            Security.Decrypt(Request["TYPE"]), false, false);
    }

    /// <summary>
    /// Hides/shows elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        OSurveyRespondentPortfolio portfolio = panel.SessionObject as OSurveyRespondentPortfolio;
        //listLocations.Visible = !checkAppliesToAllLocations.Checked;

    }


    protected void gridLocations_Action(object sender, string commandName, List<object> dataKeys)
    {
        OSurveyRespondentPortfolio portfolio = panel.SessionObject as OSurveyRespondentPortfolio;
        panel.ObjectPanel.BindControlsToObject(portfolio);

        if (commandName == "RemoveLocation")
        {
            
            foreach (Guid id in dataKeys)
            {
                //Remove Location
                portfolio.Locations.RemoveGuid(id);

                //Remove Respondents
                OLocation locParent = TablesLogic.tLocation.Load(id);
                List<OLocation> locations = TablesLogic.tLocation.LoadList(TablesLogic.tLocation.HierarchyPath.Like(locParent.HierarchyPath + "%") &
                TablesLogic.tLocation.LocationType.ObjectName != "Building" & TablesLogic.tLocation.IsActive == 1
                & TablesLogic.tLocation.IsDeleted == 0);

                foreach (OLocation loc in locations)
                {
                    List<OTenantLease> leases = TablesLogic.tTenantLease.LoadList(TablesLogic.tTenantLease.LocationID == loc.ObjectID);
                    foreach (OTenantLease lease in leases)
                    {
                        OTenantContact contact = lease.TenantContact;
                        OSurveyRespondent respondent = portfolio.SurveyRespondents.Find((p) => p.TenantID == contact.TenantID && p.ObjectName == contact.ObjectName);
                        if ( respondent != null)
                            portfolio.SurveyRespondents.Remove(respondent);
                    }
                }
            }     
                   
        }

        panel.ObjectPanel.BindObjectToControls(portfolio);
    }



    protected void gridSurveyRespondents_Action(object sender, string commandName, List<object> dataKeys)
    {
        OSurveyRespondentPortfolio portfolio = panel.SessionObject as OSurveyRespondentPortfolio;
        panel.ObjectPanel.BindControlsToObject(portfolio);

        //21stNov2012
        //var session = HttpContext.Current.Session;
        //if (Session["btnClicked"] == null)
        //{
        //    session.Add("btnClicked",""); 
        //}
        
        if (commandName == "AddRespondents")
        {
            searchTenantContacts.Show();
        }

        if (commandName == "RemoveRespondent")
        {
            foreach (Guid id in dataKeys)
                portfolio.SurveyRespondents.RemoveGuid(id);
        }
        
        //21stNov2012
        if (commandName == "AddNonTenantRespondents")
        {
            //Session["btnClicked"] = "AddNonTenantRespondents";

            OSurveyRespondent respondent = TablesLogic.tSurveyRespondent.Create();
            respondent.TenantID = null;
            respondent.EmailAddress = "";
            respondent.ObjectName = "";

            portfolio.SurveyRespondents.Add(respondent);

            //panel.ObjectPanel.BindControlsToObject(Session["btnClicked"]);
        }

        panel.ObjectPanel.BindObjectToControls(portfolio); 
    }
   
    protected void searchTenantContacts_Searched(objectSearchDialogBox.SearchEventArgs e)
    {
        e.CustomCondition = TablesLogic.tTenantContact.TenantID != null;
    }

    protected void searchTenantContacts_Selected(object sender, EventArgs e)
    {
        OSurveyRespondentPortfolio portfolio = panel.SessionObject as OSurveyRespondentPortfolio;
        panel.ObjectPanel.BindControlsToObject(portfolio);

        List<OTenantContact> contacts = TablesLogic.tTenantContact.LoadList(TablesLogic.tTenantContact.ObjectID.In(searchTenantContacts.SelectedDataKeys));
        foreach (OTenantContact contact in contacts)
        {
            if (portfolio.SurveyRespondents.Find((p) => p.TenantID == contact.TenantID) == null)
            {
                OSurveyRespondent respondent = TablesLogic.tSurveyRespondent.Create();
                respondent.TenantID = contact.TenantID;
                respondent.EmailAddress = contact.Email;
                respondent.ObjectName = contact.ObjectName;

                portfolio.SurveyRespondents.Add(respondent);
            }
        }

        panel.ObjectPanel.BindObjectToControls(portfolio);
    }


    protected void checkAppliesToAllLocations_CheckedChanged(object sender, EventArgs e)
    {

    }

    protected void treeLocation_SelectedNodeChanged(object sender, EventArgs e)
    {
        OSurveyRespondentPortfolio portfolio = panel.SessionObject as OSurveyRespondentPortfolio;
        panel.ObjectPanel.BindControlsToObject(portfolio);
        Guid locID = new Guid(treeLocation.SelectedValue);
        //Update Locations
        portfolio.Locations.AddGuid(locID);
        OLocation locParent = TablesLogic.tLocation.Load(locID);

        //Update Respondents
        List<OLocation> locations = TablesLogic.tLocation.LoadList(TablesLogic.tLocation.HierarchyPath.Like(locParent.HierarchyPath + "%") &
            TablesLogic.tLocation.LocationType.ObjectName != "Building" & TablesLogic.tLocation.IsActive == 1
            & TablesLogic.tLocation.IsDeleted == 0 );

        foreach (OLocation loc in locations)
        {
            List<OTenantLease> leases = TablesLogic.tTenantLease.LoadList(TablesLogic.tTenantLease.LocationID == loc.ObjectID);
            foreach (OTenantLease lease in leases)
            {
                OTenantContact contact = lease.TenantContact;
                if (portfolio.SurveyRespondents.Find((p) => p.TenantID == contact.TenantID) == null)
                {
                    OSurveyRespondent respondent = TablesLogic.tSurveyRespondent.Create();
                    respondent.TenantID = contact.TenantID;
                    respondent.EmailAddress = contact.Email;
                    respondent.ObjectName = contact.ObjectName;

                    portfolio.SurveyRespondents.Add(respondent);
                }
            }
        }

        panel.ObjectPanel.BindObjectToControls(portfolio);
    }

    //21stNov2012
    //protected void gridSurveyRespondents_RowDataBound(object sender, GridViewRowEventArgs e)
    //{
    //    if (Session["btnClicked"] == "AddNonTenantRespondents" && e.Row.RowIndex >= 0)
    //    {
    //        ((UIFieldTextBox)e.Row.FindControl("textName")).Enabled = true;
    //        ((UIFieldTextBox)e.Row.FindControl("textTenant")).Enabled = true;
    //    }
        
    //}
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
        <web:object runat="server" ID="panel" Caption="Survey Address Book" BaseTable="tSurveyRespondentPortfolio"
            OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave"
            meta:resourcekey="panelResource1"></web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" BorderStyle="NotSet" meta:resourcekey="tabObjectResource1"
                BeginningHtml="" EndingHtml="">
                <ui:UITabView ID="tabDetails" runat="server" Caption="Details" BorderStyle="NotSet"
                    meta:resourcekey="tabDetailsResource1" BeginningHtml="" EndingHtml="">
                    <web:base ID="objectBase" runat="server" ObjectNameCaption="Respondent Portfolio Name"
                        ObjectNumberVisible="false" meta:resourcekey="objectBaseResource1"></web:base>
                    <%--<ui:UIFieldRadioList runat="server" ID="radioSurveyTargetType" PropertyName="SurveyType"
                        Caption="Survey Target Type" Width="100%" ValidateRequiredField="True"
                        RepeatColumns="0" RepeatLayout="Flow" RepeatDirection="Vertical"
                        meta:resourcekey="SurveyTypeResource1" OnSelectedIndexChanged="radioSurveyTargetType_SelectedIndexChanged">
                        <Items>
                            <asp:ListItem Value="0" Text="Tenant Surveys" Selected="True"></asp:ListItem>
                            <asp:ListItem Value="1" Text="Service Surveys for Non Contracted Vendors"></asp:ListItem>
                            <asp:ListItem Value="2" Text="Service Surveys for Contracted Vendors"></asp:ListItem>
                            <asp:ListItem Value="3" Text="Other Surveys"></asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>
                    <br />
                    <ui:UIFieldRadioList runat="server" ID="radioRespondentType" 
                        Caption="Type" PropertyName="RespondentType" ValidateRequiredField="true"
                        RepeatColumns="3" RepeatDirection="Horizontal" OnSelectedIndexChanged="radioRespondentType_SelectedIndexChanged">
                        <Items>
                            <asp:ListItem Text="Tenants" Value="0" Selected="True"></asp:ListItem>
                            <asp:ListItem Text="Existing Users" Value="1"></asp:ListItem>
                            <asp:ListItem Text="Others" Value="2"></asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>--%>
                    <%--<ui:UIFieldCheckBox runat="server" ID="checkAppliesToAllLocations" Caption="Locations"
                        PropertyName="AppliesToAllLocations" Text="Yes, this address book applies to all locations"
                        TextAlign="Right" OnCheckedChanged="checkAppliesToAllLocations_CheckedChanged">
                    </ui:UIFieldCheckBox>--%>
                    <ui:UIFieldTreeList ID="treeLocation" runat="server" Caption="Location" ShowCheckBoxes="None"
                        TreeValueMode="SelectedNode" OnSelectedNodeChanged="treeLocation_SelectedNodeChanged"
                        OnAcquireTreePopulater="treeLocation_AcquireTreePopulater"
                        meta:resourcekey="treeLocationResource1">
                    </ui:UIFieldTreeList>
                    <ui:UIGridView runat="server" ID="gridLocations" PropertyName="Locations" Caption="Locations"
                        ToolTip="Locations that accessible to this address book"
                        KeyName="ObjectID" BindObjectsToRows="True" DataKeyNames="ObjectID" GridLines="Both"
                        SortExpression="ParentPath" OnAction="gridLocations_Action">
                        <Commands>
                            <cc1:UIGridViewCommand CommandName="RemoveLocation" CommandText="Remove" ImageUrl="~/images/delete.gif"
                                CausesValidation="false" />
                        </Commands>
                        <Columns>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveLocation" ConfirmText="Are you sure you wish to remove this item?"
                                ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource1">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Name" PropertyName="ObjectName"
                                ResourceAssemblyName="" SortExpression="ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="FastPath" HeaderText="Path" PropertyName="FastPath"
                                ResourceAssemblyName="" SortExpression="ParentPath">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                    <%--<ui:UIFieldListBox runat="server" ID="listLocations" Caption="" PropertyName="Locations"
                        CaptionPosition="Top" ToolTip="Locations that accessible to this address book">
                    </ui:UIFieldListBox>--%>
                    <%--<web:searchdialogbox runat="server" ID="searchUsers"
                        Title="Users" AllowMultipleSelection="true" BaseTable="tUser"
                        MaximumNumberOfResults="200" SearchTextBoxPropertyNames="ObjectName,UserBase.Email" OnSearched="searchUsers_Searched" OnSelected="searchUsers_Selected">
                        <Columns>
                            <ui:UIGridViewBoundColumn HeaderText="User Name" HeaderStyle-Width="300px" PropertyName="ObjectName"></ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn HeaderText="Login Name" HeaderStyle-Width="200px" PropertyName="UserBase.LoginName"></ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn HeaderText="Email" HeaderStyle-Width="200px" PropertyName="UserBase.Email"></ui:UIGridViewBoundColumn>
                        </Columns>
                    </web:searchdialogbox>--%>
                    <web:searchdialogbox runat="server" ID="searchTenantContacts" AllowMultipleSelection="true"
                        BaseTable="tTenantContact" MaximumNumberOfResults="300" SearchTextBoxPropertyNames="ObjectName,Tenant.ObjectName,Email,Tenant.TenantLeases.Location.Parent.Parent.ObjectName"
                        SearchType="Phrase" OnSearched="searchTenantContacts_Searched" OnSelected="searchTenantContacts_Selected">
                        <Columns>
                            <ui:UIGridViewBoundColumn HeaderText="Name" HeaderStyle-Width="150px" PropertyName="ObjectName">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn HeaderText="Tenant" HeaderStyle-Width="200px" PropertyName="Tenant.ObjectName">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn HeaderText="Email address" HeaderStyle-Width="250px" PropertyName="Email">
                            </ui:UIGridViewBoundColumn>
                        </Columns>
                    </web:searchdialogbox>
                    <ui:UIGridView runat="server" ID="gridSurveyRespondents" PropertyName="SurveyRespondents"
                        Caption="Survey Respondents" ValidateRequiredField="True" ToolTip="Survey Respondents"
                        KeyName="ObjectID" BindObjectsToRows="True" DataKeyNames="ObjectID" GridLines="Both"
                        OnAction="gridSurveyRespondents_Action" >
                        <Commands>
                            <cc1:UIGridViewCommand CommandName="AddRespondents" CommandText="Add" ImageUrl="~/images/add.gif"
                                CausesValidation="false" />
                            <cc1:UIGridViewCommand CommandName="RemoveRespondent" CommandText="Remove" ImageUrl="~/images/delete.gif"
                                CausesValidation="false" />
                            <cc1:UIGridViewCommand CommandName="AddNonTenantRespondents" CommandText="Add New" ImageUrl="~/images/add.gif"
                                CausesValidation="false" />
                        </Commands>
                        <Columns>
                            <%-- <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveRespondent" ConfirmText="Are you sure you wish to remove this item?"
                                ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource1">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Name" PropertyName="ObjectName"
                                ResourceAssemblyName="" SortExpression="ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Tenant.ObjectName" HeaderText="Tenant" PropertyName="Tenant.ObjectName"
                                ResourceAssemblyName="" SortExpression="Tenant.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn> --%>
                            <%--19thNov2012--%>
                             <cc1:UIGridViewTemplateColumn HeaderText="Name">
                                <HeaderStyle Font-Bold="true" />
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textName" PropertyName="ObjectName"
                                        FieldLayout="Flow" InternalControlWidth="200px" ShowCaption="false" Caption="Name"
                                        ValidateRequiredField="true" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </cc1:UIGridViewTemplateColumn>
                            <%--19thNov2012--%>
                            <cc1:UIGridViewTemplateColumn HeaderText="Tenant">
                                <HeaderStyle Font-Bold="true" />
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textTenant" PropertyName="Tenant.ObjectName"
                                        FieldLayout="Flow" InternalControlWidth="400px" ShowCaption="false" Caption="Tenant"
                                        ValidateRequiredField="true" >
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </cc1:UIGridViewTemplateColumn> 
                            <cc1:UIGridViewTemplateColumn HeaderText="E-mail address">
                                <HeaderStyle Font-Bold="true" />
                                <ItemTemplate>
                                    <ui:UIFieldTextBox runat="server" ID="textEmailAddress" PropertyName="EmailAddress"
                                        FieldLayout="Flow" InternalControlWidth="200px" ShowCaption="false" Caption="E-mail"
                                        ValidateRequiredField="true">
                                    </ui:UIFieldTextBox>
                                </ItemTemplate>
                            </cc1:UIGridViewTemplateColumn>
                        </Columns>
                    </ui:UIGridView>
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
