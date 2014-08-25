<%@page import="java.util.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=sJSSORTTABLE%>

<%
    String sAction = checkString(request.getParameter("Action"));

	String sServerId = checkString(request.getParameter("serverId")),
	       sObjectId = checkString(request.getParameter("objectId"));

	String sImmoService     = checkString(request.getParameter("immoService")),
		   sImmoServiceName = checkString(request.getParameter("immoServiceName")),
	       sImmoLocation    = checkString(request.getParameter("immoLocation")),
	       sImmoCode        = checkString(request.getParameter("immoCode")),
	       sImmoBuyer       = checkString(request.getParameter("immoBuyer")),
	       sImmoComment     = checkString(request.getParameter("immoComment"));
	
	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n*********************** util/listImmoLabels.jsp ***********************"); 
		Debug.println("sAction          : "+sAction); 
		Debug.println("sServerId        : "+sServerId); 
		Debug.println("sObjectId        : "+sObjectId); 
		Debug.println("sImmoService     : "+sImmoService); 
		Debug.println("sImmoServiceName : "+sImmoServiceName); 
		Debug.println("sImmoLocation    : "+sImmoLocation); 
		Debug.println("sImmoCode        : "+sImmoCode); 
		Debug.println("sImmoBuyer       : "+sImmoBuyer);
		Debug.println("sImmoComment     : "+sImmoComment+"\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////

    Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
	String sMsg = "";

    //*** DELETE ***********************************************
    if(sAction.equals("delete") && sServerId.length()>0 && sObjectId.length()>0){
    	String sSql = "delete from OC_IMMO where OC_IMMO_SERVERID = ? AND OC_IMMO_OBJECTID = ?";
    	PreparedStatement ps = oc_conn.prepareStatement(sSql);
    	ps.setInt(1,Integer.parseInt(sServerId));
    	ps.setInt(2,Integer.parseInt(sObjectId));
    	ps.execute();
    	ps.close();
    	
		sServerId = "";
		sObjectId = "";
		
		sMsg = getTran("web","dataIsDeleted",sWebLanguage);
		//sAction = "find";
    }
    //*** EDIT *************************************************
    else if(sAction.equals("edit") && sServerId.length()>0 && sObjectId.length()>0){
    	String sSql = "select * from OC_IMMO where OC_IMMO_SERVERID = ? AND OC_IMMO_OBJECTID = ?";
    	PreparedStatement ps = oc_conn.prepareStatement(sSql);
    	ps.setInt(1,Integer.parseInt(sServerId));
    	ps.setInt(2,Integer.parseInt(sObjectId));
    	ResultSet rs = ps.executeQuery();
    	Service service;
    	
    	while(rs.next()){
    		service = Service.getService(rs.getString("OC_IMMO_SERVICEUID"));
    		if(service!=null){
    			sImmoService = service.code;
    			sImmoServiceName = service.getLabel(sWebLanguage);
    			sImmoLocation = checkString(rs.getString("OC_IMMO_LOCATION"));
    			sImmoCode = checkString(rs.getString("OC_IMMO_CODE"));
    			sImmoBuyer = checkString(rs.getString("OC_IMMO_BUYER"));
    			sImmoComment = checkString(rs.getString("OC_IMMO_COMMENT"));
    		}
    	}
    	rs.close();
    	ps.close();
    }
    //*** NEW **************************************************
    else if(sAction.equals("new")){
		sServerId = "";
		sObjectId = "";
    }
    //*** SAVE *************************************************
	else if(sAction.equals("save")){
		String sSql = null;
		
		if(sObjectId.length() > 0){
			sSql = "update OC_IMMO set OC_IMMO_SERVICEUID=?,OC_IMMO_LOCATION=?,OC_IMMO_CODE=?,OC_IMMO_BUYER=?,OC_IMMO_COMMENT=?"+
		           " where OC_IMMO_SERVERID = ? AND OC_IMMO_OBJECTID = ?";
		}
		else{
			sSql = "insert into OC_IMMO(OC_IMMO_SERVICEUID,OC_IMMO_LOCATION,OC_IMMO_CODE,OC_IMMO_BUYER,OC_IMMO_COMMENT,"+
		           "                    OC_IMMO_SERVERID,OC_IMMO_OBJECTID)"+
		           " values(?,?,?,?,?,?,?)";
			
			sObjectId = Integer.toString(MedwanQuery.getInstance().getOpenclinicCounter("IMMO"));
		}
		
		PreparedStatement ps = oc_conn.prepareStatement(sSql);
		ps.setString(1,sImmoService);
		ps.setString(2,sImmoLocation);
		ps.setString(3,sImmoCode);
		ps.setString(4,sImmoBuyer);
		ps.setString(5,sImmoComment);
		
		ps.setInt(6,MedwanQuery.getInstance().getConfigInt("serverId"));
		ps.setInt(7,Integer.parseInt(sObjectId));
		ps.execute();
		ps.close();
		
		sAction = "find";
		sMsg = getTran("web","dataIsSaved",sWebLanguage);
	}
%>
    
<form name="immoForm" id="immoForm" method="post" 
    <%
        if(sAction.length()==0 || sAction.equals("find")){
            %>onKeyDown="if(enterEvent(event,13)){doFind();}"<%
        }
    %>
>
	<input type="hidden" name="Action" value=""/>
	<input type="hidden" name="serverId" id="serverId" value="<%=sServerId%>"/>
	<input type="hidden" name="objectId" id="objectId" value="<%=sObjectId%>"/>

    <%=writeTableHeader("web","immo",sWebLanguage)%>   
    <table width="100%" border="0" class="list" cellpadding="1" cellspacing="1">
        <%-- service --%>
        <tr>
            <td class="admin"><%=getTran("web","service",sWebLanguage)%></td>
            <td class="admin2">
                <input readonly class="text" type="text" name="immoService" id="immoService" value="<%=sImmoService%>" size="20"/>
                <input readonly class="text" type="text" name="immoServiceName" id="immoServiceName" value="<%=sImmoServiceName%>" size="60"/>
			
				<img src='_img/icon_search.gif' class='link' alt='<%=getTranNoLink("web","select",sWebLanguage)%>' onclick='searchService("immoService","immoServiceName");'>	
                <img src='_img/icon_delete.gif' class='link' alt='<%=getTranNoLink("web","clear",sWebLanguage)%>' onclick='document.getElementById("immoService").value="";document.getElementById("immoServiceName").value="";'>
            </td>
        </tr>
        <%-- location --%>
        <tr>
            <td class="admin"><%=getTran("web","immolocation",sWebLanguage)%></td>
            <td class="admin2">
            	<input class="text" type="text" name="immoLocation" id="immoLocation" value="<%=sImmoLocation%>" size="50"/>
            </td>
        </tr>
        <%-- code --%>
        <tr>
            <td class="admin"><%=getTran("web","code",sWebLanguage)%></td>
            <td class="admin2">
            	<input class="text" type="text" name="immoCode" id="immoCode" value="<%=sImmoCode%>" size="50"/>
            </td>
        </tr>
        <%-- bailleur (~verhuurder) --%>
        <tr>
            <td class="admin"><%=getTran("web","bailleur",sWebLanguage)%></td>
            <td class="admin2">
            	<input class="text" type="text" name="immoBuyer" id="immoBuyer" value="<%=sImmoBuyer%>" size="50"/>
            </td>
        </tr>
        
        <%-- comment --%>
        <tr>
            <td class="admin"><%=getTran("web","comment",sWebLanguage)%></td>
            <td class="admin2">
	        <%
	            if(sAction.equals("new") || sAction.equals("edit")){
	                %><textarea class="text" name="immoComment" id="immoComment" cols="50" rows="2" onkeyup="limitChars(this,255);"><%=sImmoComment%></textarea><%
				}
	            else{
	            	%><input type="text" class="text" name="immoComment" id="immoComment" value="<%=sImmoComment%>" size="50"/><%
	            }
		    %>
            </td>
        </tr>
        
        <%-- BUTTONS --%>
        <tr>
            <td class="admin">&nbsp;</td>
            <td class="admin2">
				<%
					if(!sAction.equalsIgnoreCase("new") && !sAction.equalsIgnoreCase("edit")){
						%>
							<input class="button" type="button" name="find" value="<%=getTranNoLink("web","find",sWebLanguage)%>" onclick="doFind();"/>
				            <input class="button" type="button" name="new" value="<%=getTranNoLink("web","new",sWebLanguage)%>" onclick="doNew();"/>
            			<%	
            		}
					else{
						%>
							<input class="button" type="button" name="saveButton" value="<%=getTranNoLink("web","save",sWebLanguage)%>" onclick="doSave();"/>
				            <input class="button" type="button" name="cancel" value="<%=getTranNoLink("web","cancel",sWebLanguage)%>" onclick="clearFields();document.getElementById('immoForm').submit()"/>
            			<%
            		}
				%>
				<input class="button" type="button" name="clear" value="<%=getTran("web","clear",sWebLanguage)%>" onclick="clearFields()"/>
            </td>
        </tr>
    </table>
</form>

<%
    //*** FIND *************************************************
	if(sAction.equalsIgnoreCase("find")){		
		String sSql = "select * from OC_IMMO where 1 = 1 ";
		
		if(sImmoService.length() > 0){
			sSql+= "and OC_IMMO_SERVICEUID like '"+sImmoService+"%'";
		}
		if(sImmoLocation.length() > 0){
			sSql+= "and OC_IMMO_LOCATION like '"+sImmoLocation+"%'";
		}
		if(sImmoCode.length() > 0){
			sSql+= "and OC_IMMO_CODE like '"+sImmoCode+"%'";
		}
		if(sImmoBuyer.length() > 0){
			sSql+= "and OC_IMMO_BUYER like '"+sImmoBuyer+"%'";
		}
		if(sImmoComment.length() > 0){
			sSql+= "and OC_IMMO_COMMENT like '%"+sImmoComment+"%'";
		}
		
		Debug.println(sSql);
		PreparedStatement ps = oc_conn.prepareStatement(sSql);
		ResultSet rs = ps.executeQuery();

		String sService, sLocation, sCode, sBuyer, sComment, sClass = "";
		int recordCount = 0;
		if(rs.absolute(1)){
			rs.beforeFirst();
			
		    %>
		        <table width="100%" class="sortable" id="searchresults" border="0" cellpadding="1" cellspacing="0">
					<tr class="admin">
						<td width="60"/>
						<td width="50">ID</td>
						<td width="120"><%=getTran("web","service",sWebLanguage)%></td>
						<td width="180"><%=getTran("web","immolocation",sWebLanguage)%></td>
						<td width="100"><%=getTran("web","code",sWebLanguage)%></td>
						<td width="200"><%=getTran("web","bailleur",sWebLanguage)%></td>
						<td width="*"><%=getTran("web","comment",sWebLanguage)%></td>
					</tr>
					
		            <%
						while(rs.next()){
							sServerId = checkString(rs.getString("OC_IMMO_SERVERID"));
							sObjectId = checkString(rs.getString("OC_IMMO_OBJECTID"));
							
							sService  = checkString(rs.getString("OC_IMMO_SERVICEUID"));
							sLocation = checkString(rs.getString("OC_IMMO_LOCATION"));
							sCode     = checkString(rs.getString("OC_IMMO_CODE"));
							sBuyer    = checkString(rs.getString("OC_IMMO_BUYER"));
							sComment  = checkString(rs.getString("OC_IMMO_COMMENT"));
							
							sComment = sComment.replaceAll("\r\n","<br>").replaceAll("\n","<br>");
							if(sComment.length() > 50) sComment = sComment.substring(0,47)+"...";
							
							if(sClass.length()==0) sClass = "1";
							else                   sClass = "";
							
							out.print("<tr class='list"+sClass+"' onmouseover='this.className=\"list_select\"' onmouseout='this.className=\"list"+sClass+"\"'>"+
							           "<td nowrap>"+
							      	    "<img src='_img/icon_delete.gif' class='link' title='"+getTranNoLink("web","delete",sWebLanguage)+"' onclick='deleteImmo("+sServerId+","+sObjectId+");'>"+
									    "<img src='_img/icon_print_top.gif' class='link' title='"+getTranNoLink("web","print",sWebLanguage)+"' onclick='printImmo("+sServerId+","+sObjectId+",\""+sService.trim()+"/"+sLocation+"_"+sCode+"/"+sBuyer+"\");'>"+
									    "<img src='_img/icon_edit.gif' class='link' title='"+getTranNoLink("web","edit",sWebLanguage)+"' onclick='editImmo("+sServerId+","+sObjectId+");'>"+
									   "</td>"+
									   "<td style='padding-left:5px;'>"+sServerId+"."+sObjectId+"</td>"+
									   "<td style='padding-left:5px;'>"+sService+"</td>"+
									   "<td style='padding-left:5px;'>"+sLocation+"</td>"+
									   "<td style='padding-left:5px;'>"+sCode+"</td>"+
									   "<td style='padding-left:5px;'>"+sBuyer+"</td>"+
									   "<td style='padding-left:5px;'>"+sComment+"</td>"+
									  "</tr>");
							
							recordCount++;
						}
						rs.close();
						ps.close();
				    %>
			    </table>
			<%
		}	
		
		if(recordCount > 0){
		    sMsg = recordCount+" "+getTran("web","recordsFound",sWebLanguage);
		}
		else{
		    sMsg = getTran("web","noRecordsFound",sWebLanguage);
		}
	}

    oc_conn.close();
%>

<%
    if(sMsg.length() > 0){
    	%><%=sMsg%><BR><%
    }
%>

<script>
  function doFind(){
    immoForm.Action.value = "find";
    immoForm.submit();
  }
  
  function doNew(){	
    immoForm.Action.value = "new";
    immoForm.submit();
  }

  <%-- SAVE --%>
  function doSave(){
	if(requiredFieldsOK()){
      immoForm.Action.value = "save";
      immoForm.submit();
	}
	else{
	  alertDialog("web.manage","dataMissing");
	}
  }

  <%-- REQUIRED FIELDS OK --%>
  function requiredFieldsOK(){
    return (document.getElementById("immoService").value.length > 0 ||
    		document.getElementById("immoServiceName").value.length > 0 ||
    		document.getElementById("immoLocation").value.length > 0 ||
    		document.getElementById("immoCode").value.length > 0 ||
    		document.getElementById("immoBuyer").value.length > 0 ||
    		document.getElementById("immoComment").value.length > 0);	  
  }

  <%-- SEARCH SERVICE --%>
  function searchService(serviceUidField,serviceNameField){
    openPopup("_common/search/searchService.jsp&ts=<%=getTs()%>&showinactive=0&VarCode="+serviceUidField+"&VarText="+serviceNameField);
    document.getElementsByName(serviceNameField)[0].focus(); 
  }

  <%-- CLEAR FIELDS --%>
  function clearFields(){
    immoForm.Action.value = "";

	document.getElementById("serverId").value = "";
	document.getElementById("objectId").value = "";
	
	document.getElementById("immoService").value = "";
	document.getElementById("immoServiceName").value = "";
	document.getElementById("immoLocation").value = "";
	document.getElementById("immoCode").value = "";
	document.getElementById("immoBuyer").value = "";
	document.getElementById("immoComment").value = "";
  }

  <%-- DELETE IMMO --%>
  function deleteImmo(serverId,objectId){
    if(yesnoDialog("web","areYouSureToDelete")){
      document.getElementById("serverId").value = serverId;
      document.getElementById("objectId").value = objectId;
		
	  immoForm.Action.value = "delete";
	  immoForm.submit();   
    }
  }

  <%-- EDIT IMMO --%>
  function editImmo(serverId,objectId){
	document.getElementById("serverId").value = serverId;
	document.getElementById("objectId").value = objectId;	
	
	immoForm.Action.value = "edit";
	immoForm.submit();   
  }

  <%-- PRINT IMMO --%>
  function printImmo(serverId,objectId,name){
    var url = "<c:url value='util/printImmoLabel.jsp'/>?article"+serverId+"."+objectId+"=<%=MedwanQuery.getInstance().getConfigString("immoprefix","CHUK")%>/"+name;
    window.open(url);
  }	
</script>