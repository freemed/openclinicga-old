<%@page import="be.openclinic.medical.UserDiagnosis,
                java.util.Vector" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("diagnoses.manageuserdiagnoses","all",activeUser)%>
<%=sJSSORTTABLE%>

<%
    String sAction = checkString(request.getParameter("Action"));

    String sDiagnosisCode           = checkString(request.getParameter("EditDiagnosisCode")),
           sDiagnosisCodeType       = checkString(request.getParameter("EditDiagnosisCodeType")),
           sDeleteDiagnosisCode     = checkString(request.getParameter("DeleteDiagnosisCode")),
           sDeleteDiagnosisCodeType = checkString(request.getParameter("DeleteDiagnosisCodeType"));
   
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n******************* medical/manageUserDiagnoses.jsp *******************");
    	Debug.println("sAction                  : "+sAction);
    	Debug.println("sDiagnosisCode           : "+sDiagnosisCode);
    	Debug.println("sDiagnosisCodeType       : "+sDiagnosisCodeType);
    	Debug.println("sDeleteDiagnosisCode     : "+sDeleteDiagnosisCode);
    	Debug.println("sDeleteDiagnosisCodeType : "+sDeleteDiagnosisCodeType+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////    
    
    String sMessage = "";

    if(sAction.equals("ADD")){
        UserDiagnosis.insertUserDiagnosis(activeUser.userid,sDiagnosisCode,sDiagnosisCodeType);
    }
    else if(sAction.equals("DELETE")){        
        UserDiagnosis.deleteUserDiagnosis(activeUser.userid,sDeleteDiagnosisCode,sDeleteDiagnosisCodeType);
        sMessage = getTran("medical.diagnosis","delete_mycode",sWebLanguage);
    }

    Vector vUserDiagnoses = UserDiagnosis.selectUserDiagnoses(activeUser.userid,"","","");
    Iterator iter = vUserDiagnoses.iterator();

    StringBuffer sbResults = new StringBuffer();
    UserDiagnosis uTmp;
    String sCode, sCodeType;
    String sClass = "1";

    while(iter.hasNext()){
        uTmp = (UserDiagnosis)iter.next();
        
        // alternate row-style
        if(sClass.equals("")) sClass = "1";
        else                  sClass = "";
        
        sCode = checkString(uTmp.getCode());
        sCodeType = checkString(uTmp.getCodeType());
        
        sbResults.append("<tr class='list"+sClass+"'>")
                  .append("<td><img src='"+sCONTEXTPATH+"/_img/icons/icon_delete.gif' class='link' alt='"+getTranNoLink("Web","delete",sWebLanguage)+"' onclick=\"doDelete('"+sCode+"','"+sCodeType+"');\"></td>")
                  .append("<td>"+sCode+"</td>")
                  .append("<td>"+MedwanQuery.getInstance().getCodeTran(sCodeType+"code"+sCode,sWebLanguage)+"</td>")
                 .append("</tr>");
    }
%>
<form name="DeleteDiagnosisForm" method="post" action="<c:url value='/main.do'/>?Page=medical/manageUserDiagnoses.jsp&ts=<%=getTs()%>">
    <%=writeTableHeader("Web.manage","manageUserDiagnoses",sWebLanguage,"")%>
    
    <table class='sortable' width='100%' cellspacing="0" cellpadding="0" id="searchresults">
        <%-- header --%>
        <tr>
            <td class="admin" width="20">&nbsp;</td>
            <td class="admin" width="100"><%=getTran("web","code",sWebLanguage)%></td>
            <td class="admin" width="900"><%=getTran("web.manage","diagnosis",sWebLanguage)%></td>
        </tr>
        <%=sbResults%>
        <%
            if(sbResults.length()==0){
	            %><tr><td colspan="2"><%=getTran("web","norecordsfound",sWebLanguage)%></td></tr><%
            }
        %>
    </table>
    
    <input type='hidden' name='DeleteDiagnosisCode'>
    <input type='hidden' name='DeleteDiagnosisCodeType'>
    <input type='hidden' name='Action'>
</form>

<form name="EditDiagnosisForm" method="POST" action="<c:url value='/main.do'/>?Page=medical/manageUserDiagnoses.jsp&ts=<%=getTs()%>">
    <table class='list' width='100%' cellspacing="1">
        <tr class="admin">
            <td colspan='2'>&nbsp;&nbsp;<%=getTran("web.manage","adduserdiagnoses",sWebLanguage)%></td>
        </tr>
        <tr>
            <td class='admin' width='<%=sTDAdminWidth%>'>
                <%=getTran("medical.diagnosis","diagnosiscode",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="hidden" name="EditDiagnosisCode" id="EditDiagnosisCode" value="">
                <input type="hidden" name="EditDiagnosisCodeType" id="EditDiagnosisCodeType" value="">
                <input class="text" type="text" name="EditDiagnosisCodeLabel" id="EditDiagnosisCodeLabel" value="" readonly size="<%=sTextWidth%>">
                
                <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchICPC('EditDiagnosisCode','EditDiagnosisCodeLabel','EditDiagnosisCodeType');">
                <img src="<c:url value="/_img/icons/icon_add.gif"/>" class="link" alt="<%=getTranNoLink("Web","add",sWebLanguage)%>" onclick="doAdd();">
            </td>
        </tr>
    </table>
    
    <input type='hidden' name='Action'>
</form>
&nbsp;<%=sMessage%>

<script>
  function searchICPC(code,codelabel,codetype){
    openPopup("/_common/search/searchICPC.jsp&ts=<%=getTs()%>&enableICD10=true&returnField="+code+"&returnField2="+codelabel+"&returnField3="+codetype+"&ListChoice=FALSE&ListMode=ALL");
  }

  function doDelete(code,codetype){
    DeleteDiagnosisForm.DeleteDiagnosisCode.value = code;
    DeleteDiagnosisForm.DeleteDiagnosisCodeType.value = codetype;
    DeleteDiagnosisForm.Action.value = "DELETE";
    DeleteDiagnosisForm.submit();
  }

  function doAdd(){
    if(EditDiagnosisForm.EditDiagnosisCode.value!=""){
      EditDiagnosisForm.Action.value = "ADD";
      EditDiagnosisForm.submit();
    }
  }

  function doBack(){
    <%
        if(activePatient != null){
            %>window.location.href="<c:url value='/main.do'/>?Page=curative/index.jsp&ts=<%=getTs()%>";<%
        }
        else{
        	%>window.location.href="<c:url value='/main.do'/>?Page=medical/index.jsp&ts=<%=getTs()%>";<%
        }
    %>
  }
</script>