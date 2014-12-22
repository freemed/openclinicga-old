<%@page import="be.openclinic.medical.Problem,
                java.util.Vector,
                be.openclinic.medical.ReasonForEncounter,
                be.openclinic.adt.Encounter"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sRfe = "";
    Encounter encounter = Encounter.getActiveEncounter(activePatient.personid);
    if(encounter!=null){
        sRfe = ReasonForEncounter.getReasonsForEncounterAsHtml(encounter.getUid(),sWebLanguage,"_img/icons/icon_delete.gif","deleteRFE($serverid,$objectid)");
    }
%>

<table width="100%" class="list" height="100%" cellspacing="0">
    <tr class="admin">
        <td colspan="3">
            <%=getTran("openclinic.chuk","actualrfe",sWebLanguage)%>&nbsp;
            <%
                if(encounter!=null){
		            %><a href="javascript:showRFElist();"><img src="<c:url value='/_img/icons/icon_edit.gif'/>" class="link" alt="<%=getTranNoLink("web","editrfelist",sWebLanguage)%>" style="vertical-align:-4px;"></a><%
                }
            %>
        </td>
    </tr>
    <tr><td id="rfe"><%=sRfe%></td></tr>
    <tr height="99%"><td/></tr>
</table>

<%
    if(encounter!=null){
%>
<script>
  function showRFElist(){
    openPopup('healthrecord/findRFE.jsp&field=rfe&encounterUid=<%=encounter.getUid()%>&ts=<%=getTs()%>',700,400);
  }

  function deleteRFE(serverid,objectid){
      if(yesnoDeleteDialog()){
      var params = "serverid="+serverid+"&objectid="+objectid+"&encounterUid=<%=encounter.getUid()%>&language=<%=sWebLanguage%>";
      var url = '<c:url value="/healthrecord/deleteRFE.jsp"/>?ts='+new Date().getTime();
      new Ajax.Request(url,{
        method: "GET",
        parameters: params,
        onSuccess: function(resp){
          document.getElementById("rfe").innerHTML = resp.responseText;
        }
      });
    }
  }
</script>
<%
    }
%>  
