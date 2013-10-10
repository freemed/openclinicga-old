<%@page import="java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="../../../assets/includes/commonFunctions.jsp"%>
<%=sJSSORTTABLE%>

<%!
    //--- GET CODES FROM LABELS -------------------------------------------------------------------
    private Vector getCodesFromLabels(String sSearchCode, String sSearchLabel, String sWebLanguage){
	    Vector codes = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSql = "SELECT OC_LABEL_ID, OC_LABEL_VALUE"+
                          " FROM OC_LABELS"+
                          "  WHERE OC_LABEL_TYPE = 'salaryCalculationCode'"+
                          "   AND OC_LABEL_LANGUAGE = ?";

            if(sSearchCode.length() > 0){
                sSql+= " AND OC_LABEL_ID LIKE ?";
            }
            if(sSearchLabel.length() > 0){
                sSql+= " AND OC_LABEL_VALUE LIKE ?";
            }
                          
            sSql+= " ORDER BY OC_LABEL_ID ASC";
            
            ps = oc_conn.prepareStatement(sSql);
            
            int psIdx = 1;
            ps.setString(psIdx++,sWebLanguage);

            if(sSearchCode.length() > 0){
                ps.setString(psIdx++,sSearchCode+"%");
            }
            if(sSearchLabel.length() > 0){
                ps.setString(psIdx++,sSearchLabel+"%");
            }
            
            // execute
            String[] code;
            rs = ps.executeQuery();            
            while(rs.next()){
            	code = new String[2];
            	code[0] = checkString(rs.getString("OC_LABEL_ID"));
            	code[1] = checkString(rs.getString("OC_LABEL_VALUE"));
            	
            	codes.add(code);
            }
        }
        catch(Exception e){
        	if(Debug.enabled) e.printStackTrace();
            Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                Debug.printProjectErr(se,Thread.currentThread().getStackTrace());
            }
        }
	    
	    return codes;
    }
%>

