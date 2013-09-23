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
        OBudget oBudget = (OBudget)panel.SessionObject;

        if (oBudget.IsNew)
        {
            oBudget.BudgetSpendingPolicy = OApplicationSetting.Current.DefaultBudgetSpendingPolicy;
            oBudget.BudgetDeductionPolicy = OApplicationSetting.Current.DefaultBudgetDeductionPolicy;
        }

        FillNotifyUser();
        treeLocation.PopulateTree();
        dropBudgetGroup.Bind(OBudgetGroup.GetListOfBudgetGroupsByListOfPositions(AppSession.User.Positions));
        panel.ObjectPanel.BindObjectToControls(oBudget);
    }

    /// <summary>
    /// Validates and save the budget object into the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OBudget budget = panel.SessionObject as OBudget;
            panel.ObjectPanel.BindControlsToObject(budget);

            // Validate
            //
            OBudget oBudget = (OBudget)panel.SessionObject;
            if (oBudget.IsDuplicateName() == true)
                objectBase.ObjectName.ErrorMessage = Resources.Errors.General_NameDuplicate;

            if (!panel.ObjectPanel.IsValid)
                return;

            // Save
            //
            budget.Save();
            c.Commit();
        }

    }

    /// <summary>
    /// Populates location access tree.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        return new LocationTreePopulaterForCapitaland(null, true, true, "",false,false);
    }


    /// <summary>
    /// Binds users to be notified to corresponding drop down list.
    /// </summary>
    protected void FillNotifyUser()
    {
        List<OUser> oUser = OUser.GetUsersByRole("BUDGETADMIN");
        NotifyUser1.Bind(oUser);
        NotifyUser2.Bind(oUser);
        NotifyUser3.Bind(oUser);
        NotifyUser4.Bind(oUser);
    }


    /// <summary>
    /// Hides/shows elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        /*        
        if (panel.SessionObject.IsNew == false)
        {
            treeLocation.Visible = false;
            gridLocations.Columns[0].Visible = false;
            gridLocations.Commands[0].Visible = false;
        }
*/
        
    }

    
    /// <summary>
    /// Occurs when the user selects a node on the treeview.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void treeLocation_SelectedNodeChanged(object sender, EventArgs e)
    {
        if (treeLocation.SelectedValue != "")
        {
            OBudget budget = panel.SessionObject as OBudget;
            panel.ObjectPanel.BindControlsToObject(budget);
            
            budget.ApplicableLocations.AddGuid(new Guid(treeLocation.SelectedValue));
            treeLocation.SelectedValue = "";

            panel.ObjectPanel.BindObjectToControls(budget);
        }
            
    }

    protected void dropBudgetGroup_SelectedIndexChanged(object sender, EventArgs e)
    {
        OBudget budget = panel.SessionObject as OBudget;
        panel.ObjectPanel.BindControlsToObject(budget);
        if (dropBudgetGroup.SelectedValue != "")
            budget.BudgetGroups.AddGuid(new Guid(dropBudgetGroup.SelectedValue));
        panel.ObjectPanel.BindObjectToControls(budget);
    }

    protected void gv_BudgetGroups_Action(object sender, string commandName, List<object> objectIds)
    {
        if (commandName == "RemoveObject")
        {
            OBudget budget = (OBudget)panel.SessionObject;
            foreach (Guid id in objectIds)
                budget.BudgetGroups.RemoveGuid(id);

            panel.ObjectPanel.BindControlsToObject(budget);
            panel.ObjectPanel.BindObjectToControls(budget);
        }
    }
</script>

