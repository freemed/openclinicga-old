<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@page import="be.openclinic.system.Screen"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%!
	//--- GET LABELS HTML -------------------------------------------------------------------------
	private String getLabelsHtml(Screen screen){
	    String sHtml = "<table width='300'>";
	    
		// supported languages
		String supportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages");
		if(supportedLanguages.length()==0) supportedLanguages = "nl,fr";
		supportedLanguages = supportedLanguages.toLowerCase();
		
		// print language selector
		StringTokenizer tokenizer = new StringTokenizer(supportedLanguages,",");
		String tmpLang, sValue = "";
		
		while(tokenizer.hasMoreTokens()){
	    	tmpLang = tokenizer.nextToken().toUpperCase();
	     
	    	if(!screen.getExamId().equals("-1")){
	    	    sValue = getTranNoLink("examination",screen.getExamId(),tmpLang);
	    	}
	    	
	        sHtml+= "<tr>"+
	                 "<td width='20'>"+tmpLang+"</td>"+
	                 "<td>"+
	                  "<input type='text' class='admin' size='40' maxLength='100' name='ScreenLabel_"+tmpLang+"' value='"+sValue+"'/>"+
	                 "</td>"+
	                "</tr>";
	    }
	    
		sHtml+= "</table>";
		
	    return sHtml;
	}
%>

<%
    String sScreenUID = checkString(request.getParameter("ScreenUID"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n############## system/ajax/screenDesigner/fetchScreen.jsp ##############");
        Debug.println("sScreenUID : "+sScreenUID+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    Screen screen;
    
    if(sScreenUID.equals("new")){
        screen = new Screen();	
		screen.setUpdateUser(activeUser.userid);
    }
    else{
        screen = Screen.get(sScreenUID);	
    }
    
    // store in session
    session.setAttribute("screen",screen);	
    
    if(screen.getXmlData()!=null){
        Debug.println("\fetched : n"+screen.getXmlData().asXML()+"\n"); ///////////////
    }

    if(Debug.enabled){
	    Debug.println("width : "+screen.widthInCells);
	    Debug.println("height : "+screen.heightInRows);
	    Debug.println("labels : "+getLabelsHtml(screen)); ////////
	    Debug.println("transactionType : "+screen.getTransactionType());
	    Debug.println("examId : "+screen.getExamId());
    }
%>

{
  "width":"<%=screen.widthInCells%>",
  "height":"<%=screen.heightInRows%>",
  "labelsHtml":"<%=HTMLEntities.htmlentities(getLabelsHtml(screen))%>",
  "transactionType":"<%=HTMLEntities.htmlentities(screen.getTransactionType())%>",
  <%
      if(!sScreenUID.equals("new")){
          %>"updateTime":"<%=ScreenHelper.fullDateFormat.format(screen.getUpdateDateTime())%>",<%
      }
      else{
          %>"updateTime":"",<%
      }
  %>
  "examId":"<%=screen.getExamId()%>"
}