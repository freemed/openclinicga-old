<%@ page import="be.openclinic.id.FingerPrint,be.mxs.common.util.system.Picture, be.openclinic.id.Barcode" %>
<%@page errorPage="/includes/error.jsp"%><%@include file="/includes/validateUser.jsp"%>
<script>
    function setButtonCheckDropDown(){
        if (!bSaveHasNotChanged) {
            if(checkSaveButton()){
               // target.click();
            }
        }
    }
    function checkDropdown(evt) {
        if (window.myButton) {
            lastevt = evt || window.event;
            var target;
            if(lastevt.target){
                target = lastevt.target;
            }else{
                target = lastevt.srcElement;
            }
            if ((target.id.indexOf("menu") > -1) || (target.id.indexOf("ddIcon") > -1)) {
                setButtonCheckDropDown();
            }
        }
    }
</script>
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="topline" >
    <tr>
        <%-- ADMIN HEADER --%>
        <td width="100%" valign='top' align="left">
            <table width="100%" cellspacing="0" cellpadding="0" border="0">
                <tr onmousedown="checkDropdown(event);">
                    <td class="menu_bar" style="vertical-align:top;"  colspan="3">
                        <%ScreenHelper.setIncludePage(customerInclude("/accountancy/dropdownmenu.jsp"), pageContext);%>
                    </td>

                </tr>
            </table>
        </td>
    </tr>
</table>
