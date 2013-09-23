<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">
    
protected void Page_Load(object sender, EventArgs e)
{
    if (Request["AccountID"] != null && Security.Decrypt(Request["AccountID"]) != null)
    {
        Guid AccountID = new Guid(Security.Decrypt(Request["AccountID"]));
        Guid BudgetPeriodID = new Guid(Security.Decrypt(Request["BudgetPeriodID"]));
        OBudgetPeriod budgetPeriod = TablesLogic.tBudgetPeriod.Load(BudgetPeriodID);
        if (budgetPeriod != null)
        {
            labelBudgetName.Text = budgetPeriod.Budget.ObjectName;
            labelBudgetPeriodName.Text = budgetPeriod.ObjectName;
            labelStartDate.Text = budgetPeriod.StartDate.Value.ToString("dd-MMM-yyyy");
            labelEndDate.Text = budgetPeriod.EndDate.Value.ToString("dd-MMM-yyyy");

            OAccount account = TablesLogic.tAccount.Load(AccountID);
            labelAccount.Text = (account != null ? account.Path : "");
                
            //wj details
            DataTable dtWJDetails = OAccount.WJDetails(AccountID, budgetPeriod.BudgetID.Value, budgetPeriod.StartDate.Value, budgetPeriod.EndDate.Value);
            gridWJDetails.DataSource = dtWJDetails;
            gridWJDetails.DataBind();

            //direct invoices
            DataTable dtInvoice = OAccount.DirectInvoice(AccountID, budgetPeriod.BudgetID.Value, budgetPeriod.StartDate.Value, budgetPeriod.EndDate.Value);
            gridDirectInvoice.DataSource = dtInvoice;
            gridDirectInvoice.DataBind();
        }
    }
}

protected override void OnPreRender(EventArgs e)
{
    base.OnPreRender(e);
}

protected void btnBackTop_Click(object sender, EventArgs e)
{
    Response.Redirect("budgetview.aspx?ID=" + HttpUtility.UrlEncode(Request["BudgetPeriodID"]));
}

