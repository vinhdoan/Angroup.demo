<%@ Page Language="C#" Inherits="PageBase" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div align='center'>
        <br />
        <br />
        <br />
        <br />
        <br />
        <div style="width: 400px">
            <asp:Label runat="server" ID="labelStaleObjectError">
The item that you are editing is no longer valid. 
<br />
<br />
This could have happened if you opened multiple windows and then tried to perform some editing, saving or other operations. For a better experience, please avoid doing that in the future.
            </asp:Label>
        </div>
    </div>
    </form>
</body>
</html>
