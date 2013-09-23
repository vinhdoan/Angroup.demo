<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto"  %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">
    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        treeLocation.PopulateTree();
    }


    /// <summary>
    /// Constructs the location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        return new LocationTreePopulaterForCapitaland(null, true, true,
            Security.Decrypt(Request["TYPE"]), false, false);
    }


    /// <summary>
    /// Searches the panel.
    /// </summary>
    /// <param name="e"></param>
    protected void panel_Search(objectSearchPanel.SearchEventArgs e)
    {
        e.CustomCondition = Query.True;

        if (treeLocation.SelectedValue != "")
        {
            OLocation location = TablesLogic.tLocation[new Guid(treeLocation.SelectedValue)];
            if (location != null)
                e.CustomCondition = e.CustomCondition & TablesLogic.tMeter.Location.HierarchyPath.Like(location.HierarchyPath + "%");
        }
        else
        {
            ExpressionCondition locCondition = Query.False;
            foreach (OPosition position in AppSession.User.GetPositionsByObjectType("OMeter"))
            {
                foreach (OLocation location in position.LocationAccess)
                    locCondition = locCondition | TablesLogic.tMeter.Location.HierarchyPath.Like(location.HierarchyPath + "%");
            }
            e.CustomCondition = locCondition;
        }
            
    }

    protected void gridResults_Action(object sender, string commandName, List<object> dataKeys)
    {
     
     
    }

    protected void buttonCancelReminderUser_Click(object sender, EventArgs e)
    {
    }

    protected void buttonAssignReminderUser_Click(object sender, EventArgs e)
    {

    }

    protected void buttonMassUpdateCancel_Click(object sender, EventArgs e)
    {
       
    }

    protected void buttonMassUpdateConfirm_Click(object sender, EventArgs e)
    {
    
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
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" >
            <web:search runat="server" ID="panel" Caption="Meter" GridViewID="gridResults" EditButtonVisible="false"
                BaseTable="tMeter" AutoSearchOnLoad="true" SearchTextBoxHint="Meter Name, Barcode, BMS Code" 
                MaximumNumberOfResults="100" SearchTextBoxPropertyNames="ObjectName,Barcode,BMSCode"
                AdvancedSearchPanelID="panelAdvanced" AdvancedSearchOnLoad="false"
                OnPopulateForm="panel_PopulateForm" SearchType="ObjectQuery" OnSearch="panel_Search">
            </web:search>
            <div class="div-form">
                <%--<ui:UITabStrip runat="server" ID="tabSearch" BorderStyle="NotSet" >
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Search" 
                        BorderStyle="NotSet" >--%>
                    <ui:uifieldtreelist runat="server" id="treeLocation" Caption="Location" 
                            OnAcquireTreePopulater="treeLocation_AcquireTreePopulater" ShowCheckBoxes="None" 
                            TreeValueMode="SelectedNode"></ui:uifieldtreelist>
                    <ui:UIPanel runat="server" ID="panelAdvanced" BorderStyle="NotSet">
                        <%--<ui:UIFieldTextBox runat="server" ID="textObjectName" PropertyName="ObjectName" 
                            Caption="Meter Name" Span="Half" InternalControlWidth="95%" 
                            meta:resourcekey="textObjectNameResource1"></ui:UIFieldTextBox>--%>
                        <ui:UIFieldRadioList runat='server' ID="radioIsActive" PropertyName="IsActive"
                            Caption="Is Active?" TextAlign="Right">
                            <Items>
                                <asp:ListItem Value="" Text="Any" Selected="True" ></asp:ListItem>
                                <asp:ListItem Value="1" Text="Yes, this Meter is active, and can be linked to a Point" ></asp:ListItem>
                                <asp:ListItem Value="0" Text="No, this Meter is Non-active, and can not be linked to a Point" ></asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <%--<ui:UIFieldTextBox runat="server" ID="textBarcode" PropertyName="Barcode"
                            Caption="Barcode" InternalControlWidth="95%" ></ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="txtBMSCode" Caption="BMS Code" 
                            PropertyName="BMSCode"  InternalControlWidth="95%"></ui:UIFieldTextBox>--%>
                        <ui:UIFieldRadioList runat="server" ID="radioIsIncreasingMeter" Caption="Type" PropertyName="IsIncreasingMeter" TextAlign="Right">
                            <Items>
                                <asp:ListItem Value="" Text="Any" Selected="True"></asp:ListItem>
                                <asp:ListItem Value="0" Text="Absolute Reading (for readings from temperature, vibration sensors, etc that do not increase over time)"></asp:ListItem>
                                <asp:ListItem Value="1" Text="Increasing Reading (for readings from electrical meters, water meters, etc that always increase over time)"></asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                    </ui:UIPanel>
                       <%-- <ui:UIFieldTextBox runat="server" ID="textMaximumReading" 
                                    Caption="Maximum Reading" PropertyName="MaximumReading" 
                                     ValidateRangeField="True" 
                                    ValidateDataTypeCheck="True" ValidationDataType="Currency" 
                                    ValidationRangeMin="0" ValidationRangeMinInclusive="False" 
                                    ValidationRangeType='Currency' Span="Half" InternalControlWidth="95%">
                         </ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="textFactor" Caption="Factor" 
                                    PropertyName="Factor"  ValidateRangeField="True" 
                                    ValidationRangeType='Currency' ValidateDataTypeCheck="True" 
                                    ValidationRangeMin="0" ValidationRangeMinInclusive="False" Span="Half" 
                                    InternalControlWidth="95%">
                                </ui:UIFieldTextBox>--%>
                        
                        <div style="clear: both"></div>
                    <%--</ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview4" Caption="Results" 
                        BorderStyle="NotSet"  >--%>
                        <ui:UIGridView runat="server" ID="gridResults" Caption="Results" 
                            KeyName="ObjectID" Width="100%" DataKeyNames="ObjectID" GridLines="Both" 
                            meta:resourcekey="gridResultsResource1" RowErrorColor="" 
                            style="clear:both;" 
                            ImageRowErrorUrl="">
                            <PagerSettings Mode="NumericFirstLast" />
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
                                <cc1:UIGridViewBoundColumn DataField="ObjectName" HeaderText="Name" 
                                     PropertyName="ObjectName" 
                                    ResourceAssemblyName="" SortExpression="ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Location.ObjectName" HeaderText="Location" 
                                     PropertyName="Location.ObjectName" 
                                    ResourceAssemblyName="" SortExpression="Location.ObjectName">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Barcode" 
                                    HeaderText="Barcode" 
                                    PropertyName="Barcode" ResourceAssemblyName="" 
                                    SortExpression="Barcode" >
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="Factor" 
                                    HeaderText="Factor" 
                                    PropertyName="Factor" ResourceAssemblyName="" 
                                    SortExpression="Factor" >
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                                <cc1:UIGridViewBoundColumn DataField="MaximumReading" 
                                    HeaderText="Maximum Reading" 
                                    PropertyName="MaximumReading" ResourceAssemblyName="" 
                                    SortExpression="MaximumReading" >
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </cc1:UIGridViewBoundColumn>
                            </Columns>
                        </ui:UIGridView>
                    <%--</ui:UITabView>
                </ui:UITabStrip>--%>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