protected void btnBackBottom_Click(object sender, EventArgs e)
{
    Response.Redirect("budgetview.aspx?ID=" + HttpUtility.UrlEncode(Request["BudgetPeriodID"]));
}
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form2" runat="server">
    <ui:UIPanel runat="server" ID="panelMain" BorderStyle="NotSet" meta:resourcekey="panelMainResource1">
        <div class="div-main" style="padding: 8px 8px 8px 8px;">
        <br />
        <ui:UIButton runat="server" ID="btnBackTop" Text="Back" OnClick="btnBackTop_Click" meta:resourcekey="btnBackTopResource1" />
        <br />
        <br />
        <table>
                    <tr>
                        <td width="150px">
                            <asp:Label ID="labelBudgetNameCaption" runat="server" Text="Budget: " Font-Bold="True" meta:resourcekey="labelBudgetNameCaptionResource1"></asp:Label>
                        </td>
                        <td>
                            <asp:Label ID="labelBudgetName" runat="server" meta:resourcekey="labelBudgetNameResource1"></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Label ID="labelBudgetPeriodNameCaption" runat="server" Text="Budget Period: "
                                Font-Bold="True" meta:resourcekey="labelBudgetPeriodNameCaptionResource1"></asp:Label>
                        </td>
                        <td>
                            <asp:Label ID="labelBudgetPeriodName" runat="server" meta:resourcekey="labelBudgetPeriodNameResource1"></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Label ID="labelStartDateCaption" runat="server" Text="Date: " Font-Bold="True" meta:resourcekey="labelStartDateCaptionResource1"></asp:Label>
                        </td>
                        <td>
                            <asp:Label ID="labelStartDate" runat="server" meta:resourcekey="labelStartDateResource1"></asp:Label>
                            <asp:Label ID="labelTo" runat="server" Text=" to " meta:resourcekey="labelToResource1"></asp:Label>
                            <asp:Label ID="labelEndDate" runat="server" meta:resourcekey="labelEndDateResource1"></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Label ID="labelAccountCaption" runat="server" Text="Account: " Font-Bold="True" meta:resourcekey="labelAccountCaptionResource1"></asp:Label>
                        </td>
                        <td>
                            <asp:Label ID="labelAccount" runat="server" meta:resourcekey="labelAccountResource1"></asp:Label>
                        </td>
                    </tr>
                </table>
        <br />
        <ui:UISeparator runat="server" Caption="WJ Details" meta:resourcekey="UISeparatorResource1" />
            <asp:DataGrid ID="gridWJDetails" runat="server" DataKeyField="AccountID"
                        CssClass="datagrid" BorderColor="#CCCCCC"
                        BorderWidth="1px" CellPadding="1" AutoGenerateColumns="False" Width="100%" meta:resourcekey="gridWJDetailsResource1" >
                        <Columns>
                             <asp:BoundColumn DataField="AccountID" ReadOnly="True" Visible="False" HeaderText="WJ Number">
                                 <ItemStyle Width="150px" />
                            </asp:BoundColumn>
                            <asp:BoundColumn DataField="RFQNumber" ReadOnly="True" HeaderText="WJ Number">
                                <ItemStyle Width="150px" />
                            </asp:BoundColumn>
                            <asp:BoundColumn DataField="PONumber" ReadOnly="True" HeaderText="PO Number">
                                <ItemStyle HorizontalAlign="Left" VerticalAlign="Middle" Width="150px" />
                             </asp:BoundColumn>
                            <asp:BoundColumn DataField="InvoiceNumber" ReadOnly="True" HeaderText="Invoice Number">
                                <ItemStyle Width="150px" />
                            </asp:BoundColumn>
                            <asp:BoundColumn DataField="Description" ReadOnly="True" HeaderText="Description">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" VerticalAlign="Middle" Width="250px" />
                             </asp:BoundColumn>
                            <asp:BoundColumn DataField="DateOfExpenditure" ReadOnly="True" HeaderText="Date Of Expenditure" DataFormatString="{0:dd-MMM-yyyy}">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" VerticalAlign="Middle" Width="150px" />
                             </asp:BoundColumn>
                            <asp:BoundColumn DataField="Amount" ReadOnly="True" HeaderText="Amount" DataFormatString="{0:#,##0.00}">
                                <HeaderStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" Width="150px" />
                             </asp:BoundColumn>
                            <asp:BoundColumn DataField="CreatedUser" ReadOnly="True" HeaderText="Requested By" >
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" VerticalAlign="Middle" />
                             </asp:BoundColumn>
                            <asp:BoundColumn DataField="ApprovedBy" ReadOnly="True" HeaderText="Approved By">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" VerticalAlign="Middle" Width="250px" />
                             </asp:BoundColumn>
                        </Columns>
                        <HeaderStyle CssClass="grid-header" />
                    </asp:DataGrid>
            <br />
            <br />
            <ui:UISeparator ID="UISeparator1" runat="server" Caption="Direct Invoices" meta:resourcekey="UISeparator1Resource1" />
            <asp:DataGrid ID="gridDirectInvoice" runat="server" DataKeyField="AccountID"
                        CssClass="datagrid" BorderColor="#CCCCCC"
                        BorderWidth="1px" CellPadding="1" AutoGenerateColumns="False" Width="100%" meta:resourcekey="gridDirectInvoiceResource1" >
                        <Columns>
                             <asp:BoundColumn DataField="AccountID" ReadOnly="True" Visible="False" HeaderText="WJ Number">
                                 <ItemStyle Width="100px" />
                            </asp:BoundColumn>
                            
                            <asp:BoundColumn DataField="InvoiceNumber" ReadOnly="True" HeaderText="Invoice Number">
                                <ItemStyle Width="100px" />
                            </asp:BoundColumn>
                            <asp:BoundColumn DataField="Description" ReadOnly="True" HeaderText="Description">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" VerticalAlign="Middle" Width="250px" />
                             </asp:BoundColumn>
                            <asp:BoundColumn DataField="DateOfExpenditure" ReadOnly="True" HeaderText="Date Of Expenditure" DataFormatString="{0:dd-MMM-yyyy}">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" VerticalAlign="Middle" Width="150px" />
                             </asp:BoundColumn>
                            <asp:BoundColumn DataField="Amount" ReadOnly="True" HeaderText="Amount" DataFormatString="{0:#,##0.00}">
                                <HeaderStyle HorizontalAlign="Right" />
                                <ItemStyle HorizontalAlign="Right" VerticalAlign="Middle" Width="100px" />
                             </asp:BoundColumn>
                            <asp:BoundColumn DataField="CreatedUser" ReadOnly="True" HeaderText="Requested By">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" VerticalAlign="Middle" />
                             </asp:BoundColumn>
                            <asp:BoundColumn DataField="ApprovedBy" ReadOnly="True" HeaderText="Approved By">
                                <HeaderStyle HorizontalAlign="Left" />
                                <ItemStyle HorizontalAlign="Left" VerticalAlign="Middle" Width="250px" />
                             </asp:BoundColumn>
                        </Columns>
                        <HeaderStyle CssClass="grid-header" />
           </asp:DataGrid>
           <br />
        <br />
           <ui:UIButton runat="server" ID="btnBackBottom" Text="Back" OnClick="btnBackBottom_Click" meta:resourcekey="btnBackBottomResource1" />
        </div>
    </ui:UIPanel>
    </form>
</body>
</html>
