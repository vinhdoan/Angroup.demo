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
        OBudget oBudget = (OBudget)panel.SessionObject;

        FillNotifyUser();
        treeLocation.PopulateTree();

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
        return new LocationTreePopulater(null, true, true, "");
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

        if (panel.SessionObject.IsNew == false)
        {
            treeLocation.Visible = false;
            gridLocations.Columns[0].Visible = false;
            gridLocations.Commands[0].Visible = false;
        }

        
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
</script>

<body>
    <form id="form1" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain">
            <web:object runat="server" ID="panel" Caption="Budget" BaseTable="tBudget" OnValidateAndSave="panel_ValidateAndSave"
                OnPopulateForm="panel_PopulateForm" meta:resourcekey="panelResource1"></web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1">
                    <!--Tab Detail-->
                    <ui:UITabView runat="server" ID="tabDetails" Caption="Details" meta:resourcekey="tabDetailsResource2"
                        Height="450px">
                        <web:base runat="server" ID="objectBase" ObjectNameVisible="true" ObjectNameCaption="Budget Name"
                            ObjectNameValidateRequiredField="true" ObjectNameEnabled="true" ObjectNumberVisible="false"
                            meta:resourcekey="objectBaseResource1"
                            >
                        </web:base>
                        <ui:UIFieldTextBox runat='server' ID="textDefaultNumberOfMonthsPerBudgetPeriod" meta:resourcekey="textDefaultNumberOfMonthsPerBudgetPeriodResource1"
                            PropertyName="DefaultNumberOfMonthsPerBudgetPeriod" 
                            Caption="Number of Months per Period" CaptionWidth="200px" Span="Half" 
                            ValidateRequiredField="true" ValidateDataTypeCheck="True" 
                            ValidateRangeField="True" ValidationDataType="Integer" ValidationRangeMin="0" 
                            ValidationRangeMinInclusive="False" ValidationRangeType="Integer">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat='server' ID="textDefaultNumberOfMonthsPerInterval" meta:resourcekey="textDefaultNumberOfMonthsPerIntervalResource1"
                            PropertyName="DefaultNumberOfMonthsPerInterval" 
                            Caption="Number of Months per Interval" CaptionWidth="200px" Span="Half" 
                            ValidateRequiredField="true" ValidateCompareField="True" 
                            ValidateDataTypeCheck="True" ValidateRangeField="True" 
                            ValidationCompareControl="textDefaultNumberOfMonthsPerBudgetPeriod" 
                            ValidationCompareOperator="LessThanEqual" ValidationCompareType="Integer" 
                            ValidationDataType="Integer" ValidationRangeMin="0" 
                            ValidationRangeMinInclusive="False" ValidationRangeType="Integer">
                        </ui:UIFieldTextBox>
                        <br />
                        <br />
                        <ui:UIFieldTreeList ID="treeLocation" runat="server" Caption="Location" OnAcquireTreePopulater="treeLocation_AcquireTreePopulater"
                            Span="full" OnSelectedNodeChanged="treeLocation_SelectedNodeChanged" meta:resourcekey="treeLocationResource1">
                        </ui:UIFieldTreeList>
                        <ui:UIGridView runat="server" ID="gridLocations" PropertyName="ApplicableLocations" Caption="Locations" ValidateRequiredField="true" meta:resourcekey="gridLocationsResource1">
                            <Columns>
                                <ui:UIGridViewButtonColumn CommandName="RemoveObject" ImageUrl="~/images/delete.gif" ConfirmText="Are you sure you wish to remove this item?" meta:resourcekey="UIGridViewButtonColumnResource1"></ui:UIGridViewButtonColumn>
                                <ui:UIGridViewBoundColumn PropertyName="Path" HeaderText="Location" meta:resourcekey="UIGridViewBoundColumnResource1"></ui:UIGridViewBoundColumn>
                            </Columns>
                            <Commands>
                                <ui:UIGridViewCommand CommandName="RemoveObject" CommandText="Remove" ConfirmText="Are you sure you wish to remove the selected items?" ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource1"/>
                            </Commands>
                        </ui:UIGridView>
                        <ui:UIObjectPanel runat="server" ID="panelLocations" meta:resourcekey="panelLocationsResource1">
                            <web:subpanel runat="server" ID="subpanelLocations" GridViewID="gridLocations" />
                        </ui:UIObjectPanel>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabReminders" Caption="Reminders" meta:resourcekey="tabRemindersResource1">
                        <ui:UIFieldDropDownList runat="server" ID="NotifyUser1" Caption="Notify User 1"  meta:resourcekey="NotifyUser1Resource1"
                            Span="half" PropertyName="NotifyUser1ID" ToolTip="User who the system will notify when available amount of a budget item reaches the threshold">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat="server" ID="NotifyUser2" Caption="Notify User 2" Span="half" meta:resourcekey="NotifyUser2Resource1"
                            PropertyName="NotifyUser2ID" ToolTip="User who the system will notify when available amount of a budget item reaches the threshold">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat="server" ID="NotifyUser3" Caption="Notify User 3" Span="half" meta:resourcekey="NotifyUser3Resource1"
                            PropertyName="NotifyUser3ID" ToolTip="User who the system will notify when available amount of a budget item reaches the threshold">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldDropDownList runat="server" ID="NotifyUser4" Caption="Notify User 4" Span="half" meta:resourcekey="NotifyUser4Resource1"
                            PropertyName="NotifyUser4ID" ToolTip="User who the system will notify when available amount of a budget item reaches the threshold">
                        </ui:UIFieldDropDownList>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabMemo" Caption="Memo" meta:resourcekey="tabMemoResource1">
                        <web:memo runat="server" ID="memo1"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView ID="tabAttachments" runat="server" Caption="Attachments" meta:resourcekey="tabAttachmentsResource1">
                        <web:attachments runat="server" ID="attachments"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
