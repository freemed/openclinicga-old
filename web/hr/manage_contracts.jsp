<%@page import="be.openclinic.hr.Contract,
               java.text.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="../hr/includes/commonFunctions.jsp"%>
<%=checkPermission("hr.contract.edit","edit",activeUser)%>

<%=sJSPROTOTYPE%>
<%=sJSNUMBER%> 
<%=sJSSTRINGFUNCTIONS%>
<%=sJSSORTTABLE%>

<%
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n************************ hr/manage_contract.jsp ***********************");
        Debug.println("no parameters\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
%>            

<%=writeTableHeader("web","contracts",sWebLanguage,"")%><br>

<div id="divContracts" class="searchResults" style="width:100%;height:160px;"></div>

<form name="EditForm" id="EditForm" method="POST">
    <input type="hidden" id="EditContractUid" name="EditContractUid" value="-1">
                
    <table class="list" border="0" width="100%" cellspacing="1">            
        <%-- contractId (read-only) --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web.hr","contractId",sWebLanguage)%></td>
            <td class="admin2">
                <div id="contractId"><%=getTran("web.hr","newContract",sWebLanguage)%></div>                              
            </td>                        
        </tr>   
               
        <%-- beginDate --%>
        <tr>
            <td class="admin"><%=getTran("web.hr","beginDate",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2" nowrap>
                <%=writeDateField("beginDate","EditForm","",sWebLanguage)%>          
            </td>                        
        </tr>
        
        <%-- endDate --%>
        <tr>
            <td class="admin"><%=getTran("web.hr","endDate",sWebLanguage)%></td>
            <td class="admin2" nowrap>
                <%=writeDateField("endDate","EditForm","",sWebLanguage)%>          
            </td>                        
        </tr>
        
        <%-- functionCode --%>
        <tr>
            <td class="admin"><%=getTran("web.hr","functionCode",sWebLanguage)%></td>
            <td class="admin2">
                <select class="text" id="functionCode" name="functionCode">
                    <option/>
                    <%=ScreenHelper.writeSelect("hr.contract.functioncode","",sWebLanguage)%>
                </select>
            </td>
        </tr>
        
        <%-- functionTitle --%>
        <tr>
            <td class="admin"><%=getTran("web.hr","functionTitle",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="functionTitle" name="functionTitle" size="80" maxLength="255" value="">
            </td>
        </tr>
                                
        <%-- functionDescription --%>
        <tr>
            <td class="admin"><%=getTran("web.hr","functionDescription",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2">
                <textarea class="text" name="functionDescription" id="functionDescription" cols="80" rows="4" onKeyup="resizeTextarea(this,8);"></textarea>
            </td>
        </tr>
            
        <%-- LEGAL REFERENCE CODES (dynamic) --%>
        <%            
            for(int i=1; i<=5; i++){ 
                if(MedwanQuery.getInstance().getConfigString("enableLegalReferenceCode"+i).equals("1")){
                    %>                    
                        <tr>
                            <td class="admin"><%=getTran("web.hr","legalReferenceCode",sWebLanguage)%> <%=i%></td>
                            <td class="admin2">
                                <input type="text" class="text" id="ref<%=i%>" name="ref<%=i%>" size="30" maxLength="50" value="">
                            </td>
                        </tr>
                    <%
                }
               }
        %>            
            
        <%-- BUTTONS --%>
        <tr>     
            <td class="admin"/>
            <td class="admin2" colspan="2">
                <input class="button" type="button" name="buttonSave" id="buttonSave" value="<%=getTranNoLink("web","save",sWebLanguage)%>" onclick="saveContract();">&nbsp;
                <input class="button" type="button" name="buttonDelete" id="buttonDelete" value="<%=getTranNoLink("web","delete",sWebLanguage)%>" onclick="deleteContract();" style="visibility:hidden;">&nbsp;
                <input class="button" type="button" name="buttonNew" id="buttonNew" value="<%=getTranNoLink("web","new",sWebLanguage)%>" onclick="newContract();" style="visibility:hidden;">&nbsp;
            </td>
        </tr>
    </table>
    <i><%=getTran("web","colored_fields_are_obligate",sWebLanguage)%></i>
    
    <div id="divMessage" style="padding-top:10px;"></div>
</form>
    
<script>
  <%-- SAVE CONTRACT --%>
  function saveContract(){
    var okToSubmit = true;
    if(document.getElementById("beginDate").value.length > 8 &&
       document.getElementById("functionTitle").value.length > 0 &&
       document.getElementById("functionDescription").value.length > 0
      ){  
      <%-- beginDate can not be after endDate --%>
      if(document.getElementById("endDate").value.length > 0){
        var beginDate = makeDate(document.getElementById("beginDate").value);
        var endDate = makeDate(document.getElementById("endDate").value);
        
        if(beginDate > endDate){
          okToSubmit = false;
          alertDialog("web","beginMustComeBeforeEnd");
          document.getElementById("beginDate").focus();
        }  
      }
             
      if(okToSubmit){
        document.getElementById("divMessage").innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br>Saving";  
        var url = "<c:url value='/hr/ajax/contract/saveContract.jsp'/>?ts="+new Date().getTime();

        document.getElementById("buttonSave").disabled = true;
        document.getElementById("buttonDelete").disabled = true;
        document.getElementById("buttonNew").disabled = true;
        
        var sParameters = "EditContractUid="+EditForm.EditContractUid.value+
                          "&PersonId=<%=activePatient.personid%>"+
                          "&beginDate="+document.getElementById("beginDate").value+
                          "&endDate="+document.getElementById("endDate").value+
                          "&functionCode="+document.getElementById("functionCode").value+
                          "&functionTitle="+document.getElementById("functionTitle").value+
                          "&functionDescription="+document.getElementById("functionDescription").value+
                          (document.getElementById("ref1")==null?"":"&ref1="+document.getElementById("ref1").value)+
                          (document.getElementById("ref2")==null?"":"&ref2="+document.getElementById("ref2").value)+
                          (document.getElementById("ref3")==null?"":"&ref3="+document.getElementById("ref3").value)+
                          (document.getElementById("ref4")==null?"":"&ref4="+document.getElementById("ref4").value)+
                          (document.getElementById("ref5")==null?"":"&ref5="+document.getElementById("ref5").value);       
                          
        new Ajax.Request(url,{
          method: "POST",
          postBody: sParameters,                          
          onSuccess: function(resp){
            var data = eval("("+resp.responseText+")");
            $("divMessage").innerHTML = data.message;

            loadContracts();
            newContract();
              
            //EditForm.EditContractUid.value = data.newUid;                  
            document.getElementById("buttonSave").disabled = false;
            document.getElementById("buttonDelete").disabled = false;
            document.getElementById("buttonNew").disabled = false;
          },
          onFailure: function(resp){
            $("divMessage").innerHTML = "Error in 'hr/ajax/contract/saveContract.jsp' : "+resp.responseText.trim();
          }
        });
      }
    }
    else{
                alertDialog("web.manage","dataMissing");
        
      <%-- focus empty field --%>
           if(document.getElementById("beginDate").value.length==0) document.getElementById("beginDate").focus();
      else if(document.getElementById("functionTitle").value.length==0) document.getElementById("functionTitle").focus();
      else if(document.getElementById("functionDescription").value.length==0) document.getElementById("functionDescription").focus();          
    }
  }
    
  <%-- LOAD CONTRACTS --%>
  function loadContracts(){
    document.getElementById("divContracts").innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br>Loading..";            
    var url = "<c:url value='/hr/ajax/contract/getContracts.jsp'/>?ts="+new Date().getTime();
    new Ajax.Request(url,{
      method: "GET",
      parameters: "PatientId=<%=activePatient.personid%>",
      onSuccess: function(resp){
        $("divContracts").innerHTML = resp.responseText;
        setTimeout("sortables_init()",500);
      },
      onFailure: function(resp){
        $("divMessage").innerHTML = "Error in 'hr/ajax/contract/getContracts.jsp' : "+resp.responseText.trim();
      }
    });
  }

  <%-- DISPLAY CONTRACT --%>
  function displayContract(contractUid){          
    var url = "<c:url value='/hr/ajax/contract/getContract.jsp'/>?ts="+new Date().getTime();
    
    new Ajax.Request(url,{
      method: "GET",
      parameters: "ContractUid="+contractUid,
      onSuccess: function(resp){
        var data = eval("("+resp.responseText+")");

        $("EditContractUid").value = contractUid;
        $("contractId").innerHTML = data.contractId;
        $("beginDate").value = data.beginDate;
        $("endDate").value = data.endDate;
        $("functionCode").value = data.functionCode.unhtmlEntities();
        $("functionTitle").value = data.functionTitle.unhtmlEntities();
        $("functionDescription").value = replaceAll(data.functionDescription.unhtmlEntities(),"<br>","\n");

        if($("ref1")!=null) $("ref1").value = data.ref1.unhtmlEntities();
        if($("ref2")!=null) $("ref2").value = data.ref2.unhtmlEntities();
        if($("ref3")!=null) $("ref3").value = data.ref3.unhtmlEntities();
        if($("ref4")!=null) $("ref4").value = data.ref4.unhtmlEntities();
        if($("ref5")!=null) $("ref5").value = data.ref5.unhtmlEntities();
          
        document.getElementById("divMessage").innerHTML = ""; 
        resizeTextarea($("functionDescription"),10);

        <%-- display hidden buttons --%>
        document.getElementById("buttonDelete").style.visibility = "visible";
        document.getElementById("buttonNew").style.visibility = "visible";
      },
      onFailure: function(resp){
        $("divMessage").innerHTML = "Error in 'hr/ajax/contract/getContract.jsp' : "+resp.responseText.trim();
      }
    });
  }
  
  <%-- DELETE CONTRACT --%>
  function deleteContract(){  
      if(yesnoDeleteDialog()){
      var url = "<c:url value='/hr/ajax/contract/deleteContract.jsp'/>?ts="+new Date().getTime();

      document.getElementById("buttonSave").disabled = true;
      document.getElementById("buttonDelete").disabled = true;
      document.getElementById("buttonNew").disabled = true;
    
      new Ajax.Request(url,{
    	method: "GET",
        parameters: "ContractUid="+document.getElementById("EditContractUid").value,
        onSuccess: function(resp){
          var data = eval("("+resp.responseText+")");
          $("divMessage").innerHTML = data.message;

          loadContracts();
          newContract();
          
          document.getElementById("buttonSave").disabled = false;
          if(document.getElementById("buttonDelete")!=null) document.getElementById("buttonDelete").disabled = false;
          if(document.getElementById("buttonNew")!=null) document.getElementById("buttonNew").disabled = false;
        },
        onFailure: function(resp){
          $("divMessage").innerHTML = "Error in 'hr/ajax/contract/deleteContract.jsp' : "+resp.responseText.trim();
        }  
      });
    }
  }
  
  <%-- NEW CONTRACT --%>
  function newContract(){                   
    <%-- hide irrelevant buttons --%>
    document.getElementById("buttonDelete").style.visibility = "hidden";
    document.getElementById("buttonNew").style.visibility = "hidden";

    $("EditContractUid").value = "-1";
    $("contractId").innerHTML = "<%=getTran("web.hr","newContract",sWebLanguage)%>";   
    $("beginDate").value = "";
    $("endDate").value = "";
    $("functionCode").value = "";
    $("functionTitle").value = "";
    $("functionDescription").value = "";
    
    if($("ref1")!=null) $("ref1").value = "";
    if($("ref2")!=null) $("ref2").value = "";
    if($("ref3")!=null) $("ref3").value = "";
    if($("ref4")!=null) $("ref4").value = "";
    if($("ref5")!=null) $("ref5").value = "";   
    
    $("beginDate").focus();
    resizeAllTextareas(8);
  }
     
  <%-- SEARCH FUNCTION CODE --%>
  function searchFunctionCode(functionCodeField){
    openPopup("/_common/search/searchFunction.jsp&ts=<%=getTs()%>&VarCode="+functionCodeField);
    document.getElementById(functionCodeField).focus();
  }
          
  EditForm.beginDate.focus();
  loadContracts();
  resizeAllTextareas(8);
</script>