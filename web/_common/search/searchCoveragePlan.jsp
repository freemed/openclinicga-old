<%@ page import="be.openclinic.finance.Wicket,java.util.Vector" %>
<%@ page import="be.openclinic.finance.Insurar" %>
<%@ page import="be.openclinic.finance.InsuranceCategory" %>
<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>
<%
    String sFindInsurarName = checkString(request.getParameter("FindInsurarName"));
    String sVarCode = checkString(request.getParameter("VarCode"));
    String sVarText = checkString(request.getParameter("VarText"));
    String sVarCat = checkString(request.getParameter("VarCat"));
    String sVarCatLetter = checkString(request.getParameter("VarCatLetter"));
    String sVarTyp = checkString(request.getParameter("VarTyp"));
    String sVarTypName = checkString(request.getParameter("VarTypName"));
    String sVarCompUID = checkString(request.getParameter("VarCompUID"));
    String sFunction = checkString(request.getParameter("doFunction"));

%>
<form name='SearchForm' method="POST" onSubmit="doFind();return false;" onsubmit="doFind();return false;">
    <input type="hidden" name="VarCode" value="<%=sVarCode%>">
    <input type="hidden" name="VarText" value="<%=sVarText%>">
    <input type="hidden" name="VarCat" value="<%=sVarCat%>">
    <input type="hidden" name="VarCatLetter" value="<%=sVarCatLetter%>">
    <table width='100%' border='0' cellspacing='0' cellpadding='0' class='menu'>
        <%-- search fields row 1 --%>
        <%-- service --%>
        <%
            if (!"false".equalsIgnoreCase(request.getParameter("header"))) {
        %>
        <tr>
            <td><%=getTran("Web", "coverageplan", sWebLanguage)%>
            </td>
            <td>
                <input class="text" type="text" name="FindInsurarName" size="<%=sTextWidth%>"
                       value="<%=sFindInsurarName%>">
            </td>
        </tr>
        <tr height='25'>
            <td/>
            <td>
                <%-- BUTTONS --%>
                <input class="button" type="button" onClick="doFind();" name="findButton"
                       value="<%=getTran("Web","find",sWebLanguage)%>">
                <input class="button" type="button" onClick="clearFields();" name="clearButton"
                       value="<%=getTran("Web","clear",sWebLanguage)%>">&nbsp;
            </td>
        </tr>
        <%
            }
        %>
        <%-- SEARCH RESULTS TABLE --%>
        <tr>
            <td style="vertical-align:top;" colspan="3" align="center" class="white" width="100%">
                <div id="divFindRecords">
                </div>
            </td>
        </tr>
    </table>
    <br>

    <%-- CLOSE BUTTON --%>
    <center>
        <input type="button" class="button" name="buttonclose" value='<%=getTran("Web","Close",sWebLanguage)%>'
               onclick='window.close()'>
    </center>

    <script>
        window.resizeTo(500, 510);

        <%-- CLEAR FIELDS --%>
        function clearFields() {
            SearchForm.FindInsurarName.value = "";
        }

        <%-- DO FIND --%>
        function doFind() {
            ajaxChangeSearchResults('_common/search/searchByAjax/searchCoveragePlanShow.jsp', SearchForm);
        }

        <%-- SET BALANCE --%>
        function setInsuranceCategory(sInsuranceCategoryLetter, sInsurarUID, sInsurarName, sInsuranceCategoryName, sInsuranceType, sInsuranceTypeName) {
            if ('<%=sVarCode%>' != '') {
                window.opener.document.getElementsByName('<%=sVarCode%>')[0].value = sInsuranceCategoryLetter;
            }

            if ('<%=sVarText%>' != '') {
                window.opener.document.getElementsByName('<%=sVarText%>')[0].value = sInsurarName;
            }

            if ('<%=sVarCompUID%>' != '') {
                window.opener.document.getElementsByName('<%=sVarCompUID%>')[0].value = sInsurarUID;
            }

            if ('<%=sVarCat%>' != '') {
                window.opener.document.getElementsByName('<%=sVarCat%>')[0].value = sInsuranceCategoryName;
            }
            if ('<%=sVarTyp%>' != '') {
                window.opener.document.getElementsByName('<%=sVarTyp%>')[0].value = sInsuranceType;
            }
            if ('<%=sVarTypName%>' != '') {
                window.opener.document.getElementsByName('<%=sVarTypName%>')[0].value = sInsuranceTypeName;
            }

    	    <%
    	    if (sFunction.length()>0){
    	        out.print("window.opener."+sFunction+";");
    	    }
    	    %>

            window.close();
        }
        window.setTimeout("document.getElementsByName('FindInsurarName')[0].focus();document.getElementsByName('FindInsurarName')[0].select();", 100);
		doFind();
    </script>
</form>
