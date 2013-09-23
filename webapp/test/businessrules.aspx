<%@ Page Language="C#" %>

<%@ Import Namespace="System" %>
<%@ Import Namespace="LogicLayer" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    protected void button_Click(object sender, EventArgs e)
    {
        Hashtable h = new Hashtable();
        Hashtable h2 = new Hashtable();
        h2["CentreClosureDate"] = DateTime.Today;
        h2["Now"] = DateTime.Now.AddDays(-100);
        Hashtable h3 = BusinessRules.Execute("TenancyTermination.CheckReinstatementFeeRequired", h2, h2);
        
        label.Text ="";
        foreach (string s in h3.Keys)
        {
            if (h3[s] != null)
                label.Text += s + " = " + h3[s] + "<br/>";
            else
                label.Text += s + " = <br/>";
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
        <asp:Label runat="server" ID="label"></asp:Label>
        <br />
        <asp:Button runat="server" ID="button" OnClick="button_Click" Text="Test" />
    </div>
    </form>
</body>
</html>
