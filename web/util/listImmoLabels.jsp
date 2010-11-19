<%@page import="java.util.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%
	String sImmoService=checkString(request.getParameter("immoService"));
	String sImmoServiceName=checkString(request.getParameter("immoServiceName"));
    String sImmoLocation=checkString(request.getParameter("immoLocation"));
    String sImmoCode=checkString(request.getParameter("immoCode"));
    String sImmoBuyer=checkString(request.getParameter("immoBuyer"));
    String sImmoComment=checkString(request.getParameter("immoComment"));
    String sImmoId=checkString(request.getParameter("immoId"));
    String sAction= checkString(request.getParameter("immoAction"));

    Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();

    if("delete".equalsIgnoreCase(sAction) && sImmoId.length()>0){
    	//Remove item
    	String sSql="delete from OC_IMMO where OC_IMMO_ID=?";
    	PreparedStatement ps = oc_conn.prepareStatement(sSql);
    	ps.setInt(1,Integer.parseInt(sImmoId));
    	ps.execute();
    	ps.close();
		sImmoId="";
		sImmoService="";
		sImmoServiceName="";
		sImmoLocation="";
		sImmoCode="";
		sImmoBuyer="";
		sImmoComment="";
    }
    else if("edit".equalsIgnoreCase(sAction) && sImmoId.length()>0){
    	//Remove item
    	String sSql="select * from OC_IMMO where OC_IMMO_ID=?";
    	PreparedStatement ps = oc_conn.prepareStatement(sSql);
    	ps.setInt(1,Integer.parseInt(sImmoId));
    	ResultSet rs = ps.executeQuery();
    	while (rs.next()){
    		Service service = Service.getService(rs.getString("OC_IMMO_SERVICEUID"));
    		if(service!=null){
    			sImmoService=service.code;
    			sImmoServiceName=service.getLabel(sWebLanguage);
    			sImmoLocation=checkString(rs.getString("OC_IMMO_LOCATION"));
    			sImmoCode=checkString(rs.getString("OC_IMMO_CODE"));
    			sImmoBuyer=checkString(rs.getString("OC_IMMO_BUYER"));
    			sImmoComment=checkString(rs.getString("OC_IMMO_COMMENT"));
    		}
    	}
    	rs.close();
    	ps.close();
    }
    else if("find".equalsIgnoreCase(sAction) && sImmoId.length()>0){
		sImmoId="";
    }
    else if("new".equalsIgnoreCase(sAction) && sImmoId.length()>0){
		sImmoId="";
		sImmoService="";
		sImmoServiceName="";
		sImmoLocation="";
		sImmoCode="";
		sImmoBuyer="";
		sImmoComment="";
    }
	else if("save".equalsIgnoreCase(sAction)){
		//Sla de ingevoerde gegevens op
		String sSql=null;
		if(sImmoId.length()>0){
			sSql="update OC_IMMO set OC_IMMO_SERVICEUID=?,OC_IMMO_LOCATION=?,OC_IMMO_CODE=?,OC_IMMO_BUYER=?,OC_IMMO_COMMENT=? where OC_IMMO_ID=?";
		}
		else {
			sSql="insert into OC_IMMO(OC_IMMO_SERVICEUID,OC_IMMO_LOCATION,OC_IMMO_CODE,OC_IMMO_BUYER,OC_IMMO_COMMENT,OC_IMMO_ID) values(?,?,?,?,?,?)";
			sImmoId=MedwanQuery.getInstance().getOpenclinicCounter("IMMO")+"";
		}
		PreparedStatement ps = oc_conn.prepareStatement(sSql);
		ps.setString(1,sImmoService);
		ps.setString(2,sImmoLocation);
		ps.setString(3,sImmoCode);
		ps.setString(4,sImmoBuyer);
		ps.setString(5,sImmoComment);
		ps.setInt(6,Integer.parseInt(sImmoId));
		ps.execute();
		ps.close();
		sAction="find";
	}

