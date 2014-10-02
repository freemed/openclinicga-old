<%@page import="org.dom4j.DocumentException,
                java.util.Vector"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSSORTTABLE%>

<%!
    //--- GET SERVICE IDS FROM XML ----------------------------------------------------------------
    private Vector getServiceIdsFromXML(HttpServletRequest request) throws Exception {
        Vector ids = new Vector();
        Document document;

        SAXReader xmlReader = new SAXReader();
        String sXmlFile = MedwanQuery.getInstance().getConfigString("servicesXMLFile"), xmlFileUrl;

        if((sXmlFile!=null) && (sXmlFile.length() > 0)){
            // Check if xmlFile exists, else use file at templateSource location.
            try{
                xmlFileUrl = "http://"+request.getServerName()+request.getRequestURI().replaceAll(request.getServletPath(), "")+"/"+sAPPDIR+"/_common/xml/"+sXmlFile;
                document = xmlReader.read(new URL(xmlFileUrl));
                Debug.println("Using custom services file : "+xmlFileUrl);
            }
            catch(DocumentException e){
                xmlFileUrl = MedwanQuery.getInstance().getConfigString("templateSource")+"/"+sXmlFile;
                document = xmlReader.read(new URL(xmlFileUrl));
                Debug.println("Using default services file : "+xmlFileUrl);
            }

            if(document!=null){
                Element root = document.getRootElement();
                if(root!=null){
                    Iterator elements = root.elementIterator("ServiceId");

                    while(elements.hasNext()){
                        ids.add(((Element)elements.next()).attributeValue("value"));
                    }
                }
            }
        }

        return ids;
    }
%>

