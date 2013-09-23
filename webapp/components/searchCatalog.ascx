<%@ Control Language="C#" ClassName="searchCatalog" %>
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
    


    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        if (!IsPostBack)
        {
            treeCatalogue.PopulateTree();
            UnitOfMeasureID.Bind(OCode.GetCodesByType("UnitOfMeasure", null));
        }
    }

    
    //---------------------------------------------------------------    
    // event
    //---------------------------------------------------------------
    protected TreePopulater treeCatalogue_AcquireTreePopulater(object sender)
    {
        if (this.ContractID != null)
            return new CatalogueTreePopulater(null, new Guid(ContractID));
        else
            return new CatalogueTreePopulater(null, true, false, true, true);
    }


    /// <summary>
    /// Constructs and returns a custom condition.
    /// </summary>
    /// <returns></returns>
    public ExpressionCondition GetCustomCondition()
    {
        // Construct a condition that searches based on a comma-separated list
        // of item code.
        //
        ExpressionCondition stockCodeCondition = Query.True;
        if (this.textStockCode.Text != "")
        {
            stockCodeCondition = Query.False;
            string[] split = textStockCode.Text.Split(',');
            foreach (string s in split)
            {
                if (stockCodeCondition == null)
                    stockCodeCondition = TablesLogic.tCatalogue.StockCode.Like("%" + s.Trim() + "%");
                else
                    stockCodeCondition = stockCodeCondition | TablesLogic.tCatalogue.StockCode.Like("%" + s.Trim() + "%");
            }
        }


        /// Constructs the condition that includes only 
        /// items specified in the contract's 
        /// purchase agreement.
        /// 
        ExpressionCondition contractCatalogCondition = Query.True;
        if (ContractID != null && ContractID != "")
        {
            contractCatalogCondition = null;
            //return fixed rate under contract only
            OContract contract = TablesLogic.tContract[new Guid(ContractID)];
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
        
        // Construct the hierarcypath search
        // if catalogue tree is selected.
        //
        ExpressionCondition catalogHierarchyCondition = Query.True;
        if (treeCatalogue.SelectedValue != "")
        {
            Guid catalogId = new Guid(treeCatalogue.SelectedValue);
            OCatalogue catalogue = TablesLogic.tCatalogue.Load(catalogId);
            if (catalogue != null)
                catalogHierarchyCondition = TablesLogic.tCatalogue.HierarchyPath.Like(catalogue.HierarchyPath + "%");
        }

        return
            stockCodeCondition & 
            contractCatalogCondition & 
            catalogHierarchyCondition &
            TablesLogic.tCatalogue.IsCatalogueItem == 1;
    }
</script>
<ui:UIFieldTreeList ID="treeCatalogue" runat="server" Caption="Catalog" 
OnAcquireTreePopulater="treeCatalogue_AcquireTreePopulater" 
    meta:resourcekey="treeCatalogueResource1" ShowCheckBoxes="None" 
    TreeValueMode="SelectedNode" >
</ui:UIFieldTreeList>
<ui:UIFieldTextBox runat="server" ID="CatalogName" PropertyName="ObjectName" 
    Caption="Catalog Name" Span="Half"  
    ToolTip="Part of the name of catalog items to search for" 
    InternalControlWidth="95%" meta:resourcekey="CatalogNameResource1" />
<ui:UIFieldTextBox runat="server" ID="textStockCode" Caption="Stock Code" 
    ToolTip="To search for more than one stock code, separate the code by comma" 
    InternalControlWidth="95%" meta:resourcekey="textStockCodeResource1" />
<ui:UIFieldTextBox runat="server" ID="Manufacturer" Span="Half" 
    PropertyName="Manufacturer" Caption="Manufacturer" 
    ToolTip="Manufacturer of the Catalog item." InternalControlWidth="95%" 
    meta:resourcekey="ManufacturerResource1" />
<ui:UIFieldTextBox runat="server" ID="Model" Span="Half" Caption="Model" 
    PropertyName="Model" ToolTip="Model of the Catalog item." 
    InternalControlWidth="95%" meta:resourcekey="ModelResource1" />
<ui:UIFieldDropDownList runat="server" ID="UnitOfMeasureID" 
    PropertyName="UnitOfMeasureID" Caption="Unit of Measure" 
    ToolTip="Unit of measure for this Catalog item." 
    meta:resourcekey="UnitOfMeasureIDResource1"/>                        
 

