<%@page import="be.mxs.common.model.vo.healthrecord.util.TransactionFactoryGeneral"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String historyBack = checkString(request.getParameter("historyBack"));

    String sTranId   = checkString(request.getParameter("be.mxs.healthrecord.transaction_id")),
           sServerId = checkString(request.getParameter("be.mxs.healthrecord.server_id"));

    String sPersonId = checkString(request.getParameter("personId")),
           sTranType = checkString(request.getParameter("transactionType"));

    boolean noBackButton = checkString(request.getParameter("NoBackButton")).equalsIgnoreCase("true");    

    /// DEBUG //////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n************ healthrecord/viewTransaction.jsp **********");
        Debug.println("historyBack  : "+historyBack);
        Debug.println("sTranId      : "+sTranId);
        Debug.println("sServerId    : "+sServerId);
        Debug.println("sPersonId    : "+sPersonId);
        Debug.println("sTranType    : "+sTranType);
        Debug.println("noBackButton : "+noBackButton+"\n");
    }
    ////////////////////////////////////////////////////////////////////////////////

    session.setAttribute("openedTran_"+sServerId+"."+sTranId,"true");
    
    // store previous active tran in variable 
    SessionContainerWO sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
    TransactionVO currentTran = sessionContainerWO.getCurrentTransactionVO();

    TransactionVO showTransaction = null; 

    if(sServerId.length() > 0 && sTranId.length() > 0){
    	showTransaction = MedwanQuery.getInstance().loadTransaction(Integer.parseInt(sServerId),Integer.parseInt(sTranId));
    }
    else if(sPersonId.length() > 0 && sTranType.length() > 0){
    	showTransaction = MedwanQuery.getInstance().getLastTransactionByType(Integer.parseInt(sPersonId),sTranType);
    }
    
    TransactionFactoryGeneral factory = new TransactionFactoryGeneral();
    if(showTransaction!=null){
	    TransactionVO tempTran = factory.createTransactionVO(sessionContainerWO.getUserVO(),showTransaction.getTransactionType());
	    factory.populateTransaction(tempTran,showTransaction);

	    // set showtran as current tran
	    sessionContainerWO.setCurrentTransactionVO(tempTran);
    }
%>

<html>
<head>
    <%-- prevent caching --%>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1"/>
    <meta http-equiv="pragma" content="no-cache"/>
    <meta http-equiv="cache-control" content="no-cache"/>
    <meta http-equiv="Expires" content="-1"/>

    <%=sIcon%>
    <%=sJSTOGGLE%>
    <%=sJSPOPUPMENU%>
    <%=sCSSNORMAL%>
    <%=sJSDATE%>
    <%=sJSPROTOTYPE%>
    <%=sJSCHAR%>
</head>

