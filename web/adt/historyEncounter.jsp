<%@page import="be.openclinic.adt.*,
                be.openclinic.adt.Encounter.*,
                java.util.Vector,
                be.openclinic.medical.ReasonForEncounter"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("adt.encounterhistory","select",activeUser)%>
<%=sJSSORTTABLE%>

<%
    String sFindSortColumn = checkString(request.getParameter("SortColumn"));

	/// DEBUG ///////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n***************** adt/historyEncounter.jsp ******************");
		Debug.println("sFindSortColumn : "+sFindSortColumn+"\n");
	}
	/////////////////////////////////////////////////////////////////////////////////////

    StringBuffer sbResults = new StringBuffer();

    if(sFindSortColumn.length() > 0){
        sFindSortColumn+= " DESC";
    } 
    else{
        sFindSortColumn = " OC_ENCOUNTER_BEGINDATE DESC,OC_ENCOUNTER_OBJECTID DESC";
    }

    Vector vEncounters = Encounter.selectEncountersUnique("","","","","","","","",activePatient.personid,sFindSortColumn);
    Debug.println("--> vEncounters : "+vEncounters.size());

    boolean bFinished = true;
    String sClass = "", sInactive = "", sInactiveSelect = "", sUpdateUser = "";
    String sBegin = "", sEnd = "", sManagerName = "", sBedName = "", sServiceUID = "";

    Iterator encIter = vEncounters.iterator();
    Encounter tmpEnc = new Encounter();
    
    while(encIter.hasNext()){
    	tmpEnc = (Encounter)encIter.next();

        if(bFinished && tmpEnc.getEnd() == null || tmpEnc.getEnd().after(ScreenHelper.getSQLDate(getDate()))){
            bFinished = false;
        } else {
            bFinished = true;
        }
		
        if(tmpEnc.getBegin() != null){
            sBegin = ScreenHelper.stdDateFormat.format(tmpEnc.getBegin());
        } else {
            sBegin = "";
        }

        if(tmpEnc.getEnd() != null){
            sEnd = ScreenHelper.stdDateFormat.format(tmpEnc.getEnd());
        } else {
            sEnd = "";
        }

        if(checkString(tmpEnc.getManagerUID()).length() > 0){
        	sManagerName = ScreenHelper.getFullUserName(tmpEnc.getManagerUID());
        } else {
            sManagerName = "";
        }

        if(checkString(tmpEnc.getBedUID()).length() > 0){
            sBedName = checkString(tmpEnc.getBed().getName());
        }

        //*** list transfer history ***
        String sServices = "", sBeds = "", sManagers = "";
        Vector tranHist = tmpEnc.getFullTransferHistory();
        for(int n=0; n<tranHist.size(); n++){
        	// services
        	EncounterService encServ = (EncounterService)tranHist.elementAt(n);
            if(checkString(encServ.serviceUID).length() > 0){
                sServices+=(sServices.length()>0?"<BR/>":"")+(n+1)+": "+getTran("service",encServ.serviceUID,sWebLanguage)+" ("+ScreenHelper.stdDateFormat.format(encServ.begin)+")";
            }
            else{
                sServices+=(sServices.length()>0?"<BR/>":"")+(n+1)+": "+"-";
            }
            
            // beds
            if(checkString(encServ.bedUID).length() > 0){
            	Bed bed = Bed.get(encServ.bedUID);
            	if(bed!=null){
            		sBeds+= (sBeds.length()>0?"<BR/>":"")+(n+1)+": "+bed.getName();
            	}
                else{
                    sBeds+= (sBeds.length()>0?"<BR/>":"")+(n+1)+": "+"-";
                }
            }
            else{
                sBeds+= (sBeds.length()>0?"<BR/>":"")+(n+1)+": "+"-";
            }
            
            // managers
            if(checkString(encServ.managerUID).length() > 0){
                sManagers+= (sManagers.length()>0?"<BR/>":"")+(n+1)+": "+MedwanQuery.getInstance().getUserName(Integer.parseInt(encServ.managerUID));
            }
            else{
                sManagers+= (sManagers.length()>0?"<BR/>":"")+(n+1)+": "+"-";
            }
        	
        }
		
        if(tmpEnc.getUpdateUser()!=null){
        	sUpdateUser = MedwanQuery.getInstance().getUserName(Integer.parseInt(tmpEnc.getUpdateUser()));
        }
        
        // active ?
        if(bFinished){
            sInactive = "Text";
            sInactiveSelect = "";
        }
        else{
            sInactive = "bold";
            sInactiveSelect = "bold";
        }

        // alternate row-style
        if(sClass.length()==0) sClass = "1";
        else                   sClass = "";
        
        sbResults.append("<tr id='"+(bFinished?"finished":"")+"' class='list"+sInactive+sClass+"'")
                 .append("onmouseover=\"this.style.cursor='pointer';\" onmouseout=\"this.style.cursor='default';\">")
                  .append("<td id='"+tmpEnc.getUid()+"' width='20px' onclick=\"deleteEncounter('"+tmpEnc.getUid()+"');\"><img class='hand' src='/openclinic/_img/icons/icon_delete.gif' alt='"+getTranNoLink("Web.Occup","medwan.common.delete",sWebLanguage)+"' border='0'></td>")
                  .append("<td height='20' onclick=\"doSelect('"+tmpEnc.getUid()+"');\" >"+getTran("web",checkString(tmpEnc.getType()),sWebLanguage)+"</td>")
                  .append("<td onclick=\"doSelect('"+tmpEnc.getUid()+"');\">"+tmpEnc.getUid()+"</td>")
                  .append("<td onclick=\"doSelect('"+tmpEnc.getUid()+"');\">"+sBegin+"</td>")
                  .append("<td onclick=\"doSelect('"+tmpEnc.getUid()+"');\">"+sEnd+"</td>")
                  .append("<td onclick=\"doSelect('"+tmpEnc.getUid()+"');\">"+sManagers+"</td>")
                  .append("<td onclick=\"doSelect('"+tmpEnc.getUid()+"');\">"+sServices+"</td>")
                  .append("<td onclick=\"doSelect('"+tmpEnc.getUid()+"');\">"+sBeds+"</td>")
                  .append("<td onclick=\"doSelect('"+tmpEnc.getUid()+"');\">"+sUpdateUser+"</td>");
        
        if(activeUser.getAccessRight("problemlist.select")){
            sbResults.append("<td onclick=\"doSelect('"+tmpEnc.getUid()+"');\">"+ReasonForEncounter.getReasonsForEncounterAsHtml(tmpEnc.getUid(),sWebLanguage)+"</td>");
        }
        sbResults.append("</tr>");
    }

    String sTitle1 = getTran("web","begindate",sWebLanguage),
           sTitle2 = getTran("web","enddate",sWebLanguage);

    if(sFindSortColumn.length() > 0){
        sTitle1 = "<i>"+sTitle1+"</i>";
    } 
    else {
        sTitle2 = "<i>"+sTitle2+"</i>";
    }
