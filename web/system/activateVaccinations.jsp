<%@page import="be.dpms.medwan.common.model.vo.occupationalmedicine.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%
    String sAction = checkString(request.getParameter("Action"));
	
	/// DEBUG //////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
	    Debug.println("\n************ system/activateVaccinations.jsp ************");
	    Debug.println("sAction : "+sAction+"\n");
	}
	////////////////////////////////////////////////////////////////////////////////
	
	if(sAction.equals("save")){
		String sActiveVaccinations = "*";		
		Enumeration pars = request.getParameterNames();
		String parname;
		
		while(pars.hasMoreElements()){
			parname = (String)pars.nextElement();
			if(parname.startsWith("cb")){
				sActiveVaccinations+= parname.substring(2)+"*";
			}
		}
		
		MedwanQuery.getInstance().setConfigString("activeVaccinations",sActiveVaccinations);
	}
%>

<form name="vaccForm" method="post">
    <input type="hidden" name="Action" value="save">

    <%=writeTableHeader("web.manage","ManageActivatedVaccinations",sWebLanguage,"doBack();")%>
        
    <table width="100%" cellspacing="1" cellpadding="0" class="list">		
		<%
			String activeVaccinations = MedwanQuery.getInstance().getConfigString("activeVaccinations","*504*506*517*525*526*527*529*530*531*539*");
		
			Iterator examinations = MedwanQuery.getInstance().getAllExaminations(sWebLanguage).iterator();
			ExaminationVO vacc;
			String sVaccType;
			
			while(examinations.hasNext()){
				vacc = (ExaminationVO)examinations.next();
				
				// only vaccinations
				if(vacc.getTransactionType().startsWith(ScreenHelper.ITEM_PREFIX+"TRANSACTION_TYPE_VACCINATION")){					
					sVaccType = (vacc.getTransactionType()).substring((ScreenHelper.ITEM_PREFIX+"TRANSACTION_TYPE_VACCINATION&vaccination=").length());
					Debug.println("sVaccType : "+sVaccType); 
					
					out.println("<tr>"+
				                 "<td class='admin2'><input type='checkbox' name='cb"+vacc.getId()+"'"+(activeVaccinations.indexOf("*"+vacc.getId()+"*")>-1?"checked":"")+"/>"+getLabel("web.occup",sVaccType,sWebLanguage,"cb"+vacc.getId())+"</td>"+
					            "</tr>");
				}
			}		
		%>		
	</table>   
	
	<%-- BUTTONS --%>
    <div style="padding-top:3px;">     
        <input class="button" type="button" name="saveButton" value="<%=getTranNoLink("web","save",sWebLanguage)%>" onClick="vaccForm.submit();"/>
        <input class="button" type="button" name="backButton" value="<%=getTran("Web","back",sWebLanguage)%>" onclick="doBack();">
  	</div>    
</form>

<script>
  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<%=sCONTEXTPATH%>/main.do?Page=system/menu.jsp"; 
  }
</script>