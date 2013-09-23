<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto"
    meta:resourcekey="PageResource1" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<script runat="server">
    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OBMSTransmissionStatus bmsStatus= panel.SessionObject as OBMSTransmissionStatus;
        panel.ObjectPanel.BindObjectToControls(bmsStatus);
    }


    /// <summary>
    /// Validates and saves the tax code object into the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OBMSTransmissionStatus bmsStatus = panel.SessionObject as OBMSTransmissionStatus;
            panel.ObjectPanel.BindControlsToObject(bmsStatus);
            // Save
            //
            bmsStatus.Save();
            c.Commit();
        }
    }


    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        OBMSTransmissionStatus bmsStatus = panel.SessionObject as OBMSTransmissionStatus;
        btnRetry.Visible = bmsStatus.Status == BMSStatus.Fail;
    }


    protected void btnRetry_Click(object sender, EventArgs e)
    {
        OBMSTransmissionStatus bmsStatus = panel.SessionObject as OBMSTransmissionStatus;
        OOPCDAServer opc = TablesLogic.tOPCDAServer.Load(bmsStatus.OPCDAServerID);
        if (opc != null)
            OBMSTransmissionStatus.GenerateReadingFromOPCDAServer(opc, true);
        OBMSTransmissionStatus newBMSStatus = TablesLogic.tBMSTransmissionStatus.Load(bmsStatus.ObjectID);
        panel.ObjectPanel.BindObjectToControls(newBMSStatus);
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
        <ui:UIObjectPanel runat="server" ID="panelMain">
            <web:object runat="server" ID="panel" Caption="BMS Transmission Status" BaseTable="tBMSTransmissionStatus" 
                OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave">
            </web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1">
                    <ui:UITabView ID="uitabview1" runat="server"  Caption="Details">
                        <web:base ID="objectBase" runat="server" ObjectNameVisible="false" ObjectNumberVisible="false">
                        </web:base>
                        <%--<ui:UIFieldLabel runat="server" ID="FileName" Caption="File Name" PropertyName="FileName"></ui:UIFieldLabel>--%>
                        <ui:UIFieldLabel runat="server" ID="OPCDAServer" Caption="OPCDA Server" PropertyName="OPCDAServer.ObjectName"></ui:UIFieldLabel>
                        <ui:UIFieldDateTime runat="server" ID="BMSDate" Caption="BMS Date" PropertyName="BMSDate" Enabled="false"></ui:UIFieldDateTime>
                        <ui:UIFieldLabel runat="server" ID="Status" Caption="Status" PropertyName="StatusText" Span="Half"></ui:UIFieldLabel>"
                        <br />
                        <ui:UIButton runat="server" ID="btnRetry" Text="Re-try" OnClick="btnRetry_Click" />
                        <ui:UIFieldDateTime runat="server" ID="SucceededDate" Caption="Succeeded Date" PropertyName="SucceededDate" Enabled="false"></ui:UIFieldDateTime>
                        <ui:UIFieldLabel runat="server" ID="NumberOfRecords" Caption="Number Of Records" PropertyName="NumberOfRecords" Span="Half"></ui:UIFieldLabel>
                        <ui:UIFieldLabel runat="server" ID="NumberOfRecordsImported" Caption="Number Of Records Imported" PropertyName="NumberOfRecordsImported" Span="Half" CaptionWidth="150px"></ui:UIFieldLabel>
                        <ui:UIFieldTextBox ID="txtRemarks" runat="server" PropertyName="Remarks" Caption="Remarks" MaxLength="500" Rows="5" Enabled="false" />
                        <ui:UISeparator runat="server" Caption="BMS Transmission Status Items" /> 
                        <ui:uigridview id="EquipmentWriteOffItems" runat="server" caption="Items" datakeynames="ObjectID" gridlines="Both" imagerowerrorurl="" keyname="ObjectID" pagingenabled="True" 
                            propertyname="BMSTransmissionStatusItems" rowerrorcolor="" showfooter="True"  SortExpression="RecordNo"
                             style="clear:both;" width="100%" >
                            <PagerSettings Mode="NumericFirstLast" />
                            <%--<commands>
                                <ui:uigridviewcommand alwaysenabled="False" causesvalidation="False" commandname="DeleteObject" commandtext="Delete" confirmtext="Are you sure you wish to delete the selected items?" imageurl="~/images/delete.gif"/>
                                <ui:uigridviewcommand alwaysenabled="False" causesvalidation="False" commandname="AddObject" commandtext="Add" imageurl="~/images/add.gif" meta:resourcekey="UIGridViewCommandResource2" />
                            </commands>--%>
                            <Columns>
                                <%--<ui:uigridviewbuttoncolumn buttontype="Image" commandname="EditObject" imageurl="~/images/edit.gif" meta:resourcekey="UIGridViewColumnResource1">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:uigridviewbuttoncolumn>
                                <ui:uigridviewbuttoncolumn buttontype="Image" commandname="DeleteObject" confirmtext="Are you sure you wish to delete this item?" imageurl="~/images/delete.gif" meta:resourcekey="UIGridViewColumnResource2">
                                    <HeaderStyle HorizontalAlign="Left" Width="16px" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:uigridviewbuttoncolumn>--%>
                                 <ui:uigridviewboundcolumn datafield="RecordNo" headertext="Record No." propertyname="RecordNo" resourceassemblyname="" sortexpression="RecordNo">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:uigridviewboundcolumn>
                                <ui:uigridviewboundcolumn datafield="BMSCode" headertext="BMS Code" propertyname="BMSCode" resourceassemblyname="" sortexpression="BMSCode">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:uigridviewboundcolumn>
                                <ui:uigridviewboundcolumn datafield="ReadingValue" headertext="Reading Value" propertyname="ReadingValue" resourceassemblyname="" sortexpression="ReadingValue">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:uigridviewboundcolumn>
                                <ui:uigridviewboundcolumn datafield="IsSuccessText" headertext="Is Success?" propertyname="IsSuccessText" resourceassemblyname="" sortexpression="IsSuccessText">
                                    <HeaderStyle HorizontalAlign="Left" />
                                    <ItemStyle HorizontalAlign="Left" />
                                </ui:uigridviewboundcolumn>
                            </Columns>
                        </ui:uigridview>
                        
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Memo"  meta:resourcekey="uitabview3Resource1">
                        <web:memo runat="server" ID="memo1"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView ID="uitabview2" runat="server"  Caption="Attachments"
                        meta:resourcekey="uitabview2Resource1">
                        <web:attachments runat="server" ID="attachments"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
