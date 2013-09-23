<%@ Page Language="C#" Inherits="PageBase" culture="auto" meta:resourcekey="PageResource1" uiculture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">
    private string type="";
    protected void form1_Load(object sender, EventArgs e)
    {
        type = HttpUtility.UrlDecode(Security.Decrypt(Request["OBJ"]));
        if (type != "")
        {
            gridTags.DataSource = GetTagList("LogicLayer." + type);
            gridTags.DataBind();
        }
    }

    /// <summary>
    /// Generates tag list for the persistent object specified by variable 'type'
    /// </summary>
    /// <param name="objectType"></param>
    /// <returns></returns>
    public DataTable GetTagList(string objectType)
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("TagName");
        dt.Columns.Add("Description");
        dt.Columns.Add("Type");        

        DataTable table1 = dt.Clone();
        DataTable table2 = dt.Clone();
        DataTable table3 = dt.Clone();

        DataTable subTable1 = dt.Clone();
        DataTable subTable2 = dt.Clone();

        // loads properties of the specific objecttype into 3 tables:
        // table1:  all primitive-type properties, including LogicLayer persistent objects.
        // table2:  properties implement IEnumerable.
        // table3:  common Properties of LogicLayer Persistent Object,
        //          common Properties of DataFramework Persistent Object
        LoadProperty(type, null, table1, table2, table3, true);
        
        // performs classifying primitive-type properties and LogicLayer persistent objects
        // from table1
        SortProperty(dt, table1, "TagName",true);

        //tag list for IEnumerable properties.
        if (table2.Rows.Count > 0)
        {
            foreach (DataRow row in table2.Rows)
            {
                dt.Rows.Add(new object[] { row[0], row[1], row[2] });
                string[] elements = row["Type"].ToString().Split('.');
                if (row["TagName"].ToString().Contains("obj.") && elements.Length < 3 &&
                    row["Type"].ToString().Contains("IEnumerable"))
                {
                    string listItem = elements[elements.Length - 1].ToLower();
                    if (listItem.StartsWith("o"))
                        listItem = listItem.Remove(0, 1);
                    
                    if(row["TagName"].ToString().Contains("Children"))
                        listItem = "children";

                    if(row["TagName"].ToString().Contains("Parent"))
                        listItem = "parent";
                    
                    string comment = "{multiple " + listItem;
                    comment = comment + " in " + row["TagName"].ToString() + ", repeatingrow=1} {/multiple}";
                    dt.Rows.Add(new object[] { comment, "", "" });
                }
                subTable1.Rows.Clear();
                subTable2.Rows.Clear();

                //Generate tag list for each individual IEnumerable property.
                //For example: OWork.WorkCost is a DataList<OWorkCost>:
                //-- OWork.WorkCost implements the IEnumerable interface
                //-- OWork.WorkCost has a generic type OWorkCost
                //so need to generate tag list for OWorkCost. Recurse only 1 level downwards.
                
                string objType = row["Type"].ToString();
                if (objType.Contains(':'))
                {
                    string[] str = objType.Split(':')[1].Split('.');
                    objType = str[str.Length - 1];
                }

                //caters for cases whereby DataList name may not be same as class name. 
                //For example class name: OPurchaseOrderReceipt, datalist name: obj.PurchaseOrderReceipts
                string parentPropertyName = GetParentName(row["TagName"].ToString().Replace("{", "").Replace("}", ""));
                LoadProperty(objType, parentPropertyName, subTable1, subTable2, null, true);
                SortProperty(dt, subTable1, "TagName", false);
                
                //tag list for IEnumerable properties.
                if (subTable2.Rows.Count > 0)
                    foreach (DataRow dr in subTable2.Rows)
                        dt.Rows.Add(new object[] { dr[0], dr[1], dr[2] });
            }

        }
        dt.Rows.Add(new object[] { "Common Properties of LogicLayer Persistent Object", "", "" });
        SortProperty(dt, table3, "TagName",true);

        dt.Rows.Add(new object[] { "Common Properties of DataFramework Persistent Object", "", "" });
        table3.Rows.Clear();
        LoadProperty(null, null, null, null, table3, false);
        SortProperty(dt, table3, "TagName",true);
        
        return dt;
    }

    /// <summary>
    /// Perform sorting: 
    /// display primitive-typed properties before displaying LogicLayer persistent object and IEnumerable properties.
    /// </summary>
    /// <param name="mainTable"></param>
    /// <param name="table"></param>
    /// <param name="columnName"></param>
    public void SortProperty(DataTable mainTable, DataTable table, string sortColumn, bool isRecursive)
    {
        DataTable primitiveTable = table.Clone();
        primitiveTable.Clear();
        DataTable nonPrimitiveTable = primitiveTable.Clone();
        DataTable subTable1 = primitiveTable.Clone();
        DataTable subTable2 = primitiveTable.Clone();

        DataTable temp = table;
        temp.DefaultView.Sort = sortColumn;
        table = temp.DefaultView.ToTable();

        ClassifyProperty(table, primitiveTable, nonPrimitiveTable, sortColumn);

        //primitiveTable contains all properties having primitive-typed
        foreach (DataRow dr in primitiveTable.Rows)
            mainTable.Rows.Add(new object[] { dr[0], dr[1], dr[2] });

        //nonPrimitiveTable contains all properties of LogicLayer persistent object and IEnumerable properties.
        foreach (DataRow dr in nonPrimitiveTable.Rows)
        {
            mainTable.Rows.Add(new object[] { dr[0], dr[1], dr[2] });
            if (isRecursive && dr["Type"].ToString().StartsWith("O"))
            {
                string parentPropertyName = dr["TagName"].ToString();
                parentPropertyName =
                    parentPropertyName + "|" +
                    ((dr["TagName"].ToString().Contains("Parent") || dr["TagName"].ToString().Contains("Children")) ?
                    type :
                    dr["Type"].ToString().Replace("{obj.", "").Replace("}", ""));
                subTable1.Clear();
                subTable2.Clear();
                LoadProperty(dr["Type"].ToString(), parentPropertyName, subTable1, subTable2, null, true);
                SortProperty(mainTable, subTable1, sortColumn, false);

                //tag list for IEnumerable properties.
                if (subTable2.Rows.Count > 0)
                    foreach (DataRow subdr in subTable2.Rows)
                        mainTable.Rows.Add(new object[] { subdr[0], subdr[1], subdr[2] });
            }
        }
    }

    /// <summary>
    /// Classifies primitive-typed properties into primitiveTable
    /// and LogicLayer persistent objects and IEnumerable properties into nonPrimitiveTable.
    /// </summary>
    /// <param name="sourceTable"></param>
    /// <param name="primitiveTable"></param>
    /// <param name="nonPrimitiveTable"></param>
    /// <param name="sortColumn"></param>
    protected void ClassifyProperty(DataTable sourceTable, DataTable primitiveTable, DataTable nonPrimitiveTable, string sortColumn)
    {
        foreach (DataRow dr in sourceTable.Rows)
        {
            if (!dr["Type"].ToString().StartsWith("O") && !dr["Type"].ToString().StartsWith("IEnumerable"))
                primitiveTable.Rows.Add(new object[] { dr[0], dr[1], dr[2] });
            else
                nonPrimitiveTable.Rows.Add(new object[] { dr[0], dr[1], dr[2] });
        }
    }
    
    /// <summary>
    /// Retrieves property name that this current property belongs to.
    /// </summary>
    /// <param name="value"></param>
    /// <returns></returns>
    protected string GetParentName(string value)
    {
        string[] str = value.Split(',')[0].Split(' ');
        return str[str.Length - 1];
    }
   
    /// <summary>
    /// Loads properties of specific objectType and 
    /// common properties of DataFramework and LogicLayerPersistentObject
    /// from xml files.
    /// </summary>
    /// <param name="objectType"></param>
    /// <param name="parentPropertyName"></param>
    /// <param name="table1"></param>
    /// <param name="table2"></param>
    /// <param name="table3"></param>
    /// <param name="isLogicLayerObject"></param>
    public void LoadProperty(string objectType, string parentPropertyName, DataTable table1, DataTable table2, DataTable table3, bool isLogicLayerObject)
    {
        XmlNodeReader reader = null;
        
        try
        {
            string filePath = "";
            
            // The xml document to read from.
            XmlDocument doc = new XmlDocument();

            // Load the xml document.
            if (isLogicLayerObject)
                filePath = Request.ApplicationPath + "/documenttag/LogicLayer.xml";
            else
                filePath = Request.ApplicationPath + "/documenttag/Anacle.xml";
            doc.Load(Server.MapPath(filePath));
            
            // Set the reader to open the xml document.
            reader = new XmlNodeReader(doc);

            XmlNodeList list = null;
            list = doc.GetElementsByTagName("member");
            foreach (XmlNode node in list)
            {
                if (node.NodeType == XmlNodeType.Element)
                {
                    if (isLogicLayerObject)
                    {
                        //only retrieve properties of the respective class specified by objectType parameter.
                        if (node.OuterXml.Contains("P:"))
                            ODocumentTemplate.GetPropertyByObjectType(node, objectType, type, parentPropertyName, table1, table2);
                        if (table3 != null && node.OuterXml.Contains("P:LogicLayer.LogicLayerPersistentObject"))
                            ODocumentTemplate.LoadCommonProperty(node, "LogicLayerPersistentObject", table3, isLogicLayerObject);
                    }
                    else
                        if (node.OuterXml.Contains("P:Anacle.DataFramework.PersistentObject"))
                            ODocumentTemplate.LoadCommonProperty(node, "PersistentObject", table3, isLogicLayerObject);
                }
            }         
        }
        finally
        {
            // Do the necessary clean up.
            if (reader != null)
                reader.Close();
        }
    }

    /// <summary>
    /// Formats background and text color.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gridTags_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            int elements = e.Row.Cells[0].Text.Split('.').Length;
            if (elements <3 && e.Row.Cells[0].Text.Contains("obj") &&
                (e.Row.Cells[2].Text.StartsWith("O") || e.Row.Cells[2].Text.Contains("IEnumerable:LogicLayer")))
            {
                e.Row.BackColor = System.Drawing.Color.MistyRose;
                e.Row.ForeColor = System.Drawing.Color.SaddleBrown;
            }
            
            if (e.Row.Cells[0].Text.Contains("Common Properties"))
            {
                e.Row.BackColor = System.Drawing.Color.DarkOrange;
                e.Row.Height = 30;
                e.Row.Font.Size = 10;
                e.Row.ForeColor = System.Drawing.Color.White;
                e.Row.Cells[0].ColumnSpan = 3;
                e.Row.Cells.RemoveAt(1);
                e.Row.Cells.RemoveAt(1);
            }
        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server" onload="form1_Load">
    <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
        meta:resourcekey="panelMainResource1" >
    <div class="div-main">
        <ui:UITabStrip runat="server" ID="tabObject" BorderStyle="NotSet" 
            meta:resourcekey="tabObjectResource1">
            <ui:UITabView ID="tabDetails" runat="server" Caption="Details" 
                BorderStyle="NotSet" meta:resourcekey="tabDetailsResource1">
                <asp:GridView runat="server" ID="gridTags" Caption="Document tags" Width="90%" 
                    AutoGenerateColumns="False" OnRowDataBound="gridTags_RowDataBound" 
                    meta:resourcekey="gridTagsResource1">
                    <Columns>
                        <asp:BoundField DataField="TagName" HeaderText="Tag name" 
                            meta:resourcekey="BoundFieldResource1" />
                        <asp:BoundField DataField="Description" HeaderText="Description" 
                            meta:resourcekey="BoundFieldResource2" />
                        <asp:BoundField DataField="Type" HeaderText="Type" 
                            meta:resourcekey="BoundFieldResource3" />
                    </Columns>
                </asp:GridView>
            </ui:UITabView>
        </ui:UITabStrip>
    </div>
     </ui:UIObjectPanel>
    </form>
</body>
</html>
