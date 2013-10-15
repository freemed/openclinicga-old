<%@page import="be.openclinic.hr.Contract,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSSORTTABLE%>

<body style="padding:5px;">
<%
    String sPersonId = checkString(request.getParameter("PersonId"));
    
    String sFunction = checkString(request.getParameter("doFunction"));
        
    String sReturnFieldContractUid = checkString(request.getParameter("ReturnFieldContractUid")),
    	   sReturnFieldContractId  = checkString(request.getParameter("ReturnFieldContractId"));

    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n**************** searchContract.jsp ****************");
        Debug.println("sPersonId               : "+sPersonId);
        Debug.println("sFunction               : "+sFunction);
        Debug.println("sReturnFieldContractUid : "+sReturnFieldContractUid);
        Debug.println("sReturnFieldContractId  : "+sReturnFieldContractId+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////
    
    String msg = "";
  
    out.println(writeTableHeader("web","contracts",sWebLanguage,""));
   
    List foundContracts = Contract.getContractsForPerson(Integer.parseInt(sPersonId));
    if(foundContracts.size() > 0){
        %>
            <br>
            
            <table id="searchresults" cellpadding="0" cellspacing="0" width="100%" class="sortable" style="border:1px solid #ccc;">
                <%-- header --%>
                <tr class="admin">
                    <td class="admin" style="padding-left:0;" width="13%" nowrap><%=getTran("web.hr","contractId",sWebLanguage)%></td>
                    <td class="admin" style="padding-left:0;" width="13%" nowrap><%=getTran("web.hr","beginDate",sWebLanguage)%></td>
                    <td class="admin" style="padding-left:0;" width="13%" nowrap><%=getTran("web.hr","endDate",sWebLanguage)%></td>
                    <td class="admin" style="padding-left:0;" width="20%" nowrap><%=getTran("web.hr","functionCode",sWebLanguage)%></td>
                    <td class="admin" style="padding-left:0;" width="*" nowrap><%=getTran("web.hr","functionTitle",sWebLanguage)%></td>
                </tr>
                
                <tbody>
                    <%
                        String sClass = "";
                        Contract contract;
                        
                        for(int i=0; i<foundContracts.size(); i++){
                            contract = (Contract)foundContracts.get(i);
                            
                            // alternate row-style
                            if(sClass.length()==0) sClass = "1";
                            else                   sClass = "";
                            
                            %>
                                <tr class="list<%=sClass%>" onmouseover="this.style.cursor='hand';" onmouseout="this.style.cursor='default';" onClick="selectContract('<%=contract.getUid()%>','<%=contract.objectId%>');">
                                    <td><%=contract.objectId%></td>
                                    <td><%=(contract.beginDate!=null?ScreenHelper.stdDateFormat.format(contract.beginDate):"")%></td>
                                    <td><%=(contract.endDate!=null?ScreenHelper.stdDateFormat.format(contract.endDate):"")%></td>
                                    <td><%=getTranNoLink("hr.contract.functioncode",checkString(contract.functionCode),sWebLanguage)%></td>
                                    <td><%=checkString(contract.functionTitle)%></td>
                                </tr>
                            <%
                        }
                    %>
                </tbody>
            </table>
        <%
    }
	
    // number of found records
    if(foundContracts.size() > 0){
        %><%=foundContracts.size()%> <%=getTran("web","recordsFound",sWebLanguage)%><%
    }
    else{
        %><br><%=getTran("web","noRecordsFound",sWebLanguage)%><%
    }

    // display message
    if(msg.length() > 0){
        %><br><%=msg%><br><%
    }
%>
    
<%-- CLOSE BUTTON --%>
<div style="text-align:center;padding-top:10px;">
    <input type="button" class="button" name="closeButton" value="<%=getTranNoLink("web","close",sWebLanguage)%>" onclick="window.close();">
</div>

<script>
  window.resizeTo(700,350);

  <%-- SELECT CONTRACT --%>
  function selectContract(uid,id){	  
    if("<%=sReturnFieldContractUid%>".length > 0){
      window.opener.document.getElementsByName("<%=sReturnFieldContractUid%>")[0].value = uid;
    }
    if("<%=sReturnFieldContractId%>".length > 0){
      window.opener.document.getElementsByName("<%=sReturnFieldContractId%>")[0].value = id;
    }
    
    <%
	    if(sFunction.length() > 0){
	        out.print("window.opener."+sFunction+";");
	    }
	%>

    window.close();
  }
  
  window.setTimeout("this.focus();",200); // bring to front
</script>
</body>