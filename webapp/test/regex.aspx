<%@ Page Language="C#" Inherits="System.Web.UI.Page" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
                           
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
    }

    protected void PerformMatchButton_Click(object sender, EventArgs e)
    {
        Regex r = new Regex(RegexPatternTextBox.Text, RegexOptions.Multiline);
        Match m = r.Match(ContentTextBox.Text);

        OutputLabel.Text = "";
        int count = 0;
        foreach (Group g in m.Groups)
        {
            if (g.Success)
                OutputLabel.Text += "Group " + (count++) + " Index " + g.Index + ": " + g.Value + "<br/>";
        }
    }
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        Regex Pattern:
        <asp:TextBox runat='server' ID="RegexPatternTextBox" Width="400px"></asp:TextBox>
        <br />
        <br />
        Search Content:
        <asp:TextBox runat='server' ID="ContentTextBox" Width="400px" Rows="8" TextMode="MultiLine"></asp:TextBox>
        <br />
        <br />
        <asp:Button runat='server' ID="PerformMatchButton" Text="Perform Match" OnClick="PerformMatchButton_Click" />
        <br />
        <br />
        <asp:Label runat="server" ID="OutputLabel"></asp:Label>
    </div>
    </form>
</body>
</html>
