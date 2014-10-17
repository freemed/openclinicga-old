<%@page import="be.openclinic.adt.Encounter"%>
<%@page import="java.util.Vector"%>
<%@page import="be.openclinic.medical.ReasonForEncounter"%>
<%@page import="be.mxs.common.model.vo.healthrecord.ICPCCode"%>
<%@include file="/includes/validateUser.jsp"%>
<!-- Dit scherm geeft een lijst van alle RFE's en biedt de mogelijkheid deze te bewerken -->

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
    String encounterUid = checkString(request.getParameter("encounterUid"));
    Debug.println("encounterUid : "+encounterUid);

    if(encounterUid.length()==0){
        out.println("<script>window.close();</script>");
        out.flush();
    }
    else{
        boolean bManageLocalCodes = activeUser.getAccessRight("system.managelocalrfecodes.edit");

        String keywords = checkString(request.getParameter("keywords"));
        Debug.println("keywords : "+keywords);
%>
    <form name="RFEForm" method="post" onKeyDown='if(event.keyCode==13){doFind();}'>
        <table class='menu' width='100%' cellspacing="0" cellpadding="0">
            <tr class="admin"><td colspan="3"><%=getTran("openclinic.chuk","rfe",sWebLanguage)%></td></tr>
            <tr>
                <td class="admin2" nowrap><%=getTran("Web","Keyword",sWebLanguage)%>&nbsp;&nbsp;</td>
                <td class="admin2" colspan='2'>
                    <input type='text' class='text' id='keywords' name='keywords' size='40' value="<%=keywords%>" onblur="limitLength(this);"/>
                
                    <%-- BUTTONS --%>
                    <input class='button' type='button' name='findButton' onclick='doFind();' value='<%=getTranNoLink("Web","Find",sWebLanguage)%>'/>
                    <input class='button' type='button' name='closeButton' onclick='window.close()' value='<%=getTranNoLink("Web","Close",sWebLanguage)%>'/>
                </td>
            </tr>
        </table>
        <br>
        
        <table class='list' width='100%' cellspacing="0" cellpadding="0">
            <%                
                int foundRecords = 0;
                String sClass = "1";
                
                if(keywords.length() > 0){
                    //*** 1 - ICPC ******************************************************
                    Vector codes = MedwanQuery.getInstance().findICPCCodes(keywords, sWebLanguage);
                    ICPCCode code;

                    // header
                    if(codes.size() > 0){
                        out.print("<tr class='admin'><td colspan='3'>"+getTran("Web.Occup","ICPC-2",sWebLanguage)+(bManageLocalCodes?" &nbsp;(<a href='javascript:addnewlocalcode(\""+keywords+"\")'>"+getTran("web","managelocalcodes",sWebLanguage)+"</a>)":"")+"</td></tr>");
                    }

                    %><tbody class="hand"><%
                    		
                    String oldcodelabel = "";
                    for(int n=0; n<codes.size(); n++){
                        code = (ICPCCode)codes.elementAt(n);
                        Debug.println("ICPC code : "+code.code); 

                        //if(!oldcodelabel.equalsIgnoreCase(code.label)){
                            oldcodelabel = code.label;
                            
                            if(code.code.length()>=5 || code.code.startsWith("I")){
                                foundRecords++;
			                    
	                        	// alternate row-style
	                        	if(sClass.length()==0) sClass = "1";
	                        	else                   sClass = ""; 
	                        	
                                if(code.code.length()>=5 && code.code.substring(3,5).equalsIgnoreCase("00")){
                                    out.print("<tr class='list"+sClass+"' style='font-weight:bold'>");
                                }
                                else{
	                                out.print("<tr class='list"+sClass+"'>");
                                }
                                out.print(" <td onclick='addICPC(\""+code.code+"\",\""+code.label+"\");'>"+code.code+"</td>");
                                out.print(" <td onclick='addICPC(\""+code.code+"\",\""+code.label+"\");'>"+code.label+"</td>");
                                out.print("</tr>");
                            }
                        //}
                    }
                    %></tbody><%
                    
                    //*** 2 - ICD10 *****************************************************
                    boolean displayICD10 = MedwanQuery.getInstance().getConfigInt("enableICD10")==1 || request.getParameter("enableICD10")!=null;
                    displayICD10 = true ; ////////////////////////////////////////////////////////
                    Debug.println("displayICD10 : "+displayICD10);
                    
                    if(displayICD10){
		                codes = MedwanQuery.getInstance().findICD10Codes(keywords,sWebLanguage);
		
		                // header
		                if(codes.size() > 0){
		                    out.print("<tr class='admin'><td colspan='3'>"+getTran("Web.Occup","ICD-10",sWebLanguage)+"</td></tr>");
		                }
		
		                %><tbody class="hand"><%
		                oldcodelabel = "";
		                for(int n=0; n<codes.size(); n++){		
		                    code = (ICPCCode)codes.elementAt(n);
	                        
		                    if(!oldcodelabel.equalsIgnoreCase(code.label)){
		                        oldcodelabel = code.label;
		                        
		                        if(code.code.length()>=3){
				                    foundRecords++;
				                    
		                        	// alternate row-style
		                        	if(sClass.length()==0) sClass = "1";
		                        	else                   sClass = ""; 
		                        	
		                            if(code.code.length()==3){
	                                    out.print("<tr class='list"+sClass+"' style='font-weight:bold'>");
	                                }
	                                else{
		                                out.print("<tr class='list"+sClass+"'>");
		                            }
		                            out.print(" <td onclick='addICD10(\""+code.code+"\",\""+code.label+"\");'>"+code.code+"</td>");
		                            out.print(" <td onclick='addICD10(\""+code.code+"\",\""+code.label+"\");'>"+code.label+"</td>");
		                            out.print("</tr>");
		                        }
		                    }
		                }
	                    %></tbody><%
                    }                    
                }
                    
                Debug.println("--> foundRecords : "+foundRecords);
                if(keywords.length() > 0){
	                if(foundRecords==0){
	                    // display 'no results' message
	                    %>
	                        <tr class="label2">
	                            <td colspan='3'><%=getTran("web","norecordsfound",sWebLanguage)%> 
	                            <%
	                                if(bManageLocalCodes){
	                                    %> (<a href='javascript:addnewlocalcode("<%=keywords%>")'><%=getTran("web","managelocalcodes",sWebLanguage)%></a>)</td><%
	                                }
	                            %>
	                        </tr>
	                    <%
	                }
                }
            %>
            
            <tr><td class='admin2' width='50'><td width="*"></tr>
        </table>
        
        <%
            if(foundRecords > 0){
                %><%=foundRecords%> <%=getTran("web","recordsFound",sWebLanguage)%><%
            }
        %>
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
      RFEForm.closeButton.disabled = true;
      RFEForm.submit();
    }
    else{
      RFEForm.keywords.focus();
    }
  }

  function addICPC(code,label){
    openPopup("/_common/search/RFEInfo.jsp&ts=<%=getTs()%>&field=<%=ScreenHelper.checkString(request.getParameter("field"))%>&trandate=<%=ScreenHelper.checkString(request.getParameter("trandate"))%>&encounterUid=<%=encounterUid%>&Type=ICPC&Code="+code+"&Label="+label,800,500);
  }

  function addICD10(code,label){
    openPopup("/_common/search/RFEInfo.jsp&ts=<%=getTs()%>&field=<%=ScreenHelper.checkString(request.getParameter("field"))%>&trandate=<%=ScreenHelper.checkString(request.getParameter("trandate"))%>&encounterUid=<%=encounterUid%>&Type=ICD10&Code="+code+"&Label="+label,800,500);
  }
    
  function addnewlocalcode(keywords){
    var url = "/system/manageLocalCodes.jsp&ts=<%=getTs()%>"+
              "&label<%=sWebLanguage.toLowerCase()%>="+keywords+
              "&action=edit&type=I&showlist=true";
  	openPopup(url,550,350);
  }    
</script>