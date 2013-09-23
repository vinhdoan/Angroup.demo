<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        labelUserLicenseCount.Text = OUserBase.GetUserLicenseText();
    }



    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        List<OLocation> locations = new List<OLocation>();
        foreach (OPosition position in AppSession.User.GetPositionsByObjectType(Security.Decrypt(Request["TYPE"])))
            foreach (OLocation location in position.LocationAccess)
                locations.Add(location);

        listPositions.Bind(OPosition.GetPositionsAtOrBelowLocations(locations));
        listRoles.Bind(ORole.GetAllRoles(), "RoleName", "ObjectID");
        
    }

    
    /// <summary>
    /// Filters the users by what the currently logged on user
    /// has access to.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        List<OLocation> locations = new List<OLocation>();
        foreach (OPosition position in AppSession.User.GetPositionsByObjectType("OUser"))
            foreach(OLocation location in position.LocationAccess)
                locations.Add(location);

        List<OPosition> positions = OPosition.GetPositionsAtOrBelowLocations(locations);

        TUser u = TablesLogic.tUser;
        TUser u2 = new TUser();

        e.CustomCondition =
            u.isTenant == 0 &
            u2.Select(u2.Positions.ObjectID.Count()).Where(u2.ObjectID == u.ObjectID & u2.Positions.IsDeleted == 0) ==
            u2.Select(u2.Positions.ObjectID.Count()).Where(u2.ObjectID == u.ObjectID & u2.Positions.IsDeleted == 0 & u2.Positions.ObjectID.In(positions));

                    
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
        <ui:UIObjectPanel runat="server" ID="formMain" 
            meta:resourcekey="formMainResource1" BorderStyle="NotSet">
            <web:search runat="server" ID="panel" Caption="User" GridViewID="gridResults" 
                BaseTable="tUser" EditButtonVisible="false" SearchType="ObjectQuery"
                AutoSearchOnLoad="false" MaximumNumberOfResults="200" SearchTextBoxHint="E.g. User Name, Login Name, Email, Cellphone, Phone, Description"
                AdvancedSearchOnLoad="false" AdvancedSearchPanelID="panelAdvanced" 
                SearchTextBoxPropertyNames="ObjectName,UserBase.LoginName,UserBase.Email,UserBase.Cellphone,UserBase.Phone,Description"
                meta:resourcekey="panel" OnPopulateForm="panel_PopulateForm" OnSearch="panel_Search"></web:search>
            <div class="div-form">
                <%--<ui:UITabStrip runat="server" ID="tabSearch" 
                    meta:resourcekey="tabSearchResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Search" 
                        meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">--%>
                    <ui:UIPanel runat="server" ID="panelAdvanced" BorderStyle="NotSet">
                        <%--<ui:UIFieldTextBox runat='server' ID='UIFieldString1' PropertyName="ObjectName" Caption="User Name"
                            ToolTip="The user name as displayed on screen." Span="Half" 
                            MaxLength="255" meta:resourcekey="UIFieldString1Resource1" 
                            InternalControlWidth="95%" />
                        <ui:UIFieldTextBox runat='server' ID='UIFieldString2' PropertyName="UserBase.LoginName"
                            Caption="Login Name" ToolTip="The identifier used by the user to log on to the system."
                            Span="Half" meta:resourcekey="UIFieldString2Resource1" 
                            InternalControlWidth="95%" />
                        <br />
                        <ui:UISeparator runat="server" ID="sep1" meta:resourcekey="sep1Resource1" />--%>
                        <%--<ui:uifieldtextbox runat="server" id="textDescription" 
                            PropertyName="Description" Caption="Description" MaxLength="255" 
                            InternalControlWidth="95%" meta:resourcekey="textDescriptionResource1"></ui:uifieldtextbox>
                        <ui:UIFieldTextBox runat="server" ID="uifieldstring4" PropertyName="UserBase.Cellphone"
                            Caption="Cell Phone" Span="Half" 
                            meta:resourcekey="uifieldstring4Resource1" InternalControlWidth="95%" />
                        <ui:UIFieldTextBox runat="server" ID="uifieldstring5" PropertyName="UserBase.Email"
                            Caption="Email" Span="Half" meta:resourcekey="uifieldstring5Resource1" 
                            InternalControlWidth="95%" />
                        <ui:UIFieldTextBox runat="server" ID="uifieldstring6" PropertyName="UserBase.Fax"
                            Caption="Fax" Span="Half" meta:resourcekey="uifieldstring6Resource1" 
                            InternalControlWidth="95%" />
                        <ui:UIFieldTextBox runat="server" ID="UIFieldTextBox1" PropertyName="UserBase.Phone"
                            Caption="Phone" Span="Half" meta:resourcekey="UIFieldTextBox1Resource1" 
                            InternalControlWidth="95%" />
                        <ui:UIFieldTextBox runat="server" ID="uifieldstring7" PropertyName="UserBase.AddressCountry"
                            Caption="Country" Span="Half" MaxLength="255" 
                            meta:resourcekey="uifieldstring7Resource1" InternalControlWidth="95%" />
                        <ui:UIFieldTextBox runat="server" ID="uifieldstring8" PropertyName="UserBase.AddressState"
                            Caption="State" Span="Half" MaxLength="255" 
                            meta:resourcekey="uifieldstring8Resource1" InternalControlWidth="95%" />
                        <ui:UIFieldTextBox runat="server" ID="uifieldstring9" PropertyName="UserBase.AddressCity"
                            Caption="City" Span="Half" MaxLength="255" 
                            meta:resourcekey="uifieldstring9Resource1" InternalControlWidth="95%" />
                        <ui:UIFieldTextBox runat="server" ID="uifieldstring10" PropertyName="UserBase.Address"
                            Caption="Address" Span="Half" MaxLength="255" 
                            meta:resourcekey="uifieldstring10Resource1" InternalControlWidth="95%" />--%>
                        <ui:uifieldlistbox runat="server" id="listPositions" PropertyName="PermanentPositions.Position.ObjectID" Caption="Positions" meta:resourcekey="listPositionsResource1"></ui:uifieldlistbox>
                        <ui:uifieldlistbox runat="server" id="listRoles" PropertyName="PermanentPositions.Position.RoleID" Caption="Roles" meta:resourcekey="listRolesResource1"></ui:uifieldlistbox>
                    </ui:UIPanel>
                    <%--</ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview2" Caption="Results" 
                        meta:resourcekey="uitabview2Resource1" BorderStyle="NotSet">--%>
                        <ui:UIGridView runat="server" ID="gridResults" BorderColor="Black" KeyName="ObjectID"
                            meta:resourcekey="gridResultsResource1" Width="100%" 
                            DataKeyNames="ObjectID" GridLines="Both" RowErrorColor="" 
                            style="clear:both;">
                            <PagerSettings Mode="NumericFirstLast" />
                            <commands>
                                <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                    CommandName="DeleteObject" CommandText="Delete Selected" 
                                    ConfirmText="Are you sure you wish to delete the selected items?" 
                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource1" />
                            </commands>
                            <Columns>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" 
                                    ImageUrl="~/images/edit.gif" meta:resourceKey="UIGridViewColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewObject" 
                                    ImageUrl="~/images/view.gif" meta:resourceKey="UIGridViewColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" 
                                    ConfirmText="Are you sure you wish to delete this item?" 
                                    ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource3">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewButtonColumn>
                                <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="User Name" 
                                    meta:resourceKey="UIGridViewColumnResource4" PropertyName="ObjectName" 
                                    ResourceAssemblyName="" SortExpression="ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="UserBase.LoginName" 
                                    HeaderText="Login Name" meta:resourceKey="UIGridViewColumnResource5" 
                                    PropertyName="UserBase.LoginName" ResourceAssemblyName="" 
                                    SortExpression="UserBase.LoginName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="UserBase.Cellphone" 
                                    HeaderText="Cellphone" meta:resourceKey="UIGridViewColumnResource6" 
                                    PropertyName="UserBase.Cellphone" ResourceAssemblyName="" 
                                    SortExpression="UserBase.Cellphone">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="UserBase.Email" HeaderText="Email" 
                                    meta:resourceKey="UIGridViewColumnResource7" PropertyName="UserBase.Email" 
                                    ResourceAssemblyName="" SortExpression="UserBase.Email">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="UserBase.Fax" HeaderText="Fax" 
                                    meta:resourceKey="UIGridViewColumnResource8" PropertyName="UserBase.Fax" 
                                    ResourceAssemblyName="" SortExpression="UserBase.Fax">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="UserBase.Phone" HeaderText="Phone" 
                                    meta:resourceKey="UIGridViewColumnResource9" PropertyName="UserBase.Phone" 
                                    ResourceAssemblyName="" SortExpression="UserBase.Phone">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="AssignedPositionNames" HeaderText="Positions" 
                                    PropertyName="AssignedPositionNames" 
                                    ResourceAssemblyName="" SortExpression="AssignedPositionNames" 
                                    meta:resourcekey="UIGridViewBoundColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                            </Columns>
                            
                        </ui:UIGridView>
                        <br />
                        <asp:Label runat="server" ID="labelUserLicense" meta:resourcekey="labelUserLicenseResource1"
                            Text="Licenses: "></asp:Label>
                        <asp:Label runat="server" ID="labelUserLicenseCount" meta:resourcekey="labelUserLicenseCountResource1"></asp:Label>
                    <%--</ui:UITabView>
                </ui:UITabStrip>--%>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
