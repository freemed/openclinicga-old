<%@ page import="be.openclinic.finance.Prestation,
                 be.openclinic.finance.PrestationGroup"%>
<%@ page import="java.util.*" %>
<%@include file="/includes/validateUser.jsp"%>

<%=checkPermission("financial.prestationgroup","all",activeUser)%>

<%
    String sFindPrestationGroupDescription = checkString(request.getParameter("FindPrestationGroupDescription"));
    
    String sEditPrestationGroupDescription = checkString(request.getParameter("EditPrestationGroupDescription"));
    String sEditPrestationGroupUID         = checkString(request.getParameter("EditPrestationGroupUID"));
    String sEditPrestationToAdd            = checkString(request.getParameter("EditPrestationToAdd"));
    String sEditPrestationToDelete         = checkString(request.getParameter("EditPrestationToDelete"));

    String sAction = checkString(request.getParameter("Action"));

    if(Debug.enabled){
        Debug.println("\n###############################################################" +
                      "\nsEditPrestationGroupDescription = " + sEditPrestationGroupDescription +
                      "\nsEditPrestationGroupUID         = " + sEditPrestationGroupUID         +
                      "\nsEditPrestationToAdd            = " + sEditPrestationToAdd            +
                      "\nsAction                         = " + sAction                         +
                      "\n###############################################################"
                        );
    }

    if(sAction.equals("SAVE")){
        PrestationGroup pgPrestationGroup = new PrestationGroup();
        if(sEditPrestationGroupUID.length() > 0){
            pgPrestationGroup = PrestationGroup.get(sEditPrestationGroupUID);
        }else{
            pgPrestationGroup.setCreateDateTime(ScreenHelper.getSQLDate(getDate()));
        }
        pgPrestationGroup.setDescription(sEditPrestationGroupDescription);
        pgPrestationGroup.setUpdateDateTime(ScreenHelper.getSQLDate(getDate()));
        pgPrestationGroup.setUpdateUser(activeUser.userid);
        pgPrestationGroup.store();
        sEditPrestationGroupUID = pgPrestationGroup.getUid();

    }

    if(sAction.equals("ADD") && sEditPrestationGroupUID.length() > 0){
        PrestationGroup pgPrestationGroup = PrestationGroup.get(sEditPrestationGroupUID);
        Prestation prestation = Prestation.get(sEditPrestationToAdd);
        pgPrestationGroup.addPrestation(prestation);
        pgPrestationGroup.store();

    }

    if(sAction.equals("DELETE") && sEditPrestationGroupUID.length() > 0){
        PrestationGroup pgPrestationGroup = PrestationGroup.get(sEditPrestationGroupUID);
        Hashtable tmpPrestations = pgPrestationGroup.getPrestations();
        tmpPrestations.remove(sEditPrestationToDelete);
        pgPrestationGroup.setPrestations(tmpPrestations);
        pgPrestationGroup.store();

    }

    if(sEditPrestationGroupUID.length() > 0){
        PrestationGroup prestationGrp = PrestationGroup.get(sEditPrestationGroupUID);
        sEditPrestationGroupDescription = checkString(prestationGrp.getDescription());
    }
%>
<%-- Find Block --%>

<form name='FindPrestationGrpForm' method='POST' action='<c:url value='/main.do'/>?Page=financial/managePrestationGroups.jsp&ts=<%=getTs()%>'>
    <%=writeTableHeader("Web.manage","manageprestationgroups",sWebLanguage," doBack();")%>
    <table class='menu' border='0' cellspacing='0' width='100%'>
        <tr>
            <td width='<%=sTDAdminWidth%>'>
                <%=getTran("web","description",sWebLanguage)%>
            </td>

            <td>
                <input class='text' type='text' name='FindPrestationGroupDescription' value='' size='40'>
            </td>
        </tr>
        <%-- buttons: search,clear,new --%>
        <tr>
            <td/>
            <td>
                <input class='button' type='button' name='buttonfind' value='<%=getTranNoLink("Web","search",sWebLanguage)%>' onclick='doFind();'>
                <input class='button' type='button' name='buttonclear' value='<%=getTranNoLink("Web","Clear",sWebLanguage)%>' onclick='doClear();'>
                <input class='button' type='button' name='buttonnew' value='<%=getTranNoLink("Web.Occup","medwan.common.create-new",sWebLanguage)%>' onclick='doNew();'>&nbsp;
            </td>
        </tr>
        <%-- action --%>
        <input type='hidden' name='Action' value=''>
    </table>
