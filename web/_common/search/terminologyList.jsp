<%@page import="be.openclinic.medical.Terminology"%>
<%@page import="java.util.Vector"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sAction = checkString(request.getParameter("Action"));

    String sVarText = checkString(request.getParameter("VarText"));

    String sEditBlockStatus = checkString(request.getParameter("EditBlockStatus"));
    if(sEditBlockStatus.length()==0){
        sEditBlockStatus = "none";
    }

    String sEditTerminologyUid    = checkString(request.getParameter("EditTerminologyUid")),
           sEditTerminologyType   = checkString(request.getParameter("EditTerminologyType")),
           sEditTerminologyPhrase = checkString(request.getParameter("EditTerminologyPhrase"));

    String sFindTerminologyType   = checkString(request.getParameter("FindTerminologyType")),
           sFindTerminologyPhrase = checkString(request.getParameter("FindTerminologyPhrase"));
    
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n****************** common/search/terminologyList.jsp *******************");
        Debug.println("sAction : "+sAction);
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
        boolean bExists = Terminology.exists(sEditTerminologyType,activeUser.userid);
        if(bExists && sEditTerminologyUid.length() == 0){
            sMessage = "<font color='red'>"+getTran("web","exists",sWebLanguage)+"</font>";
        }
        else{
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
            sMessage = "<font color='green'>"+getTran("web","saved",sWebLanguage)+"</font>";
            sEditTerminologyUid = tObj.getUid();
        }
    }
    //*** DELETE **************************************************************
    else if(sAction.equals("delete")){
        Terminology tObj = Terminology.get(sEditTerminologyUid);
        tObj.delete();
        sEditTerminologyUid = "";
    }
    
    if(sEditTerminologyUid.length() > 0){
        Terminology tObj = Terminology.get(sEditTerminologyUid);
        sEditTerminologyType = tObj.getTerminologyType();
        sEditTerminologyPhrase = tObj.getPhrase();
    }
%>

<%=writeTableHeader("terminology","manage_terminology",sWebLanguage,"")%>

<%-- EDIT TABLE ---------------------------------------------------------------------------------%>
<div id="EditBlock">
    <table width="100%" cellspacing="1" cellpadding="0">
        <form name="EditTerminologyForm" method="post">
            <%-- TYPE --%>
            <tr>
                <td class="admin" width="60"><%=getTran("terminology","type",sWebLanguage)%></td>
                <td class="admin2">
                    <input class="text" type="text" name="EditTerminologyType" value="<%=sEditTerminologyType%>" size="<%=sTextWidth%>"/>
                </td>
            </tr>
            
            <%-- PHRASE --%>
            <tr>
                <td class="admin"><%=getTran("terminology","phrase",sWebLanguage)%></td>
                <td class="admin2">
                    <textarea class="text" name="EditTerminologyPhrase" cols="<%=sTextareaCols%>"rows="<%=sTextAreaRows%>"><%=sEditTerminologyPhrase%></textarea>
                </td>
            </tr>
            
            <%-- BUTTONS --%>
            <tr>
                <td class="admin"/>
                <td class="admin2">
                    <input class="button" type="button" name="buttonsave" value="<%=getTranNoLink("web","save",sWebLanguage)%>" onclick="doSave();">&nbsp;
                    <input class="button" type="button" name="buttonclear" value="<%=getTranNoLink("web","clear",sWebLanguage)%>" onclick="clearEditFields();">&nbsp;
                    <%=sMessage%>
                </td>
            </tr>
            
            <input type="hidden" name="EditTerminologyUid" value="<%=sEditTerminologyUid%>"/>
            <input type="hidden" name="Action" value=""/>
            <input type="hidden" name="EditBlockStatus" value="<%=sEditBlockStatus%>"/>
            <input type="hidden" name="VarText" value="<%=sVarText%>"/>
        </form>
        
        <tr>
            <td colspan="2">
                <br><%=writeTableHeader("web","search",sWebLanguage,"")%>
            </td>
        </tr>
    </table>
</div>

<%-- SEARCH FORM TABLE --------------------------------------------------------------------------%>
<table width="100%" cellspacing="1" cellpadding="0" class="list">
    <form name='SearchForm' method="POST" onSubmit="doFind();" onkeydown="if(enterEvent(event,13)){doFind();}">
        <tr>
            <td class="admin2" width="<%=sTDAdminWidth%>"><%=getTran("terminology","type",sWebLanguage)%></td>
            <td class="admin2"><input class="text" type="text" name="FindTerminologyType" value="<%=sFindTerminologyType%>" size="<%=sTextWidth%>"/></td>
        </tr>
        <tr>
            <td class="admin2"><%=getTran("terminology","phrase",sWebLanguage)%></td>
            <td class="admin2"><input class="text" type="text" name="FindTerminologyPhrase" value="<%=sFindTerminologyPhrase%>" size="<%=sTextWidth%>"/></td>
        </tr>
        <tr>
            <td class="admin2"/>
            <td class="admin2">
                <table width="100%" cellspacing="0" cellpadding="0">
                    <tr>
                        <td align="left">
                            <input class="button" type="button" name="buttonfind" value="<%=getTranNoLink("web","find",sWebLanguage)%>" onclick="doFind();">
                        </td>
                        <td align="right">
                            <input class="button" type="button" name="buttonnew" value="<%=getTranNoLink("terminology","open_new",sWebLanguage)%>" onclick="javascript:toggleLayer('EditBlock');" >
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        
        <input type="hidden" name="Action" value=""/>
        <input type="hidden" name="EditBlockStatus" value="<%=sEditBlockStatus%>"/>
        <input type="hidden" name="VarText" value="<%=sVarText%>"/>
    </form>
