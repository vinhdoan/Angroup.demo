<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Register Src="~/components/menu.ascx" TagPrefix="web" TagName="menu" %>
<%@ Register Src="~/components/objectsearchpanel.ascx" TagPrefix="web" TagName="search" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<script runat="server">
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
            case MassAdditionObjectType.StoreCheckOut:
                BuildStoreCheckOutTable(dt);
                break;
            case MassAdditionObjectType.StoreTransfer:
                BuildStoreTransferTable(dt);
                break;
            case MassAdditionObjectType.WorkEstimate:
                BuildWorkEstimatedTable(dt);
                break;
            case MassAdditionObjectType.WorkActual:
                BuildWorkActualTable(dt);
                break;
            case MassAdditionObjectType.ScheduledWork:
                BuildScheduledWorkTable(dt);
                break;
            //Other case goes here            


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
            case MassAdditionObjectType.StoreCheckOut:
                if (!BuildStoreCheckOutRow(returnRow, resultRow, gridViewRow))
                    validate = false;
                break;
            case MassAdditionObjectType.StoreTransfer:
                if (!BuildStoreTransferRow(returnRow, resultRow, gridViewRow))
                    validate = false;
                break;
            case MassAdditionObjectType.WorkEstimate:
                if (!BuildWorkEstimatedRow(returnRow, resultRow, gridViewRow))
                    validate = false;
                break;
            case MassAdditionObjectType.WorkActual:
                if (!BuildWorkActualRow(returnRow, resultRow, gridViewRow))
                    validate = false;
                break;
            case MassAdditionObjectType.ScheduledWork:
                if (!BuildScheduleWorkRow(returnRow, resultRow, gridViewRow))
                    validate = false;
                break;
            //other object type cases  BuildWorkActualRow

        }
        return validate;
    }
    #region Build Tables
    /// <summary>
    /// Build Store Check Out Table
    /// </summary>
    /// <param name="dt"></param>
    private void BuildStoreCheckOutTable(DataTable dt)
    {
        dt.Columns.Add("StoreBinID");
        dt.Columns.Add("ActualQuantity");
        dt.Columns.Add("ActualUnitOfMeasureID");
    }
    /// <summary>
    /// Build Store Transfer Table
    /// </summary>
    /// <param name="dt"></param>
    private void BuildStoreTransferTable(DataTable dt)
    {
        dt.Columns.Add("FromStoreBinID");
        dt.Columns.Add("ToStoreBinID");
        dt.Columns.Add("Quantity");
    }
    /// <summary>
    /// Build Work Estimated Table
    /// </summary>
    /// <param name="dt"></param>
    private void BuildWorkEstimatedTable(DataTable dt)
    {
        dt.Columns.Add("StoreID");
        dt.Columns.Add("StoreBinID");
        dt.Columns.Add("UnitOfMeasureID");
        dt.Columns.Add("EstimatedQuantity");
        dt.Columns.Add("ActualQuantity");
        dt.Columns.Add("ChargeOut");
        dt.Columns.Add("CostType");
    }
    /// <summary>
    /// Build Work Actual Table
    /// </summary>
    /// <param name="dt"></param>
    private void BuildWorkActualTable(DataTable dt)
    {
        dt.Columns.Add("StoreID");
        dt.Columns.Add("StoreBinID");
        dt.Columns.Add("UnitOfMeasureID");
        dt.Columns.Add("EstimatedQuantity");
        dt.Columns.Add("ActualQuantity");
        dt.Columns.Add("ChargeOut");
        dt.Columns.Add("CostType");
    }
    /// <summary>
    /// Build Scheduled Work Table
    /// </summary>
    /// <param name="dt"></param>
    private void BuildScheduledWorkTable(DataTable dt)
    {
        dt.Columns.Add("StoreID");
        dt.Columns.Add("StoreBinID");
        dt.Columns.Add("UnitOfMeasureID");
        dt.Columns.Add("EstimatedQuantity");
        dt.Columns.Add("CostType");
    }
    #endregion

    #region Build Row
    private bool BuildStoreCheckOutRow(DataRow returnRow, DataRow resultRow, GridViewRow gridViewRow)
    {
        bool validate = true;
        //copy data for each of the column in the Return table. Original data such as CatalogID, CatalogName, can be retrieved from the resultRow of the catalog Search panel
        //Addition info such as quantity, unit price are to retrieve from the gridViewRow itself.                                

        //Perform necessary validation here. if not satisfy, set error message      
        //call the control Validate function to perform standard validation as specified in the control declaration
        //Additional validate will need to be performed if required.   

        //StoreBinID
        returnRow["StoreBinID"] = resultRow["BinID"];

        //CheckoutQuantity
        UIFieldTextBox txtCheckoutQuantity = (UIFieldTextBox)gridViewRow.FindControl("CheckoutQuantity");
        string message = txtCheckoutQuantity.Validate();
        if (message != null)
        {
            txtCheckoutQuantity.ErrorMessage = message;
            validate = false;
        }
        else
        {
            returnRow["ActualQuantity"] = txtCheckoutQuantity.Text;
        }

        UIFieldDropDownList dropCheckOutUnit = (UIFieldDropDownList)gridViewRow.FindControl("droCheckOutUnit");
        message = dropCheckOutUnit.Validate();
        if (message != null)
        {
            dropCheckOutUnit.ErrorMessage = message;
            validate = false;
        }
        else
        {
            returnRow["ActualUnitOfMeasureID"] = dropCheckOutUnit.SelectedValue;
        }
        //Other fields....
        return validate;
    }

    private bool BuildStoreTransferRow(DataRow returnRow, DataRow resultRow, GridViewRow gridViewRow)
    {
        bool validate = true;
        //copy data for each of the column in the Return table. Original data such as CatalogID, CatalogName, can be retrieved from the resultRow of the catalog Search panel
        //Addition info such as quantity, unit price are to retrieve from the gridViewRow itself.                                

        //Perform necessary validation here. if not satisfy, set error message      
        //call the control Validate function to perform standard validation as specified in the control declaration
        //Additional validate will need to be performed if required.           


        //FromStoreBinID
        UIFieldDropDownList droFromStore = (UIFieldDropDownList)gridViewRow.FindControl("droFromStore");
        string message = droFromStore.Validate();
        if (message != null)
        {
            droFromStore.ErrorMessage = message;
            validate = false;
        }
        else
        {
            returnRow["FromStoreBinID"] = droFromStore.SelectedValue;
        }
        //FromStoreBinID
        UIFieldDropDownList droToStore = (UIFieldDropDownList)gridViewRow.FindControl("droToStore");
        message = droToStore.Validate();
        if (message != null)
        {
            droFromStore.ErrorMessage = message;
            validate = false;
        }
        else
        {
            returnRow["ToStoreBinID"] = droToStore.SelectedValue;
        }
        //Quantity
        UIFieldTextBox txtQuantity = (UIFieldTextBox)gridViewRow.FindControl("TransferQuantity");
        message = txtQuantity.Validate();
        if (message != null)
        {
            txtQuantity.ErrorMessage = message;
            validate = false;
        }
        else
        {
            returnRow["Quantity"] = txtQuantity.Text;
        }
        //Other fields....
        return validate;
    }

    private bool BuildWorkEstimatedRow(DataRow returnRow, DataRow resultRow, GridViewRow gridViewRow)
    {
        bool validate = true;
        //copy data for each of the column in the Return table. Original data such as CatalogID, CatalogName, can be retrieved from the resultRow of the catalog Search panel
        //Addition info such as quantity, unit price are to retrieve from the gridViewRow itself.                                

        //Perform necessary validation here. if not satisfy, set error message      
        //call the control Validate function to perform standard validation as specified in the control declaration
        //Additional validate will need to be performed if required.   

        //StoreID
        returnRow["StoreID"] = resultRow["StoreID"];
        //StoreBinID
        returnRow["StoreBinID"] = resultRow["BinID"];

        //CheckOutUnit
        UIFieldDropDownList dropCheckOutUnit = (UIFieldDropDownList)gridViewRow.FindControl("drCheckOutUnit");
        string message = dropCheckOutUnit.Validate();
        if (message != null)
        {
            dropCheckOutUnit.ErrorMessage = message;
            validate = false;
        }
        else
        {
            returnRow["UnitOfMeasureID"] = dropCheckOutUnit.SelectedValue;
        }

        //EstimatedQuantity
        UIFieldTextBox txtEstimatedQty = (UIFieldTextBox)gridViewRow.FindControl("txtEstimatedQuantity");
        message = txtEstimatedQty.Validate();
        if (message != null)
        {
            txtEstimatedQty.ErrorMessage = message;
            validate = false;
        }
        else
        {
            returnRow["EstimatedQuantity"] = txtEstimatedQty.Text;
        }
        //IsCharge
        if (Security.Decrypt(Request["IsCharged"]) == "1")
        {
            UIFieldTextBox IsCharge = (UIFieldTextBox)gridViewRow.FindControl("txtIsCharge");
            message = IsCharge.Validate();
            if (message != null)
            {
                IsCharge.ErrorMessage = message;
                validate = false;
            }
            else
            {
                returnRow["ChargeOut"] = IsCharge.Text;
            }
        }

        //CostType  
        returnRow["CostType"] = 3;

        //Other fields....
        return validate;
    }
    private bool BuildWorkActualRow(DataRow returnRow, DataRow resultRow, GridViewRow gridViewRow)
    {
        bool validate = true;
        //copy data for each of the column in the Return table. Original data such as CatalogID, CatalogName, can be retrieved from the resultRow of the catalog Search panel
        //Addition info such as quantity, unit price are to retrieve from the gridViewRow itself.                                

        //Perform necessary validation here. if not satisfy, set error message      
        //call the control Validate function to perform standard validation as specified in the control declaration
        //Additional validate will need to be performed if required.   

        //StoreID
        returnRow["StoreID"] = resultRow["StoreID"];
        //StoreBinID
        returnRow["StoreBinID"] = resultRow["BinID"];

        //CheckOutUnit
        UIFieldDropDownList dropCheckOutUnit = (UIFieldDropDownList)gridViewRow.FindControl("drChOutUnit");
        string message = dropCheckOutUnit.Validate();
        if (message != null)
        {
            dropCheckOutUnit.ErrorMessage = message;
            validate = false;
        }
        else
        {
            returnRow["UnitOfMeasureID"] = dropCheckOutUnit.SelectedValue;
        }

        //ActualQuantity
        UIFieldTextBox txtActualQty = (UIFieldTextBox)gridViewRow.FindControl("txtActualQuantity");
        message = txtActualQty.Validate();
        if (message != null)
        {
            txtActualQty.ErrorMessage = message;
            validate = false;
        }
        else
        {
            returnRow["ActualQuantity"] = txtActualQty.Text;
        }
        if (Security.Decrypt(Request["IsCharged"]) == "1")
        {
            //IsCharge
            UIFieldTextBox IsCharge = (UIFieldTextBox)gridViewRow.FindControl("txtCharge");
            message = IsCharge.Validate();
            if (message != null)
            {
                IsCharge.ErrorMessage = message;
                validate = false;
            }
            else
            {

                returnRow["ChargeOut"] = IsCharge.Text;
            }
        }

        //CostType  
        returnRow["CostType"] = 3;

        //Other fields....
        return validate;
    }
    private bool BuildScheduleWorkRow(DataRow returnRow, DataRow resultRow, GridViewRow gridViewRow)
    {
        bool validate = true;
        //copy data for each of the column in the Return table. Original data such as CatalogID, CatalogName, can be retrieved from the resultRow of the catalog Search panel
        //Addition info such as quantity, unit price are to retrieve from the gridViewRow itself.                                

        //Perform necessary validation here. if not satisfy, set error message      
        //call the control Validate function to perform standard validation as specified in the control declaration
        //Additional validate will need to be performed if required.   

        //StoreID
        returnRow["StoreID"] = resultRow["StoreID"];
        //StoreBinID
        returnRow["StoreBinID"] = resultRow["BinID"];

        //CheckOutUnit
        UIFieldDropDownList dropCheckOutUnit = (UIFieldDropDownList)gridViewRow.FindControl("dropCheckOut");
        string message = dropCheckOutUnit.Validate();
        if (message != null)
        {
            dropCheckOutUnit.ErrorMessage = message;
            validate = false;
        }
        else
        {
            returnRow["UnitOfMeasureID"] = dropCheckOutUnit.SelectedValue;
        }

        //ActualQuantity
        UIFieldTextBox txtEstQty = (UIFieldTextBox)gridViewRow.FindControl("txtEstQty");
        message = txtEstQty.Validate();
        if (message != null)
        {
            txtEstQty.ErrorMessage = message;
            validate = false;
        }
        else
        {
            returnRow["EstimatedQuantity"] = txtEstQty.Text;
        }

        //CostType  
        returnRow["CostType"] = 3;

        //Other fields....
        return validate;
    }
    #endregion

    protected void catalogSearch_PopulateForm(object sender, EventArgs e)
    {
        catalogSearch.GridViewID = GridViewID;
        if (Request["ContractID"] != null)
            catalogSearch.ContractID = Security.Decrypt(Request["ContractID"]);

        catalogSearch.GridViewID = GridViewID;
        if (Request["StoreID"] != null)
            catalogSearch.StoreID = Security.Decrypt(Request["StoreID"]);

        catalogSearch.GridViewID = GridViewID;
        if (Request["LocationID"] != null)
            catalogSearch.LocationID = Security.Decrypt(Request["LocationID"]);

    }
    #region RowDataBound Events
    //populate addition data for each row if necessary    
    protected void gridCheckOut_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            UIFieldDropDownList CheckOutUnitList = (UIFieldDropDownList)e.Row.Cells[6].FindControl("droCheckOutUnit");
            DataRow resultRow = catalogSearch.ResultTable.Rows[e.Row.DataItemIndex];
            Guid catalogUnitOfMeasureID = new Guid(resultRow["CatalogUnitOfMeasureID"].ToString());
            CheckOutUnitList.Bind(OUnitConversion.GetConversions(catalogUnitOfMeasureID, null), "ObjectName", "ToUnitOfMeasureID", false);
        }
    }

    protected void gridStoreTransfer_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            UIFieldDropDownList StoreFromList = (UIFieldDropDownList)e.Row.Cells[4].FindControl("droFromStore");
            UIFieldDropDownList StoreToList = (UIFieldDropDownList)e.Row.Cells[5].FindControl("droToStore");
            DataRow resultRow = catalogSearch.ResultTable.Rows[e.Row.DataItemIndex];

            Guid tempCatalogueID = new Guid(resultRow["CatalogID"].ToString());
            if (Request["StoreID"] != null)
            {
                //Guid storeid = new Guid(Security.Decrypt(Request["StoreID"]));
                StoreFromList.Bind(OStore.FindBinsByCatalogue(new Guid(Security.Decrypt(Request["StoreID"])), tempCatalogueID, false), "ObjectName", "ObjectID", true);
            }
            if (Request["StoreToID"] != null)
            {
                //Guid storeToid = new Guid(Security.Decrypt(Request["StoreToID"]));
                StoreToList.Bind(OStore.FindBinsByCatalogue(new Guid(Security.Decrypt(Request["StoreToID"])), tempCatalogueID, true), "ObjectName", "ObjectID", true);
            }
        }
    }

    protected void gridWorkEstimated_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            UIFieldDropDownList CheckOutUnitList = (UIFieldDropDownList)e.Row.Cells[6].FindControl("drCheckOutUnit");
            DataRow resultRow = catalogSearch.ResultTable.Rows[e.Row.DataItemIndex];
            Guid catalogUnitOfMeasureID = new Guid(resultRow["CatalogUnitOfMeasureID"].ToString());
            CheckOutUnitList.Bind(OUnitConversion.GetConversions(catalogUnitOfMeasureID, null), "ObjectName", "ToUnitOfMeasureID", false);
        }
    }
    protected void gridWorkActual_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            UIFieldDropDownList CheckOutUnitList = (UIFieldDropDownList)e.Row.Cells[6].FindControl("drChOutUnit");
            DataRow resultRow = catalogSearch.ResultTable.Rows[e.Row.DataItemIndex];
            Guid catalogUnitOfMeasureID = new Guid(resultRow["CatalogUnitOfMeasureID"].ToString());
            CheckOutUnitList.Bind(OUnitConversion.GetConversions(catalogUnitOfMeasureID, null), "ObjectName", "ToUnitOfMeasureID", false);
        }
    }
    protected void gridScheduleWork_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            UIFieldDropDownList CheckOutUnitList = (UIFieldDropDownList)e.Row.Cells[6].FindControl("dropCheckOut");
            DataRow resultRow = catalogSearch.ResultTable.Rows[e.Row.DataItemIndex];
            Guid catalogUnitOfMeasureID = new Guid(resultRow["CatalogUnitOfMeasureID"].ToString());
            CheckOutUnitList.Bind(OUnitConversion.GetConversions(catalogUnitOfMeasureID, null), "ObjectName", "ToUnitOfMeasureID", false);
        }
    }

    #endregion

    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);

        if (ObjectType == MassAdditionObjectType.WorkEstimate && Security.Decrypt(Request["IsCharged"]) == "1")
            gridWorkEstimate.Grid.Columns[8].Visible = true;
        else gridWorkEstimate.Grid.Columns[8].Visible = false;

        if (ObjectType == MassAdditionObjectType.WorkActual && Security.Decrypt(Request["IsCharged"]) == "1")
            gridWorkActual.Grid.Columns[8].Visible = true;
        else gridWorkActual.Grid.Columns[8].Visible = false;

        this.messageDiv.Visible = labelMessage.Text != "";

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
                            if (row.DataItemIndex < MainGrid.DataKeys.Count)
                            {
                                //Create new row of the ReturnTable that will be used to pass back to the parent page.
                                DataRow returnRow = this.ReturnTable.NewRow();

                                //Get the corresponding row in the original result dataset
                                DataRow resultRow = resultTb.Rows[row.DataItemIndex];

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
        gridStoreCheckOut.Visible = type == MassAdditionObjectType.StoreCheckOut;
        this.gridStoreTransfer.Visible = type == MassAdditionObjectType.StoreTransfer;
        this.gridWorkEstimate.Visible = type == MassAdditionObjectType.WorkEstimate;
        this.gridWorkActual.Visible = type == MassAdditionObjectType.WorkActual;
        this.gridScheduledWork.Visible = type == MassAdditionObjectType.ScheduledWork;
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
                    objectType = MassAdditionObjectType.StoreCheckOut;
                    break;
                case 2:
                    objectType = MassAdditionObjectType.StoreTransfer;
                    break;
                case 3:
                    objectType = MassAdditionObjectType.WorkEstimate;
                    break;
                case 4:
                    objectType = MassAdditionObjectType.WorkActual;
                    break;
                case 5:
                    objectType = MassAdditionObjectType.ScheduledWork;
                    break;
                default:
                    objectType = MassAdditionObjectType.StoreCheckOut;
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
                //store check out
                case MassAdditionObjectType.StoreCheckOut:
                    return gridStoreCheckOut.Grid;
                    break;
                //StoreTransfer
                case MassAdditionObjectType.StoreTransfer:
                    return this.gridStoreTransfer.Grid;
                    break;
                //WorkEstimate
                case MassAdditionObjectType.WorkEstimate:
                    return this.gridWorkEstimate.Grid;
                    break;
                //WorkActual
                case MassAdditionObjectType.WorkActual:
                    return this.gridWorkActual.Grid;
                    break;
                //ScheduledWork
                case MassAdditionObjectType.ScheduledWork:
                    return this.gridScheduledWork.Grid;
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
                //StoreCheckOut
                case MassAdditionObjectType.StoreCheckOut:
                    _gridViewID = "gridStoreCheckOut";
                    break;
                //StoreTransfer
                case MassAdditionObjectType.StoreTransfer:
                    _gridViewID = "gridStoreTransfer";
                    break;
                //WorkEstimate
                case MassAdditionObjectType.WorkEstimate:
                    _gridViewID = "gridWorkEstimate";
                    break;
                //WorkActual
                case MassAdditionObjectType.WorkActual:
                    _gridViewID = "gridWorkActual";
                    break;
                //ScheduledWork
                case MassAdditionObjectType.ScheduledWork:
                    _gridViewID = "gridScheduledWork";
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
        StoreCheckOut = 1,
        StoreTransfer = 2,
        WorkEstimate = 3,
        WorkActual = 4,
        ScheduledWork = 5
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
                        <web:catalog ID="catalogSearch" SearchType="StockType" runat="server" OnPopulateForm="catalogSearch_PopulateForm">
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
                        <!--Grid for Store Check out-->
                        <ui:UIGridView runat="server" ID="gridStoreCheckOut" OnRowDataBound="gridCheckOut_RowDataBound"
                            CaptionWidth="120px" Width="100%" KeyName="ObjectID" AllowPaging="False" 
                            AllowSorting="True"  meta:resourcekey="gridCheckInResource1"
                            PagingEnabled="True" RowErrorColor="">
                            <Columns>
                                <ui:UIGridViewBoundColumn PropertyName="CatalogName" HeaderText="Catalog Name" HeaderStyle-Width="100px"
                                    meta:resourcekey="UIGridViewColumnResource1">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="CatalogStockCode" HeaderText="Stock Code" HeaderStyle-Width="100px"
                                    meta:resourcekey="UIGridViewColumnResource2">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="BinName" HeaderText="Bin (Available quantity)"
                                    HeaderStyle-Width="160px" meta:resourcekey="UIGridViewColumnResource3">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="CatalogUnitOfMeasure" HeaderText="Unit Of Measure"
                                    HeaderStyle-Width="80px" meta:resourcekey="UIGridViewColumnResource4">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewTemplateColumn  HeaderStyle-Width="120px" HeaderText="Check out Quantity"
                                    meta:resourcekey="UIGridViewColumnResource5">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="CheckoutQuantity" Caption="ActualQuantity"
                                            CaptionWidth="1px" PropertyName="ActualQuantity" ValidationRangeMin="0" ValidationRangeMax="99999999999999"
                                            ValidateDataTypeCheck="true" ValidationDataType="Double" ValidateRequiredField="True"
                                            ValidateRangeField="true" ValidationRangeType="double"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn  HeaderStyle-Width="150px" HeaderText="Check Out Unit"
                                    meta:resourcekey="UIGridViewColumnResource6">
                                    <ItemTemplate>
                                        <ui:UIFieldDropDownList runat="server" ID="droCheckOutUnit" Caption="ActualUnitOfMeasure"
                                            PropertyName="ActualUnitOfMeasureID" ValidateRequiredField="True" CaptionWidth="1px"
                                            Style="float: left; table-layout: fixed;"  border="0" cellpadding="2"
                                            cellspacing="0" Height="20px"  meta:resourcekey="droCheckOutUnitResource1"
                                            Width="99%">
                                        </ui:UIFieldDropDownList>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                            </Columns>
                        </ui:UIGridView>
                        <!--End of grid for Store Check Out-->
                        <!--Grid for Store transfer -->
                        <ui:UIGridView runat="server" ID="gridStoreTransfer" OnRowDataBound="gridStoreTransfer_RowDataBound"
                            CaptionWidth="120px" Width="100%" KeyName="ObjectID" AllowPaging="False" 
                            AllowSorting="True"  meta:resourcekey="gridStoreResource1"
                            PagingEnabled="True" RowErrorColor="">
                            <Columns>
                                <ui:UIGridViewBoundColumn PropertyName="CatalogName" HeaderText="Catalog Name" HeaderStyle-Width="100px"
                                    meta:resourcekey="UIGridViewColumnResource7">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="CatalogStockCode" HeaderText="Stock Code" HeaderStyle-Width="100px"
                                    meta:resourcekey="UIGridViewColumnResource8">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="CatalogUnitOfMeasure" HeaderText="Base Unit" HeaderStyle-Width="80px"
                                    meta:resourcekey="UIGridViewColumnResource9">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewTemplateColumn  HeaderStyle-Width="150px" HeaderText="From Bin" meta:resourcekey="UIGridViewColumnResource10">
                                    <ItemTemplate>
                                        <ui:UIFieldDropDownList runat="server" ID="droFromStore" PropertyName="FromStoreBinID"
                                            Caption="FromStoreBin" ValidateRequiredField="True" CaptionWidth="1px" Style="float: left;
                                            table-layout: fixed;"  border="0" cellpadding="2" cellspacing="0"
                                            Height="20px"  meta:resourcekey="droFromStoreResource1"
                                            Width="99%">
                                        </ui:UIFieldDropDownList>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn  HeaderStyle-Width="150px" HeaderText="To Bin" meta:resourcekey="UIGridViewColumnResource11">
                                    <ItemTemplate>
                                        <ui:UIFieldDropDownList runat="server" ID="droToStore" PropertyName="ToStoreBinID"
                                            Caption="ToStoreBin" ValidateRequiredField="True" CaptionWidth="1px" Style="float: left;
                                            table-layout: fixed;"  border="0" cellpadding="2" cellspacing="0"
                                            Height="20px"  meta:resourcekey="droToStoreResource1"
                                            Width="99%">
                                        </ui:UIFieldDropDownList>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn  HeaderStyle-Width="120px" HeaderText="Transfer quantity"
                                    meta:resourcekey="UIGridViewColumnResource12">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="TransferQuantity" CaptionWidth="1px" Caption="TransferQuantity"
                                            PropertyName="Quantity" ValidationRangeMin="0" ValidationRangeMax="99999999999999"
                                            ValidateDataTypeCheck="true" ValidationDataType="Double" ValidateRequiredField="True"
                                            ValidateRangeField="true" ValidationRangeType="double" Style="float: left; table-layout: fixed;"
                                             border="0" cellpadding="2" cellspacing="0" Height="20px"
                                             meta:resourcekey="TransferQuantityResource1" Width="99%">
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                            </Columns>
                        </ui:UIGridView>
                        <!--End of grid for Store transfer -->
                        <!--Grid for Work Estimated -->
                        <ui:UIGridView runat="server" ID="gridWorkEstimate" CaptionWidth="120px" Width="100%"
                            KeyName="ObjectID" OnRowDataBound="gridWorkEstimated_RowDataBound" AllowPaging="False"
                             AllowSorting="True"  meta:resourcekey="gridPurchaseRequestResource1"
                            PagingEnabled="True" RowErrorColor="">
                            <Columns>
                                <ui:UIGridViewBoundColumn PropertyName="CatalogName" HeaderText="Catalog Name" HeaderStyle-Width="100px"
                                    meta:resourcekey="UIGridViewColumnResource13">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="CatalogStockCode" HeaderText="Stock Code" HeaderStyle-Width="100px"
                                    meta:resourcekey="UIGridViewColumnResource14">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="CatalogUnitOfMeasure" HeaderText="Base Unit" HeaderStyle-Width="80px"
                                    meta:resourcekey="UIGridViewColumnResource15">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="StoreName" HeaderText="Store" HeaderStyle-Width="120px" meta:resourcekey="UIGridViewColumnResource16">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="BinName" HeaderText="Bin (Available quantity)"
                                    HeaderStyle-Width="160px" meta:resourcekey="UIGridViewColumnResource17">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewTemplateColumn  HeaderStyle-Width="150px" HeaderText="Check Out Unit"
                                    meta:resourcekey="UIGridViewColumnResource18">
                                    <ItemTemplate>
                                        <ui:UIFieldDropDownList runat="server" ID="drCheckOutUnit" Caption="UnitOfMeasure"
                                            PropertyName="UnitOfMeasureID" ValidateRequiredField="True" CaptionWidth="1px"
                                            Style="float: left; table-layout: fixed;"  border="0" cellpadding="2"
                                            cellspacing="0" Height="20px"  meta:resourcekey="drCheckOutUnitResource1"
                                            Width="99%">
                                        </ui:UIFieldDropDownList>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn  HeaderStyle-Width="120px" HeaderText="Estimated Quantity"
                                    meta:resourcekey="UIGridViewColumnResource19">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="txtEstimatedQuantity" CaptionWidth="1px" Caption="EstimatedQuantity"
                                            PropertyName="EstimatedQuantity" ValidationDataType="Double" ValidationRangeMin="0"
                                            ValidateDataTypeCheck="true" ValidateRequiredField="True" ValidateRangeField="true"
                                            ValidationRangeType="double" Style="float: left; table-layout: fixed;" 
                                            border="0" cellpadding="2" cellspacing="0" Height="20px" 
                                            meta:resourcekey="EstimatedQuantityResource1" Width="99%"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn  HeaderStyle-Width="120px" HeaderText="Charge" meta:resourcekey="UIGridViewColumnResource20">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="txtIsCharge" CaptionWidth="1px" Caption="ChargeOut"
                                            PropertyName="ChargeOut" ValidationDataType="Currency" ValidationRangeMin="0"
                                            ValidationNumberOfDecimalPlaces="2" ValidateRequiredField="True" ValidateRangeField="true"
                                            ValidationRangeType="Currency" Style="float: left; table-layout: fixed;" 
                                            border="0" cellpadding="2" cellspacing="0" Height="20px" 
                                            meta:resourcekey="txtIsChargeResource1" Width="99%"></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                            </Columns>
                        </ui:UIGridView>
                        <!--End of grid for Work Estimated-->
                        <!--Grid for WorkActual-->
                        <ui:UIGridView runat="server" ID="gridWorkActual" CaptionWidth="120px" Width="100%"
                            KeyName="ObjectID" OnRowDataBound="gridWorkActual_RowDataBound" AllowPaging="False"
                             AllowSorting="True"  meta:resourcekey="gridRequestForQuotationResource1"
                            PagingEnabled="True" RowErrorColor="">
                            <Columns>
                                <ui:UIGridViewBoundColumn PropertyName="CatalogName" HeaderText="Catalog Name" HeaderStyle-Width="100px">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="CatalogStockCode" HeaderText="Stock Code" HeaderStyle-Width="100px">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="CatalogUnitOfMeasure" HeaderText="Base Unit" HeaderStyle-Width="80px">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="StoreName" HeaderText="Store" HeaderStyle-Width="120px">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="BinName" HeaderText="Bin (Available quantity)"
                                    HeaderStyle-Width="160px">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewTemplateColumn  HeaderStyle-Width="150px" HeaderText="Check Out Unit">
                                    <ItemTemplate>
                                        <ui:UIFieldDropDownList runat="server" ID="drChOutUnit" Caption="UnitOfMeasure" PropertyName="UnitOfMeasureID"
                                            ValidateRequiredField="True" CaptionWidth="1px" Style="float: left; table-layout: fixed;"
                                             border="0" cellpadding="2" cellspacing="0" Height="20px"
                                            >
                                        </ui:UIFieldDropDownList>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn  HeaderStyle-Width="120px" HeaderText="Actual Quantity"
                                    meta:resourcekey="UIGridViewColumnResource19">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="txtActualQuantity" CaptionWidth="1px" Caption="ActualQuantity"
                                            PropertyName="ActualQuantity" ValidationRangeMin="0" ValidationRangeMax="99999999999999"
                                            ValidateDataTypeCheck="true" ValidationDataType="Double" ValidateRequiredField="True"
                                            ValidateRangeField="true" ValidationRangeType="double" Style="float: left; table-layout: fixed;"
                                             border="0" cellpadding="2" cellspacing="0" Height="20px"
                                            ></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn  HeaderStyle-Width="120px" HeaderText="Charge">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="txtCharge" CaptionWidth="1px" Caption="ChargeOut"
                                            PropertyName="ChargeOut" ValidationDataType="Currency" ValidationRangeMin="0"
                                            ValidationNumberOfDecimalPlaces="2" ValidateRequiredField="True" ValidateRangeField="true"
                                            ValidationRangeType="Currency" Style="float: left; table-layout: fixed;" 
                                            border="0" cellpadding="2" cellspacing="0" Height="20px" >
                                        </ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                            </Columns>
                        </ui:UIGridView>
                        <!--End of grid for WorkActual-->
                        <!--Grid for ScheduledWork-->
                        <ui:UIGridView runat="server" ID="gridScheduledWork" CaptionWidth="120px" Width="100%"
                            KeyName="ObjectID" OnRowDataBound="gridScheduleWork_RowDataBound" AllowPaging="False"
                             AllowSorting="True"  meta:resourcekey="gridPurchaseOrderResource1"
                            PagingEnabled="True" RowErrorColor="">
                            <Columns>
                                <ui:UIGridViewBoundColumn PropertyName="CatalogName" HeaderText="Catalog Name" HeaderStyle-Width="100px">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="CatalogStockCode" HeaderText="Stock Code" HeaderStyle-Width="100px">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="CatalogUnitOfMeasure" HeaderText="Base Unit" HeaderStyle-Width="80px">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="StoreName" HeaderText="Store" HeaderStyle-Width="120px">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewBoundColumn PropertyName="BinName" HeaderText="Bin (Available quantity)"
                                    HeaderStyle-Width="160px">
                                </ui:UIGridViewBoundColumn>
                                <ui:UIGridViewTemplateColumn  HeaderStyle-Width="150px" HeaderText="Check Out Unit">
                                    <ItemTemplate>
                                        <ui:UIFieldDropDownList runat="server" ID="dropCheckOut" PropertyName="UnitOfMeasureID"
                                            Caption="UnitOfMeasure" ValidateRequiredField="True" CaptionWidth="1px" Style="float: left;
                                            table-layout: fixed;"  border="0" cellpadding="2" cellspacing="0"
                                            Height="20px" >
                                        </ui:UIFieldDropDownList>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                                <ui:UIGridViewTemplateColumn  HeaderStyle-Width="120px" HeaderText="Estimated Quantity">
                                    <ItemTemplate>
                                        <ui:UIFieldTextBox runat="server" ID="txtEstQty" CaptionWidth="1px" Caption="EstimatedQuantity"
                                            PropertyName="EstimatedQuantity" ValidationRangeMin="0" ValidationRangeMax="99999999999999"
                                            ValidateDataTypeCheck="true" ValidationDataType="Double" ValidateRequiredField="True"
                                            ValidateRangeField="true" ValidationRangeType="double" Style="float: left; table-layout: fixed;"
                                             border="0" cellpadding="2" cellspacing="0" Height="20px"
                                            ></ui:UIFieldTextBox>
                                    </ItemTemplate>
                                </ui:UIGridViewTemplateColumn>
                            </Columns>
                        </ui:UIGridView>
                        <!--End of grid for ScheduledWork-->
                    </ui:UITabView>
                </ui:UITabStrip>
            </ui:UIObjectPanel>
        </div>
    </form>
</body>
</html>
