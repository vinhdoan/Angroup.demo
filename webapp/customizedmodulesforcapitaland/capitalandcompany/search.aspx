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
    }

    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {

    }

    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        
        
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
        <ui:UIObjectPanel runat="server" ID="formMain" BorderStyle="NotSet" 
            meta:resourcekey="formMainResource1">
            <web:search runat="server" ID="panel" Caption="Company" GridViewID="gridResults" 
                BaseTable="tCapitalandCompany" EditButtonVisible="false" 
                meta:resourcekey="panelResource1" OnPopulateForm="panel_PopulateForm" OnSearch="panel_Search"></web:search>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabSearch" 
                    meta:resourcekey="tabSearchResource1" BorderStyle="NotSet">
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Search" 
                        meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">
                        <ui:UIFieldTextBox runat='server' ID='UIFieldString1' PropertyName="ObjectName" Caption="Company Name"
                            ToolTip="The company name as displayed on screen." Span="Half" 
                            MaxLength="255" InternalControlWidth="95%" 
                            meta:resourcekey="UIFieldString1Resource1" />
                        <br />
                        <ui:UISeparator runat="server" ID="sep1" meta:resourcekey="sep1Resource1" />
                        <ui:UIFieldTextBox runat='server' ID='UIFieldString2' PropertyName="Address" 
                            Caption="Address" InternalControlWidth="95%" 
                            meta:resourcekey="UIFieldString2Resource1" />
                        <ui:UIFieldTextBox runat="server" ID="uifieldstring4" PropertyName="Country"
                            Caption="Country" Span="Half" InternalControlWidth="95%" 
                            meta:resourcekey="uifieldstring4Resource1" />
                        <ui:UIFieldTextBox runat="server" ID="uifieldstring5" PropertyName="PostalCode" 
                            Caption="Postal Code" Span="Half" InternalControlWidth="95%" 
                            meta:resourcekey="uifieldstring5Resource1" />
                        <ui:UIFieldTextBox runat="server" ID="uifieldstring6" PropertyName="PhoneNo"
                            Caption="Phone No." Span="Half" InternalControlWidth="95%" 
                            meta:resourcekey="uifieldstring6Resource1" />
                        <ui:UIFieldTextBox runat="server" ID="UIFieldTextBox1" PropertyName="FaxNo"
                            Caption="Fax" Span="Half" InternalControlWidth="95%" 
                            meta:resourcekey="UIFieldTextBox1Resource1" />
                        <ui:UIFieldTextBox runat="server" ID="uifieldstring7" PropertyName="ContactPerson"
                            Caption="Contact Person" Span="Half" MaxLength="255" 
                            InternalControlWidth="95%" meta:resourcekey="uifieldstring7Resource1" />
                         <ui:UIFieldTextBox runat="server" ID="UIFieldTextBox2" PropertyName="RegNo"
                            Caption="Regn No." Span="Half" InternalControlWidth="95%" 
                            meta:resourcekey="UIFieldTextBox2Resource1" />
                        <ui:UIFieldTextBox runat="server" ID="uifieldstring8" PropertyName="PaymentName"
                            Caption="Payment Name" Span="Half" MaxLength="255" 
                            InternalControlWidth="95%" meta:resourcekey="uifieldstring8Resource1" />
                        
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview2" Caption="Results" 
                        meta:resourcekey="uitabview2Resource1" BorderStyle="NotSet">
                        <ui:UIGridView runat="server" ID="gridResults" BorderColor="Black" KeyName="ObjectID"
                            meta:resourcekey="gridResultsResource1" Width="100%" 
                            DataKeyNames="ObjectID" GridLines="Both" RowErrorColor="" 
                            style="clear:both;" ImageRowErrorUrl="">
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
                                <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Company Name" 
                                    meta:resourceKey="UIGridViewColumnResource4" PropertyName="ObjectName" 
                                    ResourceAssemblyName="" SortExpression="ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Description" HeaderText="Description" 
                                    PropertyName="Description" 
                                    ResourceAssemblyName="" SortExpression="Description">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="ContactPerson" 
                                    HeaderText="Contact Person" meta:resourceKey="UIGridViewColumnResource5" 
                                    PropertyName="ContactPerson" ResourceAssemblyName="" 
                                    SortExpression="ContactPerson">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="PaymentName" HeaderText="Payment Name" 
                                    meta:resourceKey="UIGridViewColumnResource6" PropertyName="PaymentName" 
                                    ResourceAssemblyName="" SortExpression="PaymentName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Address" HeaderText="Address" 
                                    PropertyName="Address" 
                                    ResourceAssemblyName="" SortExpression="Address" meta:resourcekey="UIGridViewBoundColumnResource4">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="FaxNo" HeaderText="Fax" 
                                    meta:resourcekey="UIGridViewBoundColumnResource2" PropertyName="FaxNo" 
                                    ResourceAssemblyName="" SortExpression="FaxNo">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="PhoneNo" HeaderText="Phone" 
                                    meta:resourcekey="UIGridViewBoundColumnResource3" PropertyName="PhoneNo" 
                                    ResourceAssemblyName="" SortExpression="PhoneNo">
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
