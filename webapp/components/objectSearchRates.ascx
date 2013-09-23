<%@ Control Language="C#" ClassName="objectSearchRates" %>
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
    [Localizable(false), Browsable(true)]
    public string ContractID
    {
        get
        {
            if (ViewState["MultiFixedRate_ContractID"] == null)
                return null;
            else
                return ViewState["MultiFixedRate_ContractID"].ToString();
        }
        set
        {
            if (value == "" || value.Trim() == "")
                ViewState["MultiFixedRate_ContractID"] = null;
            ViewState["MultiFixedRate_ContractID"] = value;
        }
    }

    [Localizable(false), Browsable(true)]
    public string GridViewID
    {
        get
        {
            return ViewState["MultiFixedRate_GridViewID"].ToString();
        }
        set
        {
            if (value == "" || value.Trim() == "")
                throw new Exception("No GridViewID have been specified for the search panel");
            ViewState["MultiFixedRate_GridViewID"] = value;
        }
    }

    private DataTable resultTable;
    //result Table from the search query
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
    public DataTable ResultTable
    {
        get
        {
            if (Session["MultipleRateSearch"] != null)
                return (DataTable)Session["MultipleRateSearch"];
            else
                return null;
        }
        set
        {
            Session["MultipleRateSearch"] = value;
        }
    }

    /// <summary>
    /// remove search catalog result table from session to avoid waste of memory. 
    /// </summary>
    public void DisposeControl()
    {        
        Session["MultipleRateSearch"]=null;
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
           
            
        }
    }

    protected void buttonSearch_Click(object sender, EventArgs e)
    {
        string hierarchyPath = "";

        //Fixed rate treeview
        if (FixedRateID.SelectedValue != "")
        {
            OFixedRate fx = TablesLogic.tFixedRate[new Guid(this.FixedRateID.SelectedValue)];
            hierarchyPath = fx.HierarchyPath;
        }
        ArrayList itemCodeList = new ArrayList();
        ExpressionCondition itemCodeCond = null;
        if (this.ItemCode.Text != "")
        {
            //generate a list of item code
            string[] split = ItemCode.Text.Split(',');
            foreach (string s in split)
            {
                if (itemCodeCond == null)
                    itemCodeCond = TablesLogic.tFixedRate.ObjectNumber.Like("%" + s + "%");
                else
                    itemCodeCond = itemCodeCond | TablesLogic.tFixedRate.ObjectNumber.Like("%" + s + "%");
            }
        }
        
        //build custom condition, and bind result to the datagrid.
        DataTable dt= new DataTable();        
        
        ExpressionCondition cond =    
        (hierarchyPath == "" ? Query.True : TablesLogic.tFixedRate.HierarchyPath.Like(hierarchyPath + "%")) &
            TablesLogic.tFixedRate.ObjectName.Like("%" + this.Name.Text + "%") &
            TablesLogic.tFixedRate.LongDescription.Like("%" + this.LongDescription.Text + "%") &
            (this.UnitOfMeasureID.SelectedValue != "" ? TablesLogic.tFixedRate.UnitOfMeasureID == new Guid(this.UnitOfMeasureID.SelectedValue) : Query.True) &
            TablesLogic.tFixedRate.IsFixedRate == 1 &
            TablesLogic.tFixedRate.IsDeleted == 0 & (itemCodeCond != null ? itemCodeCond : Query.True);
           
         OContract contract =null;
        if (ContractID != null && ContractID != "")
        {                   
            //return fixed rate under contract only
          contract = TablesLogic.tContract[new Guid(ContractID)];
            if (contract.ProvidePricingAgreement == 1)
            {
                //retrieve all fixed rate that the contract cover
                DataList<OContractPriceService> list = contract.ContractPriceServices;
                ExpressionCondition contractCond = null;
                foreach (OContractPriceService m in list)
                {
                    if(contractCond ==null)
                        contractCond = TablesLogic.tFixedRate.HierarchyPath.Like(m.FixedRate.HierarchyPath + "%"); 
                    else
                        contractCond = contractCond | TablesLogic.tFixedRate.HierarchyPath.Like(m.FixedRate.HierarchyPath + "%"); 
                }
                //if no pricing agreement for this contract, do not return anything
                if (contractCond == null)
                    contractCond = Query.False;
                cond = cond & (contractCond);
            }
                   
        }
        
        
        dt = Query.Select(TablesLogic.tFixedRate.ObjectID, TablesLogic.tFixedRate.ObjectID.As("FixedRateID"), TablesLogic.tFixedRate.ObjectName.As("FixedRateName"),
        TablesLogic.tFixedRate.UnitOfMeasure.ObjectName.As("FixedRateUnitOfMeasure"), TablesLogic.tFixedRate.LongDescription.As("FixedRateLongDescription"), TablesLogic.tFixedRate.ObjectNumber.As("ItemCode"))
        .Where(cond).OrderBy(TablesLogic.tFixedRate.ObjectName.Asc);
        //add in contract price for the fixed rate so the system dont' have to retrive it at the main pop up page
        dt.Columns.Add("ContractPrice", typeof(decimal));        
        foreach (DataRow row in dt.Rows)
        {
            //set contract price if a contract is specified
            if (contract != null)
            {
                Guid fixRateID = new Guid(row["FixedRateID"].ToString());
                
                row["ContractPrice"] = contract.GetServiceUnitPrice(fixRateID);
            }
        }
        SetDataSource(dt);        
      
        
    }
    private void SetDataSource(DataTable dt)
    {
        //set datagrid datasource
        this.ResultTable = dt;
        this.GridView.DataSource = dt;
        this.GridView.DataBind();
        GridView.SetFocus();       
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
    protected TreePopulater FixedRateID_AcquireTreePopulater(object sender)
    {           
        if(this.ContractID!=null)
            return new FixedRateTreePopulater(null, new Guid(ContractID), true);
        else
            return new FixedRateTreePopulater(null, true, true);
    }    
    
    public event EventHandler PopulateForm;
</script>
<ui:uibutton runat="server" id="buttonSearch" ImageUrl="~/images/find.gif" Text="Perform Search" OnClick="buttonSearch_Click" meta:resourcekey="buttonSearchResource1"></ui:uibutton>
 <ui:uibutton runat="server" id="buttonReset" ImageUrl="~/images/symbol-refresh-big.gif" Text="Reset All Fields" OnClick="buttonReset_Click" ConfirmText="" meta:resourcekey="buttonResetResource1"></ui:uibutton>
<br /><br /> 
<ui:UIFieldTreeList ID="FixedRateID" runat="server" Caption="Fixed Rate" 
OnAcquireTreePopulater="FixedRateID_AcquireTreePopulater" >
</ui:UIFieldTreeList>
<ui:UIFieldTextBox runat='server' ID='Name' Caption="Name"  CaptionWidth="120px"  ToolTip="The checklist response set as displayed on screen."  />
<ui:UIFieldTextBox runat='server' ID='LongDescription' Caption="Long Description"  CaptionWidth="120px"  />
<ui:UIFieldDropDownList runat='server' ID='UnitOfMeasureID' Caption="Unit of Measure"  CaptionWidth="120px"  />
<ui:UIFieldTextBox runat="server" ID="ItemCode" Caption="Item Code" Span="full" ToolTip="To search for more than one item code, separate the code by comma" />

 

