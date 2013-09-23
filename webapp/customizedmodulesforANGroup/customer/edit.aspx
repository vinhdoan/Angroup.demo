<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<%@ Register Assembly="Anacle.UIFramework" Namespace="Anacle.UIFramework" TagPrefix="cc1" %>

<script runat="server">

    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
    }

    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OCustomer customer = (OCustomer)panel.SessionObject;
        panel.ObjectPanel.BindObjectToControls(customer);
       
      
        panel.ObjectPanel.BindControlsToObject(customer);
    }


    /// <summary>
    /// Populates the Code Type dropdown list.
    /// </summary>
    /// <param name="code"></param>
    protected void populateCodeTypeID(OCode code)
    {
    }

    /// <summary>
    /// Validates and saves the code object.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OCustomer code = (OCustomer)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(code);      
            if (!panel.ObjectPanel.IsValid)
                return;
            // Save
            //
            code.Save();
            c.Commit();
        }
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
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet">
        <web:object runat="server" ID="panel" Caption="Customer" BaseTable="tCustomer" 
            OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave">
        </web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" BorderStyle="NotSet">
                <ui:UITabView runat="server" ID="uitabview1" Caption="Chi tiết" BorderStyle="NotSet">
                    <web:base runat="server" ID="objectBase"  ObjectNameEnabled="false" ObjectNameVisible="false">
                    </web:base>
                    <ui:UIPanel runat="server" ID="CustomerDetails">
                        <ui:UIFieldTextBox runat="server" ID="tbCustomerName" Caption="Customer Name" PropertyName="CustomerName" Span="OneThird" InternalControlWidth="95%" ValidateRequiredField="true">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="tbCMND" Caption="CMND" PropertyName="CMND" Span="OneThird" InternalControlWidth="95%" ValidateRequiredField="true">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="tbEmail" Caption="Email" PropertyName="Email" Span="OneThird" InternalControlWidth="95%" ValidateRequiredField="true">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="tbPhone" Caption="Phone" PropertyName="Phone" Span="OneThird" InternalControlWidth="95%" ValidateRequiredField="true">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldDateTime runat="server" ID="dtDateOfBirth" PropertyName="CustomerDateOfBirth" Span="OneThird" Caption="Date Of Birth" ValidateRequiredField="true">
                        </ui:UIFieldDateTime>     
                        <ui:UIFieldTextBox runat="server" ID="tbAddress" PropertyName="CustomerAddress" Span="TwoThird" Caption="Address" TextMode="MultiLine" Rows="5"></ui:UIFieldTextBox>                   
                    </ui:UIPanel>
                    &nbsp; &nbsp;&nbsp;
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview3" Caption="Memo" meta:resourcekey="uitabview3Resource1"
                    BorderStyle="NotSet">
                    <web:memo ID="Memo1" runat="server"></web:memo>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview2" Caption="Đính kèm"
                    BorderStyle="NotSet">
                    <web:attachments runat="server" ID="attachments"></web:attachments>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
