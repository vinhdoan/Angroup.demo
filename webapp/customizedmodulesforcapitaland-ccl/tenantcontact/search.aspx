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
        //labelUserLicenseCount.Text = OUserBase.GetUserLicenseText();
    }

    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        e.CustomCondition = Query.True;
        e.CustomCondition = e.CustomCondition & 
            TablesLogic.tTenantContact.TenantContactTypeID.In(OCode.GetTenantContactTypes(AppSession.User,null)) &
            TablesLogic.tTenantContact.TenantID != null;
        
    }

    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        //ddlTenantContactType.Bind(OCode.GetCodesByType("TenantContactType", null));
        ddlTenantContactType.Bind(OCode.GetTenantContactTypes(AppSession.User,null));
        
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
            BorderStyle="NotSet" meta:resourcekey="formMainResource2">
            <web:search runat="server" ID="panel" Caption="Tenant Contact" GridViewID="gridResults" 
                BaseTable="tTenantContact" EditButtonVisible="false" 
                AutoSearchOnLoad="false" MaximumNumberOfResults="300" 
                SearchTextBoxPropertyNames="ObjectName,Tenant.ObjectName,Phone,Cellphone,Email,Fax" AdvancedSearchPanelID="panelAdvanced"
                SearchTextBoxHint="Contact Name, Tenant Name, Cellphone, Phone, Email, Fax, etc..."
                OnPopulateForm="panel_PopulateForm" OnSearch="panel_Search" meta:resourcekey="panelResource1"></web:search>
            <div class="div-form">
                <%--<ui:UITabStrip runat="server" ID="tabSearch" 
                    meta:resourcekey="tabSearchResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Search" 
                        meta:resourcekey="uitabview1Resource1" 
                        BorderStyle="NotSet">--%>
                    <ui:UIPanel runat="server" ID="panelAdvanced" BorderStyle="NotSet">
                        <%--<ui:UIFieldTextBox runat='server' ID='UIFieldString1' PropertyName="ObjectName" Caption="Tenant Name" 
                            MaxLength="255" 
                            InternalControlWidth="95%" meta:resourcekey="UIFieldString1Resource2" />
                        <ui:UIFieldTextBox runat="server" ID="UIFieldTextBox1" PropertyName="Tenant.ObjectName"
                            Caption="Tenant's Name" 
                            InternalControlWidth="95%" meta:resourcekey="UIFieldTextBox1Resource2" />--%>
                        <ui:UIFieldDropDownList runat="server" ID="ddlTenantContactType" PropertyName="TenantContactTypeID" Span="Half" Caption="Tenant Contact Type" meta:resourcekey="ddlTenantContactTypeResource1" />
                        <%--<ui:UIFieldTextBox runat="server" ID="UIFieldTextBox2" PropertyName="Position"
                            Caption="Position" InternalControlWidth="95%" meta:resourcekey="UIFieldTextBox2Resource1" />
                        <ui:UIFieldTextBox runat="server" ID="UIFieldTextBox3" PropertyName="Department"
                            Caption="Department" InternalControlWidth="95%" meta:resourcekey="UIFieldTextBox3Resource1" />
                        <ui:UIFieldTextBox runat="server" ID="uifieldstring4" PropertyName="Cellphone"
                            Caption="Cell Phone" Span="Half" InternalControlWidth="95%" meta:resourcekey="uifieldstring4Resource2" />
                        <ui:UIFieldTextBox runat="server" ID="uifieldstring5" PropertyName="Email"
                            Caption="Email" Span="Half" InternalControlWidth="95%" meta:resourcekey="uifieldstring5Resource2" />
                        <ui:UIFieldTextBox runat="server" ID="uifieldstring6" PropertyName="Fax"
                            Caption="Fax" Span="Half" InternalControlWidth="95%" meta:resourcekey="uifieldstring6Resource2" />--%>
                        <ui:UISeparator runat="server" ID="AmosSeparator" Caption="Amos" meta:resourcekey="AmosSeparatorResource1" />    
                        <ui:UIFieldRadioList runat="server" Caption="From Amos" ID="rdlFromAmos" RepeatColumns="3" RepeatDirection="Vertical" meta:resourcekey="rdlFromAmosResource1" TextAlign="Right">
                            <Items>
                                <asp:ListItem meta:resourcekey="ListItemResource1">All</asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource2">Yes</asp:ListItem>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource3">No</asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:uifieldtextbox id="AmosOrgID" runat="server" 
                            caption="Amos Org ID" internalcontrolwidth="95%"
                            propertyname="AmosOrgID" Span = "Half" SearchType="Range" ValidationDataType="Integer" meta:resourcekey="AmosOrgIDResource1"/>
                        <ui:uifieldtextbox id="AmosContactID" runat="server" 
                            caption="Amos Contact ID" internalcontrolwidth="95%" 
                            propertyname="AmosContactID" Span = "Half" SearchType="Range" ValidationDataType="Integer" meta:resourcekey="AmosContactIDResource1"/>
                        <ui:uifieldtextbox id="AmosBillAddressID" runat="server" 
                            caption="Amos Bill Address ID" internalcontrolwidth="95%" 
                            propertyname="AmosBillAddressID" Span = "Half" SearchType="Range" ValidationDataType="Integer" meta:resourcekey="AmosBillAddressIDResource1"/>
                        <ui:uifieldtextbox id="AddressLine1" runat="server" 
                            caption="Address Line 1" internalcontrolwidth="95%" 
                            propertyname="AddressLine1" Span = "Half" SearchType="Range" ValidationDataType="Integer" meta:resourcekey="AddressLine1Resource1"/>
                        <ui:uifieldtextbox id="AddressLine2" runat="server" 
                            caption="Address Line 2" internalcontrolwidth="95%" 
                            propertyname="AddressLine2" Span = "Half" meta:resourcekey="AddressLine2Resource1" />
                        <ui:uifieldtextbox id="AddressLine3" runat="server" 
                            caption="Address Line 3" internalcontrolwidth="95%" 
                            propertyname="AddressLine3" Span = "Half" meta:resourcekey="AddressLine3Resource1" />
                        <ui:uifieldtextbox id="AddressLine4" runat="server" 
                            caption="Address Line 4" internalcontrolwidth="95%" 
                            propertyname="AddressLine4" Span = "Half" meta:resourcekey="AddressLine4Resource1" />
                        <ui:UIFieldDateTime id="updatedOn" runat="server" 
                            caption="Updated On" internalcontrolwidth="95%"
                            propertyname="updatedOn" Span = "Half" SearchType="Range" meta:resourcekey="updatedOnResource1" ShowDateControls="True">
                        </ui:UIFieldDateTime>
                    </ui:UIPanel>
                    <%--</ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview2" Caption="Results" 
                        meta:resourcekey="uitabview2Resource1" 
                        BorderStyle="NotSet">--%>
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
                                <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Tenant Contact Name" 
                                    meta:resourceKey="UIGridViewColumnResource4" PropertyName="ObjectName" 
                                    ResourceAssemblyName="" SortExpression="ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Tenant.ObjectName" 
                                    HeaderText="Tenant's Name"   
                                    PropertyName="Tenant.ObjectName" ResourceAssemblyName="" 
                                    SortExpression="DID" meta:resourcekey="UIGridViewBoundColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="TenantContactType.ObjectName" HeaderText="Tenant Contact Type" 
                                    PropertyName="TenantContactType.ObjectName" 
                                    ResourceAssemblyName="" SortExpression="TenantContactType.ObjectName" meta:resourcekey="UIGridViewBoundColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Position" 
                                    HeaderText="Position"  
                                    PropertyName="Position" ResourceAssemblyName="" 
                                    SortExpression="DID" meta:resourcekey="UIGridViewBoundColumnResource3">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                  <cc1:UIGridViewBoundColumn DataField="Department" 
                                    HeaderText="Department"  
                                    PropertyName="Department" ResourceAssemblyName="" 
                                    SortExpression="DID" meta:resourcekey="UIGridViewBoundColumnResource4">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                 <cc1:UIGridViewBoundColumn DataField="DID" 
                                    HeaderText="DID"  
                                    PropertyName="DID" ResourceAssemblyName="" 
                                    SortExpression="DID" meta:resourcekey="UIGridViewBoundColumnResource5">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Cellphone" 
                                    HeaderText="Cellphone" meta:resourceKey="UIGridViewColumnResource6" 
                                    PropertyName="Cellphone" ResourceAssemblyName="" 
                                    SortExpression="Cellphone">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Email" HeaderText="Email" 
                                    meta:resourceKey="UIGridViewColumnResource7" PropertyName="Email" 
                                    ResourceAssemblyName="" SortExpression="Email">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Fax" HeaderText="Fax" 
                                    meta:resourceKey="UIGridViewColumnResource8" PropertyName="Fax" 
                                    ResourceAssemblyName="" SortExpression="Fax">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ModifiedDateTime" HeaderText="Last modified date time" 
                                    PropertyName="ModifiedDateTime" DataFormatString="{0:dd-MMM-yyyy HH:mm:ss}"
                                    ResourceAssemblyName="" SortExpression="ModifiedDateTime">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                            </Columns>
                            
                        </ui:UIGridView>
                        <%--<br />
                        <asp:Label runat="server" ID="labelUserLicense" meta:resourcekey="labelUserLicenseResource1"
                            Text="Licenses: "></asp:Label>
                        <asp:Label runat="server" ID="labelUserLicenseCount" meta:resourcekey="labelUserLicenseCountResource1"></asp:Label>
                    </ui:UITabView>
                </ui:UITabStrip>--%>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
