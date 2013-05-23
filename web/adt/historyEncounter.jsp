<%@ page import="be.openclinic.adt.*,be.openclinic.adt.Encounter.*,java.util.Vector" %>
<%@ page import="be.openclinic.medical.ReasonForEncounter" %>
<%@include file="/includes/validateUser.jsp"%>

<%=checkPermission("adt.encounterhistory","select",activeUser)%>
<%=sJSSORTTABLE%>

<%
    String sFindSortColumn = checkString(request.getParameter("SortColumn"));

    StringBuffer sbResults = new StringBuffer();

    if (sFindSortColumn.length() > 0) {
        sFindSortColumn += " DESC";
    } else {
        sFindSortColumn = " OC_ENCOUNTER_BEGINDATE DESC,OC_ENCOUNTER_OBJECTID DESC";
    }

    Vector vEncounters = Encounter.selectEncountersUnique("", "", "", "", "", "", "", "", activePatient.personid, sFindSortColumn);

    Iterator iter = vEncounters.iterator();
    Encounter eTmp = new Encounter();

    boolean bFinished = true;
    String sClass = "";
    String sInactive = "";
    String sInactiveSelect = "";
    String sUpdateUser = "";

    String sBegin = "", sEnd = "", sManagerName = "", sBedName = "", sServiceUID = "";
    //Timestamp ts1,ts2;
    //ts1 = new Timestamp(getSQLTime().getTime());
    while (iter.hasNext()) {
        eTmp = (Encounter) iter.next();

        if (bFinished && eTmp.getEnd() == null || eTmp.getEnd().after(ScreenHelper.getSQLDate(getDate()))) {
            bFinished = false;
        } else {
            bFinished = true;
        }
		
        if (eTmp.getBegin() != null) {
            sBegin = new SimpleDateFormat("dd/MM/yyyy").format(eTmp.getBegin());
        } else {
            sBegin = "";
        }

        if (eTmp.getEnd() != null) {
            sEnd = new SimpleDateFormat("dd/MM/yyyy").format(eTmp.getEnd());
        } else {
            sEnd = "";
        }

        if (checkString(eTmp.getManagerUID()).length() > 0) {
        	sManagerName = ScreenHelper.getFullUserName(eTmp.getManagerUID());
        } else {
            sManagerName = "";
        }

        if (checkString(eTmp.getBedUID()).length() > 0) {
            sBedName = checkString(eTmp.getBed().getName());
        } else {
            sBedName = "";
        }

        String sServices = "",sBeds="",sManagers="";
        Vector th = eTmp.getFullTransferHistory();
        for(int n=0;n<th.size();n++){
        	EncounterService es = (EncounterService)th.elementAt(n);
            if (checkString(es.serviceUID).length() > 0) {
                sServices+=(sServices.length()>0?"<BR/>":"")+(n+1)+": "+getTran("service",es.serviceUID,sWebLanguage)+" ("+new SimpleDateFormat("dd/MM/yyyy").format(es.begin)+")";
            }
            else{
                sServices+=(sServices.length()>0?"<BR/>":"")+(n+1)+": "+"-";
            }
            if (checkString(es.bedUID).length() > 0) {
            	Bed bed = Bed.get(es.bedUID);
            	if(bed!=null){
            		sBeds+=(sBeds.length()>0?"<BR/>":"")+(n+1)+": "+bed.getName();
            	}
                else{
                    sBeds+=(sBeds.length()>0?"<BR/>":"")+(n+1)+": "+"-";
                }
            }
            else{
                sBeds+=(sBeds.length()>0?"<BR/>":"")+(n+1)+": "+"-";
            }
            if (checkString(es.managerUID).length() > 0) {
                sManagers+=(sManagers.length()>0?"<BR/>":"")+(n+1)+": "+MedwanQuery.getInstance().getUserName(Integer.parseInt(es.managerUID));
            }
            else{
                sManagers+=(sManagers.length()>0?"<BR/>":"")+(n+1)+": "+"-";
            }
        	
        }
		
        if (eTmp.getUpdateUser()!=null){
        	sUpdateUser = MedwanQuery.getInstance().getUserName(Integer.parseInt(eTmp.getUpdateUser()));
        }
        if (bFinished) {
            sInactive = "Text";
            sInactiveSelect = "";
        } else {
            sInactive = "bold";
            sInactiveSelect = "bold";
        }

        if (sClass.equals("")) {
            sClass = "1";
        } else {
            sClass = "";
        }
        sbResults.append("<tr id='"+(bFinished?"finished":"")+"' class='list" + sInactive + sClass + "' " +
                " onmouseover=\"this.style.cursor='pointer';\" " +
                " onmouseout=\"this.style.cursor='default';\" >" +
                "<td id='"+eTmp.getUid()+"' width='20x'  onclick=\"delRow('" + eTmp.getUid() + "');\" ><img class='hand' src='/openclinic/_img/icon_delete.gif' alt='"+getTran("Web.Occup","medwan.common.delete",sWebLanguage)+"' border=\"0\"></td>" +
                "<td height='20' onclick=\"doSelect('" + eTmp.getUid() + "');\" >" + getTran("web", checkString(eTmp.getType()), sWebLanguage) + "</td>" +
                "<td onclick=\"doSelect('" + eTmp.getUid() + "');\">" + eTmp.getUid() + "</td>" +
                "<td onclick=\"doSelect('" + eTmp.getUid() + "');\">" + sBegin + "</td>" +
                "<td onclick=\"doSelect('" + eTmp.getUid() + "');\">" + sEnd + "</td>" +
                "<td onclick=\"doSelect('" + eTmp.getUid() + "');\">" + sManagers + "</td>" +
                "<td onclick=\"doSelect('" + eTmp.getUid() + "');\">" + sServices + "</td>" +
                "<td onclick=\"doSelect('" + eTmp.getUid() + "');\">" + sBeds + "</td>"+
		        "<td onclick=\"doSelect('" + eTmp.getUid() + "');\">" + sUpdateUser + "</td>");
        if(activeUser.getAccessRight("problemlist.select")){
            sbResults.append("<td onclick=\"doSelect('" + eTmp.getUid() + "');\">" + ReasonForEncounter.getReasonsForEncounterAsHtml(eTmp.getUid(),sWebLanguage) + "</td>");
        }
        sbResults.append("</tr>");
    }
    //ts2 = new Timestamp(getSQLTime().getTime());
    String sTitle1 = getTran("Web", "begindate", sWebLanguage);
    String sTitle2 = getTran("Web", "enddate", sWebLanguage);

    if (sFindSortColumn.length() > 0) {
        sTitle1 = "<i>" + sTitle1 + "</i>";
    } else {
        sTitle2 = "<i>" + sTitle2 + "</i>";
    }