<script>
  var sCONTEXTPATH = "<%=sCONTEXTPATH%>";
  var sHistoryUrl = "";
  var sGraphUrl = "";
  var contextMenuShown = false;

  var ie = document.all;
  var ns6 = document.getElementById && !document.all;

  window.document.title = "<%=getWindowTitle(request,sWebLanguage)%>";

  <%-- RESIZE ALL TEXTAREAS --%>
  function resizeAllTextareas(maxRows){
    var elems = document.getElementsByTagName("textarea");
    for(var i=0; i<elems.length; i++){
      resizeTextarea(elems[i],maxRows);
    }
  }

  <%-- RESIZE TEXTAREA --%>
  function resizeTextarea(ta,maxRows){
	if(ta.innerHTML.length > 0){
	  if(ta.style.visibility=="hidden"){
	    ta.style.visibility = "block";
	  }
	}

	var string = trim(ta.value);
	var lines = ta.value.split("\n");
	var counter = 0;

	for(var i=0; i<lines.length; i++){
	  if(lines[i].length >= ta.cols){
	    counter+= Math.ceil(lines[i].length/ta.cols);
	  }
	}
	counter+= lines.length;

	if(counter > ta.rows){
	  if(counter <= maxRows){
	    ta.rows = counter;
	  }
	  else{
	    ta.rows = maxRows;
	  }
	}
  }
  
  <%-- WRITE MY DATE --%>
  function writeMyDate(sObject,sImg,sText,allowPastDates,allowFutureDates){
    var sDir = sImg.substring(0,sImg.lastIndexOf("/"))+"";
    var gfPopType = "1"; // default mode

    if(allowPastDates==undefined){
      allowPastDates = true;
    }
    if(allowFutureDates==undefined){
      allowFutureDates = true;
    }

    if(allowPastDates && allowFutureDates){
      gfPopType = "1";
    }
    else{
           if(allowFutureDates) gfPopType = "3";
      else if(allowPastDates)   gfPopType = "2";
    }

    document.write("<a href='javascript:void(0);' tabindex='998' onclick='if(self.gfPop"+gfPopType+"<%=(sWebLanguage.equalsIgnoreCase("f")?"fr":"nl")%>)gfPop"+gfPopType+"<%=(sWebLanguage.equalsIgnoreCase("f")?"fr":"nl")%>.fPopCalendar(document.all[\""+sObject+"\"]);return false;' HIDEFOCUS>" +
                    "<img name='popcal' class='link' src='"+sImg+"' alt='<%=getTranNoLink("web","Select",sWebLanguage)%>'>"+
                   "</a>&nbsp;"+
                   "<a href='javascript:void(0);' tabindex='999' onClick='getToday("+sObject+");'>"+
                    "<img name='todayButton' class='link' src='"+sDir+"/compose.gif' alt='<%=getTranNoLink("web","putToday",sWebLanguage)%>'>"+
                   "</a>");
  }

  <%-- SET DEFAULT VALUE URL --%>
  function setDefaultValueUrl(itemType,tranType,textFieldOrTextArea){
    // empty
  }

  <%-- SET URLS --%>
  function setUrls(itemType){
    if(itemType==null) itemType = "";

    if(itemType.indexOf("CALCULATED_BMI") > 0){
      sHistoryUrl = "<c:url value="/healthrecord/itemHistoryBMI.jsp"/>?itemType="+itemType+"&ts=<%=getTs()%>";
      sGraphUrl = "<c:url value="/healthrecord/itemGraphBMI.jsp"/>?itemType="+itemType+"&ts=<%=getTs()%>";
    }
    else if(itemType.indexOf("CALCULATED_RESPI") > 0){
      sHistoryUrl = "<c:url value="/healthrecord/itemHistoryRespi.jsp"/>?itemType="+itemType+"&ts=<%=getTs()%>";
      sGraphUrl = "<c:url value="/healthrecord/itemGraphRespi.jsp"/>?itemType="+itemType+"&ts=<%=getTs()%>";
    }
    else{
      sHistoryUrl = "<c:url value="/healthrecord/itemHistory.jsp"/>?itemType="+itemType+"&ts=<%=getTs()%>";
      sGraphUrl = "<c:url value="/healthrecord/itemGraph.jsp"/>?itemType="+itemType+"&ts=<%=getTs()%>";
    }
  }

  <%-- SET POPUP DEFAULT --%>
  function setPopupDefault(forced){
	  
  }

  <%-- SET POPUP MAXI --%>
  function setPopupMaxi(itemType){
	  
  }

  <%-- SET POPUP MINI --%>
  function setPopupMini(itemType){
	  
  }

  <%-- HIDE SELECTS --%>
  function hideSelects(){
    var selects = document.getElementsByTagName("SELECT");
    for(var i=0; i<selects.length; i++){
      selects[i].style.visibility = "hidden";
    }
  }

  <%-- UNHIDE SELECTS --%>
  function unhideSelects(){
    var selects = document.getElementsByTagName("SELECT");
    for(var i=0; i<selects.length; i++){
      selects[i].style.visibility = "visible";
    }
  }

  <%-- CLEAR POPUP --%>
  function clearPopup(){
    document.oncontextmenu = null;
    contextMenuShown = false;
  }

  <%-- GET VALUE FROM TEXTFIELD OR TEXTAREA --%>
  function getValueFromTFOrTA(textFieldOrTA){
    var value;
    if(textFieldOrTA.value==undefined){
      value = textFieldOrTA.innerHTML;
    }
    else{
      value = textFieldOrTA.value;
    }

    if(value==undefined){
      value = "";
    }

    return value;
  }

  <%-- OPEN PAGE --%>
  function openPage(url,name,parameters){
    window.open(url,name,parameters);
  }
</script>

