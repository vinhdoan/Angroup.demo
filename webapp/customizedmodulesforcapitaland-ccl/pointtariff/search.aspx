<%@ Page Language="C#" Theme="Classy" Inherits="PageBase" Culture="auto" UICulture="auto"
    meta:resourcekey="PageResource1" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">
    
    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        List<OPosition> positions = AppSession.User.GetPositionsByObjectType(Security.Decrypt(Request["TYPE"]));
        dropLocation.Bind(OLocation.GetLocationsByType(OApplicationSetting.Current.LocationTypeNameForBuildingActual, false, positions, null));
    }

    /// <summary>
    /// Performs search with custom conditions.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        e.CustomCondition = Query.True;
        List<OPosition> positions = AppSession.User.GetPositionsByObjectType(Security.Decrypt(Request["TYPE"]));
        Guid? selectedLocation = (dropLocation.SelectedValue == "" ? (Guid?)null : new Guid(dropLocation.SelectedValue));
        OLocation location = TablesLogic.tLocation.Load(selectedLocation);
        if (location != null)
            e.CustomCondition = e.CustomCondition & TablesLogic.tPointTariff.Location.HierarchyPath.Like(location.HierarchyPath + "%");
        else
        {
            e.CustomCondition = Query.False;
            foreach (OPosition position in positions)
                foreach (OLocation l in position.LocationAccess)
                    e.CustomCondition = e.CustomCondition | TablesLogic.tPointTariff.Location.HierarchyPath.Like(l.HierarchyPath + "%");
        }
            
    }


    /// <summary>
    /// Occurs when the user clicks on a button in the grid view.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="commandName"></param>
    /// <param name="dataKeys"></param>
    protected void gridResults_Action(object sender, string commandName, List<object> dataKeys)
    {
        if (commandName == "MassUpdate")
        {
            MassDiscount.Text = "";
            MassTariff.Text = "";
            //objectPanelMassUpdate.Visible = true;
            popupMassUpdate.Show();
        }
    }

    /***********************************************
    /// <summary>
    /// Occurs when the user clicks "Save" button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonMassUpdateConfirm_Click(object sender, EventArgs e)
    {
        List<object> ids = gridResults.GetSelectedKeys();
        List<Guid> pointTariffIds = new List<Guid>();
        foreach (Guid id in ids)
            pointTariffIds.Add(id);
        OPointTariff.MassUpdateTariffAndDiscounts(pointTariffIds,
            Convert.ToDecimal(MassTariff.Text),
            Convert.ToDecimal(MassDiscount.Text));

        panel.Message = String.Format(Resources.Messages.PointTariff_MassUpdateTariffAndDiscountSuccessful, ids.Count);
        panel.PerformSearch();

        objectPanelMassUpdate.Visible = false;
        popupMassUpdate.Hide();
    }

    /// <summary>
    /// Occurs when the user clicks "Cancel" button.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonMassUpdateCancel_Click(object sender, EventArgs e)
    {
        objectPanelMassUpdate.Visible = false;
        popupMassUpdate.Hide();
    }
    **************************************************/

    protected void popupMassUpdate_ButtonClicked(object sender, ButtonClickedEventArgs e)
    {
        if (e.CommandName == "Confirm")
        {
            List<object> ids = gridResults.GetSelectedKeys();
            List<Guid> pointTariffIds = new List<Guid>();
            foreach (Guid id in ids)
                pointTariffIds.Add(id);
            OPointTariff.MassUpdateTariffAndDiscounts(pointTariffIds,
                Convert.ToDecimal(MassTariff.Text),
                Convert.ToDecimal(MassDiscount.Text));

            panel.Message = String.Format(Resources.Messages.PointTariff_MassUpdateTariffAndDiscountSuccessful, ids.Count);
            panel.PerformSearch();
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form2" runat="server">
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
        <web:search runat="server" ID="panel" OnPopulateForm="panel_PopulateForm" Caption="Point Tariff"
            GridViewID="gridResults" BaseTable="tPointTariff" OnSearch="panel_Search" SearchType="ObjectQuery"
            SearchTextBoxHint="Point Name" AutoSearchOnLoad="true" MaximumNumberOfResults="30" 
            SearchTextBoxPropertyNames="ObjectName" AdvancedSearchPanelID="panelAdvanced"
            EditButtonVisible="false" AssignedCheckboxVisible="false" SearchAssignedOnly="false"
            meta:resourcekey="panelResource1"></web:search>
        <div class="div-form">
            <%--<ui:UITabStrip runat="server" ID="tabSearch" BorderStyle="NotSet" meta:resourcekey="tabSearchResource1">
                <ui:UITabView runat="server" ID="uitabview3" Caption="Search" BorderStyle="NotSet"
                    meta:resourcekey="uitabview3Resource1">--%>
                <ui:UIPanel runat="server" ID="panelAdvanced" BorderStyle="NotSet">
                    <ui:uifielddropdownlist runat="server" id="dropLocation" Caption="Building" 
                        PropertyName="LocationID" meta:resourcekey="dropLocationResource1">
                    </ui:uifielddropdownlist>
                    <ui:UIFieldTextBox runat="server" ID="textTariff" PropertyName="DefaultTariff" Caption="Tariff"
                        Span="Half" SearchType="Range" InternalControlWidth="95%" 
                        meta:resourcekey="textTariffResource1" />
                    <ui:UIFieldTextBox runat="server" ID="textDiscount" PropertyName="DefaultDiscount"
                        Caption="Discount%" Span="Half" SearchType="Range" 
                        InternalControlWidth="95%" meta:resourcekey="textDiscountResource1" />
                </ui:UIPanel>
                <%--</ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview4" Caption="Results" BorderStyle="NotSet"
                    meta:resourcekey="uitabview4Resource1">--%>
                    <ui:UIGridView runat="server" ID="gridResults" Caption="Results" KeyName="ObjectID"
                        Width="100%" DataKeyNames="ObjectID" GridLines="Both" meta:resourcekey="gridResultsResource1"
                        RowErrorColor="" style="clear: both;" PageSize="1000" 
                        OnAction="gridResults_Action" ImageRowErrorUrl="">
                        <PagerSettings Mode="NumericFirstLast" />
                        <commands>
                            <ui:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="DeleteObject"
                                CommandText="Delete Selected" ConfirmText="Are you sure you wish to delete the selected items?"
                                ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewCommandResource1" />
                            <ui:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" CommandName="MassUpdate"
                                CommandText="Mass Update (Tariff and Discount)" ImageUrl="~/images/tick.gif"
                                meta:resourcekey="UIGridViewCommandResource2" />
                        </commands>
                        <Columns>
                            <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="EditObject" ImageUrl="~/images/edit.gif"
                                meta:resourcekey="UIGridViewButtonColumnResource1">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="ViewObject" ImageUrl="~/images/view.gif"
                                meta:resourcekey="UIGridViewButtonColumnResource2">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewButtonColumn ButtonType="Image" CommandName="DeleteObject" ConfirmText="Are you sure you wish to delete this item?"
                                ImageUrl="~/images/delete.gif" meta:resourcekey="UIGridViewButtonColumnResource3">
                                <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewBoundColumn HeaderText="Name" PropertyName="Location.ObjectName" 
                                DataField="Location.ObjectName" 
                                meta:resourcekey="UIGridViewBoundColumnResource1" ResourceAssemblyName="" 
                                SortExpression="Location.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn HeaderText="Default Tariff ($)" 
                                PropertyName="DefaultTariff" DataField="DefaultTariff" 
                                meta:resourcekey="UIGridViewBoundColumnResource2" ResourceAssemblyName="" 
                                SortExpression="DefaultTariff">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn HeaderText="Default Discount (%)" 
                                PropertyName="DefaultDiscount" DataField="DefaultDiscount" 
                                meta:resourcekey="UIGridViewBoundColumnResource3" ResourceAssemblyName="" 
                                SortExpression="DefaultDiscount">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn HeaderText="Type of Meter" 
                                PropertyName="TypeOfMeter.ObjectName" DataField="TypeOfMeter.ObjectName" 
                                ResourceAssemblyName="" 
                                SortExpression="TypeOfMeter.ObjectName">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" />
                            </ui:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                    <ui:UIDialogBox runat="server" ID="popupMassUpdate" Title="Mass Update"
                        Button1AutoClosesDialogBox="true" Button1CausesValidation="true" Button1ImageUrl="~/images/tick.gif" Button1CommandName="Confirm" Button1Text="Confirm" Button1ConfirmText="Are you sure you want to update the tariffs and discounts? The tariffs and the discounts for all ACTIVE and UNLOCKED Points at and under the Locations will be updated as well!" Button1FontBold="true"
                        Button2AutoClosesDialogBox="true" Button2CommandName="Cancel" Button2ImageUrl="~/images/delete.gif" Button2Text="Cancel" Button2CausesValidation="false" Button2FontBold="true"
                        OnButtonClicked="popupMassUpdate_ButtonClicked">
                        <ui:UIFieldTextBox runat="server" id="MassTariff" Caption="Default Tariff" ValidaterequiredField="True"
                            ValidateDataTypeCheck="True" ValidationDataType='Currency' ValidateRangeField="True"
                            ValidationRangeMin="0" InternalControlWidth="95%"
                            meta:resourcekey="MassTariffResource1" />
                        <ui:UIFieldTextBox runat="server" id="MassDiscount" Caption="Default Discount (%)"
                            ValidaterequiredField="True" ValidateDataTypeCheck="True" ValidationDataType='Currency'
                            ValidateRangeField="True" ValidationRangeMin="0"
                            ValidationRangeMax="100" InternalControlWidth="95%"
                            meta:resourcekey="MassDiscountResource1" />
                    </ui:UIDialogBox>
                    <%--<asp:LinkButton runat="server" ID="buttonMassUpdateHidden" meta:resourcekey="buttonMassUpdateHiddenResource1" />
                    <asp:ModalPopupExtender runat='server' id="popupMassUpdate" PopupControlID="objectPanelMassUpdate"
                        BackgroundCssClass="modalBackground" TargetControlID="buttonMassUpdateHidden"
                        DynamicServicePath="" Enabled="True">
                    </asp:ModalPopupExtender>
                    <ui:uiobjectpanel runat="server" id="objectPanelMassUpdate" Width="400px" 
                        BackColor="White" Visible="False"
                        BorderStyle="NotSet" meta:resourcekey="objectPanelMassUpdateResource1">
                        <div style="padding: 8px 8px 8px 8px">
                            <ui:uiseparator id="Uiseparator3" runat="server" caption="Mass Update" meta:resourcekey="Uiseparator3Resource1" />
                            
                            <br />
                            <table cellpadding='2' cellspacing='0' border='0' style="border-top: solid 1px gray;
                                width: 100%">
                                <tr>
                                    <td style='width: 120px'>
                                    </td>
                                    <td>
                                        <ui:uibutton runat='server' id="buttonMassUpdateConfirm" Text="Save" Imageurl="~/images/tick.gif"
                                            ConfirmText="Are you sure you want to update the tariffs and discounts? The tariffs and the discounts for all ACTIVE and UNLOCKED Points at and under the Locations will be updated as well!"
                                            meta:resourcekey="buttonMassUpdateConfirmResource1" OnClick="buttonMassUpdateConfirm_Click" />
                                        <ui:uibutton runat='server' id="buttonMassUpdateCancel" Text="Cancel" Imageurl="~/images/delete.gif"
                                            CausesValidation='False' meta:resourcekey="buttonMassUpdateCancelResource1" OnClick="buttonMassUpdateCancel_Click" />
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </ui:uiobjectpanel>--%>
                <%--</ui:UITabView>
            </ui:UITabStrip>--%>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
