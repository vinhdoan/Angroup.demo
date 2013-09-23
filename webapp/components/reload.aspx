<%@ Page Language="C#" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">
    protected override void OnLoad(EventArgs e)
    {
        if (!IsPostBack)
        {
            base.OnLoad(e);
            OUser user = AppSession.User;
            labelDate.Text = Request["t"];
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
        <asp:label runat="server" id="labelDate"></asp:label>
    
    </div>
    </form>
</body>
</html>
