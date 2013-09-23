<%@ Page Language="C#" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.Common" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
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

        treeParentID.PopulateTree();
    }

    
    /// <summary>
    /// Populates the budget category tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeParentID_AcquireTreePopulater(object sender)
    {
        return new AccountTreePopulater(panel.SessionObject.ParentID, true, false);
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
</script>

<body>
    <form id="form1" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain">
            <web:object runat="server" ID="panel" Caption="Account" BaseTable="tAccount" AutomaticBindingAndSaving="true"
                OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1">
            </web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1">
                    <!--Tab Detail-->
                    <ui:UITabView runat="server" ID="tabDetails" Caption="Details" meta:resourcekey="tabDetailsResource1"
                        Height="267px">
                        <web:base runat="server" ID="objectBase" ObjectNameVisible="true" ObjectNameValidateRequiredField="true"
                            ObjectNumberVisible="false"></web:base>
                        <ui:UIFieldTreeList ID="treeParentID" runat="server" Caption="Belongs Under" OnAcquireTreePopulater="treeParentID_AcquireTreePopulater"
                            PropertyName="ParentID" meta:resourcekey="treeParentIDResource1">
                        </ui:UIFieldTreeList>
                        <ui:UIFieldRadioList ID="radioType" runat="server" Caption="Category/Line Item" meta:resourcekey="radioTypeResource1"
                            RepeatDirection="Vertical" PropertyName="Type" ValidateRequiredField="true" OnSelectedIndexChanged="radioType_SelectedIndexChanged">
                            <Items>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource1">Category</asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource2">Line Item</asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIPanel runat="server" ID="panelLineItem" meta:resourcekey="panelLineItemResource1">
                            <ui:UIFieldTextBox runat="server" ID="textAccountCode" Caption="Account Code" PropertyName="AccountCode" meta:resourcekey="textAccountCodeResource1">
                            </ui:UIFieldTextBox>
                            <ui:UIFieldTextBox runat="server" ID="textDescription" Caption="Description" PropertyName="Description" meta:resourcekey="textDescriptionResource1"></ui:UIFieldTextBox>
                        </ui:UIPanel>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabMemo" Caption="Memo" meta:resourcekey="tabMemoResource1" >
                        <web:memo runat="server" ID="memo1"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView ID="tabAttachments" runat="server"  Caption="Attachments" meta:resourcekey="tabAttachmentsResource1">
                        <web:attachments runat="server" ID="attachments"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
