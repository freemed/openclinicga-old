<%@ page import="be.openclinic.system.Center" %>
<%@ page import="java.util.*" %>
<%@include file="/includes/validateUser.jsp" %>
<%=sJSSORTTABLE%><%String sAction = checkString(request.getParameter("action"));%>
<form id="searchFormForm" name="searchFormForm">
    <table width='100%' class="menu" cellspacing='0'>
        <tr class="admin">
            <td colspan="2"><%=getTran("web", "search", sWebLanguage)%></td>
        </tr>
        <tr>
            <td width="<%=sTDAdminWidth%>"><%=getTran("Web", "Begin", sWebLanguage)%></td>
            <td><%=writeDateField("FindBegin", "searchFormForm", "", sWebLanguage)%></td>
        </tr>
        <tr>
            <td><%=getTran("Web", "End", sWebLanguage)%></td>
            <td><%=writeDateField("FindEnd", "searchFormForm", "", sWebLanguage)%></td>
        </tr>
        <tr>
            <td width="<%=sTDAdminWidth%>">&nbsp;</td>
            <td>
                <input class="button" type="button" onclick="setSearch();" value="<%=getTran("web","search",sWebLanguage)%>" title="<%=getTran("web","new",sWebLanguage)%>" value="<%=getTran("web","new",sWebLanguage)%>"/>
                <input class="button" type="button" onclick="window.location='<c:url value="/main.do"/>?Page=center/manage.jsp&action=set&version=0'" value="<%=getTran("web","new",sWebLanguage)%>" title="<%=getTran("web","new",sWebLanguage)%>" value="<%=getTran("web","new",sWebLanguage)%>"/>
            </td>
        </tr>
    </table>
</form>
<div id="responseByAjax">&nbsp;</div>
<script type="text/javascript">
    var setSearch = function() {
        var params = "FindBegin=" + $F("FindBegin") + "&FindEnd=" + $F("FindEnd") + "&ts=" +<%=getTs()%>;
        var url = '<c:url value="/"/>center/ajax/searchServices.jsp';
        new Ajax.Request(url, {parameters:params,method: "POST",
            onSuccess:function(resp) {
                $("responseByAjax").update(resp.responseText);
            }});
    }
            <%
            if(sAction.length()>0){
               out.write("document.onload = setSearch()");
        }
            %>
</script>