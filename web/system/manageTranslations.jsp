<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<script src='<%=sCONTEXTPATH%>/_common/_script/prototype.js'></script>
<script src='<%=sCONTEXTPATH%>/_common/_script/stringFunctions.js'></script>
<%=checkPermission("system.managetranslations","all",activeUser)%>

<%
    // get values from form
    String findLabelID    = checkString(request.getParameter("FindLabelID")),
           findLabelType  = checkString(request.getParameter("FindLabelType")),
           findLabelLang  = checkString(request.getParameter("FindLabelLang")),
           findLabelValue = checkString(request.getParameter("FindLabelValue"));

    String editLabelID    = checkString(request.getParameter("EditLabelID")).toLowerCase(),
           editLabelType  = checkString(request.getParameter("EditLabelType")).toLowerCase();

    String editShowLink = checkString(request.getParameter("EditShowLink"));

    // supported languages
    String supportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages");
    if(supportedLanguages.length()==0) supportedLanguages = "nl,fr";

    // exclusions on labeltype
    boolean excludeServices  = checkString(request.getParameter("excludeServices")).equals("true"),
            excludeFunctions = checkString(request.getParameter("excludeFunctions")).equals("true");


    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n****************** system/manageTranslations.jsp *********************");
      	Debug.println("findLabelID      : "+findLabelID);
       	Debug.println("findLabelType    : "+findLabelType);
       	Debug.println("findLabelLang    : "+findLabelLang);
       	Debug.println("findLabelValue   : "+findLabelValue);
       	
       	Debug.println("editLabelID   : "+editLabelID);
       	Debug.println("editLabelType : "+editLabelType);
       	Debug.println("editShowLink  : "+editShowLink);
       	
       	Debug.println("supportedLanguages : "+supportedLanguages);       	
       	Debug.println("excludeServices    : "+excludeServices);
       	Debug.println("excludeFunctions   : "+excludeFunctions+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    boolean labelAllreadyExists = false;
    boolean invalidCharFound = false;
    String msg = null;
%>

<form name="transactionForm" method="post" action="<c:url value='/main.do'/>?Page=system/manageTranslations.jsp&ts=<%=getTs()%>">
<%=writeTableHeader("Web","ManageTranslations",sWebLanguage,"main.do?Page=system/menu.jsp")%>

<%-- SEARCH TABLE -------------------------------------------------------------------------------%>
<table width="100%" cellspacing="1" class="menu" onkeydown="if(enterEvent(event,13)){doFind();}">
    <%-- LABEL TYPE --%>
    <tr>
      <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web","type",sWebLanguage)%></td>
      <td class="admin2" id="FindLabelTypeDiv">
          <select id="FindLabelType" class="text">
              <option></option>
              <%
                  String sTmpLabeltype;
                  java.util.Vector vLabelTypes = Label.getLabelTypes();
                  Iterator iter = vLabelTypes.iterator();

                  while(iter.hasNext()){
                      sTmpLabeltype = (String)iter.next();
                      %><option value="<%=sTmpLabeltype%>" <%=(sTmpLabeltype.equals(findLabelType)?"selected":"")%>><%=sTmpLabeltype%></option><%
                  }
              %>
          </select>
      </td>
  </tr>
  
  <%-- LABEL ID --%>
  <tr>
      <td class="admin"><%=getTran("Web.Translations","labelid",sWebLanguage)%></td>
      <td class="admin2">
          <input type="text" class="text" id="FindLabelID" value="<%=findLabelID%>" size="50">
      </td>
  </tr>
  
  <%-- LABEL LANGUAGE --%>
  <tr>
      <td class="admin"><%=getTran("Web","Language",sWebLanguage)%></td>
      <td class="admin2">
          <select id="FindLabelLang" class="text">
              <option value=""></option>
              <%
                  String tmpLang;
                  StringTokenizer tokenizer = new StringTokenizer(supportedLanguages,",");
                  while(tokenizer.hasMoreTokens()){
                      tmpLang = tokenizer.nextToken();
                      %><option value="<%=tmpLang%>" <%=(findLabelLang.equals(tmpLang)?"selected":"")%>><%=getTran("Web.language",tmpLang,sWebLanguage)%></option><%
                  }
              %>
          </select>
      </td>
  </tr>
  
  <%-- LABEL VALUE --%>
  <tr>
      <td class="admin"><%=getTran("Web.Translations","label",sWebLanguage)%></td>
      <td class="admin2">
          <input type="text" class="text" id="FindLabelValue" value="<%=findLabelValue%>" size="50">
      </td>
  </tr>
  
  <%-- EXCLUSIONS --%>
  <tr>
      <td class="admin"><%=getTran("Web.Translations","exclusion",sWebLanguage)%></td>
      <td class="admin2">
          <input type="checkbox" name="excludeFunctions" id="excludeFunctionsCB" value="true" <%=(excludeFunctions?" CHECKED":"")%>><%=getLabel("web","functions",sWebLanguage,"excludeFunctionsCB")%>&nbsp;
          <input type="checkbox" name="excludeServices" id="excludeServicesCB" value="true" <%=(excludeServices?" CHECKED":"")%>><%=getLabel("web","services",sWebLanguage,"excludeServicesCB")%>
      </td>
  </tr>
  
  <%-- SEARCH BUTTONS --%>
  <tr>
      <td class="admin">&nbsp;</td>
      <td class="admin2">
	      <input type="button" class="button" name="FindButton" value="<%=getTranNoLink("Web","Find",sWebLanguage)%>" onclick="doFind();">&nbsp;
	      <input type="button" class="button" name="ClearButton" value="<%=getTranNoLink("Web","Clear",sWebLanguage)%>" onClick="clearFindFields();">&nbsp;
	      <input type="button" class="button" name="NewButton" value="<%=getTranNoLink("Web","New",sWebLanguage)%>" onClick="doNew();">
	      <input type="button" class="button" name="Backbutton" value="<%=getTranNoLink("Web","Back",sWebLanguage)%>" onclick="doBack();">
      </td>
  </tr>
</table>
<br>

<div style="height:200px;width:100%;border:none;" id="divFindRecords"></div>

<script>  
  <%-- do find --%>
  function doFind(){
    if($('FindLabelType').value.length>0 || $('FindLabelID').value.length>0 || $('FindLabelValue').value.length>0){
      var params = "FindLabelType="+document.getElementById('FindLabelType').value+
                   "&FindLabelID="+document.getElementById('FindLabelID').value+
                   "&FindLabelLang="+document.getElementById('FindLabelLang').value+
                   "&FindLabelValue="+document.getElementById('FindLabelValue').value;
	  var url = "<%=sCONTEXTPATH%>/system/manageTranslationsFind.jsp?ts="+new Date();
	  new Ajax.Request(url,{
		method: "GET",
        parameters: params,
        onSuccess: function(resp){
		  $('divFindRecords').innerHTML = resp.responseText;
		}
	  });
    }
    else{
      alertDialog("web.manage","dataMissing");
    }
  }

  <%-- SET LABEL --%>
  function setLabel(sType,sID){
    transactionForm.EditOldLabelType.value = sType;
    transactionForm.EditOldLabelID.value = sID;
    transactionForm.EditLabelType.value = sType;
    transactionForm.EditLabelID.value = sID;

    var params = "EditOldLabelType="+sType+
                 "&EditOldLabelID="+sID;
	var url = "<%=sCONTEXTPATH%>/system/manageTranslationsEdit.jsp?ts="+new Date();
	new Ajax.Request(url,{
      method: "GET",
      parameters: params,
      onSuccess: function(resp){
        var label = eval('('+resp.responseText+')');
        var sLabel = label;
        <%
            tokenizer = new StringTokenizer(supportedLanguages,",");
            while(tokenizer.hasMoreTokens()){
                tmpLang = tokenizer.nextToken();
                out.print("transactionForm.EditLabelValue"+tmpLang.toUpperCase()+".value=label.EditLabelValue"+tmpLang.toUpperCase()+".htmlEntities();");
            }
        %>
        $('EditShowLink').value = label.editShowLink;
      }
    });
  }

  <%-- do new --%>
  function doNew(){
    transactionForm.EditLabelID.value = "";
    transactionForm.EditLabelType.value = "";

    transactionForm.EditOldLabelID.value = "";
    transactionForm.EditOldLabelType.value = "";
    <%
        tokenizer = new StringTokenizer(supportedLanguages,",");
        while(tokenizer.hasMoreTokens()){
            tmpLang = tokenizer.nextToken();
            out.print("transactionForm.EditLabelValue"+tmpLang.toUpperCase()+".value ='';");
        }
    %>
    transactionForm.EditLabelType.focus();

    divMessage.innerHTML = "";
  }

  <%-- do back --%>
  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=system/menu.jsp";
  }

  <%-- clear find fields --%>
  function clearFindFields(){
    transactionForm.FindLabelType.selectedIndex = 0;
    transactionForm.FindLabelID.value = "";
    transactionForm.FindLabelLang.selectedIndex = 0;
    transactionForm.FindLabelValue.value = "";

    transactionForm.excludeFunctions.checked = true;
    transactionForm.excludeServices.checked = true;
  }
