<%@ Page Language="C#" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ IMport Namespace="System.Net" %>
<%@ IMport Namespace="System.DirectoryServices" %>
<%@ IMport Namespace="System.Net.Security" %>
<%@ IMport Namespace="System.Security.Cryptography.X509Certificates" %>
<%@ IMport Namespace="Microsoft.Exchange.WebServices.Data" %>
<%@ IMport Namespace="Microsoft.Exchange.WebServices" %>

<script runat="server">

    protected void buttonCheck_Click(object sender, EventArgs e)
    {
        ServicePointManager.ServerCertificateValidationCallback = delegate(
            Object obj, X509Certificate certificate, X509Chain chain, SslPolicyErrors errors)
        {
            // trust any certificate
            return true;
        };

        
        ExchangeService service = new ExchangeService(ExchangeVersion.Exchange2007_SP1);
        service.Credentials = new NetworkCredential(textLogin.Text, textPassword.Text, textDomain.Text);
        service.Url = new Uri("https://bactabank.dc.capitaland.com/ews/exchange.asmx");
        
        FindItemsResults<Item> findResults = 
            service.FindItems(WellKnownFolderName.Inbox, new ItemView(100));

        labelMails.Text = findResults.Items.Count + " item(s)<br/><hr/>";
        foreach (Item item in findResults.Items)
        {
            item.Load();
            
            labelMails.Text +=
                "<br/>From: " + ((EmailMessage)item).From.Address +
                "<br/>Subject:" + item.Subject + 
                "<br/>Body:" + item.Body.Text + "<hr/>";

            //item.Delete(DeleteMode.HardDelete);
        }
    }

    protected void buttonCheckADLogin_Click(object sender, EventArgs e)
    {
        try
        {
            DirectoryEntry entry = new DirectoryEntry("LDAP://DC=dc,DC=capitaland,DC=com", textDomain.Text + "\\" + textLogin.Text, textPassword.Text);
            object nativeObject = entry.NativeObject;
            labelAD.Text = "Success";
        }
        catch (Exception ex)
        {
            labelAD.Text = ex.Message;
            //not authenticated due to some other exception [this is optional] 
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        Login: <asp:textbox runat="server" id="textLogin" Text="marcomcmtprod" ></asp:textbox><br />
        Password: <asp:textbox runat="server" id="textPassword" TextMode="Password" ></asp:textbox><br />
        Domain: <asp:textbox runat="server" id="textDomain" Text="dc" ></asp:textbox><br />
        <asp:button runat="server" id="buttonCheckADLogin" Text="Check AD Login" OnClick="buttonCheckADLogin_Click" />
        <asp:button runat="server" id="buttonCheck" Text="Check Email" OnClick="buttonCheck_Click" />
        <asp:Label runat="server" ID="labelAD"></asp:Label>
        <br />
        <br />
        <asp:label runat="server" id="labelMails"></asp:label>
    </div>
    </form>
</body>
</html>
