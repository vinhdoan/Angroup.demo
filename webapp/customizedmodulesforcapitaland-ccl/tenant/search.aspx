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
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        //labelUserLicenseCount.Text = OUserBase.GetUserLicenseText();
    }

    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        List<OPosition> positions = AppSession.User.GetPositionsByObjectType(Security.Decrypt(Request["TYPE"]));
        ExpressionCondition cond = Query.False;
        foreach (OPosition position in positions)
            foreach (OLocation location in position.LocationAccess)
                cond = cond | TablesLogic.tUser.TenantLeases.LocationID.In(TablesLogic.tLocation.Select(TablesLogic.tLocation.ObjectID).Where(TablesLogic.tLocation.HierarchyPath.Like(location.HierarchyPath + "%")));

        e.CustomCondition = Query.True;
        e.CustomCondition = e.CustomCondition & (TablesLogic.tUser.isTenant == 1 | TablesLogic.tUser.TenantLeases.ObjectID == null);
        if (rdlFromAmos.SelectedIndex == 1)
            e.CustomCondition = e.CustomCondition & TablesLogic.tUser.FromAmos == 1;
        else if (rdlFromAmos.SelectedIndex == 2)
            e.CustomCondition = e.CustomCondition & (TablesLogic.tUser.FromAmos == 0 | TablesLogic.tUser.FromAmos == null);
        if (ddlTenantContactType.SelectedValue != null && ddlTenantContactType.SelectedValue != "")
            e.CustomCondition = e.CustomCondition & TablesLogic.tUser.TenantContacts.TenantContactTypeID == new Guid(ddlTenantContactType.SelectedValue);

        e.CustomCondition = e.CustomCondition & cond;
    }


    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        ddlTenantType.Bind(OCode.GetCodesByType("TenantType", null));
        ddlTenantContactType.Bind(OCode.GetCodesByType("TenantContactType", null));
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ui:UIObjectPanel runat="server" ID="formMain" BorderStyle="NotSet" meta:resourcekey="formMainResource2">
        <web:search runat="server" ID="panel" Caption="Tenant" GridViewID="gridResults" BaseTable="tUser"
            EditButtonVisible="false" AutoSearchOnLoad="false" MaximumNumberOfResults="300"
            SearchTextBoxPropertyNames="ObjectName,UserBase.Phone,UserBase.Cellphone,TenantLeases.ShopName,TenantContacts.DID,TenantContacts.Cellphone,TenantContacts.Email"
            AdvancedSearchPanelID="panelAdvanced" SearchTextBoxHint="Tenant Name, Contact Information, DID, Cellphone, etc..."
            meta:resourcekey="panelResource1" OnPopulateForm="panel_PopulateForm" OnSearch="panel_Search">
        </web:search>
        <div class="div-form">
            <%--<ui:UITabStrip runat="server" ID="tabSearch" 
                    meta:resourcekey="tabSearchResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Search" 
                        meta:resourcekey="uitabview1Resource1" 
                        BorderStyle="NotSet">--%>
            <ui:UIPanel runat="server" ID="panelAdvanced" BorderStyle="NotSet">
                <%--<ui:UIFieldTextBox runat='server' ID='UIFieldString1' PropertyName="ObjectName" Caption="Tenant Name"
                            ToolTip="The user name as displayed on screen." Span="Half" 
                            MaxLength="255" meta:resourcekey="UIFieldString1Resource1" 
                            InternalControlWidth="95%" />
                        <br />
                        <ui:UISeparator runat="server" ID="sep1" meta:resourcekey="sep1Resource1" />--%>
                <ui:UIFieldDropDownList runat="server" ID="ddlTenantType" PropertyName="TenantTypeID"
                    Caption="Tenant Type" Span="Half" meta:resourcekey="ddlTenantTypeResource1">
                </ui:UIFieldDropDownList>
                <ui:UIFieldTextBox ID="UIFieldTextBox1" runat="server" PropertyName="IndustryTrade"
                    Caption="Industry Trade" InternalControlWidth="95%" meta:resourcekey="UIFieldTextBoxResource1">
                </ui:UIFieldTextBox>
                <ui:UIFieldTextBox ID="UIFieldTextBox2" runat="server" PropertyName="UserBase.Address"
                    Caption="Address" InternalControlWidth="95%" meta:resourcekey="UIFieldTextBox2Resource1">
                </ui:UIFieldTextBox>
                <ui:UIFieldTextBox ID="UIFieldTextBox3" runat="server" PropertyName="Website" Caption="Website"
                    InternalControlWidth="95%" meta:resourcekey="UIFieldTextBox3Resource1">
                </ui:UIFieldTextBox>
                <%--<ui:UIFieldTextBox runat="server" ID="uifieldstring5" PropertyName="UserBase.Email"
                            Caption="Email" meta:resourcekey="uifieldstring5Resource1" 
                            InternalControlWidth="95%" />
                        <ui:UIFieldTextBox runat="server" ID="uifieldstring6" PropertyName="UserBase.Fax"
                            Caption="Fax" Span="Half" meta:resourcekey="uifieldstring6Resource1" 
                            InternalControlWidth="95%" />
                        <ui:UIFieldTextBox runat="server" ID="UIFieldTextBox17" PropertyName="UserBase.Phone"
                            Caption="Phone" Span="Half" meta:resourcekey="UIFieldTextBox1Resource1" 
                            InternalControlWidth="95%" />--%>
                <ui:UIFieldTextBox ID="UIFieldTextBox4" runat="server" PropertyName="TenantProfile"
                    Caption="Tenant Profile" TextMode="MultiLine" Rows="5" InternalControlWidth="95%"
                    meta:resourcekey="UIFieldTextBox4Resource1">
                </ui:UIFieldTextBox>
                <ui:UIFieldTextBox ID="UIFieldTextBox5" runat="server" PropertyName="Highlights"
                    Caption="Highlights" TextMode="MultiLine" Rows="5" InternalControlWidth="95%"
                    meta:resourcekey="UIFieldTextBox5Resource1">
                </ui:UIFieldTextBox>
                <ui:UIFieldTextBox ID="UIFieldTextBox6" runat="server" PropertyName="OperationHours"
                    Caption="Operation Hours" InternalControlWidth="95%" meta:resourcekey="UIFieldTextBox6Resource1">
                </ui:UIFieldTextBox>
                <ui:UIFieldRadioList runat="server" Caption="From Amos" ID="rdlFromAmos" RepeatColumns="3"
                    RepeatDirection="Vertical" meta:resourcekey="rdlFromAmosResource1" TextAlign="Right">
                    <Items>
                        <asp:ListItem meta:resourcekey="ListItemResource1">All</asp:ListItem>
                        <asp:ListItem Value="1" meta:resourcekey="ListItemResource2">Yes</asp:ListItem>
                        <asp:ListItem Value="0" meta:resourcekey="ListItemResource3">No</asp:ListItem>
                    </Items>
                </ui:UIFieldRadioList>
                <ui:UIFieldTextBox ID="AmosOrgID" runat="server" Caption="Amos Org ID" InternalControlWidth="95%"
                    PropertyName="AmosOrgID" Span="Half" SearchType="Range" ValidationDataType="Integer"
                    meta:resourcekey="AmosOrgIDResource1">
                </ui:UIFieldTextBox>
                <ui:UIFieldDateTime ID="updatedOn" runat="server" Caption="Updated On" InternalControlWidth="95%"
                    PropertyName="updatedOn" Span="Half" SearchType="Range" meta:resourcekey="updatedOnResource1"
                    ShowDateControls="True">
                </ui:UIFieldDateTime>
                <ui:UIFieldDropDownList ID="ddlTenantContactType" runat="server" Caption="Tenant Contact Type"
                    Span="Half" meta:resourcekey="ddlTenantContactTypeResource1">
                </ui:UIFieldDropDownList>
                <%--<ui:UISeparator runat="server" ID="sep2" meta:resourcekey="sep2Resource1" />
                        <ui:UIFieldTextBox ID="UIFieldTextBox7" runat="server" PropertyName="TenantContacts.ObjectName" Caption="Tenant Contact Name" InternalControlWidth="95%" meta:resourcekey="UIFieldTextBox7Resource1"></ui:UIFieldTextBox>
                        <ui:UIFieldTextBox ID="UIFieldTextBox8" runat="server" PropertyName="TenantContacts.Position" Caption="Tenant Contact Position" InternalControlWidth="95%" meta:resourcekey="UIFieldTextBox8Resource1"></ui:UIFieldTextBox>
                        <ui:UIFieldTextBox ID="UIFieldTextBox9" runat="server" PropertyName="TenantContacts.Department" Caption="Tenant Contact Department" InternalControlWidth="95%" meta:resourcekey="UIFieldTextBox9Resource1"></ui:UIFieldTextBox>
                        <ui:UIFieldTextBox ID="UIFieldTextBox10" runat="server" PropertyName="TenantContacts.DID" Caption="Tenant Contact DID" Span="Half" InternalControlWidth="95%" meta:resourcekey="UIFieldTextBox10Resource1"></ui:UIFieldTextBox>
                        <ui:UIFieldTextBox ID="UIFieldTextBox11" runat="server" PropertyName="TenantContacts.Fax" Caption="Tenant Contact Fax" Span="Half" InternalControlWidth="95%" meta:resourcekey="UIFieldTextBox11Resource1"></ui:UIFieldTextBox>
                        <ui:UIFieldTextBox ID="UIFieldTextBox12" runat="server" PropertyName="TenantContacts.Email" Caption="Tenant Contact Email" Span="Half" InternalControlWidth="95%" meta:resourcekey="UIFieldTextBox12Resource1"></ui:UIFieldTextBox>
                        <ui:UIFieldTextBox ID="UIFieldTextBox13" runat="server" PropertyName="TenantContacts.Cellphone" Caption="Tenant Contact Cellphone" Span="Half" InternalControlWidth="95%" meta:resourcekey="UIFieldTextBox13Resource1"></ui:UIFieldTextBox>
                        <ui:UIFieldTextBox ID="UIFieldTextBox14" runat="server" PropertyName="TenantContacts.Likes" Caption="Tenant Contact Likes" TextMode="MultiLine" Rows="5" InternalControlWidth="95%" meta:resourcekey="UIFieldTextBox14Resource1"></ui:UIFieldTextBox>
                        <ui:UIFieldTextBox ID="UIFieldTextBox15" runat="server" PropertyName="TenantContacts.Dislikes" Caption="Tenant Contact Dislikes" TextMode="MultiLine" Rows="5" InternalControlWidth="95%" meta:resourcekey="UIFieldTextBox15Resource1"></ui:UIFieldTextBox>
                        <ui:UIFieldTextBox ID="UIFieldTextBox16" runat="server" PropertyName="TenantContacts.AdditionalInformation" Caption="Tenant Contact Additional Information" TextMode="MultiLine" Rows="5" InternalControlWidth="95%" meta:resourcekey="UIFieldTextBox16Resource1"></ui:UIFieldTextBox>--%>
            </ui:UIPanel>
            <%--</ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview2" Caption="Results" 
                        meta:resourcekey="uitabview2Resource1" 
                        BorderStyle="NotSet">--%>
            <ui:UIGridView runat="server" ID="gridResults" BorderColor="Black" KeyName="ObjectID"
                meta:resourcekey="gridResultsResource1" Width="100%" DataKeyNames="ObjectID"
                GridLines="Both" RowErrorColor="" Style="clear: both;">
                <PagerSettings Mode="NumericFirstLast" />
                <Commands>
                    <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject"
                        CommandText="Delete Selected" ConfirmText="Are you sure you wish to delete the selected items?"
                        ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
                </Commands>
                <Columns>
                    <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ImageUrl="~/images/edit.gif"
                        meta:resourceKey="UIGridViewColumnResource1">
                        <HeaderStyle HorizontalAlign="Left" Width="16px" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewButtonColumn>
                    <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewObject" ImageUrl="~/images/view.gif"
                        meta:resourceKey="UIGridViewColumnResource2">
                        <HeaderStyle HorizontalAlign="Left" Width="16px" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewButtonColumn>
                    <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?"
                        ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource3">
                        <HeaderStyle HorizontalAlign="Left" Width="16px" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewButtonColumn>
                    <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Tenant Name" meta:resourceKey="UIGridViewColumnResource4"
                        PropertyName="ObjectName" ResourceAssemblyName="" SortExpression="ObjectName">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="AmosOrgID" HeaderText="AmosOrgID" PropertyName="AmosOrgID"
                        ResourceAssemblyName="" SortExpression="AmosOrgID">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                    <cc1:UIGridViewBoundColumn DataField="TenantType.ObjectName" HeaderText="Tenant Type"
                        PropertyName="TenantType.ObjectName" ResourceAssemblyName="" SortExpression="TenantType.ObjectName"
                        meta:resourcekey="UIGridViewBoundColumnResource1">
                        <HeaderStyle HorizontalAlign="Left" />
                        <ItemStyle HorizontalAlign="Left" />
                    </cc1:UIGridViewBoundColumn>
                </Columns>
            </ui:UIGridView>
            <%--<br />
                        <asp:Label runat="server" ID="labelUserLicense" meta:resourcekey="labelUserLicenseResource1"
                            Text="Licenses: "></asp:Label>
                        <asp:Label runat="server" ID="labelUserLicenseCount" meta:resourcekey="labelUserLicenseCountResource1"></asp:Label>--%>
            <%--</ui:UITabView>
                </ui:UITabStrip>--%>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
