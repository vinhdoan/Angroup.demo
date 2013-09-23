<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<meta http-equiv="pragma" content="no-cache" />

<script runat="server">    
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        this.messageDiv.Visible = labelMessage.Text != "";
        //set unit price title for it to contract price. EM customization
        if (Request["ContractID"] != null)
            gridPurchaseOrder.Grid.Columns[5].HeaderText = "Contract Price";
        //EM. Hide unit price, tax code if it is from quotation
        if (Request["Quotation"] != null)
        {
            gridPurchaseOrder.Grid.Columns[4].Visible = false;

        }
    }
    //A large number used for the object that required Item Order number. we set it to high value so that it will
    //always added at the end of the item list in the main page
    private int ItemNumberIncrementor = 1000000;

    /// <summary>
    /// TODO: build result table to return to the parent page. 
    /// </summary>
    /// <param name="type"></param>
    private void BuildTable(MassAdditionObjectType type)
    {
        DataTable dt = new DataTable();
        //default ObjectID column to avoid the bug in datagrid. This column usually contain meaningless information        
        dt.Columns.Add("ObjectID");
        dt.Columns.Add("FixedRateID");
        dt.Columns.Add("FixedRateName");

        switch (type)
        {
            case MassAdditionObjectType.PurchaseRequest:
                BuildPurchaseRequestTable(dt);
                break;
            case MassAdditionObjectType.RequestForQuotation:
                BuildRequestForQuotationTable(dt);
                break;
            case MassAdditionObjectType.PurchaseOrder:
                BuildPurchaseOrderTable(dt);
                break;
        }
        _returnTable = dt;
    }
    private void BuildPurchaseRequestTable(DataTable dt)
    {
        dt.Columns.Add("CatalogueID");
        dt.Columns.Add("QuantityRequired");
        dt.Columns.Add("ItemNumber");
        dt.Columns.Add("ItemType");
    }
    private void BuildRequestForQuotationTable(DataTable dt)
    {
        dt.Columns.Add("CatalogueID");
        dt.Columns.Add("QuantityRequired");
        dt.Columns.Add("ItemNumber");
        dt.Columns.Add("ItemType");
    }
    private void BuildPurchaseOrderTable(DataTable dt)
    {
        dt.Columns.Add("CatalogueID");
        dt.Columns.Add("UnitPrice");
        dt.Columns.Add("QuantityOrdered");
        dt.Columns.Add("TaxCodeID");
        dt.Columns.Add("ItemNumber");
        dt.Columns.Add("ItemType");
        dt.Columns.Add("ReceiptMode");
        dt.Columns.Add("ItemJustification");
    }
    /// <summary>
    /// TODO: Build data for a row to add into the Return table to be returned to parent page
    /// </summary>
    /// <param name="returnRow"></param>
    /// <param name="resultRow"></param>
    /// <param name="gridViewRow"></param>
    /// <returns></returns>
    private bool BuildReturnRowData(DataRow returnRow, DataRow resultRow, GridViewRow gridViewRow)
    {
        //initialize objectID avoid the bug in datagrid
        //3 columns applicable for all cases
        returnRow["ObjectID"] = resultRow["ObjectID"];
        returnRow["FixedRateID"] = resultRow["FixedRateID"];
        returnRow["FixedRateName"] = resultRow["FixedRateName"];

        bool validate = true;

        switch (ObjectType)
        {

            case MassAdditionObjectType.PurchaseRequest:
                if (!BuildPurchaseRequestRow(returnRow, resultRow, gridViewRow))
                    validate = false;
                break;
            case MassAdditionObjectType.RequestForQuotation:
                if (!BuildRequestForQuotationRow(returnRow, resultRow, gridViewRow))
                    validate = false;
                break;
            case MassAdditionObjectType.PurchaseOrder:
                if (!BuildPurchaseOrderRow(returnRow, resultRow, gridViewRow))
                    validate = false;
                break;

        }
        return validate;
    }
    private bool BuildPurchaseRequestRow(DataRow returnRow, DataRow resultRow, GridViewRow gridViewRow)
    {
        bool validate = true;

        returnRow["ItemNumber"] = ItemNumberIncrementor++;
        returnRow["ItemType"] = 1;
        //Quantity
        UIFieldTextBox ValueOfQuatityRequired = (UIFieldTextBox)gridViewRow.FindControl("PurchaseRequestQuantityRequired");
        string message = ValueOfQuatityRequired.Validate();
        if (message != null)
        {
            ValueOfQuatityRequired.ErrorMessage = message;
            validate = false;
        }
        else
        {
            returnRow["QuantityRequired"] = ValueOfQuatityRequired.Text;
        }
        return validate;
    }
    private bool BuildRequestForQuotationRow(DataRow returnRow, DataRow resultRow, GridViewRow gridViewRow)
    {
        bool validate = true;

        returnRow["ItemNumber"] = ItemNumberIncrementor++;
        returnRow["ItemType"] = 1;
        //Quantity
        UIFieldTextBox ValueOfQuotationQuatityRequired = (UIFieldTextBox)gridViewRow.FindControl("QuotationQuantityRequired");
        string message = ValueOfQuotationQuatityRequired.Validate();
        if (message != null)
        {
            ValueOfQuotationQuatityRequired.ErrorMessage = message;
            validate = false;
        }
        else
        {
            returnRow["QuantityRequired"] = ValueOfQuotationQuatityRequired.Text;
        }

        return validate;
    }
    private bool BuildPurchaseOrderRow(DataRow returnRow, DataRow resultRow, GridViewRow gridViewRow)
    {
        bool validate = true;

        returnRow["ItemNumber"] = ItemNumberIncrementor++;
        returnRow["ItemType"] = 1;

        string message = null;
        //EM. NO unit price, tax code for quotation
        if (Request["Quotation"] == null)
        {
            //UnitPrice
            /*UIFieldTextBox ValueOfUnitPrice = (UIFieldTextBox)gridViewRow.FindControl("UnitPrice");
            message = ValueOfUnitPrice.Validate();
            if (message != null)
            {
                ValueOfUnitPrice.ErrorMessage = message;
                validate = false;
            }
            else
            {
               
            }*/
            returnRow["UnitPrice"] = resultRow["ContractPrice"];
            //item justification
            UIFieldTextBox ItemJustificationValue = (UIFieldTextBox)gridViewRow.FindControl("ItemJustification");
            message = ItemJustificationValue.Validate();
            if (message != null)
            {
                ItemJustificationValue.ErrorMessage = message;
                validate = false;
            }
            else
            {
                returnRow["ItemJustification"] = ItemJustificationValue.Text;
            }

            //TaxCodeID      

            /* UIFieldDropDownList TaxCode = (UIFieldDropDownList)gridViewRow.FindControl("TaxCode");
             message = TaxCode.Validate();
             if (message != null)
             {
                 TaxCode.ErrorMessage = message;
                 validate = false;
             }
             else
             {
                 returnRow["TaxCodeID"] = TaxCode.Value;
             }*/
        }
        //Receipt Mode
        UIFieldRadioList ValueOfReceiptMode = (UIFieldRadioList)gridViewRow.FindControl("ReceiptMode");

        message = ValueOfReceiptMode.Validate();
        if (message != null)
        {
            ValueOfReceiptMode.ErrorMessage = message;
            validate = false;
        }
        else
        {
            returnRow["ReceiptMode"] = ValueOfReceiptMode.SelectedValue;


        }
        //Quantity
        UIFieldTextBox ValueOfPurchaseOrderQuatityRequired = (UIFieldTextBox)gridViewRow.FindControl("PurchaseOrderQuantityOrdered");
        message = ValueOfPurchaseOrderQuatityRequired.Validate();
        if (message != null)
        {
            ValueOfPurchaseOrderQuatityRequired.ErrorMessage = message;
            validate = false;
        }
        else
        {
            returnRow["QuantityOrdered"] = ValueOfPurchaseOrderQuatityRequired.Text;
        }

        return validate;
    }
    protected void fixedrateSearch_PopulateForm(object sender, EventArgs e)
    {
        //Initialize setting of the page here. 
        fixedrateSearch.GridViewID = GridViewID;
        if (Request["ContractID"] != null)
            fixedrateSearch.ContractID = Security.Decrypt(Request["ContractID"]);
    }
    //populate addition data for each row if necessary        
    protected void gridPurchaseOrder_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //populate TaxtCode
            /*  UIFieldDropDownList taxtCodeList = (UIFieldDropDownList)e.Row.Cells[1].FindControl("TaxCode");
              taxtCodeList.Bind(OTaxCode.GetAllTaxCodes());
              OTaxCode currentTax = OTaxCode.GetCurrentTaxCode();
              if(currentTax!=null)
                  taxtCodeList.Value = currentTax.ObjectID;
  */

        }

    }
    #region INITIALIZATION
    //private DataTable to store the return result for each of the object Type   
    private DataTable _returnTable = null;
    private string _gridViewID;

    protected void buttonAdd_Click(object sender, EventArgs e)
    {
        //Clear error message before proceed
        this.formMain.ClearErrorMessages();
        //retrieve the original result of the gridCheckIn
        DataTable resultTb = this.fixedrateSearch.ResultTable;

        if (resultTb != null && resultTb.Rows.Count > 0)
        {
            bool hasChecked = false;
            bool success = true;

            //loop through each row in the grid, and if the row is selected, bind the row value into the datatable
            foreach (GridViewRow row in MainGrid.Rows)
            {

                for (int i = 0; i < row.Cells[0].Controls.Count; i++)
                {
                    //find the select checkbox
                    if (row.Cells[0].Controls[i] is CheckBox)
                        if (((CheckBox)row.Cells[0].Controls[i]).Checked)
                        {
                            hasChecked = true;
                            //Rachel. Use row index instead of DataItemIndex as datakeys is generated for the currently in view grid page, not for the whole grid
                            if (row.RowIndex < MainGrid.DataKeys.Count)
                            {
                                //Create new row of the ReturnTable that will be used to pass back to the parent page.
                                DataRow returnRow = this.ReturnTable.NewRow();

                                //Get the corresponding row in the original result dataset, base on the data key                                
                                DataRow resultRow = null;

                                foreach (DataRow r in resultTb.Rows)
                                {
                                    //Rachel. Use row index instead of DataItemIndex as datakeys is generated for the currently in view grid page, not for the whole grid
                                    if (r["ObjectID"].ToString() == MainGrid.DataKeys[row.RowIndex][0].ToString())
                                    {
                                        resultRow = r;
                                        break;
                                    }
                                }

                                if (!BuildReturnRowData(returnRow, resultRow, row))
                                {
                                    success = false;
                                }
                                else
                                {
                                    ReturnTable.Rows.Add(returnRow);
                                }
                                //checkbox found, break
                                break;
                            }
                        }
                }
            }
            if (!hasChecked)
                this.labelMessage.Text = Resources.Errors.Multiple_SelectItem;
            //only proceed to return table if there is no error
            else if (success)
            {
                //Remember to Destroy the catalog search once this is done to avoid waste of memory
                this.fixedrateSearch.DisposeControl();
                Window.ReturnDataTable(this, ReturnTable);
            }
        }
    }

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        //build Datatable and set visibility of the grid based on the object type
        if (!IsPostBack)
        {
            //Initialize the result Table
            BuildTable(ObjectType);
            SetGridVisibility(ObjectType);
        }

    }
    //Set the grid visibility based on object type. E.g., if it is searching for store checkin item, only store check in datagrid will be visible, the rest will be invisible
    private void SetGridVisibility(MassAdditionObjectType type)
    {
        this.gridPurchaseOrder.Visible = type == MassAdditionObjectType.PurchaseOrder;
        this.gridPurchaseRequest.Visible = type == MassAdditionObjectType.PurchaseRequest;
        this.gridRequestForQuotation.Visible = type == MassAdditionObjectType.RequestForQuotation;
    }

    private MassAdditionObjectType objectType;
    //Determine what type of object that request for this page. This is to allow the system to display the correct datagrid for the object type, and to build the correct table to return to the parent
    public MassAdditionObjectType ObjectType
    {
        get
        {
            int type = Convert.ToInt32(Security.Decrypt(Request["Type"]));

            switch (type)
            {
                case 1:
                    objectType = MassAdditionObjectType.PurchaseRequest;
                    break;
                case 2:
                    objectType = MassAdditionObjectType.RequestForQuotation;
                    break;
                case 3:
                    objectType = MassAdditionObjectType.PurchaseOrder;
                    break;
                default:
                    objectType = MassAdditionObjectType.PurchaseRequest;
                    break;
            }

            return objectType;
        }

    }

    //return the main grid that will be processed based on the Type request string. Forexample, if type =1, then it is the case to add store check in item
    protected GridView MainGrid
    {
        get
        {
            switch (ObjectType)
            {
                //PurchaseRequest
                case MassAdditionObjectType.PurchaseRequest:
                    return this.gridPurchaseRequest.Grid;
                    break;
                //RequestForQuotation
                case MassAdditionObjectType.RequestForQuotation:
                    return this.gridRequestForQuotation.Grid;
                    break;
                //PurchaseOrder
                case MassAdditionObjectType.PurchaseOrder:
                    return this.gridPurchaseOrder.Grid;
                    break;
                default:
                    return null;
                    break;
            }
        }
    }

    //Return the grid view ID applicable for each object Type.
    protected string GridViewID
    {
        get
        {
            switch (ObjectType)
            {
                //PurchaseRequest
                case MassAdditionObjectType.PurchaseRequest:
                    _gridViewID = "gridPurchaseRequest";
                    break;
                //RequestForQuotation
                case MassAdditionObjectType.RequestForQuotation:
                    _gridViewID = "gridRequestForQuotation";
                    break;
                //PurchaseOrder
                case MassAdditionObjectType.PurchaseOrder:
                    _gridViewID = "gridPurchaseOrder";
                    break;
                default:
                    return null;
                    break;
            }
            return _gridViewID;
        }
    }
    //based on each object type, the result table will be built differently
    protected DataTable ReturnTable
    {
        get
        {
            if (_returnTable == null)
                BuildTable(ObjectType);
            return _returnTable;
        }
    }
    //indicate which object type that the page is for
    public enum MassAdditionObjectType
    {
        PurchaseRequest = 1,
        RequestForQuotation = 2,
        PurchaseOrder = 3
    }
    #endregion
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Simplism.EAM</title>
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <table border="0" cellpadding="0" cellspacing="0" width="100%">
            <tr class='object-name'>
                <td>
                    <asp:Label ID="labelCaption" runat="server" Text="SOR" EnableViewState="false"></asp:Label>
                </td>
            </tr>
        </table>
        <br />
        <div class="div-main">
            <ui:UIObjectPanel runat="server" ID="formMain">
                <ui:UITabStrip runat="server" ID="tabSearch">
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Search" >
                        <web:rates ID="fixedrateSearch" runat="server" OnPopulateForm="fixedrateSearch_PopulateForm">
                        </web:rates>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview2" Caption="Results" >
                        <asp:Panel runat="server" CssClass='object-message' ID="messageDiv" Style="width: 100%">
                            <asp:Label runat='server' ID='labelMessage' EnableViewState="false" ForeColor="Red"
                                Font-Bold="True" meta:resourcekey="labelMessageResource1"></asp:Label>
                        </asp:Panel>
                        <ui:UIButton runat="server" ID="buttonAdd" ImageUrl="~/images/tick.gif" Text="Add Selected Items"
                            OnClick="buttonAdd_Click"></ui:UIButton>
                        <br />
                        <br />
                        <!--Grid for Purchase Request -->
                        <ui:UIGridView runat="server" ID="gridPurchaseRequest" CaptionWidth="120px" Width="100%"
                            KeyName="ObjectID" AllowPaging="true" PageSize="100"  AllowSorting="True"
                             meta:resourcekey="gridPurchaseRequestResource1" PagingEnabled="True"
                            RowErrorColor="" ImageRowErrorUrl="">
                            <Columns>
                                <ui:UIGridViewBoundColumn PropertyName="FixedRateName" HeaderText="SOR" HeaderStyle-Width="35%">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="FixedRateLongDescription" HeaderText="Long Description"
                                    HeaderStyle-Width="35%">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="FixedRateUnitOfMeasure" HeaderText="Unit of Measure"
                                    HeaderStyle-Width="5%">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewTemplateColumn  HeaderText="Quantity Required">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" Caption="" CaptionWidth="0px" PropertyName="QuantityRequired"
                                            ID="PurchaseRequestQuantityRequired" ValidateRequiredField="True" ValidateRangeField="True"
                                            ValidationRangeMax="99999999999999" ValidationRangeMin="0" ValidationRangeType="Double"
                                            ValidateDataTypeCheck="True" ValidationDataType="Double"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                            </Columns>
                        </ui:UIGridView>
                        <!--End of grid for Purchase request-->
                        <!--Grid for RequestForQuotation-->
                        <ui:UIGridView runat="server" ID="gridRequestForQuotation" CaptionWidth="120px" Width="100%"
                            KeyName="ObjectID" AllowPaging="true" PageSize="100"  AllowSorting="True"
                             PagingEnabled="True" RowErrorColor="" ImageRowErrorUrl="">
                            <Columns>
                                <ui:UIGridViewBoundColumn PropertyName="FixedRateName" HeaderText="Fixed rate" HeaderStyle-Width="35%">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="FixedRateLongDescription" HeaderText="Long Description"
                                    HeaderStyle-Width="35%">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="FixedRateUnitOfMeasure" HeaderText="Unit of Measure"
                                    HeaderStyle-Width="5%">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewTemplateColumn  HeaderText="Quantity Required">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" Caption="" CaptionWidth="0px" PropertyName="QuantityRequired"
                                            ID="QuotationQuantityRequired" ValidateRequiredField="True" ValidateRangeField="True"
                                            ValidationRangeMax="99999999999999" ValidationRangeMin="0" ValidationRangeType="Double"
                                            ValidateDataTypeCheck="True" ValidationDataType="Double" ></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                            </Columns>
                        </ui:UIGridView>
                        <!--End of grid for gridRequestForQuotation-->
                        <!--Grid for PurchaseORder-->
                        <ui:UIGridView runat="server" ID="gridPurchaseOrder" OnRowDataBound="gridPurchaseOrder_RowDataBound"
                            CaptionWidth="120px" Width="100%" KeyName="ObjectID" PageSize="100" 
                            AllowSorting="True"  PagingEnabled="True" RowErrorColor=""
                            ImageRowErrorUrl="">
                            <Columns>
                                <ui:UIGridViewBoundColumn PropertyName="FixedRateName" HeaderText="SOR" HeaderStyle-Width="200px">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="FixedRateLongDescription" HeaderText="Long Description"
                                    HeaderStyle-Width="200px">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="ItemCode" HeaderText="Item Code" HeaderStyle-Width="80px">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="FixedRateUnitOfMeasure" HeaderText="UOM" HeaderStyle-Width="80px">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="ContractPrice" HeaderText="Contract Price" DataFormatString="{0:#,##0.0000}"
                                    HeaderStyle-Width="80px">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewTemplateColumn  HeaderStyle-Width="120px" HeaderText="Quantity">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" CaptionWidth="1px" PropertyName="Quantity" Width="120px"
                                            ID="PurchaseOrderQuantityOrdered" ValidateRequiredField="True" ValidateRangeField="True"
                                            ValidationRangeMax="99999999999999" ValidationRangeMin="0" Span="full" ValidationRangeType="Double"
                                            ValidateDataTypeCheck="True" ValidationDataType="Double" ></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn  HeaderStyle-Width="200px" HeaderText="Justification/Remarks">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="ItemJustification" Caption="Justification"
                                            CaptionWidth="1px" PropertyName="ItemJustification" Span="full" TextMode="multiLine"
                                            Rows="3"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn  HeaderText="Receipt Mode" HeaderStyle-Width="150px">
                                    <ItemTemplate>
                                        <ui:UIFieldRadioList ID="ReceiptMode" runat="server" Caption="Receipt Mode" PropertyName="ReceiptMode"
                                            RepeatColumns="1" RepeatDirection="Vertical" ValidateRequiredField="True" CaptionWidth="1px">
                                            <Items>
                                                <asp:ListItem Value="0" selected="true" Text="Quantity">
                                                </asp:ListItem>
                                                <asp:ListItem Value="1" Text="Dollar">
                                                </asp:ListItem>
                                            </Items>
                                        </ui:UIFieldRadioList>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                            </Columns>
                        </ui:UIGridView>
                        <!--End of grid for PurchaseOrder-->
                    </ui:UITabView>
                </ui:UITabStrip>
            </ui:UIObjectPanel>
        </div>
    </form>
</body>
</html>