%>

<form name="findLabels" id="findLabels" action="<c:url value="/main.do"/>" method="post">
	<input type="hidden" name="immoAction" id="immoAction" value=""/>
	<input type="hidden" name="immoId" id="immoId" value="<%=sImmoId%>"/>
    <input type="hidden" name="Page" value="util/listImmoLabels.jsp"/>
    <table border="0" width="100%">
        <tr>
            <td class="admin"><%=getTran("web","service",sWebLanguage)%></td>
            <td class="admin2">
                <input readonly class="text" type="text" name="immoService" id="immoService" value="<%=sImmoService%>" size="20"/>
                <input readonly class="text" type="text" name="immoServiceName" id="immoServiceName" value="<%=sImmoServiceName%>" size="60"/>
				<img src='_img/icon_search.gif' class='link' alt='<%=getTran("Web","select",sWebLanguage)%>' onclick='searchService("immoService","immoServiceName");'>	
                <img src='_img/icon_delete.gif' class='link' alt='<%=getTran("Web","clear",sWebLanguage)%>' onclick='document.getElementById("immoService").value="";document.getElementById("immoServiceName").value="";'>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("web","immolocation",sWebLanguage)%></td>
            <td class="admin2">
            	<input class="text" type="text" name="immoLocation" id="immoLocation" value="<%=sImmoLocation%>" size="50"/>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("web","code",sWebLanguage)%></td>
            <td class="admin2">
            	<input class="text" type="text" name="immoCode" id="immoCode" value="<%=sImmoCode%>" size="50"/>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("web","bailleur",sWebLanguage)%></td>
            <td class="admin2">
            	<input class="text" type="text" name="immoBuyer" id="immoBuyer" value="<%=sImmoBuyer%>" size="50"/>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("web","comment",sWebLanguage)%></td>
            <td class="admin2">
            	<textarea class="text" type="text" name="immoComment" id="immoComment" cols="50" rows="2"><%=sImmoComment%></textarea>
            </td>
        </tr>
        <tr>
            <td colspan="2">
				<%
					if(!sAction.equalsIgnoreCase("new") && !sAction.equalsIgnoreCase("edit")){
				%>
						<input class="button" type="button" name="find" value="<%=getTran("web","find",sWebLanguage)%>" onclick="document.getElementById('immoAction').value='find';document.getElementById('findLabels').submit()"/>
			            <input class="button" type="button" name="new" value="<%=getTran("web","new",sWebLanguage)%>" onclick="document.getElementById('immoAction').value='new';document.getElementById('findLabels').submit()"/>
            	<%	
            		}
					else {
				%>
						<input class="button" type="button" name="save" value="<%=getTran("web","save",sWebLanguage)%>" onclick="document.getElementById('immoAction').value='save';document.getElementById('findLabels').submit()"/>
			            <input class="button" type="button" name="cancel" value="<%=getTran("web","cancel",sWebLanguage)%>" onclick="clearFields();document.getElementById('findLabels').submit()"/>
            	<%
            		}
				%>
						<input class="button" type="button" name="clear" value="<%=getTran("web","clear",sWebLanguage)%>" onclick="clearFields()"/>
            </td>
        </tr>
    </table>
</form>
<table width="100%" border="0">

