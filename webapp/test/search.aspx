
 
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
 
<html xmlns="http://www.w3.org/1999/xhtml"> 
<head id="Head1" runat="server"> 
    <title></title> 
 
    <script type="text/javascript">

        function show(id) {
            $addHandler($get(id), 'click', showModalPopupViaClient);

        }

        function hide(id) {

            $addHandler($get(id), 'click', hideModalPopupViaClient);
        }

        function showModalPopupViaClient(ev) {
            ev.preventDefault();
            var modalPopupBehavior = $find('programmaticModalPopupBehavior');
            $find("AEFadeIn").get_OnClickBehavior().play();
            modalPopupBehavior.show();

        }

        function hideModalPopupViaClient(ev) {
            ev.preventDefault();
            var modalPopupBehavior = $find('programmaticModalPopupBehavior');
            $find("AEFadeOut").get_OnClickBehavior().play();
        } 
 
         
     
    </script> 
 
</head> 
<body> 
    <form id="form1" runat="server"> 
    <div> 
        <asp:ScriptManager ID="ScriptManager1" runat="server" /> 
        <ajaxToolkit:AnimationExtender ID="AEFadeIn" runat="server" Enabled="True" TargetControlID="hfFadeIn"> 
            <Animations> 
                <OnClick> 
                    <%-- We need set the AnimationTarget with the control which needs to make animation --%> 
                    <Sequence AnimationTarget="Popup"> 
                        <%--The FadeIn and Display animation.--%>                      
                        <FadeIn Duration="1" MinimumOpacity="0" MaximumOpacity="1" /> 
                    </Sequence> 
                </OnClick> 
            </Animations> 
        </ajaxToolkit:AnimationExtender> 
         
        <ajaxToolkit:AnimationExtender ID="AEFadeOut" runat="server" Enabled="True" TargetControlID="hfFadeIn"> 
            <Animations> 
                <OnClick> 
                    <%-- We need set the AnimationTarget with the control which needs to make animation --%> 
                    <Sequence AnimationTarget="Popup"> 
                        <%--The FadeOut and Display animation.--%>                      
                        <FadeOut Duration="1" MinimumOpacity="0" MaximumOpacity="1" /> 
                    </Sequence> 
                </OnClick> 
            </Animations> 
        </ajaxToolkit:AnimationExtender> 
        <%-- Dummy TargetControl HiddenField--%> 
        <asp:HiddenField runat="server" ID="hfFadeIn" /> 
        <%-- ************** --%> 
        <a id="showModalPopupClientButton" onclick="show(id)" class="nav" href="http://forums.asp.net/AddPost.aspx?ForumID=1022#"> 
            <strong>Click Here</strong></a><br /> 
        <asp:Button runat="server" ID="hiddenTargetControlForModalPopup" Style="display: none" /> 
        <ajaxToolkit:ModalPopupExtender runat="server" ID="programmaticModalPopup" BehaviorID="programmaticModalPopupBehavior" 
            TargetControlID="hiddenTargetControlForModalPopup" PopupControlID="Popup" BackgroundCssClass="modalBackground"> 
        </ajaxToolkit:ModalPopupExtender> 
        <asp:Panel runat="server" ID="Popup" Style="display: none; width: 600px; height: 400px; 
            background-color: White; border-width: 2px; border-color: #009933; border-style: solid; 
            padding: 10px;"> 
            <img src="images/block.gif" alt="" /> 
            <div class="right"> 
                -<a id="hideModalPopupViaClientButton"  onclick="hide(id)" class="nav" href="http://forums.asp.net/AddPost.aspx?ForumID=1022#"> 
                    close </a>- 
            </div> 
        </asp:Panel> 
    </div> 
    </form> 
</body> 
</html>