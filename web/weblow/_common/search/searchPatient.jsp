<%@ page import="java.util.Vector,java.util.Hashtable" %>
<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>
<%
    String sFindLastname = checkString(request.getParameter("FindLastname")),
           sFindFirstname = checkString(request.getParameter("FindFirstname")),
           sFindDOB = checkString(request.getParameter("FindDOB")),
           sFindGender = checkString(request.getParameter("FindGender")),
           sReturnPersonID = checkString(request.getParameter("ReturnPersonID")),
           sSetGreenField = checkString(request.getParameter("SetGreenField"));

    if (sReturnPersonID.length() == 0) {
        sReturnPersonID = checkString(request.getParameter("ReturnField"));
    }

    String sReturnName = checkString(request.getParameter("ReturnName"));
    boolean bIsUser = checkString(request.getParameter("isUser")).equalsIgnoreCase("yes");
%>
<form name="SearchForm" method="POST" onsubmit="doFind();return false;"  onkeydown="if(enterEvent(event,13)){doFind();}">
    <table width="100%" cellspacing="0" cellpadding="0" class="menu">
        <%-- search fields row 1 --%>
        <tr height="25">
            <td nowrap>&nbsp;<%=getTran("Web", "name", sWebLanguage)%>&nbsp;&nbsp;</td>
            <td nowrap>
                <input type="text" name="FindLastname" class="text" value="<%=sFindLastname%>"
                       onblur="validateText(this);limitLength(this);" >
            </td>
            <td nowrap>&nbsp;<%=getTran("Web", "firstname", sWebLanguage)%>&nbsp;&nbsp;</td>
            <td nowrap>
                <input type="text" name="FindFirstname" class="text" value="<%=sFindFirstname%>"
                       onblur="validateText(this);limitLength(this);">
            </td>
        </tr>
        <%
            if (!bIsUser) {
        %>
        <%-- search fields row 2 --%>
        <tr>
            <td height="25" nowrap>&nbsp;<%=getTran("Web", "dateofbirth", sWebLanguage)%>&nbsp;&nbsp;</td>
            <td nowrap>
                <input type="text" name="FindDOB" class="text" value="<%=sFindDOB%>" onblur="checkDate(this);">
            </td>
            <td nowrap>&nbsp;<%=getTran("Web", "gender", sWebLanguage)%>&nbsp;&nbsp;</td>
            <td nowrap>
                <select class="text" name="FindGender">
                    <option/>
                    <option value="M"<%=(sFindGender.equalsIgnoreCase("m") ? " selected" : "")%>>M</option>
                    <option value="F"<%=(sFindGender.equalsIgnoreCase("f") ? " selected" : "")%>>F</option>
                </select>&nbsp;
            </td>
        </tr>
        <%
            }
        %>
        <tr>
            <td>&nbsp;</td>
            <%-- BUTTONS --%>
            <td height="25">
                <input class="button" type="button" name="buttonfind" value="<%=getTran("Web","find",sWebLanguage)%>"
                       onClick="doFind();">&nbsp;
                <input class="button" type="button" name="buttonclear" value="<%=getTran("Web","clear",sWebLanguage)%>"
                       onclick="clearFields();">
            </td>
        </tr>
        <%-- SEARCH RESULTS TABLE --%>
        <tr>
            <td valign="top" colspan="4" align="center" class="white" width="100%">
                <div id="divFindRecords">
                </div>
            </td>
        </tr>
    </table>

    <%-- hidden fields --%>
    <input type="hidden" name="isUser" value="<%=checkString(request.getParameter("isUser"))%>">
    <input type="hidden" name="displayImmatNew" value="<%=checkString(request.getParameter("displayImmatNew"))%>">
    <input type="hidden" name="ReturnPersonID" value="<%=sReturnPersonID%>">
    <input type="hidden" name="ReturnName" value="<%=sReturnName%>">
    <input type="hidden" name="SetGreenField" value="<%=sSetGreenField%>">
    <br>
    <%-- CLOSE BUTTON --%>
    <center>
        <input type="button" class="button" name="buttonclose" value="<%=getTran("Web","Close",sWebLanguage)%>"
               onclick="window.close();">
    </center>
</form>
<script>
    window.resizeTo(500, 540);

    <%-- CLEAR FIELDS --%>
    function clearFields() {
        SearchForm.FindLastname.value = "";
        SearchForm.FindFirstname.value = "";
        SearchForm.FindDOB.value = "";
        SearchForm.FindGender.selectedIndex = -1;
        SearchForm.FindLastname.focus();
    }

    <%-- DO FIND --%>
    function doFind() {
        if (SearchForm.FindDOB.value.length > 0) {
            if (checkDate(SearchForm.FindDOB)) {
                ajaxChangeSearchResults('_common/search/searchByAjax/searchPatientShow.jsp', SearchForm);
            }
            else {
                SearchForm.FindDOB.value = "";
                SearchForm.FindDOB.focus();
            }
        }
        else {
            ajaxChangeSearchResults('_common/search/searchByAjax/searchPatientShow.jsp', SearchForm);
        }
    }

    <%-- SET PERSON --%>
    function setPerson(sPersonID, sName) {
        window.opener.document.all["<%=sReturnPersonID%>"].value = sPersonID;

        if ("<%=sSetGreenField%>" != "") {
            window.opener.document.all["<%=sSetGreenField%>"].className = "green";
        }

        if ("<%=sReturnName%>" != "") {
            window.opener.document.all["<%=sReturnName%>"].value = sName;
        }

        window.close();
    }

    function addPerson(){
        if (($("FindLastname").value.length>0)&&($("FindFirstname").value.length>0)&&($("FindDOB").value.length>0)&&($("FindGender").value.length>0)){
            ajaxChangeSearchResults('_common/search/searchByAjax/searchPatientAdd.jsp', SearchForm);
        }
        else {
            alert("<%=getTranNoLink("web","somefieldsareempty",sWebLanguage)%>");
        }
    }
    
    SearchForm.FindLastname.focus();
</script>