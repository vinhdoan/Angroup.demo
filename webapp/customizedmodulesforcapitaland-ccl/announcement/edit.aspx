<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" 
    UICulture="auto" meta:resourcekey="PageResource1" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">

    /// <summary>
    /// Populate form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        //listPositions.Bind(OPosition.GetAllPositions());
        sddl_PositionID.Bind(OPosition.GetAllPositions());
    }
    
        
    /// <summary>
    /// Hide/show the positions list box.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void checkIsViewableByAll_CheckedChanged(object sender, EventArgs e)
    {
    }


    /// <summary>
    /// Hide/show elements
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        //listPositions.Visible = !checkIsViewableByAll.Checked;
        panelPositions.Visible = !checkIsViewableByAll.Checked;
    }

    protected void gv_Position_Action(object sender, string commandName, List<object> objectIds)
    {
        if (commandName == "RemoveObject")
        {
            OAnnouncement a = (OAnnouncement)panel.SessionObject;
            foreach (Guid id in objectIds)
                a.Positions.RemoveGuid(id);

            panel.ObjectPanel.BindControlsToObject(a);
            panel.ObjectPanel.BindObjectToControls(a);
        }
    }

    protected void sddl_PositionID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OAnnouncement a = (OAnnouncement)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(a);
        if (sddl_PositionID.SelectedValue != "")
            a.Positions.AddGuid(new Guid(sddl_PositionID.SelectedValue));
        panel.ObjectPanel.BindObjectToControls(a);
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain" 
            BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
            <web:object runat="server" ID="panel" Caption="Announcement" BaseTable="tAnnouncement" 
                AutomaticBindingAndSaving="true" OnPopulateForm="panel_PopulateForm" meta:resourcekey="panelResource1">
            </web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" 
                    BorderStyle="NotSet" meta:resourcekey="tabObjectResource1" >
                    <ui:UITabView ID="uitabview1" runat="server"  Caption="Details" BorderStyle="NotSet" 
                        meta:resourcekey="uitabview1Resource1">
                        <web:base ID="objectBase" runat="server" ObjectNameVisible="false" ObjectNumberVisible="false" meta:resourcekey="objectBaseResource1">
                        </web:base>
                        <ui:UIFieldDateTime runat="server" ID="dateStartDate" PropertyName="StartDate" 
                            Caption="Start Date" Span="Half" meta:resourcekey="dateStartDateResource1" 
                            ShowDateControls="True"></ui:UIFieldDateTime>
                        <ui:UIFieldDateTime runat="server" ID="dateEndDate" PropertyName="EndDate" 
                            Caption="End Date" Span="Half" ValidateCompareField="True" 
                            ValidationCompareControl="dateStartDate" 
                            ValidationCompareOperator="GreaterThanEqual" ValidationCompareType="Date" 
                            meta:resourcekey="dateEndDateResource1" ShowDateControls="True" ></ui:UIFieldDateTime>
                        <ui:UIFieldTextBox runat="server" ID="textAnnouncement" 
                            PropertyName="Announcement" Caption="Announcement" MaxLength="1000" 
                            TextMode="MultiLine"
                            ValidateRequiredField="True" InternalControlWidth="95%" 
                            meta:resourcekey="textAnnouncementResource1"></ui:UIFieldTextBox>
                        <ui:UIFieldCheckBox runat="server" ID="checkIsViewableByAll" 
                            PropertyName="IsViewableByAll" Caption="Viewable by all" 
                            OnCheckedChanged="checkIsViewableByAll_CheckedChanged" 
                            meta:resourcekey="checkIsViewableByAllResource1" TextAlign="Right"></ui:UIFieldCheckBox>
                    <ui:UIPanel runat="server" ID="panelPositions" 
                            meta:resourcekey="panelMaintenanceResource1" 
                            BorderStyle="NotSet">
                        <ui:UIFieldSearchableDropDownList ID="sddl_PositionID" runat="server" 
                            Caption="Position" 
                            OnSelectedIndexChanged="sddl_PositionID_SelectedIndexChanged" 
                            meta:resourcekey="sddl_PositionIDResource1" SearchInterval="300"></ui:UIFieldSearchableDropDownList>
                        <table width="96%">
                            <tr>
                                <td width="96%">
                                    <ui:UIGridView runat="server" ID="gv_Position" PropertyName="Positions"
                                        OnAction="gv_Position_Action" Caption="Viewable by Positions" 
                                        ValidateRequiredField="True" KeyName="ObjectID" BindObjectsToRows="True" 
                                        DataKeyNames="ObjectID" GridLines="Both" 
                                        meta:resourcekey="gv_PositionResource1" RowErrorColor="" 
                                        style="clear:both;">
                                        <PagerSettings Mode="NumericFirstLast" />
                                        <commands>
                                            <cc1:UIGridViewCommand AlwaysEnabled="False" CausesValidation="False" 
                                                CommandName="RemoveObject" CommandText="Remove" 
                                                ConfirmText="Are you sure you wish to remove the selected items?" 
                                                ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewCommandResource2" />
                                        </commands>
                                        <Columns>
                                            <cc1:UIGridViewButtonColumn ButtonType="Image" CommandName="RemoveObject" 
                                                ConfirmText="Are you sure you wish to remove this item?" 
                                                ImageUrl="~/images/delete.gif" meta:resourceKey="UIGridViewColumnResource1">
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
                                </td>
                            </tr>
                        </table>
                    </ui:UIPanel>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Memo" 
                        BorderStyle="NotSet" meta:resourcekey="uitabview3Resource1"  >
                        
                        <web:memo runat="server" ID="memo1"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView ID="uitabview2" runat="server"  Caption="Attachments" BorderStyle="NotSet" 
                        meta:resourcekey="uitabview2Resource1">
                        <web:attachments runat="server" ID="attachments"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
