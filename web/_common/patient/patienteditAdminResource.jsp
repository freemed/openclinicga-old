<%@ page import="java.util.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/_common/patient/patienteditHelper.jsp"%>
<%
    if((activePatient!=null)&&(request.getParameter("SavePatientEditForm")==null)) {

        String sCategoryDescr = "&nbsp;";
        String sCategory = checkString((String)activePatient.adminextends.get("category"));
        if (sCategory.length()>0) {
            sCategoryDescr = getTranNoLink("admin.category",sCategory,sWebLanguage);
        }

        String sGroup = checkString((String)activePatient.adminextends.get("usergroup"));
        String sStatut = checkString((String)activePatient.adminextends.get("statut"));
        String sStatutDescr = "<select name='RStatut' select-one class='text'><option value=''/>"
            +ScreenHelper.writeSelect("admin.statut",sStatut,sWebLanguage)+"</select>";

        %>
        <table border='0' width='100%' class="list" cellspacing="1" style="border-top:none;">
            <tr>
                <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("admin","category",sWebLanguage)%></td>
                <td class="admin2">
                    <input type="text" readonly class="text" name="RCategoryText" value="<%=sCategoryDescr%>" size="<%=sTextWidth%>">
                    <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchCategory('RCategory','RCategoryText');">
                    <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="PatientEditForm.RCategory.value='';PatientEditForm.RCategoryText.value='';">
                    <input type="hidden" name="RCategory" value="<%=sCategory%>">
                </td>
            </tr>
             <tr>
                <td class="admin"><%=getTran("admin","statut",sWebLanguage)%></td>
                <td class="admin2"><%=sStatutDescr%></td>
            </tr>
             <tr>
                <td class="admin"><%=getTran("admin","group",sWebLanguage)%></td>
                <td class="admin2">
                	<select name="RGroup" class="text">
                		<option value=''/>
                		<%=ScreenHelper.writeSelect("usergroup",sGroup,sWebLanguage)%>
                	</select>
                </td>
            </tr>
        </table>
        <script>
            function searchCategory(CategoryUidField,CategoryNameField){
                openPopup("/_common/search/searchCategory.jsp&ts=<%=getTs()%>&VarCode="+CategoryUidField+"&VarText="+CategoryNameField);
              }
        </script>
        <%
    }
%>