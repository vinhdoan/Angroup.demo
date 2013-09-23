<%@ Control Language="C#" ClassName="objectSearchCatalog" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.Common" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Collections"%>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="System.Web.UI" %>
<%@ Import Namespace="System.Web.UI.WebControls" %>
<%@ Import Namespace="System.ComponentModel" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<script runat="server">
   
    //if a storeID is specified, the catalog tree will return catalog items that belong to the store only
    [Localizable(false), Browsable(true)]   
    public string StoreID
    {
        get
        {
            if (ViewState["MultiCatalog_StoreID"] == null)
                return null;
            else
                return ViewState["MultiCatalog_StoreID"].ToString(); 
        }
        set
        {
            if (value == "" || value.Trim() == "")
                ViewState["MultiCatalog_StoreID"] = null;
            ViewState["MultiCatalog_StoreID"] = value;
        }
    }

    //If ContractID is specified, the catalog tree will return catalog items that belong to the contract only
    [Localizable(false), Browsable(true)]
    public string ContractID
    {
        get
        {
            if (ViewState["MultiCatalog_ContractID"] == null)
                return null;
            else
                return ViewState["MultiCatalog_ContractID"].ToString();
        }
        set
        {
            if (value == "" || value.Trim() == "")
                ViewState["MultiCatalog_ContractID"] = null;
            ViewState["MultiCatalog_ContractID"] = value;
        }
    }
    
    [Localizable(false), Browsable(true)]
    public bool IncludeBinWithZeroQty
    {
        get
        {
            try
            {
                return Convert.ToBoolean(ViewState["IncludeBinWithZeroQty"]);
            }
            catch
            {
                return false;
            }
        }
        set
        {
            ViewState["IncludeBinWithZeroQty"] = value;
        }
    }

    //if a location is specified, populate store list with store cover selected location only
    private string locationID;
    [Localizable(false), Browsable(true)]  
    public string LocationID
    {
        get
        {
            if (ViewState["MultiCatalog_LocationID"] == null)
                return null;
            else
                return ViewState["MultiCatalog_LocationID"].ToString();
        }
        set
        {
            if (value == "" || value.Trim() == "")
                ViewState["MultiCatalog_LocationID"] = null;
            ViewState["MultiCatalog_LocationID"] = value;
        }
    }


    private EnumSearchType searchType= EnumSearchType.CatalogType;
    [Localizable(false), Browsable(true)]  
    //to indicate whether it is to search for stock or catalog item. By default, set to catalog type      
    public EnumSearchType SearchType
    {
        get
        {
            return searchType;
        }
        set
        {            
            this.searchType = value;
        }
    }

    
    
    [Localizable(false), Browsable(true)]
    public string GridViewID
    {
        get
        {
            return ViewState["MultiCatalog_GridViewID"].ToString();
        }
        set
        {
            if (value == "" || value.Trim() == "")
                throw new Exception("No GridViewID have been specified for the search panel");
            ViewState["MultiCatalog_GridViewID"]  = value;
        }
    }

    private DataTable resultTable;
    //result Table from the search query
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
    public DataTable ResultTable
    {
        get
        {
            if (Session["MultipleCatalogSearch"] != null)
                return (DataTable)Session["MultipleCatalogSearch"];
            else
                return null;
        }
        set
        {
            Session["MultipleCatalogSearch"] = value;
        }
    }

    /// <summary>
    /// remove search catalog result table from session to avoid waste of memory. 
    /// </summary>
    public void DisposeControl()
    {        
        Session["MultipleCatalogSearch"]=null;
    }
    //get the gridview that store result
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
    public UIGridView GridView
    {
        get
        {
            Control c = null;
            if (NamingContainer != null)
                c = NamingContainer.FindControl(GridViewID);
            if (c == null)
                c = Page.FindControl(GridViewID);
            if (c is UIGridView)
                return (UIGridView)c;
            else
                return null;
        }
    }
    
    public enum EnumSearchType
    {
        CatalogType,
        StockType
    }
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        if(!IsPostBack)
        {
            //hide stock panel if it is catalog search type
            if (SearchType == EnumSearchType.CatalogType)
                this.panelStockType.Visible = false;
            else
                this.panelStockType.Visible = true;
            //disable the store if storeID is passed in
            if (StoreID != null)
            {
                this.ddlStoreID.SelectedIndex =
                    this.ddlStoreID.Items.IndexOf(
                    this.ddlStoreID.Items.FindByValue(StoreID));
                this.ddlStoreID.Enabled = false;        
                //populate store bin
                this.ddlStoreID_ControlChange(null, null);       
            }
            else
                this.ddlStoreID.Enabled = true;
        }
   
    }

    protected override void OnLoad(EventArgs e)
    {        
        base.OnLoad(e);
        if (!IsPostBack)
        {              
            
            //call the populateForm where developer can set various attribute for the search page such as set StoreID, LocationId
            if (PopulateForm != null)
                PopulateForm(this, new EventArgs());

            //populate store list, unit of measure list
            UnitOfMeasureID.Bind(OCode.GetCodesByType("UnitOfMeasure", null));
           
            //if a location is specified, populate store list with store cover selected location only
            if (LocationID != null && LocationID !="")
            {
                OLocation loc = TablesLogic.tLocation[new Guid(LocationID.ToString())];
                this.ddlStoreID.Bind(TablesLogic.tStore[((ExpressionDataString)loc.HierarchyPath).Like(TablesLogic.tStore.Location.HierarchyPath + "%")]);
            }
            else
                this.ddlStoreID.Bind(TablesLogic.tStore[Query.True]); 
            
        }
    }

    protected void buttonSearch_Click(object sender, EventArgs e)
    {
        //build custom condition, and bind result to the datagrid.
        //for catalog search type
        DataTable dt = new DataTable();
        string hierarchyPath ="";
        
        //Catalog treeview
        if (CatalogueID.SelectedValue != "")
        {
            OCatalogue catalogue = TablesLogic.tCatalogue[new Guid(CatalogueID.SelectedValue)];
            hierarchyPath = catalogue.HierarchyPath;
        }
        ArrayList itemCodeList = new ArrayList();
        ExpressionCondition itemCodeCond = null;
        if (this.StockCode.Text != "")
        {
            //generate a list of item code
            string[] split = StockCode.Text.Split(',');
            foreach (string s in split)
            {
                if (itemCodeCond == null)
                    itemCodeCond = TablesLogic.tCatalogue.StockCode.Like("%" + s + "%");
                else
                    itemCodeCond = itemCodeCond | TablesLogic.tCatalogue.StockCode.Like("%" + s + "%");
            }
        }
        if (SearchType == EnumSearchType.CatalogType)
        {
            ExpressionCondition contractCatalogCondition = null;
            OContract contract = null;
            if (ContractID != null && ContractID != "")
            {
                //return fixed rate under contract only
                contract = TablesLogic.tContract[new Guid(ContractID)];
                if (contract.ProvidePricingAgreement == 1)
                {
                    //retrieve all fixed rate that the contract cover
                    DataList<OContractPriceMaterial> list = contract.ContractPriceMaterials;

                    foreach (OContractPriceMaterial m in list)
                    {
                        if (contractCatalogCondition == null)
                            contractCatalogCondition = TablesLogic.tCatalogue.HierarchyPath.Like(m.Catalogue.HierarchyPath + "%");
                        else
                            contractCatalogCondition = contractCatalogCondition | TablesLogic.tCatalogue.HierarchyPath.Like(m.Catalogue.HierarchyPath + "%");
                    }
                }
                //if no pricing agreement for this contract, do not return anything
                if (contractCatalogCondition == null)
                    contractCatalogCondition = Query.False;
            }
            //if no contract specified, return everything
            else
                contractCatalogCondition = Query.True;
            
            //for catalog search type
            dt = Query.Select(TablesLogic.tCatalogue.ObjectID.As("CatalogID"), TablesLogic.tCatalogue.ObjectName.As("CatalogName"), TablesLogic.tCatalogue.StockCode.As("CatalogStockCode")
                    , TablesLogic.tCatalogue.Manufacturer.As("CatalogManufacturer"), TablesLogic.tCatalogue.Model.As("CatalogModel"), TablesLogic.tCatalogue.UnitOfMeasure.ObjectName.As("CatalogUnitOfMeasure"),
                        TablesLogic.tCatalogue.StockCode.As("StockCode"))

                    //Rachel bug fixed. Should only return those catalog belong to the contract if a contract is specified.
                    .Where((hierarchyPath == "" ? (contractCatalogCondition) : TablesLogic.tCatalogue.HierarchyPath.Like(hierarchyPath + "%")) &
                        TablesLogic.tCatalogue.ObjectName.Like("%" + this.CatalogName.Text + "%") &
                //EM customization, stock code is by a list of stock code
                        (itemCodeCond != null ? itemCodeCond : Query.True) &
                // TablesLogic.tCatalogue.StockCode.Like("%" + this.StockCode.Value + "%") &
                        TablesLogic.tCatalogue.Manufacturer.Like("%" + this.Manufacturer.Text + "%") &
                        TablesLogic.tCatalogue.Model.Like("%" + this.Model.Text + "%") &
                        (this.UnitOfMeasureID.SelectedValue != "" ? TablesLogic.tCatalogue.UnitOfMeasureID == new Guid(this.UnitOfMeasureID.SelectedValue) : Query.True) &
                        TablesLogic.tCatalogue.IsCatalogueItem == 1 &
                        TablesLogic.tCatalogue.IsDeleted == 0).OrderBy(TablesLogic.tCatalogue.ObjectName.Asc);

            //bug fixed for datagrid
            dt.Columns.Add("ObjectID");
            //add in the contract price so that we could retrieve it at the search page
            dt.Columns.Add("ContractPrice", typeof(decimal));
            int count = 0;
            foreach (DataRow row in dt.Rows)
            {
                //Build a running number for the objectID  
                row["ObjectID"] = count++;
                //set contract price if a contract is specified
                if (contract!=null)
                {
                    Guid catalogueID = new Guid(row["CatalogID"].ToString());                    
                    row["ContractPrice"] = contract.GetMaterialUnitPrice(catalogueID);
                }
            }
                
            SetDataSource(dt);
            
        }
        //for stock search type
        else if(SearchType == EnumSearchType.StockType)
        {
            OLocation loc = null;
            if (LocationID != null)
            {
             loc = TablesLogic.tLocation[new Guid(LocationID.ToString())];
            }
            dt = Query.Select(TablesLogic.tStore.StoreItems.CatalogueID.As("CatalogID"),
                   TablesLogic.tStore.StoreItems.Catalogue.ObjectName.As("CatalogName"),
                   TablesLogic.tStore.StoreItems.Catalogue.StockCode.As("CatalogStockCode"),
                    TablesLogic.tStore.StoreItems.Catalogue.Manufacturer.As("CatalogManufacturer"), TablesLogic.tStore.StoreItems.Catalogue.Model.As("CatalogModel"), TablesLogic.tStore.StoreItems.Catalogue.UnitOfMeasure.ObjectName.As("CatalogUnitOfMeasure"),
                    TablesLogic.tStore.StoreItems.Catalogue.UnitOfMeasureID.As("CatalogUnitOfMeasureID"),
                    TablesLogic.tStore.ObjectID.As("StoreID"), TablesLogic.tStore.ObjectName.As("StoreName"))
                       .Where((hierarchyPath == "" ? Query.True : TablesLogic.tStore.StoreItems.Catalogue.HierarchyPath.Like(hierarchyPath + "%")) &
                       TablesLogic.tStore.StoreItems.Catalogue.ObjectName.Like("%" + this.CatalogName.Text + "%") &
                //EM customization, stock code is search by a list of stock code
                        (StockCode.Text != "" ? TablesLogic.tStore.StoreItems.Catalogue.StockCode.In(itemCodeList) : Query.True) &
                //TablesLogic.tStore.StoreItems.Catalogue.StockCode.Like("%" + this.StockCode.Value.ToString() + "%") &
                       TablesLogic.tStore.StoreItems.Catalogue.Manufacturer.Like("%" + this.Manufacturer.Text + "%") &
                       TablesLogic.tStore.StoreItems.Catalogue.Model.Like("%" + this.Model.Text + "%") &
                       (this.UnitOfMeasureID.SelectedValue != "" ? TablesLogic.tStore.StoreItems.Catalogue.UnitOfMeasureID == new Guid(this.UnitOfMeasureID.SelectedValue) : Query.True) &
                       TablesLogic.tStore.StoreItems.Catalogue.IsDeleted == 0 &
                       TablesLogic.tStore.IsDeleted == 0 &
                       TablesLogic.tStore.StoreItems.IsDeleted == 0 &
                //if store specified, search by store
                       (this.ddlStoreID.SelectedValue != null && this.ddlStoreID.SelectedValue != "" ? TablesLogic.tStore.ObjectID == new Guid(this.ddlStoreID.SelectedValue) : Query.True) &
                //if bin specified, search by bin
                       (this.ddlBinID.SelectedValue != null && this.ddlBinID.SelectedValue != "" ? TablesLogic.tStore.StoreBins.ObjectID == new Guid(this.ddlBinID.SelectedValue) : Query.True) &
                //if location specified, search only those stores that cover the location                      
                       (loc != null ? ((ExpressionDataString)loc.HierarchyPath).Like(TablesLogic.tStore.Location.HierarchyPath + "%") : Query.True))
                       .OrderBy(TablesLogic.tStore.StoreItems.Catalogue.ObjectName.Asc, TablesLogic.tStore.ObjectName.Asc);

            //Retrieve the bin availability for each store
            DataTable stockTable = new DataTable();
            stockTable.Columns.Add("ObjectID");
            stockTable.Columns.Add("CatalogID");
            stockTable.Columns.Add("CatalogName");
            stockTable.Columns.Add("CatalogStockCode");
            stockTable.Columns.Add("CatalogManufacturer");
            stockTable.Columns.Add("CatalogModel");       
            stockTable.Columns.Add("CatalogUnitOfMeasure");
            stockTable.Columns.Add("CatalogUnitOfMeasureID");
            stockTable.Columns.Add("StoreID");
            stockTable.Columns.Add("StoreName");           
            stockTable.Columns.Add("BinID", typeof(string));
            stockTable.Columns.Add("BinName", typeof(string));
            
            
            foreach(DataRow row in dt.Rows)
            {
                DataTable binQty = OStore.FindBinsByCatalogue(new Guid(row["StoreID"].ToString()), new Guid(row["CatalogID"].ToString()), IncludeBinWithZeroQty);                                             
                
                //do not insert bin if it does not match the search bin. 
                foreach (DataRow binRow in binQty.Rows)
                {
                    if (this.ddlBinID.SelectedValue != "")
                    {
                        if (binRow["ObjectID"].ToString().Trim() == this.ddlBinID.SelectedValue)
                        {
                            //bin found. Add bin record into the stocktable
                            MergeStockTable(stockTable, row, binRow);
                            break;
                        }                            
                    }
                    else
                    {
                        //no bin specified, add all record                       
                        MergeStockTable(stockTable, row, binRow);
                    }
                }                
                                
            }

            SetDataSource(stockTable);     
        }          
        
    }
    
    
    private void SetDataSource(DataTable dt)
    {
        //set datagrid datasource
        this.ResultTable = dt;
        this.GridView.DataSource = dt;
        this.GridView.DataBind();
        GridView.SetFocus();       
    }
    protected void MergeStockTable(DataTable stockTable, DataRow catalogRow, DataRow binRow)
    {
        DataRow row = stockTable.NewRow();
        //arbitrary objectid for the gridview
        row["ObjectID"] = new Guid();
        row["CatalogID"] = catalogRow["CatalogID"];
        row["CatalogName"] = catalogRow["CatalogName"];
        row["CatalogStockCode"] = catalogRow["CatalogStockCode"];
        row["CatalogManufacturer"] = catalogRow["CatalogManufacturer"];
        row["CatalogModel"] = catalogRow["CatalogModel"];
        row["CatalogUnitOfMeasure"] = catalogRow["CatalogUnitOfMeasure"];
        row["CatalogUnitOfMeasureID"] = catalogRow["CatalogUnitOfMeasureID"];
        row["StoreID"] = catalogRow["StoreID"];
        row["StoreName"] = catalogRow["StoreName"];
        row["BinID"] = binRow["ObjectID"];
        row["BinName"] = binRow["ObjectName"];

        stockTable.Rows.Add(row);   
    }
    protected void buttonReset_Click(object sender, EventArgs e)
    {
        ClearControls(this);   
    }
    void ClearControls(Control control)
    {
        if (control.GetType().IsSubclassOf(typeof(UIFieldBase)))
        {
            ((UIFieldBase)control).ControlValue = null;            
        }
        else
        {
            foreach (Control childControl in control.Controls)
                ClearControls(childControl);
        }
    }
    //---------------------------------------------------------------    
    // event
    //---------------------------------------------------------------
    protected TreePopulater CatalogueID_AcquireTreePopulater(object sender)
    {      
        if(this.StoreID!=null)
            return new CatalogueTreePopulater(null, new Guid(StoreID), true, false);
        else if(this.ContractID!=null)
            return new CatalogueTreePopulater(null, new Guid(ContractID));
        else
            return new CatalogueTreePopulater(null, true, false);
    }

    //---------------------------------------------------------------    
    // event
    //---------------------------------------------------------------
    protected void ddlStoreID_ControlChange(object sender, EventArgs e)
    {
        if (ddlStoreID.SelectedValue == "")
            this.ddlBinID.Items.Clear();
        else
            ddlBinID.Bind(TablesLogic.tStoreBin[
                TablesLogic.tStoreBin.StoreID == new Guid(ddlStoreID.SelectedValue)]);                
            
    }
    
    
    public event EventHandler PopulateForm;