<%
    String sFindLastname   = checkString(request.getParameter("FindLastname")),
           sFindFirstname  = checkString(request.getParameter("FindFirstname")),
           sReturnPersonID = checkString(request.getParameter("ReturnPersonID")),
           sReturnUserID   = checkString(request.getParameter("ReturnUserID")),
           sReturnName     = checkString(request.getParameter("ReturnName")),
           sSetGreenField  = checkString(request.getParameter("SetGreenField"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n#################### _common/search/searchUser.jsp ####################");
    	Debug.println("sFindLastname   : "+sFindLastname);
    	Debug.println("sFindFirstname  : "+sFindFirstname);
    	Debug.println("sReturnPersonID : "+sReturnPersonID);
    	Debug.println("sReturnUserID   : "+sReturnUserID);
    	Debug.println("sReturnName     : "+sReturnName);
    	Debug.println("sSetGreenField  : "+sSetGreenField+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    Vector xmlServiceIds = getServiceIdsFromXML(request);
%>
<form name="SearchForm" method="POST" onkeydown="if(enterEvent(event,13)){doFind();};">
    <table width="100%" cellspacing="0" cellpadding="0" class="menu">
        <tr height="25">
            <%-- lastname --%>
            <td class="admin2"><%=getTran("Web","name",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" name="FindLastname" size="28" maxLength="255" value="<%=sFindLastname%>" >
            </td>
            
            <%-- firstname --%>
            <td class="admin2"><%=getTran("Web","firstname",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" name="FindFirstname" size="28" maxLength="255" value="<%=sFindFirstname%>">
            </td>
            
            <%-- BUTTONS --%>
            <td class="admin2" style="text-align:right;">
                <input class="button" type="button" name="searchButton" value="<%=getTranNoLink("Web","find",sWebLanguage)%>" onClick="doFind();">
                <input class="button" type="button" name="clearButton" value="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="clearSearchFields();">&nbsp;
            </td>
        </tr>
        
        <%-- SEARCH RESULTS --%>
        <tr>
            <td style="vertical-align:top;" colspan="5" class="white" width="100%">
                <div id="divFindRecords"></div>
            </td>
        </tr>
    </table>
    <br>
    
    <%-- CLOSE BUTTON --%>
    <center>
        <input type="button" class="button" name="closeButton" value='<%=getTranNoLink("Web","Close",sWebLanguage)%>' onclick='window.close()'>
    </center>
    
    <%-- hidden fields --%>
    <input type="hidden" name="ReturnPersonID" value="<%=sReturnPersonID%>">
    <input type="hidden" name="ReturnUserID" value="<%=sReturnUserID%>">
    <input type="hidden" name="ReturnName" value="<%=sReturnName%>">
    <input type="hidden" name="SetGreenField" value="<%=sSetGreenField%>">
    <input type="hidden" name="displayImmatNew" value="<%=checkString(request.getParameter("displayImmatNew"))%>">
    <input type="hidden" name="displayImmatNew2" value="">
</form>

<script>
  window.resizeTo(600,480);
  SearchForm.FindLastname.focus();

  <%-- CLEAR SEARCH FIELDS --%>
  function clearSearchFields(){
    SearchForm.FindLastname.value = "";
    SearchForm.FindFirstname.value = "";
    SearchForm.FindLastname.focus();
  }

  <%-- DO FIND --%>
  function doFind(){
    ajaxChangeSearchResults('_common/search/searchByAjax/searchUserShow.jsp', SearchForm);
  }

  <%-- SET PERSON --%>
  function setPerson(sPersonID, sUserID, sName){
    if('<%=sReturnPersonID%>'.length > 0){
      window.opener.document.getElementsByName('<%=sReturnPersonID%>')[0].value = sPersonID;
      if(window.opener.document.getElementsByName('<%=sReturnPersonID%>')[0].onchange!=null){
        window.opener.document.getElementsByName('<%=sReturnPersonID%>')[0].onchange();
      }
    }

    if('<%=sReturnUserID%>'.length > 0){
      if(window.opener.document.getElementsByName('<%=sReturnUserID%>').length>0){
	    window.opener.document.getElementsByName('<%=sReturnUserID%>')[0].value = sUserID;
	    if(window.opener.document.getElementsByName('<%=sReturnUserID%>')[0].onchange!=null){
	      window.opener.document.getElementsByName('<%=sReturnUserID%>')[0].onchange();
	    }
      }
      else{
        window.opener.document.getElementById('<%=sReturnUserID%>').value = sUserID;
        if(window.opener.document.getElementById('<%=sReturnUserID%>').onchange!=null){
          window.opener.document.getElementById('<%=sReturnUserID%>').onchange();
        }
   	  }
    }

    if('<%=sReturnName%>'.length > 0){
      if(window.opener.document.getElementsByName('<%=sReturnName%>').length>0){
	    window.opener.document.getElementsByName('<%=sReturnName%>')[0].value = sName;
	    if(window.opener.document.getElementsByName('<%=sReturnName%>')[0].onchange!=null){
	      window.opener.document.getElementsByName('<%=sReturnName%>')[0].onchange();
	    }
      }
      else{
	    window.opener.document.getElementById('<%=sReturnName%>').value = sName;
	    if(window.opener.document.getElementById('<%=sReturnName%>').onchange!=null){
	      window.opener.document.getElementById('<%=sReturnName%>').onchange();
	    }
      }
    }

    if('<%=sSetGreenField%>'.length > 0){
      window.opener.document.getElementsByName('<%=sReturnName%>')[0].className = 'green';
    }
    if(window.opener.document.getElementsByName('<%=sReturnUserID%>').length>0){
      if(window.opener.document.getElementsByName('<%=sReturnUserID%>')[0]!=null){
        if(window.opener.document.getElementsByName('<%=sReturnUserID%>')[0].onchange!=null){
          window.opener.document.getElementsByName('<%=sReturnUserID%>')[0].onchange();
        }
      }
    }
    else{
	  if(window.opener.document.getElementById('<%=sReturnUserID%>')!=null){
        if(window.opener.document.getElementById('<%=sReturnUserID%>').onchange!=null){
          window.opener.document.getElementById('<%=sReturnUserID%>').onchange();
        }
      }
	}
    window.close();
  }

  <%-- popup : search service --%>
  function searchService(serviceUidField, serviceNameField){
    openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode="+serviceUidField+"&VarText="+serviceNameField);
  }

  <%-- activate tab --%>
  function activateTab(sTab){
    <% 
      // hide all TRs
      for(int i=0; i<xmlServiceIds.size(); i++){
        %>
          document.getElementById('tr_tab<%=i%>').style.display = 'none';
          document.getElementById('td<%=i%>').className = "tabunselected";

          if(sTab=='tab_<%=xmlServiceIds.get(i)%>'){
            document.getElementById('tr_tab<%=i%>').style.display = '';
            document.getElementById('td<%=i%>').className = "tabselected";
          }
        <%
      }
    %>

    <%-- varia tab --%>
    document.getElementById('tr_tabvaria').style.display = 'none';
    document.getElementById('td<%=xmlServiceIds.size()%>').className = "tabunselected";

    if(sTab=='tab_varia'){
      document.getElementById('tr_tabvaria').style.display = '';
      document.getElementById('td<%=xmlServiceIds.size()%>').className = "tabselected";
    }
  }
  
  doFind();
</script>