%>

<form name='HistoryEncounterForm' method='post' action="<c:url value='/main.do'/>?Page=adt/historyEncounter.jsp&ts<%=getTs()%>">

<%=writeTableHeader("web","historyencounters",sWebLanguage," doBack();")%>

<table width='100%' cellspacing="0" cellpadding="0" class="sortable" id="searchresults">
    <tr class="gray">
        <td width="20px"></td>
        <td><%=getTran("Web","type",sWebLanguage)%></td>
        <td><%=getTran("Web","id",sWebLanguage)%></td>
        <td><%=sTitle1%></td>
        <td><%=sTitle2%></td>
        <td><%=getTran("Web","manager",sWebLanguage)%></td>
        <td><%=getTran("Web","service",sWebLanguage)%></td>
        <td><%=getTran("Web","bed",sWebLanguage)%></td>
        <td><%=getTran("Web","updatedby",sWebLanguage)%></td>
        <%
            if(activeUser.getAccessRight("problemlist.select")){
        %>
        <td><%=getTran("openclinic.chuk","rfe",sWebLanguage)%></td>
        <%
            }
        %>
    </tr>
    <%=sbResults%>
</table>
<input type='hidden' name='SortColumn' value=''>
<%=ScreenHelper.alignButtonsStart()%>
    <%-- Buttons --%>
    <input class='button' type="button" name="Backbutton" value='<%=getTranNoLink("Web","Back",sWebLanguage)%>' onclick="doBack();">
<%=ScreenHelper.alignButtonsStop()%>
</form>
<script>
  function doSelect(id){
    window.location.href="<c:url value='/main.do'/>?Page=adt/editEncounter.jsp&EditEncounterUID=" + id + "&ts=<%=getTs()%>";
  }

  function doBack(){
    window.location.href="<c:url value='/main.do'/>?Page=curative/index.jsp&ts=<%=getTs()%>";
  }

  <%-- UPDATE ROW STYLES --%>
  function updateRowStyles(){
    var sClassName;

    for(var i=1; i<searchresults.rows.length; i++){
      searchresults.rows[i].style.cursor = "hand";
      sClassName = searchresults.rows[i].className;

      if(sClassName.indexOf("Text") > -1){
        searchresults.rows[i].className = "listText";
      }
      else if(sClassName.indexOf("bold") > -1){
        searchresults.rows[i].className = "listbold";
      }
      else{
        searchresults.rows[i].className = "list";
      }

      if(i%2>0){
        searchresults.rows[i].className+= "1";
      }

      if(i%2>0){
        searchresults.rows[i].onmouseout = function(){
          if(this.id.indexOf("finished")==0){
            this.className = "listText1";
          }
          else{
            this.className = "listbold1";
          }
        }
      }
      else{
        searchresults.rows[i].onmouseout = function(){
          if(this.id.indexOf("finished")==0){
            this.className = "listText";
          }
          else{
            this.className = "listbold";
          }
        }
      }
    }
  }
   function delRow(id){
    var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/yesnoPopup.jsp&ts=<%=getTs()%>&labelType=web.occup&labelID=medwan.transaction.delete.information";
      var answer =(window.showModalDialog)?window.showModalDialog(popupUrl,'',modalities):window.confirm("<%=getTranNoLink("web","areyousuretodelete",sWebLanguage)%>");
      if(answer==1){
        new Ajax.Request('<c:url value="/adt/ajaxActions/deleteEncounter.jsp"/>?EditEncounterUID=' + id,{
          onSuccess: function(resp){
            if(resp.responseText.blank() && $(id)){
                 $(id).parentNode.style.display = "none";
            }
            else{
                var label = eval('('+resp.responseText+')');
                if(label.Message=="exists"){
                    alert("<%=getTranNoLink("web.errors","error.encounter.exists.in.other.data",sWebLanguage)%>");
                }
            }
          }
      }) ;

     } 

  }
</script>