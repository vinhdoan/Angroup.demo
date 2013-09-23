<%@ Page Language="C#" Theme="Corporate" Inherits="PageBase" Culture="auto" 
    UICulture="auto" meta:resourcekey="PageResource2" %>

<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="Anacle.DataFramework" %>
<%@ Import Namespace="LogicLayer" %>

<%@ Register assembly="Anacle.UIFramework" namespace="Anacle.UIFramework" tagprefix="cc1" %>

<script runat="server">
    

</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Simplism.EAM</title>
    <meta http-equiv="pragma" content="no-cache" />
    <link href="../../App_Themes/Corporate/StyleSheet.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <ui:UIObjectPanel runat="server" ID="panelMain" BorderStyle="NotSet" 
            meta:resourcekey="panelMainResource2">
            <web:object runat="server" ID="panel" Caption="Attachment Type" BaseTable="tAttachmentType" 
                AutomaticBindingAndSaving="true" meta:resourcekey="panelResource1">
            </web:object>
            <div class="div-main">
                <ui:UITabStrip runat="server" ID="tabObject" BorderStyle="NotSet" 
                    meta:resourcekey="tabObjectResource2" >
                    <ui:UITabView ID="uitabview1" runat="server"  Caption="Details" 
                        BorderStyle="NotSet" meta:resourcekey="uitabview1Resource2">
                        <web:base ID="objectBase" runat="server" ObjectNameCaption="Attachment Type"
                        meta:resourcekey="ObjectBaseResource1">
                        </web:base>
                        
                    </ui:UITabView>
                    <ui:UITabView runat="server" ID="uitabview3" Caption="Memo" 
                        BorderStyle="NotSet" meta:resourcekey="uitabview3Resource2"  >
                        <web:memo runat="server" ID="memo1"></web:memo>
                    </ui:UITabView>
                    <ui:UITabView ID="uitabview2" runat="server"  Caption="Attachments" 
                        BorderStyle="NotSet" meta:resourcekey="uitabview2Resource2">
                        <web:attachments runat="server" ID="attachments"></web:attachments>
                    </ui:UITabView>
                </ui:UITabStrip>
            </div>
        </ui:UIObjectPanel>
    </form>
</body>
</html>
