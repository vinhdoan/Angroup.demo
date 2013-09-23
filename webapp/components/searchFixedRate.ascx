<%@ Control Language="C#" ClassName="searchFixedRate" %>
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
            treeFixedRate.PopulateTree();
            UnitOfMeasureID.Bind(OCode.GetCodesByType("UnitOfMeasure", null));
        }
    }

    
    //---------------------------------------------------------------    
    // event
    //---------------------------------------------------------------
    protected TreePopulater treeFixedRate_AcquireTreePopulater(object sender)
    {
        if (this.ContractID != null)
            return new FixedRateTreePopulater(null, new Guid(ContractID));
        else
            return new FixedRateTreePopulater(null, true, false);
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
                    stockCodeCondition = TablesLogic.tFixedRate.ItemCode.Like("%" + s.Trim() + "%");
                else
                    stockCodeCondition = stockCodeCondition | TablesLogic.tFixedRate.ItemCode.Like("%" + s.Trim() + "%");
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
                        contractCatalogCondition = TablesLogic.tFixedRate.HierarchyPath.Like(m.Catalogue.HierarchyPath + "%");
                    else
                        contractCatalogCondition = contractCatalogCondition | TablesLogic.tFixedRate.HierarchyPath.Like(m.Catalogue.HierarchyPath + "%");
                }
            }
            //if no pricing agreement for this contract, do not return anything
            if (contractCatalogCondition == null)
                contractCatalogCondition = Query.False;
        }
        
        // Construct the hierarcypath search
        // if catalogue tree is selected.
        //
        ExpressionCondition fixedRateHierarchyCondition = Query.True;
        if (treeFixedRate.SelectedValue != "")
        {
            Guid catalogId = new Guid(treeFixedRate.SelectedValue);
            OFixedRate fixedRate = TablesLogic.tFixedRate.Load(catalogId);
            if (fixedRate != null)
                fixedRateHierarchyCondition = TablesLogic.tFixedRate.HierarchyPath.Like(fixedRate.HierarchyPath + "%");
        }

        ExpressionCondition UOMCondition = Query.True;
        if (UnitOfMeasureID.SelectedValue != "")
        {
            Guid UOMID = new Guid(UnitOfMeasureID.SelectedValue);
            if (UOMID != null)
                UOMCondition = TablesLogic.tFixedRate.UnitOfMeasureID == UOMID;
        }

        ExpressionCondition NameCondition = Query.True;
        if (Name.Text != "")
        {
            NameCondition = TablesLogic.tFixedRate.ObjectName.Like("%"+Name.Text.Trim()+"%");
        }
        
        ExpressionCondition LongDescriptionCondition = Query.True;
        if (LongDescription.Text != "")
        {
            LongDescriptionCondition = TablesLogic.tFixedRate.LongDescription.Like("%" + LongDescription.Text.Trim() + "%");
        }
        
        return
            stockCodeCondition & 
            contractCatalogCondition & 
            fixedRateHierarchyCondition &
            UOMCondition & 
            NameCondition &
            LongDescriptionCondition &
            TablesLogic.tFixedRate.IsFixedRate == 1;
    }
</script>
<ui:UIFieldTreeList ID="treeFixedRate" runat="server" Caption="Fixed Rate" 
    OnAcquireTreePopulater="treeFixedRate_AcquireTreePopulater" 
    meta:resourcekey="treeFixedRateResource1" ShowCheckBoxes="None" 
    TreeValueMode="SelectedNode" >
</ui:UIFieldTreeList>
<ui:UIFieldTextBox runat='server' ID='Name' Caption="Name"  
    ToolTip="The checklist response set as displayed on screen." 
    InternalControlWidth="95%" meta:resourcekey="NameResource1"  />
<ui:UIFieldTextBox runat='server' ID='LongDescription' 
    Caption="Long Description" InternalControlWidth="95%" 
    meta:resourcekey="LongDescriptionResource1"  />
<ui:UIFieldDropDownList runat='server' ID='UnitOfMeasureID' 
    Caption="Unit of Measure" meta:resourcekey="UnitOfMeasureIDResource1"  />
<ui:UIFieldTextBox runat="server" ID="textStockCode" Caption="Item Code" 
    ToolTip="To search for more than one item code, separate the code by comma" 
    InternalControlWidth="95%" meta:resourcekey="textStockCodeResource1" />
 
