<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" culture="auto" meta:resourcekey="PageResource1" uiculture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="LogicLayer" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">
    /// <summary>
    /// Populates the form,
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
        
        treeLocation.PopulateTree();
        treeEquipment.PopulateTree();
        dropApprovalHierarchy.Bind(OApprovalHierarchy.GetAllApprovalHierarchies());
        listTransactionTypes.Bind(OCode.GetCodesByTypeOrderByParentPathAsDataTable("PurchaseType"), "Path", "ObjectID");
    }


    /// <summary>
    /// Constructs and returns a location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        return new LocationTreePopulaterForCapitaland(null, true, true, 
            Security.Decrypt(Request["TYPE"]),false,false);
    }


    /// <summary>
    /// Constructs and returns a equipment tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeEquipment_AcquireTreePopulater(object sender)
    {
        return new EquipmentTreePopulater(null, true, true, Security.Decrypt(Request["TYPE"]));
    }




    /// <summary>
    /// Attaches custom conditions.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        e.CustomCondition = Query.True;
        if (treeEquipment.SelectedValue != "")
        {
            OEquipment oEquipment = TablesLogic.tEquipment[new Guid(treeEquipment.SelectedValue)];
            if (oEquipment != null)
                e.CustomCondition = e.CustomCondition & TablesLogic.tApprovalProcess.Equipment.HierarchyPath.Like(oEquipment.HierarchyPath + "%");

        }
        if (treeLocation.SelectedValue != "")
        {
            OLocation location = TablesLogic.tLocation[new Guid(treeLocation.SelectedValue)];
            if (location != null)
                e.CustomCondition = e.CustomCondition & TablesLogic.tApprovalProcess.Location.HierarchyPath.Like(location.HierarchyPath + "%");
        }
        if (treeLocation.SelectedValue == "" && treeEquipment.SelectedValue == "")
        {
            ExpressionCondition locCondition = Query.False;
            ExpressionCondition eqptCondition = Query.False;
            foreach (OPosition position in AppSession.User.GetPositionsByObjectType(Security.Decrypt(Request["TYPE"])))
            {
                foreach (OLocation location in position.LocationAccess)
                    locCondition = locCondition | TablesLogic.tApprovalProcess.Location.HierarchyPath.Like(location.HierarchyPath + "%");
                foreach (OEquipment equipment in position.EquipmentAccess)
                    eqptCondition = eqptCondition | TablesLogic.tApprovalProcess.Equipment.HierarchyPath.Like(equipment.HierarchyPath + "%");
            }
            e.CustomCondition = locCondition & eqptCondition;
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
    <ui:UIObjectPanel runat="server" ID="panelMain" 
        BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
        <web:search runat="server" ID="panel" Caption="Approval Process" GridViewID="gridResults"
            BaseTable="tApprovalProcess" EditButtonVisible="false" OnSearch="panel_Search"
            OnPopulateForm="panel_PopulateForm" SearchType="ObjectQuery" meta:resourcekey="panelResource1"></web:search>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabSearch" 
                BorderStyle="NotSet" meta:resourcekey="tabSearchResource1">
                <ui:UITabView runat="server" ID="uitabview3" Caption="Search" 
                    BorderStyle="NotSet" meta:resourcekey="uitabview3Resource1">
                    <ui:UIFieldTextBox runat="server" ID="textDescription" Caption="Description" PropertyName="Description"
                        MaxLength="255" InternalControlWidth="95%" 
                        meta:resourcekey="textDescriptionResource1">
                    </ui:UIFieldTextBox>
                    <ui:UIFieldDropDownList runat='server' ID="dropObjectTypeName" PropertyName="ObjectTypeName"
                        Caption="Object Type Name" meta:resourcekey="dropObjectTypeNameResource1">
                    </ui:UIFieldDropDownList>
                    <ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location" OnAcquireTreePopulater="treeLocation_AcquireTreePopulater"
                        meta:resourcekey="treeLocationResource1" ShowCheckBoxes="None" 
                        TreeValueMode="SelectedNode">
                    </ui:UIFieldTreeList>
                    <ui:UIFieldTreeList runat="server" ID="treeEquipment" Caption="Equipment" OnAcquireTreePopulater="treeEquipment_AcquireTreePopulater"
                        meta:resourcekey="treeEquipmentResource1" ShowCheckBoxes="None" 
                        TreeValueMode="SelectedNode">
                    </ui:UIFieldTreeList>
                    <ui:uifieldlistbox runat="server" id="listTransactionTypes" Caption="Transaction Types" PropertyName="TransactionTypes.ObjectID" meta:resourcekey="listTransactionTypesResource1"></ui:uifieldlistbox>
                    <ui:UIFieldRadioList runat="server" ID="radioModeOfForwarding" Caption="Mode of Forwarding"
                        PropertyName="ModeOfForwarding" 
                        meta:resourcekey="radioModeOfForwardingResource1" TextAlign="Right" >
                        <Items>
                            <asp:ListItem meta:resourcekey="ListItemResource1" Text="Any"></asp:ListItem>
                            <asp:ListItem Value="0" meta:resourcekey="ListItemResource2" Text="None: No approval is required."></asp:ListItem>
                            <asp:ListItem Value="1" meta:resourcekey="ListItemResource3" Text="Direct: The object will be routed immediately to the a user/role authorized to approve the object."></asp:ListItem>
                            <asp:ListItem Value="2" meta:resourcekey="ListItemResource4" Text="Hierarchical: The object will be first routed to first user/role in the approval hierarchy, until it reaches a user/role authorized to approve the object."></asp:ListItem>
                            <asp:ListItem Value="4" meta:resourcekey="ListItemResource6" 
                                Text="Hierarchical with Skipping: Same as Hierarchical, except when a rejected task is re-submitted for approval, it starts at the same level that rejected the task." ></asp:ListItem>
                            <asp:ListItem Value="3" meta:resourcekey="ListItemResource5" Text="All: The object will be routed to all users/roles from the first to the one authorized to approve the object."></asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>
                    <ui:UIFieldDropDownList runat="server" ID="dropApprovalHierarchy" PropertyName="ApprovalHierarchyID"
                        Caption="Approval Hierarchy" 
                        meta:resourcekey="dropApprovalHierarchyResource1">
                    </ui:UIFieldDropDownList>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview4" Caption="Results" 
                    BorderStyle="NotSet" meta:resourcekey="uitabview4Resource1">
                    <ui:UIGridView runat="server" ID="gridResults" SortExpression="ObjectTypeName" 
                        DataKeyNames="ObjectID" GridLines="Both" 
                        meta:resourcekey="gridResultsResource1" RowErrorColor="" 
                        style="clear:both;" ImageRowErrorUrl="">
                        <PagerSettings Mode="NumericFirstLast" />
                        <commands>
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                CommandName="DeleteObject" CommandText="Deleted Selected" 
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
                            <cc1:UIGridViewBoundColumn DataField="ObjectTypeName" HeaderText="Object Type" 
                                meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="ObjectTypeName" 
                                ResourceAssemblyName="" ResourceName="Resources.Objects" 
                                SortExpression="ObjectTypeName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Description" HeaderText="Description" 
                                meta:resourcekey="UIGridViewBoundColumnResource2" PropertyName="Description" 
                                ResourceAssemblyName="" SortExpression="Description">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Location.Path" HeaderText="Location" 
                                meta:resourcekey="UIGridViewBoundColumnResource3" PropertyName="Location.Path" 
                                ResourceAssemblyName="" SortExpression="Location.Path">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="Equipment.Path" HeaderText="Equipment" 
                                meta:resourcekey="UIGridViewBoundColumnResource4" PropertyName="Equipment.Path" 
                                ResourceAssemblyName="" SortExpression="Equipment.Path">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="ModeOfForwardingText" 
                                HeaderText="Mode of Forwarding" 
                                meta:resourcekey="UIGridViewBoundColumnResource5" 
                                PropertyName="ModeOfForwardingText" ResourceAssemblyName="" 
                                SortExpression="ModeOfForwardingText">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                            <cc1:UIGridViewBoundColumn DataField="ApprovalHierarchy.ObjectName" 
                                HeaderText="Approval Hierarchy" 
                                meta:resourcekey="UIGridViewBoundColumnResource6" 
                                PropertyName="ApprovalHierarchy.ObjectName" ResourceAssemblyName="" 
                                SortExpression="ApprovalHierarchy.ObjectName">
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
