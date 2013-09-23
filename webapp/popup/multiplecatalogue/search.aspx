<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<script runat="server">
        
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        this.messageDiv.Visible = labelMessage.Text != "";

        //EM. Hide unit price, tax code if it is from quotation
        if (Request["Quotation"] != null)
        {
            gridPurchaseOrder.Grid.Columns[6].Visible = false;
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
        //common column for all cases
        dt.Columns.Add("CatalogueID");
        dt.Columns.Add("CatalogName");

        switch (type)
        {
            case MassAdditionObjectType.StoreCheckIn:
                BuildStoreCheckInTable(dt);
                break;
            case MassAdditionObjectType.Store:
                BuildStoreItemTable(dt);
                break;
            case MassAdditionObjectType.PurchaseRequest:
                BuildPurchaseRequestTable(dt);
                break;
            case MassAdditionObjectType.RequestForQuotation:
                BuildPurchaseRequestTable(dt);
                break;
            case MassAdditionObjectType.PurchaseOrder:
                BuildPurchaseOrderTable(dt);
                break;
        }
        _returnTable = dt;
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
        returnRow["CatalogueID"] = resultRow["CatalogID"];
        returnRow["CatalogName"] = resultRow["CatalogName"];

        bool validate = true;

        switch (ObjectType)
        {
            case MassAdditionObjectType.StoreCheckIn:
                if (!BuildStoreCheckInRow(returnRow, resultRow, gridViewRow))
                    validate = false;
                break;
            case MassAdditionObjectType.Store:
                if (!BuildStoreItemRow(returnRow, resultRow, gridViewRow))
                    validate = false;
                break;
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
    private void BuildStoreCheckInTable(DataTable dt)
    {
        dt.Columns.Add("StoreBinID");
        dt.Columns.Add("StoreBinName");
        dt.Columns.Add("UnitPrice");
        dt.Columns.Add("Quantity");
        dt.Columns.Add("ExpiryDate");
        dt.Columns.Add("LotNumber");
    }
    private void BuildPurchaseRequestTable(DataTable dt)
    {
        dt.Columns.Add("FixedRateID");
        dt.Columns.Add("QuantityRequired");
        dt.Columns.Add("ItemNumber");
        dt.Columns.Add("ItemType");
    }
    private void BuildRequestForQuotationTable(DataTable dt)
    {
        dt.Columns.Add("FixedRateID");
        dt.Columns.Add("QuantityRequired");
        dt.Columns.Add("ItemNumber");
        dt.Columns.Add("ItemType");
    }
    private void BuildPurchaseOrderTable(DataTable dt)
    {
        dt.Columns.Add("FixedRateID");
        dt.Columns.Add("UnitPrice");
        dt.Columns.Add("QuantityOrdered");
        dt.Columns.Add("TaxCodeID");
        dt.Columns.Add("ItemNumber");
        dt.Columns.Add("ItemType");
        dt.Columns.Add("ReceiptMode");
        dt.Columns.Add("ItemJustification");
    }
    private bool BuildPurchaseRequestRow(DataRow returnRow, DataRow resultRow, GridViewRow gridViewRow)
    {
        bool validate = true;

        returnRow["ItemNumber"] = ItemNumberIncrementor++;
        returnRow["ItemType"] = 0;
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
        returnRow["ItemType"] = 0;
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
        returnRow["ItemType"] = 0;

        string message = null;

        //EM, NO unit price, tax code for quotation

        if (Request["Quotation"] == null)
        {
            //UnitPrice
            /*   UIFieldTextBox ValueOfUnitPrice = (UIFieldTextBox)gridViewRow.FindControl("UnitPrice");
                message = ValueOfUnitPrice.Validate();
                if (message != null)
                {
                    ValueOfUnitPrice.ErrorMessage = message;
                    validate = false;
                }
                else
                {
                    returnRow["UnitPrice"] = ValueOfUnitPrice.Value;
                }
              */
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

            /*UIFieldDropDownList TaxCode = (UIFieldDropDownList)gridViewRow.FindControl("TaxCode");
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
    //populate addition data for each row if necessary        
    protected void gridPurchaseOrder_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {

        }

    }
    private bool BuildStoreCheckInRow(DataRow returnRow, DataRow resultRow, GridViewRow gridViewRow)
    {
        bool validate = true;
        //copy data for each of the column in the Return table. Original data such as CatalogID, CatalogName, can be retrieved from the resultRow of the catalog Search panel
        //Addition info such as quantity, unit price are to retrieve from the gridViewRow itself.                                

        //Perform necessary validation here. if not satisfy, set error message      
        //call the control Validate function to perform standard validation as specified in the control declaration
        //Additional validate will need to be performed if required.
        UIFieldDropDownList bin = (UIFieldDropDownList)gridViewRow.FindControl("checkInBin");
        string message = bin.Validate();
        if (message != null)
        {
            bin.ErrorMessage = message;
            validate = false;
        }
        else
        {
            returnRow["StoreBinID"] = bin.SelectedValue;
            returnRow["StoreBinName"] = bin.Items[bin.SelectedIndex].Text;
        }

        //Quantity
        UIFieldTextBox qty = (UIFieldTextBox)gridViewRow.FindControl("checkinQuantity");
        message = qty.Validate();
        if (message != null)
        {
            qty.ErrorMessage = message;
            validate = false;
        }
        else
        {
            returnRow["Quantity"] = qty.Text;
        }

        //UnitPrice
        UIFieldTextBox txtUnitPrice = (UIFieldTextBox)gridViewRow.FindControl("checkInUnitPrice");
        message = txtUnitPrice.Validate();
        if (message != null)
        {
            txtUnitPrice.ErrorMessage = message;
            validate = false;
        }
        else
        {
            returnRow["UnitPrice"] = txtUnitPrice.Text;
        }
        //ExpiryDate
        UIFieldDateTime txtExpiryDate = (UIFieldDateTime)gridViewRow.FindControl("checkinExpiryDate");
        message = txtExpiryDate.Validate();
        if (message != null)
        {
            txtExpiryDate.ErrorMessage = message;
            validate = false;
        }
        else
        {
            returnRow["ExpiryDate"] = txtExpiryDate.DateTime;
        }

        //LotNumber
        UIFieldTextBox txtLotNumber = (UIFieldTextBox)gridViewRow.FindControl("checkinLotNumber");
        message = txtLotNumber.Validate();
        if (message != null)
        {
            txtLotNumber.ErrorMessage = message;
            validate = false;
        }
        else
        {
            returnRow["LotNumber"] = txtLotNumber.Text;
        }
        //Other fields....
        return validate;
    }

    private void BuildStoreItemTable(DataTable dt)
    {
        dt.Columns.Add("CostingType");
        dt.Columns.Add("CostingTypeName");
        dt.Columns.Add("ItemType");
        dt.Columns.Add("ItemTypeName");
        dt.Columns.Add("ReorderDefault");
        dt.Columns.Add("ReorderThreshold");
    }
    private bool BuildStoreItemRow(DataRow returnRow, DataRow resultRow, GridViewRow gridViewRow)
    {
        bool validate = true;
        //copy data for each of the column in the Return table. Original data such as CatalogID, CatalogName, can be retrieved from the resultRow of the catalog Search panel
        //Addition info such as quantity, unit price are to retrieve from the gridViewRow itself.                                

        //Perform necessary validation here. if not satisfy, set error message      
        //call the control Validate function to perform standard validation as specified in the control declaration
        //Additional validate will need to be performed if required.

        //Costing Type 
        UIFieldRadioList rdoCostingType = (UIFieldRadioList)gridViewRow.FindControl("Catalogue_CostingType");
        string message = rdoCostingType.Validate();
        if (message != null)
        {
            rdoCostingType.ErrorMessage = message;
            validate = false;
        }
        else
        {
            returnRow["CostingType"] = rdoCostingType.SelectedValue;
            returnRow["CostingTypeName"] = rdoCostingType.Items[rdoCostingType.SelectedIndex].Text;
        }

        //Item Type 
        UIFieldRadioList rdoItemType = (UIFieldRadioList)gridViewRow.FindControl("Catalogue_ItemType");
        message = rdoItemType.Validate();
        if (message != null)
        {
            rdoItemType.ErrorMessage = message;
            validate = false;
        }
        else
        {
            returnRow["ItemType"] = rdoItemType.SelectedValue;
            returnRow["ItemTypeName"] = rdoItemType.Items[rdoItemType.SelectedIndex].Text;
        }


        //ReorderDefault
        UIFieldTextBox txtReorderDefault = (UIFieldTextBox)gridViewRow.FindControl("txtReorderDefault");
        message = txtReorderDefault.Validate();
        if (message != null)
        {
            txtReorderDefault.ErrorMessage = message;
            validate = false;
        }
        else
        {
            returnRow["ReorderDefault"] = txtReorderDefault.Text;
        }
        //ReorderThreshold
        UIFieldTextBox txtReorderThreshold = (UIFieldTextBox)gridViewRow.FindControl("txtReorderThreshold");
        message = txtReorderThreshold.Validate();
        if (message != null)
        {
            txtReorderThreshold.ErrorMessage = message;
            validate = false;
        }
        else
        {
            returnRow["ReorderThreshold"] = txtReorderThreshold.Text;
        }
        //Other fields....

        return validate;
    }
    protected void catalogSearch_PopulateForm(object sender, EventArgs e)
    {
        //Initialize setting of the page here. 
        catalogSearch.GridViewID = GridViewID;
        if (Request["ContractID"] != null)
            catalogSearch.ContractID = Security.Decrypt(Request["ContractID"]);



    }
    //populate addition data for each row if necessary    
    protected void gridCheckIn_RowDataBound(object sender, GridViewRowEventArgs e)
    {

        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //populate Bin
            UIFieldDropDownList binList = (UIFieldDropDownList)e.Row.Cells[1].FindControl("checkInBin");
            string storeID = Security.Decrypt(Request["StoreID"]);
            binList.Bind(TablesLogic.tStoreBin[TablesLogic.tStoreBin.StoreID == new Guid(storeID)]);
        }

    }




    #region INITIALIZATION
    //private DataTable to store the return result for each of the object Type   
    private DataTable _returnTable = null;
    private string _gridViewID;

    /// <summary>
    /// Loop the datagrid row and search for row with the check box being selected, and extract the row data and save into the return table
    /// If there is any data error, display error. If there is no error, pass the return table into the window.ReturnDataTable.    
    /// ******DO NOT MODIFY THIS CODE******
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void buttonAdd_Click(object sender, EventArgs e)
    {
        //Clear error message before proceed
        this.formMain.ClearErrorMessages();
        //retrieve the original result of the gridCheckIn
        DataTable resultTb = this.catalogSearch.ResultTable;

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
                                //row    
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
                this.catalogSearch.DisposeControl();
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
        gridCheckIn.Visible = type == MassAdditionObjectType.StoreCheckIn;
        this.gridStore.Visible = type == MassAdditionObjectType.Store;
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
                    objectType = MassAdditionObjectType.StoreCheckIn;
                    break;
                case 2:
                    objectType = MassAdditionObjectType.Store;
                    break;
                case 3:
                    objectType = MassAdditionObjectType.PurchaseRequest;
                    break;
                case 4:
                    objectType = MassAdditionObjectType.RequestForQuotation;
                    break;
                case 5:
                    objectType = MassAdditionObjectType.PurchaseOrder;
                    break;
                default:
                    objectType = MassAdditionObjectType.StoreCheckIn;
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
                //store check in
                case MassAdditionObjectType.StoreCheckIn:
                    return gridCheckIn.Grid;
                    break;
                //store
                case MassAdditionObjectType.Store:
                    return this.gridStore.Grid;
                    break;
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
                //store check in
                case MassAdditionObjectType.StoreCheckIn:
                    _gridViewID = "gridCheckIn";
                    break;
                //store
                case MassAdditionObjectType.Store:
                    _gridViewID = "gridStore";
                    break;
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
        StoreCheckIn = 1,
        Store = 2,
        PurchaseRequest = 3,
        RequestForQuotation = 4,
        PurchaseOrder = 5
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
                    <asp:Label ID="labelCaption" runat="server" Text="Catalog" EnableViewState="false"
                        meta:resourcekey="labelCaptionResource1"></asp:Label>
                </td>
            </tr>
        </table>
        <br />
        <div class="div-main">
            <ui:UIObjectPanel runat="server" ID="formMain">
                <ui:UITabStrip runat="server" ID="tabSearch" meta:resourcekey="tabSearchResource1">
                    <ui:UITabView runat="server" ID="uitabview1" Caption="Search" 
                        meta:resourcekey="uitabview1Resource1">
                        <web:catalog ID="catalogSearch" SearchType="CatalogType" runat="server" OnPopulateForm="catalogSearch_PopulateForm">
                        </web:catalog>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview2" Caption="Results" 
                        meta:resourcekey="uitabview2Resource1">
                        <asp:Panel runat="server" CssClass='object-message' ID="messageDiv" Style="width: 100%">
                            <asp:Label runat='server' ID='labelMessage' EnableViewState="false" ForeColor="Red"
                                Font-Bold="True" meta:resourcekey="labelMessageResource1"></asp:Label>
                        </asp:Panel>
                        <ui:UIButton runat="server" ID="buttonAdd" ImageUrl="~/images/tick.gif" Text="Add Selected Items"
                            OnClick="buttonAdd_Click" meta:resourcekey="buttonSearchResource1"></ui:UIButton>
                        <br />
                        <br />
                        <!--All grids goes here-->
                        <!--Grid for Store Check in-->
                        <ui:UIGridView runat="server" ID="gridCheckIn" OnRowDataBound="gridCheckIn_RowDataBound"
                            CaptionWidth="120px" Width="100%" KeyName="ObjectID" AllowPaging="True" PageSize="100"
                             AllowSorting="True"  meta:resourcekey="gridCheckInResource1"
                            PagingEnabled="True" RowErrorColor="" ImageRowErrorUrl="">
                            <Columns>
                                <ui:UIGridViewBoundColumn PropertyName="CatalogName" HeaderText="Catalog Name" HeaderStyle-Width="80px">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="CatalogStockCode" HeaderText="Stock Code" HeaderStyle-Width="80px">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewTemplateColumn  HeaderStyle-Width="120px" HeaderText="Bin">
                                    <ItemTemplate>
                                        <ui:UIFieldDropDownList runat="server" ID="checkInBin" Caption="Bin" CaptionWidth="1px"
                                            ValidateRequiredField="True" >
                                        </ui:UIFieldDropDownList>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn  HeaderStyle-Width="130px" HeaderText="Unit Price">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" Caption="Unit Price" CaptionWidth="1px" PropertyName="UnitPrice"
                                            ID="checkInUnitPrice" ValidateRequiredField="True" ValidationNumberOfDecimalPlaces="2"
                                            ValidateRangeField="True" ValidationRangeMax="99999999999999" ValidationRangeMin="0"
                                            ValidationRangeType="Currency" ValidateDataTypeCheck="True" ValidationDataType="Currency"
                                            ></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn  HeaderStyle-Width="120px" HeaderText="Quantity">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" Caption="Quantity" CaptionWidth="1px" PropertyName="Quantity"
                                            ID="checkinQuantity" ValidateRequiredField="True" ValidateRangeField="True" ValidationRangeMax="99999999999999"
                                            ValidationRangeMin="0" ValidationRangeType="Currency" ValidateDataTypeCheck="True"
                                            ValidationDataType="Double">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn  HeaderStyle-Width="150px" HeaderText="Expiry Date">
                                    <ItemTemplate>
                                        <ui:UIFieldDateTime runat="server" Caption="Expiry date" CaptionWidth="1px" PropertyName="ExpiryDate"
                                            ID="checkinExpiryDate" 
                                            ImageClearUrl="~/calendar/dateclr.gif"
                                            ImageUrl="~/calendar/date.gif" ></ui:UIFieldDateTime>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn  HeaderStyle-Width="120px" HeaderText="Lot Number">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" Caption="Lot Number" CaptionWidth="1px" PropertyName="LotNumber"
                                            ID="checkinLotNumber" >
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                            </Columns>
                        </ui:UIGridView>
                        <!--End of grid for Store Check In-->
                        <!--Grid for Store -->
                        <ui:UIGridView runat="server" ID="gridStore" Width="100%" KeyName="ObjectID"
                            AllowPaging="True" PageSize="100"  AllowSorting="True" 
                            meta:resourcekey="gridStoreResource1" PagingEnabled="True" RowErrorColor="" ImageRowErrorUrl="">
                            <Columns>
                                <ui:UIGridViewBoundColumn PropertyName="CatalogName" HeaderText="Catalog Name" meta:resourcekey="UIGridViewColumnResource40"
                                    HeaderStyle-Width="80px">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="CatalogStockCode" HeaderText="Stock Code" meta:resourcekey="UIGridViewColumnResource41"
                                    HeaderStyle-Width="80px">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewTemplateColumn  HeaderStyle-Width="200px" HeaderText="Costing Type"
                                    meta:resourcekey="UIGridViewColumnResource46">
                                    <ItemTemplate>
                                        <ui:UIFieldRadioList runat="server" RepeatColumns="0" RepeatDirection="Vertical" ShowCaption="false"
                                            Caption="CostingType" ID="Catalogue_CostingType" PropertyName="CostingType" ValidateRequiredField="True"
                                            CaptionWidth="1px">
                                            <Items>
                                                <asp:listitem value="0" Text="FIFO" Selected="True">
                                                </asp:listitem>
                                                <asp:listitem value="1" Text="LIFO">
                                                </asp:listitem>
                                            </Items>
                                        </ui:UIFieldRadioList>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn  HeaderStyle-Width="200px" HeaderText="Item Type" meta:resourcekey="UIGridViewColumnResource47">
                                    <ItemTemplate>
                                        <ui:UIFieldRadioList runat="server" CaptionWidth="1px" ID="Catalogue_ItemType"
                                            Caption="ItemType" ShowCaption="false" RepeatColumns="0"
                                            RepeatDirection="Vertical" PropertyName="ItemType" ValidateRequiredField="True"
                                            Width="99%">
                                            <Items>
                                                <asp:listitem value="0" Text="Stocked" Selected="True">
                                                </asp:listitem>
                                                <asp:listitem value="1" Text="Non Stocked ">
                                                </asp:listitem>
                                            </Items>
                                        </ui:UIFieldRadioList>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn  HeaderStyle-Width="150px" HeaderText="Reorder Quantity">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" CaptionWidth="1px" Caption="ReorderQuantity"
                                            PropertyName="ReorderDefault" ShowCaption="false" ID="txtReorderDefault"
                                            ValidateRequiredField="True" ValidateRangeField="True" ValidationRangeMax="99999999999999"
                                            ValidationRangeMin="0" ValidateDataTypeCheck="True" ValidationRangeType="double"
                                            ValidationDataType="Double"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn  HeaderStyle-Width="150px" HeaderText="Reorder Threshold">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" CaptionWidth="1px" Caption="ReorderThreshold"
                                            PropertyName="ReorderThreshold" ShowCaption="false" ID="txtReorderThreshold"
                                            ValidateRangeField="True" ValidationRangeMax="99999999999999"
                                            ValidationRangeMin="0" ValidateDataTypeCheck="True" ValidationRangeType="double"
                                            ValidationDataType="Double"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                            </Columns>
                        </ui:UIGridView>
                        <!--End of grid for Store -->
                        <!--Grid for Purchase Request -->
                        <ui:UIGridView runat="server" ID="gridPurchaseRequest" CaptionWidth="120px" Width="100%"
                            KeyName="ObjectID" AllowPaging="True" PageSize="100"  AllowSorting="True"
                             meta:resourcekey="gridPurchaseRequestResource1" PagingEnabled="True"
                            RowErrorColor="" ImageRowErrorUrl="">
                            <Columns>
                                <ui:UIGridViewBoundColumn PropertyName="CatalogName" HeaderText="Catalog Name" HeaderStyle-Width="20%">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="CatalogUnitOfMeasure" HeaderText="Unit Of Measure"
                                    HeaderStyle-Width="10%">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="CatalogModel" HeaderText="Model" HeaderStyle-Width="10%">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="CatalogManufacturer" HeaderText="Manufacturer"
                                    HeaderStyle-Width="20%">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewTemplateColumn  HeaderText="Quantity Required"
                                    meta:resourcekey="UIGridViewColumnResource11">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" Caption="Quantity Required" CaptionWidth="0px"
                                            PropertyName="QuantityRequired" ID="PurchaseRequestQuantityRequired" ValidateRequiredField="True"
                                            ValidateRangeField="True" ValidationRangeMax="99999999999999" ValidationRangeMin="0"
                                            ValidationRangeType="Currency" ValidateDataTypeCheck="True" ValidationDataType="Double"
                                            >
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                            </Columns>
                        </ui:UIGridView>
                        <!--End of grid for Purchase request-->
                        <!--Grid for RequestForQuotation-->
                        <ui:UIGridView runat="server" ID="gridRequestForQuotation" CaptionWidth="120px" Width="100%"
                            KeyName="ObjectID" AllowPaging="true" PageSize="100"  AllowSorting="True"
                             meta:resourcekey="gridRequestForQuotationResource1"
                            PagingEnabled="True" RowErrorColor="" ImageRowErrorUrl="">
                            <Columns>
                                <ui:UIGridViewBoundColumn PropertyName="CatalogName" HeaderText="Catalog Name" HeaderStyle-Width="20%">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="CatalogUnitOfMeasure" HeaderText="Unit Of Measure"
                                    HeaderStyle-Width="10%">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="CatalogModel" HeaderText="Model" HeaderStyle-Width="10%">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="CatalogManufacturer" HeaderText="Manufacturer"
                                    HeaderStyle-Width="20%">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewTemplateColumn  HeaderText="Quantity Required"
                                    meta:resourcekey="UIGridViewColumnResource23">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" Caption="Quantity Required" CaptionWidth="0px"
                                            PropertyName="QuantityRequired" ID="QuotationQuantityRequired" ValidateRequiredField="True"
                                            ValidateRangeField="True" ValidationRangeMax="99999999999999" ValidationRangeMin="0"
                                            ValidationRangeType="Double" ValidateDataTypeCheck="True" ValidationDataType="Double"
                                            ></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                            </Columns>
                        </ui:UIGridView>
                        <!--End of grid for gridRequestForQuotation-->
                        <!--Grid for PurchaseORder-->
                        <ui:UIGridView runat="server" ID="gridPurchaseOrder" OnRowDataBound="gridPurchaseOrder_RowDataBound"
                            CaptionWidth="120px" Width="100%" PageSize="100" AllowPaging="True" 
                            AllowSorting="True"  meta:resourcekey="gridPurchaseOrderResource1"
                            PagingEnabled="True" RowErrorColor="" ImageRowErrorUrl="" KeyName="ObjectID">
                            <Columns>
                                <ui:UIGridViewBoundColumn PropertyName="CatalogName" HeaderText="Catalog Name" HeaderStyle-Width="200px">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="StockCode" HeaderText="Stock Code" HeaderStyle-Width="80px">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="CatalogUnitOfMeasure" HeaderText="Unit Of Measure"
                                    HeaderStyle-Width="80px">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="CatalogModel" HeaderText="Model" HeaderStyle-Width="80px">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="CatalogManufacturer" HeaderText="Manufacturer"
                                    HeaderStyle-Width="80px">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="ContractPrice" HeaderText="Contract Price" DataFormatString="{0:#,##0.00##}"
                                    HeaderStyle-Width="80px">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewTemplateColumn  HeaderStyle-Width="150px" HeaderText="Quantity" meta:resourcekey="UIGridViewColumnResource29">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" Caption="Quantity" CaptionWidth="1px" PropertyName="Quantity"
                                            ID="PurchaseOrderQuantityOrdered" ValidateRequiredField="True" ValidateRangeField="True"
                                            ValidationRangeMax="99999999999999" ValidationRangeMin="0" ValidationRangeType="Double"
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