<%
	if("find".equalsIgnoreCase(sAction)){
		%>
		<tr class="admin">
			<td/>
			<td>ID</td>
			<td><%=getTran("web","service",sWebLanguage)%></td>
			<td><%=getTran("web","immolocation",sWebLanguage)%></td>
			<td><%=getTran("web","code",sWebLanguage)%></td>
			<td><%=getTran("web","bailleur",sWebLanguage)%></td>
			<td><%=getTran("web","comment",sWebLanguage)%></td>
		</tr>
		<%
		//We zoeken nu de labels volgens de opgegeven criteria op
		String sSql="select * from OC_IMMO where 1=1";
		if(sImmoService.length()>0){
			sSql+=" and OC_IMMO_SERVICEUID like '"+sImmoService+"%'";
		}
		if(sImmoLocation.length()>0){
			sSql+=" and OC_IMMO_LOCATION like '"+sImmoLocation+"%'";
		}
		if(sImmoCode.length()>0){
			sSql+=" and OC_IMMO_CODE like '"+sImmoCode+"%'";
		}
		if(sImmoBuyer.length()>0){
			sSql+=" and OC_IMMO_BUYER like '"+sImmoBuyer+"%'";
		}
		if(sImmoComment.length()>0){
			sSql+=" and OC_IMMO_COMMENT like '%"+sImmoComment+"%'";
		}
		PreparedStatement ps = oc_conn.prepareStatement(sSql);
		ResultSet rs = ps.executeQuery();
		while(rs.next()){
			String sId=checkString(rs.getString("OC_IMMO_ID"));
			String sService=checkString(rs.getString("OC_IMMO_SERVICEUID"));
			String sLocation=checkString(rs.getString("OC_IMMO_LOCATION"));
			String sCode=checkString(rs.getString("OC_IMMO_CODE"));
			String sBuyer=checkString(rs.getString("OC_IMMO_BUYER"));
			String sComment=checkString(rs.getString("OC_IMMO_COMMENT"));
			out.println("<tr class='list' onmouseover='this.className=\"list_select\"' onmouseout='this.className=\"list\"'><td width='1%' nowrap>"+
					" <img src='_img/icon_delete.gif' title='"+getTranNoLink("web","delete",sWebLanguage)+"' onclick='deleteImmo(\""+sId+"\");'>"+
					" <img src='_img/icon_print_top.gif' title='"+getTranNoLink("web","print",sWebLanguage)+"' onclick='printImmo(\""+sId+"\",\""+sService.trim()+"/"+sLocation+"_"+sCode+"/"+sBuyer+"\");'>"+
					" <img src='_img/icon_edit.gif' title='"+getTranNoLink("web","edit",sWebLanguage)+"' onclick='editImmo(\""+sId+"\");'></td><td>"
					+sId+"</td><td>"
					+sService+"</td><td>"
					+sLocation+"</td><td>"
					+sCode+"</td><td>"
					+sBuyer+"</td><td>"
					+sComment+"</td><td></tr>");	
		}
		rs.close();
		ps.close();
	}
oc_conn.close();
%>
</table>
<script>
	function searchService(serviceUidField,serviceNameField){
	    openPopup("_common/search/searchService.jsp&ts=<%=getTs()%>&showinactive=0&VarCode="+serviceUidField+"&VarText="+serviceNameField);
	    document.all[serviceNameField].focus();
	}

	function clearFields(){
		document.getElementById("immoId").value="";
		document.getElementById("immoAction").value="";
		document.getElementById("immoService").value="";
		document.getElementById("immoServiceName").value="";
		document.getElementById("immoLocation").value="";
		document.getElementById("immoCode").value="";
		document.getElementById("immoBuyer").value="";
		document.getElementById("immoComment").value="";
	}

	function deleteImmo(id){
	    var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/yesnoPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=areyousuretodelete";
	    var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
	    var answer = (window.showModalDialog)?window.showModalDialog(popupUrl,'',modalities):window.confirm("<%=getTranNoLink("web","areyousuretodelete",sWebLanguage)%>");
	    if(answer==1){
			document.getElementById("immoId").value=id;	 
			document.getElementById("immoAction").value='delete';
			document.getElementById("findLabels").submit();   
	    }
	}

	function editImmo(id){
		document.getElementById("immoId").value=id;	 
		document.getElementById("immoAction").value='edit';
		document.getElementById("findLabels").submit();   
	}

	function printImmo(id,name){
		window.open('<c:url value="util/printImmoLabel.jsp"/>?article'+id+'=<%=MedwanQuery.getInstance().getConfigString("immoprefix","CHUK")%>/'+name);
	}
		
</script>