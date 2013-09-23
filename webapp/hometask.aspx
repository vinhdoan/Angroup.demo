<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" %>
<%@ Register Src="components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.Common" %>
<%@ Import Namespace="System.Globalization" %>
<%@ Import Namespace="System.Configuration" %>
<%@ Import Namespace="System.Collections" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<script runat="server">
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);

        if (!IsPostBack)
        {
            ArrayList categoryNames = new ArrayList();

            DataTable createableFunctions = OFunction.GetFunctionsCreateableByUser(AppSession.User);

            // figure out which category names we should show
            //
            foreach (DataRow dr in createableFunctions.Rows)
            {
                if (!categoryNames.Contains(dr["CategoryName"].ToString()))
                    categoryNames.Add(dr["CategoryName"].ToString());
            }
            categoryNames.Sort();

            // add the category names
            //
            foreach (string categoryName in categoryNames)
            {
                TreeNode node = new TreeNode("&nbsp; " + categoryName, "", ConfigurationManager.AppSettings["ImageUrl_TaskFolder"], "#", "");
                node.Expanded = true;
                tree.Nodes.Add(node);

                // add the individual objects
                ///
                foreach (DataRow dr in createableFunctions.Rows)
                {
                    string url = ResolveUrl(dr["EditUrl"].ToString()) +
                        "?ID=" + HttpUtility.UrlEncode(Security.Encrypt("NEW:")) +
                        "&TYPE=" + HttpUtility.UrlEncode(Security.Encrypt(dr["ObjectType"].ToString()));
                    
                    if (dr["CategoryName"].ToString() == categoryName)
                    {
                        TreeNode childNode = null;
                        childNode = new TreeNode("&nbsp; " +
                            "<a href='#' onclick='javascript:window.open(\"" + url + "\", \"AnacleEAM_Window\")'>" + dr["FunctionName"] + "</a>", "",
                            ConfigurationManager.AppSettings["ImageUrl_TaskItem"]);
                        node.ChildNodes.Add(childNode);
                    }
                }
            }
        }
    }
   

</script>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head runat="server">
    <title>Simplism.EAM</title>
</head>
    <body topmargin="0" bottommargin="0" leftmargin="0" rightmargin="0">
        <form id="form1" runat="server">
        <div id="treediv" class="div-tree" style="overflow:auto; height:800px; width:100%">
            <asp:TreeView ID="tree" runat="server"  ExpandDepth="0"  ShowLines="True" Target="_self">
                <NodeStyle Font-Names="Tahoma" Font-Size="8pt" />
                <SelectedNodeStyle BackColor="#FFFFFF" BorderColor="#00007F" BorderWidth="1" />
            </asp:TreeView>
        </div>
        </form>
    </body>
    <script type="text/javascript">
        function resizeFrame()
        {
            var theWidth, theHeight;

            if (window.innerHeight) {
            theHeight=window.innerHeight;
            }
            else if (document.documentElement && document.documentElement.clientHeight) {
            theHeight=document.documentElement.clientHeight;
            }
            else if (document.body) {
            theHeight=document.body.clientHeight;
            }

            var f = document.getElementById( "treediv" );
            
            f.style.height = theHeight + "px";
            window.setTimeout( "resizeFrame()", 50 );
        }

        window.setTimeout( "resizeFrame()", 50 );
    
    </script>
</html>