</script>
<ui:uibutton runat="server" id="buttonSearch" ImageUrl="~/images/find.gif" Text="Perform Search" OnClick="buttonSearch_Click" meta:resourcekey="buttonSearchResource1"></ui:uibutton>
 <ui:uibutton runat="server" id="buttonReset" ImageUrl="~/images/symbol-refresh-big.gif" Text="Reset All Fields" OnClick="buttonReset_Click" ConfirmText="" meta:resourcekey="buttonResetResource1"></ui:uibutton>
<br /><br /> 
<ui:UIFieldTreeList ID="CatalogueID" runat="server" Caption="Catalog" 
OnAcquireTreePopulater="CatalogueID_AcquireTreePopulater" >
</ui:UIFieldTreeList>
<ui:UIFieldTextBox runat="server" ID="CatalogName" Caption="Catalog Name" Span="half"  CaptionWidth="120px"  ToolTip="Part of the name of catalog items to search for" />
<ui:UIFieldTextBox runat="server" ID="StockCode" Span="full" Caption="Stock Code" ToolTip="To search for more than one stock code, separate the code by comma" />
<ui:UIFieldTextBox runat="server" ID="Manufacturer" Span="half" Caption="Manufacturer" ToolTip="Manufacturer of the Catalog item." />
<ui:UIFieldTextBox runat="server" ID="Model" Span="half" Caption="Model" ToolTip="Model of the Catalog item." />
<ui:UIFieldDropDownList runat="server" ID="UnitOfMeasureID" Span="full" Caption="Unit of Measure" ToolTip="Unit of measure for this Catalog item."/>                        
<ui:uipanel ID="panelStockType" runat="server">
<ui:UIFieldDropDownList runat="server" ID="ddlStoreID" Span="half" Caption="Store" ToolTip="Store of  the Catalog item." />                        
<ui:UIFieldDropDownList runat="server" ID="ddlBinID" Span="half" Caption="Bin" ToolTip="Bin of the catalog item"/>                        
</ui:uipanel>
 

