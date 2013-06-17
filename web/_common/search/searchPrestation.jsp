<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>
<%=sJSSORTTABLE%>
<%


    String sFindPrestationCode = checkString(request.getParameter("FindPrestationCode")),
            sFindPrestationDescr = checkString(request.getParameter("FindPrestationDescr")),
            sFindPrestationType = checkString(request.getParameter("FindPrestationType")),
            sFindPrestationPrice = checkString(request.getParameter("FindPrestationPrice"));

    String sFunction = checkString(request.getParameter("doFunction"));

    String sReturnFieldUid = checkString(request.getParameter("ReturnFieldUid")),
            sReturnFieldCode = checkString(request.getParameter("ReturnFieldCode")),
            sReturnFieldDescr = checkString(request.getParameter("ReturnFieldDescr")),
            sReturnFieldDescrHtml = checkString(request.getParameter("ReturnFieldDescrHtml")),
            sReturnFieldType = checkString(request.getParameter("ReturnFieldType")),
            sReturnFieldPrice = checkString(request.getParameter("ReturnFieldPrice"));


    String sCurrency = MedwanQuery.getInstance().getConfigParam("currency", "€");
%>
<form name="SearchForm" method="POST" onkeyup="if(enterEvent(event,13)){searchPrestations();}">
    <%-- hidden fields --%>
    <input type="hidden" name="Action">
    <input type="hidden" name="ReturnFieldUid" value="<%=sReturnFieldUid%>">
    <input type="hidden" name="ReturnFieldCode" value="<%=sReturnFieldCode%>">
    <input type="hidden" name="ReturnFieldDescr" value="<%=sReturnFieldDescr%>">
    <input type="hidden" name="ReturnFieldType" value="<%=sReturnFieldType%>">
    <input type="hidden" name="ReturnFieldPrice" value="<%=sReturnFieldPrice%>">

    <table width="100%" cellspacing="1" cellpadding="0" class="menu">
        <%
            if (!"no".equalsIgnoreCase(request.getParameter("header"))) {
        %>
        <%-- TITLE --%>
        <tr class="admin">
            <td colspan="4"><%=getTran("web", "searchprestation", sWebLanguage)%>
            </td>
        </tr>
        <tr>
            <td class="admin2" width="120" nowrap><%=getTran("web", "code", sWebLanguage)%>
            </td>
            <td class="admin2" width="380" nowrap>
                <input type="text" class="text" name="FindPrestationCode" size="20" maxlength="20"
                       value="<%=sFindPrestationCode%>">
            </td>
        </tr>
        <tr>
            <td class="admin2"><%=getTran("web", "description", sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="text" class="text" name="FindPrestationDescr" size="60" maxlength="60"
                       value="<%=sFindPrestationDescr%>">
            </td>
        </tr>
        <tr>
            <td class="admin2"><%=getTran("web", "type", sWebLanguage)%>
            </td>
            <td class="admin2">
                <select class="text" name="FindPrestationType">
                    <option value=""></option>
                    <%=ScreenHelper.writeSelect("prestation.type", sFindPrestationType, sWebLanguage)%>
                </select>
            </td>
        </tr>
        <tr>
            <td class="admin2"><%=getTran("web", "price", sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="text" class="text" name="FindPrestationPrice" size="10" maxlength="8"
                       onKeyUp="if(!isNumber(this)){this.value='';}" value="<%=sFindPrestationPrice%>">&nbsp;<%=
                sCurrency%>
            </td>
        </tr>
        <tr>
            <td class="admin2"><%=getTran("web","sort",sWebLanguage)%></td>
            <td class="admin2">
                <select class="text" name="FindPrestationSort">
                    <option value="OC_PRESTATION_DESCRIPTION"><%=getTran("web","description",sWebLanguage) %></option>
                    <option value="OC_PRESTATION_CODE"><%=getTran("web","code",sWebLanguage) %></option>
                    <option value="OC_PRESTATION_PRICE"><%=getTran("web","price",sWebLanguage) %></option>
                </select>
            </td>
        </tr>
        <tr height="25">
            <td class="admin2">&nbsp;</td>
            <td class="admin2">
                <input class="button" type="button" onClick="searchPrestations();" name="searchButton"
                       value="<%=getTran("Web","search",sWebLanguage)%>">&nbsp;
                <input class="button" type="button" onClick="clearFields();" name="clearButton"
                       value="<%=getTran("Web","clear",sWebLanguage)%>">
            </td>
        </tr>
        <%
            }
        %>
        <%-- SEARCH RESULTS TABLE --%>
        <tr>
            <td valign="top" colspan="2" class="white" width="100%">
                <div id="divFindRecords">
                </div>
            </td>
        </tr>
    </table>
    <br>
    <center>
        <input type="button" class="button" name="buttonclose" value="<%=getTran("Web","Close",sWebLanguage)%>"
               onclick="window.close();">
    </center>
</form>

<script>
    window.resizeTo(800, 600);
    SearchForm.FindPrestationDescr.focus();

    function clearFields() {
        SearchForm.FindPrestationRefName.value = "";
        SearchForm.FindPrestationCode.value = "";
        SearchForm.FindPrestationDescr.value = "";
        SearchForm.FindPrestationType.value = "";
        SearchForm.FindPrestationPrice.value = "";
        SearchForm.FindPrestationCode.focus();
    }

    function searchPrestations() {
        SearchForm.Action.value = "search";
        ajaxChangeSearchResults('_common/search/searchByAjax/searchPrestationShow.jsp', SearchForm);
    }

    function setPrestation(uid, code, descr, type, price) {
        if ("<%=sReturnFieldUid%>".length > 0) {
            window.opener.document.getElementsByName("<%=sReturnFieldUid%>")[0].value = uid;
        }
        if ("<%=sReturnFieldCode%>".length > 0) {
            window.opener.document.getElementsByName("<%=sReturnFieldCode%>")[0].value = code;
        }
        if ("<%=sReturnFieldDescr%>".length > 0) {
            window.opener.document.getElementsByName("<%=sReturnFieldDescr%>")[0].value = descr;
        }
        if ("<%=sReturnFieldDescrHtml%>".length > 0) {
            window.opener.document.getElementById("<%=sReturnFieldDescrHtml%>").innerHTML = descr;
        }
        if ("<%=sReturnFieldType%>".length > 0) {
            window.opener.document.getElementsByName("<%=sReturnFieldType%>")[0].value = type;
        }
        if ("<%=sReturnFieldPrice%>".length > 0) {
            window.opener.document.getElementsByName("<%=sReturnFieldPrice%>")[0].value = price;
        }

    <%
    if (sFunction.length()>0){
        out.print("window.opener."+sFunction+";");
    }
    %>

        window.close();
    }
    window.setTimeout("document.getElementsByName('FindPrestationDescr')[0].focus();")
</script>
