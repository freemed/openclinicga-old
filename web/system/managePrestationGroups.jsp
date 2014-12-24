<%@page import="java.util.Hashtable,
                be.openclinic.finance.Prestation"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
	String sEditPrestationGroup = checkString(request.getParameter("EditPrestationGroup")),
	       sEditPrestationName  = checkString(request.getParameter("EditPrestationName"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n****************** system/managePrestationGroups.jsp ******************");
    	Debug.println("sEditPrestationGroup : "+sEditPrestationGroup);
    	Debug.println("sEditPrestationName  : "+sEditPrestationName+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
    
    //*** NEW ***
	if(request.getParameter("newgroupname")!=null && request.getParameter("newgroupname").length()>0){
		String sGroupName = request.getParameter("newgroupname");
		String sSql = "select * from oc_prestation_groups where oc_group_description=?";
		PreparedStatement ps = oc_conn.prepareStatement(sSql);
		ps.setString(1,sGroupName);
		ResultSet rs = ps.executeQuery();
		if(!rs.next()){
			rs.close();
			ps.close();
			
			sSql = "insert into oc_prestation_groups(oc_group_serverid,oc_group_objectid,oc_group_description)"+
			       " values(?,?,?)";
			ps = oc_conn.prepareStatement(sSql);
			ps.setInt(1,MedwanQuery.getInstance().getConfigInt("serverId",1));
			ps.setInt(2,MedwanQuery.getInstance().getOpenclinicCounter("OC_PRESTATION_GROUP"));
			ps.setString(3,sGroupName);
			ps.execute();
			ps.close();
		}
		else{
			rs.close();
			ps.close();
		}
	}
    //*** ADD ***
	else if(request.getParameter("addprestation")!=null && sEditPrestationGroup.length()>0 && sEditPrestationName.length()>0){
		String sSql = "select * from oc_prestationgroups_prestations"+
	                  " where oc_prestationgroup_groupuid=? and oc_prestationgroup_prestationuid=?";
		PreparedStatement ps = oc_conn.prepareStatement(sSql);
		ps.setString(1,sEditPrestationGroup);
		ps.setString(2,sEditPrestationName);
		ResultSet rs = ps.executeQuery();
		if(!rs.next()){
			rs.close();
			ps.close();
			
			sSql = "insert into oc_prestationgroups_prestations(oc_prestationgroup_groupuid,oc_prestationgroup_prestationuid)"+
			       " values(?,?)";
			ps=oc_conn.prepareStatement(sSql);
			ps.setString(1,sEditPrestationGroup);
			ps.setString(2,sEditPrestationName);
			ps.execute();
			ps.close();
		}
		else{
			rs.close();
			ps.close();
		}
	}
    //*** DELETE prestation ***
	else if(request.getParameter("deleteprestationuid")!=null){
		String sSql = "delete from oc_prestationgroups_prestations"+
	                  " where oc_prestationgroup_groupuid=? and oc_prestationgroup_prestationuid=?";
		PreparedStatement ps = oc_conn.prepareStatement(sSql);
		ps.setString(1,sEditPrestationGroup);
		ps.setString(2,request.getParameter("deleteprestationuid"));
		ps.executeUpdate();
		ps.close();
	}

    //*** DELETE group ***
	if(request.getParameter("deletegroupuid")!=null && request.getParameter("deletegroupuid").length()>0){
		String sSql = "delete from oc_prestation_groups"+
	                  " where oc_group_serverid=? and oc_group_objectid=?";
		PreparedStatement ps = oc_conn.prepareStatement(sSql);
		ps.setInt(1,Integer.parseInt(request.getParameter("deletegroupuid").split("\\.")[0]));
		ps.setInt(2,Integer.parseInt(request.getParameter("deletegroupuid").split("\\.")[1]));
		ps.executeUpdate();
		ps.close();
	}
%>
<form name='EditForm' method='POST'>
    <%=writeTableHeader("Web.manage","ManagePrestationGroups",sWebLanguage," doBack();")%>
    
	<table width="100%" class="list" cellpadding="0" cellspacing="1">
		<%-- PRESTATION GROUP --%>
		<tr>
			<td width="100" class="admin2"><%=getTran("web","prestationgroup",sWebLanguage)%></td>
			<td width="100" class="admin2">
				<select class="text" name="EditPrestationGroup" id="EditPrestationGroup" onchange="loadPrestations();">
                    <option/>
					<%
						String sSql = "select * from oc_prestation_groups"+
					                  " order by oc_group_description";
						PreparedStatement ps = oc_conn.prepareStatement(sSql);
						ResultSet rs = ps.executeQuery();
						while(rs.next()){
							String sGroupUid = rs.getInt("oc_group_serverid")+"."+rs.getInt("oc_group_objectid");
							out.println("<option "+(sEditPrestationGroup.equalsIgnoreCase(sGroupUid)?"selected":"")+" value='"+sGroupUid+"'>"+rs.getString("oc_group_description")+"</option>");
						}
						rs.close();
						ps.close();
						oc_conn.close();
					%>
				</select> <a href='javascript:deleteGroup();'><img class="link" src='<c:url value="/_img/icons/icon_delete.gif"/>'/></a>
			</td>
			<td class="admin2">
				<input type='text' class='text' name='newgroupname' id='newgroupname' size='25'/>
				<input type='button' class='button' name='newgroup' value='<%=getTranNoLink("web","new",sWebLanguage)%>' onclick='createNewGroup();'/>
			</td>
		</tr>
		
		<%-- PRESTATION --%>
		<tr>
            <td class="admin2"><%=getTran("web","prestation",sWebLanguage)%> *</td>
            <td class="admin2">
                <input type="hidden" name="tmpPrestationUID">
                <input type="hidden" name="tmpPrestationName">

                <select class="text" name="EditPrestationName" id="EditPrestationName">
                    <option/>
                    <%
                    	Vector vPopularPrestations = activeUser.getTopPopularPrestations(10);
                        if(vPopularPrestations!=null){
                            String sPrestationUid;
                            for(int i=0; i<vPopularPrestations.size(); i++){
                                sPrestationUid = checkString((String)vPopularPrestations.elementAt(i));
                                
                                if(sPrestationUid.length() > 0){
                                    Prestation prestation = Prestation.get(sPrestationUid);
                                    if(prestation!=null){
                                        out.print("<option value='"+checkString(prestation.getUid())+"'>"+checkString(prestation.getDescription())+"</option>");
                                    }
                                }
                            }
                        }
                    %>
                </select>
                <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchPrestation();">
            </td>
			<td class='admin2'>
			    <input type='button' class='button' onclick="doSubmit();" name='addprestation' value='<%=getTranNoLink("web","add",sWebLanguage)%>'/>
			</td>
        </tr>
	</table>
	
	<div id="prestationcontent"></div>
	
    <input type="hidden" name="tmpPrestationUID">
    <input type="hidden" name="tmpPrestationName">
    <input type="hidden" name="deleteprestationuid">
    <input type="hidden" name="deletegroupuid">	
</form>

<%=ScreenHelper.alignButtonsStart()%>
    <input type="button" class="button" name="backButton" value="<%=getTranNoLink("web","back",sWebLanguage)%>" OnClick="doBack();">
<%=ScreenHelper.alignButtonsStop()%>

<script>
  <%-- DO SUBMIT --%>
  function doSubmit(){
	if(EditForm.EditPrestationName.selectedIndex > 0){
	  EditForm.submit();
	}
	else{
	  alertDialog("web.manage","dataMissing");
	  EditForm.EditPrestationName.focus();
	}
  }
 
  <%-- LOAD PRESTATIONS --%>
  function loadPrestations(){
    var url= '<c:url value="/financial/getGroupPrestations.jsp"/>?ts='+new Date();
    new Ajax.Request(url,{
      method: "POST",
      postBody: 'PrestationGroupUID=' + EditForm.EditPrestationGroup.value,
      onSuccess: function(resp){
        var label = eval('('+resp.responseText+')');
        document.getElementById('prestationcontent').innerHTML = label.PrestationContent;
      },
      onFailure: function(){
        alert("error");
      }
    });
  }

  <%-- CREATE NEW GROUP --%>
  function createNewGroup(){
	if(document.getElementById("newgroupname").value.length > 0){
      EditForm.submit();
	}
	else{
      document.getElementById("newgroupname").focus();
	}
  }

  <%-- SEARCH PRESTATION --%>
  function searchPrestation(){
    EditForm.tmpPrestationName.value = "";
    EditForm.tmpPrestationUID.value = "";
    
    var url = "/_common/search/searchPrestation.jsp&ts=<%=getTs()%>"+
              "&ReturnFieldUid=tmpPrestationUID"+
              "&ReturnFieldDescr=tmpPrestationName"+
              "&doFunction=changeTmpPrestation()";
    openPopup(url);
  }

  <%-- CHANGE TMP PRESTATION --%>
  function changeTmpPrestation(){
    if(document.getElementsByName('tmpPrestationUID')[0].value.length>0){
      EditForm.EditPrestationName.options[0].text = document.getElementsByName('tmpPrestationName')[0].value;
      EditForm.EditPrestationName.options[0].value = document.getElementsByName('tmpPrestationUID')[0].value;
      EditForm.EditPrestationName.options[0].selected = true;
    }
  }

  <%-- DELETE PRESTATION --%>
  function deletePrestation(prestationuid){
	if(yesnoDeleteDialog()){
  	  document.getElementsByName('deleteprestationuid')[0].value=prestationuid;
	  EditForm.submit();
	}
  }

  <%-- DELETE GROUP --%>
  function deleteGroup(){
	if(yesnoDeleteDialog()){
      if(document.getElementsByName('EditPrestationGroup')[0].value.length>0){
        document.getElementsByName('deletegroupuid')[0].value=document.getElementsByName('EditPrestationGroup')[0].value;
	    EditForm.submit();
      }
    }
  }

  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<%=sCONTEXTPATH%>/main.jsp?Page=system/menu.jsp";
  }
  
  loadPrestations();		
</script>