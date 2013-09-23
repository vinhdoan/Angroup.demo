<%@ Page Language="C#" Inherits="PageBase" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<script runat="server">

</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Untitled Page</title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <ui:UITabStrip runat="server" ID="tabstrip">
            <ui:UITabView runat="server" ID="tabDetails" Caption="Details">
                This is the details tab.
            </ui:UITabView>
            <ui:UITabView runat="server" ID="tabMemo" Caption="Memo">
                This is the memo tab.
            </ui:UITabView>
            <ui:UITabView runat="server" ID="tabAttachment" Caption="Attachments">
                This is the attachment tab.
            </ui:UITabView>
        </ui:UITabStrip>
    </div>
    </form>
</body>
</html>
