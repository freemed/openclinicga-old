<%@ page import="java.util.Hashtable,be.openclinic.finance.Prestation" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
	String sEditPrestationGroup=checkString(request.getParameter("EditPrestationGroup"));
	String sEditPrestationName=checkString(request.getParameter("EditPrestationName"));
    Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
	if(request.getParameter("newgroupname")!=null && request.getParameter("newgroupname").length()>0){
		String sGroupName=request.getParameter("newgroupname");
		String sSql="select * from oc_prestation_groups where oc_group_description=?";
		PreparedStatement ps=oc_conn.prepareStatement(sSql);
		ps.setString(1,sGroupName);
		ResultSet rs = ps.executeQuery();
		if(!rs.next()){
			rs.close();
			ps.close();
			sSql="insert into oc_prestation_groups(oc_group_serverid,oc_group_objectid,oc_group_description) values(?,?,?)";
			ps=oc_conn.prepareStatement(sSql);
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
	else if(request.getParameter("addprestation")!=null && sEditPrestationGroup.length()>0 && sEditPrestationName.length()>0){
		String sSql="select * from oc_prestationgroups_prestations where oc_prestationgroup_groupuid=? and oc_prestationgroup_prestationuid=?";
		PreparedStatement ps=oc_conn.prepareStatement(sSql);
		ps.setString(1,sEditPrestationGroup);
		ps.setString(2,sEditPrestationName);
		ResultSet rs = ps.executeQuery();
		if(!rs.next()){
			rs.close();
			ps.close();
			sSql="insert into oc_prestationgroups_prestations(oc_prestationgroup_groupuid,oc_prestationgroup_prestationuid) values(?,?)";
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
	else if(request.getParameter("deleteprestationuid")!=null){
		String sSql="delete from oc_prestationgroups_prestations where oc_prestationgroup_groupuid=? and oc_prestationgroup_prestationuid=?";
		PreparedStatement ps=oc_conn.prepareStatement(sSql);
		ps.setString(1,sEditPrestationGroup);
		ps.setString(2,request.getParameter("deleteprestationuid"));
		ps.executeUpdate();
		ps.close();
	}
	if(request.getParameter("deletegroupuid")!=null && request.getParameter("deletegroupuid").length()>0){
		String sSql="delete from oc_prestation_groups where oc_group_serverid=? and oc_group_objectid=?";
		PreparedStatement ps=oc_conn.prepareStatement(sSql);
		ps.setInt(1,Integer.parseInt(request.getParameter("deletegroupuid").split("\\.")[0]));
		ps.setInt(2,Integer.parseInt(request.getParameter("deletegroupuid").split("\\.")[1]));
		ps.executeUpdate();
		ps.close();
	}
%>
<form name='EditForm' method='POST'>
	<table>
		<tr class='admin'>
			<td><%=getTran("web","prestationgroup",sWebLanguage)%></td>
			<td>
				<select class="text" name="EditPrestationGroup" id="EditPrestationGroup" onchange="loadPrestations();">
                    <option/>
					<%
						String sSql="select * from oc_prestation_groups order by oc_group_description";
						PreparedStatement ps=oc_conn.prepareStatement(sSql);
						ResultSet rs = ps.executeQuery();
						while(rs.next()){
							String sGroupUid=rs.getInt("oc_group_serverid")+"."+rs.getInt("oc_group_objectid");
							out.println("<option "+(sEditPrestationGroup.equalsIgnoreCase(sGroupUid)?"selected":"")+" value='"+sGroupUid+"'>"+rs.getString("oc_group_description")+"</option>");
						}
						rs.close();
						ps.close();
						oc_conn.close();
					%>
				</select> <a href='javascript:deletegroup();'><img src='<c:url value="/_img/icon_delete.gif"/>'/></a>
			</td>
			<td>
				<input type='text' class='text' name='newgroupname' id='newgroupname' size='25'/>
				<input type='button' class='text' name='newgroup' value='<%=getTran("web","new",sWebLanguage)%>' onclick='createnewgroup();'/>
			</td>
		</tr>
		<tr>
            <td class='admin'><%=getTran("web","prestation",sWebLanguage)%> *</td>
            <td class='admin2'>
                <input type="hidden" name="tmpPrestationUID">
                <input type="hidden" name="tmpPrestationName">

                <select class="text" name="EditPrestationName" id="EditPrestationName" onchange="">
                    <option/>
                    <%
                    Vector vPopularPrestations = activeUser.getTopPopularPrestations(10);
                        if (vPopularPrestations!=null){
                            String sPrestationUid;
                            for (int i=0;i<vPopularPrestations.size();i++){
                                sPrestationUid = checkString((String)vPopularPrestations.elementAt(i));
                                if (sPrestationUid.length()>0){
                                    Prestation prestation = Prestation.get(sPrestationUid);

                                    if (prestation!=null){
                                        out.print("<option value='"+checkString(prestation.getUid())+"'");

                                        out.print(">"+checkString(prestation.getDescription())+"</option>");
                                    }
                                }
                            }
                        }
                    %>
                </select>
                <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("Web","select",sWebLanguage)%>" onclick="searchPrestation();">
            </td>
			<td class='admin2'><input type='submit' class='text' name='addprestation' value='<%=getTran("web","add",sWebLanguage)%>'/></td>
        </tr>
		
		<tr id='prestationcontent'/>
	</table>
    <input type="hidden" name="tmpPrestationUID">
    <input type="hidden" name="tmpPrestationName">
    <input type="hidden" name="deleteprestationuid">
    <input type="hidden" name="deletegroupuid">
	
</form>

<script>

	function loadPrestations(){
        var today = new Date();
        var url= '<c:url value="/financial/getGroupPrestations.jsp"/>?ts='+today;
        new Ajax.Request(url,{
            method: "POST",
            postBody: 'PrestationGroupUID=' + EditForm.EditPrestationGroup.value,
            onSuccess: function(resp){
                var label = eval('('+resp.responseText+')');
                document.getElementById('prestationcontent').innerHTML=label.PrestationContent;
            },
            onFailure: function(){
                alert("error");
            }
        });
	}

	function createnewgroup(){
		if(document.getElementById('newgroupname').value.length>0){
			EditForm.submit();
		}
	}

    function searchPrestation(){
        EditForm.tmpPrestationName.value = "";
        EditForm.tmpPrestationUID.value = "";
        openPopup("/_common/search/searchPrestation.jsp&ts=<%=getTs()%>&ReturnFieldUid=tmpPrestationUID&ReturnFieldDescr=tmpPrestationName&doFunction=changeTmpPrestation()");
    }

    function changeTmpPrestation(){
        if (document.getElementsByName('tmpPrestationUID')[0].value.length>0){
            EditForm.EditPrestationName.options[0].text = document.getElementsByName('tmpPrestationName')[0].value;
            EditForm.EditPrestationName.options[0].value = document.getElementsByName('tmpPrestationUID')[0].value;
            EditForm.EditPrestationName.options[0].selected = true;
        }
    }

    function deleteprestation(prestationuid){
		document.getElementsByName('deleteprestationuid')[0].value=prestationuid;
		EditForm.submit();
    }

    function deletegroup(){
        if(document.getElementsByName('EditPrestationGroup')[0].value.length>0){
			document.getElementsByName('deletegroupuid')[0].value=document.getElementsByName('EditPrestationGroup')[0].value;
			EditForm.submit();
        }
    }
    
	loadPrestations();
		
</script>