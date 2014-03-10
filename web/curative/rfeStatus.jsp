<%@ page import="be.openclinic.medical.Problem"%>
<%@ page import="java.util.Vector"%>
<%@ page import="be.openclinic.medical.ReasonForEncounter"%>
<%@ page import="be.openclinic.adt.Encounter"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sRfe = "";
    Encounter encounter = Encounter.getActiveEncounter(activePatient.personid);
    if(encounter!=null){
        sRfe=ReasonForEncounter.getReasonsForEncounterAsHtml(encounter.getUid(),sWebLanguage,"_img/icon_delete.gif","deleteRFE($serverid,$objectid)");
    }
%>

<table width="100%" class="list" height="100%" cellspacing="0">
    <tr class="admin">
        <td colspan="3">
            <%=getTran("openclinic.chuk","actualrfe",sWebLanguage)%>&nbsp;
            <%
                if(encounter!=null){
		            %><a href="javascript:showRFElist();"><img src="<c:url value='/_img/icon_edit.gif'/>" class="link" alt="<%=getTran("web","editrfelist",sWebLanguage)%>" style="vertical-align:-4px;"></a><%
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
    if(yesnoDialog("Web","areYouSureToDelete")){
      var params = "serverid="+serverid+"&objectid="+objectid+"&encounterUid=<%=encounter.getUid()%>&language=<%=sWebLanguage%>";
      var today = new Date();
      var url= '<c:url value="/healthrecord/deleteRFE.jsp"/>?ts='+today;
      new Ajax.Request(url,{
        method: "GET",
        parameters: params,
        onSuccess: function(resp){
          document.getElementById("rfe").innerHTML=resp.responseText;
        }
      });
    }
  }
</script>
<%
    }
%>  