</form>

<%-- End Find Block --%>

<%-- Results Block--%>
<%
    if(sAction.equals("SEARCH")){
        %>
        <table class='list' cellspacing='0' border='0' width='100%'>
            <tr class='admin'>
                <td>
                    <%=getTran("web","description",sWebLanguage)%>
                </td>
            </tr>
            <%
                Vector vPrestationGrps = PrestationGroup.getPrestationGroups(sFindPrestationGroupDescription + "%");
                Iterator iter = vPrestationGrps.iterator();

                String sClass = "";
                PrestationGroup objPrestGrp;
                while(iter.hasNext()){
                    objPrestGrp = (PrestationGroup)iter.next();
                    if (sClass.equals("")) {
                        sClass = "1";
                    } else {
                        sClass = "";
                    }
                    out.print("<tr class='list" + sClass + "' onmouseover=\"this.className = 'list_select';this.style.cursor='hand'\"" +
                            " onmouseout=\"this.className = 'list" + sClass + "';this.style.cursor='default'\"" +
                            " onclick='selectPrestationGrp(\"" + checkString(objPrestGrp.getUid()) + "\");'>" +
                            "<td>" + checkString(objPrestGrp.getDescription()) +
                            "</td>" +
                            "</tr>");
                }
            %>
        </table>
        <%
    }
%>
<%-- End Results Block--%>

<%-- Edit Block --%>
<%
    if(sAction.equals("SELECT") || sAction.equals("NEW") || sAction.equals("SAVE") || sAction.equals("ADD") || sAction.equals("DELETE")){

%>
<form name='EditPrestationGrpForm' method='POST' action="<c:url value='/main.do'/>?Page=financial/managePrestationGroups.jsp&ts=<%=getTs()%>">
    <table class='list' cellspacing='1' width='100%'>
        <tr>
            <td class='admin' width='<%=sTDAdminWidth%>' valign='top'><%=getTran("web","description",sWebLanguage)%></td>
            <td class='admin2'><%=writeTextarea("EditPrestationGroupDescription","","","",sEditPrestationGroupDescription)%></td>
        </tr>
        <tr>
            <td class='admin' valign='top'><%=getTran("web","prestations",sWebLanguage)%></td>
            <td class='admin2'>
            <table class='list' border='0' cellspacing='0' cellpadding='0' width='100%'>
                <%
                    if(sEditPrestationGroupUID.length() > 0){
                %>
                <tr>
                    <td colspan='3'>
                        &nbsp;<%=getTran("web","prestations",sWebLanguage)%>:
                        <select class='text' name='EditPrestationToAdd'>
                            <option/>
                            <%
                                Vector vPrestations = Prestation.getAllPrestations();
                                Iterator iter = vPrestations.iterator();

                                Prestation prestation;
                                while(iter.hasNext()){
                                    prestation = (Prestation)iter.next();
                                    out.print("<option value='" + checkString(prestation.getUid()) + "'>" + checkString(prestation.getDescription()) + "</option>");
                                }
                            %>
                        </select>
                        <input class='button' type='button' name='addPrestationButton' value='Add Prestation' onclick='addPrestation();'>
                    </td>
                </tr>
                <%
                    }
                %>
                <tr>
                    <td colspan='3'>&nbsp;</td>
                </tr>
                <tr class='admin'>
                    <td width='3%'/>
                    <td width='67%'>
                         <%=getTran("web","description",sWebLanguage)%>
                    </td>
                    <td width='30%'>
                         <%=getTran("web","price",sWebLanguage)%>
                    </td>
                </tr>
                <%
                    PrestationGroup pgPrestations = PrestationGroup.get(sEditPrestationGroupUID);

                    Hashtable hPrestationsInGroup = pgPrestations.getPrestations();
                    if (hPrestationsInGroup != null) {
                        Enumeration enum = hPrestationsInGroup.keys();
                        Prestation pPrestation;
                        String sKey;
                        String sClass = "";
                        while (enum.hasMoreElements()) {
                            if (sClass.equals("")) {
                                sClass = "1";
                            } else {
                                sClass = "";
                            }
                            sKey = (String) enum.nextElement();
                            pPrestation = (Prestation) hPrestationsInGroup.get(sKey);
                            out.print("<tr class='list" + sClass + "' >" +
                                    "<td align='center' onmouseover=\"this.style.cursor='hand';\" onmouseout=\"this.style.cursor='default';\" onclick=\"deletePrestation('" + pPrestation.getUid() + "');\"><img src='" + request.getContextPath() + "/_img/icons/icon_delete.gif' alt='delete'></td>" +
                                    "<td>" + pPrestation.getDescription() + "</td>" +
                                    "<td>" + pPrestation.getPrice() + "</td>" +
                                    "</tr>");
                        }
                    }


                %>
            </table>
            </td>
        </tr>
    </table>
    <input type='hidden' name='Action' value=''>
    <input type='hidden' name='EditPrestationToDelete' value=''>
    <input type='hidden' name='EditPrestationGroupUID' value='<%=sEditPrestationGroupUID%>'>
</form>
<%
    }