</table>
<br/>

<%-- SEARCH RESULTS TABLE --%>
<table>
    <tr>
        <td style="vertical-align:top;" colspan="3" align="center" class="white" width="100%">
            <div id="searchResultsDiv" class="search" style="width:400;border:1px solid #ccc;">
                <table border="0" width="100%" cellpadding="1" cellspacing="0">
                    <%
                        if(sFindTerminologyType.length() > 0 || sFindTerminologyPhrase.length() > 0){
                            Vector vTerminologies = Terminology.getTerminologies(sFindTerminologyType.toLowerCase(),sFindTerminologyPhrase.toLowerCase(), activeUser.userid);
                            Iterator termIter = vTerminologies.iterator();

                            Terminology tObj = new Terminology();
                            StringBuffer sbResults = new StringBuffer();
                            String sClass = "";
                            
                            while(termIter.hasNext()){
                            	// alternate row-style
                                if(sClass.equals("")) sClass = "1";
                                else                  sClass = "";
                                
                                tObj = (Terminology)termIter.next();
                                sbResults.append("<tr class='admin'>")
                                          .append("<td colspan='3'>"+tObj.getTerminologyType()+"</td>")
			                             .append("</tr>")
			                             .append("<tr class='list"+sClass+"' onmouseover='this.className=\"list_select\";' onmouseout='this.className=\"list"+sClass+"\";'>")
			                              .append("<td>")
			                               .append("<img src='"+request.getContextPath()+"/_img/icon_edit.gif'/ alt='"+getTranNoLink("web", "edit", sWebLanguage)+"' class='link' onclick=\"doEdit('"+tObj.getUid()+"')\">")
			                              .append("</td>")
			                              .append("<td width='100%' style=\"padding-left: 10px;\" ")
			                              .append(" onmouseover='this.style.cursor=\"hand\"' ")
			                              .append(" onmouseout='this.style.cursor=\"default\"' ")
			                              .append(" onclick=\"setTerminology('"+tObj.getPhrase()+"')\">")
			                               .append(tObj.getPhrase())
			                              .append("</td>")
			                              .append("<td>")
			                               .append("<img src='"+request.getContextPath()+"/_img/icon_delete.gif'/ alt='"+getTranNoLink("web", "delete", sWebLanguage)+"' class='link' onclick=\"doDelete('"+tObj.getUid()+"')\">")
			                              .append("</td>")
			                             .append("</tr>");
                            }

                            if(vTerminologies.size() > 0){
                                out.print(sbResults);
                            } 
                            else{
                                // display 'no results' message
                                %>
                                    <tr>
                                        <td colspan='3'><%=getTran("web","norecordsfound",sWebLanguage)%></td>
                                    </tr>
                                <%
                            }
                        }
                    %>
                </table>
            </div>
        </td>
    </tr>
</table>
<br>

<%-- CLOSE BUTTON --%>
<center>
    <input type="button" class="button" name="buttonclose" value='<%=getTran("Web","Close",sWebLanguage)%>' onclick='window.close()'>
</center>

<script>
EditTerminologyForm.EditTerminologyType.focus();

<%
    if(sAction.length()==0){
    	%>document.getElementById("searchResultsDiv").style.visibility = "hidden";<%
    }
    else{
    	%>document.getElementById("searchResultsDiv").style.visibility = "visible";<%
    }
%>

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
  if(EditTerminologyForm.EditTerminologyType.value != "" && EditTerminologyForm.EditTerminologyPhrase.value != ""){
    EditTerminologyForm.buttonsave.disabled = true;
    EditTerminologyForm.Action.value = "save";
    EditTerminologyForm.EditBlockStatus.value = "block";
    EditTerminologyForm.submit();
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

<%-- SET Terminology --%>
function setTerminology(sTerminoloyPhrase){
  window.opener.document.getElementsByName('<%=sVarText%>')[0].value = window.opener.document.getElementsByName('<%=sVarText%>')[0].value+sTerminoloyPhrase;
  window.close();
}

<%-- TOGGLE LAYER --%>
function toggleLayer(whichLayer){
  if(document.getElementById){
    var style2 = document.getElementById(whichLayer).style;
    if(style2.display == "block"){
      style2.display = "none";
      SearchForm.buttonnew.value="<%=getTranNoLink("terminology","open_new",sWebLanguage)%>";
      clearEditFields();
    }
    else{
      style2.display = "block";
      SearchForm.buttonnew.value="<%=getTranNoLink("terminology","close_new",sWebLanguage)%>";
    }
  }
}

function doEdit(id){
  EditTerminologyForm.EditTerminologyUid.value = id;
  EditTerminologyForm.EditBlockStatus.value = "block";
  EditTerminologyForm.submit();
}

function clearEditFields(){
  EditTerminologyForm.EditTerminologyType.value = "";
  EditTerminologyForm.EditTerminologyPhrase.value = "";
  EditTerminologyForm.EditTerminologyUid.value = "";
}

function doDelete(id){
  EditTerminologyForm.EditTerminologyUid.value = id;
  EditTerminologyForm.Action.value = "delete";
  EditTerminologyForm.submit();
}
</script>