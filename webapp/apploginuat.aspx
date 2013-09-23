<%@ Page Language="C#" Theme="Corporate" CodeFile="~/apploginuat.aspx.cs" Inherits="applogin"
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
<body>

    <script type='text/javascript'>
        if (window.top) {
            if (window.top.name.indexOf('AnacleEAM') == 0) {
                if (window.top.opener) {
                    try {
                        window.top.opener.location = 'applogin.aspx';
                        window.top.opener.focus();
                    }
                    catch (e) {
                    }
                }
                window.top.close();
            }

            if (window.top.location != window.location)
                window.top.location = window.location;
        }
    </script>

    <form id="form1" runat="server">
    <div>
        <table cellpadding="0" cellspacing="0" border="0" width="100%">
            <tr>
                <td align="center">
                    <table cellpadding="0" cellspacing="0" border="0" runat="server">
                        <tr>
                            <td style="width: 600px; height: 50px">
                            </td>
                        </tr>
                        <tr>
                            <td runat="server" id="tableLoginCell" style="width: 600px; height: 400px; background-color: white;"
                                align="center" valign="middle">
                                <div style="padding: 12px 12px 12px 12px">
                                    <asp:Login ID="login" runat="server" OnAuthenticate="Login1_Authenticate" OnLoggedIn="Login1_LoggedIn"
                                        Font-Names="Tahoma" Font-Size="8pt" meta:resourcekey="loginResource1" DisplayRememberMe="False"
                                        UserNameLabelText="Login Name:" PasswordRecoveryText="Forgot password" 
                                        PasswordRecoveryUrl="apploginreset.aspx">
                                        <TitleTextStyle />
                                        <LoginButtonStyle Font-Names="Tahoma" Font-Size="8pt" />
                                    </asp:Login>
                                    <asp:Panel runat="server" ID="panelSchemaError" Visible="False" 
                                        meta:resourcekey="panelSchemaErrorResource1">
                                        <asp:Label runat="server" ID="labelSchemaError1" 
                                            Text="Unable to load Application Settings." 
                                            meta:resourcekey="labelSchemaError1Resource1"></asp:Label>
                                        <br />
                                        <asp:Label runat="server" ID="labelSchemaErrorException" ForeColor="Red" 
                                            meta:resourcekey="labelSchemaErrorExceptionResource1"></asp:Label>
                                    </asp:Panel>
                                    <asp:Panel runat="server" ID="panelNoAccess" Visible="false">
                                        <b>Access Denied</b>
                                        <br />
                                        Your user account '<asp:Label runat='server' ID='labelUserLoginName'></asp:Label>' was not granted access to this system.<br />
                                        <br />
                                        Please contact your administrator.
                                    </asp:Panel>
                                    <asp:Panel runat="server" ID="panelNoAccessNotLoggedOn" Visible="false">
                                        <b>Access Denied</b>
                                        <br />
                                        You are not logged as a valid Windows user. 
                                        <br />
                                        Please contact your administrator.
                                    </asp:Panel>
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
                                <asp:Panel runat="server" ID="panelSql" meta:resourcekey="panelSqlResource1">
                                    <asp:Label runat="server" ID="labelSql1" meta:resourcekey="labelSql1Resource1">Click </asp:Label>
                                    <asp:LinkButton runat="server" ID="buttonGenerateScript" 
                                        OnClick="buttonGenerateScript_Click" 
                                        meta:resourcekey="buttonGenerateScriptResource1">here</asp:LinkButton>
                                    <asp:Label runat="server" ID="labelSql2" meta:resourcekey="labelSql2Resource1">to generate the SQL Script for updating the database schema.</asp:Label>
                                    <br />
                                    <br />
                                    <asp:Label runat="server" ID="labelSql3" meta:resourcekey="labelSql3Resource1">Click </asp:Label>
                                    <asp:LinkButton runat="server" ID="buttonGenerateScriptForAuditTrail" 
                                        OnClick="buttonGenerateScriptAuditTrail_Click" 
                                        meta:resourcekey="buttonGenerateScriptAuditTrailResource1">here</asp:LinkButton>
                                    <asp:Label runat="server" ID="labelSql4" meta:resourcekey="labelSql4Resource1">to generate the SQL Script for updating the audit trail tables schema.</asp:Label>
                                </asp:Panel>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </div>
    </form>
</body>
</html>
