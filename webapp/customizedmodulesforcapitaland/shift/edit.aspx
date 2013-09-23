<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" UICulture="auto"
    meta:resourcekey="PageResource1" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
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
        OShift shift = panel.SessionObject as OShift;
        panel.ObjectPanel.BindObjectToControls(shift);
        

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
            OShift shift = panel.SessionObject as OShift;
            panel.ObjectPanel.BindControlsToObject(shift);

            shift.Save();
            c.Commit();
        }
    }


    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        StartTime.Visible = !checkIsNonWorkingShift.Checked;
        EndTime.Visible = !checkIsNonWorkingShift.Checked;
    }

    protected void checkIsNonWorkingShift_CheckedChanged(object sender, EventArgs e)
    {

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
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
            <web:object runat="server" ID="panel" Caption="Shift" BaseTable="tShift" 
                OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave" meta:resourcekey="panelResource1" >
            </web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" meta:resourcekey="tabObjectResource1" BorderStyle="NotSet">
                    <ui:UITabView ID="uitabview1" runat="server"  Caption="Details"
                        meta:resourcekey="uitabview1Resource1" BorderStyle="NotSet">
                        <web:base ID="objectBase" runat="server" ObjectNumberVisible="false" ObjectNameVisible="true" ObjectNameCaption="Shift Name" meta:resourcekey="objectBaseResource1" >
                        </web:base>
                        <ui:uifieldcheckbox runat="server" id="checkIsNonWorkingShift" 
                            Caption="Non-Working Shift" Text="Yes, this is a non-working shift." 
                            OnCheckedChanged="checkIsNonWorkingShift_CheckedChanged" 
                            meta:resourcekey="checkIsNonWorkingShiftResource1" 
                            PropertyName="IsNonWorkingShift" TextAlign="Right"></ui:uifieldcheckbox>
                        <ui:UIFieldDateTime runat="server" ID="StartTime" PropertyName="StartTime" ShowTimeControls="true" 
                            Caption="Start Time" ValidateRequiredField="True" Span="Half"  ShowDateControls="false"
                            meta:resourcekey="StartTimeResource1" ImageUrl=""></ui:UIFieldDateTime>
                        <ui:UIFieldDateTime ID="EndTime" runat="server" PropertyName="EndTime" ShowTimeControls="true"  ShowDateControls="false"
                            Caption="End Time" ValidateRequiredField="True" Span="Half" 
                            meta:resourcekey="EndTimeResource1" ImageUrl=""></ui:UIFieldDateTime>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Memo"  meta:resourcekey="uitabview3Resource1" BorderStyle="NotSet">
                        <web:memo runat="server" ID="memo1"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView ID="uitabview2" runat="server"  Caption="Attachments"
                        meta:resourcekey="uitabview2Resource1" BorderStyle="NotSet">
                        <web:attachments runat="server" ID="attachments"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