%>

<form name="HistoryEncounterForm" method="post">
<%=writeTableHeader("web","historyEncounters",sWebLanguage," doBack();")%>

<%
    if(sbResults.length() > 0){
        %>
			<table width="100%" cellspacing="0" cellpadding="0" class="sortable" id="searchresults">
			    <%-- HEADER --%>
			    <tr class="gray">
			        <td width="20px"></td>
			        <td><%=getTran("web","type",sWebLanguage)%>&nbsp;</td>
			        <td><%=getTran("web","id",sWebLanguage)%>&nbsp;</td>
			        <td><%=sTitle1%>&nbsp;</td>
			        <td><%=sTitle2%>&nbsp;</td>
			        <td><%=getTran("web","manager",sWebLanguage)%>&nbsp;</td>
			        <td><%=getTran("web","service",sWebLanguage)%>&nbsp;</td>
			        <td><%=getTran("web","bed",sWebLanguage)%>&nbsp;</td>
			        <td><%=getTran("web","updatedby",sWebLanguage)%>&nbsp;</td>
			        <%
			            if(activeUser.getAccessRight("problemlist.select")){
					        %><td><%=getTran("openclinic.chuk","rfe",sWebLanguage)%>&nbsp;</td><%
			            }
			        %>
			    </tr>
			    
			    <%=sbResults%>
		    </table>
        <%
    }
    else{
    	%><div style="padding:3px;"><%=getTran("web","noRecordsFound",sWebLanguage)%></div><%
    }
%>

<%-- BUTTONS --%>
<%=ScreenHelper.alignButtonsStart()%>
    <input class="button" type="button" name="Backbutton" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onclick="doBack();">
<%=ScreenHelper.alignButtonsStop()%>
</form>

<script>
  function doSelect(id){
    window.location.href = "<c:url value='/main.do'/>?Page=adt/editEncounter.jsp&EditEncounterUID="+id+"&ts=<%=getTs()%>";
  }

  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=curative/index.jsp&ts=<%=getTs()%>";
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

  <%-- DELETE ENCOUNTER --%>
  function deleteEncounter(id){
      if(yesnoDeleteDialog()){
      var url = "<c:url value='/adt/ajaxActions/deleteEncounter.jsp'/>?EditEncounterUID="+id+"&ts="+new Date().getTime();
      new Ajax.Request(url,{
        onSuccess: function(resp){
          if(resp.responseText.blank() && $(id)){
            $(id).parentNode.style.display = "none";
          }
          else{
            var label = eval("("+resp.responseText+")");
            if(label.Message=="exists"){
              alertDialog("web.errors","error.encounter.exists.in.other.data");
            }
          }
        },
        onError: function(resp){
          alert(resp.responseText);
        }
      });
    } 
  }
</script>