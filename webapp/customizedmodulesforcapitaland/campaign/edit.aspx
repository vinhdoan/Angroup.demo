<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" meta:resourcekey="PageResource1"
    UICulture="auto" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">

    /// <summary>
    /// Populates the form.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_PopulateForm(object sender, EventArgs e)
    {

        OCampaign campaign = panel.SessionObject as OCampaign;
         listLocation.Bind(AppSession.User.GetAllAccessibleLocation(OApplicationSetting.Current.LocationTypeNameForBuildingActual, "OCampaign"), "ObjectName", "ObjectID");

         panel.ObjectPanel.BindObjectToControls(campaign);
        if (campaign.IsNew)
        {

            for (int i = 0; i < listLocation.Items.Count; i++)
            {
                listLocation.Items[i].Selected = true;
            }
        }
        
       
    }


    /// <summary>
    /// Validates and saves the campaign object into the database.
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void panel_ValidateAndSave(object sender, EventArgs e)
    {
        using (Connection c = new Connection())
        {
            OCampaign campaign = panel.SessionObject as OCampaign;
            panel.ObjectPanel.BindControlsToObject(campaign);

            // Save
            //        
            campaign.Save();
            c.Commit();
        }
    }





    /// <summary>
    /// Hides/shows or enables/disables elements.
    /// </summary>
    /// <param name="e"></param>
    protected override void OnPreRender(EventArgs e)
    {


        base.OnPreRender(e);
     
     
    }



    
 

</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
    
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" >
            <web:object runat="server" ID="panel" Caption="Campaign" BaseTable="tCampaign"
                OnPopulateForm="panel_PopulateForm"  OnValidateAndSave="panel_ValidateAndSave">
            </web:object>
            <div class="div-main">
            <ui:UITabStrip runat="server" ID="tabObject">
            <ui:UITabView runat="server" ID="uitabview1" Caption="Details" 
                         BorderStyle="NotSet">
                        <web:base runat="server" ID="objectBase" ObjectNumberVisible="false"></web:base>
                        
                        <ui:UIPanel runat="server" ID="panelCampaignItem1" BorderStyle="NotSet">
                            <ui:UIFieldListBox runat="server" ID="listLocation" PropertyName="LocationsForCampaigns"
                             Caption="Location List of this campaign" ></ui:UIFieldListBox>
                        </ui:UIPanel>
            </ui:UITabView>
                        <ui:UITabView runat="server" ID="uitabview2" Caption="Memo"  BorderStyle="NotSet">
                        <web:memo ID="Memo1" runat="server"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Attachments" 
                        meta:resourcekey="uitabview3Resource1" BorderStyle="NotSet">
                        <web:attachments runat="server" ID="attachments"></web:attachments>
                    </ui:UITabView>
               </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
