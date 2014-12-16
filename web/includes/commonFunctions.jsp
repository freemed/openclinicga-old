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
      alert(labelId); // FF          
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
      alert(labelId); // FF          
    }
  }

  <%-- YESNO DIALOG --%>
  function yesnoDialog(labelType,labelId){
    var answer = "";
    
    if(window.showModalDialog){
      var popupUrl = "<c:url value='/_common/search/yesnoPopup.jsp'/>?ts="+new Date().getTime()+"&labelType="+labelType+"&labelID="+labelId;
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
      var popupUrl = "<c:url value='/_common/search/yesnoPopup.jsp'/>?ts="+new Date().getTime()+"&labelValue="+labelText;
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      answer = window.showModalDialog(popupUrl,"",modalities);
    }
    else{
      answer = window.confirm(labelText);          
    }
    
    return answer; // FF
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