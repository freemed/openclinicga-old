<%@ page import="be.openclinic.adt.Bed,be.openclinic.adt.Encounter,java.util.Vector,java.util.Hashtable" %>
<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>

<%
    String sFindBedName = checkString(request.getParameter("FindBedName"));
    String sVarCode = checkString(request.getParameter("VarCode"));
    String sVarText = checkString(request.getParameter("VarText"));
    String sServiceUID = checkString(request.getParameter("ServiceUID"));
%>
<form name='SearchForm' method="POST" onSubmit="doFind();" onkeydown="if(enterEvent(event,13)){doFind();}">
    <input type="hidden" name="VarCode" value="<%=sVarCode%>">
    <input type="hidden" name="VarText" value="<%=sVarText%>">
    <table width='100%' border='0' cellspacing='0' cellpadding='0' class='menu'>
        <%-- search fields row 1 --%>
        <tr height='25'>
            <td nowrap>
                <%=getTran("web", "service", sWebLanguage)%>
                <br/><%=getTran("web", "bed", sWebLanguage)%>&nbsp;&nbsp;
            </td>
            <td nowrap>
                <select class='text' name='ServiceUID' id='ServiceUid' onchange='doFind();'>
                	<option/>
                	<%
                		//We maken een lijst van alle diensten met hospitalisatie
                		Vector services = Service.getServicesWithBeds();
	                	for(int n=0;n<services.size();n++){
							Service service = (Service)services.elementAt(n);
	                		out.println("<option value='"+service.code+"'"+(service.code.equalsIgnoreCase(sServiceUID)?" selected ":"")+">"+service.code+": "+service.getLabel(sWebLanguage)+"</option>");								                		
	                	}
                	%>
                </select>
                <br/><input type="text" name='FindBedName' class="text" value="<%=sFindBedName%>"
                       onblur='validateText(this);limitLength(this);' size="50">
            </td>
            <td style='text-align:right'>
                <%-- BUTTONS --%>
                <input class="button" type="button" onClick="doFind();" name="findButton"
                       value="<%=getTran("Web","find",sWebLanguage)%>">
                <input class="button" type="button" onClick="clearFields();" name="clearButton"
                       value="<%=getTran("Web","clear",sWebLanguage)%>">&nbsp;
            </td>
        </tr>

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
        window.resizeTo(600, 520);
        SearchForm.FindBedName.focus();
        doFind();
        <%-- CLEAR FIELDS --%>
        function clearFields() {
            SearchForm.FindBedName.value = "";
            SearchForm.FindBedName.focus();
        }

        <%-- DO FIND --%>
        function doFind() {
            ajaxChangeSearchResults('_common/search/searchByAjax/searchBedShow.jsp', SearchForm);
        }

        <%-- SET BED --%>
        function setBed(sBedUID, sBedName) {
            window.opener.document.getElementsByName('<%=sVarCode%>')[0].value = sBedUID;

            if ('<%=sVarText%>' != '') {
                window.opener.document.getElementsByName('<%=sVarText%>')[0].value = document.getElementById('ServiceUid').value+': '+sBedName;
            }

            window.close();
        }
        <%-- OPEN ENCOUNTER WHERE BED IS OCCUPIED --%>
        function editEncounter(encounterUid) {
            openPopup("adt/editEncounter.jsp&EditEncounterUID=" + encounterUid + "&Popup=yes&ts=<%=getTs()%>", "editEncounterPopup<%=new java.util.Date().getTime()%>");
        }

        <%-- search service --%>
        function searchService(serviceUidField, serviceNameField) {
            openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode=" + serviceUidField + "&VarText=" + serviceNameField);
        }

        <%-- TOGGLE BED INFO --%>
        function toggleBedInfo(id) {
            if (document.getElementById(id).style.display == "none") {
                document.getElementById(id).style.display = "";
            }
            else {
                document.getElementById(id).style.display = "none";
            }
        }
    </script>
</form>
