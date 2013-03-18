<%@page import="be.openclinic.finance.Prestation"%>
<%@page import="be.openclinic.finance.Insurar"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    String sCurrency = MedwanQuery.getInstance().getConfigParam("currency","€");
	String sPrestUid=checkString(request.getParameter("tmpPrestationUID"));
	String sPrice=checkString(request.getParameter("EditPrestationPrice"));
	String sInsurarUid=checkString(request.getParameter("EditInsurarUID"));
	String sInsurarText="";
	Insurar insurar = Insurar.get(sInsurarUid);
	if(insurar!=null && insurar.getName()!=null){
		sInsurarText=insurar.getName();
	}
	String sCategory=checkString(request.getParameter("EditCategoryName"));
	
	if(request.getParameter("saveButton")!=null && sPrestUid.length()>0 && sPrice.length()>0 && sInsurarUid.length()>0){
		//Save tariff
		Prestation.saveInsuranceTariff(sPrestUid,sInsurarUid,sCategory,Double.parseDouble(sPrice));
	}
%>
<form name='EditForm' id="EditForm" method='POST' action='<c:url value="/main.do?Page=system/manageTariffs.jsp"/>'>
	<table class='list' border='0' width='100%' cellspacing='1'>
	        <tr>
	            <td class='admin'><%=getTran("web","prestation",sWebLanguage)%></td>
	            <td class='admin2'>
	                <input type="hidden" name="tmpPrestationUID" id="tmpPrestationUID" value="<%=sPrestUid %>">
	                <input type="hidden" name="tmpPrestationName">
	
	                <select class="text" name="EditPrestationName" onchange="document.getElementById('tmpPrestationUID').value=this.value">
	                    <%
	                    	Prestation prest = Prestation.get(sPrestUid);
	                    	if (prest!=null){
	                    		
	                            out.print("<option selected value='"+checkString(prest.getUid())+"'>"+checkString(prest.getDescription())+"</option>");
	                        }
	                        Vector vPopularPrestations = activeUser.getTopPopularPrestations(10);
	                        if (vPopularPrestations!=null){
	                            String sPrestationUid;
	                            for (int i=0;i<vPopularPrestations.size();i++){
	                                sPrestationUid = checkString((String)vPopularPrestations.elementAt(i));
	                                if (sPrestationUid.length()>0){
	                                    Prestation prestation = Prestation.get(sPrestationUid);
	
	                                    if (prestation!=null && prestation.getDescription()!=null && prestation.getDescription().trim().length()>0 && !(prest!=null && prestation.getUid().equals(prest.getUid()))){
	                                        out.print("<option value='"+checkString(prestation.getUid())+"'");
	                                        out.print(">"+checkString(prestation.getDescription())+"</option>");
	                                    }
	                                }
	                            }
	                        }
	                    %>
	                </select>
	                <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("Web","select",sWebLanguage)%>" onclick="searchPrestation();">
                	<img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTran("Web","clear",sWebLanguage)%>" onclick="EditForm.EditPrestationName.selectedIndex=-1;EditForm.tmpPrestationUID.value='';">
	            </td>
	        </tr>
	        <tr>
		        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("medical.accident", "insurancecompany", sWebLanguage)%>
		        </td>
		        <td class="admin2">
		            <input type="hidden" name="EditInsurarUID" value="<%=sInsurarUid %>">
		            <input type="text" class="text" readonly name="EditInsurarText" value="<%=sInsurarText %>" size="100">
		            <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("Web","select",sWebLanguage)%>" onclick="searchInsurar();">
		            <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTran("Web","clear",sWebLanguage)%>" onclick="doClearInsurar()">
		        </td>
		    </tr>
		    <tr>
		        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web.manage","selectedinsurarcategories",sWebLanguage)%>
		        </td>
		        <td class="admin2">
                    <select name="EditCategoryName" class="text">
                        <option value=""></option>
                        <%
                            StringBuffer sAlfabet = new StringBuffer("ABCDEFGHIJKLMNOPQRSTUVWXYZ");
                            for(int i=0; i<sAlfabet.length(); i++){
                                %><option <%=sCategory.equalsIgnoreCase(sAlfabet.charAt(i)+"")?"selected":"" %> value="<%=sAlfabet.charAt(i)%>"><%=sAlfabet.charAt(i)%></option><%
                            }
                        %>
                    </select>
		        </td>
		    </tr>
		    <tr>
		        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","price",sWebLanguage)%>
		        </td>
		        <td class="admin2">
                            <input type="text" class="text" name="EditPrestationPrice" size="10" maxlength="8" value="<%=sPrice%>" onKeyup="if(!isNumber(this)){this.value='';}">&nbsp;<%=sCurrency%>
		        </td>
		    </tr>
            <tr>
                <td class="admin"/>
                <td class="admin2">
                    <input type='submit' class="button" name="saveButton" value="<%=getTranNoLink("accesskey","save",sWebLanguage)%>"/>
                    <input type='submit' class="button" name="findButton" value="<%=getTranNoLink("web","find",sWebLanguage)%>"/>
                </td>
            </tr>
	        
	</table>