%>
<%=ScreenHelper.alignButtonsStart()%>
    <%-- Buttons --%>
    <%
        if(sAction.equals("NEW") || sAction.equals("SELECT") || sAction.equals("SAVE") || sAction.equals("ADD") || sAction.equals("DELETE")){
    %>
        <input class='button' type="button" name="saveButton" value='<%=getTranNoLink("Web","save",sWebLanguage)%>' onclick="doSave();">&nbsp;
    <%
        }
    %>
    <input class='button' type="button" name="Backbutton" value='<%=getTranNoLink("Web","Back",sWebLanguage)%>' onclick="doBack();">
<%=ScreenHelper.alignButtonsStop()%>
<%-- End Edit Block --%>
<script>
    function doClear(){
        FindPrestationGrpForm.FindPrestationGrpDescription.value = "";
    }
    function doFind(){
        FindPrestationGrpForm.Action.value = "SEARCH";
        FindPrestationGrpForm.buttonfind.disabled = true;
        FindPrestationGrpForm.submit();
    }

    function doBack(){
        window.location.href="<c:url value='/main.do'/>?Page=financial/index.jsp&ts=<%=getTs()%>";
    }

    function doSave(){
        saveButton.disabled = true;
        EditPrestationGrpForm.Action.value = "SAVE";
        EditPrestationGrpForm.submit();
    }

    function doNew(){
        FindPrestationGrpForm.Action.value = "NEW";
        FindPrestationGrpForm.submit();
    }

    function selectPrestationGrp(id){
        window.location.href="<c:url value='/main.do'/>?Page=financial/managePrestationGroups.jsp&Action=SELECT&EditPrestationGroupUID=" + id + "&ts=<%=getTs()%>";
    }

    function addPrestation(){
        saveButton.disabled = true;
        EditPrestationGrpForm.Action.value = "ADD";
        EditPrestationGrpForm.submit();

    }

    function deletePrestation(uid){
        saveButton.disabled = true;
        EditPrestationGrpForm.EditPrestationToDelete.value = uid;
        EditPrestationGrpForm.Action.value = "DELETE";
        EditPrestationGrpForm.submit();
    }
</script>