<body style="padding:5px;">
<%    
    String sFunction    = checkString(request.getParameter("doFunction"));

    String sReturnFieldCode  = checkString(request.getParameter("ReturnFieldCode")),
    	   sReturnFieldLabel = checkString(request.getParameter("ReturnFieldLabel"));

    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n************* searchCalculationCodes.jsp ***********");
        Debug.println("sFunction         : "+sFunction);
        Debug.println("sReturnFieldCode  : "+sReturnFieldCode);
        Debug.println("sReturnFieldLabel : "+sReturnFieldLabel+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////
        
    // inner search
    String sAction = checkString(request.getParameter("Action"));

    String sSearchCode  = ScreenHelper.checkString(request.getParameter("searchCode")),
           sSearchLabel = ScreenHelper.checkString(request.getParameter("searchLabel"));

    ///////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n********* innerSearch *********");
        Debug.println("sAction      : "+sAction);
        Debug.println("sSearchCode  : "+sSearchCode);
        Debug.println("sSearchLabel : "+sSearchLabel+"\n");
    }
    ///////////////////////////////////////////////////////
   
    boolean showAllRecordsOnEmptySearch = true;
    String msg = "";    
      
    // search fields 
    %>
        <form name="SearchForm" id="SearchForm" method="POST">          
            <%=writeTableHeader("web","searchCalculationCodes",sWebLanguage,"")%>
            <input type="hidden" name="Action" value="search">
                            
            <table class="list" border="0" width="100%" cellspacing="1">
                <%-- search CODE --%>
                <tr>
                    <td class="admin" width="120"><%=getTran("web","code",sWebLanguage)%>&nbsp;</td>
                    <td class="admin2">
                        <input type="text" class="text" id="searchCode" name="searchCode" size="20" maxLength="40" value="<%=sSearchCode%>">
                    </td>
                </tr>     
                
                <%-- search LABEL --%>
                <tr>
                    <td class="admin"><%=getTran("web","name",sWebLanguage)%>&nbsp;</td>
                    <td class="admin2">
                        <input type="text" class="text" id="searchLabel" name="searchLabel" size="40" maxLength="60" value="<%=sSearchLabel%>">
                    </td>
                </tr>     
                                    
                <%-- search BUTTONS --%>
                <tr>     
                    <td class="admin"/>
                    <td class="admin2" colspan="2">
                        <input class="button" type="button" name="buttonSearch" id="buttonSearch" value="<%=getTranNoLink("web","search",sWebLanguage)%>" onclick="searchCalculationCodes();">&nbsp;
                        <input class="button" type="button" name="buttonClear" id="buttonClear" value="<%=getTranNoLink("web","clear",sWebLanguage)%>" onclick="clearSearchFields();">&nbsp;
                    </td>
                </tr>
            </table>
        </form>
    <%
    
    //--- SEARCH ----------------------------------------------------------------------------------
    if(sAction.equals("search") || sAction.length()==0){
    	Vector foundCodes = new Vector();
    	
        if(sSearchCode.length() > 0 || sSearchLabel.length() > 0 || showAllRecordsOnEmptySearch){
            foundCodes = getCodesFromLabels(sSearchCode,sSearchLabel,sWebLanguage); // codes are labels
        	
            if(foundCodes.size() > 0){
                %>
                    <br>
                    
                    <table id="searchresults" cellpadding="0" cellspacing="0" width="100%" class="sortable" style="border:1px solid #ccc;">
                        <%-- header --%>
                        <tr class="admin">
                            <td class="admin" style="padding-left:0;" width="20%" nowrap><%=getTran("web","code",sWebLanguage)%></td>
                            <td class="admin" style="padding-left:0;" width="80%" nowrap><%=getTran("web","name",sWebLanguage)%></td>
                        </tr>
                        
                        <tbody>
                            <%
                                String sClass = "";
                                String code[];
                                
                                for(int i=0; i<foundCodes.size(); i++){
                                    code = (String[])foundCodes.get(i);
                                    
                                    // alternate row-style
                                    if(sClass.length()==0) sClass = "1";
                                    else                   sClass = "";
                                    
                                    %>
                                        <tr class="list<%=sClass%>" onmouseover="this.style.cursor='hand';" onmouseout="this.style.cursor='default';" onClick="selectCalculationCode('<%=code[0]%>','<%=code[1]%>');">
                                            <td><%=checkString(code[0])%></td>
                                            <td><%=checkString(code[1])%></td>
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
        if(foundCodes.size() > 0){
            %><%=foundCodes.size()%> <%=getTran("web","recordsFound",sWebLanguage)%><%
        }
        else{
            %><%=getTran("web","noRecordsFound",sWebLanguage)%><%
        }
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
  window.resizeTo(700,500);
  resizeAllTextareas(4);

  <%-- CLEAR SEARCH FIELDS --%>
  function clearSearchFields(){
    document.getElementById("searchCode").value = "";
    document.getElementById("searchLabel").value = "";
    
    document.getElementById("searchCode").focus();
  }
  
  <%-- SEARCH CALCULATION CODES --%>
  function searchCalculationCodes(){
    var okToSubmit = true;
    
    if(document.getElementById("searchCode").value.length > 0 ||
       document.getElementById("searchLabel").value.length > 0){
      okToSubmit = true;
    }
        
    if(okToSubmit==true){
      document.getElementById("buttonSearch").disabled = true;
      document.getElementById("buttonClear").disabled = true;
      SearchForm.submit();
    }
  }
  
  <%-- SELECT CALCULATION CODE --%>
  function selectCalculationCode(code,label){
    if("<%=sReturnFieldCode%>".length > 0){
        window.opener.document.getElementsByName("<%=sReturnFieldCode%>")[0].value = code;
      }
    if("<%=sReturnFieldLabel%>".length > 0){
        window.opener.document.getElementsByName("<%=sReturnFieldLabel%>")[0].value = code+" - "+label;
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