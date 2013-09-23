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
        OCustomerAccount customerAccount = (OCustomerAccount)panel.SessionObject;
        panel.ObjectPanel.BindObjectToControls(customerAccount);
        if (!customerAccount.IsNew)
        {
            ddlIBID.Enabled = false;
            panelCustomerDetails.Enabled = false;
        }
    }

    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OCustomerAccount customerAccount = (OCustomerAccount)panel.SessionObject;
        CustomerID.Bind(TablesLogic.tCustomer.LoadAll(), "CustomerName", "ObjectID");
        ddlIBID.Bind(TablesLogic.tUser.LoadAll());
        panel.ObjectPanel.BindObjectToControls(customerAccount);

        panel.ObjectPanel.BindControlsToObject(customerAccount);
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
            OCustomerAccount code = (OCustomerAccount)panel.SessionObject;

            panel.ObjectPanel.BindControlsToObject(code);
            if (!panel.ObjectPanel.IsValid)
                return;
            // Save
            //

            code.Save();
            c.Commit();
        }
    }

    protected void CustomerID_SelectedIndexChanged(object sender, EventArgs e)
    {
        OCustomerAccount custacc = panel.SessionObject as OCustomerAccount;
        panel.ObjectPanel.BindControlsToObject(custacc);
        if (custacc.CustomerID != null)
        {
            custacc.Customer = TablesLogic.tCustomer.Load(TablesLogic.tCustomer.ObjectID == custacc.CustomerID);
        }
        panel.ObjectPanel.BindObjectToControls(custacc);
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
        <web:object runat="server" ID="panel" Caption="Đăng ký TK" BaseTable="tCustomerAccount"
            OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave">
        </web:object>
        <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject" BorderStyle="NotSet">
                <ui:UITabView runat="server" ID="uitabview1" Caption="Chi tiết" BorderStyle="NotSet">
                    <web:base runat="server" ID="objectBase" ObjectNameEnabled="false" ObjectNameVisible="false"
                        ObjectNumberEnabled="false"></web:base>
                    <ui:UIPanel runat="server" ID="IBDetails">
                        <ui:UIFieldSearchableDropDownList runat="server" ID="ddlIBID" PropertyName="IBID"
                            Caption="IB" InternalControlWidth="95%">
                        </ui:UIFieldSearchableDropDownList>
                    </ui:UIPanel>
                    <ui:UISeparator runat="server" Caption="Khách hàng" />
                    <ui:UIPanel runat="server" ID="panelCustomerDetails">
                        <ui:UIFieldSearchableDropDownList runat="server" ID="CustomerID" PropertyName="CustomerID"
                            InternalControlWidth="95%" Caption="Customer" OnSelectedIndexChanged="CustomerID_SelectedIndexChanged">
                        </ui:UIFieldSearchableDropDownList>
                        <ui:UIFieldTextBox ID="tbCMND" runat="server" Caption="CMND" InternalControlWidth="95%"
                            Span="OneThird" PropertyName="Customer.CMND" ValidateRequiredField="true">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldDateTime runat="server" ID="dtCustomerDateOfBirth" Caption="Date Of Birth"
                            PropertyName="Customer.CustomerDateOfBirth" InternalControlWidth="95%" Span="OneThird">
                        </ui:UIFieldDateTime>
                        <%--<br />--%>
                        <ui:UIFieldTextBox ID="tbCustomerAddress" runat="server" Caption="Địa chỉ" InternalControlWidth="95%"
                            Span="TwoThird" PropertyName="Customer.CustomerAddress" ValidateRequiredField="true">
                        </ui:UIFieldTextBox>
                    </ui:UIPanel>
                    <ui:UISeparator runat="server" Caption="Tài khoản" />
                    <ui:UIPanel runat="server" ID="panelAccountDetails">
                        <ui:UIFieldTextBox runat="server" ID="tbAccountNumber" PropertyName="AccountNumber"
                            Caption="Account Number" ValidateRequiredField="true" Span="OneThird" InternalControlWidth="95%">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldTextBox runat="server" ID="tbDeposit" Caption="Deposit" ValidateRequiredField="true"
                            PropertyName="Deposit" ValidateDataTypeCheck="true" ValidationDataType="Currency"
                            InternalControlWidth="95%" DataFormatString="{0:#,##0.00}" Span="OneThird">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldLabel runat="server" ID="tbEquity" Caption="So du" DataFormatString="{0:#,##0.00}"
                            PropertyName="Equity" InternalControlWidth="95%" Span="OneThird">
                        </ui:UIFieldLabel>
                        
                    </ui:UIPanel>
                    <ui:UIPanel runat="server" ID="panelCommission">
                        <ui:UIFieldTextBox runat="server" ID="tbCommission" Caption="Commission Rate" PropertyName="CommissionRate"
                            Span="OneThird" InternalControlWidth="95%" DataFormatString="{0:#,##0.00}">
                        </ui:UIFieldTextBox>
                        <ui:UIFieldLabel runat="server" ID="tbIBCommission" Caption="IB Commission" PropertyName="BrokerCommission"
                            Span="OneThird" InternalControlWidth="95%" DataFormatString="{0:US$ #,##0.00}">
                        </ui:UIFieldLabel>
                        <%--<ui:UIFieldTextBox runat="server" ID="tb" Caption="IB Commission" PropertyName="CommissionRate"
                            Span="OneThird" InternalControlWidth="95%" DataFormatString="{0:#,##0.00}">
                        </ui:UIFieldTextBox>--%>
                    </ui:UIPanel>
                    <br />
                    <br />
                    <ui:UIGridView ID="TransactionHistories" runat="server" Caption="Transaction History"
                        PropertyName="TransactionHistories" KeyName="ObjectID" Width="100%" AllowPaging="True"
                        AllowSorting="True" PagingEnabled="True">
                        <Commands>
                            <%--<ui:UIGridViewCommand CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?"
                                ImageUrl="~/images/delete.gif" CommandName="DeleteObject"></ui:UIGridViewCommand>
                            <ui:UIGridViewCommand CommandText="Add" ImageUrl="~/images/add.gif" CommandName="AddObject">
                            </ui:UIGridViewCommand>--%>
                        </Commands>
                        <Columns>
                            <%-- <ui:UIGridViewButtonColumn ImageUrl="~/images/edit.gif" CommandName="EditObject"
                                HeaderText="" meta:resourcekey="UIGridViewColumnResource1">
                            </ui:UIGridViewButtonColumn>
                            <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" ConfirmText="Are you sure you wish to delete this item?"
                                CommandName="DeleteObject" HeaderText="">
                            </ui:UIGridViewButtonColumn>--%>
                            <ui:UIGridViewBoundColumn HeaderText="Number" PropertyName="ItemNumber">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn HeaderText="Ticket" PropertyName="Ticket">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn HeaderText="Open Time" PropertyName="OpenTime" DataFormatString="{0:yyyy.MM.dd hh:mm}">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn HeaderText="Type" PropertyName="TypeText">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn HeaderText="Size" PropertyName="Size" DataFormatString="{0:#,##0.00}">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn HeaderText="Price" PropertyName="OpenPrice" DataFormatString="{0:#,##0.00}">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn HeaderText="S / L" PropertyName="StopLoss" DataFormatString="{0:#,##0.00}">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn HeaderText="T / P" PropertyName="TakeProfit" DataFormatString="{0:#,##0.00}">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn HeaderText="Close Time" PropertyName="CloseTime" DataFormatString="{0:yyyy.MM.dd hh:mm}">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn HeaderText="Price" PropertyName="ClosePrice" DataFormatString="{0:#,##0.00}">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn HeaderText="Commission" PropertyName="Commission" DataFormatString="{0:#,##0.00}">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn HeaderText="Taxes" PropertyName="Tax" DataFormatString="{0:#,##0.00}">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn HeaderText="Swap" PropertyName="Swap" DataFormatString="{0:#,##0.00}">
                            </ui:UIGridViewBoundColumn>
                            <ui:UIGridViewBoundColumn HeaderText="Profit" PropertyName="Profit" DataFormatString="{0:#,##0.00}">
                            </ui:UIGridViewBoundColumn>
                        </Columns>
                    </ui:UIGridView>
                    <%-- <ui:UIObjectPanel ID="TransactionHistories_Panel" runat="server">
                        <web:subpanel runat="server" ID="TransactionHistories_SubPanel" GridViewID="TransactionHistories"/>
                        <ui:UIFieldTextBox ID="ItemNumber" runat="server" Caption="STT" PropertyName="ItemNumber"
                            Span="Half" ValidateRequiredField="True">
                        </ui:UIFieldTextBox>
                        
                        <ui:UIFieldRadioList ID="ItemType" runat="server" Caption="Item Type" PropertyName="ItemType"
                            RepeatColumns="0" OnSelectedIndexChanged="ItemType_SelectedIndexChanged" ValidateRequiredField="True"
                            meta:resourcekey="ItemTypeResource1">
                            <Items>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource1" Text="Inventory">
                                </asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource2" Text="Service">
                                </asp:ListItem>
                                <asp:ListItem Value="2" meta:resourcekey="ListItemResource3">Others</asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIFieldTreeList ID="CatalogueID" runat="server" Caption="Catalog" PropertyName="CatalogueID"
                            OnAcquireTreePopulater="CatalogueID_AcquireTreePopulater" OnSelectedNodeChanged="CatalogueID_SelectedNodeChanged"
                            ValidateRequiredField="True" meta:resourcekey="CatalogueIDResource1">
                        </ui:UIFieldTreeList>
                        <ui:UIFieldTreeList ID="FixedRateID" runat="server" Caption="Fixed Rate" PropertyName="FixedRateID"
                            OnAcquireTreePopulater="FixedRateID_AcquireTreePopulater" OnSelectedNodeChanged="FixedRateID_SelectedNodeChanged"
                            ValidateRequiredField="True" meta:resourcekey="FixedRateIDResource1">
                        </ui:UIFieldTreeList>
                        <ui:UIFieldLabel runat="server" ID="UnitOfMeasure" Caption="Unit of Measure" PropertyName="Catalogue.UnitOfMeasure.ObjectName"
                            meta:resourcekey="UnitOfMeasureResource1" />
                        <ui:UIFieldLabel runat="server" ID="UnitOfMeasure2" Caption="Unit of Measure" PropertyName="FixedRate.UnitOfMeasure.ObjectName"
                            meta:resourcekey="UnitOfMeasure2Resource1" />
                        <ui:UIFieldTextBox ID="ItemDescription" runat="server" Caption="Description" PropertyName="ItemDescription"
                            MaxLength="255" ValidateRequiredField="True" meta:resourcekey="ItemDescriptionResource1" />
                        <ui:UIFieldDropDownList runat="server" ID="UnitOfMeasureID" Caption="Unit of Measure"
                            PropertyName="UnitOfMeasureID" ValidateRequiredField="True" meta:resourcekey="UnitOfMeasureIDResource1" />
                        <ui:UIFieldRadioList runat="server" ID="radioReceiptMode" meta:resourcekey="radioReceiptModeResource1"
                            PropertyName="ReceiptMode" Caption="Receipt Mode" OnSelectedIndexChanged="radioReceiptMode_SelectedIndexChanged">
                            <Items>
                                <asp:ListItem Value="0" meta:resourcekey="ListItemResource4">Receive by Quantity</asp:ListItem>
                                <asp:ListItem Value="1" meta:resourcekey="ListItemResource5">Receive by Dollar Amount</asp:ListItem>
                            </Items>
                        </ui:UIFieldRadioList>
                        <ui:UIFieldTextBox ID="textQuantityRequired" runat="server" Caption="Quantity Required"
                            PropertyName="QuantityRequired" Span="Half" ValidateDataTypeCheck="True" ValidateRangeField="True"
                            ValidateRequiredField="True" ValidationDataType="Currency" ValidationRangeMax="99999999999999"
                            ValidationRangeMin="0" ValidationRangeType="Currency" meta:resourcekey="UIFieldTextBox1Resource1" />
                    </ui:UIObjectPanel>--%>
                    &nbsp; &nbsp;&nbsp;
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview3" Caption="Memo" meta:resourcekey="uitabview3Resource1"
                    BorderStyle="NotSet">
                    <web:memo ID="Memo1" runat="server"></web:memo>
                </ui:UITabView>
                <ui:UITabView runat="server" ID="uitabview2" Caption="Đính kèm" BorderStyle="NotSet">
                    <web:attachments runat="server" ID="attachments"></web:attachments>
                </ui:UITabView>
            </ui:UITabStrip>
        </div>
    </ui:UIObjectPanel>
    </form>
</body>
</html>