</script>
<br>

<%-- EDIT TABLE ---------------------------------------------------------------------%>
<table class="list" width="100%" cellspacing="1">
  <%-- type --%>
  <tr>
      <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web.Translations","LabelType",sWebLanguage)%></td>
      <td class="admin2">
          <input type="text" class="normal" name="EditLabelType" id="EditLabelType" value="<%=editLabelType%>" size="80">
      </td>
  </tr>
  
  <%-- id --%>
  <tr>
      <td class="admin"><%=getTran("Web.Translations","LabelID",sWebLanguage)%></td>
      <td class="admin2">
          <input type="text" class="normal" name="EditLabelID" id="EditLabelID" value="<%=editLabelID%>" size="80">
      </td>
  </tr>
  
  <%-- value --%>
  <%
      tokenizer = new StringTokenizer(supportedLanguages,",");
      while(tokenizer.hasMoreTokens()){
          tmpLang = tokenizer.nextToken();
          %>
		  <tr>
		      <td class="admin"><%=getTran("Web.Translations","Label",sWebLanguage)+" "+tmpLang.toUpperCase()%></td>
		      <td class="admin2">
		          <textarea name="EditLabelValue<%=tmpLang.toUpperCase()%>" class="normal" rows="4" cols="80" onKeyDown="textCounter(this,document.transactionForm.remLen<%=tmpLang.toUpperCase()%>,250)" onKeyUp="textCounter(this,document.transactionForm.remLen<%=tmpLang.toUpperCase()%>,250);resizeTextarea(this,10);"><%=getTranNoLink(editLabelType,editLabelID,tmpLang)%></textarea>
		          <input readonly type="text" class="text" name="remLen<%=tmpLang.toUpperCase()%>" size="3" value="250">
		      </td>
		  </tr>
        <%
      }
  %>

  <%-- show link --%>
  <tr>
      <td class="admin"><%=getTran("Web.Translations","ShowLink",sWebLanguage)%></td>
      <td class="admin2">
          <select name="EditShowLink" class="text">
              <option value="1"<%=(editShowLink.equals("1")?" selected":"")%>><%=getTran("Web","Yes",sWebLanguage)%></option>
              <option value="0"<%=(editShowLink.equals("0")?" selected":"")%>><%=getTran("Web","No",sWebLanguage)%></option>
          </select>
      </td>
  </tr>
  
  <%-- EDIT BUTTONS --%>
  <%=ScreenHelper.setFormButtonsStart()%>
      <input class="button" type="button" name="AddButton" value="<%=getTranNoLink("Web","Add",sWebLanguage)%>" onclick="checkSave('Add');">&nbsp;
      <input class="button" type="button" name="SaveButton" value="<%=getTranNoLink("Web","Save",sWebLanguage)%>" onclick="checkSave('Save');">&nbsp;
      <input class="button" type="button" name="DeleteButton" value="<%=getTranNoLink("Web","Delete",sWebLanguage)%>" onclick="askDelete();">
  <%=ScreenHelper.setFormButtonsStop()%>
