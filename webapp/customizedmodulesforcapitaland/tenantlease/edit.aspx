<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectpanel.ascx" TagPrefix="web" TagName="object" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">
    /// <summary>
    /// Populates the form controls.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="obj"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OTenantLease tenantLease = (OTenantLease)panel.SessionObject;
        treeLocation.PopulateTree();
        ddlStatus.Bind(OTenantLease.dtStatusList(), "Status", "Abr");
        ddlTenant.Bind(TablesLogic.tUser.LoadList(TablesLogic.tUser.isTenant==1));
        panel.ObjectPanel.BindObjectToControls(tenantLease);
        if (tenantLease.FromAmos == 1)
            tabDetails.Enabled = false;
    }
    /// <summary>
    /// Hides/shows controls
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
   
        
    }
    
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OTenantLease tenantLease = (OTenantLease)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(tenantLease);
            tenantLease.Save();
            c.Commit();
        }
    }



    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        OTenantLease tenantLease = (OTenantLease)panel.SessionObject;
        return new LocationTreePopulaterForCapitaland(tenantLease.LocationID, false, true,
            Security.Decrypt(Request["TYPE"]), false, false);
    }

    protected void gridTenantLeaseHOTO_Action(object sender, string commandName, List<object> dataKeys)
    {
        OTenantLease tenantLease = (OTenantLease)panel.SessionObject;
        panelTenantLeaseHOTO.BindControlsToObject(tenantLease);
        if (commandName == "AddRow")
        {
            OTenantLeaseHOTO hoto = TablesLogic.tTenantLeaseHOTO.Create();
            tenantLease.TenantLeaseHOTOs.Add(hoto);
            panelTenantLeaseHOTO.BindObjectToControls(tenantLease);
        }
    }


    List<OCode> standardHandoverItems = null;
    Hashtable standardHandoverItemsHash = null;

    protected void gridTenantLeaseHOTO_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            Guid id = (Guid)gridTenantLeaseHOTO.DataKeys[e.Row.DataItemIndex][0];
            
            // 2010.05.03 
            // Loading a record per line will be too slow 
            // OTenantLeaseHOTO hoto = TablesLogic.tTenantLeaseHOTO.Load(id);

            Guid? standardHandoverItemID = null;
            if (e.Row.Cells[2].Text != "" && e.Row.Cells[2].Text != "&nbsp;")
                standardHandoverItemID = new Guid(e.Row.Cells[2].Text);

            // 2010.05.03
            // Loads up the list of non-deleted standard handover items,
            // just once, so that we don't have to reload this for
            // every line item.
            //
            if (standardHandoverItems == null)
            {
                standardHandoverItems = OCode.GetCodesByType("StandardHandoverItem", null);
                standardHandoverItemsHash = new Hashtable();
                foreach (OCode code in standardHandoverItems)
                    standardHandoverItemsHash[code.ObjectID.Value] = 1;
            }
            
            UIFieldDropDownList standardItem = (UIFieldDropDownList)e.Row.FindControl("ddlStandardHandOverItem");

            if (standardHandoverItemID == null || standardHandoverItemsHash[standardHandoverItemID] != null)
                standardItem.Bind(standardHandoverItems);
            else
                // 2010.05.03
                // We only reload a new list of standard handover items,
                // if the current selected value does not already exist
                // in the non-deleted list we loaded.
                //
                standardItem.Bind(OCode.GetCodesByType("StandardHandoverItem", standardHandoverItemID));
        }

        if (e.Row.RowType == DataControlRowType.DataRow ||
            e.Row.RowType == DataControlRowType.Header ||
            e.Row.RowType == DataControlRowType.Footer)
        {
            e.Row.Cells[2].Visible = false;
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
        <web:object runat="server" ID="panel" Caption="Tenant Lease" BaseTable="tTenantLease"
            OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1">
        </web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1" BorderStyle="NotSet">
                <ui:UITabView runat="server" ID="tabDetails" Caption="Details" meta:resourcekey="tabDetailsResource1" BorderStyle="NotSet">
                    <web:base runat="server" ID="objectBase" ObjectNumberVisible="false" ObjectNameVisible="false"
                        meta:resourcekey="objectBaseResource1"></web:base>
                    <ui:uifieldtreelist id="treeLocation" runat="server" caption="Location" 
                            propertyname="LocationID" showcheckboxes="None" treevaluemode="SelectedNode" 
                            validaterequiredfield="True" OnAcquireTreePopulater="treeLocation_AcquireTreePopulater" meta:resourcekey="treeLocationResource1">
                        </ui:uifieldtreelist>
                        <ui:UIFieldSearchableDropDownList runat="server" ID="ddlTenant" PropertyName="TenantID" Caption="Tenant" meta:resourcekey="ddlTenantResource1" SearchInterval="300"></ui:UIFieldSearchableDropDownList>
                        <ui:UIFieldLabel runat="server" ID="ShopName" PropertyName="ShopName" Caption="Shop Name"></ui:UIFieldLabel>
                        <ui:UIFieldDateTime runat="server" ID="StartDate" Caption="Start Date" PropertyName="LeaseStartDate" Span="Half" meta:resourcekey="StartDateResource1" ShowDateControls="True"></ui:UIFieldDateTime>
                        <ui:UIFieldDateTime runat="server" ID="EndDate" Caption="End Date" PropertyName="LeaseEndDate"  Span="Half" meta:resourcekey="EndDateResource1" ShowDateControls="True"></ui:UIFieldDateTime>
                        <ui:UIFieldDropDownList runat="server" ID="ddlStatus" Caption="Status" PropertyName="LeaseStatus" meta:resourcekey="ddlStatusResource1"></ui:UIFieldDropDownList>
                        
                        <ui:uifieldtextbox id="LeaseStatusDate" runat="server" 
                        caption="Lease Status date" internalcontrolwidth="95%" DataFormatString="{0:dd-MMM-yyyy}"
                        propertyname="LeaseStatusDate" Span = "Half" Enabled="False" meta:resourcekey="LeaseStatusDateResource1"/>
                        <ui:UIFieldLabel id="LeaseAmosOrgID" runat="server" 
                        caption="Amos Org ID" internalcontrolwidth="95%" 
                        propertyname="AmosOrgID" Span = "Half" Enabled="False" DataFormatString="" meta:resourcekey="LeaseAmosOrgIDResource1"/>
                        <ui:UIFieldLabel id="AmosAssetID" runat="server" 
                        caption="Amos Asset ID" internalcontrolwidth="95%" 
                        propertyname="AmosAssetID" Span = "Half" Enabled="False" DataFormatString="" meta:resourcekey="AmosAssetIDResource1"/>
                        <ui:UIFieldLabel id="AmosSuiteID" runat="server" 
                        caption="Amos Suite ID" internalcontrolwidth="95%" 
                        propertyname="AmosSuiteID" Span = "Half" Enabled="False" DataFormatString="" meta:resourcekey="AmosSuiteIDResource1"/>
                        <ui:UIFieldLabel id="AmosLeaseID" runat="server" 
                        caption="Amos Lease ID" internalcontrolwidth="95%" 
                        propertyname="AmosLeaseID" Span = "Half" Enabled="False" DataFormatString="" meta:resourcekey="AmosLeaseIDResource1"/>
                        <ui:UIFieldLabel id="leaseUpdatedOn" runat="server" 
                        caption="Updated On" internalcontrolwidth="95%" DataFormatString="{0:dd-MMM-yyyy}"
                        propertyname="updatedOn" Span = "Half" Enabled="False" meta:resourcekey="leaseUpdatedOnResource1"/>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabHandingOver" Caption="Handing Over/Taking Over" BorderStyle="NotSet" meta:resourcekey="tabHandingOverResource1">
                <ui:UIFieldDateTime runat="server" ID="HandoverDateTime" PropertyName = "HandoverDateTime" Caption="Handover DateTime" meta:resourcekey="HandoverDateTimeResource1" ShowDateControls="True"></ui:UIFieldDateTime>
                <ui:UIFieldTextBox runat="server" ID="txtHandoverRemarks" PropertyName="HandoverRemarks" Caption="Handover Remarks" InternalControlWidth="95%" meta:resourcekey="txtHandoverRemarksResource1"></ui:UIFieldTextBox>
                <ui:UIFieldDateTime runat="server" ID="TakeoverDateTime" PropertyName = "TakeoverDateTime" Caption="Takeover DateTime" meta:resourcekey="TakeoverDateTimeResource1" ShowDateControls="True"></ui:UIFieldDateTime>
                <ui:UIFieldTextBox runat="server" ID="txtTakeoverRemarks" PropertyName="TakeoverRemarks" Caption="Takeover Remarks" InternalControlWidth="95%" meta:resourcekey="txtTakeoverRemarksResource1"></ui:UIFieldTextBox>
                
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabTenantLeaseHOTO" Caption="Tenant Lease HOTO" BorderStyle="NotSet" meta:resourcekey="tabTenantLeaseHOTOResource1">
                <ui:UIPanel runat="server" ID="panelTenantLeaseHOTO" BorderStyle="NotSet" meta:resourcekey="panelTenantLeaseHOTOResource1">
                    <ui:UIGridView runat="server" Caption="Tenant Lease HOTO" ID="gridTenantLeaseHOTO" OnAction="gridTenantLeaseHOTO_Action" BindObjectsToRows="True" DataKeyNames="ObjectID"
                     PropertyName="TenantLeaseHOTOs" OnRowDataBound="gridTenantLeaseHOTO_RowDataBound" GridLines="Both" ImageRowErrorUrl="" meta:resourcekey="gridTenantLeaseHOTOResource1" RowErrorColor="" style="clear:both;">
                        <PagerSettings Mode="NumericFirstLast" />
                        <commands>
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="AddRow" CommandText="Add" ImageUrl="~/images/add.gif" meta:resourcekey="UIGridViewCommandResource1" />
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject" CommandText="Remove Selected" ConfirmText="Are you sure you wish to remove the selected items?" ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource2" />
                        </commands>
                        <Columns>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" CommandText="Remove" ConfirmText="Are you sure you wish to remove this item?" ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewButtonColumnResource1">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewBoundColumn DataField="StandardHandoverItemID" meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="StandardHandoverItemID" ResourceAssemblyName="" SortExpression="StandardHandoverItemID">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewTemplateColumn HeaderText="Standard Handover Item" meta:resourcekey="UIGridViewTemplateColumnResource1">
                                <ItemTemplate>
                                    <cc1:UIFieldDropDownList ID="ddlStandardHandOverItem" runat="server" FieldLayout="Flow" InternalControlWidth="250px" meta:resourcekey="ddlStandardHandOverItemResource1" PropertyName="StandardHandoverItemID" ShowCaption="False" ValidateRequiredField="True">
                                    </cc1:UIFieldDropDownList>
                                </ItemTemplate>
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn HeaderText="Remarks" meta:resourcekey="UIGridViewTemplateColumnResource2">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="txtRemarks" runat="server" FieldLayout="Flow" InternalControlWidth="350px" meta:resourcekey="txtRemarksResource1" PropertyName="Remarks" ShowCaption="False">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn HeaderText="Quantity Handed Over" meta:resourcekey="UIGridViewTemplateColumnResource3">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="txtQuantityHandedOver" runat="server" FieldLayout="Flow" InternalControlWidth="100px" meta:resourcekey="txtQuantityHandedOverResource1" PropertyName="QuantityHandedOver" ShowCaption="False" ValidateRequiredField="True">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                            <cc1:UIGridViewTemplateColumn HeaderText="Quantity Taken Over" meta:resourcekey="UIGridViewTemplateColumnResource4">
                                <ItemTemplate>
                                    <cc1:UIFieldTextBox ID="txtQuantityTakenOver" runat="server" FieldLayout="Flow" InternalControlWidth="100px" meta:resourcekey="txtQuantityTakenOverResource1" PropertyName="QuantityTakenOver" ShowCaption="False">
                                    </cc1:UIFieldTextBox>
                                </ItemTemplate>
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewTemplateColumn>
                        </Columns>
                    </ui:UIGridView>
                     <ui:uiobjectpanel runat="server" id="objectpanelTenantLease" BorderStyle="NotSet" meta:resourcekey="objectpanelTenantLeaseResource1">
                        <web:subpanel runat="server" id="subpanelTenantLeaseHoTO" GridViewID="gridTenantLeaseHOTO" />
                     </ui:uiobjectpanel>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabMemo" Caption="Memo" meta:resourcekey="tabMemoResource1" BorderStyle="NotSet">
                    <web:memo ID="Memo1" runat="server"></web:memo>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabAttachments" Caption="Attachments" meta:resourcekey="tabAttachmentsResource1" BorderStyle="NotSet">
                    <web:attachments runat="server" ID="attachments"></web:attachments>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
