<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<link type="text/css" rel="stylesheet" href='<c:url value="/"/>_common/_css/meals.css'/>
<%=checkPermission("manage.meals","all",activeUser)%>

<%
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n******************** meals/manageNutricientItems.jsp *******************");
    	Debug.println("No parameters\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
%>

<table class="list" width="100%" cellspacing="1" onKeyDown="if(enterEvent(event,13)){searchNutricientItems();return false;}">
    <%-- NUTRIENT NAME --%>
    <tr>
        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("meals","name",sWebLanguage)%></td>
        <td class="admin2" style="padding-left:5px;">
            <input type="text" class="text" id="FindNutricientName" name="FindNutricientName" size="50" maxLength="100">&nbsp;&nbsp;
            
            <%-- BUTTONS --%>
            <input type="button" class="button" name="searchButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","search",sWebLanguage))%>" onclick="searchNutricientItems();">
            <img src="<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif" class="link" title="<%=HTMLEntities.htmlentities(getTranNoLink("web","clear",sWebLanguage))%>" onclick="FindNutricientName.value='';FindNutricientName.focus();">&nbsp;&nbsp;
			<input type="button" class="button" name="newButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","new",sWebLanguage))%>" onclick="openNutricientItem('-1');">
        </td>
    </tr>
</table>
<br>

<div id="nutricientItemResultsByAjax">&nbsp;</div>

<script>
  var itemuid = "";

  <%-- SEARCH NUTRICIENT ITEMS --%>
  function searchNutricientItems(doSearch){
	if(doSearch==null) doSearch = true;
    var id = "nutricientItemResultsByAjax";
    $(id).update("<div id='wait'></div>");
    var params = (doSearch?"Action=search&":"")+
                 "FindNutricientName="+encodeURI($F("FindNutricientName"));
    if($("FindNutricientNameWindow")){
      params+= "&FindNutricientNameWindow="+encodeURI($F("FindNutricientNameWindow"))+
               "&withSearchFields=1";
    }
    var url = "<c:url value='/meals/ajax/getNutricientItems.jsp'/>?ts="+new Date().getTime();
    new Ajax.Updater(id,url,{parameters:params,evalScripts:true});
  }

  <%-- OPEN NUTRICIENT ITEM --%>
  function openNutricientItem(id){
    var params = "nutricientItemId="+id;
    var url = "<c:url value='/meals/ajax/getNutricientItem.jsp'/>?ts="+new Date().getTime();
    Modalbox.show(url,{title:"<%=getTran("meals","nutricientitem",sWebLanguage)%>",params:params,width:530});
  }

  <%-- SET NUTRICIENT ITEM --%>
  function setNutricientItem(){
	if($F("nutricientItemName").length > 0 && $F("nutricientItemUnit").length > 0){
      var params = "action=save"+
                   "&nutricientItemId="+$F("nutricientItemId")+
                   "&nutricientItemName="+encodeURI($F("nutricientItemName"))+
                   "&nutricientItemUnit="+encodeURI($F("nutricientItemUnit"));
      $("operationByAjax").update("<div id='wait'></div>");
      var url = "<c:url value='/meals/ajax/setNutricientItem.jsp'/>?ts="+new Date().getTime();
      new Ajax.Updater("operationByAjax",url,{parameters:params,evalScripts:true});
	}
	else{
           if($F("nutricientItemName").length==0) $("nutricientItemName").focus();
 	  else if($F("nutricientItemUnit").length==0) $("nutricientItemUnit").focus();
	 	  
 	            window.showModalDialog?alertDialog("web.manage","dataMissing"):alertDialogDirectText('<%=getTran("web.manage","dataMissing",sWebLanguage)%>');
	}
  }
  
  <%-- DELETE NUTRICIENT ITEM --%>
  function deleteNutricientItem(id){
    itemuid = id;
    yesnoModalBox("deleteNutricientItemNext()","<%=getTranNoLink("web","areYouSureToDelete",sWebLanguage)%>");
  }

  <%-- DELETE NUTRICIENT ITEM NEXT --%>
  function deleteNutricientItemNext(){
    if(itemuid.length > 0){
      $("operationByAjax").update("<div id='wait'></div>");
      var url = "<c:url value='/meals/ajax/setNutricientItem.jsp'/>"+
    		    "?action=delete"+
    		    "&nutricientItemId="+itemuid+
    		    "&ts="+new Date().getTime();
      new Ajax.Updater("operationByAjax",url,{evalScripts:true});
    }
  }
</script>