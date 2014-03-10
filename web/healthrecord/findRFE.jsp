<%@ page import="be.openclinic.adt.Encounter" %>
<%@ page import="java.util.Vector" %>
<%@ page import="be.openclinic.medical.ReasonForEncounter" %>
<%@ page import="be.mxs.common.model.vo.healthrecord.ICPCCode" %>
<%@include file="/includes/validateUser.jsp"%>
<!--    Dit scherm geeft een lijst van alle RFE's
        En biedt de mogelijkheid deze te bewerken
-->

<%=sJSPOPUPSEARCH%>
<%=sJSCHAR%>
<%-- Start Floating Layer ------------------------------------------------------------------------%>
<div id="FloatingLayer" style="position:absolute;width:250px;left:225;top:170;visibility:hidden">
    <table border="0" width="250" cellspacing="0" cellpadding="5" style="border:1px solid #aaa">
        <tr>
            <td bgcolor="#dddddd" style="text-align:center">
              <%=getTran("web","searchInProgress",sWebLanguage)%>
            </td>
        </tr>
    </table>
</div>
<%-- End Floating layer --------------------------------------------------------------------------%>
<%
    String encounterUid=checkString(request.getParameter("encounterUid"));
	boolean bManageLocalCodes=activeUser.getAccessRight("system.managelocalrfecodes.edit");
    if(encounterUid.length()==0){
        out.println("<script>window.close();</script>");
        out.flush();
    }
    else {
%>
    <form name="RFEForm" method="post">
        <table class='menu' width='100%' cellspacing="0">
            <tr class="admin"><td colspan="3"><%=getTran("openclinic.chuk","rfe",sWebLanguage)%></td></tr>
            <tr>
                <td nowrap><%=getTran("Web","Keyword",sWebLanguage)%>&nbsp;&nbsp;</td>
                <td colspan='2'>
                    <input type='text' class='text' id='keywords' name='keywords' size='40' value="<%=request.getParameter("keywords")!=null?request.getParameter("keywords"):""%>" onblur="validateText(this);limitLength(this);" onKeyDown='if(event.keyCode==13){doFind();}'/>
                    <input class='button' type='button' name='findButton' onclick='doFind();' value='<%=getTran("Web","Find",sWebLanguage)%>'/>
                    <input class='button' type='button' name='cancel' onclick='window.close()' value='<%=getTran("Web","Close",sWebLanguage)%>'/>
                </td>
            </tr>
            <tr><td class="navigation_line" height="1" colspan="3"></td></tr>
            <%
                String keywords = checkString(request.getParameter("keywords"));
                int foundRecords = 0;
                if(keywords.length()>0){
                    Vector codes = MedwanQuery.getInstance().findICPCCodes(keywords, sWebLanguage);
                    ICPCCode code;

                    // header
                    if (codes.size() > 0) {
                        out.print("<tr class='admin'><td colspan='3'>" + getTran("Web.Occup", "ICPC-2", sWebLanguage) + (bManageLocalCodes?" (<a href='javascript:addnewlocalcode(\""+keywords+"\")'>"+getTran("web","managelocalcodes",sWebLanguage)+"</a>)":"")+"</td></tr>");
                    }

                    %>
                    <tbody onmouseover='this.style.cursor="pointer"' onmouseout='this.style.cursor="default"'>
                    <%
                    String oldcodelabel="";
                    for (int n=0; n<codes.size(); n++){
                        foundRecords++;
                        code = (ICPCCode)codes.elementAt(n);
                        if(!oldcodelabel.equalsIgnoreCase(code.label)){
                            oldcodelabel=code.label;
                            if (code.code.length()>=5 || code.code.startsWith("I")){
                                if (code.code.length()>=5 && code.code.substring(3,5).equalsIgnoreCase("00")){
                                    out.print("<tr class='label2'>");
                                }
                                else {
                                    out.print("<tr>");
                                }
                                out.print(" <td onclick='addICPC(\""+code.code+"\",\""+code.label+"\");'>"+code.code+"</td>");
                                out.print(" <td onclick='addICPC(\""+code.code+"\",\""+code.label+"\");'>"+code.label+"</td>");
                                out.print("</tr>");
                            }
                        }
                    }
                    if (MedwanQuery.getInstance().getConfigInt("enableICD10")==1 || request.getParameter("enableICD10")!=null){
		                codes = MedwanQuery.getInstance().findICD10Codes(keywords, sWebLanguage);
		
		                // header
		                if (codes.size() > 0) {
		                    out.print("<tr class='admin'><td colspan='3'>" + getTran("Web.Occup", "ICD-10", sWebLanguage) + "</td></tr>");
		                }
		
		                %>
		                <tbody onmouseover='this.style.cursor="pointer"' onmouseout='this.style.cursor="default"'>
		                <%
		                oldcodelabel="";
		                for (int n=0; n<codes.size(); n++){
		                    foundRecords++;
		
		                    code = (ICPCCode)codes.elementAt(n);
		                    if(!oldcodelabel.equalsIgnoreCase(code.label)){
		                        oldcodelabel=code.label;
		                        if (code.code.length()>=3){
		                            if (code.code.length()==3){
		                                out.print("<tr class='label2'>");
		                            }
		                            else {
		                                out.print("<tr>");
		                            }
		                            out.print(" <td onclick='addICD10(\""+code.code+"\",\""+code.label+"\");'>"+code.code+"</td>");
		                            out.print(" <td onclick='addICD10(\""+code.code+"\",\""+code.label+"\");'>"+code.label+"</td>");
		                            out.print("</tr>");
		                        }
		                    }
		                }
                    }
                }
                    %>
                    </tbody>
                    <%
                    if(foundRecords==0 && keywords.length() > 0){
                        // display 'no results' message
                        %>
                            <tr class="label2">
                                <td colspan='3'><%=getTran("web","norecordsfound",sWebLanguage)%> 
                                <%
                                if(bManageLocalCodes){
                                %>
                                (<a href='javascript:addnewlocalcode("<%=keywords%>")'><%=getTran("web","managelocalcodes",sWebLanguage) %></a>)</td>
								<%
                                }
                                %>
                            </tr>
                        <%
                    }
                %>
            </table>
        </form>
    <%
    }
%>
    
<script>
    window.setTimeout("document.getElementById('keywords').focus()",200);
    window.resizeTo(700,470);

    function doFind(){
      if(RFEForm.keywords.value.length > 0){
          ToggleFloatingLayer('FloatingLayer',1);
          RFEForm.findButton.disabled = true;
          RFEForm.submit();
      }
    }

    function addICPC(code,label){
        openPopup("/_common/search/RFEInfo.jsp&ts=<%=getTs()%>&field=<%=ScreenHelper.checkString(request.getParameter("field"))%>&trandate=<%=ScreenHelper.checkString(request.getParameter("trandate"))%>&encounterUid=<%=encounterUid%>&Type=ICPC&Code="+code+"&Label="+label,800,500);
    }

    function addICD10(code,label){
        openPopup("/_common/search/RFEInfo.jsp&ts=<%=getTs()%>&field=<%=ScreenHelper.checkString(request.getParameter("field"))%>&trandate=<%=ScreenHelper.checkString(request.getParameter("trandate"))%>&encounterUid=<%=encounterUid%>&Type=ICD10&Code="+code+"&Label="+label,800,500);
    }
    
    function addnewlocalcode(keywords){
    	openPopup("/system/manageLocalCodes.jsp&ts=<%=getTs()%>&label<%=sWebLanguage.toLowerCase()%>="+keywords+"&action=edit&type=I&showlist=true",550,350);
    }
    
</script>