<body>
    <form id="form1" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
            meta:resourcekey="panelMainResource1">
            <web:object runat="server" ID="panel" Caption="Budget" BaseTable="tBudget" OnValidateAndSave="panel_ValidateAndSave"
                OnPopulateForm="panel_PopulateForm" meta:resourcekey="panelResource1"></web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" BorderStyle="NotSet" 
                    meta:resourcekey="tabObjectResource1">
                    <!--Tab Detail-->
                    <ui:UITabView runat="server" ID="tabDetails" Caption="Details" 
                        Height="450px" BorderStyle="NotSet" meta:resourcekey="tabDetailsResource1">
                        <web:base runat="server" ID="objectBase" ObjectNameVisible="true" ObjectNameCaption="Budget Name"
                            ObjectNameValidateRequiredField="true" ObjectNameEnabled="true" ObjectNumberVisible="false" meta:resourcekey="objectBaseResource1">
                        </web:base>
                        <ui:UIFieldTextBox runat='server' ID="textDefaultNumberOfMonthsPerBudgetPeriod" 
                            PropertyName="DefaultNumberOfMonthsPerBudgetPeriod" 
                            Caption="Number of Months per Period" CaptionWidth="200px" Span="Half" 
                            ValidateRequiredField="True" ValidateDataTypeCheck="True" 
                            ValidateRangeField="True" ValidationDataType="Integer" ValidationRangeMin="0" 
                            ValidationRangeMinInclusive="False" ValidationRangeType="Integer" 
                            InternalControlWidth="95%" 
                            meta:resourcekey="textDefaultNumberOfMonthsPerBudgetPeriodResource1">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat='server' ID="textDefaultNumberOfMonthsPerInterval" 
                            PropertyName="DefaultNumberOfMonthsPerInterval" 
                            Caption="Number of Months per Interval" CaptionWidth="200px" Span="Half" 
                            ValidateRequiredField="True" ValidateCompareField="True" 
                            ValidateDataTypeCheck="True" ValidateRangeField="True" 
                            ValidationCompareControl="textDefaultNumberOfMonthsPerBudgetPeriod" 
                            ValidationCompareOperator="LessThanEqual" ValidationCompareType="Integer" 
                            ValidationDataType="Integer" ValidationRangeMin="0" 
                            ValidationRangeMinInclusive="False" ValidationRangeType="Integer" 
                            InternalControlWidth="95%" 
                            meta:resourcekey="textDefaultNumberOfMonthsPerIntervalResource1">
                        </ui:UIFieldTextBox>
                        <ui:uifieldradiolist runat="server" id="radioBudgetSpendingPolicy" PropertyName="BudgetSpendingPolicy" Caption="Budget Spending Policy" ValidaterequiredField="True" meta:resourcekey="radioBudgetSpendingPolicyResource1" TextAlign="Right">
                            <Items>
                                <asp:ListItem value="0" Text="Disallow spending from budget periods that have not been created." meta:resourcekey="ListItemResource1"></asp:ListItem>
                                <asp:ListItem value="1" Text="Allow spending from budget periods that have not been created." meta:resourcekey="ListItemResource2"></asp:ListItem>
                            </Items>
                        </ui:uifieldradiolist>
                        <ui:uifieldradiolist runat="server" id="radioBudgetDeductionPolicy" PropertyName="BudgetDeductionPolicy" Caption="Budget Deduction Policy" ValidaterequiredField="True" meta:resourcekey="radioBudgetDeductionPolicyResource1" TextAlign="Right">
                            <Items>
                                <asp:ListItem value="0" Text="Deducted at the point of submission of any purchase object." meta:resourcekey="ListItemResource3"></asp:ListItem>
                                <asp:ListItem value="1" Text="Deducted at the point of approval of any purchase object." meta:resourcekey="ListItemResource4"></asp:ListItem>
                            </Items>
                        </ui:uifieldradiolist>
                        <br />
                        <br />
                        <ui:UIFieldTreeList ID="treeLocation" runat="server" Caption="Location" 
                            OnAcquireTreePopulater="treeLocation_AcquireTreePopulater" 
                            OnSelectedNodeChanged="treeLocation_SelectedNodeChanged" 
                            meta:resourcekey="treeLocationResource1" ShowCheckBoxes="None" 
                            TreeValueMode="SelectedNode">
                        </ui:UIFieldTreeList>
                        <ui:UIGridView runat="server" ID="gridLocations" 
                            PropertyName="ApplicableLocations" Caption="Locations" 
                            ValidateRequiredField="True" DataKeyNames="ObjectID" GridLines="Both" 
                            meta:resourcekey="gridLocationsResource1" RowErrorColor="" 
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
                                <cc1:UIGridViewBoundColumn DataField="Path" HeaderText="Location" 
                                    meta:resourcekey="UIGridViewBoundColumnResource1" PropertyName="Path" 
                                    ResourceAssemblyName="" SortExpression="Path">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                        <ui:UIObjectPanel runat="server" ID="panelLocations" BorderStyle="NotSet" 
                            meta:resourcekey="panelLocationsResource1">
                            <web:subpanel runat="server" ID="subpanelLocations" GridViewID="gridLocations" />
                        </ui:UIObjectPanel>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabBudgetGroup" Caption="Budget Groups" 
                        Height="100%" BorderStyle="NotSet" meta:resourcekey="tabBudgetGroupResource1">
                       <ui:UIFieldDropDownList runat="server" Caption="Budgets" ID="dropBudgetGroup" 
                            OnSelectedIndexChanged="dropBudgetGroup_SelectedIndexChanged" 
                            meta:resourcekey="dropBudgetGroupResource1"></ui:UIFieldDropDownList>
                       
                    <ui:UIGridView runat="server" ID="gv_BudgetGroups" PropertyName="BudgetGroups"
                        Caption="Selected Budget Groups" KeyName="ObjectID" BindObjectsToRows="True" 
                            OnAction="gv_BudgetGroups_Action" DataKeyNames="ObjectID" GridLines="Both" meta:resourcekey="gv_BudgetGroupsResource1" 
                            RowErrorColor="" style="clear:both;" ImageRowErrorUrl="">
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
                    <ui:UITabView runat="server" ID="tabReminders" Caption="Reminders" 
                        BorderStyle="NotSet" meta:resourcekey="tabRemindersResource1">
                        <ui:UIFieldDropDownList runat="server" ID="NotifyUser1" Caption="Notify User 1" 
                            Span="Half" PropertyName="NotifyUser1ID" 
                            ToolTip="User who the system will notify when available amount of a budget item reaches the threshold" 
                            meta:resourcekey="NotifyUser1Resource1">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat="server" ID="NotifyUser2" Caption="Notify User 2" Span="Half"
                            PropertyName="NotifyUser2ID" 
                            ToolTip="User who the system will notify when available amount of a budget item reaches the threshold" 
                            meta:resourcekey="NotifyUser2Resource1">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat="server" ID="NotifyUser3" Caption="Notify User 3" Span="Half"
                            PropertyName="NotifyUser3ID" 
                            ToolTip="User who the system will notify when available amount of a budget item reaches the threshold" 
                            meta:resourcekey="NotifyUser3Resource1">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat="server" ID="NotifyUser4" Caption="Notify User 4" Span="Half"
                            PropertyName="NotifyUser4ID" 
                            ToolTip="User who the system will notify when available amount of a budget item reaches the threshold" 
                            meta:resourcekey="NotifyUser4Resource1">
                        </ui:UIFieldDropDownList>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabMemo" Caption="Memo" BorderStyle="NotSet" 
                        meta:resourcekey="tabMemoResource1">
                        <web:memo runat="server" ID="memo1"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView ID="tabAttachments" runat="server" Caption="Attachments" 
                        BorderStyle="NotSet" meta:resourcekey="tabAttachmentsResource1">
                        <web:attachments runat="server" ID="attachments"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
