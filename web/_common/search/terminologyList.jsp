<%@page import="be.openclinic.medical.Terminology"%>
<%@page import="java.util.Vector"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSSCRIPTS%>

<%
    String sAction = checkString(request.getParameter("Action"));

    String sReturnField = checkString(request.getParameter("ReturnField"));
    String sTerminologyType = checkString(request.getParameter("TerminologyType"));

    String sEditBlockStatus = checkString(request.getParameter("EditBlockStatus"));
    if(sEditBlockStatus.length()==0){
        sEditBlockStatus = "none";
    }

    String sEditTerminologyUid    = checkString(request.getParameter("EditTerminologyUid")),
           sEditTerminologyType   = checkString(request.getParameter("EditTerminologyType")),
           sEditTerminologyPhrase = checkString(request.getParameter("EditTerminologyPhrase"));

    String sFindTerminologyType   = checkString(request.getParameter("FindTerminologyType")),
           sFindTerminologyPhrase = checkString(request.getParameter("FindTerminologyPhrase"));
    
    if(sAction.length()==0){
    	sFindTerminologyType = sTerminologyType;
    }
    else if(!sAction.equals("find")){
    	sFindTerminologyType = sEditTerminologyType;
    }
    
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n****************** common/search/terminologyList.jsp *******************");
        Debug.println("sAction          : "+sAction);
        Debug.println("sReturnField     : "+sReturnField);
        Debug.println("sTerminologyType : "+sTerminologyType);
        Debug.println("sEditTerminologyUid    : "+sEditTerminologyUid);
        Debug.println("sEditTerminologyType   : "+sEditTerminologyType);
        Debug.println("sEditTerminologyPhrase : "+sEditTerminologyPhrase);
        Debug.println("sFindTerminologyType   : "+sFindTerminologyType);
        Debug.println("sFindTerminologyPhrase : "+sFindTerminologyPhrase+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    String sMessage = "";

    //*** SAVE ****************************************************************
    if(sAction.equals("save")){
            Terminology tObj = new Terminology();
            if(sEditTerminologyUid.length() > 0 ){
                tObj = Terminology.get(sEditTerminologyUid);
            }
            else{
                tObj.setCreateDateTime(getSQLTime());
            }
            
            tObj.setTerminologyType(sEditTerminologyType.toLowerCase());
            tObj.setUserUID(activeUser.userid);
            tObj.setPhrase(sEditTerminologyPhrase.replaceAll("\"","&quot;").replaceAll("'","&#146;"));
            tObj.setUpdateDateTime(getSQLTime());
            tObj.setUpdateUser(activeUser.userid);

            tObj.store();
            sMessage = "<font color='green'>"+getTran("web","dataIsSaved",sWebLanguage)+"</font>";
            sEditTerminologyUid = tObj.getUid();
    }
    //*** DELETE **************************************************************
    else if(sAction.equals("delete")){
        Terminology tObj = Terminology.get(sEditTerminologyUid);
        sFindTerminologyType = tObj.getTerminologyType();
        tObj.delete();
        sEditTerminologyUid = "";
    }
    
    if(sEditTerminologyUid.length() > 0){
        Terminology tObj = Terminology.get(sEditTerminologyUid);
        sEditTerminologyType = tObj.getTerminologyType();
        sEditTerminologyPhrase = tObj.getPhrase();
    }
%>

<%-- SEARCH FORM TABLE --------------------------------------------------------------------------%>
<form name='SearchForm' method="POST" onSubmit="doFind();" onkeydown="if(enterEvent(event,13)){doFind();}">
    <%=writeTableHeader("terminology","manage_terminology",sWebLanguage," window.close();")%>
    <table width="100%" cellspacing="1" cellpadding="0" class="list">    
        <%-- TYPE --%>
        <tr>
            <td class="admin2" width="100"><%=getTran("terminology","type",sWebLanguage)%></td>
            <td class="admin2"><input class="text" type="text" name="FindTerminologyType" value="<%=sFindTerminologyType%>" size="<%=sTextWidth%>" readonly/></td>
        </tr>
        
        <%-- PHRASE --%>
        <tr>
            <td class="admin2"><%=getTran("terminology","phrase",sWebLanguage)%></td>
            <td class="admin2"><input class="text" type="text" name="FindTerminologyPhrase" value="<%=sFindTerminologyPhrase%>" size="<%=sTextWidth%>"/></td>
        </tr>
        
        <%-- BUTTONS --%>
        <tr>
            <td class="admin2"/>
            <td class="admin2">
                <table width="100%" cellspacing="0" cellpadding="0">
                    <tr>
                        <td align="left">
                            <input class="button" type="button" name="buttonfind" value="<%=getTranNoLink("web","find",sWebLanguage)%>" onclick="doFind();">
                            <input class="button" type="button" name="buttonclearsearch" value="<%=getTranNoLink("web","clear",sWebLanguage)%>" onclick="clearSearchFields();">&nbsp;&nbsp;
	                        <input class="button" type="button" name="buttonnew" value="<%=getTranNoLink("terminology","open_new",sWebLanguage)%>" onclick="openNew();">
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        
        <input type="hidden" name="Action" value=""/>
        <input type="hidden" name="EditBlockStatus" value="<%=sEditBlockStatus%>"/>
        <input type="hidden" name="ReturnField" value="<%=sReturnField%>"/>
    </table>
</form>

<%-- EDIT TABLE ---------------------------------------------------------------------------------%>
<form name="EditForm" id="EditBlock" method="post">			        
	<input type="hidden" name="EditTerminologyUid" value="<%=sEditTerminologyUid%>"/>
	<input type="hidden" name="EditTerminologyType" value="<%=sEditTerminologyType%>"/>
			    
	<input type="hidden" name="Action" value=""/>
	<input type="hidden" name="EditBlockStatus" value="<%=sEditBlockStatus%>"/>
	<input type="hidden" name="ReturnField" value="<%=sReturnField%>"/>
		        
<%
    if(!sAction.equals("save")){
        %>
		    <%=writeTableHeader("web","edit",sWebLanguage)%>
			<table width="100%" cellspacing="1" cellpadding="0" class="list">
		        
		        <%-- PHRASE --%>
		        <tr>
		            <td class="admin"><%=getTran("terminology","phrase",sWebLanguage)%></td>
		            <td class="admin2">
		                <textarea class="text" name="EditTerminologyPhrase" style="width:310px;" rows="<%=sTextAreaRows%>"><%=sEditTerminologyPhrase%></textarea>
		            </td>
		        </tr>
		        
		        <%-- BUTTONS --%>
		        <tr>
		            <td class="admin"/>
		            <td class="admin2">
		                <input class="button" type="button" name="buttonsave" value="<%=getTranNoLink("web","save",sWebLanguage)%>" onclick="doSave();">&nbsp;
		                <input class="button" type="button" name="buttonclearedit" value="<%=getTranNoLink("web","clear",sWebLanguage)%>" onclick="clearEditFields();">&nbsp;
		                <%=sMessage%>
		            </td>
		        </tr>
		    </table>
		<%
    }
%>
</form>

<%-- SEARCH TABLE --%>
<div id="SearchBlock" style="display:block">
<%
    if(sFindTerminologyType.length() > 0 || sFindTerminologyPhrase.length() > 0){
        Vector vTerminologies = Terminology.getTerminologies(sFindTerminologyType.toLowerCase(),sFindTerminologyPhrase.toLowerCase(),activeUser.userid);

        if(vTerminologies.size() > 0){
            %>
				<table width="100%" cellspacing="1" cellpadding="0" class="list">
				    <tr>
				        <td>
			                <table border="0" width="100%" cellpadding="1" cellspacing="0">
            <%

            Iterator termIter = vTerminologies.iterator();
            Terminology tObj = new Terminology();
            StringBuffer sbResults = new StringBuffer();
            String sClass = "";
         
            int idx= 0;
            while(termIter.hasNext()){
                // alternate row-style
                if(sClass.equals("")) sClass = "1";
                else                  sClass = "";
             
                tObj = (Terminology)termIter.next();
                
                // header
                if(idx==0){
                    sbResults.append("<tr class='admin'>")
                              .append("<td colspan='3'>"+tObj.getTerminologyType()+"</td>")
	                         .append("</tr>");
                }
                
                sbResults.append("<tr class='list"+sClass+"' onmouseover='this.className=\"list_select\";' onmouseout='this.className=\"list"+sClass+"\";'>")
		                  .append("<td>")
		                   .append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_delete.gif'/ alt='"+getTranNoLink("web","delete",sWebLanguage)+"' class='link' onclick=\"doDelete('"+tObj.getUid()+"');\">")
		                   .append("<img src='"+sCONTEXTPATH+"/_img/icons/icon_edit.gif'/ alt='"+getTranNoLink("web","edit",sWebLanguage)+"' class='link' onclick=\"doEdit('"+tObj.getUid()+"');\">")
		                  .append("</td>")
		                  .append("<td width='100%' style=\"padding-left:10px;\" class='hand' onclick=\"setTerminology('"+tObj.getPhrase()+"')\">")
		                   .append(tObj.getPhrase())
		                  .append("</td>")
		                 .append("</tr>");
                idx++;
            }

            out.print(sbResults);
            
            %>
		                    </table>
		                </td>
			        </tr>
				</table>
				<br>
            <%                        
        } 
        else{
            %><%=getTran("web","norecordsFound",sWebLanguage)%><%
        }
    }
%>
</div>

<%-- CLOSE BUTTON --%>
<center>
    <input type="button" class="button" name="buttonclose" value='<%=getTranNoLink("web","close",sWebLanguage)%>' onclick='window.close()'>
</center>

<script>
SearchForm.FindTerminologyPhrase.focus();

var style2 = document.getElementById('EditBlock').style;
style2.display = style2.display?"":"<%=sEditBlockStatus%>";

if(style2.display=="block"){
  SearchForm.buttonnew.value = "<%=getTranNoLink("terminology","close_new",sWebLanguage)%>";
}
else if(style2.display=="none"){
  SearchForm.buttonnew.value = "<%=getTranNoLink("terminology","open_new",sWebLanguage)%>";
}

<%-- DO SAVE --%>
function doSave(){
  if(EditForm.EditTerminologyPhrase.value != ""){
    EditForm.buttonsave.disabled = true;
    EditForm.Action.value = "save";
    EditForm.EditBlockStatus.value = "block";
    EditForm.submit();
  }
  else{
    EditForm.EditTerminologyPhrase.focus();
	alertDialog("web.manage","dataMissing");
  }
}

<%-- DO FIND --%>
function doFind(){
  if(SearchForm.FindTerminologyType.value != "" || SearchForm.FindTerminologyPhrase.value != ""){
    SearchForm.buttonfind.disabled = true;
    SearchForm.Action.value = "find";
    SearchForm.EditBlockStatus.value = "none";
    SearchForm.submit();
  }
}

<%-- SET TERMINOLOGY --%>
function setTerminology(sTerminoloyPhrase){
  var returnField = window.opener.document.getElementById('<%=sReturnField%>');
  if(returnField.value.length > 0) returnField.value+= "\r\n";
  returnField.value+= sTerminoloyPhrase;
  if(returnField.type=="textarea"){
    resizeTextarea(returnField,10);
    limitChars(returnField,255);
  }
  window.close();
}

<%-- TOGGLE LAYER --%>
function toggleLayer(whichLayer){
  var layerStyle = document.getElementById(whichLayer).style;
  if(layerStyle.display=="block"){
	layerStyle.display = "none";
    SearchForm.buttonnew.value = "<%=getTranNoLink("terminology","open_new",sWebLanguage)%>";
  }
  else{
	layerStyle.display = "block";
         if(whichLayer=="EditBlock") clearEditFields();
    else if(whichLayer=="SearchBlock") clearSearchFields();
    SearchForm.buttonnew.value = "<%=getTranNoLink("terminology","close_new",sWebLanguage)%>";
  }
}

<%-- HIDE LAYER --%>
function hideLayer(whichLayer){
  document.getElementById(whichLayer).style.display = "none";
  SearchForm.buttonnew.value = "<%=getTranNoLink("terminology","open_new",sWebLanguage)%>"; 
}

<%-- OPEN NEW --%>
function openNew(){
  if(document.getElementById("EditBlock").style.display=="none"){
    document.getElementById("SearchBlock").style.display = "none";
    document.getElementById("EditBlock").style.display = "block";
    clearEditFields();
    
    EditForm.EditTerminologyType.value = SearchForm.FindTerminologyType.value;
    EditForm.EditTerminologyPhrase.value = SearchForm.FindTerminologyPhrase.value;
    
    SearchForm.buttonnew.value = "<%=getTranNoLink("terminology","close_new",sWebLanguage)%>";
  }
  else{
	document.getElementById("EditBlock").style.display = "none";
    SearchForm.buttonnew.value = "<%=getTranNoLink("terminology","open_new",sWebLanguage)%>";
  }
}

<%-- CLEAR EDIT FIELDS --%>
function clearEditFields(){
  //EditForm.EditTerminologyType.value = "";
  EditForm.EditTerminologyPhrase.value = "";
  EditForm.EditTerminologyUid.value = "";
  
  EditForm.EditTerminologyPhrase.focus();
}

<%-- CLEAR SEARCH FIELDS --%>
function clearSearchFields(){
  //SearchForm.FindTerminologyType.value = "";
  SearchForm.FindTerminologyPhrase.value = "";
  
  SearchForm.FindTerminologyPhrase.focus();
  hideLayer('EditBlock');
  hideLayer('SearchBlock');
}

function doEdit(id){
  EditForm.EditTerminologyUid.value = id;
  EditForm.EditBlockStatus.value = "block";
  EditForm.submit();
}

function doDelete(id){
  if(yesnoDialog("Web","areYouSureToDelete")){
    EditForm.EditTerminologyUid.value = id;
    EditForm.Action.value = "delete";
    EditForm.submit();
  }
}
</script>