</table>

<div id="divMessage" name="divMessage"></div>

<%-- link to synchronise labels with ini --%>
<%=ScreenHelper.alignButtonsStart()%>
    <img src="<c:url value="/_img/themes/default/pijl.gif"/>">
    <a href="<c:url value='/main.do?Page=system/syncLabelsWithIni.jsp?ts='/><%=getTs()%>" onMouseOver="window.status='';return true;"><%=getTran("Web.manage","synchronizelabelswithini",sWebLanguage)%></a>&nbsp;
<%=ScreenHelper.alignButtonsStop()%>

<%-- SCRIPTS ------------------------------------------------------------------------------------%>
<script>
 transactionForm.FindLabelType.focus();

  <%-- CLEAR EDIT FIELDS --%>
  function clearEditFields(){
    transactionForm.EditLabelType.value = "";
    transactionForm.EditLabelID.value = "";

    transactionForm.EditShowLink.selectedIndex = 0;

    <%
	    tokenizer = new StringTokenizer(supportedLanguages,",");
	    while(tokenizer.hasMoreTokens()){
	        tmpLang = tokenizer.nextToken();
	        out.print("textCounter(transactionForm.EditLabelValue"+tmpLang.toUpperCase()+",transactionForm.remLen,250);");
	    }
    %>
    transactionForm.EditLabelType.focus();
    transactionForm.SaveButton.disabled = true;
  }

  <%-- CHECK SAVE --%>
  function checkSave(sAction){
    if(formComplete()){
      var url = "<%=sCONTEXTPATH%>/system/manageTranslationsStore.jsp?ts="+new Date();
      var pb = 'Action='+sAction+
               '&EditLabelID='+transactionForm.EditLabelID.value+
	           '&EditLabelType='+transactionForm.EditLabelType.value+
	           '&EditOldLabelID='+transactionForm.EditOldLabelID.value+
	           '&EditOldLabelType='+transactionForm.EditOldLabelType.value;
	  <%
	      tokenizer = new StringTokenizer(supportedLanguages,",");
	      while(tokenizer.hasMoreTokens()){
	          tmpLang = tokenizer.nextToken();
	          out.print("pb+= '&EditLabelValue"+tmpLang.toUpperCase()+"='+encodeURIComponent(transactionForm.EditLabelValue"+tmpLang.toUpperCase()+".value);");
	      }
	  %>
	  new Ajax.Request(url,{
        method: "POST",
        postBody: pb,
        onSuccess: function(resp){
          $('divMessage').innerHTML = resp.responseText;
          $('EditOldLabelType').value = $('EditLabelType').value;
          $('EditOldLabelID').value = $('EditLabelID').value;
          updateTypeSelectAndSearch();
        },
        onFailure: function(){
          $('divMessage').innerHTML = "Error in function manageTranslationsStore() => AJAX";
        }
      });
    }
  }

  <%-- ASK DELETE --%>
  function askDelete(){
    if(formComplete()){
      if(yesnoDialog("Web","areYouSureToDeleteLabelForAllLanguages")){
        var url = "<%=sCONTEXTPATH%>/system/manageTranslationsStore.jsp?ts="+new Date();
        new Ajax.Request(url,{
          method: "POST",
          postBody: 'Action=Delete'+
                    '&EditLabelID='+$('EditLabelID').value+
                    '&EditLabelType='+$('EditLabelType').value,
          onSuccess: function(resp){
            $('divMessage').innerHTML = resp.responseText;
            doNew();
            updateTypeSelect();
            clearSearchResults();
          },
          onFailure: function(){
            $('divMessage').innerHTML = "Error in function askDelete() => AJAX";
          }
        });
      }
    }
  }
  
  <%-- CLEAR SEARCH RESULTS --%>
  function clearSearchResults(){
    document.getElementById("divFindRecords").innerHTML = "";  
  }
  
  <%-- UPDATE TYPE SELECT AND SEARCH --%>
  function updateTypeSelectAndSearch(){
    var url = "<%=sCONTEXTPATH%>/system/ajax/manageTranslationsGetTypeSelect.jsp?ts="+new Date().getTime();
    new Ajax.Request(url,{
      onSuccess: function(resp){
        document.getElementById("FindLabelTypeDiv").innerHTML = resp.responseText.trim();     
        
        transactionForm.FindLabelType.value = transactionForm.EditLabelType.value;
        transactionForm.FindLabelID.value = transactionForm.EditLabelID.value;    
        doFind();
      }
    });
  }
  
  <%-- UPDATE TYPE SELECT --%>
  function updateTypeSelect(){
    var url = "<%=sCONTEXTPATH%>/system/ajax/manageTranslationsGetTypeSelect.jsp?ts="+new Date().getTime();
    new Ajax.Request(url,{
      onSuccess: function(resp){
        document.getElementById("FindLabelTypeDiv").innerHTML = resp.responseText.trim();
      }
    });
  }

  <%-- FORM COMPLETE --%>
  function formComplete(){
    if(transactionForm.EditLabelType.value=="" || transactionForm.EditLabelID.value==""){
      alertDialog("web","somefieldsareempty");
      
      if(transactionForm.EditLabelType.value.length==0){
        transactionForm.EditLabelType.focus();
      }
      else if(transactionForm.EditLabelID.value.length==0){
        transactionForm.EditLabelID.focus();
      }

      return false;
    }

    return true;
  }
</script>

<%-- hidden fields --%>
<input type="hidden" name="EditOldLabelType" value="<%=editLabelType%>">
<input type="hidden" name="EditOldLabelID" value="<%=editLabelID%>">
<input type="hidden" name="Action">

  <%
      // alert message
      if(labelAllreadyExists || invalidCharFound){
          %><script>alertDialogDirectText("<%=msg%>");</script><%
      }
  %>
</form>