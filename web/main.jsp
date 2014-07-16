<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	// prevent caching
    response.setHeader("Content-Type", "text/html; charset=ISO-8859-1");
    response.setHeader("Expires", "Sat, 6 May 1995 12:00:00 GMT");
    response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
    response.addHeader("Cache-Control", "post-check=0, pre-check=0");
    response.setHeader("Pragma", "no-cache");
    
    // WorkTime-message
    String sWorkTimeMessage = "";
    boolean alertWorkTimeMsg = false;

    // only show message on server
    if(MedwanQuery.getInstance().getConfigString("masterEnabled").equals("1")){
        // get message from DB
        if(checkString((String) session.getAttribute("WorkTimeMessage")).length() == 0){
            sWorkTimeMessage = getTranDb("WorkTime", "WorkTimeMessage", sWebLanguage);

            // add WorkTimeMessage to session
            if(sWorkTimeMessage.length() > 0 && !sWorkTimeMessage.equalsIgnoreCase("WorkTimeMessage")){
                alertWorkTimeMsg = true;
                session.setAttribute("WorkTimeMessage", sWorkTimeMessage);
            } 
            else {
                session.removeAttribute("WorkTimeMessage");
            }
        }
        else {
            // get message from session
            sWorkTimeMessage = checkString((String) session.getAttribute("WorkTimeMessage"));
        }
    }
%>
<html>
<head>
    <%=sCSSNORMAL%>
    <%=sCSSMODALBOX%>
    <%//=sCSSOPERA%>
    <%=sJSTOGGLE%>
    <%=sJSFORM%>
    <%=sJSPOPUPMENU%>
    <%=sJSPROTOTYPE%>
    <%=sJSSCRPTACULOUS%>
    <%=sJSMODALBOX%>
    <%=sIcon%>
</head>

<%@include file="/includes/messageChecker.jsp"%>

<body id="body" onresize="pageResize();">
<%
    if(request.getParameter("exitmessage") != null){
        if(request.getParameter("exitmessage").startsWith("printlabels")){
            int serverid = Integer.parseInt(request.getParameter("exitmessage").split("\\.")[1]);
            int transactionId = Integer.parseInt(request.getParameter("exitmessage").split("\\.")[2]);
			
			%><script>window.open("<c:url value='/healthrecord/createLabSampleLabelPdf.jsp'/>?serverid=<%=serverid%>&transactionid=<%=transactionId%>&ts=<%=getTs()%>", "Popup"+new Date().getTime(), "toolbar=no, status=yes, scrollbars=yes, resizable=yes, width=400, height=300, menubar=no").moveTo((screen.width - 400) / 2, (screen.height - 300) / 2);</script><%
        }
    }
%>

<table width="100%" border="0" cellspacing="0" cellpadding="0"  id="holder">
    <tr>
        <td colspan="2" style="vertical-align:top;" id="header"><%ScreenHelper.setIncludePage("/_common/header.jsp", pageContext);%></td>
    </tr>
    <% if(!"datacenter".equalsIgnoreCase((String)session.getAttribute("edition"))){ %>
    <tr class="menu_navigation">
        <td align="left" id="menu">
            <%ScreenHelper.setIncludePage("/_common/navigation.jsp", pageContext);%>
        </td>
          <td align="right" >
        <%ScreenHelper.setIncludePage("/_common/iconsRight.jsp", pageContext);%>
        </td>
    </tr>
    <% }%>
    <%-- INCLUDE PAGE --%>
    <tr>
        <td colspan="2" height="100%" style="vertical-align:top;" class="white">
            <div class="content" id="Juist" height="100%"><a name="topp">&nbsp;</a>
                <table width="100%" border="0" id="mijn">
                    <tr>
                        <td style="vertical-align:top;" class="white">
                            <%
                                String sPage = checkString(request.getParameter("Page"));

                                if(sPage.length() > 0 && !sPage.equalsIgnoreCase("null")){
                                    ScreenHelper.setIncludePage(customerInclude("/"+sPage), pageContext);
                                } 
                                else{
                                    ScreenHelper.setIncludePage("/_common/start.jsp", pageContext);
                                }
                            %>
                        </td>
                    </tr>
                </table>
            </div>
        </td>
    </tr>
