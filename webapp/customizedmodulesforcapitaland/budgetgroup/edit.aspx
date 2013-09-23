<%@ Page Language="C#" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.Common" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>
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
        OBudgetGroup budgetGroup = panel.SessionObject as OBudgetGroup;
        List<OLocation> locations = new List<OLocation>();
        foreach (OPosition position in AppSession.User.GetPositionsByObjectType("OUser"))
            foreach (OLocation location in position.LocationAccess)
                locations.Add(location);
        

        dropPosition.Bind(OPosition.GetPositionsAtOrBelowLocations(locations), "ObjectName", "ObjectID");
        dropBudget.Bind(OBudget.GetBudgetsByListOfLocations(locations), "ObjectName", "ObjectID");
    }



    /// <summary>
    /// Hides/shows elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

     
    }

    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        OBudgetGroup budgetGroup = panel.SessionObject as OBudgetGroup;

        // Validate
        //
        if (budgetGroup.IsDuplicateName())
            this.objectBase.ObjectName.ErrorMessage = Resources.Errors.General_NameDuplicate;
        

        if (!panel.ObjectPanel.IsValid)
            return;

        budgetGroup.Save();
    }


    protected void dropPosition_SelectedIndexChanged(object sender, EventArgs e)
    {
        OBudgetGroup budgetGroup = (OBudgetGroup)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(budgetGroup);
        if (dropPosition.SelectedValue != "")
            budgetGroup.Positions.AddGuid(new Guid(dropPosition.SelectedValue));
        panel.ObjectPanel.BindObjectToControls(budgetGroup);
    }

    protected void gv_Position_Action(object sender, string commandName, List<object> objectIds)
    {
        if (commandName == "RemoveObject")
        {
            OBudgetGroup budgetGroup = (OBudgetGroup)panel.SessionObject;
            foreach (Guid id in objectIds)
                budgetGroup.Positions.RemoveGuid(id);

            panel.ObjectPanel.BindControlsToObject(budgetGroup);
            panel.ObjectPanel.BindObjectToControls(budgetGroup);
        }
    }

    protected void dropBudget_SelectedIndexChanged(object sender, EventArgs e)
    {
        OBudgetGroup budgetGroup = (OBudgetGroup)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(budgetGroup);
        if (dropBudget.SelectedValue != "")
            budgetGroup.Budgets.AddGuid(new Guid(dropBudget.SelectedValue));
        panel.ObjectPanel.BindObjectToControls(budgetGroup);
    }

    protected void gv_Budgets_Action(object sender, string commandName, List<object> objectIds)
    {
        if (commandName == "RemoveObject")
        {
            OBudgetGroup budgetGroup = (OBudgetGroup)panel.SessionObject;
            foreach (Guid id in objectIds)
                budgetGroup.Budgets.RemoveGuid(id);

            panel.ObjectPanel.BindControlsToObject(budgetGroup);
            panel.ObjectPanel.BindObjectToControls(budgetGroup);
        }
    }
</script>

<body>
    <form id="form1" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
            meta:resourcekey="panelMainResource1">
            <web:object runat="server" ID="panel" Caption="Budget Group" BaseTable="tBudgetGroup" AutomaticBindingAndSaving="true"
                OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1">
            </web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" 
                    meta:resourcekey="tabObjectResource1" BorderStyle="NotSet">
                    <!--Tab Detail-->
                    <ui:UITabView runat="server" ID="tabDetails" Caption="Details" 
                        Height="267px" BorderStyle="NotSet" meta:resourcekey="tabDetailsResource1">
                        <web:base runat="server" ID="objectBase" ObjectNameVisible="true" ObjectNameCaption="Budget Group Name" ObjectNameValidateRequiredField="true"
                            ObjectNumberVisible="false" meta:resourcekey="objectBaseResource1"></web:base>
                        <ui:UIFieldTextBox runat="server" ID="txtDescription" Caption="Description" 
                            PropertyName="Description" InternalControlWidth="95%" 
                            meta:resourcekey="txtDescriptionResource1"></ui:UIFieldTextBox>
                        
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabPosition" Caption="Position" Height="100%" 
                        BorderStyle="NotSet" meta:resourcekey="tabPositionResource1">
                       <ui:UIFieldDropDownList runat="server" Caption="Posistions" ID="dropPosition" 
                            OnSelectedIndexChanged="dropPosition_SelectedIndexChanged" 
                            meta:resourcekey="dropPositionResource1"></ui:UIFieldDropDownList>
                       
                    <ui:UIGridView runat="server" ID="gv_Position" PropertyName="Positions"
                        Caption="Selected Positions" KeyName="ObjectID" BindObjectsToRows="True" 
                            OnAction="gv_Position_Action" DataKeyNames="ObjectID" GridLines="Both" 
                            meta:resourcekey="gv_PositionResource1" RowErrorColor="" 
                            style="clear:both;" ImageRowErrorUrl="">
                        <PagerSettings Mode="NumericFirstLast" />
                        <commands>
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                CommandName="RemoveObject" CommandText="Remove" 
                                ConfirmText="Are you sure you wish to remove the selected items?" 
                                ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource1" />
                        </commands>
                        <Columns>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" 
                                ConfirmText="Are you sure you wish to remove this item?" 
                                ImageUrl="~/images/delete.gif" 
                                meta:resourcekey="UIGridViewButtonColumnResource1">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Name" 
                                meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="ObjectName" 
                                ResourceAssemblyName="" SortExpression="ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabBudget" Caption="Budgets" Height="100%" 
                        BorderStyle="NotSet" meta:resourcekey="tabBudgetResource1">
                       <ui:UIFieldDropDownList runat="server" Caption="Budgets" ID="dropBudget" 
                            OnSelectedIndexChanged="dropBudget_SelectedIndexChanged" 
                            meta:resourcekey="dropBudgetResource1"></ui:UIFieldDropDownList>
                       
                    <ui:UIGridView runat="server" ID="gv_Budgets" PropertyName="Budgets"
                        Caption="Selected Budgets" KeyName="ObjectID" BindObjectsToRows="True" 
                            OnAction="gv_Budgets_Action" DataKeyNames="ObjectID" GridLines="Both" 
                            meta:resourcekey="gv_BudgetsResource1" RowErrorColor="" 
                            style="clear:both;" ImageRowErrorUrl="">
                        <PagerSettings Mode="NumericFirstLast" />
                        <commands>
                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                CommandName="RemoveObject" CommandText="Remove" 
                                ConfirmText="Are you sure you wish to remove the selected items?" 
                                ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource2" />
                        </commands>
                        <Columns>
                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" 
                                ConfirmText="Are you sure you wish to remove this item?" 
                                ImageUrl="~/images/delete.gif" 
                                meta:resourcekey="UIGridViewButtonColumnResource2">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewButtonColumn>
                            <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Name" 
                                meta:resourcekey="UIGridViewBoundColumnResource2" PropertyName="ObjectName" 
                                ResourceAssemblyName="" SortExpression="ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </cc1:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                        
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabMemo" Caption="Memo" BorderStyle="NotSet" 
                        meta:resourcekey="tabMemoResource1"  >
                        <web:memo runat="server" ID="memo1"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView ID="tabAttachments" runat="server"  Caption="Attachments" 
                        BorderStyle="NotSet" meta:resourcekey="tabAttachmentsResource1">
                        <web:attachments runat="server" ID="attachments"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