<body id="body" style="padding:3px" onLoad="setContextMenu(event);" onclick="hidemenuie5(event);setContextMenu(event);" onmouseover="setContextMenu(event);">
    <%
       	if(noBackButton){
       		// no button at all; only at the bottom
       	}
       	else{
            %>
                <br>

                <%-- BUTTONS --%>
                <p align="center">
                    <input type="button" class="button" name="ButtonBackDoNotHide1" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onclick="backToOverview();">
                    <input type="button" class="button" name="ButtonCloseDoNotHide1" value="<%=getTranNoLink("web","close",sWebLanguage)%>" onclick="window.close();">
                </p>
            <%
       	}
    %>

    <% ScreenHelper.setIncludePage("/healthrecord/content.jsp",pageContext); %>

    <script>
      window.resizeTo(1100,800);
      <%=sCenterWindow%>

      window.onerror = noError;
      hideButtons();
      hidePrintlanguageSelector();

      document.getElementById("ButtonBackDoNotHide1").style.visibility = "";
      document.getElementById("ButtonCloseDoNotHide1").style.visibility = "";

      <%-- NO ERROR --%>
      function noError(){
        return true;
      }
      
      <%-- BACK TO OVERVIEW --%>
      function backToOverview(){
    	window.location.href = "<%=sCONTEXTPATH%>/healthrecord/showTransactionHistoryWithItems.jsp?ts=<%=getTs()%>";
      }

      <%-- HIDE BUTTONS --%>
      function hideButtons(){
        <%-- hide buttons (1) --%>
        var inputElements = document.getElementsByTagName("INPUT");
        for(var i=0; i<inputElements.length; i++){
          if(inputElements[i].className=="button"){
            if(inputElements[i].name==null || (inputElements[i].name!=null && inputElements[i].name.indexOf("DoNotHide") < 0)){
              inputElements[i].style.visibility = "hidden";
            }
          }
        }

        <%-- hide buttons (2) --%>
        inputElements = document.getElementsByTagName("BUTTON");
        for(var i=0; i<inputElements.length; i++){
          if(inputElements[i].name==null || (inputElements[i].name!=null && inputElements[i].name.indexOf("DoNotHide") < 0)){
            inputElements[i].style.visibility = "hidden";
          }
        }
      }

      <%-- HIDE PRINTLANGUAGE SELECTOR --%>
      function hidePrintlanguageSelector(){
        var inputElement = document.all["PrintLanguage"];
        if(inputElement!=null) inputElement.style.visibility = "hidden";

        inputElement = document.getElementById("printLanguage");
        if(inputElement!=null) inputElement.style.visibility = "hidden";

        inputElement = document.getElementById("PrintLanguage");
        if(inputElement!=null) inputElement.style.visibility = "hidden";
      }
      
      <%-- GET CONTENT TAB --%>
      function getContentTab(sPage,sDiv){
        var url = "<c:url value='/projects/medwan/healthrecord/'/>"+sPage+
                  "?skipRequestQueue=true"+
        		  "&ts=<%=getTs()%>";
        setWaitMsg(sDiv);
        
        new Ajax.Request(url,
          {
            onSuccess: function(resp){
              var respText = convertSpecialCharsToHTML(resp.responseText);
              $(sDiv).innerHTML = respText;
              hideButtons(); <%-- hide buttons when page is loaded by ajax --%>
            },
            onFailure: function(resp){
              alert("ERROR :\n"+resp.responseText);
            }
          }
        );
      }
    </script>

    <%
       	if(noBackButton){
            %>
                <%-- BUTTONS --%>
                <p align="center">
                    <input type="button" class="button" name="ButtonCloseDoNotHide2" value="<%=getTranNoLink("web","close",sWebLanguage)%>" onclick="window.close();">
                </p>

                <br>
            <%
       	}
       	else{
            %>
                <%-- BUTTONS --%>
                <p align="center">
                    <input type="button" class="button" name="ButtonBackDoNotHide2" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onclick="backToOverview();">
                    <input type="button" class="button" name="ButtonCloseDoNotHide2" value="<%=getTranNoLink("web","close",sWebLanguage)%>" onclick="window.close();">
                </p>

                <br>
            <%
       	}
    %>
    
    <script>resizeAllTextareas(10);</script>
</body>
</html>

<%
    // set previous active tran as current tran again
    sessionContainerWO.setCurrentTransactionVO(currentTran);
%>