</table>
<script>
  var dateFormat = "<%=ScreenHelper.stdDateFormat.toPattern()%>";
  var ie = document.all;
  var ns6 = document.getElementById && !document.all;
  
  function hasScrollbar(){
    return (document.getElementById("Juist").scrollHeight > document.getElementById("Juist").clientHeight);
  }

  function pageResize(){
    if(ie){
      var rcts = document.getElementById("Juist").getClientRects();
      var headerH = rcts[0].top;
      document.getElementById("Juist").style.height = document.body.clientHeight - headerH;
      if(hasScrollbar()){
        document.getElementById("holder").style.width = document.body.clientWidth - 1;
        document.getElementById("Juist").style.width = document.body.clientWidth - 2;
        document.getElementById("mijn").style.width = document.getElementById("Juist").offsetWidth - 17;
      }
      else{
        document.getElementById("holder").style.width = document.body.clientWidth - 1;
        document.getElementById("Juist").style.width = document.body.clientWidth - 2;
        document.getElementById("mijn").style.width = document.getElementById("Juist").offsetWidth;
      }
    }
    else{
      var divHeight = document.getElementById("body").offsetHeight - (document.getElementById("menu").offsetHeight+document.getElementById("header").offsetHeight+5);
      document.getElementById("Juist").style.height = divHeight+"px";
    }
    resizeSearchFields();
  }
  
  <%
      // do not resize textarea's in pages below : 
      if(!sPage.endsWith("medIntProctologyProtocol.jsp")){
          %>
			  Event.observe(window,'load',function(){
			    resizeAllTextareas(10);
			    changeInputColor();
			    pageResize();
			  });
	    <%
      }
  %>

  function checkDropdown(evt){
    if(!dropDownChecked){
      if(window.myButton){
        if(ns6){
          lastEvent = evt;
          if(lastEvent.target.id.indexOf("menu") > -1 || lastEvent.target.id.indexOf("ddIcon") > -1){
            if(!bSaveHasNotChanged){
              dropDownChecked = true;
              if(checkSaveButton()){
                lastEvent.target.click();
              }
            }
          }
        }
        else{
          lastEvent = window.event;
          if(lastEvent.srcElement.id.indexOf("menu") > -1 || lastEvent.srcElement.id.indexOf("ddIcon") > -1){
            if(!bSaveHasNotChanged){
              dropDownChecked = true;
              if(checkSaveButton()){
                lastEvent.srcElement.click();
              }
            }
          }
        }
      }
    }
    else{
      if(ns6){
        lastEvent = evt;
        lastEvent.target.click;
      }
      else{
        lastEvent = window.event;
        lastEvent.srcElement.click();
      }
    }
  }
  
<%
    if(alertWorkTimeMsg){
		%>
		  var popupUrl = "<c:url value="/_common/search/workTimePopup.jsp"/>?ts=<%=getTs()%>&labelValue=<%=getTranNoLink("Web.Occup","medwan.common.workuntil",sWebLanguage)%> <%=sWorkTimeMessage%>";
		  var modalities = "dialogWidth:400px;dialogHeight:150px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
		  (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("Web.Occup","medwan.common.workuntil",sWebLanguage)%>");
		<%
    }

    String msg = checkString(request.getParameter("msg"));
    if(msg.length() > 0){
		%>
		  var popupUrla = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&tts=<%=getTs()%>&labelValue=<%=msg%>";
		  var modalitiesa = "dialogWidth:400px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
		  (window.showModalDialog)?window.showModalDialog(popupUrla,"",modalitiesa):window.confirm("<%=msg%>");
		<%
    }
%>
</script>
</body>
</html>
