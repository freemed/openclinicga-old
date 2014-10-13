<%@page import="be.openclinic.assets.Supplier,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="../../assets/includes/commonFunctions.jsp"%>
<%=sJSSORTTABLE%>

<body style="padding:5px;">
<%
    String sSupplierUid = checkString(request.getParameter("SupplierUid"));
    
    String sFunction = checkString(request.getParameter("doFunction"));
        
    // return fields
    String sReturnFieldUid  = checkString(request.getParameter("ReturnFieldUid")),
           sReturnFieldName = checkString(request.getParameter("ReturnFieldName"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n******************* _common/search/searchSupplier.jsp *****************");
        Debug.println("sSupplierUid     : "+sSupplierUid);
        Debug.println("sFunction        : "+sFunction);
        Debug.println("sReturnFieldUid  : "+sReturnFieldUid);
        Debug.println("sReturnFieldName : "+sReturnFieldName+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
        
    // inner search
    String sAction = checkString(request.getParameter("Action"));
    sAction = "search"; // display all records by default
    
    String sCode      = checkString(request.getParameter("searchCode")),
           sName      = checkString(request.getParameter("searchName")),
           sVatNumber = checkString(request.getParameter("searchVatNumber"));

    ///////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n********** innerSearch **********");
        Debug.println("sAction    : "+sAction);
        Debug.println("sCode      : "+sCode);
        Debug.println("sName      : "+sName);
        Debug.println("sVatNumber : "+sVatNumber+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////
   
    boolean showAllSuppliersOnEmptySearch = true;
    String msg = "";
     
    // search fields 
    %>
        <form name="SearchForm" id="SearchForm" method="POST">
            <%=writeTableHeader("web","searchSuppliers",sWebLanguage," window.close();")%>
            <input type="hidden" name="Action" value="search">
                    
            <table class="list" border="0" width="100%" cellspacing="1">
                <%-- search CODE --%>
                <tr>
                    <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","code",sWebLanguage)%></td>
                    <td class="admin2">
                        <input type="text" class="text" id="searchCode" name="searchCode" size="20" maxLength="50" value="<%=sCode%>">
                    </td>
                </tr>   
                
                <%-- search NAME --%>                
                <tr>
                    <td class="admin"><%=getTran("web","name",sWebLanguage)%></td>
                    <td class="admin2">
                        <input type="text" class="text" id="searchName" name="searchName" size="20" maxLength="50" value="<%=sName%>">
                    </td>
                </tr>
                
                <%-- search VAT NUMBER --%>
                <tr>
                    <td class="admin"><%=getTran("web","vatNumber",sWebLanguage)%></td>
                    <td class="admin2">
                        <input type="text" class="text" id="searchVatNumber" name="searchVatNumber" size="20" maxLength="50" value="<%=sVatNumber%>">
                    </td>
                </tr>     
                            
                <%-- search BUTTONS --%>
                <tr>     
                    <td class="admin"/>
                    <td class="admin2" colspan="2">
                        <input class="button" type="button" name="buttonSearch" id="buttonSearch" value="<%=getTranNoLink("web","search",sWebLanguage)%>" onclick="searchSuppliers();">&nbsp;
                        <input class="button" type="button" name="buttonClear" id="buttonClear" value="<%=getTranNoLink("web","clear",sWebLanguage)%>" onclick="clearSearchFields();">&nbsp;
                    </td>
                </tr>
            </table>
        </form>
    <%
    
    List<Supplier> foundSuppliers = new LinkedList(); 
    
    if(sAction.equals("search")){
	    if(sCode.length() > 0 || sName.length() > 0 || sVatNumber.length() > 0 || showAllSuppliersOnEmptySearch){
	        Supplier findItem = new Supplier();
	        findItem.code = sCode;
	        findItem.name = sName;
	        findItem.vatNumber = sVatNumber;
	        
	        foundSuppliers = Supplier.getList(findItem);
	        if(foundSuppliers.size() > 0){
	            %>	                
	                <table id="searchresults" cellpadding="0" cellspacing="0" width="100%" class="sortable">
	                    <%-- header --%>
	                    <tr class="admin">
	                        <td class="admin" style="padding-left:0;" width="20%" nowrap><%=getTran("web","code",sWebLanguage)%></td>
	                        <td class="admin" style="padding-left:0;" width="50%" nowrap><asc><%=getTran("web","name",sWebLanguage)%></asc></td>
	                        <td class="admin" style="padding-left:0;" width="30%" nowrap><%=getTran("web","vatNumber",sWebLanguage)%></td>
	                    </tr>
	                    
	                    <tbody>
	                        <%
	                            String sClass = "1";
	                            Supplier supplier;
	                            
	                            for(int i=0; i<foundSuppliers.size(); i++){
	                                supplier = (Supplier)foundSuppliers.get(i);
	                                
	                                // alternate row-style
	                                if(sClass.length()==0) sClass = "1";
	                                else                   sClass = "";
	                                
	                                %>
	                                    <tr class="list<%=sClass%>" onmouseover="this.style.cursor='hand';" onmouseout="this.style.cursor='default';" onClick="selectSupplier('<%=supplier.getUid()%>','<%=supplier.name%>');">
	                                        <td><%=checkString(supplier.code)%></td>
	                                        <td><%=checkString(supplier.name).replaceAll("\r\n","<br>")%></td>
	                                        <td><%=checkString(supplier.vatNumber)%></td>
	                                    </tr>
	                                <%
	                            }
	                        %>
	                    </tbody>
	                </table>
	            <%
	        }
	    }
	    
	    // number of found records
	    if(foundSuppliers.size() > 0){
	        %><%=foundSuppliers.size()%> <%=getTran("web","recordsFound",sWebLanguage)%><%
	    }
	    else{
	        %><%=getTran("web","noRecordsFound",sWebLanguage)%><%
	    }
    }
    
    // display message
    if(msg.length() > 0){
        %><%=msg%><br><%
    }
%>
    
<%-- CLOSE BUTTON --%>
<div style="text-align:center;padding-top:10px;">
    <input type="button" class="button" name="closeButton" value="<%=getTranNoLink("web","close",sWebLanguage)%>" onclick="window.close();">
</div>

<script>
  window.resizeTo(700,500);

  <%-- CLEAR SEARCH FIELDS --%>
  function clearSearchFields(){
    document.getElementById("searchCode").value = "";
    document.getElementById("searchName").value = "";
    document.getElementById("searchVatNumber").value = "";
    
    document.getElementById("searchCode").focus();
  }
  
  <%-- SEARCH SUPPLIERS --%>
  function searchSuppliers(){
    var okToSubmit = true;
    
    if(document.getElementById("searchCode").value.length > 0 ||
       document.getElementById("searchName").value.length > 0 ||
       document.getElementById("searchVatNumber").value.length > 0){
      okToSubmit = true;
    }
  
    if(okToSubmit==true){
      document.getElementById("buttonSearch").disabled = true;
      document.getElementById("buttonClear").disabled = true;
      SearchForm.submit();
    }
  }
  
  <%-- SELECT SUPPLIER --%>
  function selectSupplier(uid,name){      
    if("<%=sReturnFieldUid%>".length > 0){
      window.opener.document.getElementsByName("<%=sReturnFieldUid%>")[0].value = uid;
    }
    if("<%=sReturnFieldName%>".length > 0){
      window.opener.document.getElementsByName("<%=sReturnFieldName%>")[0].value = name;
    }
    
    <%
        if(sFunction.length() > 0){
            out.print("window.opener."+sFunction+";");
        }
    %>

    window.close();
  }
  
  document.getElementById("searchCode").focus();
</script>
</body>