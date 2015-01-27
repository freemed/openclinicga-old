<%@page import="be.mxs.common.util.system.ScreenHelper"%>

<script>  
  <%-- ALERT DIALOG --%>
  function alertDialog(labelType,labelId){
    if(window.showModalDialog){
      var popupUrl = "<c:url value='/_common/search/okPopup.jsp'/>?ts=<%=ScreenHelper.getTs()%>&labelType="+labelType+"&labelID="+labelId;
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      window.showModalDialog(popupUrl,"",modalities);
    }
    else{
   	  alertDialogAjax(labelType,labelId); // Opera          
    }
  }
  
  <%-- ALERT DIALOG DIRECT TEXT --%>
  function alertDialogDirectText(sMsg){
    if(window.showModalDialog){
      var popupUrl = "<c:url value='/_common/search/okPopup.jsp'/>?ts=<%=ScreenHelper.getTs()%>&labelValue="+sMsg;
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      window.showModalDialog(popupUrl,"",modalities);
    }
    else{
      alert(sMsg); // Opera          
    }
  }

  <%-- ALERT DIALOG AJAX --%>
  function alertDialogAjax(labelType,labelId){
    var url = "<c:url value='/_common/getLabel.jsp'/>?ts=<%=ScreenHelper.getTs()%>&LabelType="+labelType+"&LabelId="+labelId;
    new Ajax.Request(url,{
      onSuccess:function(resp){
        var label = resp.responseText.trim();
        if(label.length > 0){
          label = convertSpecialCharsToHTML(label);
          alertDialogDirectText(label);
        }
        else{
          alert(labelType+"."+labelId);
        }
      }
    });
  }

  <%-- YESNO DIALOG --%>
  function yesnoDialog(labelType,labelId){
    var answer = "";
    
    if(window.showModalDialog){
      var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/yesnoPopup.jsp&ts="+new Date().getTime()+"&labelType="+labelType+"&labelID="+labelId;
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      answer = window.showModalDialog(popupUrl,"",modalities);
    }
    else{       
      var url = "<c:url value='/_common/getLabel.jsp'/>?ts=<%=ScreenHelper.getTs()%>&LabelType="+labelType+"&LabelId="+labelId;
      new Ajax.Request(url,{
        onSuccess:function(resp){
          var label = resp.responseText.unhtmlEntities();
          if(label.length > 0){
        	answer = yesnoDialogDirectText(label);
          }
          else{
        	answer = window.confirm(labelType+"."+labelId);
          }
        }
      });
    }
    
    return answer;
  }
  
  <%-- YESNO DIALOG DIRECT TEXT --%>
  function yesnoDialogDirectText(labelText){
    var answer = "";
    
    if(window.showModalDialog){
      var popupUrl = "<c:url value='/_common/search/yesnoPopup.jsp'/>?ts="+new Date().getTime()+"&labelValue="+labelText;
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      answer = window.showModalDialog(popupUrl,"",modalities);
    }
    else{
      answer = window.confirm(labelText);          
    }
    
    return answer; // FF
  }
    
  <%-- YESNO DELETE DIALOG --%>
  function yesnoDeleteDialog(){
	<%
	    /*
        String sAPPTITLE = ScreenHelper.checkString((String)session.getAttribute("activeProjectTitle"));
	    if(sAPPTITLE.length()==0) sAPPTITLE = "Openclinic";
	    
        String sWebLanguage = ScreenHelper.checkString((String)session.getAttribute(sAPPTITLE+"WebLanguage"));
        */
	%>
	return yesnoDialogDirectText("<%=ScreenHelper.getTranNoLink("Web","areYouSureToDelete",sWebLanguage)%>");	
  }
  
  <%-- PROMPT DIALOG --%>
  function promptDialog(labelType,labelId){
    var answer = "";
    
    if(window.showModalDialog){
      var popupUrl = "<c:url value='/_common/search/promptPopup.jsp'/>?ts=<%=ScreenHelper.getTs()%>&labelType="+labelType+"&labelID="+labelId;
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      answer = window.showModalDialog(popupUrl,"",modalities);
    }
    else{
      answer = window.confirm(labelId);          
    }
    
    return answer; // FF
  } 
  
  <%-- ENTER EVENT --%>
  function enterEvent(e,targetKeyCode){
    var eventKey = e.which?e.which:window.event.keyCode;
	return (eventKey==targetKeyCode);
  }
	  
  <%-- ENTER KEY PRESSED --%>
  function enterKeyPressed(e){
    var eventKey = e.which?e.which:window.event.keyCode;
	return (eventKey==13);
  }

  <%-- DELETE KEY PRESSED --%>
  function deleteKeyPressed(e){
	var eventKey = e.which?e.which:window.event.keyCode;
	return (eventKey==46);	
  }
</script>