</form>
<table class='list' border='0' width='100%' cellspacing='1'>

<%
	if(request.getParameter("findButton")!=null){
		String sSql="select distinct b.oc_insurar_name,c.oc_prestation_description,a.oc_tariff_insurancecategory,a.oc_tariff_price "+
			",a.oc_tariff_insuraruid,a.oc_tariff_prestationuid,a.oc_tariff_insurancecategory,a.oc_tariff_price"+
			" from oc_tariffs a,oc_insurars b,oc_prestations c"+
			" where"+
			" b.oc_insurar_objectid=replace(a.oc_tariff_insuraruid,'"+MedwanQuery.getInstance().getConfigInt("serverId")+".','') and "+
			" c.oc_prestation_objectid=replace(a.oc_tariff_prestationuid,'"+MedwanQuery.getInstance().getConfigInt("serverId")+".','') and "+
			" a.oc_tariff_insuraruid like '"+sInsurarUid+"%' and "+
			" a.oc_tariff_prestationuid like '"+sPrestUid+"%' and "+
			" a.oc_tariff_insurancecategory like '"+sCategory+"%'";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = oc_conn.prepareStatement(sSql);
		ResultSet rs = ps.executeQuery();
		while (rs.next()){
			String iud=rs.getString("oc_tariff_insuraruid");
			String pud=rs.getString("oc_tariff_prestationuid");
			String cat=rs.getString("oc_tariff_insurancecategory");
			Double price=rs.getDouble("oc_tariff_price");
			out.println("<tr class='list'>");
			%>
				<td><img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTran("Web","delete",sWebLanguage)%>" onclick='selectPrestation("<%=iud%>","<%=pud %>","<%=cat %>",-1);'></td>
			<%
			out.print("<td><td><a href='javascript:selectPrestation(\""+iud+"\",\""+pud+"\",\""+cat+"\","+price+");'>"+rs.getString("oc_insurar_name")+"</a></td><td>"+rs.getString("oc_prestation_description")+"</td><td>"+
					rs.getString("oc_tariff_insurancecategory")+"</td><td>"+rs.getDouble("oc_tariff_price")+"</td></tr>");
		}
		rs.close();
		ps.close();
		oc_conn.close();
%>
<%
	}
%>
</table>
<script>
	function selectPrestation(insuraruid,prestationuid,category,price){
		window.location.href='<c:url value="/main.do?Page=system/manageTariffs.jsp"/>&tmpPrestationUID='+prestationuid+'&EditInsurarUID='+insuraruid+'&EditCategoryName='+category+'&EditPrestationPrice='+price+(price==-1?'&saveButton=true':'');
	}
	
    function searchPrestation(){
        EditForm.tmpPrestationName.value = "";
        EditForm.tmpPrestationUID.value = "";
        openPopup("/_common/search/searchPrestation.jsp&ts=<%=getTs()%>&ReturnFieldUid=tmpPrestationUID&ReturnFieldDescr=tmpPrestationName&doFunction=changeTmpPrestation()");
    }
    
    function doClearInsurar() {
        EditForm.EditInsurarUID.value = "";
        EditForm.EditInsurarText.value = "";
    }

    function changeTmpPrestation(){
    	if (EditForm.tmpPrestationUID.value.length>0){
            EditForm.EditPrestationName.options[0].text = EditForm.tmpPrestationName.value;
            EditForm.EditPrestationName.options[0].value = EditForm.tmpPrestationUID.value;
            EditForm.EditPrestationName.options[0].selected = true;
        }
    }
    function searchInsurar() {
        openPopup("/_common/search/searchInsurar.jsp&ts=<%=getTs()%>&ReturnFieldInsurarUid=EditInsurarUID&ReturnFieldInsurarName=EditInsurarText&doFunction=changeInsurar()&excludePatientSelfIsurarUID=true&PopupHeight=500&PopupWith=500");
    }
    function changeInsurar(){
    }    
        
</script>