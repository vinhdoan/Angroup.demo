<%@ Page Language="C#" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<meta http-equiv="pragma" content="no-cache" />

<%@ Import Namespace="System.Collections.Generic" %>

<script runat="server">

    //------------------------------------------------------------
    // code to load the tree
    //------------------------------------------------------------
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            new CatalogueTreePopulater(null, new Guid(), true, false).Populate(treeview);
        }
    }

    protected void treeview_TreeNodePopulate(object sender, TreeNodeEventArgs e)
    {
        TreePopulater.AddTreeNodes( e.Node,
            new CatalogueTreePopulater(null, new Guid(), true, false).GetChildrenNodes(e.Node.Value));
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
    <head runat="server">
        <title>Simplism.EAM</title>
    </head>
    <body>
        <form id="form1" runat="server">
        <div>
            <asp:TreeView ID="treeview" runat="server"  ExpandDepth="0"  ShowLines="True" OnTreeNodePopulate="treeview_TreeNodePopulate" Target="_self">
                <NodeStyle Font-Names="Tahoma" Font-Size="8pt" />
                <SelectedNodeStyle BackColor="#FFFFFF" BorderColor="#00007F" BorderWidth="1" />
            </asp:TreeView>
        </div>
        </form>
    </body>
</html>

