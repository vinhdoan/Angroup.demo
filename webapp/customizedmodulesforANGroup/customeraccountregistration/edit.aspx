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
        OCustomerAccountRegistration registration = (OCustomerAccountRegistration)panel.SessionObject;
        panel.ObjectPanel.BindObjectToControls(registration);
        ddlIBID.Bind(OUser.GetAllUsers());
        if (registration.IsNew || registration.CurrentActivity.ObjectName.Is("Start"))
        {
            registration.IBID = Workflow.CurrentUser.ObjectID;
        }
        panel.ObjectPanel.BindControlsToObject(registration);
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
            OCustomerAccountRegistration code = (OCustomerAccountRegistration)panel.SessionObject;
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
        <web:object runat="server" ID="panel" Caption="Đăng ký TK" BaseTable="tCustomerAccountRegistration" SaveButtonsVisible="false" ShowWorkflowActionAsButtons="true"
            OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave">
        </web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" BorderStyle="NotSet">
                <ui:UITabView runat="server" ID="uitabview1" Caption="Chi tiết" BorderStyle="NotSet">
                    <web:base runat="server" ID="objectBase"  ObjectNameEnabled="false" ObjectNameVisible="false">
                    </web:base>
                    <ui:UIPanel runat="server" ID="IBDetails">
                        <ui:UIFieldSearchableDropDownList runat="server" ID="ddlIBID" PropertyName="IBID"
                            Caption="IB" InternalControlWidth="95%">
                        </ui:UIFieldSearchableDropDownList>
                    </ui:UIPanel>
                    <ui:UISeparator runat="server" Caption="Khách hàng" />
                    <ui:UIPanel runat="server" ID="panelCustomerDetails">
                        <ui:UIFieldTextBox ID="tbCustomerName" runat="server" Caption="Tên KH" InternalControlWidth="95%"
                            Span="Half" PropertyName="CustomerName" ValidateRequiredField="true">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldTextBox ID="tbCMND" runat="server" Caption="Số CMND" InternalControlWidth="95%"
                            Span="Half" PropertyName="CustomerName" ValidateRequiredField="true">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldDateTime runat="server" ID="dtCustomerDateOfBirth" Caption="Ngày sinh"
                            PropertyName="CustomerDateOfBirth" InternalControlWidth="95%" Span="Half">
                        </ui:UIFieldDateTime>
                        <ui:UIFieldTextBox ID="tbCustomerAddress" runat="server" Caption="Địa chỉ" InternalControlWidth="95%"
                            Span="Half" PropertyName="CustomerAddress" ValidateRequiredField="true">
                        </ui:UIFieldTextBox>
                    </ui:UIPanel>
                    <ui:UISeparator runat="server" Caption="Tài khoản" />
                    <ui:UIPanel runat="server" ID="panelAccountDetails">
                        <ui:UIFieldTextBox runat="server" ID="tbDeposit" Caption="Deposit" ValidateRequiredField="true" PropertyName="Deposit"
                            ValidateDataTypeCheck="true" ValidationDataType="Currency" Span="Half">
                        </ui:UIFieldTextBox>
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
