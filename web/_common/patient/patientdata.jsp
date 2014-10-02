<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    if ((activePatient!=null) && (activePatient.personid.length()>0)) {
        String tab = checkString(request.getParameter("Tab"));
        if(tab.equals("")) tab = "Admin";
        %>
            <%-- TABS ---------------------------------------------------------------------------%>
            <table width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <td class='tabs' width='5'>&nbsp;</td>
                    <td class='tabunselected' width="1%" onclick="activateTab('Admin')" id="td0" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"' nowrap>&nbsp;<b><%=getTran("Web","actualpersonaldata",sWebLanguage)%></b>&nbsp;</td>
                    <td class='tabs' width='5'>&nbsp;</td>
                    <td class='tabunselected' width="1%" onclick="activateTab('AdminPrivate')" id="td1" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"' nowrap>&nbsp;<b><%=getTran("Web","private",sWebLanguage)%></b>&nbsp;</td>
                    <td class='tabs' width='5'>&nbsp;</td>
                    <td class='tabunselected' width="1%" onclick="activateTab('AdminFamilyRelation')" id="td3" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"' nowrap>&nbsp;<b><%=getTran("Web","AdminFamilyRelation",sWebLanguage)%></b>&nbsp;</td>
                    <td class='tabs' width='5'>&nbsp;</td>
                    <td class='tabunselected' width="1%" onclick="activateTab('AdminResource')" id="td4" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"' nowrap>&nbsp;<b><%=getTran("Web","AdminResource",sWebLanguage)%></b>&nbsp;</td>
                    <td width="*" class='tabs'>&nbsp;</td>
                </tr>
            </table>
            
            <%-- ONE TAB ------------------------------------------------------------------------%>
            <table style="vertical-align:top;" width="100%" border="0" cellspacing="0" cellpadding="0">
                <tr id="tr0-view" style="display:none">
                    <td><%ScreenHelper.setIncludePage(customerInclude("_common/patient/patientdataAdmin.jsp"),pageContext);%></td>
                </tr>
                <tr id="tr1-view" style="display:none">
                    <td><%ScreenHelper.setIncludePage(customerInclude("_common/patient/patientdataAdminPrivate.jsp"),pageContext);%></td>
                </tr>
                <tr id="tr3-view" style="display:none">
                    <td><%ScreenHelper.setIncludePage(customerInclude("_common/patient/patientdataAdminFamilyRelation.jsp"),pageContext);%></td>
                </tr>
                <tr id="tr4-view" style="display:none">
                    <td><%ScreenHelper.setIncludePage(customerInclude("_common/patient/patientdataAdminResource.jsp"),pageContext);%></td>
                </tr>
            </table>
            
            <script>
              function activateTab(sTab){
                document.getElementById('tr0-view').style.display = 'none';
                td0.className="tabunselected";
                if(sTab=='Admin'){
                  document.getElementById('tr0-view').style.display = '';
                  td0.className="tabselected";
                 }

                document.getElementById('tr1-view').style.display = 'none';
                td1.className="tabunselected";
                if(sTab=='AdminPrivate'){
                  document.getElementById('tr1-view').style.display = '';
                  td1.className="tabselected";
                }
                document.getElementById('tr3-view').style.display = 'none';
                td3.className="tabunselected";
                if(sTab=='AdminFamilyRelation'){
                  document.getElementById('tr3-view').style.display = '';
                  td3.className="tabselected";
                }

                document.getElementById('tr4-view').style.display = 'none';
                td4.className="tabunselected";
                if(sTab=='AdminResource'){
                  document.getElementById('tr4-view').style.display = '';
                  td4.className="tabselected";
                }
              }
              activateTab('<%=tab%>');
            </script>
        <%
    }
    else{
        out.print("No patient selected");
    }
%>