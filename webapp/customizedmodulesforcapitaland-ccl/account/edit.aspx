<%@ Page Language="C#" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.Common" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Register Assembly="Anacle.UIFramework" Namespace="Anacle.UIFramework" TagPrefix="cc1" %>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <meta http-equiv="pragma" content="no-cache" />
</head>

<script runat="server">

    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OAccount account = panel.SessionObject as OAccount;
        if (!account.IsNew)
            this.radioType.Enabled = false;
        listPurchaseType.Bind(OCode.GetTableCodesWithPath("PurchaseType"), "Path", "ObjectID");
        dropAccountType.Bind(OAccountType.GetAllAccountTypes(), "ObjectName", "ObjectID");
        treeParentID.PopulateTree();
        treeSubCategoryID.PopulateTree();
    }


    /// <summary>
    /// Populates the budget category tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeParentID_AcquireTreePopulater(object sender)
    {
        OAccount account = panel.SessionObject as OAccount;
        if (account.ParentID != null)
            return new AccountTreePopulater(account.ParentID, true, false);
        else
            return new AccountTreePopulater(panel.SessionObject.ParentID, true, false);
    }


    /// <summary>
    /// Populates the budget sub category tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeSubCategoryID_AcquireTreePopulater(object sender)
    {
        return new AccountTreePopulater(panel.SessionObject.ParentID, true, true);
    }
    
    
    /// <summary>
    /// Occurs when user mades selection in the type drop down list.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void radioType_SelectedIndexChanged(object sender, EventArgs e)
    {

    }


    /// <summary>
    /// Hides/shows elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        panelLineItem.Visible = radioType.SelectedValue == "1";
        listPurchaseType.Visible = rdlIsAllTos.SelectedValue == "0";
        TransactionPanel.Visible = radioType.SelectedValue != "0";
    }

    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        OAccount account = panel.SessionObject as OAccount;

        // Validate
        //
        if (account.IsDuplicateName())
            this.objectBase.ObjectName.ErrorMessage = Resources.Errors.General_NameDuplicate;
        if (account.IsCyclicalReference())
            treeParentID.ErrorMessage = Resources.Errors.Code_CyclicalReference;

        if (!panel.ObjectPanel.IsValid)
            return;

        account.Save();
    }





    protected void rdlIsAllTos_SelectedIndexChanged(object sender, EventArgs e)
    {

    }
</script>

<body>
    <form id="form1" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
        <web:object runat="server" ID="panel" Caption="Account" BaseTable="tAccount" AutomaticBindingAndSaving="true"
            OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave"
            meta:resourcekey="panelResource1"></web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1"
                BorderStyle="NotSet">
                <!--Tab Detail-->
                <ui:UITabView runat="server" ID="tabDetails" Caption="Details" Height="267px" BorderStyle="NotSet"
                    meta:resourcekey="tabDetailsResource1">
                    <web:base runat="server" ID="objectBase" ObjectNameVisible="true" ObjectNameValidateRequiredField="true"
                        ObjectNumberVisible="false" meta:resourcekey="objectBaseResource1"></web:base>
                    <ui:UIFieldTreeList ID="treeParentID" runat="server" Caption="Belongs Under" OnAcquireTreePopulater="treeParentID_AcquireTreePopulater"
                        PropertyName="ParentID" meta:resourcekey="treeParentIDResource1" ShowCheckBoxes="None"
                        TreeValueMode="SelectedNode">
                    </ui:UIFieldTreeList>
                    <ui:UIFieldRadioList ID="radioType" runat="server" Caption="Category/Line Item" RepeatDirection="Vertical"
                        PropertyName="Type" ValidateRequiredField="True" OnSelectedIndexChanged="radioType_SelectedIndexChanged"
                        meta:resourcekey="radioTypeResource1" TextAlign="Right">
                        <Items>
                            <asp:ListItem Value="0" meta:resourcekey="ListItemResource1" Text="Category"></asp:ListItem>
                            <asp:ListItem Value="1" meta:resourcekey="ListItemResource2" Text="Line Item"></asp:ListItem>
                        </Items>
                    </ui:UIFieldRadioList>                    
                    <ui:UIPanel runat="server" ID="panelLineItem" BorderStyle="NotSet" meta:resourcekey="panelLineItemResource1">
                        <ui:UIFieldTextBox ID="txtReallocationGroupName" runat="server" Caption="Group Name"
                            PropertyName="ReallocationGroupName"></ui:UIFieldTextBox>
                            <ui:UIFieldTreeList ID="treeSubCategoryID" runat="server" Caption="Sub Category" ValidateRequiredField="False"
                                OnAcquireTreePopulater="treeSubCategoryID_AcquireTreePopulater" PropertyName="SubCategoryID"
                                meta:resourcekey="treeSubCategoryIDResource1" ShowCheckBoxes="None" TreeValueMode="SelectedNode">
                            </ui:UIFieldTreeList>
                            <ui:uifielddropdownlist runat='server' id="dropAccountType" Caption="Account Type"
                                PropertyName="AccountTypeID" meta:resourcekey="dropAccountTypeResource1">
                            </ui:uifielddropdownlist>
                            <ui:UIFieldTextBox runat="server" ID="textAccountCode" Caption="Account Code" PropertyName="AccountCode"
                                InternalControlWidth="95%" meta:resourcekey="textAccountCodeResource1">
                            </ui:UIFieldTextBox>
                            <ui:UIFieldTextBox runat="server" ID="textDescription" Caption="Description" PropertyName="Description"
                                InternalControlWidth="95%" meta:resourcekey="textDescriptionResource1">
                            </ui:UIFieldTextBox>
                    </ui:UIPanel>
                    <ui:UIPanel runat="server" ID="TransactionPanel" BorderStyle="NotSet" meta:resourcekey="TransactionPanelResource1">
                        <ui:UIFieldRadioList runat="server" ID="rdlIsAllTos" Caption="Transaction Types"
                            PropertyName="AppliesToAllPurchaseTypes" OnSelectedIndexChanged="rdlIsAllTos_SelectedIndexChanged"
                            ValidateRequiredField="True" meta:resourcekey="rdlIsAllTosResource1" TextAlign="Right">
                            <Items>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource3" Text="Apply to all transaction types"></asp:ListItem>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource4" Text="Apply only to the following transaction types "></asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIFieldListBox ID="listPurchaseType" runat="server" ValidateRequiredField="True"
                            PropertyName="PurchaseTypes" ToolTip="Purchase Types that assigned to this Account"
                            meta:resourcekey="listPurchaseTypeResource1"></ui:UIFieldListBox>
                    </ui:UIPanel>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="tabMemo" Caption="Memo" BorderStyle="NotSet" meta:resourcekey="tabMemoResource1">
                    <web:memo runat="server" ID="memo1"></web:memo>
                </ui:UITabView>
                <ui:UITabView ID="tabAttachments" runat="server" Caption="Attachments" BorderStyle="NotSet"
                    meta:resourcekey="tabAttachmentsResource1">
                    <web:attachments runat="server" ID="attachments"></web:attachments>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
