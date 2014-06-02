<%@page errorPage="/includes/error.jsp"%>
<%@include file="/_common/templateAddIns.jsp"%>
<html>
<head>
    <%=sCSSNORMAL%>
    <%=sJSCHAR%>
    <%=sJSDATE%>
    <%=sJSPOPUPSEARCH%>
    <%=sJSDROPDOWNMENU%>
    <%=sJSPROTOTYPE%>
    <%=sJSNUMBER%>
    <%=sJSTOGGLE%>
        
<%
    String sPopupPage = checkString(request.getParameter("Page"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n############################# /popup.jsp ##############################");
        Debug.println("sPopupPage : "+sPopupPage+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
%>
<script>  
	var dateFormat = "<%=ScreenHelper.stdDateFormat.toPattern()%>";
  <%-- ALERT DIALOG --%>
  function alertDialog(labelType,labelId){
    if(window.showModalDialog){
      var popupUrl = "<c:url value='/_common/search/okPopup.jsp'/>?ts=<%=ScreenHelper.getTs()%>&labelType="+labelType+"&labelID="+labelId;
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      window.showModalDialog(popupUrl,"",modalities);
    }
    else{
      alert(labelId); // FF          
    }
  }
  
  <%-- ALERT DIALOG MESSAGE --%>
  function alertDialogMessage(sMsg){
    if(window.showModalDialog){
      var popupUrl = "<c:url value='/_common/search/okPopup.jsp'/>?ts=<%=ScreenHelper.getTs()%>&labelValue="+sMsg;
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      window.showModalDialog(popupUrl,"",modalities);
    }
    else{
      alert(labelId); // FF          
    }
  }

  <%-- CONFIRM DIALOG --%>
  function confirmDialog(labelType,labelId){
    var answer = "";
    
    if(window.showModalDialog){
      var popupUrl = "<c:url value='/_common/search/okPopup.jsp'/>?ts=<%=ScreenHelper.getTs()%>&labelType="+labelType+"&labelID="+labelId;
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      answer = window.showModalDialog(popupUrl,"",modalities);
    }
    else{
      answer = window.confirm(labelId);          
    }
    
    return answer; // FF
  }

  <%-- YESNO DIALOG --%>
  function yesnoDialog(labelType,labelId){
    var answer = "";
    
    if(window.showModalDialog){
      var popupUrl = "<c:url value='/_common/search/yesnoPopup.jsp'/>?ts=<%=ScreenHelper.getTs()%>&labelType="+labelType+"&labelID="+labelId;
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      answer = window.showModalDialog(popupUrl,"",modalities);
    }
    else{
      answer = window.confirm(labelId);          
    }
    
    return answer; // FF
  }
  
  <%-- YESNO DIALOG DIRECT TEXT --%>
  function yesnoDialogDirectText(labelText){
    var answer = "";
    
    if(window.showModalDialog){
      var popupUrl = "<c:url value='/_common/search/yesnoPopup.jsp'/>?ts=<%=ScreenHelper.getTs()%>&labelValue="+labelText;
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      answer = window.showModalDialog(popupUrl,"",modalities);
    }
    else{
      answer = window.confirm(labelText);          
    }
    
    return answer; // FF
  }
</script>
    
<script>
  var ie = document.all
  var ns6 = document.getElementById && !document.all

  <%-- OPEN POPUP --%>
  function openPopup(page,width,height,title){
    var url = "<c:url value="/popup.jsp"/>?Page="+page;
    if(width != undefined) url += "&PopupWidth="+width;
    if(height != undefined) url += "&PopupHeight="+height;
    if(title == undefined){
      if(page.indexOf("&") < 0) {
        title = page.replace("/", "_");
      }
      else{
        title = replaceAll(page.substring(1, page.indexOf("&")), "/", "_");
        title = replaceAll(title, ".", "_");
      }
    }
        
    var w = window.open(url,title,"toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=1,height=1,menubar=no");
    w.moveBy(2000, 2000);
  }

  function replaceAll(s,s1,s2){
    while(s.indexOf(s1) > -1){
      s = s.replace(s1,s2);
    }
    return s;
  }

  <%-- ENTER EVENT --%>
  var desKey = 13;
  function enterEvent(e){
    var key = e.which?e.which:window.event.keyCode;
    if(key==desKey){
      return true;
    }
    else{
      return false;
    }
  }

  <%-- AJAX CHANGE SEARCH RESULTS --%>
  function ajaxChangeSearchResults(urlForm,SearchForm,moreParams){
    document.getElementById('divFindRecords').innerHTML = "<div style='text-align:center'><img src='<c:url value="/_img/ajax-loader.gif"/>'/><br/>Loading</div>";
    var url = urlForm;
    var params = Form.serialize(SearchForm)+moreParams;
    var myAjax = new Ajax.Updater("divFindRecords",url,{
      evalScripts:true,
      method: "post",
      parameters: params,
      onload: function(){
      },
      onSuccess: function(resp){
        document.getElementById("divFindRecords").innerHTML = trim(resp.responseText);
      },
      onFailure:function(){
        $("divFindRecords").innerHTML = "Problem with ajax request !";
      }
    });
  }
</script>
  
    <title><%=sWEBTITLE+" "+sAPPTITLE%></title>
</head>

<%-- Start Floating Layer -----------------------------------------------------------------------%>
<div id="FloatingLayer" style="position:absolute;width:250px;height:30px;visibility:hidden">
    <table width="100%" cellspacing="0" cellpadding="5" style="border:1px solid #aaa">
        <tr>
            <td bgcolor="#dddddd" style="text-align:center">
                <%=getTran("web","searchInProgress",sWebLanguage)%>
            </td>
        </tr>
    </table>
</div>

<%-- End Floating layer -------------------------------------------------------------------------%>
<body style="margin:2px;" onload="resizeMe();">
<table width="100%" border="0" cellspacing="0" cellpadding="0" id="popuptbl" height="100%">
    <tr>
        <td colspan="3" style="vertical-align:top;" height="100%">
            <%
                response.setHeader("Pragma","no-cache"); //HTTP 1.0
                response.setDateHeader("Expires",0); //prevents caching at the proxy server
                ScreenHelper.setIncludePage("/"+customerInclude(sPopupPage),pageContext);
            %>
        </td>
    </tr>
</table>

<script>
  <%=getUserInterval(session,activeUser)%>

  function resizeMe(){
    <%
		String sPopupWidth = checkString(request.getParameter("PopupWidth"));
		if(sPopupWidth.length() > 0){
            %>w = <%=sPopupWidth%>;<%
		}
		else{
            %>
	        if(ie){
	          rcts = popuptbl.getClientRects();
	          w = rcts[0].right;
	        } 
	        else{
	          w = document.getElementById("popuptbl").clientWidth;
	        }
            <%
		}

		String sPopupHeight = checkString(request.getParameter("PopupHeight"));
		if(sPopupHeight.length() > 0){
            %>h =<%=sPopupHeight%>;<%
		}
		else{
            %>
	        if(ie){
	          rcts = popuptbl.getClientRects();
	          h = rcts[0].bottom+80;
	        }
	        else{
	          h = document.getElementById("popuptbl").clientHeight;
	        }
            <%
        }
    %>
    
    if(h > 800) h = 800;
    if(h > screen.height) h = screen.height;
    w = w+35;
    if(w < 400) w = 400;
    h = h+80;
    window.resizeTo(w,h);
    window.moveTo((screen.width-w)/2,(screen.height-h)/2);
  }
  
  if(typeof focusfield != "undefined") focusfield.focus();
  window.setTimeout('resizeMe();',200);
</script>
</body>
</html>