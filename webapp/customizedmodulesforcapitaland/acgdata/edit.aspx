<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" 
    UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<script runat="server">
    
    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {
        OACGData obj = (OACGData)panel.SessionObject;

        if (obj.IsNew)
        {
            OCode parentCode = TablesLogic.tCode.Load(TablesLogic.tCode.ObjectName == "RevenueType");
            if (parentCode != null)
            {
                List<OCode> codeList = OCode.GetCodesByParentID(parentCode.ObjectID, null);
                foreach (OCode code in codeList)
                {
                    obj.ACGDataRevenue.Add(OACGDataRevenue.CreateRevenue(code));
                }
            }
        }
        BindYear();
        BindMonth();
        treeLocation.PopulateTree();
        panel.ObjectPanel.BindObjectToControls(obj); 
    }

    /// <summary>
    /// Constructs the location tree populater.
    /// </summary>
    /// <param name="sender"></param>
    /// <returns></returns>
    protected TreePopulater treeLocation_AcquireTreePopulater(object sender)
    {
        OACGData obj = panel.SessionObject as OACGData;
        return new LocationTreePopulaterForCapitaland(obj.LocationID, false, true
            ,Security.Decrypt(Request["TYPE"]),false,false);
    }

    /// <summary>
    /// Saves the calendar to the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using(Connection c = new Connection())
        {
            OACGData obj = (OACGData)panel.SessionObject;
            panel.ObjectPanel.BindControlsToObject(obj);

            foreach (OACGDataRevenue rev in obj.ACGDataRevenue)
            {
                foreach (GridViewRow gvr in this.gridACGDataRevenue.Rows)
                {
                    DataKey dk = this.gridACGDataRevenue.DataKeys[gvr.RowIndex];
                    if (rev.ObjectID.Value.ToString() == dk["ObjectID"].ToString())
                    {
                        UIGridView gv = gvr.FindControl("gridACGDataRevenueItem") as UIGridView;

                        if (gv != null)
                        {
                            foreach (GridViewRow row in gv.Rows)
                            {
                                UIFieldTextBox tb = row.FindControl("ObjectID") as UIFieldTextBox;
                                if (tb != null)
                                {
                                    foreach (OACGDataRevenueItem item in rev.ACGDataRevenueItem)
                                    {
                                        if (item.ObjectID.Value.ToString() == tb.Text.ToString())
                                        {
                                            item.Month01Amount = decimal.Parse(((UIFieldTextBox)row.FindControl("Month01Amount")).Text);
                                            item.Month02Amount = decimal.Parse(((UIFieldTextBox)row.FindControl("Month02Amount")).Text);
                                            item.Month03Amount = decimal.Parse(((UIFieldTextBox)row.FindControl("Month03Amount")).Text);
                                            item.Month04Amount = decimal.Parse(((UIFieldTextBox)row.FindControl("Month04Amount")).Text);
                                            item.Month05Amount = decimal.Parse(((UIFieldTextBox)row.FindControl("Month05Amount")).Text);
                                            item.Month06Amount = decimal.Parse(((UIFieldTextBox)row.FindControl("Month06Amount")).Text);
                                            item.Month07Amount = decimal.Parse(((UIFieldTextBox)row.FindControl("Month07Amount")).Text);
                                            item.Month08Amount = decimal.Parse(((UIFieldTextBox)row.FindControl("Month08Amount")).Text);
                                            item.Month09Amount = decimal.Parse(((UIFieldTextBox)row.FindControl("Month09Amount")).Text);
                                            item.Month10Amount = decimal.Parse(((UIFieldTextBox)row.FindControl("Month10Amount")).Text);
                                            item.Month11Amount = decimal.Parse(((UIFieldTextBox)row.FindControl("Month11Amount")).Text);
                                            item.Month12Amount = decimal.Parse(((UIFieldTextBox)row.FindControl("Month12Amount")).Text);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if (!panel.ObjectPanel.IsValid)
                return;

            // Save
            //
            obj.Save();
            c.Commit();
        }
    }

    public void BindYear()
    {
        OACGData obj = panel.SessionObject as OACGData;
        
        Year.Items.Add(new ListItem(((DateTime.Today.Year) - 1).ToString(), ((DateTime.Today.Year) - 1).ToString()));
        Year.Items.Add(new ListItem((DateTime.Today.Year) .ToString(), (DateTime.Today.Year).ToString()));
        Year.Items.Add(new ListItem(((DateTime.Today.Year) + 1).ToString(), ((DateTime.Today.Year) + 1).ToString()));
       
        bool duplicate = false;
        
        foreach (ListItem item in Year.Items)
        {
            if (item.Value.ToString() == obj.Year.ToString())
                duplicate = true;
        }
        
        if (!duplicate && obj.Year != null)
            Year.Items.Add(new ListItem(obj.Year.ToString(), obj.Year.ToString()));
        else
            obj.Year = (DateTime.Today.Year);

        panel.ObjectPanel.BindObjectToControls(obj);     
    }

    public void BindMonth()
    {
        Month.Items.Add(new ListItem("Jan", "1"));
        Month.Items.Add(new ListItem("Feb", "2"));
        Month.Items.Add(new ListItem("Mar", "3"));
        Month.Items.Add(new ListItem("Apr", "4"));
        Month.Items.Add(new ListItem("May", "5"));
        Month.Items.Add(new ListItem("Jun", "6"));
        Month.Items.Add(new ListItem("Jul", "7"));
        Month.Items.Add(new ListItem("Aug", "8"));
        Month.Items.Add(new ListItem("Sep", "9"));
        Month.Items.Add(new ListItem("Oct", "10"));
        Month.Items.Add(new ListItem("Nov", "11"));
        Month.Items.Add(new ListItem("Dec", "12"));
    }

    protected void subpanelACGDataCarPark_ValidateAndUpdate(object sender, EventArgs e)
    {
        OACGDataCarPark carpark = (OACGDataCarPark)subpanelACGDataCarPark.SessionObject;

        subpanelACGDataCarPark.ObjectPanel.BindControlsToObject(carpark);

        OACGData obj = (OACGData)panel.SessionObject;
        obj.ACGDataCarPark.Add(carpark);
        panel.ObjectPanel.BindObjectToControls(obj);
    }

    protected void gridACGDataRevenueItem_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        OACGData obj = panel.SessionObject as OACGData;
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            UIFieldTextBox ObjectID = e.Row.FindControl("ObjectID") as UIFieldTextBox;
            UIFieldTextBox RevenueTypeID = e.Row.FindControl("RevenueTypeID") as UIFieldTextBox;
            UIFieldTextBox Month01Amount = e.Row.FindControl("Month01Amount") as UIFieldTextBox;
            UIFieldTextBox Month02Amount = e.Row.FindControl("Month02Amount") as UIFieldTextBox;
            UIFieldTextBox Month03Amount = e.Row.FindControl("Month03Amount") as UIFieldTextBox;
            UIFieldTextBox Month04Amount = e.Row.FindControl("Month04Amount") as UIFieldTextBox;
            UIFieldTextBox Month05Amount = e.Row.FindControl("Month05Amount") as UIFieldTextBox;
            UIFieldTextBox Month06Amount = e.Row.FindControl("Month06Amount") as UIFieldTextBox;
            UIFieldTextBox Month07Amount = e.Row.FindControl("Month07Amount") as UIFieldTextBox;
            UIFieldTextBox Month08Amount = e.Row.FindControl("Month08Amount") as UIFieldTextBox;
            UIFieldTextBox Month09Amount = e.Row.FindControl("Month09Amount") as UIFieldTextBox;
            UIFieldTextBox Month10Amount = e.Row.FindControl("Month10Amount") as UIFieldTextBox;
            UIFieldTextBox Month11Amount = e.Row.FindControl("Month11Amount") as UIFieldTextBox;
            UIFieldTextBox Month12Amount = e.Row.FindControl("Month12Amount") as UIFieldTextBox;

            DataKey dk = ((GridView)sender).DataKeys[e.Row.RowIndex];

            foreach (OACGDataRevenue revenue in obj.ACGDataRevenue)
            {
                foreach (OACGDataRevenueItem item in revenue.ACGDataRevenueItem)
                {
                    //if (revenue.RevenueTypeID.ToString() == RevenueTypeID.Text)
                    if (item.ObjectID.Value.ToString() == dk["ObjectID"].ToString())
                    {
                        if (e.Row.Cells[1].Text == item.EntryTypeText)
                        {
                            ObjectID.Text = item.ObjectID.ToString();
                            Month01Amount.Text = item.Month01Amount.Value.ToString("#,##0.00");
                            Month02Amount.Text = item.Month02Amount.Value.ToString("#,##0.00");
                            Month03Amount.Text = item.Month03Amount.Value.ToString("#,##0.00");
                            Month04Amount.Text = item.Month04Amount.Value.ToString("#,##0.00");
                            Month05Amount.Text = item.Month05Amount.Value.ToString("#,##0.00");
                            Month06Amount.Text = item.Month06Amount.Value.ToString("#,##0.00");
                            Month07Amount.Text = item.Month07Amount.Value.ToString("#,##0.00");
                            Month08Amount.Text = item.Month08Amount.Value.ToString("#,##0.00");
                            Month09Amount.Text = item.Month09Amount.Value.ToString("#,##0.00");
                            Month10Amount.Text = item.Month10Amount.Value.ToString("#,##0.00");
                            Month11Amount.Text = item.Month11Amount.Value.ToString("#,##0.00");
                            Month12Amount.Text = item.Month12Amount.Value.ToString("#,##0.00");
                        }
                        else if (e.Row.Cells[1].Text == item.EntryTypeText)
                        {
                            ObjectID.Text = item.ObjectID.ToString();
                            Month01Amount.Text = item.Month01Amount.ToString();
                            Month02Amount.Text = item.Month02Amount.ToString();
                            Month03Amount.Text = item.Month03Amount.ToString();
                            Month04Amount.Text = item.Month04Amount.ToString();
                            Month05Amount.Text = item.Month05Amount.ToString();
                            Month06Amount.Text = item.Month06Amount.ToString();
                            Month07Amount.Text = item.Month07Amount.ToString();
                            Month08Amount.Text = item.Month08Amount.ToString();
                            Month09Amount.Text = item.Month09Amount.ToString();
                            Month10Amount.Text = item.Month10Amount.ToString();
                            Month11Amount.Text = item.Month11Amount.ToString();
                            Month12Amount.Text = item.Month12Amount.ToString();
                        }
                    }
                }
            }
        }
    }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        RevenueType.Items.Clear();
        RevenueType.Items.Add(new ListItem());
        OACGData obj = (OACGData)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(obj);

        List<OCode> codeList = new List<OCode>();
        OCode parentCode = TablesLogic.tCode.Load(TablesLogic.tCode.ObjectName == "RevenueType");
        if (parentCode != null)
        {
            codeList = OCode.GetCodesByParentID(parentCode.ObjectID, null);
            foreach (OCode code in codeList)
            {
                bool exist = false;
                foreach (OACGDataRevenue rev in obj.ACGDataRevenue)
                {
                    if (code.ObjectID == rev.RevenueTypeID)
                        exist = true;
                }
                if (!exist)
                    RevenueType.Items.Add(new ListItem(code.ObjectName, code.ObjectID.ToString()));
            }
        }
    }

    protected void RevenueType_SelectedIndexChanged(object sender, EventArgs e)
    {
        OACGData obj = (OACGData)panel.SessionObject;
        panel.ObjectPanel.BindControlsToObject(obj);
        
        if (RevenueType.SelectedValue != "")
        {
            OCode code = TablesLogic.tCode.Load(new Guid(RevenueType.SelectedValue));
            if (code != null)
            {
                obj.ACGDataRevenue.Add(OACGDataRevenue.CreateRevenue(code));
            }
        }

        panel.ObjectPanel.BindObjectToControls(obj);
    }

    protected void gridACGDataRevenue_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        OACGData obj = (OACGData)panel.SessionObject;

        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            UIGridView gv = e.Row.FindControl("gridACGDataRevenueItem") as UIGridView;
            if (gv != null)
            {
                DataKey dk = gridACGDataRevenue.DataKeys[e.Row.RowIndex];
                foreach (OACGDataRevenue rev in obj.ACGDataRevenue)
                {
                    if (rev.ObjectID.Value.ToString() == dk["ObjectID"].ToString())
                    {
                        DataList<OACGDataRevenueItem> dl = rev.ACGDataRevenueItem;
                        dl.Sort("EntryType", true);
                        gv.Bind(dl);
                        break;
                    }
                }
            }

        }
    }
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain">
            <web:object runat="server" ID="panel" Caption="ACG Data" BaseTable="tACGData" meta:resourcekey="panelResource1"
                OnPopulateForm="panel_PopulateForm" OnValidateAndSave="panel_ValidateAndSave">
            </web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" >
                    <ui:UITabView ID="tabDetails" runat="server"  Caption="Details">
                        <web:base ID="objectBase" runat="server" ObjectNameCaption="ACG Name" meta:resourcekey="objectBaseResource1" ObjectNumberVisible="false">
                        </web:base>
                        <ui:UIFieldDropDownList runat="server" PropertyName="Year" Caption="Year" ID="Year" Span="Half">
                        </ui:UIFieldDropDownList>
                        <ui:UIFieldTreeList runat="server" ID="treeLocation" Caption="Location" PropertyName="LocationID"
                            OnAcquireTreePopulater="treeLocation_AcquireTreePopulater"
                            ValidateRequiredField="True" meta:resourcekey="treeLocationResource1" ShowCheckBoxes="None"
                            TreeValueMode="SelectedNode">
                        </ui:UIFieldTreeList>
                        <br /><br />
                        <ui:UIPanel runat="server" ID="panel_ACGDataCarpark">
                            <ui:UIGridView runat="server" ID="gridACGDataCarPark" PropertyName="ACGDataCarPark" 
                                Caption="ACGDataRevenue" ShowFooter="true" PageSize="50" SortExpression="ObjectName ASC" 
                                BindObjectsToRows="true" AllowPaging="false">
                                <Commands>
                                    <ui:UIGridViewCommand CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?" ImageUrl="~/images/delete.gif" CommandName="DeleteObject"></ui:UIGridViewCommand>
                                    <ui:UIGridViewCommand CommandText="Add" ImageUrl="~/images/add.gif" CommandName="AddObject"></ui:UIGridViewCommand>
                                </Commands> 
                                <Columns>
                                    <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" ConfirmText="Are you sure you wish to delete this item?" CommandName="DeleteObject" HeaderText="">
                                    </ui:UIGridViewButtonColumn>
                                    <ui:UIGridViewBoundColumn PropertyName="MonthText" HeaderText="Month" />
                                    <ui:UIGridViewBoundColumn PropertyName="TotalNumberOfLots" HeaderText="Total Number Of Lots" />
                                    <ui:UIGridViewBoundColumn PropertyName="SeasonLotSold" HeaderText="Season Lot Sold" />
                                    <ui:UIGridViewBoundColumn PropertyName="TenantRateInclGST" HeaderText="Tenant Rate Incl GST" />
                                    <ui:UIGridViewBoundColumn PropertyName="NonTenantRateInclGST" HeaderText="Non Tenant Rate Incl GST" />
                                    <ui:UIGridViewBoundColumn PropertyName="PerEntryCost" HeaderText="Per Entry Cost" />
                                 </Columns>
                             </ui:UIGridView>  
                             <ui:UIObjectPanel runat="server" ID="objectPanelACGDataCarPark">
                                <web:subpanel runat="server" ID="subpanelACGDataCarPark" GridViewID="gridACGDataCarPark" OnValidateAndUpdate="subpanelACGDataCarPark_ValidateAndUpdate" />
                                    <ui:UIFieldDropDownList runat="server" PropertyName="Month" Caption="Month" ID="Month" Span="Half" />
                                    <ui:uifieldtextbox runat="server" id="TotalNumberOfLots" PropertyName="TotalNumberOfLots" Caption="Total Number Of Lots" 
                                        ValidateRequiredField='true' Span="Half" ValidateDataTypeCheck="true" ValidationDataType="Currency"
                                        ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive="false" 
                                        DataFormatString="{0:n}" />
                                    <ui:uifieldtextbox runat="server" id="SeasonLotSold" PropertyName="SeasonLotSold" Caption="Season Lot Sold" 
                                        ValidateRequiredField='true' Span="Half" ValidateDataTypeCheck="true" ValidationDataType="Currency"
                                        ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive="false" 
                                        DataFormatString="{0:n}" />
                                    <ui:uifieldtextbox runat="server" id="TenantRateInclGST" PropertyName="TenantRateInclGST" Caption="Tenant Rate Incl GST" 
                                        ValidateRequiredField='true' Span="Half" ValidateDataTypeCheck="true" ValidationDataType="Currency"
                                        ValidateRangeField="true" ValidationRangeMin="0" ValidationRangeMinInclusive="false" 
                                        DataFormatString="{0:n}" />
                                    <ui:uifieldtextbox runat="server" id="NonTenantRateInclGST" PropertyName="NonTenantRateInclGST" Caption="Non Tenant Rate Incl GST" 
                                        ValidateRequiredField='true' Span="Half" ValidateDataTypeCheck="true" ValidationDataType="Currency"
                                        ValidationRangeMin="0" ValidationRangeMinInclusive="false" 
                                        DataFormatString="{0:n}" />
                                    <ui:uifieldtextbox runat="server" id="PerEntryCost" PropertyName="PerEntryCost" Caption="Per Entry Cost" 
                                        ValidateRequiredField='true' Span="Half" ValidateDataTypeCheck="true" ValidationDataType="Currency"
                                        ValidationRangeMin="0" ValidationRangeMinInclusive="false" 
                                        DataFormatString="{0:n}" />
                            </ui:UIObjectPanel>         
                        </ui:UIPanel>
                        <br /><br />
                        <ui:UIPanel runat="server" ID="panel_ACGDataRevenue">
                            <ui:UIFieldDropDownList runat="server" ID="RevenueType" Caption="Revenue Type" OnSelectedIndexChanged="RevenueType_SelectedIndexChanged" />
                            <ui:UIGridView runat="server" ID="gridACGDataRevenue" PropertyName="ACGDataRevenue" 
                                Caption="ACGDataRevenue" ShowFooter="true" PageSize="50" SortExpression="ObjectName ASC" 
                                BindObjectsToRows="true" AllowPaging="false" OnRowDataBound="gridACGDataRevenue_RowDataBound">
                                <Commands>
                                    <ui:UIGridViewCommand CommandText="Delete" ConfirmText="Are you sure you wish to delete the selected items?" ImageUrl="~/images/delete.gif" CommandName="DeleteObject"></ui:UIGridViewCommand>
                                </Commands> 
                                <Columns>
                                    <ui:UIGridViewButtonColumn ImageUrl="~/images/delete.gif" ConfirmText="Are you sure you wish to delete this item?" CommandName="DeleteObject" HeaderText="">
                                    </ui:UIGridViewButtonColumn>
                                    <ui:UIGridViewBoundColumn PropertyName="RevenueType.ObjectName" HeaderText="Revenue Type">
                                    </ui:UIGridViewBoundColumn>
                                    <ui:UIGridViewTemplateColumn>
                                        <ItemTemplate>
                                            <ui:UIGridView runat="server" ID="gridACGDataRevenueItem" PropertyName="" ShowCaption="false" 
                                                CheckBoxColumnVisible="false" PageSize="50"
                                                BindObjectsToRows="true" AllowPaging="false" OnRowDataBound="gridACGDataRevenueItem_RowDataBound">
                                                <Columns>
                                                    <ui:UIGridViewBoundColumn PropertyName="EntryTypeText">
                                                    </ui:UIGridViewBoundColumn>
                                                    <ui:UIGridViewTemplateColumn HeaderText="ObjectID" Visible="false">
                                                        <ItemTemplate>
                                                            <ui:uifieldtextbox runat="server" id="ObjectID" PropertyName="ObjectID" 
                                                            Caption="ObjectID" FIeldLayout="Flow" InternalControlWidth="80px" ShowCaption="false">
                                                            </ui:uifieldtextbox>
                                                        </ItemTemplate>
                                                    </ui:UIGridViewTemplateColumn>
                                                    <ui:UIGridViewTemplateColumn HeaderText="RevenueTypeID" Visible="false">
                                                        <ItemTemplate>
                                                            <ui:uifieldtextbox runat="server" id="RevenueTypeID" PropertyName="ACGDataRevenue.RevenueTypeID" 
                                                            Caption="ACGDataRevenue.RevenueTypeID" FIeldLayout="Flow" InternalControlWidth="80px" ShowCaption="false">
                                                            </ui:uifieldtextbox>
                                                        </ItemTemplate>
                                                    </ui:UIGridViewTemplateColumn>
                                                    <ui:UIGridViewTemplateColumn HeaderText="Month01">
                                                        <ItemTemplate>
                                                            <ui:uifieldtextbox runat="server" id="Month01Amount" PropertyName="Month01Amount" Caption="Month01"
                                                            FIeldLayout="Flow" InternalControlWidth="80px" ShowCaption="false" ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                                            ValidateRequiredField="True" ValidationDataType="Currency" 
                                                            ValidationRangeMin="0" ValidationRangeType="Currency">
                                                            </ui:uifieldtextbox>
                                                        </ItemTemplate>
                                                    </ui:UIGridViewTemplateColumn>
                                                    <ui:UIGridViewTemplateColumn HeaderText="Month02">
                                                        <ItemTemplate>
                                                            <ui:uifieldtextbox runat="server" id="Month02Amount" PropertyName="Month02Amount" Caption="Month02" 
                                                            FIeldLayout="Flow" InternalControlWidth="80px" ShowCaption="false" ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                                            ValidateRequiredField="True" ValidationDataType="Currency" 
                                                            ValidationRangeMin="0" ValidationRangeType="Currency">
                                                            </ui:uifieldtextbox>
                                                        </ItemTemplate>
                                                    </ui:UIGridViewTemplateColumn>
                                                    <ui:UIGridViewTemplateColumn HeaderText="Month03">
                                                        <ItemTemplate>
                                                            <ui:uifieldtextbox runat="server" id="Month03Amount" PropertyName="Month03Amount" Caption="Month03" 
                                                            FIeldLayout="Flow" InternalControlWidth="80px" ShowCaption="false" ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                                            ValidateRequiredField="True" ValidationDataType="Currency" 
                                                            ValidationRangeMin="0" ValidationRangeType="Currency">
                                                            </ui:uifieldtextbox>
                                                        </ItemTemplate>
                                                    </ui:UIGridViewTemplateColumn>
                                                    <ui:UIGridViewTemplateColumn HeaderText="Month04">
                                                        <ItemTemplate>
                                                            <ui:uifieldtextbox runat="server" id="Month04Amount" PropertyName="Month04Amount" Caption="Month04" 
                                                            FIeldLayout="Flow" InternalControlWidth="80px" ShowCaption="false" ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                                            ValidateRequiredField="True" ValidationDataType="Currency" 
                                                            ValidationRangeMin="0" ValidationRangeType="Currency">
                                                            </ui:uifieldtextbox>
                                                        </ItemTemplate>
                                                    </ui:UIGridViewTemplateColumn>
                                                    <ui:UIGridViewTemplateColumn HeaderText="Month05">
                                                        <ItemTemplate>
                                                            <ui:uifieldtextbox runat="server" id="Month05Amount" PropertyName="Month05Amount" Caption="Month05" 
                                                            FIeldLayout="Flow" InternalControlWidth="80px" ShowCaption="false" ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                                            ValidateRequiredField="True" ValidationDataType="Currency" 
                                                            ValidationRangeMin="0" ValidationRangeType="Currency">
                                                            </ui:uifieldtextbox>
                                                        </ItemTemplate>
                                                    </ui:UIGridViewTemplateColumn>
                                                    <ui:UIGridViewTemplateColumn HeaderText="Month06">
                                                        <ItemTemplate>
                                                            <ui:uifieldtextbox runat="server" id="Month06Amount" PropertyName="Month06Amount" Caption="Month06" 
                                                            FIeldLayout="Flow" InternalControlWidth="80px" ShowCaption="false" ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                                            ValidateRequiredField="True" ValidationDataType="Currency" 
                                                            ValidationRangeMin="0" ValidationRangeType="Currency">
                                                            </ui:uifieldtextbox>
                                                        </ItemTemplate>
                                                    </ui:UIGridViewTemplateColumn>
                                                    <ui:UIGridViewTemplateColumn HeaderText="Month07">
                                                        <ItemTemplate>
                                                            <ui:uifieldtextbox runat="server" id="Month07Amount" PropertyName="Month07Amount" Caption="Month07" 
                                                            FIeldLayout="Flow" InternalControlWidth="80px" ShowCaption="false" ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                                            ValidateRequiredField="True" ValidationDataType="Currency" 
                                                            ValidationRangeMin="0" ValidationRangeType="Currency">
                                                            </ui:uifieldtextbox>
                                                        </ItemTemplate>
                                                    </ui:UIGridViewTemplateColumn>
                                                    <ui:UIGridViewTemplateColumn HeaderText="Month08">
                                                        <ItemTemplate>
                                                            <ui:uifieldtextbox runat="server" id="Month08Amount" PropertyName="Month08Amount" Caption="Month08" 
                                                            FIeldLayout="Flow" InternalControlWidth="80px" ShowCaption="false" ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                                            ValidateRequiredField="True" ValidationDataType="Currency" 
                                                            ValidationRangeMin="0" ValidationRangeType="Currency">
                                                            </ui:uifieldtextbox>
                                                        </ItemTemplate>
                                                    </ui:UIGridViewTemplateColumn>
                                                    <ui:UIGridViewTemplateColumn HeaderText="Month09">
                                                        <ItemTemplate>
                                                            <ui:uifieldtextbox runat="server" id="Month09Amount" PropertyName="Month09Amount" Caption="Month09" 
                                                            FIeldLayout="Flow" InternalControlWidth="80px" ShowCaption="false" ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                                            ValidateRequiredField="True" ValidationDataType="Currency" 
                                                            ValidationRangeMin="0" ValidationRangeType="Currency">
                                                            </ui:uifieldtextbox>
                                                        </ItemTemplate>
                                                    </ui:UIGridViewTemplateColumn>
                                                    <ui:UIGridViewTemplateColumn HeaderText="Month10">
                                                        <ItemTemplate>
                                                            <ui:uifieldtextbox runat="server" id="Month10Amount" PropertyName="Month10Amount" Caption="Month10" 
                                                            FIeldLayout="Flow" InternalControlWidth="80px" ShowCaption="false" ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                                            ValidateRequiredField="True" ValidationDataType="Currency" 
                                                            ValidationRangeMin="0" ValidationRangeType="Currency">
                                                            </ui:uifieldtextbox>
                                                        </ItemTemplate>
                                                    </ui:UIGridViewTemplateColumn>
                                                    <ui:UIGridViewTemplateColumn HeaderText="Month11">
                                                        <ItemTemplate>
                                                            <ui:uifieldtextbox runat="server" id="Month11Amount" PropertyName="Month11Amount" Caption="Month11" 
                                                            FIeldLayout="Flow" InternalControlWidth="80px" ShowCaption="false" ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                                            ValidateRequiredField="True" ValidationDataType="Currency" 
                                                            ValidationRangeMin="0" ValidationRangeType="Currency">
                                                            </ui:uifieldtextbox>
                                                        </ItemTemplate>
                                                    </ui:UIGridViewTemplateColumn>
                                                    <ui:UIGridViewTemplateColumn HeaderText="Month12">
                                                        <ItemTemplate>
                                                            <ui:uifieldtextbox runat="server" id="Month12Amount" PropertyName="Month12Amount" Caption="Month12" 
                                                            FIeldLayout="Flow" InternalControlWidth="80px" ShowCaption="false" ValidateDataTypeCheck="True" ValidateRangeField="True" 
                                                            ValidateRequiredField="True" ValidationDataType="Currency" 
                                                            ValidationRangeMin="0" ValidationRangeType="Currency">
                                                            </ui:uifieldtextbox>
                                                        </ItemTemplate>
                                                    </ui:UIGridViewTemplateColumn>
                                                </Columns>
                                            </ui:UIGridView>
                                        </ItemTemplate>
                                    </ui:UIGridViewTemplateColumn>
                                </Columns>
                            </ui:UIGridView>
                            <ui:UIObjectPanel runat="server" ID="UIObjectPanel1">
                                <web:subpanel runat="server" ID="subpanel_ACGDataRevenue" GridViewID="gridACGDataRevenue" />
                                   
                            </ui:UIObjectPanel> 
                        </ui:UIPanel>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabMemo" Caption="Memo"  >
                        <web:memo runat="server" ID="memo1"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="tabAttachments"  Caption="Attachments">
                        <web:attachments runat="server" ID="attachments"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
