<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

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
        listPositions.Bind(OPosition.GetAllPositions());
        listRoles.Bind(ORole.GetAllRoles(), "RoleName", "ObjectID");
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
        <ui:UIObjectPanel runat="server" ID="formMain">
            <web:search runat="server" ID="panel" Caption="User" GridViewID="gridResults" 
                BaseTable="tUser" EditButtonVisible="false" 
                meta:resourcekey="panel" OnPopulateForm="panel_PopulateForm"></web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1">
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Search" 
                        meta:resourcekey="uitabview1Resource1">
                        <ui:UIFieldTextBox runat='server' ID='UIFieldString1' PropertyName="ObjectName" Caption="User Name"
                            ToolTip="The user name as displayed on screen." Span="Half" MaxLength="255" meta:resourcekey="UIFieldString1Resource1" />
                        <ui:UIFieldTextBox runat='server' ID='UIFieldString2' PropertyName="UserBase.LoginName"
                            Caption="Login Name" ToolTip="The identifier used by the user to log on to the system."
                            Span="Half" meta:resourcekey="UIFieldString2Resource1" />
                        <br />
                        <ui:UISeparator runat="server" ID="sep1" meta:resourcekey="sep1Resource1" />
                        <ui:UIFieldTextBox runat="server" ID="uifieldstring4" PropertyName="UserBase.Cellphone"
                            Caption="Cell Phone" Span="Half" meta:resourcekey="uifieldstring4Resource1" />
                        <ui:UIFieldTextBox runat="server" ID="uifieldstring5" PropertyName="UserBase.Email"
                            Caption="Email" Span="Half" meta:resourcekey="uifieldstring5Resource1" />
                        <ui:UIFieldTextBox runat="server" ID="uifieldstring6" PropertyName="UserBase.Fax"
                            Caption="Fax" Span="Half" meta:resourcekey="uifieldstring6Resource1" />
                        <ui:UIFieldTextBox runat="server" ID="UIFieldTextBox1" PropertyName="UserBase.Phone"
                            Caption="Phone" Span="Half" meta:resourcekey="UIFieldTextBox1Resource1" />
                        <ui:UIFieldTextBox runat="server" ID="uifieldstring7" PropertyName="UserBase.AddressCountry"
                            Caption="Country" Span="Half" MaxLength="255" meta:resourcekey="uifieldstring7Resource1" />
                        <ui:UIFieldTextBox runat="server" ID="uifieldstring8" PropertyName="UserBase.AddressState"
                            Caption="State" Span="Half" MaxLength="255" meta:resourcekey="uifieldstring8Resource1" />
                        <ui:UIFieldTextBox runat="server" ID="uifieldstring9" PropertyName="UserBase.AddressCity"
                            Caption="City" Span="Half" MaxLength="255" meta:resourcekey="uifieldstring9Resource1" />
                        <ui:UIFieldTextBox runat="server" ID="uifieldstring10" PropertyName="UserBase.Address"
                            Caption="Address" Span="Half" MaxLength="255" meta:resourcekey="uifieldstring10Resource1" />
                        <ui:uifieldlistbox runat="server" id="listPositions" PropertyName="Positions.ObjectID" Caption="Positions"></ui:uifieldlistbox>
                        <ui:uifieldlistbox runat="server" id="listRoles" PropertyName="Positions.Role.ObjectID" Caption="Roles"></ui:uifieldlistbox>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview2" Caption="Results" 
                        meta:resourcekey="uitabview2Resource1">
                        <ui:UIGridView runat="server" ID="gridResults" BorderColor="Black" KeyName="ObjectID"
                            meta:resourcekey="gridResultsResource1" Width="100%">
                            <Columns>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif"
                                    CommandName="EditObject" HeaderText="" meta:resourcekey="UIGridViewColumnResource1">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/view.gif" 
                                    CommandName="ViewObject" HeaderText="" meta:resourcekey="UIGridViewColumnResource2">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" 
                                    CommandName="DeleteObject" HeaderText="" ConfirmText="Are you sure you wish to delete this item?"
                                    meta:resourcekey="UIGridViewColumnResource3">
                                </ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn PropertyName="ObjectName" HeaderText="User Name" meta:resourcekey="UIGridViewColumnResource4">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="UserBase.LoginName" HeaderText="Login Name"
                                    meta:resourcekey="UIGridViewColumnResource5">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="UserBase.Cellphone" HeaderText="Cellphone"
                                    meta:resourcekey="UIGridViewColumnResource6">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="UserBase.Email" HeaderText="Email" meta:resourcekey="UIGridViewColumnResource7">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="UserBase.Fax" HeaderText="Fax" meta:resourcekey="UIGridViewColumnResource8">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="UserBase.Phone" HeaderText="Phone" meta:resourcekey="UIGridViewColumnResource9">
                                </ui:UIGridViewBoundColumn>
                            </Columns>
                            <Commands>
                                <ui:UIGridViewCommand CommandText="Delete Selected" ConfirmText="Are you sure you wish to delete the selected items?"
                                    ImageUrl="~/images/delete.gif" CommandName="DeleteObject" meta:resourcekey="UIGridViewCommandResource1">
                                </ui:UIGridViewCommand>
                            </Commands>
                            
                        </ui:UIGridView>
                        <br />
                        <asp:Label runat="server" ID="labelUserLicense" meta:resourcekey="labelUserLicenseResource1"
                            Text="Licenses: "></asp:Label>
                        <asp:Label runat="server" ID="labelUserLicenseCount" meta:resourcekey="labelUserLicenseCountResource1"></asp:Label>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
