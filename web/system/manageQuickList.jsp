<%@ page import="be.openclinic.finance.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%!
	public String getItemValue(String[] prestations,int column, int row){
		for(int n=0;n<prestations.length;n++){
			if(prestations[n].split("£").length==2 && prestations[n].split("£")[1].split("\\.").length==2 && Integer.parseInt(prestations[n].split("£")[1].split("\\.")[0])==column && Integer.parseInt(prestations[n].split("£")[1].split("\\.")[1])==row){
				return prestations[n].split("£")[0];
			}
		}
		return "";
	}
%>
<%
	if(request.getParameter("submit")!=null){
		Enumeration parameterNames = request.getParameterNames();
		SortedMap prestations = new TreeMap();
		while(parameterNames.hasMoreElements()){
			String parameterName = (String)parameterNames.nextElement();
			if(parameterName.startsWith("prest.")){
				String parameterValue=request.getParameter(parameterName);
				if(parameterValue.startsWith("$")){
					prestations.put(parameterName,parameterValue);
				}
				else {
					Prestation prestation = Prestation.getByCode(parameterValue);
					if (prestation!=null && prestation.getDescription()!=null){
						prestations.put(parameterName,parameterValue);
					}
				}
			}
		}
		String pars = "";
		Iterator p = prestations.keySet().iterator();
		while(p.hasNext()){
			String name=(String)p.next();
			String prestation = (String)prestations.get(name);
			if(pars.length()>0){
				pars+=";";
			}
			pars+=prestation+"£"+name.split("\\.")[1]+"."+name.split("\\.")[2];
		}
		if(request.getParameter("UserQuickList")!=null){
			MedwanQuery.getInstance().setConfigString("quickList."+activeUser.userid,pars);
		}
		else {
			MedwanQuery.getInstance().setConfigString("quickList",pars);
		}
	}

	String[] sPrestations = MedwanQuery.getInstance().getConfigString("quickList","").split(";");
	if(request.getParameter("UserQuickList")!=null){
		sPrestations = MedwanQuery.getInstance().getConfigString("quickList."+activeUser.userid,"").split(";");
	}
	int rows=MedwanQuery.getInstance().getConfigInt("quickListRows",20),cols=MedwanQuery.getInstance().getConfigInt("quickListCols",2);
%>
<form name="transactionForm" method="post">
	<table width="100%">
		<%
			out.println("<tr>");
			for(int n=0;n<cols;n++){
				out.println("<td class='admin'>"+getTran("web","code",sWebLanguage)+"</td>");
				out.println("<td class='admin'>"+getTran("web","description",sWebLanguage)+"</td>");
			}
			out.println("</tr>");
			for(int n=0;n<rows;n++){
		%>
				<tr>
			<%
				for(int i=0;i<cols;i++){
			%>
					<td class='admin2' width='1%' nowrap>
						<input name="prest.<%=i%>.<%=n%>" id="prest.<%=i%>.<%=n%>" type="text" class="text" value="<%=getItemValue(sPrestations,i,n)%>"/>
						<img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("Web","select",sWebLanguage)%>" onclick="searchPrestation('<%=i+"."+n%>');">
					</td>
			<%
					String val=getItemValue(sPrestations,i,n);
					if(val.length()>0){
						if(val.startsWith("$")){
							out.println("<td id='prestname."+i+"."+n+"' width='"+(100/cols)+"%' class='admin'>"+val.substring(1)+"<hr/></td>");
						}
						else {
							Prestation prestation = Prestation.getByCode(val);
							if(prestation!=null && prestation.getDescription()!=null){
								out.println("<td id='prestname."+i+"."+n+"' width='"+(100/cols)+"%' class='admin2'>"+prestation.getDescription()+"</td>");
							}
							else {
								out.println("<td id='prestname."+i+"."+n+"' width='"+(100/cols)+"%' class='admin2'><font color='red'>Code not found</font></td>");
							}
						}
					}
					else {
						out.println("<td id='prestname."+i+"."+n+"' width='"+(100/cols)+"%' class='admin2'>&nbsp;</td>");
					}
				}
			%>
				</tr>
		<%
			}
		%>
	</table>
	<input type="submit" class="button" name="submit" value="<%=getTran("web","save",sWebLanguage)%>"/>
</form>
<script>
function searchPrestation(id){
	document.getElementById('prest.'+id).value='';
	document.getElementById('prestname.'+id).value='';
    openPopup("/_common/search/searchPrestation.jsp&ts=<%=getTs()%>&ReturnFieldCode=prest."+id+"&ReturnFieldDescrHtml=prestname."+id);
}
</script>
