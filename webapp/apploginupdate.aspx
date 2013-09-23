<%@ Page Language="C#" Theme="Corporate" CodeFile="~/apploginupdate.aspx.cs" Inherits="apploginupdate"
    UICulture="auto" Culture="auto" meta:resourcekey="PageResource1" %>

<%@ Import Namespace="System.Threading" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<script runat="server">
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Simplism.EAM</title>
</head>
<body style="padding: 0px 0px 0px 0px; margin: 0px 0px 0px 0px">
    <form id="form1" runat="server">
    <table cellpadding="0" cellspacing="0" border="0" width="100%">
        <tr>
            <td align="center">
                <table id="Table1" cellpadding="0" cellspacing="0" border="0" runat="server">
                    <tr>
                        <td style="width: 600px; height: 50px">
                        </td>
                    </tr>
                    <tr>
                        <td runat="server" id="tableLoginCell" style="width: 600px; height: 400px;" align="center"
                            valign="middle">
                            <div style="padding: 12px 12px 12px 12px">
                                <table runat="server" id="tblNewPassword" cellpadding="0" border="0">
                                    <tr>
                                        <td align="center" colspan="2">
                                            <asp:Label runat="server" ID="lblUpdatePasswordMessage" Text="Please enter a new password." />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td align="right">
                                            <asp:Label runat="server" ID="lblNewPassword" Text="New Password:" />
                                        </td>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtNewPassword" TextMode="Password" MaxLength="50" />
                                            <asp:Label runat="server" ID="lblPasswordRequired" ToolTip="New Password is required."
                                                ForeColor="Red" Visible="false">*</asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td align="right">
                                            <asp:Label runat="server" ID="lblConfirmNewPassword" Text="Confirm Password:" />
                                        </td>
                                        <td>
                                            <asp:TextBox runat="server" ID="txtConfirmNewPassword" TextMode="Password" MaxLength="50" />
                                            <asp:Label runat="server" ID="lblConfirmNewPasswordRequired" ToolTip="Confirm New Password is required."
                                                ForeColor="Red" Visible="false">*</asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td align="right" colspan="2" style="color: Red;">
                                            <asp:Label runat="server" ID="lblPasswordError" EnableViewState="false" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td align="right" colspan="2">
                                            <asp:Button runat="server" ID="btnUpdatePassword" Text="Update & Proceed" OnClick="btnUpdatePassword_Click" />
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td align="center" valign="middle" style="height: 30px">
                            <asp:Label runat="server" ID="labelLicense" meta:resourcekey="labelLicenseResource1"></asp:Label>
                        </td>
                    </tr>
                    <tr>
                        <td align="center" valign="middle" style="height: 30px">
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
    </form>
</body>
</html>
